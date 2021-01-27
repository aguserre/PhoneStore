//
//  DetailViewController.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 26/01/2021.
//

import UIKit
import FirebaseDatabase

class DetailViewController: UIViewController {

    var selectedPhone: PhoneModel?
    var selectedAccesorie: ReplacementModel?
    var showType: ShowType = .phones
    var dataBaseRef: DatabaseReference!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        if let p = selectedPhone {
            print(p.toJSON())
        }
        if let a = selectedAccesorie {
            print(a.toJSON())
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    @IBAction func deleteProduct(_ sender: Any) {
        let type = showType == .accesories ? "accesories" : "iphone"
        dataBaseRef = Database.database().reference().child("data")
        dataBaseRef.child(type).observeSingleEvent(of: .value) { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    for snap in snapshot {
                        if let postDict = snap.value as? Dictionary<String, AnyObject> {
                                if self.selectedPhone?.id == postDict["id"] as? String {
                                    self.dataBaseRef.child(type).child(snap.key).removeValue(completionBlock: { (error, ref) in
                                        if error != nil {
                                            print("Error: \(String(describing: error))")
                                            return
                                        }
                                        print("Removed successfully")
                                    })
                                }
                        } else {
                            print("Zhenya: failed to convert")
                        }
                    }
                }
        }
    }
}
