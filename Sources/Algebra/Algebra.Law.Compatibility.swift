extension Algebra.Law {

    public enum Compatibility {}
}

extension Algebra.Law.Compatibility {

    @inlinable
    public static func scalar<
        Scalar: Equatable,
        Vector: Equatable,
        Scalars: Swift.Sequence<Scalar>,
        Vectors: Swift.Sequence<Vector>
    >(
        of module: Algebra.Module<Scalar, Vector>,
        over scalars: Scalars,
        _ vectors: Vectors
    ) -> Algebra.Law.Violation<Vector>? {
        let scalars = Array(scalars)
        let vectors = Array(vectors)

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
