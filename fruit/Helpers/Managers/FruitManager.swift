import Foundation

class FruitManager {
    var networkManager = NetworkManager.shared
    
    func getAllFruits(completion: @escaping (_ fruits: [Fruit])->()) {
        networkManager.getAllFruit(){response, error in
            if let error = error {
                print(error)
            }
            guard let fruits = response else { return }
            completion(fruits)
        }
    }
    
}
