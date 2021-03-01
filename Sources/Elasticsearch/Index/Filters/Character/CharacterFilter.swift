import Foundation


/// :nodoc:
public protocol CharacterFilter: Codable {
    static var typeKey: CharacterFilterType { get }
    var name: String { get }
}

/// :nodoc:
public protocol BuiltinCharacterTokenFilter {
    init()
}

/// :nodoc:
public enum CharacterFilterType: String, Codable {
    case htmlStrip = "html_strip"
    case mapping
    case patternReplace = "pattern_replace"
    
    var metatype: CharacterFilter.Type {
        switch self {
        case .htmlStrip:
            return HTMLStripCharacterFilter.self
        case .mapping:
            return MappingCharacterFilter.self
        case .patternReplace:
            return PatternReplaceCharacterFilter.self
        }
    }
    
    enum Builtins: String, CodingKey {
        case htmlStrip = "html_strip"
        
        var metatype: BuiltinCharacterTokenFilter.Type {
            switch self {
            case .htmlStrip:
                return HTMLStripCharacterFilter.self
            }
        }
    }
}

/// :nodoc:
internal struct AnyCharacterFilter : Codable {
    var base: CharacterFilter
    
    init(_ base: CharacterFilter) {
        self.base = base
    }
    
    /// :nodoc:
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicKey.self)
        
        let type = try container.decode(CharacterFilterType.self, forKey: DynamicKey(stringValue: "type")!)
        self.base = try type.metatype.init(from: decoder)
    }
    
    /// :nodoc:
    public func encode(to encoder: Encoder) throws {
        try base.encode(to: encoder)
    }
}


/**
 The HTML strip character filter strips HTML elements from the text and replaces HTML entities with their decoded value (e.g. replacing &amp; with &).

 [More Information](https://www.elastic.co/guide/en/elasticsearch/reference/current/analysis-htmlstrip-charfilter.html)
 */
public struct HTMLStripCharacterFilter: CharacterFilter, BuiltinCharacterTokenFilter {
    /// :nodoc:
    public static var typeKey = CharacterFilterType.htmlStrip

    /// Holds the string that Elasticsearch uses to identify the filter type
    public let type = typeKey.rawValue
    public let name: String
    public let escapedTags: [String]?

    let isCustom: Bool

    enum CodingKeys: String, CodingKey {
        case type
        case escapedTags = "escaped_tags"
    }

    public init() {
        self.name = type
        self.isCustom = false
        self.escapedTags = nil
    }

    public init(name: String, escapedTags: [String]) {
        self.name = name
        self.escapedTags = escapedTags
        self.isCustom = true
    }

    /// :nodoc:
    public func encode(to encoder: Encoder) throws {
        if self.isCustom {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(type, forKey: .type)
            try container.encode(escapedTags, forKey: .escapedTags)
        }
        else {
            var container = encoder.singleValueContainer()
            try container.encode(type)
        }
    }

    /// :nodoc:
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = (decoder.codingPath.last?.stringValue)!

        self.escapedTags = try container.decodeIfPresent([String].self, forKey: .escapedTags)
        self.isCustom = true
    }
}

public struct MappingCharacterFilter: CharacterFilter {
    /// :nodoc:
    public static var typeKey = CharacterFilterType.mapping

    /// Holds the string that Elasticsearch uses to identify the filter type
    public let type = typeKey.rawValue
    public let name: String
    public let mappings: [String: String]?
    public let mappingsPath: String?

    enum CodingKeys: String, CodingKey {
        case type
        case mappings
        case mappingsPath = "mappings_path"
    }

    public init(name: String, mappings: [String: String]) {
        self.name = name
        self.mappings = mappings
        self.mappingsPath = nil
    }

    public init(name: String, mappingsPath: String) {
        self.name = name
        self.mappings = nil
        self.mappingsPath = mappingsPath
    }

    /// :nodoc:
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = (decoder.codingPath.last?.stringValue)!

        self.mappings = try container.decodeIfPresent([String: String].self, forKey: .mappings)
        self.mappingsPath = try container.decodeIfPresent(String.self, forKey: .mappingsPath)
    }
}

/**
 The pattern replace character filter uses a regular expression to match characters which should be replaced with the specified replacement string. The replacement string can refer to capture groups in the regular expression.

 [More information](https://www.elastic.co/guide/en/elasticsearch/reference/current/analysis-pattern-replace-charfilter.html)
 */
public struct PatternReplaceCharacterFilter: CharacterFilter {
    /// :nodoc:
    public static var typeKey = CharacterFilterType.patternReplace

    /// Holds the string that Elasticsearch uses to identify the filter type
    public let type = typeKey.rawValue
    public let name: String
    public var pattern: String
    public var replacement: String
    public var flags: String?

    enum CodingKeys: String, CodingKey {
        case type
        case pattern
        case replacement
        case flags
    }

    public init(name: String, pattern: String, replacement: String, flags: String? = nil) {
        self.name = name
        self.pattern = pattern
        self.replacement = replacement
        self.flags = flags
    }

    /// :nodoc:
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = (decoder.codingPath.last?.stringValue)!

        self.pattern = try container.decode(String.self, forKey: .pattern)
        self.replacement = try container.decode(String.self, forKey: .replacement)
        self.flags = try container.decodeIfPresent(String.self, forKey: .flags)
    }
}
