import Foundation


enum Result<String> {
   case success
   case failure(String)
}

class NetworkManager {
    static let shared = NetworkManager()
    private let router = Router<FruitApi>()
    private init(){}
    
    enum NetworkResponse: String{
        case sucsess
        case authenticationError = "You need to be authenticated first."
        case badRequest = "Bad request"
        case outdated = "The url you requested is outdated"
        case failed = "Network request failed."
        case noData = "Response returned with no data ro decode."
        case unableToDecode = "We could not decode the response."
    }
    
    fileprivate func handleNetworkResponse(_ response:HTTPURLResponse) -> Result<String>{
        switch response.statusCode {
            case 200...299: return .success
            case 401...500: return .failure(NetworkResponse.authenticationError.rawValue)
            case 501...599: return .failure(NetworkResponse.badRequest.rawValue)
            case 600      : return .failure(NetworkResponse.outdated.rawValue)
            default       : return .failure(NetworkResponse.failed.rawValue)
        }
    }

    func getAllFruits(completion: @escaping (_ fruit: [Fruit]?, _ error: String?) -> ()) {
        router.request(.allFruits){ data, response, error in
            if error != nil {
                completion(nil, "Plase check eour network connection")
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                    case .success:
                        guard let responseData = data else {
                            completion(nil, NetworkResponse.unableToDecode.rawValue)
                            return
                        }
                        do {
                            let apiResponse = try JSONDecoder().decode([Fruit].self, from: responseData)
                            completion(apiResponse, nil)
                        } catch {
                            completion(nil, NetworkResponse.unableToDecode.rawValue)
                        }
                    case .failure(let networkFailureError):
                        completion(nil, networkFailureError)
                }
            }
        }
    }
    
    func getMyFruits(completion: @escaping (_ fruit: [MyFruit]?, _ error: String?) -> ()) {
        router.request(.myFruits){ data, response, error in
             if error != nil {
                 completion(nil, "Plase check eour network connection")
             }
             if let response = response as? HTTPURLResponse {
                 let result = self.handleNetworkResponse(response)
                 switch result {
                     case .success:
                         guard let responseData = data else {
                             completion(nil, NetworkResponse.unableToDecode.rawValue)
                             return
                         }
                         do {
                             let apiResponse = try JSONDecoder().decode([MyFruit].self, from: responseData)
                             completion(apiResponse, nil)
                         } catch {
                             completion(nil, NetworkResponse.unableToDecode.rawValue)
                         }
                     case .failure(let networkFailureError):
                         completion(nil, networkFailureError)
                 }
             }
         }
     }
    
    func addFruit(fruitId: Int, completion: @escaping (Bool)->()) {
        router.request(.addFruit(fruitId: fruitId)){ data, response, error in
            if error != nil {
                print("Plase check eour network connection")
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                    case .success:
                        completion(true)
                        return
                    case .failure(let networkFailureError):
                        completion(false)
                        print(networkFailureError)
                }
            }
        }
    }
    
    func removeFruit(fruitId: Int,completion: @escaping (Bool) -> ()) {
        router.request(.removeFruit(fruitId: fruitId)){ data, response, error in
            if error != nil {
                print("Plase check eour network connection")
                completion(false)
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                    case .success:
                        completion(true)
                        return
                    case .failure(_):
                        completion(false)
                }
            }
        }
    }
}
