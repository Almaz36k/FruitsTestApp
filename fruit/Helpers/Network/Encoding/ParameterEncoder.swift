import Foundation

public enum NetworkError : String, Error {
    case parametersNil = "Parameters were."
    case encodingFailed = "Parameter encoding failed."
    case missingURL = "URL is nil."
}

public typealias Parameters = [String: Int]

protocol ParameterEncoder {
    static func encode(urlRequest: inout URLRequest, with Parameters: Parameters) throws
}
