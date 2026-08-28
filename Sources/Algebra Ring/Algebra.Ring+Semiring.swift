import Algebra_Semiring

extension Algebra.Ring {

    @inlinable
    public var semiring: Algebra.Semiring<Element> {
        .init(
            additive: additive.commutative,
            multiplicative: multiplicative
        )
    }
}

extension Algebra.Ring.Commutative {

    @inlinable
    public var semiring: Algebra.Semiring<Element>.Commutative {
        .init(semiring: ring.semiring)
    }
}

extension Algebra.Semiring {

    @inlinable
    public init(_ ring: Algebra.Ring<Element>) {
        self = ring.semiring
    }
}

extension Algebra.Semiring.Commutative {

    @inlinable
    public init(_ commutativeRing: Algebra.Ring<Element>.Commutative) {
        self = commutativeRing.semiring
    }
}
