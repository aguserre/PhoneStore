//
//  MovementsViewController.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 27/01/2021.
//

import UIKit
import FirebaseDatabase


class MovementsViewController: UIViewController {

    @IBOutlet weak var filterStackView: UIStackView!
    @IBOutlet weak var dayButton: UIButton!
    @IBOutlet weak var weekButton: UIButton!
    @IBOutlet weak var monthButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var chartCollectionView: UICollectionView!
    @IBOutlet weak var backGroundTableView: UIView!
    let generator = UIImpactFeedbackGenerator(style: .medium)
    var senderFilter = UIButton()
    var filter: FilterSelection = .none
    var dataBaseRef: DatabaseReference!
    var posts = [PointOfSale]()
    
    var filterArray = [Int]()
    var isShowingCollectionView = false
        
    @IBOutlet weak var movementsTableView: UITableView!
    var movements = [MovementsModel]()
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataBaseRef = Database.database().reference().child("PROD_MOV")
        getMovementsData()
        
        expandCollection(expand: isShowingCollectionView, showCells: filterArray)
        
        backGroundTableView.addShadow(offset: .zero, color: .black, radius: 5, opacity: 0.4)
        backGroundTableView.layer.cornerRadius = 20
        backGroundTableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                
        weekButton.addShadow(offset: .zero, color: .black, radius: 5, opacity: 0.4)
        dayButton.addShadow(offset: .zero, color: .black, radius: 5, opacity: 0.4)
        monthButton.addShadow(offset: .zero, color: .black, radius: 5, opacity: 0.4)
        weekButton.layer.cornerRadius = 10
        monthButton.layer.cornerRadius = 10
        dayButton.layer.cornerRadius = 10
        
    }
    
    @IBAction func seeMoreAction(_ sender: Any) {
        generator.impactOccurred()
        print("Filtro especifico")
    }
    
    @IBAction private func selectSender(sender: UIButton) {
        generator.impactOccurred()
        if filter == .none {
            isShowingCollectionView.toggle()
        }
        senderFilter = sender
        filter = FilterSelection(rawValue: sender.tag) ?? FilterSelection(rawValue: 0)!
        
        switch filter {
        case .day:
            dayButtonAction()
        case .week:
            weekButtonAction()
        case.month:
            monthButtonAction()
        default:
            expandCollection(expand: false, showCells: [])
        }
    }
    
    private func getMovementsData() {
        dataBaseRef.observeSingleEvent(of: .value) { (snap) in
            if let snapshot = snap.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if let posDic = snap.value as? [String : AnyObject] {
                        if let posObject = MovementsModel(JSON: posDic) {
                            self.movements.append(posObject)
                        }
                    }
                }
                
                for post in self.posts {
                    self.getTotalMovementsFromLocal(localId: post.id ?? "")
                }
                self.movementsTableView.reloadData()
            }
        }
    }
    
    func getTotalMovementsFromLocal(localId: String) {
        let filterPost = movements.filter({$0.id == localId})
        let filterOutMov = filterPost.filter({$0.movementType == MovementType.out.rawValue})
        let filterAmount = filterOutMov.map({$0.totalAmount ?? 0})
        
        let total = filterAmount.reduce(0, +)
        
        
                
       
        
        print(total)
    }
    
    func monthButtonAction() {
        filter = .month
        expandCollection(expand: isShowingCollectionView, showCells: getMonths())
    }
    
    func weekButtonAction() {
        filter = .week
        expandCollection(expand: isShowingCollectionView, showCells: getWeeks())
    }
    
    func dayButtonAction() {
        filter = .day
        filterArray = getDays()
        expandCollection(expand: isShowingCollectionView, showCells: getDays())
    }
    
    func expandCollection(expand: Bool, showCells: [Int]) {
        if expand == false {
            filterArray.removeAll()
        } else {
            filterArray = showCells
        }
        let const: CGFloat = expand ? 60 : 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        } completion: { (success) in
            
        }
    }
    
    func getMonths() -> [Int] {
        var months = [Int]()
        if let monthCant = Calendar.current.ordinality(of: .month, in: .year, for: Date()) {
            for month in 1...monthCant {
                months.append(month)
            }
        }
        return months
    }
    
    func getWeeks() -> [Int] {
        var weeks = [Int]()
        if let weekCant = Calendar.current.ordinality(of: .weekday, in: .month, for: Date()) {
            for day in 1...weekCant {
                weeks.append(day)
            }
        }
        return weeks
    }
    
    func getDays() -> [Int] {
        var days = [Int]()
        if let dayMonth = Calendar.current.ordinality(of: .day, in: .month, for: Date()) {
            for day in 1...dayMonth {
                days.append(day)
            }
        }
       return days
    }
}

extension MovementsViewController: UICollectionViewDelegate {
    
}

extension MovementsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChartCollectionViewCell", for: indexPath) as! ChartCollectionViewCell
        
        cell.setupCell(name: posts[indexPath.row].name ?? "Sin nombre", total: 80)
        
        return cell
    }
}

extension MovementsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cantiti = CGFloat(posts.count)
        let width = (collectionView.bounds.width)/cantiti
        let height = collectionView.bounds.height
        
        
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension MovementsViewController: UITableViewDelegate {
    
    
    
}

extension MovementsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovementsTableViewCell", for: indexPath) as! MovementsTableViewCell
        
        cell.configure(mov: movements[indexPath.row])
        
        return cell
    
    }
}
