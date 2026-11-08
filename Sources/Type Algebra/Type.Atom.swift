
extension Type {
    public struct Atom: Hashable, Sendable {
        public let scope: [String]
        public let name: String
        public init(_ name: String, scope: [String] = []) {
            self.name = name
            self.scope = scope
        }
    }
}
