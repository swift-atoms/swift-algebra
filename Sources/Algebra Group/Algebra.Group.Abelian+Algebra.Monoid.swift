import Algebra_Monoid

extension Algebra.Monoid {

    @inlinable
    public init(
        _ abelian: Algebra.Group<Element>.Abelian
    ) {
        self.init(identity: abelian.group.identity, combining: abelian.group.combining)
    }
}
