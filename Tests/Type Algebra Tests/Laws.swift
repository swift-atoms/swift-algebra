import Type_Algebra
import CustomDump
import Testing

private let x = Type.Variable("X")
private let y = Type.Variable("Y")
private let a = Type.Atom("A", scope: ["Example"])
private let b = Type.Atom("B", scope: ["Example"])

@Suite struct Algebra {
    @Test func distributionAndUnitsRoundTrip() throws {
        let distribution = Type.Isomorphism.distribution(.atom(a), over: [.atom(b), .unit])
        for i in 0..<4 {
            for payload in [Type.Value.sum(0, .atom(b, i)), .sum(1, .unit)] {
                let value = Type.Value.product([.atom(a, i), payload])
                expectNoDifference(try distribution.backward.apply(distribution.forward.apply(value)), value)
            }
        }
        let product = try Type.Isomorphism.productUnit(.atom(a))
        let sum = try Type.Isomorphism.sumZero(.atom(a))
        expectNoDifference(try product.forward.apply(product.backward.apply(.atom(a, 3))), .atom(a, 3))
        expectNoDifference(try sum.forward.apply(sum.backward.apply(.atom(a, 3))), .atom(a, 3))
    }

    @Test func productUniversalProperty() throws {
        let factors: [Type.Expression] = [.atom(a), .atom(b)]
        let first = try Type.Morphism.projection(factors, at: 0)
        let second = try Type.Morphism.projection(factors, at: 1)
        let paired = try Type.Morphism.pairing(from: .product(factors), [first, second])
        for i in 0..<3 {
            for j in 0..<4 {
                let value = Type.Value.product([.atom(a, i), .atom(b, j)])
                expectNoDifference(try paired.apply(value), value)
                expectNoDifference(try paired.followed(by: first).apply(value), try first.apply(value))
                expectNoDifference(try paired.followed(by: second).apply(value), try second.apply(value))
            }
        }
    }

    @Test func coproductUniversalProperty() throws {
        let alternatives: [Type.Expression] = [.atom(a), .atom(b)]
        let injections = try alternatives.indices.map { try Type.Morphism.injection(alternatives, at: $0) }
        let eliminate = try Type.Morphism.elimination(to: .sum(alternatives), injections)
        for i in 0..<3 {
            for (index, atom) in [a, b].enumerated() {
                let value = Type.Value.atom(atom, i)
                expectNoDifference(try injections[index].followed(by: eliminate).apply(value), .sum(index, value))
            }
        }
    }

    @Test func compositionAndIdentity() throws {
        let factors: [Type.Expression] = [.atom(a), .atom(b)]
        let p = try Type.Morphism.projection(factors, at: 0)
        let i = try Type.Morphism.injection([.atom(a), .unit], at: 0)
        let end = Type.Morphism.terminal(from: i.codomain)
        let value = Type.Value.product([.atom(a, 2), .atom(b, 7)])
        expectNoDifference(try p.followed(by: i).followed(by: end).apply(value), try p.followed(by: i.followed(by: end)).apply(value))
        expectNoDifference(try Type.Morphism.identity(p.domain).followed(by: p).apply(value), try p.apply(value))
        expectNoDifference(try p.followed(by: .identity(p.codomain)).apply(value), try p.apply(value))
    }

    @Test func checkedMapsRejectBadTypes() throws {
        #expect(throws: Type.Failure.self) { try Type.Morphism.identity(.atom(a)).followed(by: .identity(.atom(b))) }
        #expect(throws: Type.Failure.self) { try Type.Morphism.projection([], at: 0) }
        #expect(throws: Type.Failure.self) { try Type.Morphism.pairing(from: .atom(a), [.identity(.atom(b))]) }
        #expect(throws: Type.Failure.self) { try Type.Morphism.identity(.atom(a)).apply(.atom(b, 1)) }
        #expect(throws: Type.Failure.self) { try Type.Equation(.identity(.atom(a)), .identity(.atom(b))) }
    }

