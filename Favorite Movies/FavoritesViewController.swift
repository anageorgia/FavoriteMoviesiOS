//
//  FavoritesViewController.swift
//  Favorite Movies
//
//  Created by Ana Geórgia Gama on 03/05/17.
//  Copyright © 2017 Ana Geórgia Gama. All rights reserved.
//

import UIKit
import Parse
import Kingfisher
import AlamofireObjectMapper
import Alamofire


protocol MovieDelegate {
    func didGetDetails(movie: Movie)
}


class FavoritesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    @IBOutlet weak var favCollectionView: UICollectionView!
    
    var movies = [Movie]()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.favCollectionView.delegate = self
        self.favCollectionView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Loading start
        DispatchQueue.main.async {
            let spinnerActivity = MBProgressHUD.showAdded(to: self.view, animated: true)
            spinnerActivity.label.text = "Loading";
            spinnerActivity.isUserInteractionEnabled = false;
        }
        
        
        getMovieCollection(onCompletion: {
            (objects) in
            
            var moviesIDs = [String]()
            var auxArray = [Movie]()

            
            //Getting the IDs saved in my database
            for obj: PFObject in objects! {
                moviesIDs.append(obj["imdbID"] as! String)
            }
            
            //For each ID, search for the movie on API
            for movieID: String in moviesIDs {

                let requestURL = "https://www.omdbapi.com/?i=\(movieID)"
                
                Alamofire.request(requestURL).responseObject{ (response: DataResponse<Movie>) in

                    let movieResult = response.result.value
                    let movie: Movie = Movie()
                    
                    if let title = movieResult?.title {
                        movie.title = title
                    }
                    
                    if let posterURL = movieResult?.posterURL {
                        movie.posterURL = posterURL
                    }
                    
                    if let imdbID = movieResult?.imdbID {
                        movie.imdbID = imdbID
                    }
                    
                    auxArray.append(movie)
                    
                    DispatchQueue.main.async {
                        self.movies = auxArray.sorted{ $0.title! < $1.title! }
                        self.favCollectionView.reloadData()
                    }

                }

            }

        })
        
        // Loading hide
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true);
        }

    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.movies.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = favCollectionView.dequeueReusableCell(withReuseIdentifier: "FavCollectionCell", for: indexPath) as! FavoritesCollectionViewCell
        
        let movie = movies[indexPath.row]
        
        let imgStg: String = movie.posterURL!
        let imgURL: URL? = URL(string: imgStg)
        let imgSrc = ImageResource(downloadURL: imgURL!, cacheKey: imgStg)
        
        cell.favTitleLabel.text = movie.title
        
        cell.favPosterImageView.layer.cornerRadius = cell.favPosterImageView.frame.size.width/2
        cell.favPosterImageView.clipsToBounds = true
        
        //image cache with KingFisher
        cell.favPosterImageView.kf.setImage(with: imgSrc)
        
        return cell
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 
        if segue.identifier == "segueFromFavorites" {

            if let destination = segue.destination as? MovieViewController {
                let cell = sender as! FavoritesCollectionViewCell
                let indexPath = self.favCollectionView!.indexPath(for: cell)?.row
                let movieSelectedID = self.movies[indexPath!].imdbID

                destination.imdbID = movieSelectedID!
                destination.fromFavorite = true

            }
        }
    }
    
    

}
