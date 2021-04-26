//
//  Core.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 03/04/2021.
//

class Core {
    static let shared = Core()
    
    func isNewUser() -> Bool {
        return !KeysValues().isNewUser
    }
    
    func setIsNotNewUser() {
        UserDefaults.standard.set(true, forKey: Keys.isNewUser)
    }
}
