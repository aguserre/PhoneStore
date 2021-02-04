//
//  ProductModel.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 01/02/2021.
//

import ObjectMapper

class ProductModel: Mappable {
        
    var id: String?
    var localInStock: String?
    var code: String?
    var description: String?
    var color: String?
    var condition: String?
    var priceBuy: Double?
    var priceSale: Double?
    var dateIn: String?
    var dateOut: String?
    var isChecked = false

    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id <- map["id"]
        code <- map["code"]
        description <- map["description"]
        color <- map["color"]
        condition <- map["condition"]
        priceBuy <- map["priceBuy"]
        priceSale <- map["priceSale"]
        dateIn <- map["dateIn"]
        dateOut <- map["dateOut"]
        localInStock <- map["localInStock"]
    }
    
    func toDictionary() -> NSDictionary {
        return ["id":id as Any,
                "code" : code as Any,
                "description" : description as Any,
                "color" : color as Any,
                "condition" : condition as Any,
                "priceBuy" : priceBuy as Any,
                "priceSale" : priceSale as Any,
                "dateIn" : dateIn as Any,
                "dateOut" : dateOut as Any,
                "isChecked" : isChecked as Any,
                "localInStock" : localInStock as Any] as NSDictionary
    }
}
