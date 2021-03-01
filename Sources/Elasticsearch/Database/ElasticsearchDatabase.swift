import DatabaseKit
import Async
import Foundation

public final class ElasticsearchDatabase: Database {
    public typealias Connection = ElasticsearchClient
    
    /// This client's configuration.
    public let config: ElasticsearchClientConfig
    
    /// Creates a new `ElasticsearchDatabase`.
    public init(config: ElasticsearchClientConfig) { 
        self.config = config
    }
    
    public init(url: URL) {
        self.config = ElasticsearchClientConfig(url: url)
    }
    
    /// See `Database`.
    public func newConnection(on worker: Worker) -> Future<ElasticsearchClient> {
        return ElasticsearchClient.connect(config: config, on: worker)
    }
}

/// :nodoc:
extension DatabaseIdentifier {
    /// Default identifier for `ElasticsearchClient`.
    public static var elasticsearch: DatabaseIdentifier<ElasticsearchDatabase> {
        return .init("elasticsearch")
    }
}

/**
 Keyed cache supporting
 */
extension ElasticsearchDatabase: KeyedCacheSupporting {
    static func setupKeyedCache(client: ElasticsearchClient, on worker: Worker) -> Future<Void> {
        if client.config.enableKeyedCache == false {
            return .done(on: worker)
        }

        client.logger?.record(query: "Keyed cached is enabled")

        return client.fetchIndex(name: client.config.keyedCacheIndexName).flatMap { index -> Future<Void> in
            if index != nil {
                client.logger?.record(query: "Keyed cache index exists")
                return .done(on: worker)
            }

            let index = client.configureIndex(name: client.config.keyedCacheIndexName)
            index.mappings.doc.enabled = false
            index.mappings.doc.dynamic = true
            return index.create(client: client)
        }
    }

    public static func keyedCacheGet<D>(_ key: String, as decodable: D.Type, on conn: ElasticsearchClient) throws -> EventLoopFuture<D?> where D : Decodable {
        return conn.get(decodeTo: D.self, index: conn.config.keyedCacheIndexName, id: key).map(to: D?.self) { result in
            if let result = result {
                return result.source
            }
            return nil
        }
    }

    public static func keyedCacheSet<E>(_ key: String, to encodable: E, on conn: ElasticsearchClient) throws -> EventLoopFuture<Void> where E : Encodable {
        return conn.index(doc: encodable, index: conn.config.keyedCacheIndexName, id: key).map(to: Void.self, { _ in
            return
        })
    }

    public static func keyedCacheRemove(_ key: String, on conn: ElasticsearchClient) throws -> EventLoopFuture<Void> {
        return conn.delete(index: conn.config.keyedCacheIndexName, id: key).map(to: Void.self) { _ in
            return
        }
    }
}

/**
 Log supporting
 */
extension ElasticsearchDatabase: LogSupporting {
    /// See `LogSupporting`.
    public static func enableLogging(_ logger: DatabaseLogger, on conn: ElasticsearchDatabase.Connection) {
        conn.logger = logger
    }
}
