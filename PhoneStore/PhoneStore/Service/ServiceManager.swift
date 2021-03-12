//
//  ServiceManager.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 12/03/2021.
//
import FirebaseAuth

typealias ServiceManagerFinishedLogin = ((AuthDataResult?, Error?) -> Void)

class ServiceManager: NSObject {
    
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
    
    
}
