//
//  MovementsModel.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 27/01/2021.
//

import ObjectMapper

class MovementsModel: Mappable {

    var id: String?
    var products: [NSDictionary]?
    var movementType: String?
    var localId: String?
    var code: String?
    var condition: String?
    var totalAmount: Double?
    var dateOut: String?
    var cantitiPurchase: Int?
    var client: NSDictionary?
    

    required init?(map: Map) {}

    func mapping(map: Map) {
        id <- map["id"]
        products <- map["products"]
        movementType <- map["movementType"]
        localId <- map["localId"]
        code <- map["code"]
        condition <- map["condition"]
        totalAmount <- map["totalAmount"]
        dateOut <- map["dateOut"]
        cantitiPurchase <- map["cantitiPurchase"]
        client <- map["client"]
    }
    
    func toDictionary() -> NSDictionary {
        return ["id": id  ?? "",
                "products": products ?? [:],
                "movementType": movementType ?? "",
                "localId": localId as Any,
                "code" : code as Any,
                "condition" : condition as Any,
                "totalAmount" : totalAmount as Any,
                "dateOut" : dateOut as Any,
                "client" : client as Any,
                "cantitiPurchase" : cantitiPurchase as Any] as NSDictionary
    }
    
}

enum MovementType: String {
    case out, new
    
    public typealias RawValue = String
    
    public var rawValue: RawValue {
        switch self {
        case .out:
            return "out"
        case .new:
            return "in"
        }
    }
    
    public init?(rawValue: RawValue) {
        switch rawValue {
        case "out":
            self = .out
        case "in":
            self = .new
        default:
            self = .new
        }
    }
}
