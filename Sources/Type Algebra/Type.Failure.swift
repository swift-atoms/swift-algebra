
extension Type {
    public struct Failure: Swift.Error, Equatable, Sendable, CustomStringConvertible {
        public let description: String
        public init(_ description: String) { self.description = description }
    }
}
