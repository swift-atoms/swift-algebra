import Algebra_Group

extension Algebra.Ring {

    @frozen
    public struct Commutative {

        public var ring: Algebra.Ring<Element>

        @inlinable
        public init(ring: Algebra.Ring<Element>) {
            self.ring = ring
        }
    }
}

extension Algebra.Ring.Commutative: Sendable where Element: Sendable {}
