import Foundation

struct Fruit: Decodable {
    let id: Int
    let text: String
    let image: String
}

struct MyFruit: Decodable{
    let id: Int
    let text: String
    let image: Int
    let pivot : Pivot
}

struct Pivot: Decodable {
    let userId: Int
    let fruitId: Int
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case fruitId = "fruit_id"
    }
}



