import Foundation

/// :nodoc:
public protocol Analyzer: Codable {
    static var typeKey: AnalyzerType { get }
    var name: String { get }
}

/// :nodoc:
public protocol BuiltinAnalyzer {
    init()
}

/// :nodoc:
public enum AnalyzerType: String, Codable {
    case standard
    case simple
    case whitespace
    case stop
    case keyword
    case pattern
    case fingerprint
    case custom
    
    var metatype: Analyzer.Type {
        switch self {
        case .standard:
            return StandardAnalyzer.self
        case .simple:
            return SimpleAnalyzer.self
        case .whitespace:
            return WhitespaceAnalyzer.self
        case .stop:
            return StopAnalyzer.self
        case .keyword:
            return KeywordAnalyzer.self
        case .pattern:
            return PatternAnalyzer.self
        case .fingerprint:
            return FingerprintAnalyzer.self
        case .custom:
            return CustomAnalyzer.self
        }
    }
    
    enum Builtins: String, CodingKey {
        case standard
        case simple
        case whitespace
        case keyword
        
        var metatype: BuiltinAnalyzer.Type {
            switch self {
            case .standard:
                return StandardAnalyzer.self
            case .simple:
                return SimpleAnalyzer.self
            case .whitespace:
                return WhitespaceAnalyzer.self
            case .keyword:
                return KeywordAnalyzer.self
            }
        }
    }
}

/// :nodoc:
internal struct AnyAnalyzer : Codable {
    var base: Analyzer
    
    init(_ base: Analyzer) {
        self.base = base
    }
    
    /// :nodoc:
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicKey.self)
        
        let type = try container.decode(AnalyzerType.self, forKey: DynamicKey(stringValue: "type")!)
        self.base = try type.metatype.init(from: decoder)
    }
    
    /// :nodoc:
    public func encode(to encoder: Encoder) throws {
        try base.encode(to: encoder)
    }
}

/**
 Custom Analyzer
 When the built-in analyzers do not fulfill your needs, you can create a custom analyzer which uses the appropriate combination of:

 * a tokenizer
 * zero or more character filters
 * zero or more token filters.

 [More information](https://www.elastic.co/guide/en/elasticsearch/reference/6.3/analysis-custom-analyzer.html)
 */
public struct CustomAnalyzer: Analyzer, DefinesTokenizers, DefinesTokenFilters, DefinesCharacterFilters {
    /// :nodoc:
    public static var typeKey = AnalyzerType.custom

    /// Holds the string that Elasticsearch uses to identify the analyzer type
    public let type = typeKey.rawValue
    public let name: String
    public let tokenizer: Tokenizer
    public let charFilter: [CharacterFilter]?
    public let filter: [TokenFilter]?
    public let positionIncrementGap: Int?

    enum CodingKeys: String, CodingKey {
        case type
        case tokenizer
        case charFilter = "char_filter"
        case filter
        case positionIncrementGap = "position_increment_gap"
    }

    public init(name: String,
                tokenizer: Tokenizer,
                filter: [TokenFilter]? = nil,
                characterFilter: [CharacterFilter]? = nil,
                positionIncrementGap: Int? = nil) {

        self.name = name
        self.tokenizer = tokenizer
        self.filter = filter
        self.charFilter = characterFilter
        self.positionIncrementGap = positionIncrementGap
    }

    /// :nodoc:
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(type, forKey: .type)
        try container.encode(tokenizer.name, forKey: .tokenizer)

        if self.charFilter?.count ?? 0 > 0 {
            var charFilterContainer = container.nestedUnkeyedContainer(forKey: .charFilter)
            if let charFilter = self.charFilter {
                for filter in charFilter {
                    try charFilterContainer.encode(filter.name)
                }
            }
        }

        if self.filter?.count ?? 0 > 0 {
            var tokenFilterContainer = container.nestedUnkeyedContainer(forKey: .filter)
            if let tokenFilter = self.filter {
                for filter in tokenFilter {
                    try tokenFilterContainer.encode(filter.name)
                }
            }
        }

        try container.encodeIfPresent(positionIncrementGap, forKey: .positionIncrementGap)
    }

    /// :nodoc:
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = (decoder.codingPath.last?.stringValue)!

        self.positionIncrementGap = try container.decodeIfPresent(Int.self, forKey: .positionIncrementGap)

        if let analysis = decoder.analysis() {
            let tokenizer = try container.decode(String.self, forKey: .tokenizer)
            self.tokenizer = analysis.tokenizer(named: tokenizer)!

            if let charFilters = try container.decodeIfPresent([String].self, forKey: .charFilter) {
                self.charFilter = charFilters.map { analysis.characterFilter(named: $0)! }
            } else {
                self.charFilter = nil
            }
            if let tokenFilters = try container.decodeIfPresent([String].self, forKey: .filter) {
                self.filter = tokenFilters.map { analysis.tokenFilter(named: $0)! }
            } else {
                self.filter = nil
            }
        }
        else {
            // This should never be called
            self.tokenizer = StandardTokenizer()
            self.charFilter = nil
            self.filter = nil
        }
    }

    /// :nodoc:
    public func definedTokenizers() -> [Tokenizer] {
        return [self.tokenizer]
    }

    /// :nodoc:
    public func definedTokenFilters() -> [TokenFilter] {
        var filters = [TokenFilter]()
        if let tokenFilters = self.filter {
            for filter in tokenFilters {
                filters.append(filter)
            }
        }
        return filters
    }

    /// :nodoc:
    public func definedCharacterFilters() -> [CharacterFilter] {
        var filters = [CharacterFilter]()
        if let charFilters = self.charFilter {
            for filter in charFilters {
                filters.append(filter)
            }
        }
        return filters
    }
}

