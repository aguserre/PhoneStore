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
typealias ServiceManagerFinishUpdateProduct = ((String?) -> Void)
typealias ServiceManagerFinishGetMovements = (([MovementsModel]?) -> Void)

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
                                    completion(nil)
                                } else {
                                    self.updateProductCantiti(key: snap.key, newCantiti: cantiti - prod.cantitiToSell, prod: prod, amount: withTotalAmount)
                                    completion(nil)
                                }
                            }
                        }
                    } else {
                        completion("Error")
                    }
                }
            } else {
                completion("Error")
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
    
    func registerAddMov(product: ProductModel) {
        checkDatabaseReference()
        dataBaseRef = Database.database().reference().child("PROD_MOV").childByAutoId()
        var amount = 0.0
        if let priceBuy = product.priceBuy, let cantiti = product.cantiti {
            amount = priceBuy * Double(cantiti)
        }
        let mov = generateMovment(prod: product, movType: .new, amount: amount)
        dataBaseRef.setValue(mov?.toDictionary())
    }
    
    private func generateMovment(prod: ProductModel, movType: MovementType, amount: Double) -> MovementsModel? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
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
    
    func saveProduct(productDic: [String : Any],
                     condition: String,
                     saveToPOS: PointOfSale,
                     cantiti: Int) {
        checkDatabaseReference()
        dataBaseRef = Database.database().reference().child("PROD_ADD").childByAutoId()
        let productToSave = createProduct(productDic: productDic, condition: condition, saveToPOS: saveToPOS, cantiti: cantiti)
        
        dataBaseRef.setValue(productToSave?.toDictionary()) { (error, ref) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let product = productToSave {
                    self.registerAddMov(product: product)
                }
            }
        }
    }
    
    private func createProduct(productDic: [String : Any],
                               condition: String,
                               saveToPOS: PointOfSale,
                               cantiti: Int) -> ProductModel? {
        let date = Date()
        let formatter1 = DateFormatter()
        formatter1.dateStyle = .short
        let today = formatter1.string(from: date)
        var priceBuy: Double = 0.00
        var saleBuy: Double = 0.00
        
        if let stringPrice = productDic["priceBuy"] as? String {
            priceBuy = stringPrice.doubleValue
        }
        if let stringPrice = productDic["priceSale"] as? String {
            saleBuy = stringPrice.doubleValue
        }
        
        let key = dataBaseRef.key

        let prodDic: [String : Any] =  ["id":saveToPOS.id as Any,
                                        "productId":key as Any,
                                        "code" : productDic["code"] as Any,
                                        "description" : productDic["description"] as Any,
                                        "color" : productDic["color"] as Any,
                                        "condition" : condition,
                                        "priceBuy" : priceBuy,
                                        "priceSale" : saleBuy,
                                        "dateIn" : today,
                                        "dateOut" : "",
                                        "cantiti" : cantiti as Any,
                                        "localInStock" : saveToPOS.name as Any]
        
        return ProductModel(JSON: prodDic)
    }
    
    func getMovements(completion: @escaping ServiceManagerFinishGetMovements) {
        checkDatabaseReference()
        dataBaseRef = Database.database().reference().child("PROD_MOV")
        var movs = [MovementsModel]()
        dataBaseRef.observeSingleEvent(of: .value) { (snap) in
            if let snapshot = snap.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if let posDic = snap.value as? [String : AnyObject] {
                        if let posObject = MovementsModel(JSON: posDic) {
                            movs.append(posObject)
                        }
                    }
                }
                completion(movs)
            }
        }
    }
    
    func updateCantiti(delegate: UIViewController, product: ProductModel?, newCantiti: Int) {
        checkDatabaseReference()
        dataBaseRef = Database.database().reference().child("PROD_ADD")
        var totalCant: Int = 0
        if let actualCantiti = product?.cantiti {
            totalCant = Int(newCantiti) + actualCantiti
        }
        let newCantiti = ["cantiti": totalCant]
        guard let id = product?.productId else {
            return
        }
        dataBaseRef.child(id).updateChildValues(newCantiti) { (error, ref) in
            if error != nil {
                delegate.presentAlertController(title: "Error", message: "mposible actualizar la cantidad de stock en este momento", delegate: delegate, completion: nil)
                return
            }
            delegate.presentAlertController(title: "Guardado con exito", message: "", delegate: delegate) { (action) in
                delegate.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func createNewUser(delegate: UIViewController, userDic: [String : Any], email: String, pass: String, userType: UserType, posAsignedId: String) {
        Auth.auth().createUser(withEmail: email, password: pass) { (auth, error) in
            guard let user = auth?.user else {
                print(error?.localizedDescription)
                return
            }
            
            let newUserDic: [String : Any] = ["id":user.uid,
                                            "email": user.email as Any,
                                            "username": userDic["username"] as Any,
                                            "dni":userDic["dni"] as Any,
                                            "type": userType.rawValue,
                                            "localAutorized":posAsignedId]
            
            let userModel = UserModel(JSON: newUserDic)?.toDictionary()
            self.saveUserInDB(delegate: delegate, id: user.uid, userModel: userModel)
        }
    }
    
    private func saveUserInDB(delegate: UIViewController, id: String, userModel: NSDictionary?) {
        checkDatabaseReference()
        dataBaseRef = Database.database().reference().child("USER_ADD").child(id)
        dataBaseRef.setValue(userModel) { (error, ref) in
            if let error = error {
                delegate.presentAlertController(title: "Error", message: error.localizedDescription, delegate: delegate, completion: nil)
            } else {
                delegate.presentAlertController(title: "Guardado", message: "Se guardaron los datos", delegate: delegate) { (action) in
                    delegate.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    func saveNewPOS(delegate: UIViewController, userDic: [String : Any], userType: POSType) {
        checkDatabaseReference()
        dataBaseRef = Database.database().reference().child("POS_ADD").childByAutoId()
        let key = dataBaseRef.key
        let newPosDic: [String : Any] = ["id": key as Any,
                                         "name": userDic["name"] as Any,
                                         "type": userType.rawValue,
                                        "localized" : userDic["localized"] as Any]

        let posModel = PointOfSale(JSON: newPosDic)
        dataBaseRef.setValue(posModel?.toDictionary()) { (error, ref) in
            if let error = error {
                delegate.presentAlertController(title: "Error", message: error.localizedDescription, delegate: delegate, completion: nil)
            } else {
                delegate.presentAlertController(title: "Guardado", message: "Se guardaron los datos", delegate: delegate) { (action) in
                    delegate.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
}
