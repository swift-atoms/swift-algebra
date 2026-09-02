public import Algebra_Lattice
public import Algebra_Ring

extension Algebra {

    @frozen
    public struct Boolean<Element> {

        public var lattice: Algebra.Lattice<Element>

        public var complementing: (borrowing Element) -> Element

        @inlinable
        public init(
            lattice: Algebra.Lattice<Element>,
            complementing: @escaping (borrowing Element) -> Element
        ) {
            self.lattice = lattice
            self.complementing = complementing
        }
    }
}

extension Algebra.Boolean {

    @inlinable
    public init(
        falsity: Element,
        disjunction: @escaping (borrowing Element, borrowing Element) -> Element,
        truth: Element,
        conjunction: @escaping (borrowing Element, borrowing Element) -> Element,
        negation: @escaping (borrowing Element) -> Element
    ) {
        self.init(
            lattice: .init(
                bottom: falsity,
                join: disjunction,
                top: truth,
                meet: conjunction
            ),
            complementing: negation
        )
    }
}

extension Algebra.Boolean {

    @inlinable
    public var falsity: Element { lattice.bottom }

    @inlinable
    public var truth: Element { lattice.top }

    @inlinable
    public var disjunction: Algebra.Semilattice<Element> { lattice.join }

    @inlinable
    public var conjunction: Algebra.Semilattice<Element> { lattice.meet }

    @inlinable
    public func negation(_ value: borrowing Element) -> Element {
        complementing(value)
    }

    @inlinable
    public func exclusive(
        _ lhs: borrowing Element,
        _ rhs: borrowing Element
    ) -> Element {
        conjunction(disjunction(lhs, rhs), negation(conjunction(lhs, rhs)))
    }

    @inlinable
    public func implication(
        _ lhs: borrowing Element,
        _ rhs: borrowing Element
    ) -> Element {
        disjunction(negation(lhs), rhs)
    }

    @inlinable
    public func equivalence(
        _ lhs: borrowing Element,
        _ rhs: borrowing Element
    ) -> Element {
        negation(exclusive(lhs, rhs))
    }
}

extension Algebra.Boolean {

    @inlinable
    public var semiring: Algebra.Semiring<Element>.Commutative {
        .init(
            semiring: .init(
                additive: disjunction.monoid,
                multiplicative: conjunction.monoid.monoid
            )
        )
    }

    @inlinable
    public var ring: Algebra.Ring<Element>.Commutative {
        .init(
            ring: .init(
                additive: .init(
                    group: .init(
                        identity: falsity,
                        combining: exclusive,
                        inverting: { $0 }
                    )
                ),
                multiplicative: conjunction.monoid.monoid
            )
        )
    }
}
