//
//  ProductModel.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 01/02/2021.
//

import ObjectMapper

class ProductModel: Mappable {
        
    var id: String?
    var productId: String = ""
    var localInStock: String?
    var code: String?
    var description: String?
    var color: String?
    var condition: String?
    var priceBuy: Double?
    var priceSale: Double?
    var dateIn: String?
    var dateOut: String?
    var cantiti: Int?
    var cantitiToSell = 1
    var isChecked = false
    var isRma = false

    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id <- map["id"]
        productId <- map["productId"]
        code <- map["code"]
        description <- map["description"]
        color <- map["color"]
        condition <- map["condition"]
        priceBuy <- map["priceBuy"]
        priceSale <- map["priceSale"]
        dateIn <- map["dateIn"]
        dateOut <- map["dateOut"]
        cantiti <- map["cantiti"]
        isRma <- map["isRma"]
        localInStock <- map["localInStock"]
    }
    
    func toDictionary() -> NSDictionary {
        return ["id":id as Any,
                "productId" : productId as Any,
                "code" : code as Any,
                "description" : description as Any,
                "color" : color as Any,
                "condition" : condition as Any,
                "priceBuy" : priceBuy as Any,
                "priceSale" : priceSale as Any,
                "dateIn" : dateIn as Any,
                "dateOut" : dateOut as Any,
                "isChecked" : isChecked as Any,
                "cantiti" : cantiti as Any,
                "cantitiToSell" : cantitiToSell as Any,
                "isRma" : isRma as Any,
                "localInStock" : localInStock as Any] as NSDictionary
    }
}
