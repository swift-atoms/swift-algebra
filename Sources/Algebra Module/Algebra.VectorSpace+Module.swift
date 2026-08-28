import Algebra_Field

extension Algebra.VectorSpace {

    @inlinable
    public var module: Algebra.Module<Scalar, Vector> {
        .init(
            scalars: scalars.ring.ring,
            vectors: vectors,
            scaling: scaling
        )
    }
}
