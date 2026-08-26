import Algebra_Field

extension Algebra.Law {

    public enum Commutativity {}
}

extension Algebra.Law.Commutativity {

    @inlinable
    public static func check<Element: Equatable, C: Swift.Collection<Element>>(
        of combining: @Sendable (Element, Element) -> Element,
        over elements: C
    ) -> Algebra.Law.Violation<Element>? {
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
