import Foundation

class FruitManager {
    var networkManager = NetworkManager.shared
    
    func getAllFruits(completion: @escaping (_ fruits: [Fruit])->()) {
        networkManager.getAllFruits(){response, error in
            if let error = error {
                print(error)
            }
            guard let fruits = response else { return }
            completion(fruits)
        }
    }
    
    func getMyFruits(completion: @escaping (_ fruits: [MyFruit])->()) {
        networkManager.getMyFruits(){response, error in
              if let error = error {
                  print(error)
              }
              guard let myFruits = response else { return }
              completion(myFruits)
          }
      }
    
    func addFruit(fruitId: Int, completion: @escaping (Bool)->()) {
        networkManager.addFruit(fruitId: fruitId, completion: completion)
    }
    
    func removeFruit(fruitId: Int, completion: @escaping (Bool) -> ()) {
        networkManager.removeFruit(fruitId: fruitId, completion: completion)
    }
}
