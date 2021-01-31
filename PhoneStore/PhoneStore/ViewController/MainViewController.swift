//
//  MainViewController.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 26/01/2021.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class MainViewController: UIViewController {
    
    @IBOutlet weak var welcomeLabel: UILabel!

    var userId: String = ""
    var user: UserModel?
    var dataBaseRef: DatabaseReference!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Use to need clear DB info
        //let realm = try! Realm()
        //try! realm.write {
        //    realm.deleteAll()
        //}
        setupUserByID(id: userId)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.leftBarButtonItem = setupBackButton(target: #selector(logOutTapped))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.hidesBackButton = false
        dataBaseRef.removeAllObservers()
    }
    
    private func setupUserByID(id: String) {
        dataBaseRef = Database.database().reference().child(id)
        dataBaseRef.observeSingleEvent(of: .value) { (snapshot) in
            if let userDic = snapshot.value as? Dictionary<String , Any> {
                let userLogged = UserModel(JSON: userDic)
                self.prepareViewByUser(user: userLogged)
            }
        }
    }
    
    private func prepareViewByUser(user: UserModel?) {
        self.user = user
        if user?.type == UserType.admin.rawValue {
            setupAdminView()
        } else {
            setupVendorViewByPOSView()
        }
    }
    
    private func setupAdminView() {
        
    }
    
    private func setupVendorViewByPOSView() {

    }
    
    
    @IBAction func goToSettings(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "goToSettings", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueId = segue.identifier,
           segueId == "goToList",
           let listViewController = segue.destination as? ListViewController {
            
        }
        
        if let segueId = segue.identifier,
           segueId == "goToSettings",
           let settingsVC = segue.destination as? SettingsViewController {
            if self.user?.type == UserType.admin.rawValue {
                settingsVC.userTypeView = .admin
            } else {
                settingsVC.userTypeView = .vendor
            }
        }
    }
    
    @objc func logOutTapped() {
        do { try Auth.auth().signOut() }
        catch { print("already logged out") }
        
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction @objc func logOut(_ sender: Any) {
        logOutTapped()
    }
}

extension UIViewController {
    func setupBackButton(target: Selector?) -> UIBarButtonItem {
        let newBackButton = UIBarButtonItem(barButtonSystemItem: .close,
                                            target: self,
                                            action:target)
        newBackButton.tintColor = .black
        return newBackButton
    }
    
    func setupRightButton(target: Selector?) -> UIBarButtonItem {
        setupBackButton(target: target)
    }
    
}
