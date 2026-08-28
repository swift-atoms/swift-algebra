import Algebra_Semilattice

extension Algebra.Lattice where Element: Comparable {

    @inlinable
    public static func minMax(bottom: Element, top: Element) -> Self {
        .init(
            join: .maximum(bottom: bottom),
            meet: .minimum(top: top)
        )
    }
}
