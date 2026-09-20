import CustomDump
import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import Testing
import Type_Algebra_Syntax

@Test func handwrittenAlgebraMaterializesAndRunsAsSwift() throws {
    let atom = Type.Atom("Number", scope: ["Study"])
    let value = Type.Expression.atom(atom)
    let alternatives: [Type.Expression] = [value, .unit]
    let distributed = alternatives.map { Type.Expression.product([value, $0]) }
    let interpreter = Type.Syntax.Interpretation(atoms: [atom: TypeSyntax(stringLiteral: "Int")],
        representations: [.sum(alternatives): TypeSyntax(stringLiteral: "Choice"), .sum(distributed): TypeSyntax(stringLiteral: "Distributed")])
    var counter = 0
    func fresh(_ hint: String) -> TokenSyntax {
        counter += 1
        return .identifier("_\(hint)\(counter)")
    }
    let record = try Type.Record([.init("left", value), .init("right", value)])
    let projection = try Type.Morphism.projection([value, value], at: 1)
    let curry = try projection.curried()
    let distribution = Type.Isomorphism.distribution(value, over: alternatives)
    let forward = try interpreter.expression(distribution.forward, appliedTo: ExprSyntax(stringLiteral: "(3, Choice.branch0(7))"), fresh: fresh)
    let backward = try interpreter.expression(distribution.backward, appliedTo: ExprSyntax(stringLiteral: "distributed"), fresh: fresh)
    let curried = try interpreter.expression(curry, appliedTo: ExprSyntax(stringLiteral: "3"), fresh: fresh)
    let uncurried = try interpreter.expression(curry.uncurried(), appliedTo: ExprSyntax(stringLiteral: "(3, 9)"), fresh: fresh)
    let source = """
        \(try interpreter.record(record, named: .identifier("Pair")))
        \(try interpreter.coproduct(alternatives, named: .identifier("Choice")))
        \(try interpreter.coproduct(distributed, named: .identifier("Distributed")))
        let pair = Pair(left: 3, right: 7)
        precondition(pair.right == 7)
        let distributed = \(forward)
        let recovered = \(backward)
        precondition(recovered.0 == 3)
        switch recovered.1 {
        case .branch0(let value): precondition(value == 7)
        case .branch1: preconditionFailure("incorrect alternative")
        }
        let function = \(curried)
        precondition(function(11) == 11)
        precondition(\(uncurried) == 9)
        """
    let process = Process()
    let input = Pipe(), output = Pipe()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
    process.arguments = ["swift", "-swift-version", "6", "-"]
    process.standardInput = input
    process.standardOutput = output
    process.standardError = output
    try process.run()
    input.fileHandleForWriting.write(Data(source.utf8))
    try input.fileHandleForWriting.close()
    let diagnostic = String(decoding: output.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
    process.waitUntilExit()
    #expect(process.terminationStatus == 0, "Generated interpretation failed: \(diagnostic)\n\(source)")
}

@Test func interpretationRequiresExplicitRepresentations() throws {
    let interpreter = Type.Syntax.Interpretation()
    #expect(throws: Type.Failure.self) { try interpreter.type(.atom(.init("Unknown"))) }
    #expect(throws: Type.Failure.self) { try interpreter.type(.sum([.unit, .unit])) }
    #expect(throws: Type.Failure.self) { try interpreter.type(.effect(.init("Async"), .unit)) }
}

@Test func productInterpretationFollowsMapsAndRetainsRepresentation() throws {
    let record = try Type.Syntax.Record([.init("first", type: "Int"), .init("second", type: "String")])
    let whole = record.projecting("source")
    let lens = try Type.Lens.coordinate("second", in: record.algebra)
    expectNoDifference(try whole.applying(lens.get).expression, "source.second")
    let update = try Type.Syntax.Interpretation.Product.product([whole, .value("replacement")]).applying(lens.put)
    expectNoDifference(try record.constructing("Pair", from: update), "Pair(first: source.first, second: replacement)")
    let selection = try record.algebra.selecting(["second", "first"])
    expectNoDifference(try whole.applying(selection.projection).expression, "(source.second, source.first)")
    let empty = try record.algebra.selecting([])
    expectNoDifference(try whole.applying(empty.projection).expression, "()")
    #expect(throws: Type.Failure.self) { try Type.Syntax.Interpretation.Product.product([]).applying(lens.get) }
    #expect(throws: Type.Failure.self) { try record.constructing("Pair", from: .product([])) }
    let renamed = Type.Syntax.Record(record.algebra) { .init("_" + $0.name, type: "Opaque", label: $0.name) }
    expectNoDifference(try renamed.selecting(["second"]).fields.map(\.name), ["_second"])
    expectNoDifference(try renamed.selecting(["second"]).algebra, try selection.record.excluding(["first"]).record)
}
