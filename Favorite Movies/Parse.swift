//
//  Parse.swift
//  Favorite Movies
//
//  Created by Ana Geórgia Gama on 30/04/17.
//  Copyright © 2017 Ana Geórgia Gama. All rights reserved.
//

import Foundation
import Parse


// MARK: Save movie on DB

func saveMovieOnDB(movieID: String, onCompletion: @escaping (Bool) -> ()) {
    
    let Query: PFQuery = PFQuery(className: "favoriteMoviesCollection")
    Query.whereKey("imdbID", equalTo: movieID)
    
    Query.cachePolicy = .cacheThenNetwork
    
    var isFavorite: Bool = false
    
    Query.findObjectsInBackground { (objects:[PFObject]?, error:Error?) in
        
        if error == nil {
            
            if (objects!.count > 0) {
                isFavorite = true
            }
                
            else {
                
                let object = PFObject(className: "favoriteMoviesCollection")

                object["imdbID"] = movieID
  
                object.saveInBackground(block: {
                    (success: Bool, error: Error?) in
                    
                    if success { print("Movie saved on database!") }
                    
                    else { print(error!) }
                })
            }
        }
        
        else {
            print(error!)
        }
        
        onCompletion(isFavorite)
    }
}


// MARK: Search movie on DB

func getMovieCollection(onCompletion: @escaping ([PFObject]?) -> ()) {
    
    let Query: PFQuery = PFQuery(className: "favoriteMoviesCollection")
    Query.whereKeyExists("imdbID")
    Query.cachePolicy = .cacheThenNetwork
    
    Query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
        
        if (error == nil && objects!.count > 0) {
            onCompletion(objects!)
        }
            
        else if (error != nil) {
            print(error!)
        }
    }
}


// MARK: Remove movie from DB

func removeFromFavorites(movieID: String, onCompletion: @escaping () -> ()) {
    
    let Query: PFQuery = PFQuery(className: "favoriteMoviesCollection")
    Query.whereKey("imdbID", equalTo: movieID)
    Query.cachePolicy = .cacheThenNetwork
    
    Query.findObjectsInBackground() {
        (objects: [PFObject]?, error: Error?) in
        
        if (error == nil && objects!.count > 0) {
            for object: PFObject in objects! {
                object.deleteEventually()
                onCompletion()
            }
        }
        
        else if (error != nil) {
            print(error!)
        }
    }
}
