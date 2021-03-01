
import Foundation

public struct ArabicNormalizationFilter: BasicTokenFilter, BuiltinTokenFilter {
    /// :nodoc:
    public static var typeKey = TokenFilterType.arabicNormalization
    
    /// Holds the string that Elasticsearch uses to identify the filter type
    public let type = typeKey.rawValue
    /// :nodoc:
    public let name: String
    
    public init() {
        self.name = self.type
    }
}

public struct HindiNormalizationFilter: BasicTokenFilter, BuiltinTokenFilter {
    /// :nodoc:
    public static var typeKey = TokenFilterType.hindiNormalization

    /// Holds the string that Elasticsearch uses to identify the filter type
    public let type = typeKey.rawValue
    /// :nodoc:
    public let name: String

    public init() {
        self.name = self.type
    }
}


public struct GermanNormalizationFilter: BasicTokenFilter, BuiltinTokenFilter {
    /// :nodoc:
    public static var typeKey = TokenFilterType.germanNormalization

    /// Holds the string that Elasticsearch uses to identify the filter type
    public let type = typeKey.rawValue
    /// :nodoc:
    public let name: String

    public init() {
        self.name = self.type
    }
}

public struct IndicNormalizationFilter: BasicTokenFilter, BuiltinTokenFilter {
    /// :nodoc:
    public static var typeKey = TokenFilterType.indicNormalization

    /// Holds the string that Elasticsearch uses to identify the filter type
    public let type = typeKey.rawValue
    /// :nodoc:
    public let name: String

    public init() {
        self.name = self.type
    }
}

public struct PersianNormalizationFilter: BasicTokenFilter, BuiltinTokenFilter {
    /// :nodoc:
    public static var typeKey = TokenFilterType.persianNormalization

    /// Holds the string that Elasticsearch uses to identify the filter type
    public let type = typeKey.rawValue
    /// :nodoc:
    public let name: String

    public init() {
        self.name = self.type
    }
}

public struct ScandinavianNormalizationFilter: BasicTokenFilter, BuiltinTokenFilter {
    /// :nodoc:
    public static var typeKey = TokenFilterType.scandinavianNormalization

    /// Holds the string that Elasticsearch uses to identify the filter type
    public let type = typeKey.rawValue
    /// :nodoc:
    public let name: String

    public init() {
        self.name = self.type
    }
}

public struct SerbianNormalizationFilter: BasicTokenFilter, BuiltinTokenFilter {
    /// :nodoc:
    public static var typeKey = TokenFilterType.serbianNormalization

    /// Holds the string that Elasticsearch uses to identify the filter type
    public let type = typeKey.rawValue
    /// :nodoc:
    public let name: String

    public init() {
        self.name = self.type
    }
}

public struct SoraniNormalizationFilter: BasicTokenFilter, BuiltinTokenFilter {
    /// :nodoc:
    public static var typeKey = TokenFilterType.soraniNormalization

    /// Holds the string that Elasticsearch uses to identify the filter type
    public let type = typeKey.rawValue
    /// :nodoc:
    public let name: String

    public init() {
        self.name = self.type
    }
}
