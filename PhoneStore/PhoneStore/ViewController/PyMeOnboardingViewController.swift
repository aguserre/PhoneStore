//
//  PyMeOnboardingViewController.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 03/04/2021.
//

import UIKit

final class PyMeOnboardingViewController: UIViewController {
    
    @IBOutlet weak var holderView: UIView!
    let scrollView = UIScrollView()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.backgroundColor = .clear
        view.layer.insertSublayer(createCustomGradiend(view: view), at: 0)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configure()
    }
    
    private func configure() {
        scrollView.frame = holderView.bounds
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        holderView.addSubview(scrollView)
        let titles = ["Crea tu iPyMe", "Administra tu iPyMe", "Comparte datos", "Gracias por utilizar iPyMe!"]
        let desciptions = ["Registrá tu PyMe, un administrador te contactará informandote que ya fue creada. \nSe te otorgará un usuario administrador para comenzar a utilizarla",
                           "Crea Usuarios vendedores o admins, Puntos de venta, productos.\nChequea los movimientos de tus puntos de ventas.",
                           "Comparte tus movimientos y base de clientes.\nY mucho mas!",
                           ""]
        for x in 0..<4 {
            let pageView = UIView(frame: CGRect(x: CGFloat(x)*holderView.frame.size.width, y: 0, width: holderView.frame.size.width, height: holderView.frame.size.height))
            pageView.backgroundColor = .clear
            scrollView.addSubview(pageView)
            
            let titleLabel = UILabel(frame: CGRect(x: 10, y: 10, width: pageView.frame.size.width-20, height: 100))
            titleLabel.textAlignment = .center
            titleLabel.font = UIFont(name: "Helvetica-Bold", size: 32)
            titleLabel.textColor = .white
            titleLabel.numberOfLines = 0
            pageView.addSubview(titleLabel)
            titleLabel.text = titles[x]
            
            let imageView = UIImageView(frame: CGRect(x: 10, y: 80, width: pageView.frame.size.width-20, height: pageView.frame.size.height - 100 - 160 - 30))
            imageView.contentMode = .scaleAspectFit
            imageView.image = UIImage(named: "on_step\(x)")
            pageView.addSubview(imageView)
            
            let button = UIButton(frame: CGRect(x: 10, y: pageView.frame.size.height-60, width: pageView.frame.size.width-20, height: 50))
            button.addTarget(self, action: #selector(start), for: .touchUpInside)
            button.setTitleColor(.white, for: .normal)
            button.setTitle("Comenzar", for: .normal)
            button.backgroundColor = .systemIndigo
            button.layer.cornerRadius = 10
            button.addShadow(offset: .zero, color: .black, radius: 4, opacity: 0.4)
            button.isHidden = x != 3
            pageView.addSubview(button)
            
            let descriptionLabel = UILabel(frame: CGRect(x: 10, y: pageView.frame.size.height-160, width: pageView.frame.size.width-20, height: 160))
            descriptionLabel.numberOfLines = 0
            descriptionLabel.textAlignment = .justified
            descriptionLabel.font = UIFont(name: "Helvetica-Medium", size: 15)
            descriptionLabel.textColor = .black
            pageView.addSubview(descriptionLabel)
            descriptionLabel.text = desciptions[x]
            descriptionLabel.isHidden = x > 3
        }
        
        scrollView.contentSize = CGSize(width: holderView.frame.size.width * 4, height: 0)
        scrollView.isPagingEnabled = true
    }
    
    @objc func start() {
        Core.shared.setIsNotNewUser()
        dismiss(animated: true, completion: nil)
    }

}
