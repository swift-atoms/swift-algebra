
extension Algebra.Monoid {

    @inlinable
    public init(_ group: Algebra.Group<Element>) {
        self.init(identity: group.identity, combining: group.combining)
    }
}
