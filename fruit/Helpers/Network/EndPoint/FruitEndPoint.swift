import Foundation

public enum FruitApi {
    case allFruits
    case myFruits
    case addFruit(fruitId: Int)
    case removeFruit(fruitId: Int)
}

extension FruitApi: EndPointType {
    
    var baseURL: URL {
       return URL(string: "http://vsibi.best/api/test/")!
    }
    
    var path: String {
        switch self {
            case .allFruits:   return "all"
            case .myFruits:    return "my_fruits"
            case .addFruit:    return "add"
            case .removeFruit: return "remove"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
            case .allFruits, .myFruits: return .get
            case .addFruit, .removeFruit: return .post
        }
    }
    
    var headers: HTTPHeaders? {
        switch self {
            case .allFruits: return nil
            case .addFruit, .removeFruit, .myFruits: return ["uid": "26"]
        }
    }
    
    var task: HTTPTask {
        switch self {
            case .allFruits:
                return.request
            
            case.myFruits:
                return.requestParametersAndHeaders(bodyParameters: nil, urlParameters: nil, additionalHeaders: self.headers)
            
            case .addFruit(fruitId: let fruitId):
                let bodyParameters = ["fruit_id": fruitId]
                return .requestParametersAndHeaders(bodyParameters: bodyParameters, urlParameters: nil, additionalHeaders: self.headers)
        
            case.removeFruit(fruitId: let fruitId):
                let bodyParameters = ["fruit_id": fruitId]
                return .requestParametersAndHeaders(bodyParameters: bodyParameters, urlParameters: nil, additionalHeaders: self.headers)
        }
    }
    
    
}
