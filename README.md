# swift-algebra

Use `Algebra` when you need an algebraic structure over a type (a monoid to fold with, a semilattice to merge with, a ring or field to compute in) as a value you pass around, not a protocol the type conforms to. One type can have several: `Int` under addition and `Int` under multiplication are two `Algebra.Monoid<Int>` values. Use `Algebra.Magma` or `Algebra.Semigroup` when the elements are noncopyable or nonescapable; they are the only structures that accept them.

## Model

Every structure is a `@frozen` struct of an identity and `@escaping` closures over `borrowing` operands. Copies share the closures. None is `Sendable`. Each richer structure is built from smaller ones and projects back down:

- `Magma` (`combining`) → `Semigroup` → `Monoid` (`identity`) → `Group` (`inverting`). `.monoid`, `.semigroup` and `.magma` project down, and `init(_:)` converts.
- `Monoid.Commutative` and `Group.Abelian` wrap a `monoid` or `group` to mark commutativity. `Semilattice` wraps a commutative monoid and adds `join` and `leq`.
- `Lattice`: a `join` and a `meet` semilattice, with `bottom` and `top`. `Boolean` adds `complementing` and derives `exclusive`, `implication`, `equivalence`, a `semiring` (or, and) and a `ring` (xor, and).
- `Semiring`: commutative `additive` monoid + `multiplicative` monoid. `Ring`: abelian `additive` group + monoid, adding `subtracting` and `negating`. Both have `.Commutative` wrappers.
- `Field`: abelian group + commutative monoid + a throwing `reciprocal`. `dividing` and `unit(_:)` throw too. `unit` is the abelian group of `Unit` values (element with its inverse). `.ring` projects to `Ring.Commutative`.
- `Module<Scalar, Vector>` scales an abelian group by a ring. `Vector.Space<Scalar, Element>` scales by a field and projects to `.module`.
- `Magma`, `Semigroup`, `Monoid`, `Group`, `Monoid.Commutative`, `Group.Abelian` and `Semilattice` are callable: `monoid(a, b)` is `monoid.combining(a, b)`.
- Ready-made instances: `Monoid<Bool>.conjunction` and `.disjunction`, the same on `Semilattice<Bool>`, `Lattice<Bool>()` and `Semiring<Bool>.Commutative()`. For `Comparable` elements there are `Semilattice.maximum(bottom:)`, `.minimum(top:)` and `Lattice.ordered(bottom:top:)`. `Monoid.transported(to:from:)` moves a monoid along a pair of conversions.

## Laws

The initializers check nothing: a `Group` whose `inverting` is wrong still constructs. Check laws with `Algebra.Law` over sample elements. Each check returns `nil` when the law holds, or the first `Algebra.Law.Violation` (`law` name, `elements`, `lhs`, `rhs`):

- `Associativity.check` and `Commutativity.check` try every triple or pair, so the cost is cubic or quadratic in the sample count.
- `Identity.left`/`.right`, `Inverse.left`/`.right`, `Distributivity.left`/`.right`, `Annihilation.zero`.
- `Reciprocal.check`: zero must throw. Any other element must have a reciprocal whose product with it is `one`, so throwing for a nonzero element is a violation.
- Module laws (`Action.identity`, `Compatibility.scalar`, `Distributivity.scalar`, `Distributivity.addition`) put the two sides in `elements`, not the inputs.
- `Algebra.Law.Equation.check(_:over:lhs:rhs:)`, in the test-support module, compares any two observations per sample.

## Error Handling

`Algebra.Field.Error` has one case, `.nonInvertible`. Your `reciprocal` throws it, and `dividing` and `unit(_:)` pass it on. The type-algebra and macro layers throw `Type.Failure`, a struct carrying a `description`.

## Example

```swift
let addition = Algebra.Monoid<Int>(identity: 0, combining: +)
let multiplication = Algebra.Monoid<Int>(identity: 1, combining: *)
addition(2, 3)        // 5
multiplication(2, 3)  // 6

Algebra.Law.Associativity.check(of: addition.semigroup, over: [-1, 0, 1, 2])  // nil
let broken = Algebra.Monoid<Int>(identity: 1, combining: +)
Algebra.Law.Identity.left(of: broken, over: [0, 2])?.law                      // "identity-left"
```

## Deriving a product monoid

`@Monoid` (in `Monoid_Macro`, which re-exports `Algebra`) on a struct adds a static `monoid` function returning `Algebra.Monoid<Self>`. It takes one `Algebra.Monoid` per stored property, labelled with the property's name and typed by its annotation, combines field by field, and uses the struct's `public` or `package` access. The macro emits an error for enums, `~Copyable` structs, custom initializers, `lazy` or observed properties, initialized `let`s, and properties without a type annotation. Attributed stored properties count as fields.

## Type expressions

`Type_Algebra` describes types as values: `Type.Expression` (zero, unit, atoms, variables, sums, products, exponentials, lists, effects, opaque constructors). Its tools are typed maps (`Type.Morphism`, applied to `Type.Value`), `Isomorphism`, `Record` selections, `Lens`, `Polynomial` derivatives and cardinalities, variance-checked `Mapping.derive`, operation `Signature`s, and strictly positive `Recursion`. All of these are `Sendable` and `Equatable`. Constructors and `apply` check their types and throw `Type.Failure` rather than build an ill-typed value. `Type_Algebra_Syntax` reads SwiftSyntax types and struct properties into these values, rejects nonregular and mutual recursion, and renders expressions and maps back to Swift source. To render a sum, you supply its nominal Swift type.
