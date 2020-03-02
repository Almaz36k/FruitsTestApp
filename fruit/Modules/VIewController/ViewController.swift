import UIKit

protocol FruitTableDelegate: class {
    func updateFruitTable()
}

class ViewController: UIViewController {
    // MARK: fruitTable variables
    @IBOutlet weak var fruitTable: UITableView!
    let fruitTableCellId = "MyCell"
    var delegate: FruitTableDelegate?
    var fruitsArray: [MyFruit] = []
    
    // MARK: CardViewController variables
    @IBOutlet weak var contentView: UIView!
    var cardViewController: CardViewController!
    var cardHeight:CGFloat = 0
    let cardHandleAreaHeight:CGFloat = 80
    var cardVisible = false
    
    enum CardState {
        case expanded
        case collapsed
    }
    
    var nextState: CardState {
        return cardVisible ? .collapsed : .expanded
    }
    
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted: CGFloat = 0
    
    // MARK: other variables
    let fruitManager = FruitManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cardHeight = contentView.bounds.height
        fetchFruits()
        setupCard()
        
        let nibCell = UINib(nibName: "MyFruitTableCell", bundle: nil)
        fruitTable.register(nibCell, forCellReuseIdentifier: fruitTableCellId)
        fruitTable.delegate = self
        fruitTable.dataSource = self
    }
    
    private func fetchFruits() {
        fruitManager.getMyFruits() {[weak self] myFruits in
            DispatchQueue.main.async {
                self?.fruitsArray = myFruits
                self?.fruitTable.reloadData()
            }
        }
    }
    
    // MARK: derive bottom sheet
    func setupCard() {
        cardViewController = CardViewController(nibName:"CardViewController", bundle:nil)
        cardViewController.delegate = self
        self.addChild(cardViewController)
        contentView.addSubview(cardViewController.view)

        DispatchQueue.main.async {
            self.cardViewController.view.frame = CGRect(
                x: 0,
                y: self.contentView.bounds.height - self.cardHandleAreaHeight,
                width: self.contentView.frame.width,
                height: self.cardHeight
            )
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleCardTap(recognizer:)))
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ViewController.handleCardPan(recognizer:)))
        
        cardViewController.handleArea.addGestureRecognizer(tapGestureRecognizer)
        cardViewController.handleArea.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func handleCardTap(recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            animateTransitionIfNeeded(state: nextState, duration: 0.9)
        default:
            break
        }
    }
    
    @objc func handleCardPan (recognizer:UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            startInteractiveTransition(state: nextState, duration: 0.9)
        case .changed:
            let translation = recognizer.translation(in: self.cardViewController.handleArea)
            var fractionComplete = translation.y / cardHeight
            fractionComplete = cardVisible ? fractionComplete : -fractionComplete
            updateInteractiveTransition(fractionCompleted: fractionComplete)
        case .ended:
            continueInteractiveTransition()
        default:
            break
        }
        
    }
    
    func animateTransitionIfNeeded(state: CardState, duration: TimeInterval){
        if runningAnimations.isEmpty {
            let frameAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear){
                switch state {
                case .expanded:
                    self.cardViewController.view.frame.origin.y = 0
                case .collapsed:
                    self.cardViewController.view.frame.origin.y = self.contentView.frame.height - self.cardHandleAreaHeight
                }
            }
            frameAnimator.addCompletion{_ in
                self.cardVisible = !self.cardVisible
                self.runningAnimations.removeAll()
            }
            frameAnimator.startAnimation()
            runningAnimations.append(frameAnimator)
        }
    }
    
    func startInteractiveTransition(state:CardState, duration:TimeInterval) {
        if runningAnimations.isEmpty {
            animateTransitionIfNeeded(state: state, duration: duration)
        }
        for animator in runningAnimations {
            animator.pauseAnimation()
            animationProgressWhenInterrupted = animator.fractionComplete
        }
    }
       
    func updateInteractiveTransition(fractionCompleted:CGFloat) {
        for animator in runningAnimations {
            animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
        }
    }
       
    func continueInteractiveTransition (){
        for animator in runningAnimations {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
       
}

// MARK: UITableViewDataSource
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fruitsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: fruitTableCellId, for: indexPath) as! MyFruitTableCell
        cell.isEditing = true
        cell.fruitName.text = fruitsArray[indexPath.row].text

        let urlImage = URL(string: "\(fruitsArray[indexPath.row].image)") ?? URL(string: "")!
        ImageLoader.image(for: urlImage) { image in
            cell.fruitImage.image = image
        }
        return cell
    }
}

// MARK: UITableViewDelegate
extension ViewController: UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "") { _, _, complete in
            self.fruitManager.removeFruit(fruitId: self.fruitsArray[indexPath.row].id){ isSuccess in
                if isSuccess {
                    DispatchQueue.main.async {
                        self.fruitsArray.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        complete(true)
                    }
                } else {
                    complete(false)
                }
            }
        }
        deleteAction.backgroundColor = UIColor(red:0.41, green:0.59, blue:0.20, alpha:1.0)
        deleteAction.image = .remove
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])

        return configuration
    }
}

// MARK: FruitTableDelegate
extension ViewController: FruitTableDelegate {
    func updateFruitTable() {
        fetchFruits()
    }
}
