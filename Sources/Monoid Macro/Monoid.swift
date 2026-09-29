@_exported import Algebra
@attached(member, names: named(monoid))
public macro Monoid() = #externalMacro(module: "Monoid_Macro_Plugin", type: "Derive")
