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
    
    func generateImpactWhenTouch() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    func setupBackButton(target: Selector?) -> UIBarButtonItem {
        let newBackButton = UIBarButtonItem(barButtonSystemItem: .close,
                                            target: self,
                                            action:target)
        newBackButton.tintColor = .black
        return newBackButton
    }
    
    func setupRightButton(target: Selector?) -> UIBarButtonItem {
        setupBackButton(target: target)
    }
    
    func clearNavBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.tintColor = .black
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
