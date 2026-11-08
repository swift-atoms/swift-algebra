#if Symmetry
    public import Symmetry

    extension Phase {

        @inlinable
        public static var group: Algebra.Group<Phase>.Abelian {
            .init(
                group: .init(
                    identity: .zero,
                    combining: { lhs, rhs in

                        guard let result = Phase(rawValue: (lhs.rawValue + rhs.rawValue) % 4) else {
                            preconditionFailure("Phase rawValue mod 4 is always in 0...3")
                        }
                        return result
                    },
                    inverting: { phase in

                        guard let result = Phase(rawValue: (4 - phase.rawValue) % 4) else {
                            preconditionFailure("Phase rawValue mod 4 is always in 0...3")
                        }
                        return result
                    }
                )
            )
        }

        @inlinable
        public func composed(with other: Phase) -> Phase {
            Self.group.combining(self, other)
        }

        @inlinable
        public var inverse: Phase {
            Self.group.inverting(self)
        }
    }

    extension Phase {

        @inlinable
        public var next: Phase {
            Self.group.combining(self, .quarter)
        }

        @inlinable
        public var previous: Phase {
            Self.group.combining(self, .threeQuarter)
        }

        @inlinable
        public var opposite: Phase {
            Self.group.combining(self, .half)
        }

        @inlinable
        public static prefix func ! (value: Phase) -> Phase {
            value.opposite
        }
    }
#endif
