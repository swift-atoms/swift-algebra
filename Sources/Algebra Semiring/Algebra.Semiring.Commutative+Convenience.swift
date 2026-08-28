import Algebra_Monoid

extension Algebra.Semiring.Commutative {

    @inlinable
    public var additive: Algebra.Monoid<Element>.Commutative { semiring.additive }

    @inlinable
    public var multiplicative: Algebra.Monoid<Element> { semiring.multiplicative }
}
