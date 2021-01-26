//
//  UserModel.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 26/01/2021.
//

struct UserModel {

    var username: String?
    var type: UserType?

}

enum UserType {
    case admin, vendor
}

enum ShowType {
    case phones, accesories
}
