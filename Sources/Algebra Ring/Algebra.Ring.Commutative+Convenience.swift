import Algebra_Group

extension Algebra.Ring.Commutative {

    @inlinable
    public var additive: Algebra.Group<Element>.Abelian { ring.additive }

    @inlinable
    public var multiplicative: Algebra.Monoid<Element> { ring.multiplicative }
}
