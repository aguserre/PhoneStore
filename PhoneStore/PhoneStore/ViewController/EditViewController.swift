//
//  EditViewController.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 24/04/2021.
//

import UIKit

final class EditViewController: UIViewController {
    
    @IBOutlet weak var typeEditSegmentedControl: UISegmentedControl!
    @IBOutlet weak var posCollectionView: UICollectionView!
    enum EditType: Int {
        case pos = 0
        case user
    }
    var type: EditType = .pos
    var users = [UserModel]()
    var posFullList: [PointOfSale]?
    let cellScale: CGFloat = 0.5


    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupCollectionDelegates()
        getUsers()
    }
    
    private func setupView() {
        setNavTitle(title: "Editar Punto de venta")
        view.layer.insertSublayer(createCustomGradiend(view: view), at: 0)
    }
    
    private func setupCollectionDelegates() {
        posCollectionView.delegate = self
        posCollectionView.dataSource = self
    }
    
    private func getUsers() {
        ServiceManager().getUsersList { (users) in
            if let users = users {
                self.users = users
            }
        }
    }
    
    private func presentAlertBeforeDelete(index: IndexPath) {
        switch type {
        case .pos:
            deletePos(atIndex: index)
        default:
            print("")
        }
        
        
    }
    
    private func deletePos(atIndex: IndexPath) {
        guard let selectedPos = posFullList?[atIndex.row].id else {
            return
        }
        presentAlertControllerWithCancel(title: "Seguro desea eliminar el Punto de Venta?", message: "Se borrará por completo el POS seleccionado y sus productos asociados", delegate: self) { (completion) in
            ServiceManager().deleteSpecificPOS(id: selectedPos) { (error) in
                guard let error = error else {
                    self.posFullList?.remove(at: atIndex.row)
                    self.posCollectionView.reloadItems(at: [atIndex])
                    return
                }
                
                self.presentAlertController(title: errorTitle, message: error.localizedDescription, delegate: self, completion: nil)
            }
            
        }
    }
    
    private func deleteUser(atIndex: IndexPath) {
        guard let selectedUserId = users[atIndex.row].id else {
            return
        }
        presentAlertControllerWithCancel(title: "Seguro desea eliminar el usuario?", message: "Se borrará por completo el usuario seleccionado", delegate: self) { (completion) in
            ServiceManager().deleteSpecificUser(id: selectedUserId) { (error) in
                guard let error = error else {
                    self.users.remove(at: atIndex.row)
                    self.posCollectionView.reloadItems(at: [atIndex])
                    self.presentAlertControllerWithCancel(title: success, message: "Se borró con éxito el usuario.\nPara crear un usuario con el mismo email, deberá contactar con soporte", delegate: self, completion: nil)
                   return
                }
                self.presentAlertController(title: errorTitle, message: error.localizedDescription, delegate: self, completion: nil)
            }
        }
        
    }
    
    @IBAction func segmentdChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            type = .pos
        default:
            type = .user
        }
        posCollectionView.reloadData()
    }
    
}

extension EditViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      presentAlertBeforeDelete(index: indexPath)
    }
}

extension EditViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return type == .pos ? posFullList?.count ?? 1 : users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EditCollectionViewCell", for: indexPath) as! EditCollectionViewCell
        
        switch type {
        case .pos:
            guard let posList = posFullList?[indexPath.row] else {
                return cell
            }
            cell.setupCell(pos: posList)
        default:
            cell.setupCell(user: users[indexPath.row])
        }
        
        cell.contentView.layer.cornerRadius = 15
        cell.addShadow(offset: .zero, color: .black, radius: 4, opacity: 0.4)
        
        return cell
    }
    
}

extension EditViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width * cellScale - 20
        let height = width
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}
