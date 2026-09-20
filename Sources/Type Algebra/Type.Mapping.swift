extension Type {
    /// A language-independent plan for the action of a type constructor on maps.
    /// The backend assigns variable names and emits closures; variance is decided here.
    public indirect enum Mapping: Equatable, Sendable {
        case identity
        case transform(Variable, Direction)
        case sum([Mapping])
        case product([Mapping])
        case list(Mapping)
        case exponential(domain: Mapping, codomain: Mapping)

        public enum Direction: Equatable, Sendable { case forward, backward }

        public static func derive(_ type: Expression, forward: Set<Variable>, backward: Set<Variable> = [],
            direction: Direction = .forward) throws -> Self {
            switch type {
            case .zero, .unit, .atom: return .identity
            case .variable(let variable):
                guard (direction == .forward ? forward : backward).contains(variable) else {
                    throw Failure("parameter `\(variable.name)` occurs in the wrong variance position; supply a bidirectional mapping or an explicit implementation")
                }
                return .transform(variable, direction)
            case .sum(let types):
                return .sum(try types.map { try derive($0, forward: forward, backward: backward, direction: direction) })
            case .product(let types):
                return .product(try types.map { try derive($0, forward: forward, backward: backward, direction: direction) })
            case .list(let type):
                return .list(try derive(type, forward: forward, backward: backward, direction: direction))
            case .exponential(let domain, let codomain):
                return .exponential(
                    domain: try derive(domain, forward: forward, backward: backward, direction: direction == .forward ? .backward : .forward),
                    codomain: try derive(codomain, forward: forward, backward: backward, direction: direction))
            case .effect, .opaque: throw Failure("mapping this constructor requires an explicit functor action")
            }
        }
    }
}
