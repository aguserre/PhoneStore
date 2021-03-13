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
typealias ServiceManagerFinishedGetProducts = (([ProductModel]?, String?) -> Void)
typealias ServiceManagerFinishUpdateProduct = (() -> Void)

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
    
    func getProductList(posId: String, completion: @escaping ServiceManagerFinishedGetProducts) {
        checkDatabaseReference()
        var products = [ProductModel]()
        dataBaseRef = Database.database().reference().child("PROD_ADD")
        dataBaseRef.observeSingleEvent(of: .value) { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if let prodDict = snap.value as? Dictionary<String, AnyObject> {
                        if let p = ProductModel(JSON: prodDict) {
                            if posId == p.id {
                                products.append(p)
                            }
                        }
                    } else {
                        print("Zhenya: failed to convert")
                    }
                }
                if products.isEmpty {
                    completion(nil, "Aun no tiene productos cargados")
                } else {
                    completion(products, nil)
                }
            }
        }
    }
    
    func deleteProduct(delegate: UIViewController, productsList: [ProductModel], withTotalAmount: Double, completion: @escaping ServiceManagerFinishUpdateProduct)  {
        checkDatabaseReference()
        dataBaseRef = Database.database().reference().child("PROD_ADD")
        dataBaseRef.observeSingleEvent(of: .value) { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        for prod in productsList {
                            if prod.code == postDict["code"] as? String,
                               let cantiti = postDict["cantiti"] as? Int {
                                if cantiti == prod.cantitiToSell {
                                    self.deleteProduct(key: snap.key, prod: prod, amount: withTotalAmount)
                                    completion()
                                } else {
                                    self.updateProductCantiti(key: snap.key, newCantiti: cantiti - prod.cantitiToSell, prod: prod, amount: withTotalAmount)
                                    completion()
                                }
                            }
                        }
                    } else {
                        print("Zhenya: failed to convert")
                    }
                }
            } else {
                delegate.presentAlertController(title: "Error", message: "Hubo un error al actualizar el producto", delegate: delegate, completion: nil)
            }
        }
    }
    
    private func deleteProduct(key: String, prod: ProductModel, amount: Double) {
        checkDatabaseReference()
        print("Se quedo sin stock del producto \(key)")
        self.dataBaseRef.child(key).removeValue(completionBlock: { (error, ref) in
            if error != nil {
                print("Error: \(String(describing: error))")
                return
            }
            self.registerSaleMov(prod: prod, movType: .out, totalAmount: amount)
        })
    }
    
    private func updateProductCantiti(key: String, newCantiti: Int, prod: ProductModel, amount: Double) {
        checkDatabaseReference()
        print("Se actualiza el stock del producto \(key), por una cantidad de \(newCantiti)")
        let post = ["cantiti": newCantiti]

        self.dataBaseRef.child(key).updateChildValues(post) { (error, ref) in
            if error != nil {
                print("Imposible actualizar la cantidad")
                return
            }
            self.registerSaleMov(prod: prod, movType: .out, totalAmount: amount)
        }
    }
    
    func registerSaleMov(prod: ProductModel, movType: MovementType, totalAmount: Double) {
        checkDatabaseReference()
        dataBaseRef = Database.database().reference().child("PROD_MOV").childByAutoId()
        let mov = generateMovment(prod: prod, movType: movType, amount: totalAmount)
        dataBaseRef.setValue(mov?.toDictionary())
    }
    
    private func generateMovment(prod: ProductModel, movType: MovementType, amount: Double) -> MovementsModel? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YY/MM/dd"
        let movDic = ["id": prod.id  ?? "",
                      "productDescription": prod.description ?? "",
                      "movementType": movType.rawValue,
                      "localId": prod.localInStock as Any,
                      "code" : prod.code as Any,
                      "condition" : prod.condition as Any,
                      "totalAmount" : amount as Any,
                      "dateOut" : dateFormatter.string(from: Date()),
                      "cantitiPurchase" : prod.cantitiToSell as Any]
        guard let mov = MovementsModel(JSON: movDic) else {
            return nil
        }
        return mov
    }
    
}
