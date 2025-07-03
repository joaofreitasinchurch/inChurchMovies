//
//  MovieDetailsViewController.swift
//  inchurchmovie
//
//  Created by João Flavio Cardoso de Freitas Souza on 27/06/25.
//
import UIKit
import Kingfisher

class MovieDetailsViewController: UIViewController
{
    var movieDetails: Movie?
    
    private var gradient: GradientOverlayView = {
        let gradient = GradientOverlayView()
        return gradient
    }()
    
    private var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .black
        return activityIndicator
    }()
    
    private var movieImage = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private var placeHolderView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        
        return view
    }()
    
    lazy var movieTitle: UILabel = {
        let label = UILabel()
        label.text = movieDetails?.title
        label.textColor = .white
        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.numberOfLines = 3
        return label
    }()
    
    lazy var text: UILabel = {
        let label = UILabel()
        label.text = "Details"
        label.textColor = .white
        return label
    }()
    
    lazy var movieOverview: UILabel = {
        let label = UILabel()
        label.text = movieDetails?.overview
        label.textColor = .white
        label.numberOfLines = 5
        label.font = .systemFont(ofSize: 18)
        return label
    }()
    
    lazy var movieReleaseDate: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = movieDetails?.releaseDate
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupViews()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupMovieImage()
    }
    private func setupViews()
    {
        view.backgroundColor = .systemBackground
        activityIndicatorView.startAnimating()
        gradient.addSubview(movieTitle)
        gradient.addSubview(text)
        gradient.addSubview(movieOverview)
        gradient.addSubview(movieReleaseDate)
        view.addSubview(movieImage)
        movieImage.addSubview(gradient)
        gradient.addSubview(placeHolderView)
        placeHolderView.addSubview(activityIndicatorView)
        placeHolderView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        text.translatesAutoresizingMaskIntoConstraints = false
        movieTitle.translatesAutoresizingMaskIntoConstraints = false
        movieOverview.translatesAutoresizingMaskIntoConstraints = false
        movieReleaseDate.translatesAutoresizingMaskIntoConstraints = false
        movieImage.translatesAutoresizingMaskIntoConstraints = false
        gradient.translatesAutoresizingMaskIntoConstraints = false
        setupConstraints()
        
    }
    private func setupMovieImage() {
        self.placeHolderView.frame = self.movieImage.bounds
        let baseURL = "https://image.tmdb.org/t/p/original"
        let finalURL = baseURL + (self.movieDetails?.posterPath ?? "")
        self.movieImage.kf.setImage(with: URL(string: finalURL)) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.placeHolderView.removeFromSuperview()
                self.activityIndicatorView.stopAnimating()
            case .failure:
                self.movieImage.image = UIImage(named: "no_poster")
                self.placeHolderView.removeFromSuperview()
                self.activityIndicatorView.stopAnimating()
            }
            
        }
    }
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            movieImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            movieImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            movieImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            movieImage.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            text.topAnchor.constraint(equalTo: movieImage.bottomAnchor, constant: 20),
            movieTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            movieTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            movieTitle.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 60),
            movieReleaseDate.topAnchor.constraint(equalTo: movieTitle.bottomAnchor, constant: 10),
            movieReleaseDate.leadingAnchor.constraint(equalTo: movieTitle.leadingAnchor),
            movieOverview.topAnchor.constraint(equalTo: movieReleaseDate.bottomAnchor, constant: 40),
            movieOverview.leadingAnchor.constraint(equalTo: movieTitle.leadingAnchor),
            movieOverview.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            gradient.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            gradient.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradient.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gradient.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            placeHolderView.bottomAnchor.constraint(equalTo: gradient.bottomAnchor),
            placeHolderView.topAnchor.constraint(equalTo: gradient.topAnchor),
            placeHolderView.leadingAnchor.constraint(equalTo: gradient.leadingAnchor),
            placeHolderView.trailingAnchor.constraint(equalTo: gradient.trailingAnchor),
            activityIndicatorView.centerXAnchor.constraint(equalTo: placeHolderView.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: placeHolderView.centerYAnchor)
            ])
    }
}

class GradientOverlayView: UIView {

    // Define as cores do gradiente
    var gradientColors: [CGColor] = [
        UIColor.clear.cgColor, // Começa transparente no topo
        UIColor.black.cgColor  // Termina preto sólido no fundo
    ]
    
    // Define a direção do gradiente (de cima para baixo)
    var startPoint: CGPoint = CGPoint(x: 0.5, y: 0.0)
    var endPoint: CGPoint = CGPoint(x: 0.5, y: 1.0)
    
    // Diz ao sistema que a camada principal (layer) desta view É um CAGradientLayer
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    // Este método é chamado quando a view é desenhada. É o lugar perfeito
    // para garantir que nosso gradiente esteja configurado.
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Converte a layer padrão para CAGradientLayer e a configura
        guard let gradientLayer = self.layer as? CAGradientLayer else { return }
        
        gradientLayer.colors = gradientColors
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
    }
}
