import Foundation

public struct URLParameterEncoder: ParameterEncoder {
    static func encode(urlRequest: inout URLRequest, with Parameters: Parameters) throws {
        guard let url = urlRequest.url else { throw NetworkError.missingURL }
        
        if var urlComponents = URLComponents(url: url,resolvingAgainstBaseURL: false), !Parameters.isEmpty{
            urlComponents.queryItems = [URLQueryItem]()
            
            for (key, value) in Parameters {
                let queryItem = URLQueryItem(
                    name: key,
                    value: "\(value)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed))
                
                urlComponents.queryItems?.append(queryItem)
            }
          urlRequest.url = urlComponents.url
        }
        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest.setValue("application/x-www-form-urlencoded; charser=utf-8", forHTTPHeaderField: "Content-Type")
        }
    }
}
