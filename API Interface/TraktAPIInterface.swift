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
let SEARCH_SUCCESS = "searchSuccessNotification"

class TraktAPIInterface
{
    let debugMode = true
    
    let baseURL = "https://api.trakt.tv"
    let popularMoviesURL = "/movies/popular"
    let searchURL = "/search/"
    
    let defaultHeaders = [
        "Content-type":"application/json",
        "trakt-api-key": apiKey,
        "trakt-api-version":"2"
    ]

    var searchRequest:Alamofire.Request?
    var searchResultArray:[Movie]? //Search results could be anything, a movie, a show, a person, a season, or an epidsode
    
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
            .validate()
            .responseJSON
            {
                response in
                
                switch response.result
                {
                case .Success:
                    print("Request Successful")
                    
                    let json = JSON(data:response.data!)
                    
                    //debugPrint(json)
                    
                    movieArray = self.getMoviesArrayFromJSON(json)
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(POPULAR_MOVIES_SUCCESS_NOTIFICATION, object: movieArray)
                    
                    
                case .Failure(let error):
                    print("Request Failed with error \(error)")
                }
        }
    }
    
    func searchKeyword(keyword:String) //This only gets the first page
    {
                //Cancel the old search request if it still hasnt returned
        if let request = searchRequest
        {
            debugPrint("Cancelling old request")
            request.cancel()
        }
        
        debugPrint("Searching for \(keyword)")
        
        let urlString = baseURL + searchURL
        searchRequest = Alamofire.request(.GET, urlString, parameters: ["extended":"full,images", "type":"movie", "query":keyword], headers: defaultHeaders)
            .validate()
            .responseJSON{
                response in
                
                switch response.result
                {
                case .Success:
                    debugPrint("Request Successful")
                    
                    let searchJSON = JSON(data:response.data!)
                    self.searchResultArray = self.getMoviesArrayFromJSON(searchJSON)
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(SEARCH_SUCCESS, object: self.searchResultArray)
                    
                case .Failure(let error):
                    print("Request Failed with error \(error)")
                }
        }
    }
    
    
    // This function just parses the returned JSON, and produces a movie array ready for display.
    private func getMoviesArrayFromJSON(json:JSON) -> [Movie]
    {
        var parsedMovieArray = [Movie]()
        
        for i in 0 ..< json.count
        {
            let movieData = json[i]
            
            let currentMovie = Movie()
            currentMovie.title = movieData["title"].string
            currentMovie.overView = movieData["overview"].string
            currentMovie.year = String(movieData["year"].numberValue)
            currentMovie.posterFullSizeURLString = movieData["images"]["poster"]["full"].string
            currentMovie.posterThumbnailURLString = movieData["images"]["poster"]["thumb"].string
            
            
            
            parsedMovieArray.append(currentMovie)
        }
        
        return parsedMovieArray
    }
}