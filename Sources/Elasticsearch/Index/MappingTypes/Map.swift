/*
 These structs define all of the types that Elasticsearch can store,
 how they map to Swift types and allows the user to configure what
 the mapping should be like in their index.
 
 The list of types in Elasticsearch can be found at:
 https://www.elastic.co/guide/en/elasticsearch/reference/current/mapping-types.html
 */

public struct MapBinary: Mappable {
    /// :nodoc:
    public static var typeKey = MapType.binary

    /// Holds the string that Elasticsearch uses to identify the mapping type
    public let type = typeKey.rawValue
    public let docValues: Bool?
    public let store: Bool?
    
    enum CodingKeys: String, CodingKey {
        case type
        case docValues = "doc_values"
        case store
    }
    
    public init(docValues: Bool? = nil, store: Bool? = nil) {
        self.docValues = docValues
        self.store = store
    }
}

public struct MapBoolean: Mappable {
    /// :nodoc:
    public static var typeKey = MapType.boolean

    /// Holds the string that Elasticsearch uses to identify the mapping type
    public let type = typeKey.rawValue
    public let boost: Float?
    public let docValues: Bool?
    public let index: Bool?
    public let nullValue: Bool?
    public let store: Bool?

    enum CodingKeys: String, CodingKey {
        case type
        case boost
        case docValues = "doc_values"
        case index
        case nullValue = "null_value"
        case store
    }

    public init(docValues: Bool? = nil,
                index: Bool? = nil,
                store: Bool? = nil,
                boost: Float? = nil,
                nullValue: Bool? = nil) {

        self.boost = boost
        self.docValues = docValues
        self.index = index
        self.nullValue = nullValue
        self.store = store
    }
}

public struct MapByte: Mappable {
    /// :nodoc:
    public static var typeKey = MapType.byte

    /// Holds the string that Elasticsearch uses to identify the mapping type
    public let type = typeKey.rawValue
    public let coerce: Bool?
    public let boost: Float?
    public let docValues: Bool?
    public let ignoreMalformed: Bool?
    public let index: Bool?
    public let nullValue: Int8?
    public let store: Bool?

    enum CodingKeys: String, CodingKey {
        case type
        case coerce
        case boost
        case docValues = "doc_values"
        case ignoreMalformed = "ignore_malformed"
        case index
        case nullValue = "null_value"
        case store
    }

    public init(docValues: Bool? = nil,
                index: Bool? = nil,
                store: Bool? = nil,
                boost: Float? = nil,
                coerce: Bool? = nil,
                ignoreMalformed: Bool? = nil,
                nullValue: Int8? = nil) {

        self.coerce = coerce
        self.boost = boost
        self.docValues = docValues
        self.ignoreMalformed = ignoreMalformed
        self.index = index
        self.nullValue = nullValue
        self.store = store
    }
}

public struct MapDate: Mappable {
    /// :nodoc:
    public static var typeKey = MapType.date

    /// Holds the string that Elasticsearch uses to identify the mapping type
    public let type = typeKey.rawValue
    public let boost: Float?
    public let docValues: Bool?
    public let format: String?
    public let locale: String?
    public let ignoreMalformed: Bool?
    public let index: Bool?
    public let nullValue: Bool?
    public let store: Bool?

    enum CodingKeys: String, CodingKey {
        case type
        case boost
        case docValues = "doc_values"
        case format
        case locale
        case ignoreMalformed = "ignoreMalformed"
        case index
        case nullValue = "null_value"
        case store
    }

    public init(format: String? = nil,
                docValues: Bool? = nil,
                index: Bool? = nil,
                store: Bool? = nil,
                boost: Float? = nil,
                locale: String? = nil,
                ignoreMalformed: Bool? = nil,
                nullValue: Bool? = nil) {

        self.boost = boost
        self.docValues = docValues
        self.format = format
        self.locale = locale
        self.ignoreMalformed = ignoreMalformed
        self.index = index
        self.nullValue = nullValue
        self.store = store
    }
}

public struct MapDateRange: Mappable {
    /// :nodoc:
    public static var typeKey = MapType.dateRange

