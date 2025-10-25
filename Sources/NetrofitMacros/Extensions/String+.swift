import Foundation

extension String {
    func trimmingQuotes() -> String {
        var result = self
        if result.hasPrefix("\"") {
            result.removeFirst()
        }
        if result.hasSuffix("\"") {
            result.removeLast()
        }
        return result
    }

    func addingQuotes() -> String {
        return "\"\(self)\""
    }
}
