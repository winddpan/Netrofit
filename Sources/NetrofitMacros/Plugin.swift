import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct NetrofitMacros: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        APIMacro.self,
        MethodMacro.self,
        EmptyMacro.self,
    ]
}
