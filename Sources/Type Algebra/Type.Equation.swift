extension Type {
    public struct Equation: Equatable, Sendable {
        public let lhs: Morphism
        public let rhs: Morphism
        public init(_ lhs: Morphism, _ rhs: Morphism) throws {
            guard lhs.domain == rhs.domain, lhs.codomain == rhs.codomain else {
                throw Failure("an equation requires parallel maps")
            }
            self.lhs = lhs
            self.rhs = rhs
        }
    }
}
