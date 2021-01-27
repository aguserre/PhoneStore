//
//  PhoneModel.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 26/01/2021.
//
import ObjectMapper


class PhoneModel: Mappable {

    var id: String?
    var model: String?
    var color: String?
    var vendor: String?
   

    init(){}
    required init?(map: Map) {}

    func mapping(map: Map) {
        id <- map["id"]
        model <- map["model"]
        color <- map["color"]
        vendor <- map["vendor"]
    }
    
    func toDictionary() -> NSDictionary {
        return ["id": id  ?? "",
                "model": model ?? "",
                "color": color ?? "",
                "vendor":vendor ?? ""] as NSDictionary
    }
    
    func toDictionary(id: String, model: String, color: String, vendor: String) -> [String : Any] {
        return ["id": id  ,
                "model": model ,
                "color": color ,
                "vendor":vendor ] as [String : Any]
    }
}

