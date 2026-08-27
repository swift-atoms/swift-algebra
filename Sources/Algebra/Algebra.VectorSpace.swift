extension Algebra {

    @frozen
    public struct VectorSpace<Scalar, Vector> {

        public var scalars: Algebra.Field<Scalar>

        public var vectors: Algebra.Group<Vector>.Abelian

        public var scaling: (Scalar, Vector) -> Vector

        @inlinable
        public init(
            scalars: Algebra.Field<Scalar>,
            vectors: Algebra.Group<Vector>.Abelian,
            scaling: @escaping (Scalar, Vector) -> Vector
        ) {
            self.scalars = scalars
            self.vectors = vectors
            self.scaling = scaling
        }
    }
}

extension Algebra.VectorSpace: @unchecked Sendable where Scalar: Sendable, Vector: Sendable {}
