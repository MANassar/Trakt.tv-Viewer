//
//  Movie.swift
//  Trakt.tv Viewer
//
//  Created by Mohamed Nassar on 7/28/16.
//  Copyright © 2016 Mohamed Nassar. All rights reserved.
//

import Foundation

class MediaShow
{
    var title:String?
    var year:String?
    //    var traktID:Int?
    //    var slug:String?
    //    var imdb:String?
    //    var tmdb:Int?
    var posterFullSizeURLString:String?
    var posterThumbnailURLString:String?
    var overView:String?
}

class Movie:MediaShow
{
    
}

class TVShow:MediaShow
{
}