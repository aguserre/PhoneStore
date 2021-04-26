//
//  LoginViewController.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 26/01/2021.
//

import UIKit
import SkeletonView
import FirebaseAuth
import LocalAuthentication

final class LoginViewController: UIViewController {
    
    @IBOutlet private weak var userTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var loginButtonConstant: NSLayoutConstraint!
    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var lostPasswordButton: UIButton!
    @IBOutlet private weak var registerPymeButton: UIButton!
    
    private let serviceManager = ServiceManager()
    private var userId = ""
    let context = LAContext()
    var error: NSError? = nil
    let canUseApp = KeysValues().canUseApp
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        guard canUseApp else {
            return
        }
        checkIfNewUser()
        setupObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        guard canUseApp else {
            return
        }
        if let userLogged = KeysValues().userId {
            userId = userLogged
            setupEmptyViewBeforeNavigation()
        } else {
            showViews()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func checkIfNewUser() {
        if Core.shared.isNewUser() {
            let vc = storyboard?.instantiateViewController(identifier: "Onboarding") as! PyMeOnboardingViewController
            present(vc, animated: true, completion: nil)
        }
    }
    
    private func showViews() {
        backgroundView.isHidden = false
        loginButton.isHidden = false
        lostPasswordButton.isHidden = false
        registerPymeButton.isHidden = false
    }
    
    private func setupEmptyViewBeforeNavigation() {
        backgroundView.isHidden = true
        loginButton.isHidden = true
        lostPasswordButton.isHidden = true
        registerPymeButton.isHidden = true
        
        beingIdentity()
    }
    
    private func beingIdentity() {
        var error:NSError?
        
        guard self.context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error) else{
            return print(error!)
        }

        let reason = "Identity yourselt to countinue"
        
        self.context.evaluatePolicy(LAPolicy.deviceOwnerAuthentication, localizedReason: reason) { (isSuccess, error) in
            DispatchQueue.main.async {
                if isSuccess {
                    self.performSegue(withIdentifier: "goToMain", sender: nil)
                }else{
                    self.showLAError(laError: error!)
                    self.serviceManager.forceLogOut()
                    self.showViews()
                }
            }
        }
    }
    
    private func showLAError(laError: Error) -> Void {
        var message = ""
        switch laError {
        case LAError.appCancel:
            message = "Authentication was cancelled by application"
        case LAError.authenticationFailed:
            message = "The user failed to provide valid credentials"
        case LAError.invalidContext:
            message = "The context is invalid"
        case LAError.passcodeNotSet:
            message = "Passcode is not set on the device"
        case LAError.systemCancel:
            message = "Authentication was cancelled by the system"
        case LAError.biometryLockout:
            message = "Too many failed attempts."
            case LAError.biometryNotAvailable:
            message = "TouchID is not available on the device"
        case LAError.userCancel:
            message = "The user did cancel"
        case LAError.userFallback:
            message = "The user chose to use the fallback"
        default:
            if #available(iOS 11.0, *) {
                switch laError {
                case LAError.biometryNotAvailable:
                    message = "Biometry is not available"
                case LAError.biometryNotEnrolled:
                    message = "Authentication could not start, because biometry has no enrolled identities"
                case LAError.biometryLockout:
                    message = "Biometry is locked. Use passcode."
                default:
                    message = "Did not find error code on LAError object"
                }
            }else{
                message = "Did not find error code on LAError object"
            }
        }
        
        NSLog("LAError message - \(message)", self)
    }
    
    private func setupObservers() {
        hideKeyboardWhenTappedAround()
    }
    
    private func setupView() {
        showViews()
        skeletonSetup()
        view.layer.insertSublayer(createCustomGradiend(view: view), at: 0)
        loginButton.layer.insertSublayer(createCustomGradiend(view: loginButton), at: 0)
        registerPymeButton.layer.cornerRadius = 10
        registerPymeButton.addShadow(offset: .zero, color: .black, radius: 4, opacity: 0.4)
        backgroundView.addShadow(offset: .zero, color: .systemIndigo, radius: 4, opacity: 0.4)
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
        guard canUseApp else {
            presentAlertController(title: errorTitle, message: "Actualice la app para continuar", delegate: self, completion: nil)
            return
        }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueId = segue.identifier,
           segueId == "goToMain",
           let mainViewController = segue.destination as? MainViewController {
            mainViewController.userId = self.userId
        }
    }
    
    @IBAction private func verifyEmailButtonTapped(_ sender: UIButton) {
        guard let email = userTextField.text else {
            presentAlertController(title: errorTitle, message: "", delegate: self, completion: nil)
            return
        }
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                self.presentAlertController(title: errorTitle, message: error.localizedDescription, delegate: self, completion: nil)
            } else {
                self.presentAlertController(title: success, message: "Se envio un correo a la direccion \(email)", delegate: self, completion: nil)
            }
        }
    }
    
    @IBAction private func registerPyme(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(identifier: "RegisterPymeViewController") as! RegisterPymeViewController
        present(vc, animated: true, completion: nil)
    }
}