    @Test func subproductsAndPermutations() throws {
        let record = try Type.Record([.init("a", .atom(a)), .init("b", .atom(b))])
        expectNoDifference(try record.selections().count, 4)
        let value = Type.Value.product([.atom(a, 3), .atom(b, 4)])
        let permutation = try Type.Isomorphism.permutation(of: record, order: ["b", "a"])
        expectNoDifference(try permutation.backward.apply(permutation.forward.apply(value)), value)
        let reversed = try permutation.forward.apply(value)
        expectNoDifference(try permutation.forward.apply(permutation.backward.apply(reversed)), reversed)
        expectNoDifference(try record.selecting([]).projection.apply(value), .product([]))
        #expect(throws: Type.Failure.self) { try record.selecting(["a", "a"]) }
        #expect(throws: Type.Failure.self) { try record.excluding(["missing"]) }
        #expect(throws: Type.Failure.self) { try record.selections(limit: 3) }
    }

    @Test func fiveCoordinatesHaveThirtyTwoSelections() throws {
        let record = try Type.Record((0..<5).map { .init("field\($0)", .unit) })
        let selections = try record.selections()
        expectNoDifference(selections.count, 32)
        for (size, count) in [1, 5, 10, 10, 5, 1].enumerated() {
            expectNoDifference(selections.filter { $0.indices.count == size }.count, count)
        }
    }

    @Test func changingCoordinatePreservesItsComplement() throws {
        let record = try Type.Record([.init("left", .atom(a)), .init("right", .atom(b))])
        let lens = try Type.Lens.coordinate("left", in: record, replacingWith: .variable(x))
        let whole = Type.Value.product([.atom(a, 3), .atom(b, 7)])
        expectNoDifference(try lens.get.apply(whole), .atom(a, 3))
        expectNoDifference(try lens.put.apply(.product([whole, .variable(x, 9)])), .product([.variable(x, 9), .atom(b, 7)]))
        #expect(throws: Type.Failure.self) { try lens.put.apply(.product([whole, .atom(a, 9)])) }
    }

    @Test func lensLaws() throws {
        let record = try Type.Record([.init("a", .atom(a)), .init("b", .atom(b))])
        let lens = try Type.Lens.coordinate("a", in: record)
        for old in 0..<3 {
            for new in 0..<3 {
                let whole = Type.Value.product([.atom(a, old), .atom(b, 9)])
                let replacement = Type.Value.atom(a, new)
                let changed = try lens.put.apply(.product([whole, replacement]))
                expectNoDifference(try lens.get.apply(changed), replacement)
                expectNoDifference(try lens.put.apply(.product([whole, lens.get.apply(whole)])), whole)
                expectNoDifference(try lens.put.apply(.product([changed, .atom(a, 7)])),
                    try lens.put.apply(.product([whole, .atom(a, 7)])))
            }
        }
    }

    @Test func derivativeCountsPointedPositions() throws {
        let polynomial = Type.Polynomial.product([.variable(x), .variable(x), .variable(y)])
        let derivative = polynomial.derivative(withRespectTo: x)
        for n in 0..<5 {
            for m in 0..<4 {
                expectNoDifference(try derivative.cardinality(variables: [x: n, y: m]), 2 * n * m)
            }
        }
        expectNoDifference(try polynomial.derivative(withRespectTo: y).derivative(withRespectTo: y).cardinality(variables: [x: 3, y: 4]), 0)
        #expect(throws: Type.Failure.self) { try Type.Polynomial(.list(.variable(x))) }
        #expect(throws: Type.Failure.self) { try Type.Polynomial(.exponential(domain: .variable(x), codomain: .unit)) }
        #expect(throws: Type.Failure.self) { try Type.Polynomial.product([.atom(a), .atom(b)]).cardinality(atoms: [a: Int.max, b: 2]) }
    }

    @Test func contextsRetainConstructorAndPosition() throws {
        let tree = Type.Polynomial.sum([.product([.atom(a)]), .product([.variable(x), .atom(b), .variable(x)])])
        let contexts = try tree.contexts(for: x)
        expectNoDifference(contexts.map(\.alternative), [1, 1])
        expectNoDifference(contexts.map(\.position), [0, 2])
        expectNoDifference(contexts[0].remainder, [.atom(b), .variable(x)])
        #expect(throws: Type.Failure.self) { try Type.Polynomial.sum([.product([.sum([.variable(x)])])]).contexts(for: x) }
    }