    /// Holds the string that Elasticsearch uses to identify the mapping type
    public let type = typeKey.rawValue
    public let format: String
    public let coerce: Bool?
    public let boost: Float?
    public let index: Bool?
    public let store: Bool?

    enum CodingKeys: String, CodingKey {
        case type
        case format
        case coerce
        case boost
        case index
        case store
    }

    public init(format: String,
                index: Bool? = nil,
                store: Bool? = nil,
                boost: Float? = nil,
                coerce: Bool? = nil) {

        self.format = format
        self.coerce = coerce
        self.boost = boost
        self.index = index
        self.store = store
    }
}

public struct MapDouble: Mappable {
    /// :nodoc:
    public static var typeKey = MapType.double

    /// Holds the string that Elasticsearch uses to identify the mapping type
    public let type = typeKey.rawValue
    public let coerce: Bool?
    public let boost: Float?
    public let docValues: Bool?
    public let ignoreMalformed: Bool?
    public let index: Bool?
    public let nullValue: Double?
    public let store: Bool?

    enum CodingKeys: String, CodingKey {
        case type
        case coerce
        case boost
        case docValues = "doc_values"
        case ignoreMalformed = "ignore_malformed"
        case index
        case nullValue = "null_value"
        case store
    }

    public init(docValues: Bool? = nil,
                index: Bool? = nil,
                store: Bool? = nil,
                boost: Float? = nil,
                coerce: Bool? = nil,
                ignoreMalformed: Bool? = nil,
                nullValue: Double? = nil) {

        self.coerce = coerce
        self.boost = boost
        self.docValues = docValues
        self.ignoreMalformed = ignoreMalformed
        self.index = index
        self.nullValue = nullValue
        self.store = store
    }
}

public struct MapDoubleRange: Mappable {
    /// :nodoc:
    public static var typeKey = MapType.doubleRange

    /// Holds the string that Elasticsearch uses to identify the mapping type
    public let type = typeKey.rawValue
    public let coerce: Bool?
    public let boost: Float?
    public let index: Bool?
    public let store: Bool?

    enum CodingKeys: String, CodingKey {
        case type
        case coerce
        case boost
        case index
        case store
    }

    public init(index: Bool? = nil,
                store: Bool? = nil,
                boost: Float? = nil,
                coerce: Bool? = nil) {

        self.index = index
        self.store = store
        self.boost = boost
        self.coerce = coerce
    }
}

public struct MapFloat: Mappable {
    /// :nodoc:
    public static var typeKey = MapType.float

    /// Holds the string that Elasticsearch uses to identify the mapping type
    public let type = typeKey.rawValue
    public let coerce: Bool?
    public let boost: Float?
    public let docValues: Bool?
    public let ignoreMalformed: Bool?
    public let index: Bool?
    public let nullValue: Float?
    public let store: Bool?

    enum CodingKeys: String, CodingKey {
        case type
        case coerce
        case boost
        case docValues = "doc_values"
        case ignoreMalformed = "ignore_malformed"
        case index
        case nullValue = "null_value"
        case store
    }

    public init(docValues: Bool? = nil,
                index: Bool? = nil,
                store: Bool? = nil,
                boost: Float? = nil,
                coerce: Bool? = nil,
                ignoreMalformed: Bool? = nil,
                nullValue: Float? = nil) {

        self.coerce = coerce
        self.boost = boost
        self.docValues = docValues
        self.ignoreMalformed = ignoreMalformed
        self.index = index
        self.nullValue = nullValue
        self.store = store
    }
}

public struct MapFloatRange: Mappable {
    /// :nodoc:
    public static var typeKey = MapType.floatRange

    /// Holds the string that Elasticsearch uses to identify the mapping type
    public let type = typeKey.rawValue
    public let coerce: Bool?
    public let boost: Float?
    public let index: Bool?
    public let store: Bool?

    enum CodingKeys: String, CodingKey {
        case type
        case coerce
        case boost
        case index
        case store
    }

    public init(index: Bool? = nil,
                store: Bool? = nil,
                boost: Float? = nil,
                coerce: Bool? = nil) {

        self.index = index
        self.store = store
        self.boost = boost
        self.coerce = coerce
    }
}

