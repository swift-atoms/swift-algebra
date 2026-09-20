public import Type_Algebra
public import SwiftSyntax

/// A source-level algebra, not a substitute for Swift's type checker.
/// Unknown constructors retain their parameter occurrences and cannot silently become constants.
extension Type.Syntax {
    public indirect enum Expression {
        case constant(TypeSyntax)
        case parameter(String)
        case array(Type.Syntax.Expression)
        case optional(Type.Syntax.Expression)
        case tuple([Coordinate])
        case arrow([Type.Syntax.Expression], Type.Syntax.Expression)
        case unsupported(TypeSyntax, Set<String>)

        public struct Coordinate {
            public let label: String?
            public let type: Type.Syntax.Expression
            public init(label: String?, type: Type.Syntax.Expression) { self.label = label; self.type = type }
        }

        public typealias Polarity = Type.Polarity

        public init(_ syntax: TypeSyntax, parameters: Set<String>) {
            let references = Self.references(in: syntax, parameters: parameters)
            guard !references.isEmpty else { self = .constant(syntax); return }
            if let identifier = syntax.as(IdentifierTypeSyntax.self), identifier.genericArgumentClause == nil, identifier.moduleSelector == nil,
                parameters.contains(identifier.name.text) {
                self = .parameter(identifier.name.text); return
            }
            if let array = syntax.as(ArrayTypeSyntax.self) {
                self = .array(Self(array.element, parameters: parameters)); return
            }
            if let optional = syntax.as(OptionalTypeSyntax.self) {
                self = .optional(Self(optional.wrappedType, parameters: parameters)); return
            }
            if let tuple = syntax.as(TupleTypeSyntax.self) {
                if tuple.elements.count == 1, let element = tuple.elements.first, element.firstName == nil {
                    self = Self(element.type, parameters: parameters); return
                }
                self = .tuple(tuple.elements.map {
                    .init(label: $0.firstName?.text, type: Self($0.type, parameters: parameters))
                }); return
            }
            if let arrow = syntax.as(FunctionTypeSyntax.self), arrow.effectSpecifiers == nil,
                arrow.parameters.allSatisfy({ $0.ellipsis == nil && !$0.type.is(AttributedTypeSyntax.self) }) {
                self = .arrow(arrow.parameters.map { Self($0.type, parameters: parameters) },
                    Self(arrow.returnClause.type, parameters: parameters)); return
            }
            let name: String?
            let arguments: GenericArgumentListSyntax?
            if let identifier = syntax.as(IdentifierTypeSyntax.self) {
                name = identifier.name.text; arguments = identifier.genericArgumentClause?.arguments
            } else if let member = syntax.as(MemberTypeSyntax.self), member.baseType.trimmedDescription == "Swift" {
                name = member.name.text; arguments = member.genericArgumentClause?.arguments
            } else { name = nil; arguments = nil }
            if let arguments, arguments.count == 1, let argument = arguments.first?.argument.as(TypeSyntax.self) {
                if name == "Array" { self = .array(Self(argument, parameters: parameters)); return }
                if name == "Optional" { self = .optional(Self(argument, parameters: parameters)); return }
            }
            self = .unsupported(syntax, references)
        }

        public var algebra: Type.Expression {
            switch self {
            case .constant(let syntax): return .atom(.init(syntax.trimmedDescription, scope: ["Swift"]))
            case .parameter(let name): return .variable(.init(name))
            case .array(let element): return .list(element.algebra)
            case .optional(let element): return .optional(element.algebra)
            case .tuple(let coordinates): return .product(coordinates.map { $0.type.algebra })
            case .arrow(let inputs, let output): return .exponential(domain: .product(inputs.map(\.algebra)), codomain: output.algebra)
            case .unsupported(let syntax, let names): return .opaque(.init(syntax.trimmedDescription, scope: ["Swift"]), Set(names.map(Type.Variable.init)))
            }
        }

        public func polarity(of parameter: String) -> Polarity { algebra.polarity(of: .init(parameter)) }
        public var isTraversable: Bool { algebra.isTraversable }
        public var isPolynomial: Bool { (try? Type.Polynomial(algebra)) != nil }

        public var diagnostic: String? {
            switch self {
            case .unsupported(let syntax, _):
                return "unsupported type constructor, effect, or ownership in `\(syntax.trimmedDescription)`; supply an explicit implementation"
            case .array(let element), .optional(let element): return element.diagnostic
            case .tuple(let fields): return fields.compactMap { $0.type.diagnostic }.first
            case .arrow(let inputs, let output): return (inputs + [output]).compactMap(\.diagnostic).first
            default: return nil
            }
        }
    }

}

extension Type.Syntax.Expression {
    public var containsArrow: Bool { algebra.containsExponential }
}

extension Type.Syntax.Expression {
    public func spelling(replacing parameters: [String: String]) -> String {
        switch self {
        case .constant(let type), .unsupported(let type, _): type.trimmedDescription
        case .parameter(let name): parameters[name] ?? name
        case .array(let element): "[\(element.spelling(replacing: parameters))]"
        case .optional(let element): "(\(element.spelling(replacing: parameters)))?"
        case .tuple(let coordinates): "(" + coordinates.map { coordinate in
            (coordinate.label.map { $0 == "_" ? "" : "\($0): " } ?? "") + coordinate.type.spelling(replacing: parameters)
        }.joined(separator: ", ") + ")"
        case .arrow(let inputs, let output): "(" + inputs.map { $0.spelling(replacing: parameters) }.joined(separator: ", ") + ") -> " + output.spelling(replacing: parameters)
        }
    }
}

extension Type.Syntax.Expression {
    /// Identifier positions, excluding tuple labels and qualified member names.
    public static func references(in syntax: TypeSyntax, parameters: Set<String>) -> Set<String> {
        final class References: SyntaxVisitor {
            let parameters: Set<String>
            var names: Set<String> = []
            init(_ parameters: Set<String>) { self.parameters = parameters; super.init(viewMode: .sourceAccurate) }
            override func visit(_ node: IdentifierTypeSyntax) -> SyntaxVisitorContinueKind {
                if node.moduleSelector == nil && parameters.contains(node.name.text) { names.insert(node.name.text) }
                return .visitChildren
            }
        }
        let visitor = References(parameters)
        visitor.walk(syntax)
        return visitor.names
    }
}
