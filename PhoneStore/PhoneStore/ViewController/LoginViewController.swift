//
//  LoginViewController.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 26/01/2021.
//

import UIKit
import SkeletonView

final class LoginViewController: UIViewController {
    
    @IBOutlet private weak var userTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var loginButtonConstant: NSLayoutConstraint!
    @IBOutlet private weak var backgroundView: UIView!
    
    private let serviceManager = ServiceManager()
    private var userId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        skeletonSetup()
        setupObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name:UIResponder.keyboardWillHideNotification, object: nil)
        hideKeyboardWhenTappedAround()
    }
    
    private func setupView() {
        view.layer.insertSublayer(createCustomGradiend(view: view), at: 0)
        loginButton.layer.insertSublayer(createCustomGradiend(view: loginButton), at: 0)
        
        backgroundView.addShadow(offset: .zero, color: .systemIndigo, radius: 6, opacity: 0.4)
        loginButton.addShadow(offset: .zero, color: .black, radius: 4, opacity: 0.4)

        backgroundView.layer.cornerRadius = 20
    }
    
    private func skeletonSetup() {
        userTextField.isSkeletonable = true
        userTextField.skeletonCornerRadius = 10
        passwordTextField.isSkeletonable = true
        passwordTextField.skeletonCornerRadius = 10
        loginButton.isSkeletonable = true
    }
    
    @IBAction @objc func checkUser(_ sender: Any) {
        generateImpactWhenTouch()
        userTextField.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .systemIndigo), animation: nil, transition: .crossDissolve(0.5))
        passwordTextField.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .systemIndigo), animation: nil, transition: .crossDissolve(0.5))
        loginButton.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .systemIndigo), animation: nil, transition: .crossDissolve(0.5))
        guard let username = userTextField.text,
              let pass = passwordTextField.text else {
            userTextField.hideSkeleton()
            passwordTextField.hideSkeleton()
            loginButton.hideSkeleton()
            return
        }
        
        serviceManager.login(user: username, password: pass) { (auth, error) in
            if let user = auth?.user {
                self.userId = user.uid
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.userTextField.hideSkeleton()
                    self.passwordTextField.hideSkeleton()
                    self.loginButton.hideSkeleton()
                    self.performSegue(withIdentifier: "goToMain", sender: nil)
                }
            }
            if let error = error {
                self.presentAlertController(title: errorTitle, message: error.localizedDescription, delegate: self) { (action) in
                    self.userTextField.hideSkeleton()
                    self.passwordTextField.hideSkeleton()
                    self.loginButton.hideSkeleton()
                }
            }
        }
    }
    
    @objc private func keyboardWillShow(notification:NSNotification) {
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        self.loginButtonConstant.constant = keyboardFrame.height + 50
        UIView.animate(withDuration: 0.3, delay: 0.5) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    @objc private func keyboardWillHide(notification:NSNotification){
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
