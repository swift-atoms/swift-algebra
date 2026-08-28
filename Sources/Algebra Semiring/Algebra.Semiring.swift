import Algebra_Monoid

extension Algebra {

    @frozen
    public struct Semiring<Element> {

        public var additive: Algebra.Monoid<Element>.Commutative

        public var multiplicative: Algebra.Monoid<Element>

        @inlinable
        public init(
            additive: Algebra.Monoid<Element>.Commutative,
            multiplicative: Algebra.Monoid<Element>
        ) {
            self.additive = additive
            self.multiplicative = multiplicative
        }
    }
}

extension Algebra.Semiring: Sendable where Element: Sendable {}
