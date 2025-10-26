import Foundation

public enum JSONDecoderError: Error {
    case errorKeyPath(String)
    case errorKeyPathValue(Any)
}

extension JSONDecoder: HTTPBodyDecoder {
    public func decodeBody<D>(_ type: D.Type, from data: Data, contentType: String?, deocdeKeyPath: String?) throws -> D where D: Decodable {
        var decodeData = data
        if let deocdeKeyPath, !deocdeKeyPath.isEmpty {
            let pathParts = deocdeKeyPath.components(separatedBy: ".").filter { !$0.isEmpty }
            var value = try JSONSerialization.jsonObject(with: data)
            for part in pathParts {
                if let dict = value as? [String: Any], let _value = dict[part] {
                    value = _value
                } else {
                    throw JSONDecoderError.errorKeyPath(deocdeKeyPath)
                }
            }
            if let value = value as? D {
                return value
            } else if value is [String: Any] || value is [Any] {
                decodeData = try JSONSerialization.data(withJSONObject: value)
            } else if let value = value as? Encodable {
                decodeData = try JSONEncoder().encode(value)
            } else {
                throw JSONDecoderError.errorKeyPathValue(value)
            }
        }
        do {
            return try decode(type, from: decodeData)
        } catch {
            if D.self == String.self, let string = String(data: data, encoding: .utf8) {
                return string as! D
            }
            throw error
        }
    }
}
