extension Algebra.Law {

    public enum Annihilation {}
}

extension Algebra.Law.Annihilation {

    @inlinable
    public static func zero<
        Element: Equatable,
        Sequence: Swift.Sequence<Element>
    >(
        of ring: Algebra.Ring<Element>,
        over elements: Sequence
    ) -> Algebra.Law.Violation<Element>? {
        for a in elements {
            let lhs = ring.multiplying(ring.zero, a)
            if lhs != ring.zero {
                return .init(law: "annihilation-left", elements: [a], lhs: lhs, rhs: ring.zero)
            }
            let rhs = ring.multiplying(a, ring.zero)
            if rhs != ring.zero {
                return .init(law: "annihilation-right", elements: [a], lhs: rhs, rhs: ring.zero)
            }
        }
        return nil
    }
}
