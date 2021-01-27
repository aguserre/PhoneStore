//
//  ReplacementModel.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 26/01/2021.
//

import ObjectMapper
import RealmSwift


class ReplacementModel: Object, Mappable {

    @objc dynamic var descriptions: String?

    override init(){}
    required init?(map: Map) {}

    func mapping(map: Map) {
        descriptions <- map["descriptions"]
    }
    func toDictionary() -> NSDictionary {
        return ["descriptions": descriptions  ?? ""] as NSDictionary
    }
    
}
