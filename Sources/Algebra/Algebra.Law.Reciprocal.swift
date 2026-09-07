extension Algebra.Law {

    public enum Reciprocal {}
}

extension Algebra.Law.Reciprocal {

    @inlinable
    public static func check<
        Element: Equatable,
        Sequence: Swift.Sequence<Element>
    >(
        of field: Algebra.Field<Element>,
        over elements: Sequence
    ) -> Algebra.Law.Violation<Element>? {
        for a in elements {
            if a == field.zero {
                do throws(Algebra.Field<Element>.Error) {
                    let result = try field.reciprocal(a)
                    return .init(law: "reciprocal", elements: [a], lhs: result, rhs: field.zero)
                } catch {
                    continue
                }
            } else {
                do throws(Algebra.Field<Element>.Error) {
                    let inv = try field.reciprocal(a)
                    let product = field.multiplying(a, inv)
                    if product != field.one {
                        return .init(law: "reciprocal", elements: [a], lhs: product, rhs: field.one)
                    }
                } catch {
                    return .init(law: "reciprocal", elements: [a], lhs: a, rhs: field.one)
                }
            }
        }
        return nil
    }
}
