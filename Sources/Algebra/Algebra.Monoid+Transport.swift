extension Algebra.Monoid {
    /// Transports this chosen monoid. The caller must establish both inverse equations.
    /// No equality or numeric operation is inferred from the destination type.
    public func transported<Other>(to forward: @escaping (Element) -> Other,
        from backward: @escaping (Other) -> Element) -> Algebra.Monoid<Other> {
        .init(identity: forward(identity), combining: { lhs, rhs in
            forward(self.combining(backward(lhs), backward(rhs)))
        })
    }
}
