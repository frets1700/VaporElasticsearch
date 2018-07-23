
import Foundation

public struct Analysis: Codable {
    public var filters: [String: AnyTokenFilter]
    public var characterFilters: [String: AnyCharacterFilter]
    public var analyzers: [String: AnyAnalyzer]
    public var normalizers: [String: AnyNormalizer]
    public var tokenizers: [String: AnyTokenizer]
    
    enum CodingKeys: String, CodingKey {
        case filters = "filter"
        case characterFilters = "char_filter"
        case analyzers = "analyzer"
        case normalizers = "normalizer"
        case tokenizers = "tokenizer"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.filters = try container.decode([String: AnyTokenFilter].self, forKey: .filters)
        self.characterFilters = try container.decode([String: AnyCharacterFilter].self, forKey: .characterFilters)
        self.analyzers = try container.decode([String: AnyAnalyzer].self, forKey: .analyzers)
        self.normalizers = try container.decode([String: AnyNormalizer].self, forKey: .normalizers)
        self.tokenizers = try container.decode([String: AnyTokenizer].self, forKey: .tokenizers)
    }
    
    public init() {
        self.filters = [:]
        self.characterFilters = [:]
        self.analyzers = [:]
        self.normalizers = [:]
        self.tokenizers = [:]
    }
    
    internal mutating func add(tokenFilter: AnyTokenFilter) {
        // If it's a builtin filter, don't add
        if TokenFilterType.Builtins(rawValue: tokenFilter.base.name) != nil {
            return
        }
        self.filters[tokenFilter.base.name] = tokenFilter
    }
    
    internal mutating func add(characterFilter: AnyCharacterFilter) {
        // TODO - Should check to see if the character filter already exists and print a warning if it does exist and is different from what's being set
        self.characterFilters[characterFilter.base.name] = characterFilter
    }
    
    internal mutating func add(tokenizer: AnyTokenizer) {
        // If it's a builtin tokenizer, don't add
        if TokenizerType.Builtins(rawValue: tokenizer.base.name) != nil {
            return
        }
        self.tokenizers[tokenizer.base.name] = tokenizer
    }
    
    internal mutating func add(analyzer: AnyAnalyzer) {
        self.analyzers[analyzer.base.name] = analyzer
    }
    
    internal mutating func add(normalizer: AnyNormalizer) {
        self.normalizers[normalizer.base.name] = normalizer
    }
}
