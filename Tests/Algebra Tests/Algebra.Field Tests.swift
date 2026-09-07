import Testing

@testable import Algebra

private enum Field {}

extension Field {
    @Suite
    struct `Fields preserve arithmetic laws and reject invalid reciprocals` {
    }
}

extension Field.`Fields preserve arithmetic laws and reject invalid reciprocals` {
    static var boolField: Algebra.Field<Bool> {
        .init(
            additive: .init(
                group: .init(
                    identity: false,
                    combining: { $0 != $1 },
                    inverting: { $0 }
                )
            ),
            multiplicative: .init(
                monoid: .init(
                    identity: true,
                    combining: { $0 && $1 }
                )
            ),
            reciprocal: { element throws(Algebra.Field<Bool>.Error) in
                guard element == true else { throw .nonInvertible }
                return element
            }
        )
    }

    @Test
    func `init stores additive and multiplicative structures`() {
        let field = Self.boolField
        #expect(field.additive.identity == false)
        #expect(field.multiplicative.identity == true)
    }

    @Test
    func `zero returns additive identity`() {
        let field = Self.boolField
        #expect(field.zero == false)
    }

    @Test
    func `one returns multiplicative identity`() {
        let field = Self.boolField
        #expect(field.one == true)
    }

    @Test
    func `adding delegates to additive group`() {
        let field = Self.boolField
        #expect(field.adding(true, true) == false)
        #expect(field.adding(true, false) == true)
    }

    @Test
    func `negating delegates to additive inverse`() {
        let field = Self.boolField
        #expect(field.negating(true) == true)
        #expect(field.negating(false) == false)
    }

    @Test
    func `multiplying delegates to multiplicative monoid`() {
        let field = Self.boolField
        #expect(field.multiplying(true, true) == true)
        #expect(field.multiplying(true, false) == false)
    }

    @Test
    func `reciprocal succeeds for invertible element`() throws {
        let field = Self.boolField
        #expect(try field.reciprocal(true) == true)
    }

    @Test
    func `reciprocal throws for non-invertible element`() {
        let field = Self.boolField
        #expect(throws: Algebra.Field<Bool>.Error.nonInvertible) {
            try field.reciprocal(false)
        }
    }

    @Test
    func `dividing succeeds for invertible divisor`() throws {
        let field = Self.boolField
        #expect(try field.dividing(true, true) == true)
    }

    @Test
    func `dividing throws for non-invertible divisor`() {
        let field = Self.boolField
        #expect(throws: Algebra.Field<Bool>.Error.nonInvertible) {
            try field.dividing(true, false)
        }
    }

    @Test
    func `subtracting computes additive difference`() {
        let field = Self.boolField
        #expect(field.subtracting(true, true) == false)
        #expect(field.subtracting(true, false) == true)
    }

    @Test
    func `unit method succeeds for invertible element`() throws {
        let field = Self.boolField
        let u = try field.unit(true)
        #expect(u.element == true)
        #expect(u.inverse == true)
    }

    @Test
    func `unit method throws for non-invertible element`() {
        let field = Self.boolField
        #expect(throws: Algebra.Field<Bool>.Error.nonInvertible) {
            try field.unit(false)
        }
    }

    @Test
    func `unit group identity is one`() {
        let field = Self.boolField
        let group = field.unit
        #expect(group.identity.element == true)
        #expect(group.identity.inverse == true)
    }

    @Test
    func `unit group inverting swaps element and inverse`() throws {
        let field = Self.boolField
        let group = field.unit
        let u = try field.unit(true)
        let inv = group.inverting(u)
        #expect(inv.element == true)
        #expect(inv.inverse == true)
    }

    @Test
    func `ring projection returns commutative ring`() {
        let field = Self.boolField
        let ring = field.ring
        #expect(ring.zero == false)
        #expect(ring.one == true)
    }
}

extension Field.`Fields preserve arithmetic laws and reject invalid reciprocals` {
    @Test
    func `field distributivity holds`() {
        let field = Field.`Fields preserve arithmetic laws and reject invalid reciprocals`.boolField
        let a = true
        let b = true
        let c = false

        let lhs = field.multiplying(a, field.adding(b, c))
        let rhs = field.adding(field.multiplying(a, b), field.multiplying(a, c))
        #expect(lhs == rhs)
    }

    @Test
    func `additive inverse produces zero`() {
        let field = Field.`Fields preserve arithmetic laws and reject invalid reciprocals`.boolField
        #expect(field.adding(true, field.negating(true)) == field.zero)
    }
}
