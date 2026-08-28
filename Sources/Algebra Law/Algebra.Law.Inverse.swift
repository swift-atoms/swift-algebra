import Algebra_Field

extension Algebra.Law {

    public enum Inverse {}
}

extension Algebra.Law.Inverse {

    @inlinable
    public static func left<
        Element: Equatable,
        Sequence: Swift.Sequence<Element>
    >(
        of group: Algebra.Group<Element>,
        over elements: Sequence
    ) -> Algebra.Law.Violation<Element>? {
        for a in elements {
            let lhs = group.combining(group.inverting(a), a)
            if lhs != group.identity {
                return .init(law: "inverse-left", elements: [a], lhs: lhs, rhs: group.identity)
            }
        }
        return nil
    }

    @inlinable
    public static func right<
        Element: Equatable,
        Sequence: Swift.Sequence<Element>
    >(
        of group: Algebra.Group<Element>,
        over elements: Sequence
    ) -> Algebra.Law.Violation<Element>? {
        for a in elements {
            let lhs = group.combining(a, group.inverting(a))
            if lhs != group.identity {
                return .init(law: "inverse-right", elements: [a], lhs: lhs, rhs: group.identity)
            }
        }
        return nil
    }
}
