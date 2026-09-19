public import SwiftSyntax

/// A source-level algebra, not a substitute for Swift's type checker.
/// Unknown constructors retain their parameter occurrences and cannot silently become constants.
public indirect enum TypeExpression {
    case constant(TypeSyntax)
    case parameter(String)
    case array(TypeExpression)
    case optional(TypeExpression)
    case tuple([Coordinate])
    case arrow([TypeExpression], TypeExpression)
    case unsupported(TypeSyntax, Set<String>)

    public struct Coordinate {
        public let label: String?
        public let type: TypeExpression
        public init(label: String?, type: TypeExpression) { self.label = label; self.type = type }
    }

    public struct Polarity: OptionSet, Sendable {
        public let rawValue: Int
        public init(rawValue: Int) { self.rawValue = rawValue }
        public static let positive = Self(rawValue: 1)
        public static let negative = Self(rawValue: 2)
        public static let unknown = Self(rawValue: 4)
        public var reversed: Self {
            var result: Self = []
            if contains(.positive) { result.insert(.negative) }
            if contains(.negative) { result.insert(.positive) }
            if contains(.unknown) { result.insert(.unknown) }
            return result
        }
    }

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

    public func polarity(of parameter: String) -> Polarity {
        switch self {
        case .constant: return []
        case .parameter(let name): return name == parameter ? .positive : []
        case .array(let element), .optional(let element): return element.polarity(of: parameter)
        case .tuple(let fields): return fields.reduce([]) { $0.union($1.type.polarity(of: parameter)) }
        case .arrow(let inputs, let output):
            return inputs.reduce(output.polarity(of: parameter)) { $0.union($1.polarity(of: parameter).reversed) }
        case .unsupported(_, let names): return names.contains(parameter) ? .unknown : []
        }
    }

    public var isPolynomial: Bool {
        switch self {
        case .constant, .parameter: true
        case .array(let element), .optional(let element): element.isPolynomial
        case .tuple(let fields): fields.allSatisfy { $0.type.isPolynomial }
        case .arrow, .unsupported: false
        }
    }

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

public struct AlgebraDiagnostic: Error, CustomStringConvertible {
    public let description: String
    public init(_ description: String) { self.description = description }
}

/// Common, explicit eligibility for reconstructing an unconstrained generic value.
public struct GenericProduct {
    public let declaration: StructDeclSyntax
    public let properties: StoredProperties
    public let parameters: [String]
    public let fields: [TypeExpression]
    public let access: String

    public init(_ declaration: StructDeclSyntax, arity: Int, reconstructing: Bool = true) throws {
        self.declaration = declaration
        properties = StoredProperties(declaration, requiresMemberwise: reconstructing)
        if !properties.diagnostics.isEmpty { throw AlgebraDiagnostic(properties.diagnostics.joined(separator: "; ")) }
        guard let clause = declaration.genericParameterClause, clause.parameters.count == arity,
            clause.parameters.allSatisfy({ $0.inheritedType == nil }), declaration.genericWhereClause == nil else {
            throw AlgebraDiagnostic("requires \(arity) unconstrained type parameter(s)")
        }
        let names = clause.parameters.map(\.name.text)
        parameters = names
        fields = properties.fields.map { TypeExpression($0.type, parameters: Set(names)) }
        if let reason = fields.compactMap(\.diagnostic).first { throw AlgebraDiagnostic(reason) }
        access = RecursiveShape.access(of: declaration)
    }
}

extension TypeExpression {
    public var containsArrow: Bool {
        switch self {
        case .arrow: true
        case .array(let element), .optional(let element): element.containsArrow
        case .tuple(let coordinates): coordinates.contains { $0.type.containsArrow }
        default: false
        }
    }
}

extension TypeExpression {
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

extension TypeExpression {
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
