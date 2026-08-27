extension Algebra.Group {

    @frozen
    public struct Abelian {

        public var group: Algebra.Group<Element>

        @inlinable
        public init(group: Algebra.Group<Element>) {
            self.group = group
        }
    }
}

extension Algebra.Group.Abelian: Sendable where Element: Sendable {}
