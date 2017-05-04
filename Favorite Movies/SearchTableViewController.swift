//
//  SearchTableViewController.swift
//  Favorite Movies
//
//  Created by Ana Geórgia Gama on 28/04/17.
//  Copyright © 2017 Ana Geórgia Gama. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper
import ObjectMapper
import Kingfisher



class SearchTableViewController: UITableViewController, UISearchResultsUpdating {

    
    @IBOutlet var searchTableView: UITableView!
    
    var movies: [Movie]?
    
    
    // MARK: SearchBar
    
    @IBAction func showResults(_ sender: Any) {
        let searchController = UISearchController(searchResultsController: nil)
        self.present(searchController, animated: true, completion: nil)
        searchController.searchBar.barTintColor = self.searchTableView.backgroundColor!
        searchController.searchResultsUpdater = self
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTableView.dataSource = self
        searchTableView.delegate = self
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let searchText = searchController.searchBar.text, searchText != "" else {
            return
        }
        
        let movieSearched: String = searchText.replacingOccurrences(of: " ", with: "_")
        
        
        // MARK: Alamofire search by title
        
        let URL = "https://www.omdbapi.com/?s=\(movieSearched)&type=movie"
        
        Alamofire.request(URL).responseObject{ (response: DataResponse<SearchResponse>) in
            
            // Loading start
            DispatchQueue.main.async {
                let spinnerActivity = MBProgressHUD.showAdded(to: self.view, animated: true)
                spinnerActivity.label.text = "Loading";
                spinnerActivity.detailsLabel.text = "Searching movie..."
                spinnerActivity.isUserInteractionEnabled = false;
            }

            switch response.result {
            case .success(let value):
                let searchResponse = value
                self.movies = (searchResponse.searchArray)
                self.searchTableView.reloadData()

            case .failure(let error):
                let alert = UIAlertController(title: "Error", message: "Error 4xx / 5xx: \(error)", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
            //Loading hide
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
            }
            
        } // Alamofire.request

    } // func UpdateResults
    

    
    // MARK: Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        if let safeMovies = movies {
            if safeMovies.count > 0 {
                self.tableView.backgroundView = nil
                self.tableView.separatorStyle = .singleLine
                return 1
            }
        }
  
        // Setting message for empty tableView
        let rect = CGRect(x: 0,
                          y: 0,
                          width: self.tableView.bounds.size.width,
                          height: self.tableView.bounds.size.height)
        let noDataLabel: UILabel = UILabel(frame: rect)
        noDataLabel.text = "No results"
        noDataLabel.textAlignment = .center
        noDataLabel.textColor = UIColor.gray
        noDataLabel.sizeToFit()
        
        self.tableView.backgroundView = noDataLabel
        self.tableView.separatorStyle = .none
        
        return 0
    
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let safeMovies = movies {
            return safeMovies.count
        }
        else {
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCellIdentifier", for: indexPath) as! SearchTableViewCell
        
        let movie = movies?[indexPath.row]
        
        let imgStg: String = movie!.posterURL!
        let imgURL: URL? = URL(string: imgStg)
        let imgSrc = ImageResource(downloadURL: imgURL!, cacheKey: imgStg)

        
        cell.titleLabel.text = movie?.title
        cell.yearLabel.text = movie?.year
        
        // Rounded image
        cell.posterImageView.layer.cornerRadius = cell.posterImageView.frame.size.width/2
        cell.posterImageView.clipsToBounds = true
        
        //image cache with KingFisher
        cell.posterImageView.kf.setImage(with: imgSrc)
        
        return cell
    }
    
    
    // MARK: Navigation
    
    let searchSegue = "segueFromSearch"
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let searchIndex = tableView.indexPathForSelectedRow?.row
        let movie = movies?[searchIndex!]
        let selectedImdbID = movie?.imdbID
        
        if segue.identifier == searchSegue {
            if let destination = segue.destination as? MovieViewController {
                
                destination.imdbID = selectedImdbID!
                
            }
            
        }// segue.identifier
        
    }// func prepare segue
    
}// Search tableViewController
