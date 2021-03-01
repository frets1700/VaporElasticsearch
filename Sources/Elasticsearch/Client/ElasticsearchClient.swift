import HTTP
import DatabaseKit
import Async

/// A Elasticsearch client.
public final class ElasticsearchClient: DatabaseConnection, BasicWorker {
    public typealias Database = ElasticsearchDatabase
    
    /// See `BasicWorker`.
    public var eventLoop: EventLoop {
        return worker.eventLoop
    }
    
    /// See `DatabaseConnection`.
    public var isClosed: Bool

    /// If non-nil, will log requests/reponses.
    public var logger: DatabaseLogger?

    /// See `Extendable`.
    public var extend: Extend
    
    /// The HTTP connection
    private var esConnection: HTTPClient?
    
    public let worker: Worker
    public var isConnected: Bool

    internal let encoder = JSONEncoder()
    internal let decoder = JSONDecoder()
    internal let config: ElasticsearchClientConfig
    
    /// Creates a new Elasticsearch client.
    public init(client: HTTPClient, config: ElasticsearchClientConfig, worker: Worker) {
        self.esConnection = client
        self.extend = [:]
        self.isClosed = false
        self.isConnected = false
        self.config = config
        self.worker = worker
    }
    
    /// Closes this client.
    public func close() {
        self.isClosed = true
        esConnection?.close().do() {[weak self] in
            self?.isClosed = true
            self?.isConnected = false
            self?.esConnection = nil
        }.catch() {[weak self] error in
            self?.isClosed = true
            self?.isConnected = false
            self?.esConnection = nil
        }
    }

    internal static func generateURL(
        path: String,
        routing: String? = nil,
        version: Int? = nil,
        storedFields: [String]? = nil,
        realtime: Bool? = nil,
        forceCreate: Bool? = nil
    ) -> URLComponents {
        var url = URLComponents()
        url.path = path
        var query = [URLQueryItem]()

        if routing != nil {
            query.append(URLQueryItem(name: "routing", value: routing))
        }

        if let version = version {
            query.append(URLQueryItem(name: "version", value: "\(version)"))
        }

        if let storeField = storedFields {
            query.append(URLQueryItem(name: "stored_fields", value: storeField.joined(separator: ",")))
        }

        if let realtime = realtime {
            query.append(URLQueryItem(name: "realtime", value: realtime ? "true" : "false"))
        }

        url.queryItems = query
        
        return url
    }
    
    public func send(
        _ method: HTTPMethod,
        to path: String
    ) -> Future<Data?> {
        let httpReq = HTTPRequest(method: method, url: path)
        return send(httpReq)
    }
    
    public func send(
        _ method: HTTPMethod,
        to path: String,
        with body: Dictionary<String, Any>
    ) -> Future<Data?> {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
            return send(method, to: path, with: jsonData)
        } catch {
            return worker.future(error: error)
        }
    }
    
    public func send(
        _ method: HTTPMethod,
        to path: String,
        with body: Data
    ) -> Future<Data?> {
        let httpReq = HTTPRequest(method: method, url: path, body: HTTPBody(data: body))
        return send(httpReq)
    }
    
    public func send(
        _ request: HTTPRequest
    ) -> Future<Data?> {
        var request = request
        if request.headers.contains(name: "Content-Type") == false {
            request.headers.add(name: "Content-Type", value: "application/json")
        }

        if let username = self.config.username, let password = self.config.password {
            let token = "\(username):\(password)".data(using: String.Encoding.utf8)?.base64EncodedString()
            if let token = token {
                request.headers.add(name: "Authorization", value: "Basic \(token)")
            }
        }

        logger?.record(query: request.description)

        guard let esConnection = self.esConnection else {
            return future(error: ElasticsearchError.report(error: .connectionFailed))
        }

        return esConnection.send(request).map(to: Data?.self) {[weak self] response in
            guard let responseData = response.body.data else {
                throw ElasticsearchError.report(error: .emptyResponse)
            }
 
            if response.status.code >= 400 {
                guard let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
                    throw ElasticsearchError.report(error: .invalidResponse)
                }
                
                if response.status.code == 404 {
                    return nil
                }

                var error = ""
                if json["error"] != nil {
                    error = (json["error"] as? Dictionary<String, Any>)?.description ?? ""
                }

                throw ElasticsearchError.report(error: .unknown, attach: error)
            }
            
            let bodyString = String(data: responseData, encoding: String.Encoding.utf8) as String?
            self?.logger?.record(query: bodyString ?? "")
            
            return responseData
        }
    }
}

