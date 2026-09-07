extension Algebra.Law {

    public enum Commutativity {}
}

extension Algebra.Law.Commutativity {

    @inlinable
    public static func check<
        Element: Equatable,
        Sequence: Swift.Sequence<Element>
    >(
        of combining: (borrowing Element, borrowing Element) -> Element,
        over elements: Sequence
    ) -> Algebra.Law.Violation<Element>? {
        let elements = Array(elements)

        for a in elements {
            for b in elements {
                let lhs = combining(a, b)
                let rhs = combining(b, a)
                if lhs != rhs {
                    return .init(law: "commutativity", elements: [a, b], lhs: lhs, rhs: rhs)
                }
            }
        }
        return nil
    }
}
