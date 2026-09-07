
extension Algebra.Semiring {

    @inlinable
    public init(_ ring: Algebra.Ring<Element>) {
        self = ring.semiring
    }
}
