import Foundation

struct Fruit: Decodable {
    let id: Int
    let text: String
    let image: String
}

struct MyFruit: Decodable{
    let id: Int
    let text: String
    let image: String
    let pivot : Pivot
}

struct Pivot: Decodable {
    let userId: String
    let fruitId: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case fruitId = "fruit_id"
    }
}



