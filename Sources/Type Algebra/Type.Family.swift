extension Type {
    public struct Family: Equatable, Sendable {
        public let fibers: Record
        public init(_ fibers: Record) { self.fibers = fibers }
        public var sum: Expression { fibers.alternatives }
        public var product: Expression { fibers.expression }
        public func fiber(at index: String) throws -> Expression {
            guard let field = fibers.fields.first(where: { $0.name == index }) else {
                throw Failure("unknown family index")
            }
            return field.type
        }
    }
}
