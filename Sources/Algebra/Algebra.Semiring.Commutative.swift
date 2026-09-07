extension Algebra.Semiring {

    @frozen
    public struct Commutative {

        public var semiring: Algebra.Semiring<Element>

        @inlinable
        public init(semiring: Algebra.Semiring<Element>) {
            self.semiring = semiring
        }
    }
}

extension Algebra.Semiring.Commutative {

    @inlinable
    public var additive: Algebra.Monoid<Element>.Commutative { semiring.additive }

    @inlinable
    public var multiplicative: Algebra.Monoid<Element> { semiring.multiplicative }
}
