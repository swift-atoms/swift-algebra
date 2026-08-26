import Algebra_Module

extension Algebra.Law {

    public enum Compatibility {}
}

extension Algebra.Law.Compatibility {

    @inlinable
    public static func scalar<
        Scalar: Equatable & Sendable,
        Vector: Equatable & Sendable,
        CS: Swift.Collection<Scalar>,
        CV: Swift.Collection<Vector>
    >(
        of module: Algebra.Module<Scalar, Vector>,
        over scalars: CS,
        _ vectors: CV
    ) -> Algebra.Law.Violation<Vector>? {
        for r in scalars {
            for s in scalars {
                for m in vectors {
                    let lhs = module.scaling(module.scalars.multiplying(r, s), m)
                    let rhs = module.scaling(r, module.scaling(s, m))
                    if lhs != rhs {
                        return .init(
                            law: "compatibility",
                            elements: [lhs, rhs],
                            lhs: lhs,
                            rhs: rhs
                        )
                    }
                }
            }
        }
        return nil
    }
}
