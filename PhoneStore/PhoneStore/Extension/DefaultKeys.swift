//
//  DefaultKeys.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 26/04/2021.
//


struct Keys {
    static let userId = "userId"
    static let canUseApp = "canUseApp"
    static let pymeId = "pymeId"
    static let isNewUser = "isNewUser"
}

struct KeysValues {
    var userId = UserDefaults.standard.string(forKey: Keys.userId)
    var canUseApp = UserDefaults.standard.bool(forKey: Keys.canUseApp)
    var pymeId = UserDefaults.standard.string(forKey: Keys.pymeId)
    var isNewUser = UserDefaults.standard.bool(forKey: Keys.isNewUser)
}
