//
//  SettingsViewController.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 28/01/2021.
//

import UIKit

final class SettingsViewController: UIViewController {
    
    var user: UserModel?
    var userLogged: UserModel?
    var pos: PointOfSale?
    var selectedPos = [PointOfSale]()
    var posArray = [PointOfSale]()
    var viewState: StateExpandView? = .userExpanded
    var userTypeView: UserType? = .vendor
    private let serviceManager = ServiceManager()
    
    var placeholders = [String]()
    let placeHolderUser = ["Nombre completo", "Email", "Password", "Documento"]
    let placeHolderPos = ["Nombre del Punto de Venta", "Ubicacion"]
    var userDic = [String : Any]()
    @IBOutlet private weak var addButton: UIButton!
    @IBOutlet private weak var backgroundContactView: UIView!
    
    @IBOutlet private weak var posSelectionButton: UIButton!
    @IBOutlet private weak var rolSegmentedControl: UISegmentedControl!
    
    @IBOutlet private weak var textFieldsTableView: UITableView!
    private var textFields = [UITextField]()
    @IBOutlet private weak var addTypeSelectedControl: UISegmentedControl!
    enum StateExpandView {
        case userExpanded, posExpanded
    }
    
    enum UserTextFieldData: Int {
        case nameTextField = 0
        case emailTextField = 1
        case passwordTextField = 2
        case documentTextField = 3

    }
    
    enum PosTextFieldData: Int {
        case nameTextField = 0
        case ubicationTextField = 1
    }
    
    private var startEditing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        backgroundContactView.layer.insertSublayer(createCustomGradiend(view: backgroundContactView), at: 0)
        setNavTitle(title: "Configuracion")
        
        navigationItem.rightBarButtonItem = setupRightButton(target: #selector(logOut))
        addButton.isHidden = userTypeView == .admin ? false : true
        
        if !addButton.isHidden {
            addButton.layer.insertSublayer(createCustomGradiend(view: addButton), at: 0)
            addButton.addShadow(offset: .zero, color: .black, radius: 4, opacity: 0.4)
        }
        
        expandViewSetup(type: .userExpanded)
    }
    
    private func expandViewAnimation(expand: Bool) {
        UIView.animate(withDuration: 0.5) {
            if expand {
                self.addButton.setTitle(save, for: .normal)
                self.addButton.tag = 0
            } else {
                self.addButton.setTitle(addNew, for: .normal)
                self.addButton.tag = 1
            }
            self.view.layoutIfNeeded()
        } completion: { (success) in
            UIView.animate(withDuration: 0.3) {
                if expand {
                    self.backgroundContactView.clipsToBounds = true
                    self.backgroundContactView.layer.cornerRadius = 0
                } else {
                    self.backgroundContactView.clipsToBounds = true
                    self.backgroundContactView.layer.cornerRadius = 20
                }
                self.backgroundContactView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                self.view.layoutIfNeeded()
            }
        }

        textFieldsTableView.reloadData()
    }
    
    private func setupTextFields() {
        let totalTextFields = viewState == .userExpanded ? 4 : 2
        textFields.removeAll()
        switch viewState {
        case .userExpanded:
            for _ in 1...totalTextFields {
                let textFieldToShow = UITextField()
                self.textFields.append(textFieldToShow)
            }
        case .posExpanded:
            for _ in 1...totalTextFields {
                let textFieldToShow = UITextField()
                self.textFields.append(textFieldToShow)
            }
        default:
            textFieldsTableView.isHidden = true
        }
    }
    
    @IBAction private func add(_ sender: UIButton) {
        generateImpactWhenTouch()
        let typeViewExpanded: StateExpandView  = addTypeSelectedControl.selectedSegmentIndex == 0 ? .userExpanded : .posExpanded
        let typeRawValue: UserType = self.rolSegmentedControl.selectedSegmentIndex == 0 ? .vendor : .admin
        
        if typeViewExpanded == .userExpanded {
            if typeRawValue == .vendor,
               selectedPos.count == 0  {
                presentAlertController(title: errorTitle, message: needSelectAPOS, delegate: self, completion: nil)
                return
            }
            var selectedPosIds: [String] {
                var posIds: [String] = ["undefined"]
                if selectedPos.count == 0 {
                    return posIds
                }
                posIds.removeAll()
                for pos in selectedPos {
                    if let posId = pos.id {
                        posIds.append(posId)
                    }
                }
                return posIds
            }
            user = UserModel(JSON: userDic)
            guard let email = userDic["email"] as? String, let pass = userDic["password"] as? String else {
                presentAlertController(title: errorTitle, message: registrationError, delegate: self, completion: nil)
                return
            }
            serviceManager.createNewUser(delegate: self, userDic: userDic, email: email, pass: pass, userType: typeRawValue, posAsignedId: selectedPosIds)
        } else {
            let typeRawValue: POSType = self.rolSegmentedControl.selectedSegmentIndex == 0 ? .movil : .kStatic
            serviceManager.saveNewPOS(delegate: self,userDic: userDic, userType: typeRawValue)
        }
    }
    
