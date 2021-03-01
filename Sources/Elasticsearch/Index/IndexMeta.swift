import Foundation

/// :nodoc:
internal struct IndexMeta: Codable {
    var `private`: PrivateIndexMeta
    var userDefined: [String: String]?
    
    init() {
        self.private = PrivateIndexMeta(version: 1)
    }
}

/// :nodoc:
public struct PrivateIndexMeta: Codable {
    let serialVersion: Int
    var propertiesHash: String
    
    init(version: Int) {
        self.serialVersion = version
       self.propertiesHash = ""
    }
}

public protocol IndexModifies {
    mutating func modifyAfterReceiving(index: ElasticsearchIndex)
}

public struct IndexSettings: Codable {
    let numberOfShards: Int
    let numberOfReplicas: Int
    var creationDate: String? = nil
    var uuid: String? = nil
    var version: Version? = nil
    var providedName: String? = nil

    enum CodingKeys: String, CodingKey {
        case numberOfShards = "number_of_shards"
        case numberOfReplicas = "number_of_replicas"
        case creationDate = "creation_date"
        case uuid
        case version
        case providedName = "provided_name"
    }

    public init(shards: Int, replicas: Int) {
        numberOfShards = shards
        numberOfReplicas = replicas
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        numberOfShards = Int(try container.decode(String.self, forKey: .numberOfShards))!
        numberOfReplicas = Int(try container.decode(String.self, forKey: .numberOfReplicas))!
        creationDate = try container.decodeIfPresent(String.self, forKey: .creationDate)
        uuid = try container.decodeIfPresent(String.self, forKey: .uuid)
        version = try container.decodeIfPresent(Version.self, forKey: .version)
        providedName = try container.decodeIfPresent(String.self, forKey: .providedName)
    }

    public struct Version: Codable {
        let created: String
    }
}
