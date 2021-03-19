//
//  MovementDetailViewController.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 14/02/2021.
//

import UIKit
import Lottie

final class MovementDetailViewController: UIViewController {

    @IBOutlet private weak var contentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var productNameLbl: UILabel!
    @IBOutlet weak var productTypeLbl: UILabel!
    @IBOutlet weak var productLocalLbl: UILabel!
    @IBOutlet weak var productConditionLbl: UILabel!
    @IBOutlet weak var productCantitiLbl: UILabel!
    @IBOutlet weak var productDateOutLbl: UILabel!
    @IBOutlet weak var clientNameLbl: UILabel!
    @IBOutlet weak var clientDocLbl: UILabel!
    @IBOutlet weak var clientPhoneLbl: UILabel!
    @IBOutlet weak var totalLbl: UILabel!
    @IBOutlet weak var clientBackgroundView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var animationView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    
    private let serviceManager = ServiceManager()
    var mov: MovementsModel?
    var clientViewExpanded = true
    private let successAnimationView = AnimationView(name: "idScan")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        getClient()
        configureAnimation(animationView: successAnimationView)
    }
    
    private  func setupView() {
        expandClientView()
        view.layer.insertSublayer(createCustomGradiend(view: view), at: 0)
        closeButton.layer.cornerRadius = 15
        closeButton.addShadow(offset: .zero, color: .black, radius: 4, opacity: 0.4)
        productNameLbl.text = mov?.code
        productTypeLbl.text = mov?.movementType
        productLocalLbl.text = mov?.localId
        productConditionLbl.text = mov?.condition
        productCantitiLbl.text = String(mov?.cantitiPurchase ?? 1)
        productDateOutLbl.text = mov?.dateOut
        totalLbl.text = "$ "+String(mov?.totalAmount ?? 0)
        
        clientBackgroundView.layer.cornerRadius = 10
        clientBackgroundView.clipsToBounds = true
        clientBackgroundView.addShadow(offset: .zero, color: .systemIndigo, radius: 4, opacity: 0.4)
        clientBackgroundView.layer.borderWidth = 1
        clientBackgroundView.layer.borderColor = UIColor.systemIndigo.cgColor
    }
    
    @objc func expandClientView() {
        clientViewExpanded.toggle()
        if !clientViewExpanded {
            clientNameLbl.isHidden = !clientViewExpanded
            clientDocLbl.isHidden = !clientViewExpanded
            clientPhoneLbl.isHidden = !clientViewExpanded
        }
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 0, options: []) {
            self.contentViewHeightConstraint.constant = self.clientViewExpanded ? 150 : 42
            self.view.layoutIfNeeded()
            self.successAnimationView.frame = self.animationView.bounds
            self.view.layoutIfNeeded()
        } completion: { (finished) in
            self.clientNameLbl.isHidden = !self.clientViewExpanded
            self.clientDocLbl.isHidden = !self.clientViewExpanded
            self.clientPhoneLbl.isHidden = !self.clientViewExpanded
        }
    }
    
    private func getClient() {
        serviceManager.getClientById(id: mov?.client ?? 0) { (client) in
            if let client = client {
                self.clientNameLbl.text = client.name
                self.clientDocLbl.text = String(client.document ?? 0)
                self.clientPhoneLbl.text = client.phone
                let gesture = UITapGestureRecognizer(target: self, action: #selector(self.expandClientView))
                self.clientBackgroundView.addGestureRecognizer(gesture)
            } else {
                //Cliente no encontrado
            }
        }
    }
    
    private func configureAnimation(animationView: AnimationView) {
        animationView.frame = self.animationView.bounds
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 1
        animationView.addShadow(offset: .zero, color: .systemIndigo, radius: 8, opacity: 1)
        self.animationView.addSubview(animationView)
        animationView.play()
    }
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
