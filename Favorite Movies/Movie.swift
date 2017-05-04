//
//  Movie.swift
//  Favorite Movies
//
//  Created by Ana Geórgia Gama on 27/04/17.
//  Copyright © 2017 Ana Geórgia Gama. All rights reserved.
//

import Foundation
import ObjectMapper
import AlamofireObjectMapper


class Movie: Mappable {
    
    var posterURL  : String?
    var title      : String?
    var runtime    : String?
    var director   : String?
    var actors     : String?
    var genre      : String?
    var plot       : String?
    var production : String?
    var released   : String?
    var year       : String?
    var imdbID     : String?
    var imdbRating : String?
    
    init() { }
    
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        posterURL  <- map["Poster"]
        title      <- map["Title"]
        runtime    <- map["Runtime"]
        director   <- map["Director"]
        actors     <- map["Actors"]
        genre      <- map["Genre"]
        plot       <- map["Plot"]
        production <- map["Production"]
        released   <- map["Released"]
        year       <- map["Year"]
        imdbID     <- map["imdbID"]
        imdbRating <- map["imdbRating"]
    }
}




