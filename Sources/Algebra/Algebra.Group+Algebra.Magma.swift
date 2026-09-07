
extension Algebra.Magma {

    @inlinable
    public init(_ group: Algebra.Group<Element>) {
        self.init(combining: group.combining)
    }
}
