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
    private var userId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @IBAction func goToSettings(_ sender: UIButton) {
        self.performSegue(withIdentifier: "goToSettings", sender: nil)
    }
    
    @IBAction func checkUser(_ sender: Any) {
        guard let username = userTextField.text,
              let pass = passwordTextField.text else {
            return
        }
        
        Auth.auth().signIn(withEmail: username.lowercased(), password: pass) { (auth, error) in
            if let user = auth?.user {
                self.userId = user.uid
                self.performSegue(withIdentifier: "goToMain", sender: nil)
            } else {
                //TODO: Crear alerta
                print("error login")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueId = segue.identifier,
           segueId == "goToMain",
           let mainViewController = segue.destination as? MainViewController {
            mainViewController.userId = self.userId
        }
        if let segueId = segue.identifier,
           segueId == "goToSettings",
           let _ = segue.destination as? SettingsViewController { }
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
