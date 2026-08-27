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

extension Algebra.Semiring.Commutative: Sendable where Element: Sendable {}
