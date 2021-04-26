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
typealias ServiceManagerFinishedGetUserList = (([UserModel]?) -> Void)
typealias ServiceManagerFinishedSaveProduct = ((ProductModel?, Error?) -> Void)
typealias ServiceManagerFinishedGetPOS = (([PointOfSale]?, String?) -> Void)
typealias ServiceManagerFinishedDeletePOS = ((Error?) -> Void)
typealias ServiceManagerFinishedDeleteUser = ((Error?) -> Void)
typealias ServiceManagerDidFinishUpdateUser = ((Error?) -> Void)
typealias ServiceManagerFinishedGetProducts = (([ProductModel]?, String?) -> Void)
typealias ServiceManagerFinishUpdateProduct = ((String?) -> Void)
typealias ServiceManagerFinishGetMovements = (([MovementsModel]?) -> Void)
typealias ServiceManagerFinishedSaveClient = ((ClientModel?, Error?) -> Void)
typealias ServiceManagerFinishedGetClients = (([ClientModel]?, String?) -> Void)
typealias ServiceManagerFinishedGetClientById = ((ClientModel?) -> Void)
typealias ServiceManagerFinishedCreatePyMe = ((DatabaseReference?, Error?) -> Void)

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
                UserDefaults.standard.set(auth.user.uid, forKey: defaultsKeys.userId)
                completion(auth, nil)
            }
        }
    }
    
    func logOut(delegate: UIViewController) {
        delegate.presentAlertControllerWithCancel(title: needCloseSession, message: closeSessionMessage, delegate: delegate) { (action) in
            do {
                try Auth.auth().signOut()
                delegate.navigationController?.popToRootViewController(animated: true)
                UserDefaults.standard.set(nil, forKey: defaultsKeys.userId)
            }
            catch {
                delegate.presentAlertController(title: errorTitle, message: error.localizedDescription, delegate: delegate, completion: nil)
            }
        }
    }
    
    func forceLogOut() {
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.set(nil, forKey: defaultsKeys.userId)
        }
        catch {
            NSLog(error.localizedDescription, self)
        }
    }
    
    func setupUserByID(id: String, completion: @escaping ServiceManagerFinishedSetupUser) {
        checkDatabaseReference()
        var userLogged: UserModel?
        dataBaseRef = Database.database().reference().child(USER_ADD)
        dataBaseRef.observeSingleEvent(of: .value) { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if let userDic = snap.value as? [String : AnyObject] {
                        if let userObject = UserModel(JSON: userDic) {
                            if userObject.id == id {
                                userLogged = userObject
                            }
                        }
                    }
                }
                completion(userLogged, nil)
            } else {
                completion(nil, userNotExist)
            }
        }
    }
    
    func getUsersList(completion: @escaping ServiceManagerFinishedGetUserList) {
        checkDatabaseReference()
        var users = [UserModel]()
        guard let identifier = UserDefaults.standard.string(forKey: "pymeId") else {
            return
        }
        dataBaseRef = Database.database().reference().child(USER_ADD)
        dataBaseRef.observeSingleEvent(of: .value) { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot],
               snapshot.count > 0 {
                for snap in snapshot {
                    if let userDic = snap.value as? [String : AnyObject] {
                        if let userObject = UserModel(JSON: userDic) {
                            if userObject.email != "admin@admin.com",
                               userObject.email != Auth.auth().currentUser?.email,
                               userObject.pyme == identifier {
                                users.append(userObject)
                            }
                        }
                    }
                }
                completion(users)
            } else {
                completion(nil)
            }
        }
    }
    
    func updateSpecificUser(info: [String : Any], userId: String, completion: @escaping ServiceManagerDidFinishUpdateUser) {
        checkDatabaseReference()
        dataBaseRef = Database.database().reference().child(USER_ADD).child(userId)
        dataBaseRef.updateChildValues(info) { (error, _) in
            guard let error = error else {
                return completion(nil)
            }
            completion(error)
        }
    }
    
    func getPOSFullList(completion: @escaping ServiceManagerFinishedGetPOS) {
        checkDatabaseReference()
        var pos = [PointOfSale]()
        guard let identifier = UserDefaults.standard.string(forKey: "pymeId") else {
            return
        }
        dataBaseRef = Database.database().reference().child("PYME_LIST").child(identifier).child(POS_ADD)
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
                completion(nil, emptyPOS)
            }
        }
    }
    
    func getSpecificPOS(ids: [String], completion: @escaping ServiceManagerFinishedGetPOS) {
        checkDatabaseReference()
        var pos = [PointOfSale]()
        guard let identifier = UserDefaults.standard.string(forKey: "pymeId") else {
            return
        }
        dataBaseRef = Database.database().reference().child("PYME_LIST").child(identifier).child(POS_ADD)
        dataBaseRef.observeSingleEvent(of: .value) { (snap) in
            if let snapshot = snap.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if let posDic = snap.value as? [String : AnyObject] {
                        if let posObject = PointOfSale(JSON: posDic) {
                            for id in ids {
                                if id == posObject.id {
                                    pos.append(posObject)
                                }
                            }
                        }
                    }
                }
                completion(pos, nil)
            } else {
                completion(nil, emptyPOS)
            }
        }
    }
    
    func deleteSpecificUser(id: String, completion: @escaping ServiceManagerFinishedDeleteUser) {
        checkDatabaseReference()
        dataBaseRef = Database.database().reference().child(USER_ADD).child(id)
        dataBaseRef.removeValue { (error, _) in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    func deleteSpecificPOS(id: String, completion: @escaping ServiceManagerFinishedDeletePOS) {
        checkDatabaseReference()
        guard let identifier = UserDefaults.standard.string(forKey: "pymeId") else {
            return
        }
        dataBaseRef = Database.database().reference().child("PYME_LIST").child(identifier).child(POS_ADD).child(id)
        dataBaseRef.removeValue { (error, ref) in
            if let error = error {
                completion(error)
                return
            }
            DispatchQueue.main.async {
                self.deleteProductsInPos(posId: id) { (error) in
                    if let error = error {
                        completion(error)
                        return
                    }
                    completion(nil)
                }
            }
        }
    }
    
    func deleteProductsInPos(posId: String, completion: @escaping ServiceManagerFinishedDeletePOS) {
        checkDatabaseReference()
        guard let identifier = UserDefaults.standard.string(forKey: "pymeId") else {
            return
        }
        dataBaseRef = Database.database().reference().child("PYME_LIST").child(identifier).child(PROD_ADD)
        dataBaseRef.observeSingleEvent(of: .value) { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot],
               snapshot.count > 0 {
                for snap in snapshot {
                    if let prodDict = snap.value as? Dictionary<String, AnyObject> {
                        if posId == prodDict["id"] as? String,
                           let prodId = prodDict["productId"] as? String {
                            self.dataBaseRef.child(prodId).setValue(nil) { (error, _) in
                                if let error = error {
                                    completion(error)
                                    return
                                }
                                completion(nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getProductList(posId: String? = nil, completion: @escaping ServiceManagerFinishedGetProducts) {
        checkDatabaseReference()
        var products = [ProductModel]()
        guard let identifier = UserDefaults.standard.string(forKey: "pymeId") else {
            return
        }
        dataBaseRef = Database.database().reference().child("PYME_LIST").child(identifier).child(PROD_ADD)
        dataBaseRef.observeSingleEvent(of: .value) { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if let prodDict = snap.value as? Dictionary<String, AnyObject> {
                        if let p = ProductModel(JSON: prodDict) {
                            if posId != nil {
                                if posId == p.id {
                                    products.append(p)
                                }
                            } else {
                                products.append(p)
                            }
                        }
                    }
                }
                if products.isEmpty {
                    completion(nil, emptyProds)
                } else {
                    completion(products, nil)
                }
            }
        }
    }
    
    func registerPyme(pyme: PyMeModel, completion: @escaping ServiceManagerFinishedCreatePyMe) {
        checkDatabaseReference()
        dataBaseRef = Database.database().reference().child("PYME_LIST")
        dataBaseRef.setValue(pyme.toJSON()) { (error, success) in
            if let error = error {
                completion(nil, error)
                return
            }
            completion(success, nil)
        }
    }
    
    func updateProductCantiti(isRma: Bool? = false, productsList: [ProductModel], completion: @escaping ServiceManagerFinishUpdateProduct)  {
        checkDatabaseReference()
        guard let identifier = UserDefaults.standard.string(forKey: "pymeId") else {
            return
        }
        dataBaseRef = Database.database().reference().child("PYME_LIST").child(identifier).child(PROD_ADD)
        dataBaseRef.observeSingleEvent(of: .value) { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        for prod in productsList {
                            if prod.code == postDict["code"] as? String,
                               let cantiti = postDict["cantiti"] as? Int {
                                self.updateProductCantiti(key: snap.key, newCantiti: cantiti - prod.cantitiToSell, prod: prod)
                            }
                        }
                    } else {
                        completion(errorTitle)
                        return
                    }
                }
                completion(nil)
            } else {
                completion(errorTitle)
            }
        }
    }

    private func updateProductCantiti(key: String, newCantiti: Int, prod: ProductModel) {
        checkDatabaseReference()
        let post = ["cantiti": newCantiti]
        self.dataBaseRef.child(key).updateChildValues(post)
    }
    
    func registerSaleMov(client: ClientModel?, prods: [ProductModel], movType: MovementType, paymentMethod: String? = nil) {
        checkDatabaseReference()
        guard let identifier = UserDefaults.standard.string(forKey: "pymeId") else {
            return
        }
        dataBaseRef = Database.database().reference().child("PYME_LIST").child(identifier).child(PROD_MOV).childByAutoId()
        let movs = generateMovment(clientId: client?.document, prods: prods, movType: movType, amount: nil, paymentMethod: paymentMethod)
        dataBaseRef.setValue(movs)
    }
    
    func registerAddMov(product: ProductModel) {
        checkDatabaseReference()
        guard let identifier = UserDefaults.standard.string(forKey: "pymeId") else {
            return
        }
        dataBaseRef = Database.database().reference().child("PYME_LIST").child(identifier).child(PROD_MOV).childByAutoId()
        var amount = 0.0
        if let priceBuy = product.priceBuy {
            amount = priceBuy * Double(product.cantitiToSell)
        }
        let mov = generateMovment(prods: [product], movType: .new, amount: amount)
        dataBaseRef.setValue(mov)
    }
    
    func registerRmaMov(product: ProductModel) {
        checkDatabaseReference()
        guard let identifier = UserDefaults.standard.string(forKey: "pymeId") else {
            return
        }
        dataBaseRef = Database.database().reference().child("PYME_LIST").child(identifier).child(PROD_MOV).childByAutoId()
        if let mov = generateRmaMovement(prod: [product], movType: .rma) {
            dataBaseRef.setValue(mov)
        }
    }
    
    private func generateRmaMovement(prod: [ProductModel], movType: MovementType) -> [String : Any]? {
        guard let prod = prod.first else {
            return nil
        }
        var movs = [[String : Any]]()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"

        let movDic = ["id": prod.id  ?? "",
                     "productDescription": prod.description ?? "",
                     "movementType": movType.rawValue,
                     "localId": prod.localInStock as Any,
                     "code" : prod.code as Any,
                     "condition" : prod.condition as Any,
                     "totalAmount" : 0 as Any,
                     "dateOut" : dateFormatter.string(from: Date()),
                     "cantitiPurchase" : prod.cantitiToSell as Any]

        movs.append(movDic)
        let products: [String: Any] = ["products" : movs]
   
        return products
    }
    
    private func generateMovment(clientId: Int? = nil, prods: [ProductModel], movType: MovementType, amount: Double? = nil, paymentMethod: String? = nil) -> [String : Any]? {
        let dateFormatter = DateFormatter()
        var movs = [[String : Any]]()
        dateFormatter.dateFormat = "dd/MM/yy"
        for prod in prods {
            var amountToShow: Double? = amount
            if amount == nil, let prodSalePrice = prod.priceSale{
                amountToShow = prodSalePrice * Double(prod.cantitiToSell)
            }
            let movDic = ["id": prod.id  ?? "",
                          "productDescription": prod.description ?? "",
                          "movementType": movType.rawValue,
                          "localId": prod.localInStock as Any,
                          "code" : prod.code as Any,
                          "condition" : prod.condition as Any,
                          "totalAmount" : amountToShow as Any,
                          "dateOut" : dateFormatter.string(from: Date()),
                          "client" : clientId as Any,
                          "paymentMethod" : paymentMethod as Any,
                          "cantitiPurchase" : prod.cantitiToSell as Any]
            movs.append(movDic)
        }
        let products: [String: Any] = ["products" : movs]
        
        return products
    }
    
    func saveProduct(productDic: [String : Any],
                     condition: String,
                     saveToPOS: PointOfSale,
                     cantiti: Int, completion: @escaping ServiceManagerFinishedSaveProduct) {
        checkDatabaseReference()
        guard let identifier = UserDefaults.standard.string(forKey: "pymeId") else {
            return
        }
        dataBaseRef = Database.database().reference().child("PYME_LIST").child(identifier).child(PROD_ADD).childByAutoId()
        let productToSave = createProduct(productDic: productDic, condition: condition, saveToPOS: saveToPOS, cantiti: cantiti)
        
        dataBaseRef.setValue(productToSave?.toDictionary()) { (error, ref) in
            if let error = error {
                completion(nil, error)
            }
            if let product = productToSave {
                product.cantitiToSell = cantiti
                self.registerAddMov(product: product)
                completion(product, nil)
            } else {
                completion(nil, nil)
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
        guard let identifier = UserDefaults.standard.string(forKey: "pymeId") else {
            return
        }
        dataBaseRef = Database.database().reference().child("PYME_LIST").child(identifier).child(PROD_MOV)
        var movsObjects = [MovementsModel]()
        dataBaseRef.observeSingleEvent(of: .value) { (snap) in
            if let snapshot = snap.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if let movDic = snap.value as? [String : AnyObject] {
                        if let movs = movDic["products"] as? [[String : AnyObject]] {
                            for mov in movs {
                                if let movObject = MovementsModel(JSON: mov) {
                                    movsObjects.append(movObject)
                                }
                            }
                        }
                    }
                }
                completion(movsObjects)
            }
        }
    }
    
    func updateCantiti(delegate: UIViewController, product: ProductModel?) {
        checkDatabaseReference()
        guard let identifier = UserDefaults.standard.string(forKey: "pymeId") else {
            return
        }
        dataBaseRef = Database.database().reference().child("PYME_LIST").child(identifier).child(PROD_ADD)
        
        let updatedValues: [String : Any] = ["cantiti": product?.cantiti as Any,
                                             "priceBuy":product?.priceBuy as Any,
                                             "priceSale":product?.priceSale as Any]

        guard let id = product?.productId else {
            return
        }
        dataBaseRef.child(id).updateChildValues(updatedValues) { (error, ref) in
            if error != nil {
                delegate.presentAlertController(title: errorTitle, message: updateValuesError, delegate: delegate, completion: nil)
                return
            }
            delegate.presentAlertController(title: successSaved, message: "", delegate: delegate) { (action) in
                delegate.dismiss(animated: true, completion: nil)
            }
            
            if let prod = product {
                self.registerAddMov(product: prod)
            }
        }
    }
    
    func createNewUser(delegate: UIViewController, userDic: [String : Any], email: String, pass: String, userType: UserType, posAsignedId: [String]) {
        guard let identifier = UserDefaults.standard.string(forKey: "pymeId") else {
            return
        }
        Auth.auth().createUser(withEmail: email, password: pass) { (auth, error) in
            if let user = auth?.user  {
                let newUserDic: [String : Any] = ["id":user.uid,
                                                "email": user.email as Any,
                                                "username": userDic["username"] as Any,
                                                "dni":userDic["dni"] as Any,
                                                "type": userType.rawValue,
                                                "pymeId" : identifier as Any,
                                                "localAutorized":posAsignedId]
                
                let userModel = UserModel(JSON: newUserDic)?.toDictionary()
                self.saveUserInDB(delegate: delegate, id: user.uid, userModel: userModel)
            }
            if let error = error {
                delegate.presentAlertController(title: errorTitle, message: error.localizedDescription, delegate: delegate, completion: nil)
            }
        }
    }
    
    private func saveUserInDB(delegate: UIViewController, id: String, userModel: NSDictionary?) {
        checkDatabaseReference()
        dataBaseRef = Database.database().reference().child(USER_ADD).child(id)
        dataBaseRef.setValue(userModel) { (error, ref) in
            if let error = error {
                delegate.presentAlertController(title: errorTitle, message: error.localizedDescription, delegate: delegate, completion: nil)
            } else {
                delegate.presentAlertController(title: saved, message: successSaved, delegate: delegate) { (action) in
                    delegate.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    func saveNewPOS(delegate: UIViewController, userDic: [String : Any], userType: POSType) {
        checkDatabaseReference()
        guard let identifier = UserDefaults.standard.string(forKey: "pymeId") else {
            return
        }
        dataBaseRef = Database.database().reference().child("PYME_LIST").child(identifier).child(POS_ADD).childByAutoId()
        let key = dataBaseRef.key
        let newPosDic: [String : Any] = ["id": key as Any,
                                         "name": userDic["name"] as Any,
                                         "type": userType.rawValue,
                                        "localized" : userDic["localized"] as Any]

        let posModel = PointOfSale(JSON: newPosDic)
        dataBaseRef.setValue(posModel?.toDictionary()) { (error, ref) in
            if let error = error {
                delegate.presentAlertController(title: errorTitle, message: error.localizedDescription, delegate: delegate, completion: nil)
            } else {
                delegate.presentAlertController(title: saved, message: successSaved, delegate: delegate) { (action) in
                    delegate.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    func saveClient(client: ClientModel, completion: @escaping ServiceManagerFinishedSaveClient) {
        checkDatabaseReference()
        guard let identifier = UserDefaults.standard.string(forKey: "pymeId") else {
            return
        }
        dataBaseRef = Database.database().reference().child("PYME_LIST").child(identifier).child(CLI_ADD).childByAutoId()
        if let clientKey = dataBaseRef.key {
            let clientDic = client.toDictionary(withKey: clientKey)
            dataBaseRef.setValue(clientDic) { (error, ref) in
                if let error = error {
                    completion(nil, error)
                } else {
                    completion(client, nil)
                }
            }
        }
    }
    
    func getClientFullList(completion: @escaping ServiceManagerFinishedGetClients) {
        checkDatabaseReference()
        var clients = [ClientModel]()
        guard let identifier = UserDefaults.standard.string(forKey: "pymeId") else {
            return
        }
        dataBaseRef = Database.database().reference().child("PYME_LIST").child(identifier).child(CLI_ADD)
        dataBaseRef.observeSingleEvent(of: .value) { (snap) in
            if let snapshot = snap.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if let posDic = snap.value as? [String : AnyObject] {
                        if let cliObject = ClientModel(JSON: posDic) {
                            clients.append(cliObject)
                        }
                    }
                }
                completion(clients, nil)
                return
            }
            completion(nil, genericError)
        }
    }
    
    func getClientById(id: Int, completion: @escaping ServiceManagerFinishedGetClientById) {
        getClientFullList { (clients, error) in
            if let clients = clients {
                for client in clients {
                    if client.document == id {
                        completion(client)
                        return
                    }
                }
                completion(nil)
            }
        }
    }
    
    func checkClientExist(clientDoc: Int, completion: @escaping (ClientModel?) -> Void) {
        checkDatabaseReference()
        var client: ClientModel?
        guard let identifier = UserDefaults.standard.string(forKey: "pymeId") else {
            return
        }
        dataBaseRef = Database.database().reference().child("PYME_LIST").child(identifier).child(CLI_ADD)
        dataBaseRef.observeSingleEvent(of: .value) { (snap) in
            if let snapshot = snap.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if let posDic = snap.value as? [String : AnyObject] {
                        if let cliObject = ClientModel(JSON: posDic), cliObject.document == clientDoc {
                            client = cliObject
                        }
                    }
                }
                completion(client)
            }
        }
    }
    
}
