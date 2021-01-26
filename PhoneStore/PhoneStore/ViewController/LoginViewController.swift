//
//  LoginViewController.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 26/01/2021.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var user: UserModel?
    
    @IBOutlet weak var asfefwe: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction func checkUser(_ sender: Any) {
        guard let username = userTextField.text,
              let pass = passwordTextField.text else {
            return
        }
        
        
        Auth.auth().signIn(withEmail: username, password: pass) { (auth, error) in
            if let _ = auth {
                self.performSegue(withIdentifier: "goToApp", sender: nil)
            } else {
                print("error login")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueId = segue.identifier,
           segueId == "goToApp",
           let _ = segue.destination as? UINavigationController {
            
        }
    }


}
