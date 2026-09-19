extension Algebra.Semilattice where Element == Bool {

    @inlinable
    public static var disjunction: Self {
        .init(identity: false, combining: { $0 || $1 })
    }

    @inlinable
    public static var conjunction: Self {
        .init(identity: true, combining: { $0 && $1 })
    }
}
