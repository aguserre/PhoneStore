//
//  MovementsViewController.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 27/01/2021.
//

import UIKit


final class MovementsViewController: UIViewController {

    @IBOutlet private weak var filterStackView: UIStackView!
    @IBOutlet private weak var dayButton: UIButton!
    @IBOutlet private weak var weekButton: UIButton!
    @IBOutlet private weak var monthButton: UIButton!
    @IBOutlet private weak var datePickerBackgroundView: UIView!
    @IBOutlet private weak var datePicker: UIDatePicker!
    @IBOutlet private weak var chartCollectionView: UICollectionView!
    @IBOutlet private weak var collectionViewHightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var backGroundTableView: UIView!
    var senderFilter = UIButton()
    let serviceManager = ServiceManager()
    var movSelected: MovementsModel?
    var filter: FilterSelection = .day
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
    let filename = "Movimientos.csv"
    var selectedDate: Date?
    var filterNumber = 0
    var isShowingCollectionView = false
        
    @IBOutlet private weak var movementsTableView: UITableView!
    var movements = [MovementsModel]()
    var movementsWithoutFilters = [MovementsModel]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        getMovementsData()
        setupDatePicker()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.3, animations: {
            self.collectionViewHightConstraint.constant = 180
            self.view.layoutIfNeeded()
        }) { (success) in
            UIView.animate(withDuration: 1) { [self] in
                self.chartCollectionView.delegate = self
                self.chartCollectionView.dataSource = self
            }
        }
    }
    
    private func setupView() {
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        view.layer.insertSublayer(createCustomGradiend(view: view), at: 0)
        backGroundTableView.addShadow(offset: .zero, color: .black, radius: 5, opacity: 0.4)
        backGroundTableView.layer.cornerRadius = 20
        backGroundTableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                
        weekButton.addShadow(offset: .zero, color: .black, radius: 5, opacity: 0.4)
        dayButton.addShadow(offset: .zero, color: .black, radius: 5, opacity: 0.4)
        monthButton.addShadow(offset: .zero, color: .black, radius: 5, opacity: 0.4)
        datePickerBackgroundView.addShadow(offset: .zero, color: .black, radius: 5, opacity: 0.4)
        weekButton.layer.cornerRadius = 5
        monthButton.layer.cornerRadius = 5
        dayButton.layer.cornerRadius = 5
        datePickerBackgroundView.layer.cornerRadius = 5
    }
    
    @IBAction private func selectSender(sender: UIButton) {
        generateImpactWhenTouch()
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
    
    @IBAction func shareOptions(_ sender: UIBarButtonItem) {
        let actionSheetController: UIAlertController = UIAlertController(title: "Que desea compartir?", message: nil, preferredStyle: .actionSheet)
        
        let actionFull: UIAlertAction = UIAlertAction(title: "Todos los movimientos", style: .default) { action -> Void in
            self.shareData(dataToShare: self.movementsWithoutFilters)
        }
        actionSheetController.addAction(actionFull)
        
        let actionFilter: UIAlertAction = UIAlertAction(title: "Movimientos filtrados", style: .default) { action -> Void in
            self.shareData(dataToShare: self.movements)
        }
        actionSheetController.addAction(actionFilter)

        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancelar", style: .cancel) { action -> Void in }
        actionSheetController.addAction(cancelAction)
        
        present(actionSheetController, animated: true)
    }
    
    private func shareData(dataToShare: [MovementsModel]) {
        let docDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let docURL = URL(fileURLWithPath: docDirectoryPath).appendingPathComponent(filename)
        
        let output = OutputStream.toMemory()
        let csvWriter = CHCSVWriter(outputStream: output, encoding: String.Encoding.utf8.rawValue, delimiter: ",".utf16.first!)
        
        csvWriter?.writeField("NOMBRE LOCAL")
        csvWriter?.writeField("TIPO DE MOVIMIENTO")
        csvWriter?.writeField("MONTO DE VENTA")
        csvWriter?.writeField("FECHA DE VENTA")
        csvWriter?.finishLine()
        
        for (elements) in dataToShare.enumerated() {
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
            share()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func share() {
        let file = getDocumentsDirectory().appending("/\(filename)")
        let fileURL = URL(fileURLWithPath: file)
        
        let vc = UIActivityViewController(activityItems: [fileURL], applicationActivities: [])

        self.present(vc, animated: true)
    }
    
    func getDocumentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    private func getMovementsData() {
        serviceManager.getMovements { (movs) in
            if let movements = movs {
                self.movementsWithoutFilters = movements
                self.movements = movements
                self.dayButtonAction()
            }
        }
    }
    
    private func getTotalMovementsFromLocal(localId: String) -> Double {
        let filterPost = movements.filter({$0.id == localId})
        let filterOutMov = filterPost.filter({$0.movementType == MovementType.out.rawValue})
        let filterAmount = filterOutMov.map({$0.totalAmount ?? 0})
                
        total = filterAmount.reduce(0, +)
        
        return total
    }
    
    private func otherButtonAction(date: Date) {
        filter = .other
        getDatesToFilter(filterBy: filter, date: date)
    }
    
    private func monthButtonAction() {
        filter = .month
        getDatesToFilter(filterBy: filter)
    }
    
    private func weekButtonAction() {
        filter = .week
        getDatesToFilter(filterBy: filter)
    }
    
    private func dayButtonAction() {
        filter = .day
        getDatesToFilter(filterBy: filter)
    }
    
    private func setupDatePicker() {
        datePicker.timeZone = NSTimeZone.local
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker){
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
        selectedDate = sender.date
        guard let date = selectedDate else { return }
        otherButtonAction(date: date)
    }

    
    private func filterTableView(dates: [String]) {
        movements = movementsWithoutFilters
        movements = movements.filter { (mov) -> Bool in
            dates.contains(where: {$0 == mov.dateOut})
        }
        if movements.count == 0 {
            presentAlertController(title: "Sin movimientos", message: "No se registran movimientos para la fecha elegida", delegate: self, completion: nil)
            return
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
    
    private func getDatesToFilter(filterBy: FilterSelection, date: Date? = nil) {
        var today = Date()
        
        if let newDate = date {
            today = newDate
        }
        
        var lastDays = [String]()

        let formatter1 = DateFormatter()
        formatter1.dateStyle = .short
        formatter1.dateFormat = "dd/MM/yy"
        
        if filterBy != .day && filterBy != .other {
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
    
    private func getMaxValue() -> Double {
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
    
    private func sortData() {
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
