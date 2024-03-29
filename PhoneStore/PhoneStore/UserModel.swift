//
//  UserModel.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 26/01/2021.
//

import ObjectMapper

final class UserModel: Mappable {
        
    var id: String?
    var username: String?
    var email: String?
    var dni: String?
    var type: String?
    var localAutorized: [String]?
    var pyme: String?

    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id <- map["id"]
        username <- map["username"]
        dni <- map["dni"]
        type <- map["type"]
        email <- map["email"]
        pyme <- map["pymeId"]
        localAutorized <- map["localAutorized"]
    }
    
    func toDictionary() -> NSDictionary {
        return ["id":id as Any,
                "username" : username as Any,
                "email" : email as Any,
                "dni" : dni as Any,
                "type" : type as Any,
                "pymeId" : pyme as Any,
                "localAutorized" : localAutorized as Any] as NSDictionary
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