    @Test func varianceAndMappingAreIndependentOfSwift() throws {
        let mixed = Type.Expression.exponential(domain: .variable(x), codomain: .variable(x))
        expectNoDifference(mixed.polarity(of: x), [.positive, .negative])
        #expect(throws: Type.Failure.self) { try Type.Mapping.derive(mixed, forward: [x]) }
        expectNoDifference(try Type.Mapping.derive(mixed, forward: [x], backward: [x]),
            .exponential(domain: .transform(x, .backward), codomain: .transform(x, .forward)))
        let twice = Type.Expression.exponential(domain: .exponential(domain: .variable(x), codomain: .unit), codomain: .unit)
        expectNoDifference(twice.polarity(of: x), .positive)
        _ = try Type.Mapping.derive(twice, forward: [x])
        let truth = Type.Expression.sum([.unit, .unit])
        let doublePower = Type.Expression.exponential(domain: .exponential(domain: .variable(x), codomain: truth), codomain: truth)
        expectNoDifference(doublePower.polarity(of: x), .positive)
        _ = try Type.Mapping.derive(doublePower, forward: [x])
        #expect(throws: Type.Failure.self) { try Type.Recursion(.least, variable: x, body: doublePower) }
        #expect(throws: Type.Failure.self) { try Type.Recursion(.greatest, variable: x, body: doublePower) }
        #expect(Type.Expression.list(.variable(x)).isTraversable)
        #expect(!mixed.isTraversable)
        #expect(throws: Type.Failure.self) { try Type.Mapping.derive(.opaque(a, [x]), forward: [x]) }
    }

    @Test func signaturesRetainDependentResults() throws {
        let signature = try Type.Signature([
            .init("create", input: .atom(a), output: .atom(b)),
            .init("delete", input: .atom(b), output: .unit)
        ])
        expectNoDifference(try signature.response(to: "create"), .atom(b))
        expectNoDifference(try signature.response(to: "delete"), .unit)
        expectNoDifference(signature.request, .sum([.atom(a), .atom(b)]))
        let program = try Type.Recursion.free(layer: signature.continuation(.variable(x)), variable: x, returning: .atom(a))
        expectNoDifference(program.kind, .least)
        #expect(throws: Type.Failure.self) { try signature.response(to: "read") }
        #expect(throws: Type.Failure.self) { try Type.Recursion(.least, variable: x, body: .exponential(domain: .variable(x), codomain: .unit)) }
        #expect(throws: Type.Failure.self) { try Type.Recursion.free(layer: .variable(x), variable: x, returning: .variable(x)) }
        let batch = try Type.Program.Batch(["create", "delete", "create"], in: signature, returning: .atom(a))
        expectNoDifference(batch.outputs, .product([.atom(b), .unit, .atom(b)]))
        expectNoDifference(try Type.Program.monadic(signature, returning: .atom(a), variable: x), program)
        expectNoDifference(try Type.Program.interaction(signature, returning: .atom(a), variable: x).kind, .greatest)
    }

    @Test func effectOrderAndPartialRecordsRemainDistinct() throws {
        let record = try Type.Record([.init("a", .atom(a)), .init("b", .atom(b))])
        #expect(record.partial != record.optional)
        #expect(Type.Construction.retaining(state: .atom(a), failure: .atom(b), value: .unit)
            != Type.Construction.discarding(state: .atom(a), failure: .atom(b), value: .unit))
        let partial = try Type.Polynomial(record.partial)
        expectNoDifference(try partial.cardinality(atoms: [a: 2, b: 3]), 12)
        let whole = try Type.Polynomial(record.optional)
        expectNoDifference(try whole.cardinality(atoms: [a: 2, b: 3]), 7)
    }

    @Test func twoFrontendsShareOneDescription() throws {
        let signature = try Type.Signature([.init("read", input: .atom(a), output: .atom(b))])
        let interface = try Type.Interface(signature: signature, children: Type.Record([]))
        expectNoDifference(try interface.implementation.expression, signature.implementation)
        expectNoDifference(try interface.requests(children: Type.Record([])), signature.request)
        #expect(throws: Type.Failure.self) {
            try Type.Interface(signature: signature, children: Type.Record([.init("read", .unit)]))
        }
    }
}
