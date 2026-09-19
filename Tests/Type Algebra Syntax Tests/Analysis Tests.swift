import Type_Algebra_Syntax
import SwiftParser
import SwiftSyntax
import Testing

private func type(_ source: String) throws -> TypeSyntax {
    let file = Parser.parse(source: "struct S<A> { let value: \(source) }")
    let declaration = try #require(file.statements.first?.item.as(StructDeclSyntax.self))
    return try #require(StoredProperties(declaration).fields.first?.type)
}
@Test func polarityTracksNestedArrows() throws {
    #expect(TypeExpression(try type("[A?]"), parameters: ["A"]).polarity(of: "A") == .positive)
    #expect(TypeExpression(try type("(A) -> Int"), parameters: ["A"]).polarity(of: "A") == .negative)
    let mixed = TypeExpression(try type("(A) -> A"), parameters: ["A"])
    #expect(mixed.polarity(of: "A") == [.positive, .negative])
    #expect(throws: AlgebraDiagnostic.self) { try MappingExpression.apply(mixed, to: "value", forward: [:], backward: ["A": "f"]) }
    #expect(TypeExpression(try type("((A) -> Int) -> Int"), parameters: ["A"]).polarity(of: "A") == .positive)
}
@Test(arguments: ["Unknown<A>", "(A) async -> Int", "(inout A) -> Void", "@Sendable (A) -> Int"])
func unsupportedShapesStayVisible(_ source: String) throws {
    let shape = TypeExpression(try type(source), parameters: ["A"])
    #expect(shape.diagnostic != nil)
    #expect(shape.polarity(of: "A").contains(.unknown))
}
@Test func constantsAndQualifiedNamesAreNotGenericPositions() throws {
    let shape = TypeExpression(try type("String"), parameters: ["A"])
    #expect(shape.polarity(of: "A").isEmpty)
    #expect(shape.isPolynomial)
}
@Test(arguments: ["indirect enum Tree<A> { case node(Tree<Int>) }", "indirect enum Tree<A> { case node([Tree<A>]) }"])
func nonregularRecursionIsRejected(_ source: String) throws {
    let file = Parser.parse(source: source)
    let declaration = try #require(file.statements.first?.item.as(EnumDeclSyntax.self))
    #expect(throws: AlgebraDiagnostic.self) { try RecursiveShape.validate(declaration) }
}
@Test func regularGenericRecursionIsAccepted() throws {
    let file = Parser.parse(source: "indirect enum Tree<A> { case leaf(A); case node(Tree<A>, Self) }")
    try RecursiveShape.validate(try #require(file.statements.first?.item.as(EnumDeclSyntax.self)))
}
@Test(arguments: ["let value = 1", "var value: Int { didSet {} }", "lazy var value: Int = 1"])
func invalidStoredConstructionIsDiagnosed(_ property: String) throws {
    let file = Parser.parse(source: "struct S { \(property) }")
    let declaration = try #require(file.statements.first?.item.as(StructDeclSyntax.self))
    #expect(!StoredProperties(declaration, requiresMemberwise: true).diagnostics.isEmpty)
}

@Test func visibleMutualRecursionIsRejected() throws {
    let source = Parser.parse(source: "enum Domain { indirect enum A { case b(B) }; indirect enum B { case a(A) } }")
    let declaration = try #require(source.statements.first?.item.as(EnumDeclSyntax.self))
    #expect(throws: AlgebraDiagnostic.self) { try RecursiveShape.validateNamespace(declaration) }
}