    private func expandViewSetup(type: StateExpandView) {
        switch type {
        case .userExpanded:
            setupUserView()
            viewState = .userExpanded
        case .posExpanded:
            setupPosView()
            viewState = .posExpanded
        }
    }
    
    private func setupUserView() {
        viewState = .userExpanded
        rolSegmentedControl.setTitle(vendor, forSegmentAt: 0)
        rolSegmentedControl.setTitle(admin, forSegmentAt: 1)
        rolSegmentedControl.isHidden = false
        posSelectionButton.setTitle(asignPOS, for: .normal)
        posSelectionButton.isHidden = false
        textFieldsTableView.isHidden = false
        setupTextFields()
        expandViewAnimation(expand: true)
    }
    
    private func setupPosView() {
        viewState = .posExpanded
        rolSegmentedControl.setTitle(movil, forSegmentAt: 0)
        rolSegmentedControl.setTitle(kStatic, forSegmentAt: 1)
        rolSegmentedControl.isHidden = false
        posSelectionButton.isHidden = true
        textFieldsTableView.isHidden = false
        setupTextFields()
        expandViewAnimation(expand: true)
    }
    
    private func presentActionSheet() {
        serviceManager.getPOSFullList { (pos, error) in
            if let pos = pos {
                self.posArray = pos
                self.presentSelectionPosActionSheet()
            }
            if let error = error {
                self.presentAlertController(title: errorTitle, message: error, delegate: self, completion: nil)
            }
        }
    }
    
    private func presentSelectionPosActionSheet() {
        let actionSheetController: UIAlertController = UIAlertController(title: chooseOption, message: nil, preferredStyle: .actionSheet)

        for pos in posArray {
            let actionAdd: UIAlertAction = UIAlertAction(title: pos.name, style: .default) { action -> Void in
                self.selectedPos.append(pos)
                self.posSelectionButton.setTitle("Asignar puntos de venta(\(self.selectedPos.count ?? 0))", for: .normal)
            }
            actionSheetController.addAction(actionAdd)
        }

        let cancelAction: UIAlertAction = UIAlertAction(title: cancel, style: .cancel) { action -> Void in }
        actionSheetController.addAction(cancelAction)

        present(actionSheetController, animated: true) {
            self.posArray.removeAll()
        }
    }
    
    @IBAction private func selectAsign(_ sender: Any) {
        generateImpactWhenTouch()
        presentActionSheet()
    }
    
    @IBAction private func typeChanged(_ sender: UISegmentedControl) {
        generateImpactWhenTouch()
        textFields.removeAll()
        userDic = [:]
        expandViewSetup(type: sender.selectedSegmentIndex == 0 ? .userExpanded : .posExpanded)
    }
    
    @IBAction private func typeUserChange(_ sender: Any) {
        generateImpactWhenTouch()
    }
    
    @objc private func logOut(_ sender: Any) {
        serviceManager.logOut(delegate: self)
    }

}

extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.textFields.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldTableViewCell", for: indexPath) as! TextFieldTableViewCell
        
        if viewState == .userExpanded {
            placeholders = placeHolderUser
        } else {
            placeholders = placeHolderPos
        }
       
        cell.setupTextfields(textFieldDelegate: self, tag: indexPath.row, placeHolder: placeholders[indexPath.row])
        
        return cell
    }
}

extension SettingsViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.addTarget(self, action: #selector(valueChanged), for: .editingChanged)
    }
    
    @objc func valueChanged(_ textField: UITextField){
        if self.viewState == .userExpanded, textField.text != "" {
            switch textField.tag {
            case UserTextFieldData.nameTextField.rawValue:
                userDic["username"] = textField.text
                textField.keyboardType = .alphabet
            case UserTextFieldData.emailTextField.rawValue:
                userDic["email"] = textField.text
                textField.keyboardType = .emailAddress
            case UserTextFieldData.passwordTextField.rawValue:
                textField.keyboardType = .alphabet
                userDic["password"] = textField.text
            case UserTextFieldData.documentTextField.rawValue:
                userDic["dni"] = textField.text
                textField.keyboardType = .numberPad
            default:
                break
            }
            print(userDic)
        } else if self.viewState == .posExpanded {
            switch textField.tag {
            case PosTextFieldData.nameTextField.rawValue:
                userDic["name"] = textField.text
                textField.keyboardType = .alphabet
            case PosTextFieldData.ubicationTextField.rawValue:
                userDic["localized"] = textField.text
                textField.keyboardType = .emailAddress
            default:
                break
            }
            print(userDic)
        }
    }
}
