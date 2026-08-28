import Algebra_Field

extension Algebra {

    @frozen
    public struct Module<Scalar, Vector> {

        public var scalars: Algebra.Ring<Scalar>

        public var vectors: Algebra.Group<Vector>.Abelian

        public var scaling: (borrowing Scalar, borrowing Vector) -> Vector

        @inlinable
        public init(
            scalars: Algebra.Ring<Scalar>,
            vectors: Algebra.Group<Vector>.Abelian,
            scaling: @escaping (borrowing Scalar, borrowing Vector) -> Vector
        ) {
            self.scalars = scalars
            self.vectors = vectors
            self.scaling = scaling
        }
    }
}

extension Algebra.Module {

    @inlinable
    public var zero: Vector { vectors.identity }

    @inlinable
    public var one: Scalar { scalars.one }

    @inlinable
    public func adding(_ lhs: borrowing Vector, _ rhs: borrowing Vector) -> Vector {
        vectors.combining(lhs, rhs)
    }

    @inlinable
    public func negating(_ vector: borrowing Vector) -> Vector {
        vectors.inverting(vector)
    }
}
