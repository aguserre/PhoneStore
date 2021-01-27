//
//  PhoneModel.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 26/01/2021.
//
import ObjectMapper
import RealmSwift

class PhoneModel: Object, Mappable {

    @objc dynamic var id: String?
    @objc dynamic var model: String?
    @objc dynamic var color: String?
    @objc dynamic var vendor: String?
   

    override init(){}
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
    
}

