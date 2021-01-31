//
//  MovementsModel.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 27/01/2021.
//

import ObjectMapper

class MovementsModel: Mappable {

    @objc dynamic var id: String?
    @objc dynamic var productDescription: String?
    @objc dynamic var movementType: String?

    required init?(map: Map) {}

    func mapping(map: Map) {
        id <- map["id"]
        productDescription <- map["productDescription"]
        movementType <- map["movementType"]
    }
    
    func toDictionary() -> NSDictionary {
        return ["id": id  ?? "",
                "productDescription": productDescription ?? "",
                "movementType": movementType ?? ""] as NSDictionary
    }
    
}
