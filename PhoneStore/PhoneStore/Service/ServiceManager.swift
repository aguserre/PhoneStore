//
//  ServiceManager.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 12/03/2021.
//
import FirebaseAuth
import FirebaseDatabase

typealias ServiceManagerFinishedLogin = ((AuthDataResult?, Error?) -> Void)
typealias ServiceManagerFinishedLogOut = ((Error?) -> Void)
typealias ServiceManagerFinishedSetupUser = ((UserModel?, String?) -> Void)
typealias ServiceManagerFinishedGetPOS = (([PointOfSale]?, String?) -> Void)

class ServiceManager: NSObject {
    
    var dataBaseRef: DatabaseReference!
    
    private func checkDatabaseReference() {
        if dataBaseRef != nil {
            dataBaseRef.removeAllObservers()
        }
    }
    
    func login(user: String, password: String, completion: @escaping ServiceManagerFinishedLogin) {
        Auth.auth().signIn(withEmail: user, password: password) { (auth, error) in
            if let error = error {
                completion(nil, error)
            }
            if let auth = auth {
                completion(auth, nil)
            }
        }
    }
    
    func logOut(delegate: UIViewController) {
        delegate.presentAlertControllerWithCancel(title: "Desea cerrar la sesion?", message: "Se perderan los datos que no haya guardado", delegate: delegate) { (action) in
            do {
                try Auth.auth().signOut()
                delegate.navigationController?.popToRootViewController(animated: true)
            }
            catch {
                delegate.presentAlertController(title: "Error", message: error.localizedDescription, delegate: delegate, completion: nil)
            }
        }
    }
    
    func setupUserByID(id: String, completion: @escaping ServiceManagerFinishedSetupUser) {
        checkDatabaseReference()
        dataBaseRef = Database.database().reference().child("USER_ADD")
        dataBaseRef.observeSingleEvent(of: .value) { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if let userDic = snap.value as? [String : AnyObject] {
                        if let userObject = UserModel(JSON: userDic) {
                            if userObject.id == id {
                                completion(userObject, nil)
                            }
                        }
                    }
                }
            } else {
                completion(nil, "No se pudo encontrar el usuario")
            }
        }
    }
    
    func getPOSFullList(completion: @escaping ServiceManagerFinishedGetPOS) {
        checkDatabaseReference()
        var pos = [PointOfSale]()
        dataBaseRef = Database.database().reference().child("POS_ADD")
        dataBaseRef.observeSingleEvent(of: .value) { (snap) in
            if let snapshot = snap.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if let posDic = snap.value as? [String : AnyObject] {
                        if let posObject = PointOfSale(JSON: posDic) {
                            pos.append(posObject)
                        }
                    }
                }
                completion(pos, nil)
            } else {
                completion(nil, "No existen puntos de ventas creados")
            }
        }
    }
    
    func getSpecificPOS(id: String, completion: @escaping ServiceManagerFinishedGetPOS) {
        checkDatabaseReference()
        var pos = [PointOfSale]()
        dataBaseRef = Database.database().reference().child("POS_ADD")
        dataBaseRef.observeSingleEvent(of: .value) { (snap) in
            if let snapshot = snap.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if let posDic = snap.value as? [String : AnyObject] {
                        if let posObject = PointOfSale(JSON: posDic) {
                            if id == posObject.id {
                                pos.append(posObject)
                            }
                        }
                    }
                }
                completion(pos, nil)
            } else {
                completion(nil, "No existen puntos de ventas creados")
            }
        }
    }
    
}
