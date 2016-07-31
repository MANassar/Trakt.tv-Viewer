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

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate
{
    
    @IBOutlet var tableView: UITableView!
    
    var numberOfSections = 1 //Initially, just the most popular movies
    var currentPage = 1
    
    var moviesArray = [Movie]()
    var searchResultsArray = [Movie]()
    var displayArray = [Movie]()
    
    let apiClient = TraktAPIInterface()
    var searchMode:Bool = false
        {
        didSet{
            if searchMode == true
            {
                debugPrint("Switching to search array")
                self.displayArray = self.searchResultsArray
            }
            
            else
            {
                debugPrint("Switching to movies array")
                self.displayArray = self.moviesArray
            }
            
//            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        apiClient.getMostPopularMovies(currentPage, limit: 10)
        
        self.view.makeToastActivity(.Center)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(gotPopularMovies(_:)), name: POPULAR_MOVIES_SUCCESS_NOTIFICATION, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(gotSearchResults(_:)), name: SEARCH_SUCCESS, object: nil)
    }
    

    func gotPopularMovies(notification:NSNotification)
    {
        debugPrint("Got movies")
        
        self.view.hideToastActivity()
        
        //We append to the array, so if it empty, we just get the initial movies. If not, then we get the next page.
        self.moviesArray.appendContentsOf(notification.object as! [Movie])
        self.displayArray = moviesArray
        tableView.reloadData()
    }
    
    func gotSearchResults(notification:NSNotification)
    {
        debugPrint("Got Search results")
        
        self.view.hideToastActivity()
        
        //We append to the array, so if it empty, we just get the initial movies. If not, then we get the next page.
        self.searchResultsArray.appendContentsOf(notification.object as! [Movie])
        self.displayArray = searchResultsArray
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
            debugPrint("We have \(displayArray.count) movies now")
            return displayArray.count
            
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
            
                let movie = self.displayArray[indexPath.row]
                let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
                
                cell.titleLabel.text = movie.title
                cell.yearLabel.text = movie.year
                cell.overviewTextView.text = movie.overView
                cell.overviewTextView.scrollRangeToVisible(NSMakeRange(0, 10))
                
                cell.posterImageView.sd_setImageWithURL(NSURL(string: movie.posterThumbnailURLString!), completed: nil)
                
                if indexPath.row >= displayArray.count - 1
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
        let movieCell = cell as! MovieCell
        movieCell.overviewTextView.scrollRangeToVisible(NSMakeRange(0, 10))
        
        // Check if this it the last cell
        if indexPath.row >= displayArray.count
        {
            currentPage += 1
            
            debugPrint("Getting more movies, page = \(currentPage)")
            apiClient.getMostPopularMovies(currentPage, limit: 10)
        }
    }
    
    
    //
    // MARK: Search bar delegate
    //
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String)
    {
        if searchText == "" {
            searchMode = false
            self.tableView.reloadData()
        }
        
        else
        {
            self.view.makeToastActivity(.Center)
            apiClient.searchKeyword(searchText)
        }
        
    }
}//end class