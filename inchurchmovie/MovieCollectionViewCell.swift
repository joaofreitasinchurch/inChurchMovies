//
//  MovieCollectionViewCell.swift
//  inchurchmovie
//
//  Created by João Flavio Cardoso de Freitas Souza on 17/06/25.
//
import UIKit
import Kingfisher

class MovieCollectionViewCell: UICollectionViewCell {
    
   
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieImageView: UIImageView!
    private let gradientLayer = CAGradientLayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupPresentation()
    }
    
    func setupPresentation() {
        movieImageView.layer.shadowColor = UIColor.black.cgColor
        movieImageView.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        movieImageView.layer.shadowOpacity = 0.9
        movieImageView.layer.shadowRadius = 25.0
        movieImageView.layer.cornerRadius = 15.0
        movieImageView.clipsToBounds = true
        
        let edgeColor = UIColor.black.withAlphaComponent(0.15).cgColor
                gradientLayer.colors = [edgeColor, UIColor.clear.cgColor, UIColor.clear.cgColor, edgeColor]
                gradientLayer.locations = [0, 0.15, 0.85, 1]
                gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
                gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
                movieImageView.layer.addSublayer(gradientLayer)
    }
    
    func configure(with movie: Movie) {
        movieTitleLabel.text = movie.title
        
        if let posterPath = movie.posterPath {
            let baseURL = "https://image.tmdb.org/t/p/w500"
            let finalImageURL = URL(string: baseURL + (posterPath))
            movieImageView.kf.setImage(with: finalImageURL,
                                       options: [.transition(.fade(0.2))])
        }
        else
        {
            movieImageView.image = UIImage(named: "no_poster")
        }
        
    }

}
