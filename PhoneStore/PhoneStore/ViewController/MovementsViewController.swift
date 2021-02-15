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
    @IBOutlet weak var otherDateButton: UIButton!
    @IBOutlet weak var chartCollectionView: UICollectionView!
    @IBOutlet weak var collectionViewHightConstraint: NSLayoutConstraint!
    @IBOutlet weak var backGroundTableView: UIView!
    let generator = UIImpactFeedbackGenerator(style: .medium)
    var senderFilter = UIButton()
    var movSelected: MovementsModel?
    var filter: FilterSelection = .day
    var dataBaseRef: DatabaseReference!
    var posts = [PointOfSale]()
    var total: Double = 0.0
    var dic = [String:Double]()
    var dicSorted = [[String:Double]]()
    var totalPerPos = [[String:Double]]()
    var posDictionary: [Dictionary<String, AnyObject>] = Array()
    var maxAmount: Double = 0.0
    var amounts = [Double]()
    var nameKey = ""
    var valueV = 0.0
    
    var filterNumber = 0
    var isShowingCollectionView = false
        
    @IBOutlet weak var movementsTableView: UITableView!
    var movements = [MovementsModel]()
    var movementsWithoutFilters = [MovementsModel]()
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if dataBaseRef != nil {
            dataBaseRef.removeAllObservers()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        dataBaseRef = Database.database().reference().child("PROD_MOV")
        getMovementsData()
        
        backGroundTableView.addShadow(offset: .zero, color: .black, radius: 5, opacity: 0.4)
        backGroundTableView.layer.cornerRadius = 20
        backGroundTableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                
        weekButton.addShadow(offset: .zero, color: .black, radius: 5, opacity: 0.4)
        dayButton.addShadow(offset: .zero, color: .black, radius: 5, opacity: 0.4)
        monthButton.addShadow(offset: .zero, color: .black, radius: 5, opacity: 0.4)
        otherDateButton.addShadow(offset: .zero, color: .black, radius: 5, opacity: 0.4)
        weekButton.layer.cornerRadius = 5
        monthButton.layer.cornerRadius = 5
        dayButton.layer.cornerRadius = 5
        otherDateButton.layer.cornerRadius = 5
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.3, animations: {
            self.collectionViewHightConstraint.constant = 180
            self.view.layoutIfNeeded()
        }) { (success) in
            UIView.animate(withDuration: 1) { [self] in
//                for pos in self.posts {
//                    self.total = self.getTotalMovementsFromLocal(localId: pos.id ?? "")
//                    self.dic = [pos.name ?? "" : self.total]
//                    self.totalPerPos.append(dic)
//                }
//                self.dicSorted = totalPerPos
//                self.sortData()
//                self.maxAmount = self.getMaxValue()
                self.chartCollectionView.delegate = self
                self.chartCollectionView.dataSource = self
            }
        }
    }
    
    @IBAction func seeMoreAction(_ sender: Any) {
        generator.impactOccurred()
        print("Filtro especifico")
    }
    
    @IBAction private func selectSender(sender: UIButton) {
        generator.impactOccurred()

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
            print("F")
        }
    }
    
    @IBAction func updateData(_ sender: Any) {
        movements.removeAll()
        movementsWithoutFilters.removeAll()
        getMovementsData()
    }
    
    @IBAction func shareData(_ sender: Any) {
        let filename = "Movimientos.csv"
        let docDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let docURL = URL(fileURLWithPath: docDirectoryPath).appendingPathComponent(filename)
        
        let output = OutputStream.toMemory()
        let csvWriter = CHCSVWriter(outputStream: output, encoding: String.Encoding.utf8.rawValue, delimiter: ",".utf16.first!)
        
        csvWriter?.writeField("NOMBRE LOCAL")
        csvWriter?.writeField("TIPO DE MOVIMIENTO")
        csvWriter?.writeField("MONTO DE VENTA")
        csvWriter?.writeField("FECHA DE VENTA")
        csvWriter?.finishLine()
        
        for (elements) in movements.enumerated() {
            csvWriter?.writeField(elements.element.localId)
            csvWriter?.writeField(elements.element.movementType)
            csvWriter?.writeField(elements.element.totalAmount)
            csvWriter?.writeField(elements.element.dateOut)
            
            csvWriter?.finishLine()
        }
        
        csvWriter?.closeStream()
        
        let buffer = (output.property(forKey: .dataWrittenToMemoryStreamKey) as? Data)
        
        do {
            try buffer?.write(to: docURL)
        } catch {
            print(error.localizedDescription)
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
                self.movementsWithoutFilters = self.movements
                self.dayButtonAction()
            }
        }
    }
    
    func getTotalMovementsFromLocal(localId: String) -> Double {
        let filterPost = movements.filter({$0.id == localId})
        let filterOutMov = filterPost.filter({$0.movementType == MovementType.out.rawValue})
        let filterAmount = filterOutMov.map({$0.totalAmount ?? 0})
                
        total = filterAmount.reduce(0, +)
        
        return total
    }
    
    func yearButtonAction() {
        filter = .month
        filterNumber = filterByCurrentYear()
    }
    
    func monthButtonAction() {
        filter = .month
        getDatesToFilter(filterBy: filter)
    }
    
    func weekButtonAction() {
        filter = .week
        getDatesToFilter(filterBy: filter)
    }
    
    func dayButtonAction() {
        filter = .day
        getDatesToFilter(filterBy: filter)
    }
    
    func filterTableView(dates: [String]) {
        movements = movementsWithoutFilters
        
        movements = movements.filter { (mov) -> Bool in
            dates.contains(where: {$0 == mov.dateOut})
        }
        amounts.removeAll()
        totalPerPos.removeAll()
        for pos in posts {
            total = getTotalMovementsFromLocal(localId: pos.id ?? "")
            dic = [pos.name ?? "" : total]
            totalPerPos.append(dic)
        }
        dicSorted = totalPerPos
        sortData()
        maxAmount = getMaxValue()
        
        UIView.animate(withDuration: 0.3) {
            self.movementsTableView.reloadData()
            self.chartCollectionView.reloadData()
            self.view.layoutIfNeeded()
        } completion: { (success) in
            
        }
    }
    
    func getDatesToFilter(filterBy: FilterSelection){
        var today = Date()
        var lastDays = [String]()

        let formatter1 = DateFormatter()
        formatter1.dateStyle = .short
        formatter1.dateFormat = "yy/MM/dd"
        
        if filterBy != .day {
            let days = filterBy == .week ? -6 : -30
            lastDays = (days...0).map { delta -> String in
                let tomorrow = Calendar.current.date(byAdding: .day, value: -1, to: today)
                let stringDate : String = formatter1.string(from: today)
                today = tomorrow!
                
                return stringDate
            }
        } else {
            lastDays.append(formatter1.string(from: today))
        }
        filterTableView(dates: lastDays)
    }
    
    func filterByToday() -> Int{
        let calendar = Calendar.current
        return calendar.component(.day, from: Date())
    }
    
    func filterByCurrentMonth() -> Int {
        let calendar = Calendar.current
        return calendar.component(.month, from: Date())
    }
    
    func filterByCurrentWeek() -> Int {
        let calendar = Calendar.current
        return calendar.component(.weekOfMonth, from: Date())
    }
    
    func filterByCurrentYear() -> Int {
        let calendar = Calendar.current
        return calendar.component(.year, from: Date())
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
    
    func getMaxValue() -> Double {
        if amounts.isEmpty {
            for item in totalPerPos {
                for (_, value) in item {
                    amounts.append(value)
                }
            }
            maxAmount = amounts.max() ?? 0
        }
        
        return maxAmount
    }
    
    func sortData() {
        dicSorted.sort {
            item1, item2 in
            var amount1 = 0.0
            var amount2 = 0.0
            
            if let date1 = item1.values.first {
                amount1 = date1
            }
            if let date2 = item2.values.first {
                amount2 = date2
            }
            
            return amount1 > amount2
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueId = segue.identifier,
           segueId == "showMovDetail",
           let detailViewController = segue.destination as? MovementDetailViewController {
            detailViewController.mov = movSelected
        }
    }
}

extension MovementsViewController: UICollectionViewDelegate {
    
}

extension MovementsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dicSorted.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChartCollectionViewCell", for: indexPath) as! ChartCollectionViewCell
        
        var nameS = ""
        var valueD = 0.0
        
        for (key, value) in dicSorted[indexPath.row] {
            nameS = key
            valueD = value
        }
        
        cell.setupCell(name: nameS,
                       total: CGFloat(valueD),
                       maxAmount: maxAmount)
        
        return cell
    }
}

extension MovementsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cantiti: CGFloat = CGFloat(posts.count > 5 ? 5 : Double(posts.count))
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        movSelected = movements[indexPath.row]
        performSegue(withIdentifier: "showMovDetail", sender: nil)
    }
    
    
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
