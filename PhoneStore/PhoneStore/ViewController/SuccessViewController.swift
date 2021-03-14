//
//  SuccessViewController.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 14/03/2021.
//

import UIKit
import Lottie

final class SuccessViewController: UIViewController {
    
    @IBOutlet weak var newSaleButton: UIButton!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    enum Result {
        case success, failure
    }
    var result: Result = .success
    private let successAnimationView = AnimationView(name: "success")
    private let failureAnimationView = AnimationView(name: "fail")

    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialView()
        topConstraint.constant = 1000
    }
    
    private func setupInitialView() {
        navigationController?.setNavigationBarHidden(true, animated: true)
        view.layer.insertSublayer(createCustomGradiend(view: view), at: 0)
        newSaleButton.layer.insertSublayer(createCustomGradiend(view: newSaleButton), at: 0)
        newSaleButton.addShadow(offset: .zero, color: .black, radius: 4, opacity: 0.4)
        newSaleButton.isHidden = true
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
    
    private func setupViewAfterSuccessAnimation(animationView: AnimationView) {
        UIView.animate(withDuration: 0.4) {
            let safearea = self.view.safeAreaInsets.top
            animationView.frame.origin.y = safearea
            animationView.frame.origin.x = (self.view.bounds.size.width - animationView.frame.size.width) / 2.0
            self.view.layoutIfNeeded()
        } completion: { (success) in
            UIView.animate(withDuration: 0.4) {
                self.newSaleButton.isHidden = false
                self.topConstraint.constant = 160
                self.view.layoutIfNeeded()
            } completion: { (finish) in
                
            }
        }
    }
    
    private func setupViewAfterFailureAnimation(animationView: AnimationView) {
        
    }
    
    private func setupSuccessView() {
        configureAnimation(animationView: successAnimationView)
    }
    
    private func setupFailureView() {
        configureAnimation(animationView: failureAnimationView)
    }
    
    private func configureAnimation(animationView: AnimationView) {
        animationView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        animationView.center = self.view.center
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        animationView.animationSpeed = 0.8
        view.addSubview(animationView)
        
        animationView.play { (finish) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if self.result == .success {
                    self.setupViewAfterSuccessAnimation(animationView: animationView)
                } else {
                    self.setupViewAfterFailureAnimation(animationView: animationView)
                }
            }
        }
    }

}