public struct MapGeoPoint: Mappable {
    /// :nodoc:
    public static var typeKey = MapType.geoPoint

    /// Holds the string that Elasticsearch uses to identify the mapping type
    public let type = typeKey.rawValue
    public let ignoreMalformed: Bool?

    enum CodingKeys: String, CodingKey {
        case type
        case ignoreMalformed = "ignore_malformed"
    }

    public init(ignoreMalformed: Bool? = nil) {
        self.ignoreMalformed = ignoreMalformed
    }
}

public struct MapHalfFloat: Mappable {
    /// :nodoc:
    public static var typeKey = MapType.halfFloat

    /// Holds the string that Elasticsearch uses to identify the mapping type
    public let type = typeKey.rawValue
    public let coerce: Bool?
    public let boost: Float?
    public let docValues: Bool?
    public let ignoreMalformed: Bool?
    public let index: Bool?
    public let nullValue: Float?
    public let store: Bool?

    enum CodingKeys: String, CodingKey {
        case type
        case coerce
        case boost
        case docValues = "doc_values"
        case ignoreMalformed = "ignore_malformed"
        case index
        case nullValue = "null_value"
        case store
    }

    public init(docValues: Bool? = nil,
                index: Bool? = nil,
                store: Bool? = nil,
                boost: Float? = nil,
                coerce: Bool? = nil,
                ignoreMalformed: Bool? = nil,
                nullValue: Float? = nil) {

        self.coerce = coerce
        self.boost = boost
        self.docValues = docValues
        self.ignoreMalformed = ignoreMalformed
        self.index = index
        self.nullValue = nullValue
        self.store = store
    }
}

public struct MapIPAddress: Mappable {
    /// :nodoc:
    public static var typeKey = MapType.ipAddress

    /// Holds the string that Elasticsearch uses to identify the mapping type
    public let type = typeKey.rawValue
    public let boost: Float?
    public let docValues: Bool?
    public let index: Bool?
    public let nullValue: Bool?
    public let store: Bool?

    enum CodingKeys: String, CodingKey {
        case type
        case boost
        case docValues = "doc_values"
        case index
        case nullValue = "null_value"
        case store
    }

    public init(docValues: Bool? = nil,
                index: Bool? = nil,
                store: Bool? = nil,
                boost: Float? = nil,
                nullValue: Bool? = nil) {

        self.boost = boost
        self.docValues = docValues
        self.index = index
        self.nullValue = nullValue
        self.store = store
    }
}

public struct MapInteger: Mappable {
    /// :nodoc:
    public static var typeKey = MapType.integer

    /// Holds the string that Elasticsearch uses to identify the mapping type
    public let type = typeKey.rawValue
    public let coerce: Bool?
    public let boost: Float?
    public let docValues: Bool?
    public let ignoreMalformed: Bool?
    public let index: Bool?
    public let nullValue: Int32?
    public let store: Bool?

    enum CodingKeys: String, CodingKey {
        case type
        case coerce
        case boost
        case docValues = "doc_values"
        case ignoreMalformed = "ignore_malformed"
        case index
        case nullValue = "null_value"
        case store
    }

    public init(docValues: Bool? = nil,
                index: Bool? = nil,
                store: Bool? = nil,
                boost: Float? = nil,
                coerce: Bool? = nil,
                ignoreMalformed: Bool? = nil,
                nullValue: Int32? = nil) {

        self.coerce = coerce
        self.boost = boost
        self.docValues = docValues
        self.ignoreMalformed = ignoreMalformed
        self.index = index
        self.nullValue = nullValue
        self.store = store
    }
}

public struct MapIntegerRange: Mappable {
    /// :nodoc:
    public static var typeKey = MapType.integerRange

    /// Holds the string that Elasticsearch uses to identify the mapping type
    public let type = typeKey.rawValue
    public let coerce: Bool?
    public let boost: Float?
    public let index: Bool?
    public let store: Bool?

    enum CodingKeys: String, CodingKey {
        case type
        case coerce
        case boost
        case index
        case store
    }

    public init(index: Bool? = nil,
                store: Bool? = nil,
                boost: Float? = nil,
                coerce: Bool? = nil) {

        self.index = index
        self.store = store
        self.boost = boost
        self.coerce = coerce
    }
}

