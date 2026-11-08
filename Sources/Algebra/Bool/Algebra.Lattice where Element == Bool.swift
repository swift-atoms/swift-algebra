extension Algebra.Lattice where Element == Bool {

    @inlinable
    public init() {
        self.init(join: .disjunction, meet: .conjunction)
    }
}
