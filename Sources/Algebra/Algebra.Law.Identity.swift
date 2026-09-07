
extension Algebra.Law {

    public enum Identity {}
}

extension Algebra.Law.Identity {

    @inlinable
    public static func left<
        Element: Equatable,
        Sequence: Swift.Sequence<Element>
    >(
        of monoid: Algebra.Monoid<Element>,
        over elements: Sequence
    ) -> Algebra.Law.Violation<Element>? {
        for a in elements {
            let lhs = monoid.combining(monoid.identity, a)
            if lhs != a {
                return .init(law: "identity-left", elements: [a], lhs: lhs, rhs: a)
            }
        }
        return nil
    }

    @inlinable
    public static func right<
        Element: Equatable,
        Sequence: Swift.Sequence<Element>
    >(
        of monoid: Algebra.Monoid<Element>,
        over elements: Sequence
    ) -> Algebra.Law.Violation<Element>? {
        for a in elements {
            let lhs = monoid.combining(a, monoid.identity)
            if lhs != a {
                return .init(law: "identity-right", elements: [a], lhs: lhs, rhs: a)
            }
        }
        return nil
    }
}
