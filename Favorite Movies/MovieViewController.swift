//
//  MovieViewController.swift
//  Favorite Movies
//
//  Created by Ana Geórgia Gama on 26/04/17.
//  Copyright © 2017 Ana Geórgia Gama. All rights reserved.
//

import UIKit
import AlamofireObjectMapper
import Alamofire
import Kingfisher



class MovieViewController: UIViewController, UITabBarControllerDelegate {
    
    @IBOutlet weak var addButton: UIBarButtonItem!

    @IBOutlet weak var movTitleLabel: UILabel!
    @IBOutlet weak var movRuntimeLabel: UILabel!
    @IBOutlet weak var movGenreLabel: UILabel!
    @IBOutlet weak var movPosterImageView: UIImageView!
    @IBOutlet weak var movRatingLabel: UILabel!
    @IBOutlet weak var movReleasedLabel: UILabel!
    @IBOutlet weak var movProductionLabel: UILabel!
    @IBOutlet weak var movDirectorLabel: UILabel!
    @IBOutlet weak var movActorsLabel: UILabel!
    @IBOutlet weak var movPlotTextView: UITextView!
  
    
    var imdbID: String?
    var fromFavorite: Bool = false
    var movieDelegate: MovieDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Tab Bar
        self.tabBarController?.delegate = self
        
        getMovie(imdbID: imdbID!)
    }
    
    
    // Tab tapped goes to root view
    func tabBarController(_ tabBarController: UITabBarController,didSelect viewController: UIViewController) {
        
        let tabBarIndex = tabBarController.selectedIndex
        
        if tabBarIndex == 0 {
            _ = self.navigationController?.popViewController(animated: true)
        }
        else {
            return
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {

        DispatchQueue.main.async {
            let spinnerActivity = MBProgressHUD.showAdded(to: self.view, animated: true)
            spinnerActivity.label.text = "Loading";
            spinnerActivity.isUserInteractionEnabled = false;
        }
    }
    
    
    // MARK: Movie Details
    
    func getMovie(imdbID: String){

        let requestURL = "https://www.omdbapi.com/?i=\(imdbID)"
        
        Alamofire.request(requestURL).responseObject{ (response: DataResponse<Movie>) in

            let movieResult = response.result.value
            let movieDetailed: Movie = Movie()
            
            if let title = movieResult?.title {
                self.movTitleLabel.text = title
                movieDetailed.title = title
            }
            
            if let runtime = movieResult?.runtime {
                self.movRuntimeLabel.text = runtime
                movieDetailed.runtime = runtime
            }
            
            if let genre = movieResult?.genre {
                self.movGenreLabel.text = genre
                movieDetailed.genre = genre
            }
                
            if let plot = movieResult?.plot {
                self.movPlotTextView.text = plot
                movieDetailed.plot = plot
            }
            
            if let rating = movieResult?.imdbRating {
                self.movRatingLabel.text = rating
                movieDetailed.imdbRating = rating
            }
            
            if let director = movieResult?.director {
                self.movDirectorLabel.text = director
                movieDetailed.director = director
            }
                
            if let production = movieResult?.production {
                self.movProductionLabel.text = production
                movieDetailed.production = production
            }
            
            if let actors = movieResult?.actors {
                self.movActorsLabel.text = actors
                movieDetailed.actors = actors
            }
            
            if let released = movieResult?.released {
                self.movReleasedLabel.text = released
                movieDetailed.released = released
            }
            
            if let posterURL = movieResult?.posterURL {
                
                let imgStg: String = posterURL
                let imgURL: URL? = URL(string: imgStg)
                let imgSrc = ImageResource(downloadURL: imgURL!, cacheKey: imgStg)
                
                // Rounded image
                self.movPosterImageView.layer.cornerRadius = self.movPosterImageView.frame.size.width/2
                self.movPosterImageView.clipsToBounds = true
                
                // Image cache with KingFisher
                self.movPosterImageView.kf.setImage(with: imgSrc)
                
                movieDetailed.posterURL = posterURL
                
            }
            
            if let movieImdbID = movieResult?.imdbID {
                movieDetailed.imdbID = movieImdbID
            }

            if self.fromFavorite {
                self.addButton.title = "Remove"
            }
            
            
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
            }
            
            self.movieDelegate?.didGetDetails(movie: movieDetailed)
            
        }//Alamofire.request
        
    }//getMovie()
    
    
    func showAlertButton(tile: String, msg: String) {
        let alert = UIAlertController(title: tile, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    
    // MARK: - Add Button
    
    @IBAction func addAsFavorite(_ sender: Any) {
        
        if (!self.fromFavorite) {

            saveMovieOnDB(movieID: self.imdbID!, onCompletion: {
                (isFavorite) in
                
                if isFavorite {
                    self.showAlertButton(tile: "Error", msg: "You already saved this movie as favorite")
                }
                    
                else {
                    self.showAlertButton(tile: "Saved", msg: "The movie was saved in your favorites list")
                }
                
            })
            
        }
            
        else {
            removeFromFavorites(movieID: self.imdbID!, onCompletion: {
                self.showAlertButton(tile: "Removed", msg: "The movie was removed from favorites list")
            })

        }
    }
    
    
} //MovieControler
    
    

