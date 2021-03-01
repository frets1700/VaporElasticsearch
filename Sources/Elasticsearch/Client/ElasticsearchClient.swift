import HTTP
import DatabaseKit

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
