//
//  InitialAnimationViewController.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 17/03/2021.
//

import UIKit
import Lottie

final class InitialAnimationViewController: UIViewController {
    
    private let successAnimationView = AnimationView(name: "loaderApple")
    @IBOutlet weak var aniView: UIView!
    private var needSaveCopy = false
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.insertSublayer(createCustomGradiend(view: view), at: 0)
        configureAnimation(animationView: successAnimationView)
        checkIfNeedSaveCopy()
    }
    
    private func configureAnimation(animationView: AnimationView) {
        animationView.frame = CGRect(x: 0, y: 0, width: 220, height: 220)
        animationView.center = self.view.center
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 1
        animationView.addShadow(offset: .zero, color: .systemIndigo, radius: 8, opacity: 1)
        view.addSubview(animationView)
        animationView.play()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            UIView.animate(withDuration: 0.7, delay: 0) {
                animationView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            } completion: { (finish) in
                animationView.removeFromSuperview()
                //MARK: - ADD SECURITY COPY OF DB
                self.checkIfNeedSaveCopy()
            }
        }
    }
    
    private func checkIfNeedSaveCopy() {
        let today = Date()
        let wasSavedData = defaults.bool(forKey: defaultsKeys.needSaveKey)
        
        if today == today.startOfMonth() || !wasSavedData {
            presentAlertControllerWithDoubleAction(title: "Ops!", message: "Desea guardar una copia de seguridad?", delegate: self) { (actionOk) in
                self.saveCopy()
            } completionFailed: { (actionCancel) in
                self.dontSaveCopy()
            }
        } else {
            goToLogin()
        }
    }
    
    private func saveCopy() {
        //MARK:- Save success
        defaults.set(true, forKey: defaultsKeys.needSaveKey)
        //MARK:- Save failed
        defaults.set(false, forKey: defaultsKeys.needSaveKey)
        
        goToLogin()
    }
    
    private func dontSaveCopy() {
        defaults.set(false, forKey: defaultsKeys.needSaveKey)
        goToLogin()
    }
    
    private func goToLogin() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "MainNavigationController") as! UINavigationController
        newViewController.modalPresentationStyle = .fullScreen
        self.present(newViewController, animated: true, completion: nil)
    }
}

extension Date {
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
}
struct defaultsKeys {
    static let needSaveKey = "firstStringKey"
}
