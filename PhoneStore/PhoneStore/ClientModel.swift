//
//  ClientModel.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 16/03/2021.
//

import ObjectMapper

class ClientModel: Mappable {
        
    var name: String?
    var document: Int?
    var phone: String?

    required init?(map: Map) {}
    
    func mapping(map: Map) {
        name <- map["name"]
        document <- map["document"]
        phone <- map["phone"]
    }
    
    func toDictionary(withKey: String) -> NSDictionary {
        return ["key": withKey as Any,
                "name":name as Any,
                "document" : document as Any,
                "phone" : phone as Any] as NSDictionary
    }
}
