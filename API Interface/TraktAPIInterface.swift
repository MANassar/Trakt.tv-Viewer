//
//  TraktAPIInterface.swift
//  Trakt.tv Viewer
//
//  Created by Mohamed Nassar on 7/28/16.
//  Copyright © 2016 Mohamed Nassar. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

let apiKey = "ad005b8c117cdeee58a1bdb7089ea31386cd489b21e14b19818c91511f12a086"
let POPULAR_MOVIES_SUCCESS_NOTIFICATION = "PopMoviesSuccess"

class TraktAPIInterface
{
    let debugMode = true
    
    let baseURL = "https://api.trakt.tv"
    let popularMoviesURL = "/movies/popular"
    
    
    let defaultHeaders = [
        "Content-type":"application/json",
        "trakt-api-key": apiKey,
        "trakt-api-version":"2"
    ]

    
    func getMostPopularMovies(page:Int, limit:Int)
    {
        
        
        var movieArray = [Movie]()
        
        if debugMode
        {
            print("Getting most popular movies")
        }
        
        let urlString = baseURL + popularMoviesURL
        
        debugPrint(urlString)
        //We know this is a GET request
        
        Alamofire.request(.GET, urlString, parameters: ["extended":"full,images", "page":page], headers: defaultHeaders)
            
            .responseJSON
            {
                response in
//                debugPrint(response.request)  // original URL request
//                debugPrint(response.response) // URL response
//                debugPrint(response.data)     // server data
//                debugPrint(response.result)   // result of response serialization
                
                let json = JSON(data:response.data!)
                
//                debugPrint(json)
                
                for i in 0 ..< json.count
                {
                    let movieData = json[i]
                    
                    let currentMovie = Movie()
                    currentMovie.title = movieData["title"].string
                    currentMovie.overView = movieData["overview"].string
                    currentMovie.year = String(movieData["year"].numberValue)
                    currentMovie.posterFullSizeURLString = movieData["images"]["poster"]["full"].string
                    currentMovie.posterThumbnailURLString = movieData["images"]["poster"]["thumb"].string
                    
                    movieArray.append(currentMovie)
                }
                
                NSNotificationCenter.defaultCenter().postNotificationName(POPULAR_MOVIES_SUCCESS_NOTIFICATION, object: movieArray)

        }
    }
}