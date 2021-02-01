//
//  UserModel.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 26/01/2021.
//

import ObjectMapper

class UserModel: Mappable {
        
    var id: String?
    var username: String?
    var email: String?
    var dni: String?
    var type: String?
    var localAutorized: String?

    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id <- map["id"]
        username <- map["username"]
        dni <- map["dni"]
        type <- map["type"]
        email <- map["email"]
        localAutorized <- map["localAutorized"]
    }
    
    func toDictionary() -> NSDictionary {
        return ["id":id as Any,
                "username" : username as Any,
                "email" : email as Any,
                "dni" : dni as Any,
                "type" : type as Any,
                "localAutorized" : localAutorized as Any] as NSDictionary
    }
}

class PointOfSale: Mappable {
    var id: String?
    var name: String?
    var type: String?
    var localized: String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        localized <- map["localized"]
        type <- map["type"]
    }
    
    func toDictionary() -> NSDictionary {
        return ["id":id as Any,
                "name" : name as Any,
                "localized" : localized as Any,
                "type" : type as Any] as NSDictionary
    }
}


enum UserType: Int, RawRepresentable {
    case admin = 0
    case vendor = 1
    
    public typealias RawValue = String
    
    public var rawValue: RawValue {
        switch self {
        case .vendor:
            return "vendor" 
        case . admin:
            return "admin"
        }
    }
    
    public init?(rawValue: RawValue) {
        switch rawValue.lowercased() {
        case "vendor":
            self = .vendor
        case "admin":
            self = .admin
        default:
            self = .vendor
        }
    }
}

enum addType: Int {
    case user = 0
    case pos = 1
}

enum ShowType {
    case phones, accesories
}

enum POSType: Int, RawRepresentable {
    case movil = 0
    case kStatic = 1
    
    public typealias RawValue = String
    
    public var rawValue: RawValue {
        switch self {
        case .kStatic:
            return "fijo"
        case .movil:
            return "movil"
        }
    }
    
    public init?(rawValue: RawValue) {
        switch rawValue.lowercased() {
        case "movil":
            self = .movil
        case "fijo":
            self = .kStatic
        default:
            self = .kStatic
        }
    }
}
