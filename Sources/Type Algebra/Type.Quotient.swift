extension Type {
    public struct Quotient: Equatable, Sendable {
        public let base: Expression
        public let relation: Atom
        public init(_ base: Expression, by relation: Atom) {
            self.base = base
            self.relation = relation
        }
    }
}
