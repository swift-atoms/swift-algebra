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
