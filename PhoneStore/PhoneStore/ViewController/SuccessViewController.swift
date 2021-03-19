//
//  SuccessViewController.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 14/03/2021.
//

import UIKit
import Lottie

final class SuccessViewController: UIViewController {
    
    @IBOutlet private weak var newSaleButton: UIButton!
    @IBOutlet private weak var topConstraint: NSLayoutConstraint!
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var docTextField: UITextField!
    @IBOutlet private weak var phoneTextField: UITextField!
    @IBOutlet private weak var cancelSaveButton: UIButton!
    @IBOutlet private weak var buttonHeightConstraint: NSLayoutConstraint!
    
    enum Result {
        case success, failure
    }
    enum ButtonTitle: Int {
        case failure, newSale, saveUser
    }
    var clientExist: ClientModel?
    var buttonTitle: ButtonTitle = .newSale
    var result: Result = .success
    var products: [ProductModel]?
    var amount: Double?
    private let serviceManager = ServiceManager()
    private let successAnimationView = AnimationView(name: "success")
    private let failureAnimationView = AnimationView(name: "fail")

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        setupInitialView()
        topConstraint.constant = 1000
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func setupInitialView() {
        navigationController?.setNavigationBarHidden(true, animated: true)
        view.layer.insertSublayer(createCustomGradiend(view: view), at: 0)
        newSaleButton.layer.insertSublayer(createCustomGradiend(view: newSaleButton), at: 0)
        newSaleButton.addShadow(offset: .zero, color: .black, radius: 4, opacity: 0.4)
        buttonHeightConstraint.constant = 0
        setupViewWithResult(result: result)
    }
    
    private func setupViewWithResult(result: Result) {
        switch result {
        case .success:
            setupSuccessView()
        case .failure:
            setupFailureView()
        }
    }
    
    private func setupSuccessView() {
        configureAnimation(animationView: successAnimationView)
    }
    
    private func setupFailureView() {
        configureAnimation(animationView: failureAnimationView)
    }
    
    private func configureAnimation(animationView: AnimationView) {
        animationView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        animationView.center = self.view.center
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        animationView.animationSpeed = 0.8
        view.addSubview(animationView)
        
        animationView.play { (finish) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if self.result == .success {
                    self.setupViewAfterSuccessAnimation(animationView: animationView)
                } else {
                    self.setupViewAfterFailureAnimation(animationView: animationView)
                }
            }
        }
    }
    
    private func setupViewAfterSuccessAnimation(animationView: AnimationView) {
        UIView.animate(withDuration: 0.4) {
            let safearea = self.view.safeAreaInsets.top
            animationView.frame.origin.y = safearea
            animationView.frame.origin.x = (self.view.bounds.size.width - animationView.frame.size.width) / 2.0
            self.view.layoutIfNeeded()
        } completion: { (success) in
            self.expandDataClient()
        }
    }
    
    private func setupViewAfterFailureAnimation(animationView: AnimationView) {
        checkButtonTitle(title: .failure)
        UIView.animate(withDuration: 0.4) {
            self.buttonHeightConstraint.constant = 70
            self.view.layoutIfNeeded()
        }
    }
    
    private func expandDataClient() {
        checkButtonTitle(title: .saveUser)
        UIView.animate(withDuration: 0.4) {
            self.cancelSaveButton.layer.cornerRadius = 15
            self.cancelSaveButton.addShadow(offset: .zero, color: .black, radius: 4, opacity: 0.4)
            self.buttonHeightConstraint.constant = 70
            self.topConstraint.constant = 200
            self.view.layoutIfNeeded()
        }
    }
    
    private func hideDataClient() {
        UIView.animate(withDuration: 0.4) {
            self.topConstraint.constant = 1000
            self.buttonHeightConstraint.constant = 0
            self.successAnimationView.center = self.view.center
            self.view.layoutIfNeeded()
        } completion: { (finish) in
            UIView.animate(withDuration: 0.4) {
                self.buttonHeightConstraint.constant = 70
                self.view.layoutIfNeeded()
            }
        }
    }
    
    private func checkClientExist() {
        guard let clientDoc = docTextField.text, clientDoc.count > 6 && clientDoc.count < 9 else {
            presentAlertController(title: "Error", message: "El campo documento debe tener un formato valido", delegate: self, completion: nil)
            return
        }
        let clientDocInt = Int(clientDoc) ?? 0
        serviceManager.checkClientExist(clientDoc: clientDocInt) { (client) in
            if client != nil {
                self.presentAlertController(title: "Usuario existente", message: "", delegate: self) { (action) in
                    self.clientExist = client
                    self.dontSaveClient(animationShowing: self.successAnimationView)
                }
            } else {
                self.createClient(document: clientDocInt)
            }
        }
    }
    
    private func createClient(document: Int) {
        let clientDic: [String : Any] = ["name" : nameTextField.text ?? "",
                                         "document" : document as Any,
                                         "phone" : phoneTextField.text ?? ""]
        if let client = ClientModel(JSON: clientDic) {
            saveClient(client: client)
        }
    }
    
    private func saveClient(client: ClientModel) {
        generateSaleMovement(client: client)
        serviceManager.saveClient(client: client) { (client, error) in
            if let error = error {
                self.presentAlertController(title: "Error", message: error.localizedDescription, delegate: self, completion: nil)
            } else {
                self.presentAlertController(title: "Exito!", message: "Usuario guardado con exito", delegate: self) { (action) in
                    self.checkButtonTitle(title: .newSale)
                    self.hideDataClient()
                }
            }
        }
    }
    
    private func dontSaveClient(animationShowing: AnimationView) {
        generateSaleMovement(client: clientExist)
        checkButtonTitle(title: .newSale)
        hideDataClient()
    }
    
    private func generateSaleMovement(client: ClientModel?) {
        if let prods = products {
            serviceManager.registerSaleMov(client: client, prods: prods, movType: .out)
        }
    }
    
    private func checkButtonTitle(title: ButtonTitle) {
        switch title {
        case .saveUser:
            buttonTitle = .saveUser
            newSaleButton.setTitle("Guardar", for: .normal)
        case .newSale:
            buttonTitle = .newSale
            newSaleButton.setTitle("Nueva venta", for: .normal)
        case .failure:
            buttonTitle = .failure
            newSaleButton.setTitle("Intentar de nuevo", for: .normal)
        }
    }
    
    @IBAction func cancelSaveClient(_ sender: Any) {
        dontSaveClient(animationShowing: successAnimationView)
    }
    
    @IBAction func goToMain(_ sender: Any) {
        switch buttonTitle {
        case .saveUser:
            checkClientExist()
        case .newSale:
            performSegue(withIdentifier: "unwindToMain", sender: self)
        case .failure:
            performSegue(withIdentifier: "unwindToMain", sender: self)
        }
    }
}

