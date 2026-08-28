import Algebra_Field

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

extension Algebra.VectorSpace {

    @inlinable
    public var zero: Vector { vectors.identity }

    @inlinable
    public func adding(_ lhs: Vector, _ rhs: Vector) -> Vector {
        vectors.combining(lhs, rhs)
    }

    @inlinable
    public func subtracting(_ lhs: Vector, _ rhs: Vector) -> Vector {
        vectors.combining(lhs, vectors.inverting(rhs))
    }

    @inlinable
    public func negating(_ vector: Vector) -> Vector {
        vectors.inverting(vector)
    }

    @inlinable
    public var module: Algebra.Module<Scalar, Vector> {
        .init(
            scalars: scalars.ring.ring,
            vectors: vectors,
            scaling: scaling
        )
    }
}
