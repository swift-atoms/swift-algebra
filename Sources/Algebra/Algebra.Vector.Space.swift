extension Algebra.Vector {

    @frozen
    public struct Space<Scalar, Element> {

        public var scalars: Algebra.Field<Scalar>

        public var vectors: Algebra.Group<Element>.Abelian

        public var scaling: (borrowing Scalar, borrowing Element) -> Element

        @inlinable
        public init(
            scalars: Algebra.Field<Scalar>,
            vectors: Algebra.Group<Element>.Abelian,
            scaling: @escaping (borrowing Scalar, borrowing Element) -> Element
        ) {
            self.scalars = scalars
            self.vectors = vectors
            self.scaling = scaling
        }
    }
}

extension Algebra.Vector.Space {

    @inlinable
    public var zero: Element { vectors.identity }

    @inlinable
    public func adding(_ lhs: borrowing Element, _ rhs: borrowing Element) -> Element {
        vectors.combining(lhs, rhs)
    }

    @inlinable
    public func subtracting(_ lhs: borrowing Element, _ rhs: borrowing Element) -> Element {
        vectors.combining(lhs, vectors.inverting(rhs))
    }

    @inlinable
    public func negating(_ vector: borrowing Element) -> Element {
        vectors.inverting(vector)
    }

    @inlinable
    public var module: Algebra.Module<Scalar, Element> {
        .init(
            scalars: scalars.ring.ring,
            vectors: vectors,
            scaling: scaling
        )
    }
}
