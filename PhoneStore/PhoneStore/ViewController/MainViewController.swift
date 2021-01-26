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
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let username = user?.username {
            welcomeLabel.text = "Bienvenido \(username)"
        }
    }
    
    @IBAction func goToList(_ sender: Any) {
        performSegue(withIdentifier: "goToList", sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueId = segue.identifier,
           segueId == "goToList",
           let _ = segue.destination as? ListViewController {
        
        }
    }
}
