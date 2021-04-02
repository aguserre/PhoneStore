//
//  PopUpViewController.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 01/04/2021.
//

import UIKit

class PopUpViewController: UIViewController {
    @IBOutlet private weak var backView: UIView!
    @IBOutlet private weak var closeButtonView: UIButton!
    @IBOutlet private weak var productNameLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var localLabel: UILabel!
    @IBOutlet private weak var cantitiLabel: UILabel!
    
    var product: ProductModel?
    var pos = [PointOfSale]()
    let serviceManager = ServiceManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showAnimated()
        setupView()
    }
    
    private func setupView() {
        backView.layer.cornerRadius = 10
        productNameLabel.text = product?.code?.capitalized
        descriptionLabel.text = product?.description
        localLabel.text = product?.localInStock?.capitalized
        cantitiLabel.text = String(product?.cantiti ?? 1)
        closeButtonView.layer.cornerRadius = closeButtonView.bounds.width/2
        closeButtonView.addShadow(offset: .zero, color: .black, radius: 4, opacity: 0.4)
    }
    
    @IBAction func close(_ sender: Any) {
        closeAnimated()
    }
    
    func showAnimated() {
        view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        view.alpha = 0.0
        UIView.animate(withDuration: 0.4) {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
    
    func closeAnimated() {
        UIView.animate(withDuration: 0.4) {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0
        } completion: { (finished) in
            self.view.removeFromSuperview()
        }
    }

}
