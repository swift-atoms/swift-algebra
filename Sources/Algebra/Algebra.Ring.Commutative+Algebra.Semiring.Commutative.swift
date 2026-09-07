extension Algebra.Semiring.Commutative {

    @inlinable
    public init(_ commutativeRing: Algebra.Ring<Element>.Commutative) {
        self = commutativeRing.semiring
    }
}
