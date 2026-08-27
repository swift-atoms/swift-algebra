extension Algebra {

    @frozen
    public struct Ring<Element> {

        public var additive: Algebra.Group<Element>.Abelian

        public var multiplicative: Algebra.Monoid<Element>

        @inlinable
        public init(
            additive: Algebra.Group<Element>.Abelian,
            multiplicative: Algebra.Monoid<Element>
        ) {
            self.additive = additive
            self.multiplicative = multiplicative
        }
    }
}

extension Algebra.Ring: Sendable where Element: Sendable {}
