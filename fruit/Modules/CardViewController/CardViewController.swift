import UIKit

class CardViewController: UIViewController {    
    // MARK: collectionViewAllFruit variables
    @IBOutlet weak var collectionViewAllFruit: UICollectionView!
    let collectionViewCellId = "CellAllFruit"
    var allFruitArray: [Fruit] = []
    var delegate: FruitTableDelegate?
    
    // MARK: other variables
    @IBOutlet weak var handleArea: UIView!
    let fruitManager = FruitManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nibCell = UINib(nibName: "AllFruitCollectionCell",bundle: nil)
        collectionViewAllFruit.register(nibCell, forCellWithReuseIdentifier: collectionViewCellId)
        collectionViewAllFruit.delegate = self
        collectionViewAllFruit.dataSource = self
        roundCorners()
        fruitManager.getAllFruits() {[weak self] fruits in
            DispatchQueue.main.async {
                self?.allFruitArray = fruits
                self?.collectionViewAllFruit.reloadData()
            }
        }
    }
    
    func roundCorners() {
        let rect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: handleArea.bounds.height)
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [.topRight, .topLeft],
            cornerRadii: CGSize(width: 30, height:  30)
        )
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        handleArea.layer.mask = maskLayer
    }
}

// MARK: UICollectionViewDataSource
extension CardViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allFruitArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionViewCellId, for: indexPath) as! AllFruitCollectionCell
        let urlImage = URL(string: "\(allFruitArray[indexPath.row].image)") ?? URL(string: "")!
        ImageLoader.image(for: urlImage) { image in
            cell.fruitImage.image = image
        }
        return cell
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension CardViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Int(collectionView.frame.width / 3 - 16), height: Int(collectionView.frame.width / 3 - 16))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
}

// MARK: UICollectionViewDelegate, FruitTableDelegate
extension CardViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        fruitManager.addFruit(fruitId: allFruitArray[indexPath.row].id){ isSuccess in
            if isSuccess {
                self.delegate?.updateFruitTable()
            }
        }
    }
}
