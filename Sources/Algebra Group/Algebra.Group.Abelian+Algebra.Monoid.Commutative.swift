import Algebra_Monoid

extension Algebra.Monoid.Commutative {

    @inlinable
    public init(
        _ abelian: Algebra.Group<Element>.Abelian
    ) {
        self.init(monoid: .init(abelian))
    }
}
