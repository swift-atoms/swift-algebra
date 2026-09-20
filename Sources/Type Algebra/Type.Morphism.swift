extension Type {
    /// Checked terms in the free bicartesian closed language. Equality of terms is syntactic;
    /// no claim of decidable extensional equality, or automatic proof of supplied laws, is made.
    public struct Morphism: Equatable, Sendable {
        public let domain: Expression
        public let codomain: Expression
        public let term: Term

        public indirect enum Term: Equatable, Sendable {
            case identity
            case composition(Morphism, Morphism)
            case projection(Int)
            case pairing([Morphism])
            case injection(Int)
            case elimination([Morphism])
            case terminal
            case initial
            case evaluation
            case curry(Morphism)
            case uncurry(Morphism)
            case distribution
            case factorization
            case generator(Atom)
        }

        private init(_ domain: Expression, _ codomain: Expression, _ term: Term) {
            self.domain = domain; self.codomain = codomain; self.term = term
        }

        public static func identity(_ type: Expression) -> Self { Self(type, type, .identity) }
        /// A formal generator. A model must supply its meaning; declaring it proves no laws.
        public static func generator(_ name: Atom, domain: Expression, codomain: Expression) -> Self {
            Self(domain, codomain, .generator(name))
        }
        public static func distribution(_ factor: Expression, over alternatives: [Expression]) -> Self {
            Self(.product([factor, .sum(alternatives)]), .sum(alternatives.map { .product([factor, $0]) }), .distribution)
        }
        public static func factorization(_ factor: Expression, from alternatives: [Expression]) -> Self {
            Self(.sum(alternatives.map { .product([factor, $0]) }), .product([factor, .sum(alternatives)]), .factorization)
        }
        public func followed(by next: Self) throws -> Self {
            guard codomain == next.domain else { throw Failure("composition requires matching intermediate types") }
            return Self(domain, next.codomain, .composition(self, next))
        }
        public static func projection(_ factors: [Expression], at index: Int) throws -> Self {
            guard factors.indices.contains(index) else { throw Failure("projection index is outside the product") }
            return Self(.product(factors), factors[index], .projection(index))
        }
        public static func pairing(from domain: Expression, _ maps: [Self]) throws -> Self {
            guard maps.allSatisfy({ $0.domain == domain }) else { throw Failure("pairing requires a common domain") }
            return Self(domain, .product(maps.map(\.codomain)), .pairing(maps))
        }
        public static func injection(_ alternatives: [Expression], at index: Int) throws -> Self {
            guard alternatives.indices.contains(index) else { throw Failure("injection index is outside the coproduct") }
            return Self(alternatives[index], .sum(alternatives), .injection(index))
        }
        public static func elimination(to codomain: Expression, _ maps: [Self]) throws -> Self {
            guard maps.allSatisfy({ $0.codomain == codomain }) else { throw Failure("elimination requires a common codomain") }
            return Self(.sum(maps.map(\.domain)), codomain, .elimination(maps))
        }
        public static func terminal(from domain: Expression) -> Self { Self(domain, .unit, .terminal) }
        public static func initial(to codomain: Expression) -> Self { Self(.zero, codomain, .initial) }
        public static func evaluation(domain: Expression, codomain: Expression) -> Self {
            Self(.product([.exponential(domain: domain, codomain: codomain), domain]), codomain, .evaluation)
        }
        public func curried() throws -> Self {
            guard case .product(let factors) = domain, factors.count == 2 else { throw Failure("currying requires a binary product domain") }
            return Self(factors[0], .exponential(domain: factors[1], codomain: codomain), .curry(self))
        }
        public func uncurried() throws -> Self {
            guard case .exponential(let input, let output) = codomain else { throw Failure("uncurrying requires an exponential codomain") }
            return Self(.product([domain, input]), output, .uncurry(self))
        }
    }

    /// An interpretation for first-order structural maps. Function values need a supplied model.
    public indirect enum Value: Equatable, Sendable {
        case unit
        case atom(Atom, Int)
        case variable(Variable, Int)
        case product([Value])
        case sum(Int, Value)
        case list([Value])

        public func inhabits(_ expression: Expression) -> Bool {
            switch (self, expression) {
            case (.unit, .unit): return true
            case let (.atom(a, _), .atom(b)): return a == b
            case let (.variable(a, _), .variable(b)): return a == b
            case let (.product(values), .product(types)):
                return values.count == types.count && zip(values, types).allSatisfy { $0.inhabits($1) }
            case let (.sum(index, value), .sum(types)):
                return types.indices.contains(index) && value.inhabits(types[index])
            case let (.list(values), .list(type)): return values.allSatisfy { $0.inhabits(type) }
            default: return false
            }
        }
    }
}

extension Type.Morphism {
    public func apply(_ value: Type.Value) throws -> Type.Value {
        guard value.inhabits(domain) else { throw Type.Failure("value does not inhabit the map's domain") }
        switch term {
        case .identity: return value
        case .composition(let first, let second): return try second.apply(first.apply(value))
        case .projection(let index):
            guard case .product(let values) = value else { throw Type.Failure("expected product") }
            return values[index]
        case .pairing(let maps): return .product(try maps.map { try $0.apply(value) })
        case .injection(let index): return .sum(index, value)
        case .elimination(let maps):
            guard case .sum(let index, let payload) = value else { throw Type.Failure("expected sum") }
            return try maps[index].apply(payload)
        case .terminal: return .unit
        case .initial: throw Type.Failure("the empty type has no values")
        case .distribution:
            guard case .product(let values) = value, case .sum(let index, let payload) = values[1] else { throw Type.Failure("expected distributive product") }
            return .sum(index, .product([values[0], payload]))
        case .factorization:
            guard case .sum(let index, let payload) = value, case .product(let values) = payload else { throw Type.Failure("expected distributive sum") }
            return .product([values[0], .sum(index, values[1])])
        case .generator: throw Type.Failure("a generator requires a supplied interpretation")
        case .evaluation, .curry, .uncurry: throw Type.Failure("function interpretation requires a model of exponentials")
        }
    }
}
