extension Algebra {

    @frozen
    public struct Field<Element> {

        public var additive: Algebra.Group<Element>.Abelian

        public var multiplicative: Algebra.Monoid<Element>.Commutative

        public var reciprocal: (Element) throws(Algebra.Field<Element>.Error) -> Element

        @inlinable
        public init(
            additive: Algebra.Group<Element>.Abelian,
            multiplicative: Algebra.Monoid<Element>.Commutative,
            reciprocal: @escaping (Element) throws(Algebra.Field<Element>.Error) -> Element
        ) {
            self.additive = additive
            self.multiplicative = multiplicative
            self.reciprocal = reciprocal
        }
    }
}

extension Algebra.Field: @unchecked Sendable where Element: Sendable {}

extension Algebra.Field {

    public enum Error: Swift.Error, Sendable {

        case nonInvertible
    }
}
