//
//  PyMeModel.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 03/04/2021.
//

import ObjectMapper

class PyMeModel: Mappable {
        
    var name: String?
    var cuil: Int?
    var localized: String?
    var contact: String?

    required init?(map: Map) {}
    
    func mapping(map: Map) {
        name <- map["name"]
        cuil <- map["cuil"]
        localized <- map["localized"]
        contact <- map["contact"]
    }
    
    func toDictionary(withKey: String) -> NSDictionary {
        return ["key": withKey as Any,
                "name":name as Any,
                "cuil" : cuil as Any,
                "localized" : localized as Any,
                "contact" : contact as Any] as NSDictionary
    }
}
