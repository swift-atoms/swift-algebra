#if Symmetry
    public import Symmetry

    extension Shear where N == 2, Scalar: Sendable {

        @inlinable
        public static var group: Algebra.Group<Self>.Abelian {
            .init(
                group: .init(
                    identity: .identity,
                    combining: { lhs, rhs in
                        Self(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
                    },
                    inverting: { shear in
                        Self(x: -shear.x, y: -shear.y)
                    }
                )
            )
        }

        @inlinable
        public func composed(with other: Self) -> Self {
            Self.group.combining(self, other)
        }

        @inlinable
        public var inverted: Self {
            Self.group.inverting(self)
        }
    }
#endif