/**
 FingerPrint Analyzer
 The fingerprint analyzer implements a fingerprinting algorithm which is used by the OpenRefine project to assist in clustering.

 Input text is lowercased, normalized to remove extended characters, sorted, deduplicated and concatenated into a single token. If a stopword list is configured, stop words will also be removed.

 [More information](https://www.elastic.co/guide/en/elasticsearch/reference/6.3/analysis-fingerprint-analyzer.html)
 */
public struct FingerprintAnalyzer: Analyzer {
    /// :nodoc:
    public static var typeKey = AnalyzerType.fingerprint

    /// Holds the string that Elasticsearch uses to identify the analyzer type
    public let type = typeKey.rawValue
    public let name: String
    public let separator: String?
    public let maxOutputSize: Int?
    public let stopwords: [String]?
    public let stopwordsPath: String?

    enum CodingKeys: String, CodingKey {
        case type
        case separator
        case maxOutputSize = "max_output_size"
        case stopwords
        case stopwordsPath = "stopwords_path"
    }

    public init(name: String,
                separator: String? = nil,
                maxOutputSize: Int? = nil,
                stopwords: [String]) {

        self.name = name
        self.separator = separator
        self.maxOutputSize = maxOutputSize
        self.stopwords = stopwords
        self.stopwordsPath = nil
    }

    public init(name: String,
                separator: String? = nil,
                maxOutputSize: Int? = nil,
                stopwordsPath: String) {

        self.name = name
        self.separator = separator
        self.maxOutputSize = maxOutputSize
        self.stopwords = nil
        self.stopwordsPath = stopwordsPath
    }

    /// :nodoc:
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = (decoder.codingPath.last?.stringValue)!

        self.separator = try container.decodeIfPresent(String.self, forKey: .separator)
        self.maxOutputSize = try container.decodeIfPresent(Int.self, forKey: .maxOutputSize)
        self.stopwords = try container.decodeIfPresent([String].self, forKey: .stopwords)
        self.stopwordsPath = try container.decodeIfPresent(String.self, forKey: .stopwordsPath)
    }
}

/**
 The keyword analyzer is a “noop” analyzer which returns the entire input string as a single token.

 [More information](https://www.elastic.co/guide/en/elasticsearch/reference/6.3/analysis-keyword-analyzer.html)
 */
public struct KeywordAnalyzer: Analyzer, BuiltinAnalyzer {
    /// :nodoc:
    public static var typeKey = AnalyzerType.keyword

    /// Holds the string that Elasticsearch uses to identify the analyzer type
    public let type = typeKey.rawValue
    public let name: String

    public init() {
        self.name = type
    }

    /// :nodoc:
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(type)
    }
}

/**
 The pattern analyzer uses a regular expression to split the text into terms. The regular expression should match the token separators not the tokens themselves. The regular expression defaults to \W+ (or all non-word characters).

 [More information](https://www.elastic.co/guide/en/elasticsearch/reference/6.3/analysis-pattern-analyzer.html)
 */
public struct PatternAnalyzer: Analyzer {
    /// :nodoc:
    public static var typeKey = AnalyzerType.pattern

    /// Holds the string that Elasticsearch uses to identify the analyzer type
    public let type = typeKey.rawValue
    public let name: String
    public let pattern: String?
    public let flags: String?
    public let lowercase: Bool?
    public let stopwords: [String]?
    public let stopwordsPath: String?

    enum CodingKeys: String, CodingKey {
        case type
        case pattern
        case flags
        case lowercase
        case stopwords
        case stopwordsPath = "stopwords_path"
    }

    public init(name: String,
                pattern: String? = nil,
                flags: String? = nil,
                lowercase: Bool? = nil,
                stopwords: [String]) {

        self.name = name
        self.pattern = pattern
        self.flags = flags
        self.lowercase = lowercase
        self.stopwords = stopwords
        self.stopwordsPath = nil
    }

    public init(name: String,
                pattern: String? = nil,
                flags: String? = nil,
                lowercase: Bool? = nil,
                stopwordsPath: String) {

        self.name = name
        self.pattern = pattern
        self.flags = flags
        self.lowercase = lowercase
        self.stopwords = nil
        self.stopwordsPath = stopwordsPath
    }

    /// :nodoc:
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = (decoder.codingPath.last?.stringValue)!

