//
//  PhoneModel.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 26/01/2021.
//
import ObjectMapper


class PhoneModel: Mappable {

    var model: String?
    var color: String?
    var vendor: String?
   

    init(){}
    required init?(map: Map) {}

    func mapping(map: Map) {
        model <- map["model"]
        color <- map["color"]
        vendor <- map["vendor"]
    }
}

