
import Foundation

public struct Analysis: Codable {
    
    public struct Filter: Codable {
        public let type: String
        public var name: String?
        public var synonyms: [String]?
        
        public init(type: String, name: String? = nil, synonyms: [String]? = nil) {
            self.type = type
            self.name = name
            self.synonyms = synonyms
        }
    }
    
    public var filter: [String: Filter]?
    public var analyzer: [String: AnyAnalyzer]?
    public var normalizer: [String: Normalizer]?
    public var tokenizers: [String: AnyTokenizer]?
    
    public init(
        filter: [String: Filter]? = nil,
        analyzer: [String: Analyzer]? = nil,
        normalizer: [String: Normalizer]? = nil,
        tokenizer: [String: Tokenizer]? = nil) {
        
        self.filter = filter
        self.analyzer = analyzer?.mapValues({ analyzer -> AnyAnalyzer in
            return AnyAnalyzer(analyzer)
        })
        self.normalizer = normalizer
        self.tokenizers = tokenizer?.mapValues({ tokenizer -> AnyTokenizer in
            return AnyTokenizer(tokenizer)
        })
    }
}