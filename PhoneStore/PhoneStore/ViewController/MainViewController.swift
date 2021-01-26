//
//  MainViewController.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 26/01/2021.
//

import UIKit
import FirebaseDatabase

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
        super.viewDidLoad()
        if let username = user?.username {
            welcomeLabel.text = "Bienvenido \(username)"
        }
        celButton.tag = 0
        accesoriesButton.tag = 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataBaseRef = Database.database().reference()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dataBaseRef.removeAllObservers()
    }
    
    func getData() {
        let type = showType == .accesories ? "accesories" : "iphone"
        dataBaseRef.child("data").child(type).observeSingleEvent(of: .value) { (snapshot) in
            if let array = snapshot.value as? [[String : AnyObject]] {
                self.cels.removeAll()
                self.acces.removeAll()
                
                    for object in array {
                        if self.showType == .phones {
                            if let cel = PhoneModel(JSON: object) {
                                self.cels.append(cel)
                            }
                        } else {
                            if let access = ReplacementModel(JSON: object) {
                                self.acces.append(access)
                            }
                        }
                    }
            }
            
            self.performSegue(withIdentifier: "goToList", sender: nil)
        }
    }
    
    @IBAction func goToList(_ sender: UIButton) {
        if sender.tag == 0 {
            showType = .phones
        } else {
            showType = .accesories
        }
        getData()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueId = segue.identifier,
           segueId == "goToList",
           let listViewController = segue.destination as? ListViewController {
            listViewController.showType = self.showType
            listViewController.acces = self.acces
            listViewController.cels = self.cels
        }
    }
}
