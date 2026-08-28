import Algebra_Field

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

extension Algebra.Module {

    @inlinable
    public var zero: Vector { vectors.identity }

    @inlinable
    public var one: Scalar { scalars.one }

    @inlinable
    public func adding(_ lhs: Vector, _ rhs: Vector) -> Vector {
        vectors.combining(lhs, rhs)
    }

    @inlinable
    public func negating(_ vector: Vector) -> Vector {
        vectors.inverting(vector)
    }
}