        self.pattern = try container.decodeIfPresent(String.self, forKey: .pattern)
        self.flags = try container.decodeIfPresent(String.self, forKey: .flags)
        self.lowercase = try container.decodeIfPresent(Bool.self, forKey: .lowercase)
        self.stopwords = try container.decodeIfPresent([String].self, forKey: .stopwords)
        self.stopwordsPath = try container.decodeIfPresent(String.self, forKey: .stopwordsPath)
    }
}

/**
 The simple analyzer breaks text into terms whenever it encounters a character which is not a letter. All terms are lower cased.

 [More information](https://www.elastic.co/guide/en/elasticsearch/reference/6.3/analysis-simple-analyzer.html)
 */
public struct SimpleAnalyzer: Analyzer, BuiltinAnalyzer {
    /// :nodoc:
    public static var typeKey = AnalyzerType.simple

    /// Holds the string that Elasticsearch uses to identify the analyzer type
    public let type = typeKey.rawValue
    public let name: String

    public init() {
        self.name = type
    }

    /// :nodoc:
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(type)
    }
}

/**
 The standard analyzer is the default analyzer which is used if none is specified. It provides grammar based tokenization (based on the Unicode Text Segmentation algorithm, as specified in Unicode Standard Annex #29) and works well for most languages.

 [More information](https://www.elastic.co/guide/en/elasticsearch/reference/6.3/analysis-standard-analyzer.html)
 */
public struct StandardAnalyzer: Analyzer, BuiltinAnalyzer {
    /// :nodoc:
    public static var typeKey = AnalyzerType.standard

    /// Holds the string that Elasticsearch uses to identify the analyzer type
    public let type = typeKey.rawValue
    public let name: String
    public let maxTokenLength: Int?
    public let stopwords: [String]?
    public let stopwordsPath: String?

    let isCustom: Bool

    enum CodingKeys: String, CodingKey {
        case type
        case maxTokenLength = "max_token_length"
        case stopwords
        case stopwordsPath = "stopwords_path"
    }

    public init() {
        self.name = type
        self.maxTokenLength = nil
        self.stopwords = nil
        self.stopwordsPath = nil
        self.isCustom = false
    }

    public init(name: String, stopwords: [String]? = nil, maxTokenLength: Int? = nil) {
        self.name = name
        self.stopwords = stopwords
        self.stopwordsPath = nil
        self.maxTokenLength = maxTokenLength
        self.isCustom = true
    }

    public init(name: String, stopwordsPath: String? = nil, maxTokenLength: Int? = nil) {
        self.name = name
        self.stopwords = nil
        self.stopwordsPath = stopwordsPath
        self.maxTokenLength = maxTokenLength
        self.isCustom = true
    }

    /// :nodoc:
    public func encode(to encoder: Encoder) throws {
        if self.isCustom {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(type, forKey: .type)
            try container.encodeIfPresent(stopwords, forKey: .stopwords)
            try container.encodeIfPresent(stopwordsPath, forKey: .stopwordsPath)
            try container.encodeIfPresent(maxTokenLength, forKey: .maxTokenLength)
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

        self.maxTokenLength = try container.decodeIfPresent(Int.self, forKey: .maxTokenLength)
        self.stopwords = try container.decodeIfPresent([String].self, forKey: .stopwords)
        self.stopwordsPath = try container.decodeIfPresent(String.self, forKey: .stopwordsPath)
        self.isCustom = true
    }
}

/**
 The stop analyzer is the same as the simple analyzer but adds support for removing stop words.

 [More information](https://www.elastic.co/guide/en/elasticsearch/reference/6.3/analysis-stop-analyzer.html)
 */
public struct StopAnalyzer: Analyzer {
    /// :nodoc:
    public static var typeKey = AnalyzerType.stop

    /// Holds the string that Elasticsearch uses to identify the analyzer type
    public let type = typeKey.rawValue
    public let name: String
    public let stopwords: [String]?
    public let stopwordsPath: String?

    enum CodingKeys: String, CodingKey {
        case type
        case stopwords
        case stopwordsPath = "stopwords_path"
    }

    public init(name: String, stopwords: [String]) {
        self.name = name
        self.stopwords = stopwords
        self.stopwordsPath = nil
    }

    public init(name: String, stopwordsPath: String? = nil) {
        self.name = name
        self.stopwords = nil
        self.stopwordsPath = stopwordsPath
    }

    /// :nodoc:
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = (decoder.codingPath.last?.stringValue)!

        self.stopwords = try container.decodeIfPresent([String].self, forKey: .stopwords)
        self.stopwordsPath = try container.decodeIfPresent(String.self, forKey: .stopwordsPath)

    }
}

/**
 The whitespace analyzer breaks text into terms whenever it encounters a whitespace character.

 [More information](https://www.elastic.co/guide/en/elasticsearch/reference/6.3/analysis-whitespace-analyzer.html)
 */
public struct WhitespaceAnalyzer: Analyzer, BuiltinAnalyzer {
    /// :nodoc:
    public static var typeKey = AnalyzerType.whitespace

    /// Holds the string that Elasticsearch uses to identify the analyzer type
    public let type = typeKey.rawValue
    public let name: String

    public init() {
        self.name = type
    }

    /// :nodoc:
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(type)
    }
}


