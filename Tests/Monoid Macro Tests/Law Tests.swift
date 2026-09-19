import Monoid_Macro
import Algebra_Test_Support
import Testing
@Monoid private struct Totals: Equatable { let count: Int; let label: String }
@Monoid private struct Unit: Equatable {}
@Test func productMonoidInheritsItsChosenComponentLaws() {
    let integers = Algebra.Monoid<Int>(identity: 0, combining: +)
    let strings = Algebra.Monoid<String>(identity: "", combining: +)
    let monoid = Totals.monoid(count: integers, label: strings)
    let samples = [-1, 0, 1].flatMap { n in ["", "a", "b"].map { Totals(count: n, label: $0) } }
    #expect(Algebra.Law.Associativity.check(of: monoid.semigroup, over: samples) == nil)
    #expect(Algebra.Law.Equation.check("left unit", over: samples, lhs: { monoid.combining(monoid.identity, $0) }, rhs: { $0 }) == nil)
    #expect(Algebra.Law.Equation.check("right unit", over: samples, lhs: { monoid.combining($0, monoid.identity) }, rhs: { $0 }) == nil)
    #expect(Unit.monoid().combining(Unit(), Unit()) == Unit())
}
@Test func numericChoiceIsExplicitAndTransportPreservesIt() {
    let addition = Algebra.Monoid<Int>(identity: 0, combining: +)
    let multiplication = Algebra.Monoid<Int>(identity: 1, combining: *)
    #expect(addition.combining(2, 3) == 5)
    #expect(multiplication.combining(2, 3) == 6)
    struct Wrapped: Equatable { let value: Int }
    let transported = addition.transported(to: Wrapped.init, from: { $0.value })
    #expect(Algebra.Law.Equation.check("transport operation", over: [-2, 0, 3], lhs: { transported.combining(Wrapped(value: $0), Wrapped(value: 1)).value }, rhs: { addition.combining($0, 1) }) == nil)
}
