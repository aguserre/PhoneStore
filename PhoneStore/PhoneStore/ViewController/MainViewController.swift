//
//  MainViewController.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 26/01/2021.
//

import UIKit

final class MainViewController: UIViewController {
    
    @IBOutlet private weak var shadowView: UIView!
    @IBOutlet private weak var posTableView: UITableView!
    @IBOutlet private weak var seeMoreButton: UIButton!
    @IBOutlet private weak var settingsButton: UIBarButtonItem!
    @IBOutlet private weak var loaderIndicator: UIActivityIndicatorView!
    
    var userId: String = ""
    var userLogged: UserModel?
    var users = [UserModel]()
    var posts = [PointOfSale]()
    var selectedPost: PointOfSale?
    let serviceManager = ServiceManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupelementsView()
    }
    
    private func setupelementsView() {
        settingsButton.isEnabled = false
        posTableView.isHidden = true
        loaderIndicator.startAnimating()
        self.navigationItem.leftBarButtonItem = setupBackButton(target: #selector(logOutTapped))
        clearNavBar()
        posts.removeAll()
        setupUserByID(id: userId)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.hidesBackButton = false
    }
    
    private func setupView() {
        view.layer.insertSublayer(createCustomGradiend(view: view), at: 0)
        shadowView.layer.insertSublayer(createCustomGradiend(view: shadowView), at: 0)
        seeMoreButton.layer.insertSublayer(createCustomGradiend(view: seeMoreButton), at: 0)

        shadowView.addShadow(offset: .zero, color: .black, radius: 4, opacity: 0.4)
        seeMoreButton.addShadow(offset: .zero, color: .black, radius: 4, opacity: 0.4)
    }
    
    private func setupUserByID(id: String) {
        serviceManager.setupUserByID(id: id) { (user, error) in
            if let error = error {
                self.presentAlertController(title: "Error", message: error, delegate: self, completion: nil)
                return
            }
            if let user = user {
                self.selectUserLogged(users: user)
            }
        }
    }
    
    private func selectUserLogged(users: UserModel) {
        userLogged = users
        prepareViewByUser(user: userLogged)
    }
    
    private func prepareViewByUser(user: UserModel?) {
        if user?.type == UserType.admin.rawValue {
            setupAdminView()
        } else {
            setupVendorViewByPOSView()
        }
        settingsButton.isEnabled = true
        posTableView.isHidden = false
        loaderIndicator.stopAnimating()
        loaderIndicator.isHidden = true
    }
    
    private func setupAdminView() {
        serviceManager.getPOSFullList { (pos, error) in
            if let pos = pos {
                self.posts = pos
                self.posTableView.reloadData()
            }
            if let error = error {
                self.presentAlertController(title: "Error", message: error, delegate: self, completion: nil)
            }
        }
    }
    
    private func setupVendorViewByPOSView() {
        seeMoreButton.isHidden = true
        serviceManager.getSpecificPOS(id: userLogged?.localAutorized ?? "") { (pos, error) in
            if let pos = pos {
                self.posts = pos
                self.posTableView.reloadData()
            }
            if let error = error {
                self.presentAlertController(title: "Error", message: error, delegate: self, completion: nil)
            }
        }
    }
    
    @IBAction private func goToMovements(_ sender: Any) {
        generateImpactWhenTouch()
        performSegue(withIdentifier: "goToMovements", sender: nil)
    }
    
    @IBAction private func goToSettings(_ sender: UIBarButtonItem) {
        generateImpactWhenTouch()
        performSegue(withIdentifier: "goToSettings", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueId = segue.identifier,
           segueId == "goToList",
           let listViewController = segue.destination as? ListViewController {
            listViewController.selectedPos = self.selectedPost
            listViewController.userLogged = self.userLogged
        }
        
        if let segueId = segue.identifier,
           segueId == "goToSettings",
           let settingsVC = segue.destination as? SettingsViewController {
            if self.userLogged?.type == UserType.admin.rawValue {
                settingsVC.userTypeView = .admin
            } else {
                settingsVC.userTypeView = .vendor
            }
        }
        
        if let segueId = segue.identifier,
           segueId == "goToMovements",
           let movementsVC = segue.destination as? MovementsViewController {
            movementsVC.posts = posts
        }
    }
    
    private func checkResponsable(position: Int) -> String {
        var responsable = ""
        if userLogged?.type == UserType.vendor.rawValue {
            responsable = userLogged?.username ?? "Indefinido"
        } else {
            
            for user in users {
                if posts[position].id == user.localAutorized {
                    responsable = user.username ?? "Indefinido"
                }
            }
        }
        if responsable.isEmpty {
            responsable = "Indefinido"
        }
        
        return responsable.capitalized
    }
    
    @objc func logOutTapped() {
        self.serviceManager.logOut(delegate: self)
    }
    
    @IBAction func movmentsActionButton(_ sender: Any) {
        generateImpactWhenTouch()
    }
    
    @IBAction @objc func logOut(_ sender: Any) {
        generateImpactWhenTouch()
        logOutTapped()
    }
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PosTableViewCell", for: indexPath) as! PosTableViewCell

        cell.setupPosCell(pos: posts[indexPath.row], resp: checkResponsable(position: indexPath.row))
        
        return cell
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        generateImpactWhenTouch()
        selectedPost = posts[indexPath.row]
        performSegue(withIdentifier: "goToList", sender: nil)
    }
}
