import SwiftSyntax

struct FuncArg {
    let attributes: AttributeListSyntax
    let externalName: String
    let internalName: String
    let identifierType: String
}

extension FunctionDeclSyntax {
    var parameterList: [FuncArg] {
        signature.parameterClause.parameters.map { parameter in
            FuncArg(
                attributes: parameter.attributes,
                externalName: parameter.firstName.trimmed.text,
                internalName: parameter.secondName?.trimmed.text ?? parameter.firstName.trimmed.text,
                identifierType: parameter.type.trimmedDescription
            )
        }
    }
}
