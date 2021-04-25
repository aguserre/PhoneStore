//
//  EditViewController.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 24/04/2021.
//

import UIKit

final class EditViewController: UIViewController {
    
    @IBOutlet weak var posCollectionView: UICollectionView!
    var posFullList: [PointOfSale]?
    let cellScale: CGFloat = 0.5


    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupCollectionDelegates()
    }
    
    private func setupView() {
        setNavTitle(title: "Editar Punto de venta")
        view.layer.insertSublayer(createCustomGradiend(view: view), at: 0)
    }
    
    private func setupCollectionDelegates() {
        posCollectionView.delegate = self
        posCollectionView.dataSource = self
    }
    
}

extension EditViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      
    }
}

extension EditViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posFullList?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EditCollectionViewCell", for: indexPath) as! EditCollectionViewCell
        cell.setupCell(pos: (posFullList?[indexPath.row])!)
        cell.contentView.layer.cornerRadius = 15
        cell.addShadow(offset: .zero, color: .black, radius: 4, opacity: 0.4)
        
        return cell
    }
    
}

extension EditViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width * cellScale - 20
        let height = width
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}
