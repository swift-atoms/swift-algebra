extension Algebra {

    @frozen
    public struct Module<Scalar, Vector> {

        public var scalars: Algebra.Ring<Scalar>

        public var vectors: Algebra.Group<Vector>.Abelian

        public var scaling: (Scalar, Vector) -> Vector

        @inlinable
        public init(
            scalars: Algebra.Ring<Scalar>,
            vectors: Algebra.Group<Vector>.Abelian,
            scaling: @escaping (Scalar, Vector) -> Vector
        ) {
            self.scalars = scalars
            self.vectors = vectors
            self.scaling = scaling
        }
    }
}

extension Algebra.Module: @unchecked Sendable where Scalar: Sendable, Vector: Sendable {}
