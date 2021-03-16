//
//  UIView+Gradient.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 12/03/2021.
//
import UIKit

extension UIViewController {
    func createCustomGradiend(view: UIView) -> CAGradientLayer{
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor.systemIndigo.cgColor, UIColor.systemTeal.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        return gradientLayer
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func createDefaultAlert(title: String, message:String, completion: ((UIAlertAction) -> Void)?) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: completion)
        alert.addAction(action)
        
        return alert
    }
    
    func presentAlertController(title: String, message:String, delegate: UIViewController, completion: ((UIAlertAction) -> Void)?) {
        let alert = createDefaultAlert(title: title, message: message, completion: completion)
        
        delegate.present(alert, animated: true, completion: nil)
    }
    
    func presentAlertControllerWithCancel(title: String, message:String, delegate: UIViewController, completion: ((UIAlertAction) -> Void)?) {
        let alert = createDefaultAlert(title: title, message: message, completion: completion)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        delegate.present(alert, animated: true, completion: nil)
    }
    
    func presentAlertControllerWithDoubleAction(title: String, message:String, delegate: UIViewController, completionSuccess: ((UIAlertAction) -> Void)?, completionFailed: ((UIAlertAction) -> Void)?) {
        let alert = createDefaultAlert(title: title, message: message, completion: completionSuccess)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: completionFailed)
        alert.addAction(cancelAction)
        
        delegate.present(alert, animated: true, completion: nil)
    }
    
    
    func generateImpactWhenTouch() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    func setupBackButton(target: Selector?) -> UIBarButtonItem {
        let newBackButton = UIBarButtonItem(barButtonSystemItem: .close,
                                            target: self,
                                            action:target)
        newBackButton.tintColor = .white
        return newBackButton
    }
    
    func setupRightButton(target: Selector?) -> UIBarButtonItem {
        setupBackButton(target: target)
    }
    
    func clearNavBar() {
        navigationController?.navigationBar.barTintColor = .systemIndigo
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .white
        
        navigationController?.navigationBar.layer.masksToBounds = false
        navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        navigationController?.navigationBar.layer.shadowOpacity = 0.4
        navigationController?.navigationBar.layer.shadowOffset = .zero
        navigationController?.navigationBar.layer.shadowRadius = 4
    }
    
    func setNavTitle(title: String) {
        let string = title
        let titleLbl = UILabel()
        let titleLblColor = UIColor.white
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Medium", size: 15)!,
                                                         NSAttributedString.Key.foregroundColor: titleLblColor]
        titleLbl.attributedText = NSAttributedString(string: string, attributes: attributes)
        titleLbl.sizeToFit()
        
        navigationItem.titleView = titleLbl
    }
    
}

extension UIView {
    func addShadow(offset: CGSize, color: UIColor, radius: CGFloat, opacity: Float) {
        layer.masksToBounds = false
        layer.shadowOffset = offset
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity

        let backgroundCGColor = backgroundColor?.cgColor
        backgroundColor = nil
        layer.backgroundColor =  backgroundCGColor
    }
    

    
}

extension String {
    static let numberFormatter = NumberFormatter()
    var doubleValue: Double {
        String.numberFormatter.decimalSeparator = "."
        if let result =  String.numberFormatter.number(from: self) {
            return result.doubleValue
        } else {
            String.numberFormatter.decimalSeparator = ","
            if let result = String.numberFormatter.number(from: self) {
                return result.doubleValue
            }
        }
        return 0
    }
}
