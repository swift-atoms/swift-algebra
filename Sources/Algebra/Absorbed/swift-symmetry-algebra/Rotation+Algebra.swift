#if Symmetry
    public import Symmetry

    extension Rotation where N == 2, Scalar: BinaryFloatingPoint & Sendable {

        @inlinable
        public static var group: Algebra.Group<Self>.Abelian {
            .init(
                group: .init(
                    identity: .identity,
                    combining: { lhs, rhs in
                        let a =
                            lhs.matrix[0][0] * rhs.matrix[0][0]
                            + lhs.matrix[0][1] * rhs.matrix[1][0]
                        let b =
                            lhs.matrix[0][0] * rhs.matrix[0][1]
                            + lhs.matrix[0][1] * rhs.matrix[1][1]
                        let c =
                            lhs.matrix[1][0] * rhs.matrix[0][0]
                            + lhs.matrix[1][1] * rhs.matrix[1][0]
                        let d =
                            lhs.matrix[1][0] * rhs.matrix[0][1]
                            + lhs.matrix[1][1] * rhs.matrix[1][1]
                        var m = InlineArray<2, InlineArray<2, Scalar>>(
                            repeating: InlineArray<2, Scalar>(repeating: .zero)
                        )
                        m[0][0] = a
                        m[0][1] = b
                        m[1][0] = c
                        m[1][1] = d
                        return Self(matrix: m)
                    },
                    inverting: { rotation in
                        var m = InlineArray<2, InlineArray<2, Scalar>>(
                            repeating: InlineArray<2, Scalar>(repeating: .zero)
                        )
                        m[0][0] = rotation.matrix[0][0]
                        m[0][1] = rotation.matrix[1][0]
                        m[1][0] = rotation.matrix[0][1]
                        m[1][1] = rotation.matrix[1][1]
                        return Self(matrix: m)
                    }
                )
            )
        }

        @inlinable
        public func concatenating(_ other: Self) -> Self {
            Self.group.combining(self, other)
        }

        @inlinable
        public var inverted: Self {
            Self.group.inverting(self)
        }
    }
#endif
