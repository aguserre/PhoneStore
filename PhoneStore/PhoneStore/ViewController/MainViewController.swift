//
//  MainViewController.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 26/01/2021.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import RealmSwift

class MainViewController: UIViewController {
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var celButton: UIButton!
    @IBOutlet weak var accesoriesButton: UIButton!
    var user: UserModel?
    var cels = [PhoneModel]()
    var phones: PhoneModel?
    var acces = [ReplacementModel]()
    var accesories: ReplacementModel?
    var showType: ShowType = .phones
    var dataBaseRef: DatabaseReference!

    
    override func viewDidLoad() {
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
        
        super.viewDidLoad()
        if let username = user?.username {
            welcomeLabel.text = "Bienvenido \(username)"
        }
        celButton.tag = 0
        accesoriesButton.tag = 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        dataBaseRef = Database.database().reference().child("data")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        dataBaseRef.removeAllObservers()
    }
    
    @IBAction func goToList(_ sender: UIButton) {
        if sender.tag == 0 {
            showType = .phones
        } else {
            showType = .accesories
        }
        self.performSegue(withIdentifier: "goToList", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueId = segue.identifier,
           segueId == "goToList",
           let listViewController = segue.destination as? ListViewController {
            listViewController.showType = self.showType
        }
    }
    
    @IBAction func logOut(_ sender: Any) {
        do { try Auth.auth().signOut() }
        catch { print("already logged out") }
        
        navigationController?.popToRootViewController(animated: true)
    }
}
