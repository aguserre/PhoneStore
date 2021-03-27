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
    @IBOutlet private weak var productNameLbl: UILabel!
    @IBOutlet private weak var productTypeLbl: UILabel!
    @IBOutlet private weak var productLocalLbl: UILabel!
    @IBOutlet private weak var productConditionLbl: UILabel!
    @IBOutlet private weak var productCantitiLbl: UILabel!
    @IBOutlet private weak var productDateOutLbl: UILabel!
    @IBOutlet private weak var clientNameLbl: UILabel!
    @IBOutlet private weak var clientDocLbl: UILabel!
    @IBOutlet private weak var clientPhoneLbl: UILabel!
    @IBOutlet private weak var clientInstLabel: UILabel!
    @IBOutlet private weak var clientEmailLabel: UILabel!
    @IBOutlet private weak var totalLbl: UILabel!
    @IBOutlet private weak var clientBackgroundView: UIView!
    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var animationView: UIView!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var paymentMethodLbl: UILabel!
    
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
        productNameLbl.text = mov?.code?.capitalized
        var type: String {
            switch mov?.movementType {
            case "out":
                return "Venta"
            case "in":
                return "Ingreso"
            case "rma":
                return "RMA"
            default:
                return ""
            }
        }
        productTypeLbl.text =  type
        productLocalLbl.text = mov?.localId?.capitalized
        productConditionLbl.text = mov?.condition?.capitalized
        productCantitiLbl.text = String(mov?.cantitiPurchase ?? 1)
        productDateOutLbl.text = mov?.dateOut
        paymentMethodLbl.text = mov?.paymentMethod?.capitalized
        totalLbl.text = mov?.movementType == MovementType.rma.rawValue ? "RMA" : "$ "+String(mov?.totalAmount ?? 0)
        
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
            clientInstLabel.isHidden = !clientViewExpanded
            clientEmailLabel.isHidden = !clientViewExpanded
        }
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 0, options: []) {
            self.contentViewHeightConstraint.constant = self.clientViewExpanded ? 170 : 42
            self.view.layoutIfNeeded()
            self.successAnimationView.frame = self.animationView.bounds
            self.view.layoutIfNeeded()
        } completion: { (finished) in
            self.clientNameLbl.isHidden = !self.clientViewExpanded
            self.clientDocLbl.isHidden = !self.clientViewExpanded
            self.clientPhoneLbl.isHidden = !self.clientViewExpanded
            self.clientInstLabel.isHidden = !self.clientViewExpanded
            self.clientEmailLabel.isHidden = !self.clientViewExpanded
        }
    }
    
    private func getClient() {
        serviceManager.getClientById(id: mov?.client ?? 0) { (client) in
            if let client = client {
                self.clientNameLbl.text = client.name
                self.clientDocLbl.text = String(client.document ?? 0)
                self.clientPhoneLbl.text = client.phone
                self.clientInstLabel.text = client.instagram
                self.clientEmailLabel.text = client.email
                self.setupGestures()
            }
        }
    }
    
    private func setupGestures() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.expandClientView))
        self.clientBackgroundView.addGestureRecognizer(gesture)
        
        let tapInstagram = UITapGestureRecognizer(target: self, action: #selector(openInstagram))
        clientInstLabel.isUserInteractionEnabled = true
        clientInstLabel.addGestureRecognizer(tapInstagram)
        
        let tapPhone = UITapGestureRecognizer(target: self, action: #selector(openWhatsApp))
        clientPhoneLbl.isUserInteractionEnabled = true
        clientPhoneLbl.addGestureRecognizer(tapPhone)
        
        let tapEmail = UITapGestureRecognizer(target: self, action: #selector(sendCustomEmail))
        clientEmailLabel.isUserInteractionEnabled = true
        clientEmailLabel.addGestureRecognizer(tapEmail)
    }
    
    @objc private func openInstagram() {
        if let username = clientInstLabel.text?.replacingOccurrences(of: "@", with: "").lowercased() {
            let instagramHooks = "instagram://user?username=\(username)"
            guard let instagramUrl = URL(string: instagramHooks) else {
                return
            }
            if UIApplication.shared.canOpenURL(instagramUrl) {
                UIApplication.shared.open(instagramUrl, options: [:], completionHandler: nil)
            } else {
              //redirect to safari because the user doesn't have Instagram
                UIApplication.shared.open(URL(string: "http://instagram.com/\(username)")!, options: [:], completionHandler: nil)
            }
        }
    }
    
    @objc private func openWhatsApp() {
        let urlWhats = "whatsapp://send?phone=+549\(clientPhoneLbl.text ?? "")&abid=12354&text=\(whatsappDefaultMessage)"
        if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
            if let whatsappURL = URL(string: urlString) {
                if UIApplication.shared.canOpenURL(whatsappURL) {
                    UIApplication.shared.open(whatsappURL, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    @objc private func sendCustomEmail() {
        let email = clientEmailLabel.text ?? ""
        if let url = URL(string: "mailto:\(email)") {
          if #available(iOS 10.0, *) {
            UIApplication.shared.open(url)
          } else {
            UIApplication.shared.openURL(url)
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
