import Algebra_Monoid

extension Algebra.Monoid.Commutative {

    @inlinable
    public init(_ semiring: Algebra.Semiring<Element>) {
        self = semiring.additive
    }
}
