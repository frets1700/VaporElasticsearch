public protocol AggregationResponse: Decodable {
    var name: String { get set }
}

public struct AggregationBucket<T: Decodable>: Decodable {
    public typealias HitsContainer = SearchResponse<T>.HitsContainer
    public typealias AggregationHits = [String: HitsContainer]

    public let key: String
    public let docCount: Int
    public let docCountErrorUpperBound: Int?
    public var hitsMap: AggregationHits = [:]

    enum CodingKeys: String, CodingKey {
        case key
        case hitsMap
        case docCount = "doc_count"
        case docCountErrorUpperBound = "doc_count_error_upper_bound"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        docCount = try container.decode(Int.self, forKey: .docCount)
        docCountErrorUpperBound = try container.decodeIfPresent(Int.self,
                                                                forKey: .docCountErrorUpperBound)

        if let value = try? container.decode(Int.self, forKey: .key) {
            key = String(value)
        } else {
            key = try container.decode(String.self, forKey: .key)
        }

        let dynamicContainer = try decoder.container(keyedBy: DynamicKey.self)
        let hitsKey = DynamicKey(stringValue: "hits")!

        for key in dynamicContainer.allKeys {
            do {
                let nestedContainer = try dynamicContainer.nestedContainer(keyedBy: DynamicKey.self, forKey: key)
                if nestedContainer.contains(hitsKey) {
                     let hits = try nestedContainer.decode(HitsContainer.self, forKey: hitsKey)
                     hitsMap[key.stringValue] = hits
                }

            } catch {}
        }
    }
}

public struct AggregationIntBucket: Decodable {
    public let key: Int
    public let docCount: Int

    enum CodingKeys: String, CodingKey {
        case key
        case docCount = "doc_count"
    }
}

public struct AggregationDateBucket: Decodable {
    public let key: Int64
    public let date: Date
    public let docCount: Int

    enum CodingKeys: String, CodingKey {
        case key
        case docCount = "doc_count"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.docCount = try container.decode(Int.self, forKey: .docCount)
        self.key = try container.decode(Int64.self, forKey: .key)
        self.date = Date(timeIntervalSince1970: TimeInterval(self.key / 1000))
    }
}

public struct AggregationDateHistogramResponse: AggregationResponse {
    public var name: String
    public let buckets: [AggregationDateBucket]

    enum CodingKeys: String, CodingKey {
        case buckets
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = (decoder.codingPath.last?.stringValue)!

        self.buckets = try container.decode([AggregationDateBucket].self, forKey: .buckets)
    }
}

public struct AggregationExtendedStatsResponse: AggregationResponse {
    public var name: String
    public let count: Int
    public let min: Float
    public let max: Float
    public let avg: Float
    public let sum: Float
    public let sumOfSquares: Float
    public let variance: Float
    public let stdDeviation: Float
    public let stdDeviationBounds: StandardDeviationBounds

    public struct StandardDeviationBounds: Decodable {
        public let upper: Float
        public let lower: Float
    }

    enum CodingKeys: String, CodingKey {
        case count
        case min
        case max
        case avg
        case sum
        case sumOfSquares = "sum_of_squares"
        case variance
        case stdDeviation = "std_deviation"
        case stdDeviationBounds = "std_deviation_bounds"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = (decoder.codingPath.last?.stringValue)!

        self.count = try container.decode(Int.self, forKey: .count)
        self.min = try container.decode(Float.self, forKey: .min)
        self.max = try container.decode(Float.self, forKey: .max)
        self.avg = try container.decode(Float.self, forKey: .avg)
        self.sum = try container.decode(Float.self, forKey: .sum)
        self.sumOfSquares = try container.decode(Float.self, forKey: .sumOfSquares)
        self.variance = try container.decode(Float.self, forKey: .variance)
        self.stdDeviation = try container.decode(Float.self, forKey: .stdDeviation)
        self.stdDeviationBounds = try container.decode(StandardDeviationBounds.self, forKey: .stdDeviationBounds)
    }
}

public struct AggregationGeoBoundsResponse: AggregationResponse {
    public var name: String
    public let bounds: BoundsContainer

    public struct BoundsContainer: Decodable {
        public let topLeft: BoundsPoint
        public let bottomRight: BoundsPoint
    }

    public struct BoundsPoint: Decodable {
        public let lat: Float
        public let lon: Float
    }

    enum CodingKeys: String, CodingKey {
        case bounds
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = (decoder.codingPath.last?.stringValue)!

        self.bounds = try container.decode(BoundsContainer.self, forKey: .bounds)
    }
}

public struct AggregationGeoCentroidResponse: AggregationResponse {
    public var name: String
    public let location: BoundsPoint
    public let count: Int

    public struct BoundsPoint: Decodable {
        public let lat: Float
        public let lon: Float
    }

    enum CodingKeys: String, CodingKey {
        case location
        case count
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = (decoder.codingPath.last?.stringValue)!

        self.location = try container.decode(BoundsPoint.self, forKey: .location)
        self.count = try container.decode(Int.self, forKey: .count)
    }
}

public struct AggregationHistogramResponse: AggregationResponse {
    public var name: String
    public let buckets: [AggregationIntBucket]

    enum CodingKeys: String, CodingKey {
        case buckets
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = (decoder.codingPath.last?.stringValue)!

        self.buckets = try container.decode([AggregationIntBucket].self, forKey: .buckets)
    }
}

public struct AggregationSingleValueResponse: AggregationResponse {
    public var name: String
    public let value: Float

    enum CodingKeys: String, CodingKey {
        case value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = (decoder.codingPath.last?.stringValue)!

        self.value = try container.decode(Float.self, forKey: .value)
    }
}

public struct AggregationStatsResponse: AggregationResponse {
    public var name: String
    public let count: Int
    public let min: Float
    public let max: Float
    public let avg: Float
    public let sum: Float

    enum CodingKeys: String, CodingKey {
        case count
        case min
        case max
        case avg
        case sum
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = (decoder.codingPath.last?.stringValue)!

        self.count = try container.decode(Int.self, forKey: .count)
        self.min = try container.decode(Float.self, forKey: .min)
        self.max = try container.decode(Float.self, forKey: .max)
        self.avg = try container.decode(Float.self, forKey: .avg)
        self.sum = try container.decode(Float.self, forKey: .sum)
    }
}

public struct AggregationTermsResponse<T: Decodable>: AggregationResponse {
    public var name: String
    public let docCountErrorUpperBound: Int
    public let sumOtherDocCount: Int
    public let buckets: [AggregationBucket<T>]

    enum CodingKeys: String, CodingKey {
        case docCountErrorUpperBound = "doc_count_error_upper_bound"
        case sumOtherDocCount = "sum_other_doc_count"
        case buckets
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = (decoder.codingPath.last?.stringValue)!

        self.docCountErrorUpperBound = try container.decode(Int.self, forKey: .docCountErrorUpperBound)
        self.sumOtherDocCount = try container.decode(Int.self, forKey: .sumOtherDocCount)
        self.buckets = try container.decode([AggregationBucket<T>].self, forKey: .buckets)
    }
}

internal struct AnyAggregationResponse<T: Decodable> : Decodable {
    public var base: AggregationResponse?

    init(_ base: AggregationResponse) {
        self.base = base
    }

    private enum CodingKeys : CodingKey {
        case base
    }

    public init(from decoder: Decoder) throws {
        let aggName = (decoder.codingPath.last?.stringValue)!
        self.base = try decoder.aggregationResponseType(forAggregationName: aggName, docType: T.self)
    }
}

