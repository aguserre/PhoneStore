//
//  ReplacementModel.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 26/01/2021.
//

import ObjectMapper


class ReplacementModel: Mappable {

    var description: String?

    init(){}
    required init?(map: Map) {}

    func mapping(map: Map) {
        description <- map["description"]
    }
}
