
extension Type {
    public struct Variable: Hashable, Sendable {
        public let name: String
        public init(_ name: String) { self.name = name }
    }
}
