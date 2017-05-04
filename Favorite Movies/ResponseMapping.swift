//
//  SearchResponse.swift
//  Favorite Movies
//
//  Created by Ana Geórgia Gama on 27/04/17.
//  Copyright © 2017 Ana Geórgia Gama. All rights reserved.
//

import Foundation
import AlamofireObjectMapper
import ObjectMapper


class SearchResponse: Mappable {
    var isSuccess  : Bool?
    var searchArray: [Movie]?
    var searchCount: String?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        isSuccess   <- map["Response"]
        searchArray <- map["Search"]
        searchCount <- map["totalResults"]
    }
}
