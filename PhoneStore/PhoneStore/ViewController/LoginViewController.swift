//
//  LoginViewController.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 26/01/2021.
//

import UIKit
import FirebaseAuth
import SkeletonView

class LoginViewController: UIViewController {
    
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginButtonConstant: NSLayoutConstraint!
    @IBOutlet weak var backgroundView: UIView!
    
    private var userId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        skeletonSetup()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name:UIResponder.keyboardWillHideNotification, object: nil)
        
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
        headerView.addShadow(offset: .zero, color: .black, radius: 4, opacity: 0.4)
        
        backgroundView.layer.cornerRadius = 20
        backgroundView.addShadow(offset: .zero, color: .systemIndigo, radius: 6, opacity: 0.4)
        
        loginButton.addShadow(offset: .zero, color: .black, radius: 4, opacity: 0.4)
        
        let gradientLayer3 = CAGradientLayer()
        gradientLayer3.frame = self.loginButton.bounds
        gradientLayer3.colors = [UIColor.systemIndigo.cgColor,  UIColor.systemTeal.cgColor]
        gradientLayer3.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer3.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.loginButton.layer.insertSublayer(gradientLayer3, at: 0)
        
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
    
    func skeletonSetup() {
        userTextField.isSkeletonable = true
        userTextField.skeletonCornerRadius = 10
        passwordTextField.isSkeletonable = true
        passwordTextField.skeletonCornerRadius = 10
        loginButton.isSkeletonable = true
    }
    
    @IBAction @objc func checkUser(_ sender: Any) {
        userTextField.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .systemIndigo), animation: nil, transition: .crossDissolve(0.5))
        passwordTextField.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .systemIndigo), animation: nil, transition: .crossDissolve(0.5))
        loginButton.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .systemIndigo), animation: nil, transition: .crossDissolve(0.5))
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        guard let username = userTextField.text,
              let pass = passwordTextField.text else {
            userTextField.hideSkeleton()
            passwordTextField.hideSkeleton()
            loginButton.hideSkeleton()
            return
        }
        
        Auth.auth().signIn(withEmail: username.lowercased(), password: pass) { (auth, error) in
            if let user = auth?.user {
                self.userId = user.uid
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.userTextField.hideSkeleton()
                    self.passwordTextField.hideSkeleton()
                    self.loginButton.hideSkeleton()
                    self.performSegue(withIdentifier: "goToMain", sender: nil)
                }
            } else {
                //TODO: Crear alerta
                print("error login")
                self.userTextField.hideSkeleton()
                self.passwordTextField.hideSkeleton()
                self.loginButton.hideSkeleton()
            }
        }
    }
    
    @objc func keyboardWillShow(notification:NSNotification) {
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        self.loginButtonConstant.constant = keyboardFrame.height + 50
        UIView.animate(withDuration: 0.3, delay: 0.5) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        UIView.animate(withDuration: 1, delay: 0.5) {
            self.loginButtonConstant.constant = 70
            self.loginButton.addTarget(self, action: #selector(self.checkUser(_:)), for: .touchUpOutside)
            self.view.layoutIfNeeded()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueId = segue.identifier,
           segueId == "goToMain",
           let mainViewController = segue.destination as? MainViewController {
            mainViewController.userId = self.userId
        }
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
