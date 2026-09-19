@_exported import Algebra
/// A product monoid from explicit component witnesses; no numeric or domain operation is guessed.
@attached(member, names: named(monoid))
public macro Monoid() = #externalMacro(module: "Monoid_Macro_Plugin", type: "Derive")