public struct MapJoin: Mappable {
    /// :nodoc:
    public static var typeKey = MapType.join

    /// Holds the string that Elasticsearch uses to identify the mapping type
    public let type = typeKey.rawValue
    public let relations: [String: String]

    enum CodingKeys: String, CodingKey {
        case type
        case relations
    }

    public init(relations: [String: String]) {
        self.relations = relations
    }
}

public struct MapLong: Mappable {
    /// :nodoc:
    public static var typeKey = MapType.long

    /// Holds the string that Elasticsearch uses to identify the mapping type
    public let type = typeKey.rawValue
    public let coerce: Bool?
    public let boost: Float?
    public let docValues: Bool?
    public let ignoreMalformed: Bool?
    public let index: Bool?
    public let nullValue: Int64?
    public let store: Bool?

    enum CodingKeys: String, CodingKey {
        case type
        case coerce
        case boost
        case docValues = "doc_values"
        case ignoreMalformed = "ignore_malformed"
        case index
        case nullValue = "null_value"
        case store
    }

    public init(docValues: Bool? = nil,
                index: Bool? = nil,
                store: Bool? = nil,
                boost: Float? = nil,
                coerce: Bool? = nil,
                ignoreMalformed: Bool? = nil,
                nullValue: Int64? = nil) {

        self.coerce = coerce
        self.boost = boost
        self.docValues = docValues
        self.ignoreMalformed = ignoreMalformed
        self.index = index
        self.nullValue = nullValue
        self.store = store
    }
}

public struct MapLongRange: Mappable {
    /// :nodoc:
    public static var typeKey = MapType.longRange

    /// Holds the string that Elasticsearch uses to identify the mapping type
    public let type = typeKey.rawValue
    public var coerce: Bool?
    public var boost: Float?
    public var index: Bool?
    public var store: Bool?

    enum CodingKeys: String, CodingKey {
        case type
        case coerce
        case boost
        case index
        case store
    }

    public init(index: Bool? = nil,
                store: Bool? = nil,
                boost: Float? = nil,
                coerce: Bool? = nil) {

        self.index = index
        self.store = store
        self.boost = boost
        self.coerce = coerce
    }
}


public struct MapPercolator: Mappable {
    /// :nodoc:
    public static var typeKey = MapType.percolator

    /// Holds the string that Elasticsearch uses to identify the mapping type
    public let type = typeKey.rawValue

    enum CodingKeys: String, CodingKey {
        case type
    }

    public init() {}
}

public struct MapScaledFloat: Mappable {
    /// :nodoc:
    public static var typeKey = MapType.scaledFloat

    /// Holds the string that Elasticsearch uses to identify the mapping type
    public let type = typeKey.rawValue
    public let coerce: Bool?
    public let boost: Float?
    public let docValues: Bool?
    public let ignoreMalformed: Bool?
    public let index: Bool?
    public let nullValue: Float?
    public let store: Bool?

    public var scalingFactor: Int? = 0

    enum CodingKeys: String, CodingKey {
        case type
        case coerce
        case boost
        case docValues = "doc_values"
        case ignoreMalformed = "ignore_malformed"
        case index
        case nullValue = "null_value"
        case store
        case scalingFactor = "scaling_factor"
    }

    public init(scalingFactor: Int? = nil,
                docValues: Bool? = nil,
                index: Bool? = nil,
                store: Bool? = nil,
                boost: Float? = nil,
                coerce: Bool? = nil,
                ignoreMalformed: Bool? = nil,
                nullValue: Float? = nil) {

        self.scalingFactor = scalingFactor
        self.coerce = coerce
        self.boost = boost
        self.docValues = docValues
        self.ignoreMalformed = ignoreMalformed
        self.index = index
        self.nullValue = nullValue
        self.store = store
    }
}

public struct MapShort: Mappable {
    /// :nodoc:
    public static var typeKey = MapType.short

    /// Holds the string that Elasticsearch uses to identify the mapping type
    public let type = typeKey.rawValue
    public let coerce: Bool?
    public let boost: Float?
    public let docValues: Bool?
    public let ignoreMalformed: Bool?
    public let index: Bool?
    public let nullValue: Int16?
    public let store: Bool?

