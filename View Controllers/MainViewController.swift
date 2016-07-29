//
//  MainViewController.swift
//  Trakt.tv Viewer
//
//  Created by Mohamed Nassar on 7/27/16.
//  Copyright © 2016 Mohamed Nassar. All rights reserved.
//

import Foundation
import UIKit
import Toast_Swift

class MovieCell:UITableViewCell
{
    @IBOutlet var posterImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var yearLabel: UILabel!
    @IBOutlet var overviewTextView: UITextView!
}

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    
    @IBOutlet var tableView: UITableView!
    
    var numberOfSections = 1 //Initially, just the most popular movies
    var currentPage = 1
    var moviesArray:[Movie] = []
    let apiClient = TraktAPIInterface()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
//        moviesArray = apiClient.getMostPopularMovies(0)
        apiClient.getMostPopularMovies(currentPage, limit: 10)
        
        self.view.makeToastActivity(.Center)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(gotPopularMovies(_:)), name: POPULAR_MOVIES_SUCCESS_NOTIFICATION, object: nil)
    }
    

    func gotPopularMovies(notification:NSNotification)
    {
        debugPrint("Got movies")
        
        self.view.hideToastActivity()
        
        //We append to the array, so if it empty, we just get the initial movies. If not, then we get the next page.
        self.moviesArray.appendContentsOf(notification.object as! [Movie])
        
        tableView.reloadData()
    }
    
    //
    //MARK: Table View Data Source
    //
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return numberOfSections
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch section
        {
        case 0:
            debugPrint("We have \(moviesArray.count) movies now")
            return moviesArray.count
            
        default:
            return 0
        }//end switch
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        switch section
        {
        case 0:
            return "Most Popular Movies"
            
        default:
            return ""
        }//end switch
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        switch indexPath.section
        {
        case 0: //Movies
            
                let movie = self.moviesArray[indexPath.row]
                let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
                
                cell.titleLabel.text = movie.title
                cell.yearLabel.text = movie.year
                cell.overviewTextView.text = movie.overView
                cell.overviewTextView.scrollRangeToVisible(NSMakeRange(0, 10))
                
//                let block: SDWebImageCompletionBlock! = {(image: UIImage!, error: NSError!, cacheType: SDImageCacheType, imageURL: NSURL!) -> Void in
//                    //			println(self)
//                }
                
                cell.posterImageView.sd_setImageWithURL(NSURL(string: movie.posterThumbnailURLString!), completed: nil)
                
                if indexPath.row >= moviesArray.count - 1
                {
                    currentPage += 1
                    self.view.makeToastActivity(.Bottom)
                    debugPrint("Getting more movies, page = \(currentPage)")
                    apiClient.getMostPopularMovies(currentPage, limit: 10)
                }
                
                return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    //
    // MARK: Table View Delegate
    //
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    {
        // Check if this it the last cell
        if indexPath.row >= moviesArray.count
        {
            currentPage += 1
            
            debugPrint("Getting more movies, page = \(currentPage)")
            apiClient.getMostPopularMovies(currentPage, limit: 10)
        }
    }
    
}//end class