//
//  MainViewController.swift
//  Trakt.tv Viewer
//
//  Created by Mohamed Nassar on 7/27/16.
//  Copyright © 2016 Mohamed Nassar. All rights reserved.
//

import Foundation
import UIKit

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
    var moviesArray:[Movie] = []
    let apiClient = TraktAPIInterface()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
//        moviesArray = apiClient.getMostPopularMovies(0)
        apiClient.getMostPopularMovies(0, limit: 10)
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
            return moviesArray.count
            
        default:
            return 0
        }//end switch
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        switch indexPath.section
        {
        case 0: //Movies
            
                let movie = self.moviesArray[indexPath.row]
                let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
                
                cell.titleLabel.text = "Movie Title"
                cell.yearLabel.text = "3000"
                cell.overviewTextView.text = "This is some awesome movie"
                return cell
            
        default:
            return UITableViewCell()
        }
    }
    
}//end class