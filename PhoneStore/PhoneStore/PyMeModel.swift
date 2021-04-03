//
//  PyMeModel.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 03/04/2021.
//

import ObjectMapper

class PyMeModel: Mappable {
        
    var name: String?
    var cuil: String?
    var localized: String?
    var contact: String?
    var id: String?
    var description: String?

    required init?(map: Map) {}
    
    func mapping(map: Map) {
        name <- map["name"]
        cuil <- map["cuil"]
        localized <- map["localized"]
        contact <- map["contact"]
        id <- map["id"]
        description <- map["description"]
    }
    
    func toDictionary() -> NSDictionary {
        return ["id": id as Any,
                "name":name as Any,
                "cuil" : cuil as Any,
                "localized" : localized as Any,
                "description" : description as Any,
                "contact" : contact as Any] as NSDictionary
    }
}
