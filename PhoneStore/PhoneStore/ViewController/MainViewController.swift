//
//  MainViewController.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 26/01/2021.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class MainViewController: UIViewController {
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var posTableView: UITableView!
    var userId: String = ""
    var userLogged: UserModel?
    var users = [UserModel]()
    var posts = [PointOfSale]()
    var selectedPost: PointOfSale?
    var dataBaseRef: DatabaseReference!
    @IBOutlet weak var headerTableView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [UIColor.systemTeal.cgColor,  UIColor.systemIndigo.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blurEffectView, at: 0)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.leftBarButtonItem = setupBackButton(target: #selector(logOutTapped))
        clearNavBar()
        posts.removeAll()
        setupUserByID(id: userId)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.hidesBackButton = false
        dataBaseRef.removeAllObservers()
    }
    
    private func setupUserByID(id: String) {
        dataBaseRef = Database.database().reference().child("USER_ADD")
        dataBaseRef.observeSingleEvent(of: .value) { [self] (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if let userDic = snap.value as? [String : AnyObject] {
                        if let userObject = UserModel(JSON: userDic) {
                            self.users.append(userObject)
                        }
                    }
                }
                selectUserLogged(users: self.users)
            }
            
            
            
//            if let userDic = snapshot.value as? Dictionary<String , Any> {
//                let userLogged = UserModel(JSON: userDic)
//                self.prepareViewByUser(user: userLogged)
//            }
        }
    }
    
    private func selectUserLogged(users: [UserModel]) {
        for user in users {
            if user.id == userId {
                userLogged = user
            }
        }
        prepareViewByUser(user: userLogged)
    }
    
    private func prepareViewByUser(user: UserModel?) {
        if user?.type == UserType.admin.rawValue {
            setupAdminView()
        } else {
            setupVendorViewByPOSView()
        }
    }
    
    private func setupAdminView() {
        dataBaseRef = Database.database().reference().child("POS_ADD")
        dataBaseRef.observeSingleEvent(of: .value) { (snap) in
            if let snapshot = snap.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if let posDic = snap.value as? [String : AnyObject] {
                        if let posObject = PointOfSale(JSON: posDic) {
                            self.posts.append(posObject)
                        }
                    }
                }
                self.posTableView.reloadData()
            }
        }
    }
    
    private func setupVendorViewByPOSView() {
        dataBaseRef = Database.database().reference().child("POS_ADD")
        dataBaseRef.observeSingleEvent(of: .value) { (snap) in
            if let snapshot = snap.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if let posDic = snap.value as? [String : AnyObject] {
                        if let posObject = PointOfSale(JSON: posDic),
                           let userId = self.userLogged?.localAutorized,
                           userId == posObject.id {
                            self.posts.append(posObject)
                        }
                    }
                }
                self.posTableView.reloadData()
            }
        }
    }
    
    
    @IBAction func goToSettings(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "goToSettings", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueId = segue.identifier,
           segueId == "goToList",
           let listViewController = segue.destination as? ListViewController {
            
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
        do { try Auth.auth().signOut() }
        catch { print("already logged out") }
        
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction @objc func logOut(_ sender: Any) {
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
        selectedPost = posts[indexPath.row]
        print(selectedPost?.name)
    }
}

extension UIViewController {
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

