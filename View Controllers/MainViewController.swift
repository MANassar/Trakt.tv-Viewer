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
    @IBOutlet var movieSearchBar: UISearchBar!
    
    var numberOfSections = 1 //Initially, just the most popular movies
    var currentPage = 1
    var currentSearchPage = 1
    
    var moviesArray = [Movie]()
    var searchResultsArray = [Movie]()
    var displayArray = [Movie]()
    
    let apiClient = TraktAPIInterface()
    var searchMode:Bool = false
        {
        didSet
        {
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: true)
            
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
            
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.tableView.scrollsToTop = true
        
        apiClient.getMostPopularMovies(currentPage)
        
        self.view.makeToastActivity(.Center)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(gotPopularMovies(_:)), name: POPULAR_MOVIES_SUCCESS_NOTIFICATION, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(popularMoviesRequestFailed(_:)), name: POPULAR_MOVIES_FAILURE_NOTIFICATION, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(gotSearchResults(_:)), name: SEARCH_SUCCESS_NOTIFICATION, object: nil)
        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(gotSearchResults(_:)), name: SEARCH_FAILED_NOTIFICATION, object: nil)
//        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(gotSearchResults(_:)), name: SEARCH_NO_RESULT_NOTIFICATION, object: nil)
    }
    

    //
    // MARK: Notification handlers
    //
    
    func gotPopularMovies(notification:NSNotification)
    {
        debugPrint("Got movies")

        //We append to the array, so if it empty, we just get the initial movies. If not, then we get the next page.
        self.moviesArray.appendContentsOf(notification.object as! [Movie])
        self.displayArray = moviesArray
        tableView.reloadData()
    }
    
    func gotSearchResults(notification:NSNotification)
    {
        debugPrint("Got Search results")
        
        //We append to the array, so if it empty, we just get the initial movies. If not, then we get the next page.
        self.searchResultsArray = notification.object as! [Movie]
        self.displayArray = searchResultsArray
        tableView.reloadData()
    }
    
    func popularMoviesRequestFailed(notification:NSNotification)
    {
        self.view.hideToastActivity()
        
        let error = notification.object as! NSError
        
        let alert = UIAlertController(title: "Sorry", message: "\(error.localizedDescription). \(error.localizedRecoverySuggestion)\nWould you like to try again?", preferredStyle: .Alert)
        
        let cancel = UIAlertAction(title: "No", style: .Cancel, handler: nil)
        let retry = UIAlertAction(title: "Retry", style: .Default, handler: {
            (action:UIAlertAction!) -> Void in
            self.apiClient.getMostPopularMovies(self.currentPage)
        })
        
        alert.addAction(cancel)
        alert.addAction(retry)
        
        self.presentViewController(alert, animated:true, completion: nil)
    }
    
    func searchRequestFailed(notification:NSNotification)
    {
        debugPrint("Search request failed")
    }
    
    //
    //MARK: Table View Data Source
    //
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        self.view.hideToastActivity()
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
            return searchMode ? "Search Results" : "Most Popular Movies"
            
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
                cell.overviewTextView.scrollRangeToVisible(NSMakeRange(0, 10))
                cell.posterImageView.image = UIImage(named: "Placeholder")
                
                if let posterURL = movie.posterThumbnailURLString {
                    cell.posterImageView.sd_setImageWithURL(NSURL(string: posterURL), completed: nil)
                }
                
                
                if indexPath.row >= displayArray.count - 1
                {
                    self.view.makeToastActivity(.Bottom)
                    
                    if !searchMode
                    {
                        currentPage += 1
                        apiClient.getMostPopularMovies(currentPage)
                        
                        debugPrint("Getting next popular movies page")
                    }
                        
                    else
                    {
                        currentSearchPage += 1
                        apiClient.searchKeyword(movieSearchBar.text!, page:currentSearchPage)
                        
                        debugPrint("Getting next search page")
                    }
                }
                
                return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    
    
    //
    // MARK: Search bar delegate
    //
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String)
    {
        
        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: true)
        
        if searchText == "" {
            searchMode = false
            self.tableView.reloadData()
        }
        
        else
        {
            searchMode = true
//            self.view.makeToastActivity(.Center)
            apiClient.searchKeyword(searchText, page:0)
        }
        
    }
}//end class