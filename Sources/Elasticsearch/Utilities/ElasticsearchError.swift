import Debugging
import COperatingSystem

public enum ElasticsearchErrorIdentifier: LocalizedError {
    case noActiveNodes
    case connectionFailed
    case emptyResponse
    case invalidResponse
    case unknown
    case searchFailed
    case urlError

    public var localized: String {
        switch self {
        case .noActiveNodes:
            return "no_active_nodes"
        case .connectionFailed:
            return "connection_failed"
        case .emptyResponse:
            return "empty_response"
        case .invalidResponse:
            return "invalid_response"
        case .unknown:
            return "es_error"
        case .searchFailed:
            return "search_failed"
        case .urlError:
            return "url_error"
        }
    }

    public var errorDescription: String? {
        switch self {
        case .noActiveNodes:
            return "No active available nodes in cluster"
        case .connectionFailed:
            return "Could not connect to Elasticsearch"
        case .emptyResponse:
            return "Missing response body from Elasticsearch"
        case .invalidResponse:
            return "Cannot parse response body from Elasticsearch"
        case .unknown:
            return "Error"
        case .searchFailed:
            return "Could not execute search"
        case .urlError:
            return "Url error"
        }
    }
}

/// Errors that can be thrown while working with Elasticsearch.
public struct ElasticsearchError: Debuggable {
    public static let readableName = "Elasticsearch Error"
    public let identifier: String
    public var reason: String
    public var sourceLocation: SourceLocation?
    public var stackTrace: [String]
    public var possibleCauses: [String]
    public var suggestedFixes: [String]
    public var statusCode: UInt?

    /// Create a new Elasticsearch error.
    public init(
        identifier: String,
        reason: String,
        possibleCauses: [String] = [],
        suggestedFixes: [String] = [],
        source: SourceLocation,
        statusCode: UInt? = nil
    ) {
        self.identifier = identifier
        self.reason = reason
        self.sourceLocation = source
        self.stackTrace = ElasticsearchError.makeStackTrace()
        self.possibleCauses = possibleCauses
        self.suggestedFixes = suggestedFixes
        self.statusCode = statusCode
    }
}

extension ElasticsearchError {
    public static func report(error identifier: ElasticsearchErrorIdentifier, attach description: String? = nil, statusCode: UInt? = nil) -> ElasticsearchError {
        return ElasticsearchError(identifier: identifier.localized, reason: "\(identifier.localizedDescription) + \(description ?? "")", source: .capture(), statusCode: statusCode)
    }
}
