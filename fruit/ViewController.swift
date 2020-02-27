import UIKit

class ViewController: UIViewController {
    let fruitManager = FruitManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fruitManager.getAllFruits() { fruits in
            print(fruits[0])
        }
    }


}

