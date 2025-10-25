extension String {
    public init<E: CustomStringConvertible>(netrofitURLPathPart: E?, encoded: Bool) {
        if let netrofitURLPathPart {
            let string = "\(netrofitURLPathPart)"
            if encoded {
                self = .init(stringLiteral: string)
            } else {
                self = .init(stringLiteral: string)
            }
            self = .init(stringLiteral: string.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")
        } else {
            self = .init(stringLiteral: "")
        }
    }
}
