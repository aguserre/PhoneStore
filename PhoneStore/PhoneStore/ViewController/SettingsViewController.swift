//
//  SettingsViewController.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 28/01/2021.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class SettingsViewController: UIViewController {
    
    var user: UserModel?
    var userLogged: UserModel?
    var pos: PointOfSale?
    var selectedPos: PointOfSale?
    var posArray = [PointOfSale]()
    var baseRef: DatabaseReference!
    var viewState: StateExpandView? = .hidden
    var userTypeView: UserType? = .vendor
    
    var placeholders = [String]()
    let placeHolderUser = ["Nombre completo", "Email", "Password", "Documento"]
    let placeHolderPos = ["Nombre del Punto de Venta", "Ubicacion"]
    var userDic = [String : Any]()
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var backgroundContactView: UIView!
    @IBOutlet weak var hightBackgroundView: NSLayoutConstraint!
    
    @IBOutlet weak var posSelectionButton: UIButton!
    @IBOutlet weak var rolSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var textFieldsTableView: UITableView!
    private var textFields = [UITextField]()
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addTypeSelectedControl: UISegmentedControl!
    enum StateExpandView {
        case hidden, userExpanded, posExpanded
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
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [UIColor.systemTeal.cgColor,  UIColor.systemIndigo.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blurEffectView, at: 0)
        
        let gradientLayer2 = CAGradientLayer()
        gradientLayer2.frame = self.headerView.bounds
        gradientLayer2.colors = [UIColor.systemTeal.cgColor,  UIColor.systemIndigo.cgColor]
        gradientLayer2.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer2.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.headerView.layer.insertSublayer(gradientLayer2, at: 0)
        
        let shadowSize: CGFloat = 20
        let contactRect = CGRect(x: -shadowSize, y: headerView.bounds.height - (shadowSize * 0.4), width: headerView.bounds.width + shadowSize * 2, height: shadowSize)
        headerView.layer.shadowPath = UIBezierPath(ovalIn: contactRect).cgPath
        headerView.layer.shadowRadius = 4
        headerView.layer.shadowOpacity = 0.2
        
        navigationItem.rightBarButtonItem = setupRightButton(target: #selector(logOut))
        addButton.isHidden = userTypeView == .admin ? false : true
        
        if !addButton.isHidden {
            addButton.layer.shadowPath = UIBezierPath(rect: addButton.bounds).cgPath
            addButton.layer.shadowRadius = 5
            addButton.layer.shadowOffset = .zero
            addButton.layer.shadowOpacity = 0.3
            
            let gradientLayer3 = CAGradientLayer()
            gradientLayer3.cornerRadius = 10
            gradientLayer3.frame = addButton.bounds
            gradientLayer3.colors = [UIColor.systemTeal.cgColor,  UIColor.systemIndigo.cgColor]
            gradientLayer3.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer3.endPoint = CGPoint(x: 1.0, y: 0.5)
            
            self.addButton.layer.insertSublayer(gradientLayer3, at: 0)
        }
        
        
        expandViewSetup(type: .hidden)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if baseRef != nil {
            baseRef.removeAllObservers()
        }
    }
    
    func expandViewAnimation(expand: Bool) {
        UIView.animate(withDuration: 0.5) {
            if expand {
                let safeAreaTop = self.view.safeAreaInsets.top
                self.hightBackgroundView.constant = self.view.bounds.height-safeAreaTop - self.headerView.bounds.height
                self.addButton.setTitle("Guardar", for: .normal)
                self.addButton.tag = 0
            } else {
                self.hightBackgroundView.constant = 0
                self.addButton.setTitle("Agregar", for: .normal)
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
    
    func setupTextFields() {
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
    
    @IBAction func add(_ sender: UIButton) {
        let typeViewExpanded: StateExpandView  = addTypeSelectedControl.selectedSegmentIndex == 0 ? .userExpanded : .posExpanded
        let typeRawValue: UserType = self.rolSegmentedControl.selectedSegmentIndex == 0 ? .vendor : .admin
        
        if sender.tag == 1 {
            expandViewSetup(type: typeViewExpanded)
        } else {
            if typeViewExpanded == .userExpanded {
                
                if typeRawValue == .vendor,
                   selectedPos?.id == nil  {
                    print("Debe seleccionar un local")
                    return
                }
                
                let selectedPosId = selectedPos?.id ?? ""
                
            
                user = UserModel(JSON: userDic)
                guard let email = userDic["email"] as? String, let pass = userDic["password"] as? String else {
                    print("Error de registracion")
                    return
                }
                
                Auth.auth().createUser(withEmail: email, password: pass ) { (auth, error) in
                guard let user = auth?.user else {
                    print(error?.localizedDescription)
                    return
                }
                    
                
                    
                let newUserDic: [String : Any] = ["id":user.uid,
                                                "email": user.email as Any,
                                                "username": self.userDic["username"] as Any,
                                                "dni":self.userDic["dni"] as Any,
                                                "type": typeRawValue.rawValue,
                                                "localAutorized":selectedPosId]

                let userModel = UserModel(JSON: newUserDic)?.toDictionary()
                self.baseRef = Database.database().reference().child("USER_ADD").child(user.uid)
                self.baseRef.setValue(userModel) { (error, ref) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        print("Save SUCCESS")
                        self.expandViewSetup(type: .hidden)
                    }
                }
                }
            } else {
                let typeRawValue: POSType = self.rolSegmentedControl.selectedSegmentIndex == 0 ? .movil : .kStatic
                self.baseRef = Database.database().reference().child("POS_ADD").childByAutoId()
                let key = baseRef.key
                let newPosDic: [String : Any] = ["id": key as Any,
                                                 "name": userDic["name"] as Any,
                                                 "type": typeRawValue.rawValue,
                                                "localized" : userDic["localized"] as Any]

                let posModel = PointOfSale(JSON: newPosDic)
                
                self.baseRef.setValue(posModel?.toDictionary()) { (error, ref) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        print("Save SUCCESS")
                        self.expandViewSetup(type: .hidden)
                    }
                }
            }
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
        case .hidden:
            setupHiddenView()
            viewState = .hidden
        }
    }
    
    func changeViewColor() {
        switch viewState {
        case .userExpanded:
            backgroundContactView.backgroundColor = .systemIndigo
            textFieldsTableView.backgroundColor = .systemIndigo
        case .posExpanded:
            backgroundContactView.backgroundColor = .systemTeal
            textFieldsTableView.backgroundColor = .systemTeal
        default:
            backgroundContactView.backgroundColor = .clear
        }
    }
    
    private func setupUserView() {
        viewState = .userExpanded
        cancelButton.isHidden = false
        titleLabel.isHidden = false
        rolSegmentedControl.setTitle("Vendedor", forSegmentAt: 0)
        rolSegmentedControl.setTitle("Administrador", forSegmentAt: 1)
        rolSegmentedControl.isHidden = false
        posSelectionButton.setTitle("Asignar punto de venta", for: .normal)
        posSelectionButton.isHidden = false
        textFieldsTableView.isHidden = false
        setupTextFields()
        expandViewAnimation(expand: true)
    }
    
    private func setupPosView() {
        viewState = .posExpanded
        cancelButton.isHidden = false
        titleLabel.isHidden = false
        rolSegmentedControl.setTitle("Movil", forSegmentAt: 0)
        rolSegmentedControl.setTitle("Fijo", forSegmentAt: 1)
        rolSegmentedControl.isHidden = false
        posSelectionButton.isHidden = true
        textFieldsTableView.isHidden = false
        setupTextFields()
        expandViewAnimation(expand: true)
    }
    
    private func setupHiddenView() {
        cancelButton.isHidden = true
        posSelectionButton.isHidden = true
        rolSegmentedControl.isHidden = true
        titleLabel.isHidden = true
        textFieldsTableView.isHidden = true
        expandViewAnimation(expand: false)
    }
    
    private func presentActionSheet() {
        baseRef = Database.database().reference().child("POS_ADD")
        baseRef.observeSingleEvent(of: .value) { (snap) in
            if let snapshot = snap.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if let posDic = snap.value as? [String : AnyObject] {
                        if let posObject = PointOfSale(JSON: posDic) {
                            self.posArray.append(posObject)
                        }
                    }
                }
                self.presentSelectionPosActionSheet()
            }
        }
            
        // create an actionSheet

    }
        
    func presentSelectionPosActionSheet() {
        let actionSheetController: UIAlertController = UIAlertController(title: "Elegi una opcion", message: nil, preferredStyle: .actionSheet)

        for pos in posArray {
            let actionAdd: UIAlertAction = UIAlertAction(title: pos.name, style: .default) { action -> Void in
                self.selectedPos = pos
            }
            actionSheetController.addAction(actionAdd)
        }

        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }
        actionSheetController.addAction(cancelAction)

        present(actionSheetController, animated: true) {
            self.posArray.removeAll()
        }
    }
    
    @IBAction func selectAsign(_ sender: Any) {
        presentActionSheet()
    }
    
    
    @IBAction func cancelAction(_ sender: UIButton) {
        setupHiddenView()
    }
    
    @IBAction func typeChanged(_ sender: UISegmentedControl) {
        textFields.removeAll()
        userDic = [:]
        expandViewSetup(type: sender.selectedSegmentIndex == 0 ? .userExpanded : .posExpanded)
        changeViewColor()
    }
    
    @objc func logOut(_ sender: Any) {
        do { try Auth.auth().signOut() }
        catch { print("already logged out") }
        
        navigationController?.popToRootViewController(animated: true)
    }

}

extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.textFields.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldTableViewCell", for: indexPath) as! TextFieldTableViewCell
        
        let color = backgroundContactView.backgroundColor
        if viewState == .userExpanded {
            placeholders = placeHolderUser
        } else {
            placeholders = placeHolderPos
        }
       
        cell.setupTextfields(textFieldDelegate: self, tag: indexPath.row, backColor: color ?? .clear, placeHolder: placeholders[indexPath.row])
        
        return cell
    }
}

extension SettingsViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.addTarget(self, action: #selector(valueChanged), for: .editingChanged)
    }
    
    @objc func valueChanged(_ textField: UITextField){
        if self.viewState == .userExpanded {
            
            switch textField.tag {
            case UserTextFieldData.nameTextField.rawValue:
                userDic["username"] = textField.text
                textField.keyboardType = .alphabet
            case UserTextFieldData.emailTextField.rawValue:
                userDic["email"] = textField.text
                textField.keyboardType = .emailAddress
            case UserTextFieldData.passwordTextField.rawValue:
                userDic["password"] = textField.text
                textField.isSecureTextEntry = true
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
