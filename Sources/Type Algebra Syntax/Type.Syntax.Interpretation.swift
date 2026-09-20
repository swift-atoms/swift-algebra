public import Type_Algebra
public import SwiftSyntax
import SwiftSyntaxBuilder

extension Type.Syntax {
    /// One Swift representation of the core language. Atoms and nominal sums are explicit bindings;
    /// this interpreter never invents a declaration for an imported sort or an effect constructor.
    public struct Interpretation {
        public let atoms: [Type.Atom: TypeSyntax]
        public let variables: [Type.Variable: TypeSyntax]
        public let representations: [Type.Expression: TypeSyntax]
        public let generators: [Type.Atom: ExprSyntax]

        public init(atoms: [Type.Atom: TypeSyntax] = [:], variables: [Type.Variable: TypeSyntax] = [:],
            representations: [Type.Expression: TypeSyntax] = [:], generators: [Type.Atom: ExprSyntax] = [:]) {
            self.atoms = atoms; self.variables = variables; self.representations = representations; self.generators = generators
        }

        public func type(_ expression: Type.Expression) throws -> TypeSyntax {
            if let supplied = representations[expression] {
                switch expression {
                case .sum, .effect, .opaque: return supplied
                default: throw Type.Failure("structural representations are fixed by this interpreter; bind atoms or nominal sums instead")
                }
            }
            let result: String
            switch expression {
            case .zero: result = "Swift.Never"
            case .unit: result = "Swift.Void"
            case .atom(let atom):
                guard let value = atoms[atom] else { throw Type.Failure("no Swift representation for atom `\(atom.name)`") }
                return value
            case .variable(let variable):
                guard let value = variables[variable] else { throw Type.Failure("no Swift representation for variable `\(variable.name)`") }
                return value
            case .product(let factors):
                let elements = try factors.map { try type($0).trimmedDescription }
                result = elements.count == 1 ? elements[0] : "(" + elements.joined(separator: ", ") + ")"
            case .exponential(let domain, let codomain):
                result = "(\(try type(domain))) -> \(try type(codomain))"
            case .list(let element): result = "[\(try type(element))]"
            case .sum: throw Type.Failure("a Swift coproduct requires an explicit nominal representation")
            case .effect, .opaque: throw Type.Failure("this constructor requires an explicit Swift representation")
            }
            return TypeSyntax(stringLiteral: result)
        }

        public func record(_ record: Type.Record, named name: TokenSyntax, access: String = "",
            escaping: Set<String> = []) throws -> DeclSyntax {
            guard escaping.isSubset(of: Set(record.fields.map(\.name))) else { throw Type.Failure("escaping policy names an unknown field") }
            let representation = try Record(record.fields.map { field in
                let syntax = try type(field.type)
                let function = syntax.is(FunctionTypeSyntax.self)
                    || syntax.as(AttributedTypeSyntax.self)?.baseType.is(FunctionTypeSyntax.self) == true
                return .init(field.name, type: syntax.trimmedDescription,
                    argument: (function || escaping.contains(field.name) ? "@escaping " : "") + syntax.trimmedDescription)
            })
            return DeclSyntax(stringLiteral: """
                \(access)struct \(name.trimmedDescription) {
                \(representation.declarations(access: access).joined(separator: "\n"))
                \(try representation.initializer(access: access))
                }
                """)
        }

        /// This representation uses one payload per branch, including Void. The same branch convention
        /// is used by the morphism interpreter below, so nullary and unary products stay unambiguous.
        public func coproduct(_ alternatives: [Type.Expression], named name: TokenSyntax, access: String = "") throws -> DeclSyntax {
            let cases = try alternatives.enumerated().map { "case branch\($0.offset)(\(try type($0.element)))" }
            return DeclSyntax(stringLiteral: "\(access)enum \(name.trimmedDescription) {\n\(cases.joined(separator: "\n"))\n}")
        }

        /// The caller supplies hygienic names (a macro can use context.makeUniqueName).
        /// Function and generator behavior is assumed pure, as required by the core laws.
        public func expression(_ map: Type.Morphism, appliedTo value: ExprSyntax,
            fresh: (String) -> TokenSyntax) throws -> ExprSyntax {
            let argument = fresh("value").text
            let body = try body(map, value: argument, fresh: fresh)
            return ExprSyntax(stringLiteral: "({ (\(argument): \(try type(map.domain))) -> \(try type(map.codomain)) in \(body) })(\(value))")
        }

        private func call(_ map: Type.Morphism, _ value: String, fresh: (String) -> TokenSyntax) throws -> String {
            try expression(map, appliedTo: ExprSyntax(stringLiteral: value), fresh: fresh).trimmedDescription
        }

        private func body(_ map: Type.Morphism, value: String, fresh: (String) -> TokenSyntax) throws -> String {
            func tuple(_ values: [String]) -> String { values.count == 1 ? values[0] : "(" + values.joined(separator: ", ") + ")" }
            switch map.term {
            case .identity: return "return \(value)"
            case .composition(let first, let second): return "return \(try call(second, call(first, value, fresh: fresh), fresh: fresh))"
            case .projection(let index):
                guard case .product(let factors) = map.domain else { throw Type.Failure("invalid product representation") }
                return "return \(factors.count == 1 ? value : "\(value).\(index)")"
            case .pairing(let maps): return "return \(tuple(try maps.map { try call($0, value, fresh: fresh) }))"
            case .injection(let index): return "return .branch\(index)(\(value))"
            case .elimination(let maps):
                let branches = try maps.enumerated().map { index, branch in
                    let payload = fresh("payload").text
                    return "case .branch\(index)(let \(payload)): return \(try call(branch, payload, fresh: fresh))"
                }
                return "switch \(value) { \(branches.joined(separator: "\n")) }"
            case .terminal: return "return ()"
            case .initial: return "switch \(value) {}"
            case .evaluation: return "return \(value).0(\(value).1)"
            case .curry(let uncurried):
                let argument = fresh("argument").text
                return "return { \(argument) in \(try call(uncurried, "(\(value), \(argument))", fresh: fresh)) }"
            case .uncurry(let curried): return "return (\(try call(curried, "\(value).0", fresh: fresh)))(\(value).1)"
            case .generator(let atom):
                guard let function = generators[atom] else { throw Type.Failure("no Swift interpretation for generator `\(atom.name)`") }
                return "return (\(function))(\(value))"
            case .distribution:
                guard case .sum(let alternatives) = map.codomain else { throw Type.Failure("invalid distribution") }
                let branches = alternatives.indices.map { index in
                    let payload = fresh("payload").text
                    return "case .branch\(index)(let \(payload)): return .branch\(index)((\(value).0, \(payload)))"
                }
                return "switch \(value).1 { \(branches.joined(separator: "\n")) }"
            case .factorization:
                guard case .sum(let alternatives) = map.domain else { throw Type.Failure("invalid factorization") }
                let branches = alternatives.indices.map { index in
                    let payload = fresh("payload").text
                    return "case .branch\(index)(let \(payload)): return (\(payload).0, .branch\(index)(\(payload).1))"
                }
                return "switch \(value) { \(branches.joined(separator: "\n")) }"
            }
        }
    }
}
