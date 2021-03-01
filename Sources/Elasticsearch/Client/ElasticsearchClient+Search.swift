import HTTP

/**
 Search methods.
 */
extension ElasticsearchClient {
    /// Execute a search in a given index
    ///
    /// - Parameters:
    ///   - decodeTo: A struct or class that conforms to the Decodable protocol and can properly decode the documents stored in the index
    ///   - index: The index to execute the query against
    ///   - query: A SearchContainer object that specifies the query to execute
    ///   - type: The index type (defaults to _doc)
    ///   - routing: Routing information
    /// - Returns: A Future SearchResponse
    public func search<U: Decodable>(
        decodeTo: U.Type,
        index: String,
        query: SearchContainer,
        routing: String? = nil
    ) -> Future<SearchResponse<U>> {
        let body: Data
        do {
            body = try self.encoder.encode(query)
        } catch {
            return worker.future(error: error)
        }

        let url = ElasticsearchClient.generateURL(path: "/\(index)/_search", routing: routing)
        guard let urlString = url.string else {
            return worker.future(error: ElasticsearchError.report(error: .urlError))
        }

        return send(HTTPMethod.POST, to: urlString, with: body).map(to: SearchResponse.self) { jsonData in
            let decoder = JSONDecoder()
            if let aggregations = query.aggs {
                if aggregations.count > 0 {
                    decoder.userInfo(fromAggregations: aggregations)
                }
            }
            
            if let jsonData = jsonData {
                return try decoder.decode(SearchResponse<U>.self, from: jsonData)
            }

            throw ElasticsearchError.report(error: .searchFailed, attach: nil, statusCode: 404)
        }
    }
}
