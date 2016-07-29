//
//  TraktAPIInterface.swift
//  Trakt.tv Viewer
//
//  Created by Mohamed Nassar on 7/28/16.
//  Copyright © 2016 Mohamed Nassar. All rights reserved.
//

import Foundation
import Alamofire

let apiKey = "ad005b8c117cdeee58a1bdb7089ea31386cd489b21e14b19818c91511f12a086"

class TraktAPIInterface
{
 
    
    
    let debugMode = true
    
    let baseURL = "https://api.trakt.tv"
    let expansionEndURL = "?extended={full,images}"
    let popularMoviesURL = "/movies/popular"
    
    
    let defaultHeaders = [
        "Content-type":"application/json",
        "trakt-api-key": apiKey,
        "trakt-api-version":"2"
    ]
    
    
    //
    // Helper method to prepare request and add default headers
    //
    
//    func prepareRequest(type:String, endURLString:String, parameters:[String:String]) ->
//    {
//        
//    }
    
    func getMostPopularMovies(page:Int, limit:Int) -> [Movie]
    { //We know this is a GET request
        
        if debugMode
        {
            print("Getting most popular movies")
        }
        
        
        
        
        
        let movie = Movie()
        
        movie.title = "Batman Begins"
        movie.year = "2005"
        movie.overView = "Some awesome movie"
        
        return [movie]
    }
}