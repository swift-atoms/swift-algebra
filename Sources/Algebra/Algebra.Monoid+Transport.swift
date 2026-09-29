extension Algebra.Monoid {
    public func transported<Other>(to forward: @escaping (Element) -> Other,
        from backward: @escaping (Other) -> Element) -> Algebra.Monoid<Other> {
        .init(identity: forward(identity), combining: { lhs, rhs in
            forward(self.combining(backward(lhs), backward(rhs)))
        })
    }
}
