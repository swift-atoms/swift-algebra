extension Algebra.Semilattice where Element: Comparable {

    @inlinable
    public static func maximum(bottom: Element) -> Self {
        .init(identity: bottom, combining: { Swift.max($0, $1) })
    }

    @inlinable
    public static func minimum(top: Element) -> Self {
        .init(identity: top, combining: { Swift.min($0, $1) })
    }
}