    enum CodingKeys: String, CodingKey {
        case type
        case coerce
        case boost
        case docValues = "doc_values"
        case ignoreMalformed = "ignore_malformed"
        case index
        case nullValue = "null_value"
        case store
    }

    public init(docValues: Bool? = nil,
                index: Bool? = nil,
                store: Bool? = nil,
                boost: Float? = nil,
                coerce: Bool? = nil,
                ignoreMalformed: Bool? = nil,
                nullValue: Int16? = nil) {

        self.coerce = coerce
        self.boost = boost
        self.docValues = docValues
        self.ignoreMalformed = ignoreMalformed
        self.index = index
        self.nullValue = nullValue
        self.store = store
    }
}

public struct MapTokenCount: Mappable {
    /// :nodoc:
    public static var typeKey = MapType.tokenCount

    /// Holds the string that Elasticsearch uses to identify the mapping type
    public let type = typeKey.rawValue
    public let analyzer: String?
    public let enablePositionIncrements: Bool?
    public let boost: Float?
    public let docValues: Bool?
    public let index: Bool?
    public let nullValue: Bool?
    public let store: Bool?

    enum CodingKeys: String, CodingKey {
        case type
        case analyzer
        case enablePositionIncrements = "enable_position_increments"
        case boost
        case docValues = "doc_values"
        case index
        case nullValue = "null_value"
        case store
    }

    public init(docValues: Bool? = nil,
                index: Bool? = nil,
                store: Bool? = nil,
                analyzer: String? = nil,
                enablePositionIncrements: Bool? = nil,
                boost: Float? = nil,
                nullValue: Bool? = nil) {

        self.docValues = docValues
        self.index = index
        self.store = store
        self.analyzer = analyzer
        self.enablePositionIncrements = enablePositionIncrements
        self.boost = boost
        self.nullValue = nullValue
    }
}

public struct MapGeoShape: Mappable {
    /// :nodoc:
    public static var typeKey = MapType.geoShape

    public enum GeoShapePrefixTree: String, Codable {
        case geohash
        case quadtree
    }

    public enum GeoShapePrecision: String, Codable {
        case `in`
        case inch
        case yd
        case yard
        case mi
        case miles
        case km
        case kilometers
        case m
        case meters
        case cm
        case centimeters
        case mm
        case millimeters
    }

    public enum GeoShapeStrategy: String, Codable {
        case recursive = "recursive"
        case term = "term"
    }

    public enum GeoShapeOrientation: String, Codable {
        case right = "right"
        case ccw = "ccw"
        case counterclockwise = "counterclockwise"
        case left = "left"
        case cw = "cw"
        case clockwise = "clockwise"
    }

    /// Holds the string that Elasticsearch uses to identify the mapping type
    public let type = typeKey.rawValue
    public let tree: GeoShapePrefixTree?
    public let precision: GeoShapePrecision?
    public let treeLevels: String?
    public let strategy: GeoShapeStrategy?
    public let distanceErrorPct: Float?
    public let orientation: GeoShapeOrientation?
    public let pointsOnly: Bool?
    public let ignoreMalformed: Bool?

    enum CodingKeys: String, CodingKey {
        case type
        case tree
        case precision
        case treeLevels = "tree_levels"
        case strategy = "null_value"
        case distanceErrorPct = "distance_error_pct"
        case orientation
        case pointsOnly = "points_only"
        case ignoreMalformed = "ignore_malformed"
    }

    public init(tree: GeoShapePrefixTree? = nil,
                precision: GeoShapePrecision? = nil,
                treeLevels: String? = nil,
                strategy: GeoShapeStrategy? = nil,
                distanceErrorPct: Float? = nil,
                orientation: GeoShapeOrientation? = nil,
                pointsOnly: Bool? = nil,
                ignoreMalformed: Bool? = nil) {

        self.tree = tree
        self.precision = precision
        self.treeLevels = treeLevels
        self.strategy = strategy
        self.distanceErrorPct = distanceErrorPct
        self.orientation = orientation
        self.pointsOnly = pointsOnly
        self.ignoreMalformed = ignoreMalformed
    }
}