/// Index Mgt
extension ElasticsearchClient {
    public func fetchIndex(name: String) -> Future<ElasticsearchIndex?> {
        return ElasticsearchIndex.fetch(indexName: name, client: self)
    }

    public func configureIndex(name: String) -> ElasticsearchIndex {
        return ElasticsearchIndex(indexName: name)
    }

    public func deleteIndex(name: String) -> Future<Void> {
        return ElasticsearchIndex.delete(indexName: name, client: self)
    }
}

/**
 Search methods.
 */
extension ElasticsearchClient {
    /// Execute a search in a given index
    ///
    /// - Parameters:
    ///   - decodeTo: A struct or class that conforms to the Decodable protocol and can properly decode the documents stored in the index
    ///   - index: The index to execute the query against
    ///   - query: A SearchContainer object that specifies the query to execute
    ///   - type: The index type (defaults to _doc)
    ///   - routing: Routing information
    /// - Returns: A Future SearchResponse
    public func search<U: Decodable>(
        decodeTo: U.Type,
        index: String,
        query: SearchContainer,
        routing: String? = nil
    ) -> Future<SearchResponse<U>> {
        let body: Data
        do {
            body = try self.encoder.encode(query)
        } catch {
            return worker.future(error: error)
        }

        let url = ElasticsearchClient.generateURL(path: "/\(index)/_search", routing: routing)
        guard let urlString = url.string else {
            return worker.future(error: ElasticsearchError.report(error: .urlError))
        }

        return send(HTTPMethod.POST, to: urlString, with: body).map(to: SearchResponse.self) { jsonData in
            let decoder = JSONDecoder()
            if let aggregations = query.aggs {
                if aggregations.count > 0 {
                    decoder.userInfo(fromAggregations: aggregations)
                }
            }

            if let jsonData = jsonData {
                return try decoder.decode(SearchResponse<U>.self, from: jsonData)
            }

            throw ElasticsearchError.report(error: .searchFailed, attach: nil, statusCode: 404)
        }
    }
}

/**
 Connection methods
 */
extension ElasticsearchClient {
    /// Connects to a Elasticsearch server over HTTP.
    ///
    /// - Parameters:
    ///   - config: The connection configuration to use
    ///   - worker: The worker to execute with
    /// - Returns: An ElasticsearchClient Future
    public static func connect(
        config: ElasticsearchClientConfig,
        on worker: Worker
    ) -> Future<ElasticsearchClient> {
        let clientPromise = worker.eventLoop.newPromise(ElasticsearchClient.self)
        let scheme: HTTPScheme = config.useSSL ? .https : .http
        HTTPClient.connect(scheme: scheme, hostname: config.hostname, port: config.port, on: worker) { error in
            let esError = ElasticsearchError(identifier: "connection_failed", reason: "Could not connect to Elasticsearch: " + error.localizedDescription, source: .capture())
            clientPromise.fail(error: esError)
        }.do() { client in
            let esClient = ElasticsearchClient.init(client: client, config: config, worker: worker)
            esClient.isConnected = true
            clientPromise.succeed(result: esClient)
        }.catch { error in
            let esError = ElasticsearchError(identifier: "connection_failed", reason: "Could not connect to Elasticsearch: " + error.localizedDescription, source: .capture())
            clientPromise.fail(error: esError)
        }

        return clientPromise.futureResult
    }
}

