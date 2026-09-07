extension Algebra.Law {

    public enum Associativity {}
}

extension Algebra.Law.Associativity {

    @inlinable
    public static func check<
        Element: Equatable,
        Sequence: Swift.Sequence<Element>
    >(
        of semigroup: Algebra.Semigroup<Element>,
        over elements: Sequence
    ) -> Algebra.Law.Violation<Element>? {
        let elements = Array(elements)

        for a in elements {
            for b in elements {
                for c in elements {
                    let lhs = semigroup.combining(semigroup.combining(a, b), c)
                    let rhs = semigroup.combining(a, semigroup.combining(b, c))
                    if lhs != rhs {
                        return .init(law: "associativity", elements: [a, b, c], lhs: lhs, rhs: rhs)
                    }
                }
            }
        }
        return nil
    }
}
