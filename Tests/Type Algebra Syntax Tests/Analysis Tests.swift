import CustomDump
import Type_Algebra_Syntax
import SwiftParser
import SwiftSyntax
import Testing

private func type(_ source: String) throws -> TypeSyntax {
    let file = Parser.parse(source: "struct S<A> { let value: \(source) }")
    let declaration = try #require(file.statements.first?.item.as(StructDeclSyntax.self))
    return try #require(Type.Syntax.Properties(declaration).fields.first?.type)
}
@Test func polarityTracksNestedArrows() throws {
    #expect(Type.Syntax.Expression(try type("[A?]"), parameters: ["A"]).polarity(of: "A") == .positive)
    #expect(Type.Syntax.Expression(try type("(A) -> Int"), parameters: ["A"]).polarity(of: "A") == .negative)
    let mixed = Type.Syntax.Expression(try type("(A) -> A"), parameters: ["A"])
    #expect(mixed.polarity(of: "A") == [.positive, .negative])
    #expect(throws: Type.Failure.self) { try Type.Syntax.Mapping.apply(mixed, to: "value", forward: [:], backward: ["A": "f"]) }
    #expect(Type.Syntax.Expression(try type("((A) -> Int) -> Int"), parameters: ["A"]).polarity(of: "A") == .positive)
}
@Test(arguments: ["Unknown<A>", "(A) async -> Int", "(inout A) -> Void", "@Sendable (A) -> Int"])
func unsupportedShapesStayVisible(_ source: String) throws {
    let shape = Type.Syntax.Expression(try type(source), parameters: ["A"])
    #expect(shape.diagnostic != nil)
    #expect(shape.polarity(of: "A").contains(.unknown))
}
@Test func constantsAndQualifiedNamesAreNotGenericPositions() throws {
    let shape = Type.Syntax.Expression(try type("String"), parameters: ["A"])
    #expect(shape.polarity(of: "A").isEmpty)
    #expect(shape.isPolynomial)
}
@Test(arguments: ["indirect enum Tree<A> { case node(Tree<Int>) }", "indirect enum Tree<A> { case node([Tree<A>]) }"])
func nonregularRecursionIsRejected(_ source: String) throws {
    let file = Parser.parse(source: source)
    let declaration = try #require(file.statements.first?.item.as(EnumDeclSyntax.self))
    #expect(throws: Type.Failure.self) { try Type.Syntax.Recursion.validate(declaration) }
}
@Test func regularGenericRecursionIsAccepted() throws {
    let file = Parser.parse(source: "indirect enum Tree<A> { case leaf(A); case node(Tree<A>, Self) }")
    try Type.Syntax.Recursion.validate(try #require(file.statements.first?.item.as(EnumDeclSyntax.self)))
}
@Test(arguments: ["let value = 1", "var value: Int { didSet {} }", "lazy var value: Int = 1"])
func invalidStoredConstructionIsDiagnosed(_ property: String) throws {
    let file = Parser.parse(source: "struct S { \(property) }")
    let declaration = try #require(file.statements.first?.item.as(StructDeclSyntax.self))
    #expect(!Type.Syntax.Properties(declaration, requiresMemberwise: true).diagnostics.isEmpty)
}

@Test func visibleMutualRecursionIsRejected() throws {
    let source = Parser.parse(source: "enum Domain { indirect enum A { case b(B) }; indirect enum B { case a(A) } }")
    let declaration = try #require(source.statements.first?.item.as(EnumDeclSyntax.self))
    #expect(throws: Type.Failure.self) { try Type.Syntax.Recursion.validateNamespace(declaration) }
}

@Test func syntaxAndHandwrittenDescriptionsAgree() throws {
    let parsed = Type.Syntax.Expression(try type("([A?], (A) -> Int)"), parameters: ["A"])
    let hand = Type.Expression.product([
        .list(.optional(.variable(.init("A")))),
        .exponential(domain: .product([.variable(.init("A"))]), codomain: .atom(.init("Int", scope: ["Swift"])))
    ])
    #expect(parsed.algebra == hand)
    #expect(parsed.algebra.polarity(of: .init("A")) == [.positive, .negative])
}

@Test func syntaxPreservesLabelsWhileCoreSelectsCoordinates() throws {
    let record = try Type.Syntax.Record([
        .init("name", type: "String", label: "_"),
        .init("count", type: "Int", initial: "0")
    ])
    let selected = try record.selecting(["count", "name"])
    let declaration = try selected.initializer(access: "public ")
    #expect(declaration.contains("count: Int = 0, _ name: String"))
    #expect(declaration.contains("self.name = name"))
    #expect(throws: Type.Failure.self) { try record.selecting(["missing"]) }
}

@Test func listsAreTraversableButNotFinitePolynomials() throws {
    let parsed = Type.Syntax.Expression(try type("[A]"), parameters: ["A"])
    #expect(parsed.isTraversable)
    #expect(!parsed.isPolynomial)
}

@Test func traversalInterpretsPositionsInDeclarationOrder() throws {
    func positions(_ source: String) throws -> [String] {
        try Type.Syntax.Traversal.interpret(Type.Syntax.Expression(type(source), parameters: ["A"]), value: "root", parameter: "A",
            constant: { _, _ in [] }, transform: { [$0] },
            collection: { optional, _, binding, positions in [optional ? "optional" : "list", binding] + positions },
            product: { _, fields, _ in fields.flatMap { $0.1 } })
    }
    expectNoDifference(try positions("(Int, [A?], A)"), ["list", "element1", "optional", "element2", "element2", "(root).2"])
    #expect(throws: Type.Failure.self) { try positions("(A) -> Int") }
    #expect(throws: Type.Failure.self) { try positions("Unknown<A>") }
}
