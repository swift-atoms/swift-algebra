extension Type {
    public struct Refinement: Equatable, Sendable {
        public let base: Expression
        public let predicate: Atom
        public init(_ base: Expression, satisfying predicate: Atom) {
            self.base = base
            self.predicate = predicate
        }
    }
}
