extension Algebra.Law {

    public enum Action {}
}

extension Algebra.Law.Action {

    @inlinable
    public static func identity<
        Scalar,
        Vector: Equatable,
        Sequence: Swift.Sequence<Vector>
    >(
        of module: Algebra.Module<Scalar, Vector>,
        over vectors: Sequence
    ) -> Algebra.Law.Violation<Vector>? {
        for m in vectors {
            let lhs = module.scaling(module.one, m)
            if lhs != m {
                return .init(law: "action-identity", elements: [m], lhs: lhs, rhs: m)
            }
        }
        return nil
    }
}
