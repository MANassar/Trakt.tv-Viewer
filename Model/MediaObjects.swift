//
//  MediaObjects.swift
//  Trakt.tv Viewer
//
//  Created by Mohamed Nassar on 7/29/16.
//  Copyright © 2016 Mohamed Nassar. All rights reserved.
//

import Foundation
import SwiftyJSON

class MediaType
{
    var title:String?
    var year:String?
    var posterFullSizeURLString:String?
    var posterThumbnailURLString:String?
    var overView:String?
    
//    func description() -> String
//    {
//        return "\(title) \(year) \(overView)"
//    }
}

class Movie:MediaType
{
    
    var traktID:Int?
    var slug:String?
    var imdb:String?
    var tmdb:Int?
    
    init(movieData:JSON)
    {
        super.init()
        
        self.title = movieData["title"].string
        self.overView = movieData["overview"].string
        self.year = String(movieData["year"].numberValue)
        self.posterFullSizeURLString = movieData["images"]["poster"]["full"].string
        self.posterThumbnailURLString = movieData["images"]["poster"]["thumb"].string
    }
}

class TVShow:MediaType
{
    var traktID:Int?
    var slug:String?
    var imdb:String?
    var tmdb:Int?
}

class Season
{
    var number:Int?
    var traktID:Int?
    var tvdb:Int?
    var tmdb:Int?
    var tvrage:Int?
}

class Episode
{
    var season:Int?
    var number:Int?
    var title:String?
    var traktID:Int?
}