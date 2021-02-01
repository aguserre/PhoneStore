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
    @IBOutlet weak var headerView: UIView!
    private var userId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [UIColor.systemIndigo.cgColor, UIColor.systemTeal.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
        let blur = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame = self.view.bounds
        view.insertSubview(blurView, at: 0)
        
        let gradientLayer2 = CAGradientLayer()
        gradientLayer2.frame = self.headerView.bounds
        gradientLayer2.colors = [UIColor.systemIndigo.cgColor,  UIColor.systemTeal.cgColor]
        gradientLayer2.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer2.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.headerView.layer.insertSublayer(gradientLayer2, at: 0)
        
        let shadowSize: CGFloat = 20
        let contactRect = CGRect(x: -shadowSize, y: headerView.bounds.height - (shadowSize * 0.4), width: headerView.bounds.width + shadowSize * 2, height: shadowSize)
        headerView.layer.shadowPath = UIBezierPath(ovalIn: contactRect).cgPath
        headerView.layer.shadowRadius = 4
        headerView.layer.shadowOpacity = 0.2
        
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
