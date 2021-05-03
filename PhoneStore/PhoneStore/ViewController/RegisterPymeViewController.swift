//
//  RegisterPymeViewController.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 03/04/2021.
//

import UIKit
import MessageUI

final class RegisterPymeViewController: UIViewController {
    
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var cuilTextField: UITextField!
    @IBOutlet private weak var email: UITextField!
    @IBOutlet private weak var descripTextField: UITextField!
    @IBOutlet private weak var localizedTextField: UITextField!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var backGroundView: UIView!
    @IBOutlet private weak var sendInfoButton: UIButton!
    
    private var dicPyme: [String : Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        setupObservers()
        view.layer.insertSublayer(createCustomGradiend(view: view), at: 0)
        sendInfoButton.layer.insertSublayer(createCustomGradiend(view: sendInfoButton), at: 0)
        sendInfoButton.addShadow(offset: .zero, color: .black, radius: 4, opacity: 0.4)
        backGroundView.layer.cornerRadius = 10
        backGroundView.addShadow(offset: .zero, color: .black, radius: 4, opacity: 0.4)
    }
   
    private func randomString(length: Int) -> String {
      let letters = lettersCombinations
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    @IBAction private func add(_ sender: UIButton) {
        if validateTexts() {
            dicPyme["id"] = randomString(length: 22)
            showMailComposer()
        }
    }
    private func validateTexts() -> Bool {
        var validatedSuccess = false
        if let name = nameTextField.text, name.count > 2 {
            dicPyme["name"] = name
            validatedSuccess = true
        } else {
            presentAlertController(title: errorTitle, message: "El nombre debe contener al menos 3 letras", delegate: self, completion: nil)
            validatedSuccess = false
        }
        if let cuil = cuilTextField.text, cuil.count == 11 {
            dicPyme["cuil"] = cuil
            validatedSuccess = true
        } else {
            presentAlertController(title: errorTitle, message: "El CUIL debe ser de 11 digitos", delegate: self, completion: nil)
            validatedSuccess = false
        }
        if let email = email.text, email.contains("@"), email.contains(".") {
            dicPyme["contact"] = email
            validatedSuccess = true
        } else {
            presentAlertController(title: errorTitle, message: "Formato inválido de email", delegate: self, completion: nil)
            validatedSuccess = false
        }
        if let desc = descripTextField.text, desc.count > 9 {
            dicPyme["description"] = desc
            validatedSuccess = true
        } else {
            presentAlertController(title: errorTitle, message: "Debe agregar una descripcion de al menos 10 caracteres", delegate: self, completion: nil)
            validatedSuccess = false
        }
        
        if let localized = localizedTextField.text, localized.count > 0 {
            dicPyme["localized"] = localized
            validatedSuccess = true
        } else {
            presentAlertController(title: errorTitle, message: "Debe especificar una ubicación", delegate: self, completion: nil)
            validatedSuccess = false
        }
        
        return validatedSuccess
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name:UIResponder.keyboardWillHideNotification, object: nil)
        hideKeyboardWhenTappedAround()
    }
    
    @objc private func keyboardWillShow(notification:NSNotification) {
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: backGroundView.frame.size.height + keyboardFrame.height)

        UIView.animate(withDuration: 0.3, delay: 0.5) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    @objc private func keyboardWillHide(notification:NSNotification) {
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height - keyboardFrame.height/2)
        UIView.animate(withDuration: 1, delay: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func showMailComposer() {
        guard MFMailComposeViewController.canSendMail() else {
            presentAlertController(title: errorTitle, message: pymeRegistrationError, delegate: self, completion: nil)
            return
        }
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients([emailSupport])
        composer.setSubject("Solicitud nueva iPyme \(dicPyme["name"] ?? "")")
        composer.setMessageBody("Name: \(dicPyme["name"] ?? "") \nCUIL: \(dicPyme["cuil"] ?? "")\nLocalized: \(dicPyme["localized"] ?? "")\nContact: \(dicPyme["contact"] ?? "")\nid: \(dicPyme["id"] ?? "")\n Description: \(dicPyme["description"] ?? "")\n", isHTML: false)
        present(composer, animated: true)
    }
    
}

extension RegisterPymeViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let _ = error {
            controller.dismiss(animated: true) {
                self.presentAlertController(title: errorTitle, message: pymeRegistrationError, delegate: self, completion: nil)
            }
            return
        }
        switch result {
        case .cancelled:
            controller.dismiss(animated: true, completion: nil)
        case .failed:
            controller.dismiss(animated: true) {
                self.presentAlertController(title: errorTitle, message: pymeRegistrationError, delegate: self) { (action) in
                    self.dismiss(animated: true, completion: nil)
                }
            }
        case .saved:
            controller.dismiss(animated: true, completion: nil)
        case .sent:
            controller.dismiss(animated: true) {
                self.presentAlertController(title: success, message: pymeRegistrationSuccess, delegate: self) { (action) in
                    self.dismiss(animated: true, completion: nil)
                }
            }
        @unknown default:
            break
        }
    }
}
