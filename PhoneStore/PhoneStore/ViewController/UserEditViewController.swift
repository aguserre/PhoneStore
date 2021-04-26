//
//  UserEditViewController.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 25/04/2021.
//

import UIKit

final class UserEditViewController: UIViewController {
    
    var user: UserModel?
    var pos = [PointOfSale]()
    var posIdAsigned = [String]()
    var dic = [String : Any]()
    var delegate: ModalDelegate?
        
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var posButton: UIButton!
    @IBOutlet weak var rolButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        view.layer.insertSublayer(createCustomGradiend(view: view), at: 0)
        saveButton.layer.insertSublayer(createCustomGradiend(view: saveButton), at: 0)
        saveButton.addShadow(offset: .zero, color: .black, radius: 4, opacity: 0.4)
        nameLabel.text = user?.email
        typeLabel.text = user?.type == "admin" ? "Administrador" : "Vendedor"
        posButton.layer.cornerRadius = 10
        posButton.addShadow(offset: .zero, color: .black, radius: 4, opacity: 0.5)
        rolButton.layer.cornerRadius = 10
        rolButton.addShadow(offset: .zero, color: .black, radius: 4, opacity: 0.5)
        deleteButton.layer.cornerRadius = 10
        deleteButton.addShadow(offset: .zero, color: .black, radius: 4, opacity: 0.5)
    }
    
    private func presentSelectionPosActionSheet() {
        let actionSheetController: UIAlertController = UIAlertController(title: chooseOption, message: nil, preferredStyle: .actionSheet)

        for pos in pos {
            let actionStyle: UIAlertAction.Style = self.posIdAsigned.contains(pos.id ?? "ds") ? .destructive : .default
            let actionAdd: UIAlertAction = UIAlertAction(title: pos.name?.capitalized, style: actionStyle) { action -> Void in
                if !self.posIdAsigned.contains(pos.id ?? "ds") {
                    self.posIdAsigned.append(pos.id ?? "a")
                } else {
                    self.posIdAsigned.removeAll { $0 == pos.id }
                }
                self.posButton.setTitle("Asignar puntos de venta(\(self.posIdAsigned.count ))", for: .normal)
            }
            actionSheetController.addAction(actionAdd)
        }

        let cancelAction: UIAlertAction = UIAlertAction(title: cancel, style: .cancel) { action -> Void in }
        actionSheetController.addAction(cancelAction)

        present(actionSheetController, animated: true)
    }
    
    @IBAction func asignPos(_ sender: Any) {
        presentSelectionPosActionSheet()
    }
    
    @IBAction func changeRol(_ sender: Any) {
        switch user?.type {
        case "admin":
            user?.type = UserType.vendor.rawValue
        default:
            user?.type = UserType.admin.rawValue
        }
        
        typeLabel.text = user?.type == "admin" ? "Administrador" : "Vendedor"
    }
    
    @IBAction func deleteUser(_ sender: Any) {
        guard let selectedUserId = user?.id else {
            return
        }
        presentAlertControllerWithCancel(title: "Seguro desea eliminar el usuario?", message: "Se borrará por completo el usuario seleccionado", delegate: self) { (completion) in
            ServiceManager().deleteSpecificUser(id: selectedUserId) { (error) in
                guard let error = error else {
                    self.presentAlertController(title: success, message: "Se borró con éxito el usuario.\nPara crear un usuario con el mismo email, deberá contactar con soporte", delegate: self) { (action) in
                        self.dismiss(animated: true) {
                            self.delegate?.changeValue(userIdDeleted: selectedUserId)
                        }
                    }
                   return
                }
                self.presentAlertController(title: errorTitle, message: error.localizedDescription, delegate: self, completion: nil)
            }
        }
    }
    
    @IBAction func save(_ sender: Any) {
        guard let userId = user?.id else {
            return
        }
        if let type = user?.type {
            dic["type"] = type
        }
        if posIdAsigned.count > 0 {
            dic["localAutorized"] = posIdAsigned
        }
        
        ServiceManager().updateSpecificUser(info: dic, userId: userId) { (error) in
            guard let error = error else {
                self.presentAlertController(title: success, message: "Usuario actualizado!", delegate: self) { (action) in
                    self.dismiss(animated: true, completion: nil)
                }
                return
            }
            self.presentAlertController(title: errorTitle, message: error.localizedDescription, delegate: self, completion: nil)
        }
    }
    
}
