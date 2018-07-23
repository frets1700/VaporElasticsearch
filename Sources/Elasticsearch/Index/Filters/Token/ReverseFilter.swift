
import Foundation

public struct ReverseFilter: BasicTokenFilter {
    /// :nodoc:
    public static var typeKey = TokenFilterType.reverse
    
    public let type = typeKey.rawValue
    public let name: String
    
    public init() {
        self.name = self.type
    }
}