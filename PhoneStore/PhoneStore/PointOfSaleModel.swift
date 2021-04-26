//
//  PointOfSaleModel.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 26/04/2021.
//
import ObjectMapper

final class PointOfSale: Mappable {
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
