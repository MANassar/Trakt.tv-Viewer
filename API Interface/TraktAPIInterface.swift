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
let POPULAR_MOVIES_FAILURE_NOTIFICATION = "PopMoviesFailed"
let SEARCH_SUCCESS_NOTIFICATION = "SearchSuccessNotification"
let SEARCH_FAILED_NOTIFICATION = "SearchFailedNotification"
let SEARCH_NO_RESULT_NOTIFICATION = "SearchNoResultsNotification"

class TraktAPIInterface
{
    let defaultLimit = 10
    
    let baseURL = "https://api.trakt.tv"
    let popularMoviesURL = "/movies/popular"
    let searchURL = "/search/"
    
    let defaultHeaders = [
        "Content-type":"application/json",
        "trakt-api-key": apiKey,
        "trakt-api-version":"2"
    ]

    var searchRequest:Alamofire.Request?
    var searchResultArray = [Movie]() //Search results could be anything, a movie, a show, a person, a season, or an epidsode
    
    func startNetworkMonitor()
    {
//        NetworkReachabilityManager.st
    }
    
    func getMostPopularMovies(page:Int)
    {
        var movieArray = [Movie]()
        
        debugPrint("Getting most popular movies")
            
        let urlString = baseURL + popularMoviesURL
        
        debugPrint(urlString)
        //We know this is a GET request
        
        let moviesRequest = Alamofire.request(.GET, urlString, parameters: ["extended":"full,images", "page":page, "limit":defaultLimit], headers: defaultHeaders)
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
                    NSNotificationCenter.defaultCenter().postNotificationName(POPULAR_MOVIES_FAILURE_NOTIFICATION, object: error)
                }
        }
    }
    
    func searchKeyword(keyword:String, page:Int)
    {
        
        //Reset the array if we're making a new search.
        if page < 2 {
            searchResultArray.removeAll()
        }
        
        //Cancel the old search request if it still hasnt returned
        if let request = searchRequest
        {
            debugPrint("Cancelling old request")
            request.cancel()
        }
        
        debugPrint("Searching for \(keyword)")
        
        let urlString = baseURL + searchURL
        searchRequest = Alamofire.request(.GET, urlString, parameters: ["extended":"full,images", "type":"movie", "query":keyword, "page":page, "limit":defaultLimit], headers: defaultHeaders)
            .validate()
            .responseJSON{
                response in
                
                switch response.result
                {
                case .Success:
                    debugPrint("Request Successful")
                    
                    let searchJSON = JSON(data:response.data!)
                    
                    if searchJSON.count == 0 //Empty search
                    {
                        NSNotificationCenter.defaultCenter().postNotificationName(SEARCH_NO_RESULT_NOTIFICATION, object: nil)
                    }
                    
                    for i in 0 ..< searchJSON.count
                    {
                        let searchResult = searchJSON[i]
                        let searchMoviesJSON = searchResult["movie"]
                        
                        let currentMovie = Movie(movieData: searchMoviesJSON)
                        
//                        debugPrint(currentMovie)
                        
                        self.searchResultArray.append(currentMovie)
                    }
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(SEARCH_SUCCESS_NOTIFICATION, object: self.searchResultArray)
                    
                case .Failure(let error):
                    print("Request Failed with error \(error)")
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(SEARCH_NO_RESULT_NOTIFICATION, object: nil)
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
            let currentMovie = Movie(movieData: movieData)
            parsedMovieArray.append(currentMovie)
        }
        
        return parsedMovieArray
    }
}