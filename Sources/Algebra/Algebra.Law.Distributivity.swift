
extension Algebra.Law {

    public enum Distributivity {}
}

extension Algebra.Law.Distributivity {

    @inlinable
    public static func left<
        Element: Equatable,
        Sequence: Swift.Sequence<Element>
    >(
        of ring: Algebra.Ring<Element>,
        over elements: Sequence
    ) -> Algebra.Law.Violation<Element>? {
        let elements = Array(elements)

        for a in elements {
            for b in elements {
                for c in elements {
                    let lhs = ring.multiplying(a, ring.adding(b, c))
                    let rhs = ring.adding(ring.multiplying(a, b), ring.multiplying(a, c))
                    if lhs != rhs {
                        return .init(
                            law: "distributivity-left",
                            elements: [a, b, c],
                            lhs: lhs,
                            rhs: rhs
                        )
                    }
                }
            }
        }
        return nil
    }

    @inlinable
    public static func right<
        Element: Equatable,
        Sequence: Swift.Sequence<Element>
    >(
        of ring: Algebra.Ring<Element>,
        over elements: Sequence
    ) -> Algebra.Law.Violation<Element>? {
        let elements = Array(elements)

        for a in elements {
            for b in elements {
                for c in elements {
                    let lhs = ring.multiplying(ring.adding(a, b), c)
                    let rhs = ring.adding(ring.multiplying(a, c), ring.multiplying(b, c))
                    if lhs != rhs {
                        return .init(
                            law: "distributivity-right",
                            elements: [a, b, c],
                            lhs: lhs,
                            rhs: rhs
                        )
                    }
                }
            }
        }
        return nil
    }

    @inlinable
    public static func scalar<
        Scalar,
        Vector: Equatable,
        Scalars: Swift.Sequence<Scalar>,
        Vectors: Swift.Sequence<Vector>
    >(
        of module: Algebra.Module<Scalar, Vector>,
        over scalars: Scalars,
        _ vectors: Vectors
    ) -> Algebra.Law.Violation<Vector>? {
        let vectors = Array(vectors)

        for r in scalars {
            for v in vectors {
                for w in vectors {
                    let lhs = module.scaling(r, module.vectors.combining(v, w))
                    let rhs = module.vectors.combining(module.scaling(r, v), module.scaling(r, w))
                    if lhs != rhs {
                        return .init(
                            law: "distributivity-scalar",
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

    @inlinable
    public static func addition<
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
                for v in vectors {
                    let lhs = module.scaling(module.scalars.adding(r, s), v)
                    let rhs = module.vectors.combining(module.scaling(r, v), module.scaling(s, v))
                    if lhs != rhs {
                        return .init(
                            law: "distributivity-addition",
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
