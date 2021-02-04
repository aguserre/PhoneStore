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
    let generator = UIImpactFeedbackGenerator(style: .medium)
    var senderFilter = UIButton()
    var filter: FilterSelection = .none
    @IBOutlet weak var colectionView: UICollectionView!
    @IBOutlet weak var colectionViewHigtConstraint: NSLayoutConstraint!
    var filterArray = [Int]()
    var isShowingCollectionView = false
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var movementsTableView: UITableView!
    var movements = [MovementsModel]()
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        expandCollection(expand: isShowingCollectionView, showCells: filterArray)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [UIColor.systemTeal.cgColor,  UIColor.systemIndigo.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
        let gradientLayer2 = CAGradientLayer()
        gradientLayer2.frame = stackView.bounds
        gradientLayer2.colors = [UIColor.systemTeal.cgColor,  UIColor.systemIndigo.cgColor]
        gradientLayer2.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer2.endPoint = CGPoint(x: 1.0, y: 0.5)
        stackView.layer.insertSublayer(gradientLayer2, at: 0)
        stackView.addShadow(offset: .zero, color: .black, radius: 5, opacity: 0.4)
        
        colectionView.addShadow(offset: .zero, color: .black, radius: 5, opacity: 0.4)
        colectionView.layer.cornerRadius = 10
        
        backgroundView.addShadow(offset: .zero, color: .black, radius: 5, opacity: 0.4)
        backgroundView.layer.cornerRadius = 20
        backgroundView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                
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
            self.colectionViewHigtConstraint.constant = const
            self.view.layoutIfNeeded()
        } completion: { (success) in
            self.colectionView.reloadData()
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

extension MovementsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarCollectionViewCell", for: indexPath) as! CalendarCollectionViewCell
        cell.addShadow(offset: .zero, color: .black, radius: 4, opacity: 0.3)
        cell.setupCell(day: filterArray[indexPath.row])
        cell.layer.cornerRadius = 10
        return cell
    }
}

extension MovementsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        generator.impactOccurred()
        isShowingCollectionView.toggle()
        filter = .none
        expandCollection(expand: isShowingCollectionView, showCells: [])
    }
    
}
