import Foundation

class Router <EndPoint: EndPointType>: NetworkRouter {
    private var task: URLSessionTask?
    
    func request(_ route: EndPoint, complection: @escaping NetworkRouterCompletion) {
        let session = URLSession.shared
        do {
            let request = try self.buildRequest(from: route)
            task = session.dataTask(with: request, completionHandler: { (Data, response, error) in
                complection(Data, response, error)
            })
        } catch {
            complection(nil, nil, error)
        }
        self.task?.resume()
    }
    
   fileprivate func buildRequest(from route: EndPoint) throws -> URLRequest {
        var request = URLRequest(
            url: route.baseURL.appendingPathComponent(route.path),
            cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10.0
        )
        request.httpMethod = route.httpMethod.rawValue
        do {
            switch route.task {
                case .request:
                    request.setValue("application/json", forHTTPHeaderField:"Content-Type")
                
                case .requestParameters(
                    let bodyParameters,
                    let urlParameters
                    ):
                    try self.configureParameters(
                        bodyParameters: bodyParameters,
                        urlParameters:  urlParameters,
                        request:        &request
                    )
                
                case .requestParametersAndHeaders(
                    bodyParameters: let bodyParameters,
                    urlParameters: let urlParameters,
                    additionalHeaders: let additionalHeaders
                    ):
                    self.addAdditionalHeaders(additionalHeaders, request: &request)
                    try self.configureParameters(
                        bodyParameters: bodyParameters,
                        urlParameters:  urlParameters,
                        request:        &request
                    )
            }
            return request
        } catch {
            throw error
        }
    }
    
    fileprivate func configureParameters(
        bodyParameters: Parameters?,
        urlParameters: Parameters?,
        request: inout URLRequest
    ) throws {
        do{
            if let bodyParameters = bodyParameters {
                try JSONParameterEncoder.encode(urlRequest: &request, with: bodyParameters)
            }
            if let urlParameters = urlParameters {
               try URLParameterEncoder.encode(urlRequest: &request, with: urlParameters)
            }
        } catch {
            throw error
        }
    }
    
    fileprivate func addAdditionalHeaders(_ additionalHeaders: HTTPHeaders?, request: inout URLRequest){
        guard let headers = additionalHeaders else { return }
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
    
    func cansel() {
        self.task?.cancel()
    }
}
