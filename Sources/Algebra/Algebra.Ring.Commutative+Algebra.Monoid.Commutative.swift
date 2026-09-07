extension Algebra.Monoid.Commutative {

    @inlinable
    public init(_ commutativeRing: Algebra.Ring<Element>.Commutative) {
        self.init(monoid: commutativeRing.ring.multiplicative)
    }
}
