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
}
