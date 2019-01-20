
import Foundation

/**
 A multi-value metrics aggregation that computes stats over numeric values
 extracted from the aggregated documents. These values can be extracted either
 from specific numeric fields in the documents, or be generated by a provided
 script.

 The extended_stats aggregations is an extended version of the stats
 aggregation, where additional metrics are added such as sum_of_squares,
 variance, std_deviation and std_deviation_bounds.

 [More information](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-metrics-extendedstats-aggregation.html)
 */
public struct ExtendedStatsAggregation: Aggregation {
    public var aggs: [Aggregation]?
  
    /// :nodoc:
    public static var typeKey = AggregationResponseMap.extendedStats
    
    /// :nodoc:
    public var name: String
    
    /// :nodoc:
    public let field: String?
    
    /// :nodoc:
    public let sigma: Int?
    
    /// :nodoc:
    public let script: Script?
    
    /// :nodoc:
    public let missing: Int?
    
    enum CodingKeys: String, CodingKey {
        case field
        case sigma
        case script
        case missing
        case aggs
    }
    
    /// Create an [extended_stats](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-metrics-extendedstats-aggregation.html) aggregation
    ///
    /// - Parameters:
    ///   - name: The aggregation name
    ///   - field: The field to perform the aggregation over
    ///   - sigma: Controls how many standard deviations +/- from the mean should be returned
    ///   - script: A script used to calculate the values
    ///   - missing: Defines how documents that are missing a value should be treated
    public init(
        name: String,
        field: String? = nil,
        sigma: Int? = nil,
        script: Script? = nil,
        missing: Int? = nil,
        aggs: [Aggregation]? = nil
        ) {
        self.name = name
        self.field = field
        self.sigma = sigma
        self.script = script
        self.missing = missing
        self.aggs = aggs
    }
    
    /// :nodoc:
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicKey.self)
        var valuesContainer = container.nestedContainer(keyedBy: CodingKeys.self, forKey: DynamicKey(stringValue: type(of: self).typeKey.rawValue)!)
        try valuesContainer.encodeIfPresent(field, forKey: .field)
        try valuesContainer.encodeIfPresent(sigma, forKey: .sigma)
        try valuesContainer.encodeIfPresent(script, forKey: .script)
        try valuesContainer.encodeIfPresent(missing, forKey: .missing)
        if aggs != nil {
          if aggs != nil {
          if aggs != nil && aggs!.count > 0 {
          var aggContainer = container.nestedContainer(keyedBy: DynamicKey.self, forKey: DynamicKey(stringValue: "aggs")!)
          for agg in aggs! {
            try aggContainer.encode(AnyAggregation(agg), forKey: DynamicKey(stringValue: agg.name)!)
          }
        }
      }
        }
    }
}
