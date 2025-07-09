//
//  ViewController.swift
//  inchurchmovie
//
//  Created by João Flavio Cardoso de Freitas Souza on 02/06/25.
//

import UIKit
import Kingfisher
import Combine
import SwiftUI

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var popularCollectionView: UICollectionView!
    @IBOutlet weak var upcomingCollectionView: UICollectionView!
    private var viewModel: MovieViewModel!
    private var isSearching: Bool {
        return searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true)
    }
    @IBOutlet weak var searchCollectionView: UICollectionView!
    private var loadingContainerView: UIView!
    private var activityIndicator: UIActivityIndicatorView!
    private var loadingLabel: UILabel!
    private var timer: Timer?
    var cancellables = Set<AnyCancellable>()
    var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "InChurch Movies"
        self.setupCollectionView()
        viewModel = MovieViewModel()
        self.setupLoadingView()
        self.viewStatusBinding()
        self.setupSearchController()
        self.presentLoadingStatus()
        self.setupNavigationBarButton()
    }
    
    func setupNavigationBarButton() {
            let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchButtonTapped))
            navigationItem.rightBarButtonItem = searchButton
        }
    
    func setupSearchController() {
            searchController = UISearchController(searchResultsController: nil)
            
            searchController.searchResultsUpdater = self
            
            searchController.delegate = self

            searchController.obscuresBackgroundDuringPresentation = false
            searchController.searchBar.placeholder = "Fetch Movies..."
            searchController.searchBar.delegate = self
            searchController.searchBar.searchTextField.isHidden = true

            navigationItem.searchController = searchController
        }


        @objc func searchButtonTapped() {
            searchController.isActive = true
            searchController.searchBar.searchTextField.isHidden = false
        }
    
    private func setupLoadingView() {
            loadingContainerView = UIView()
            loadingContainerView.translatesAutoresizingMaskIntoConstraints = false
            loadingContainerView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            loadingContainerView.layer.cornerRadius = 10
            self.view.addSubview(loadingContainerView)

            activityIndicator = UIActivityIndicatorView(style: .large)
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            activityIndicator.color = .white
            activityIndicator.hidesWhenStopped = true
            loadingContainerView.addSubview(activityIndicator)

            loadingLabel = UILabel()
            loadingLabel.translatesAutoresizingMaskIntoConstraints = false
            loadingLabel.text = "Loading Movies..."
            loadingLabel.textColor = .white
            loadingLabel.textAlignment = .center
            loadingContainerView.addSubview(loadingLabel)

            NSLayoutConstraint.activate([
                loadingContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                loadingContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                loadingContainerView.widthAnchor.constraint(equalToConstant: 150),
                loadingContainerView.heightAnchor.constraint(equalToConstant: 150)
            ])

            NSLayoutConstraint.activate([
                activityIndicator.centerXAnchor.constraint(equalTo: loadingContainerView.centerXAnchor),
                activityIndicator.topAnchor.constraint(equalTo: loadingContainerView.topAnchor, constant: 40)
            ])

            NSLayoutConstraint.activate([
                loadingLabel.centerXAnchor.constraint(equalTo: loadingContainerView.centerXAnchor),
                loadingLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 10),
                loadingLabel.leadingAnchor.constraint(equalTo: loadingContainerView.leadingAnchor, constant: 10),
                loadingLabel.trailingAnchor.constraint(equalTo: loadingContainerView.trailingAnchor, constant: -10)
            ])
            
            loadingContainerView.isHidden = true
        }
}

extension ViewController: UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource,UIScrollViewDelegate {
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        popularCollectionView.delegate = self
        popularCollectionView.dataSource = self
        popularCollectionView.showsHorizontalScrollIndicator = false
        upcomingCollectionView.delegate = self
        upcomingCollectionView.dataSource = self
        upcomingCollectionView.showsHorizontalScrollIndicator = false
        searchCollectionView.delegate = self
        searchCollectionView.dataSource = self
        searchCollectionView.showsVerticalScrollIndicator = false
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            return viewModel.movies.count
        } else if collectionView == popularCollectionView {
            return viewModel.popularMovies.count
        } else if collectionView == upcomingCollectionView {
            return viewModel.upcomingMovies.count
        }
            else if collectionView == searchCollectionView {
                return viewModel.searchMovies.count
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MovieCollectionViewCell
        
        let movie: Movie
        if collectionView == self.collectionView {
            movie = viewModel.movies[indexPath.row]
        } else if collectionView == popularCollectionView {
            movie = viewModel.popularMovies[indexPath.row]
        } else if collectionView == upcomingCollectionView {
            movie = viewModel.upcomingMovies[indexPath.row]
        } else if collectionView == searchCollectionView {
            movie = viewModel.searchMovies[indexPath.row]
        }
        else {
            return cell
        }
        
        cell.configure(with: movie)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let itemCount: Int
        
        if collectionView == self.collectionView {
            itemCount = isSearching ? viewModel.searchMovies.count : viewModel.movies.count
        } else if collectionView == popularCollectionView {
            itemCount = viewModel.popularMovies.count
        } else if collectionView == upcomingCollectionView {
            itemCount = viewModel.upcomingMovies.count
        } else if collectionView == searchCollectionView {
            itemCount = viewModel.searchMovies.count
        }
        else {
            return
        }
        
        if indexPath.row == itemCount - 1 {
            if collectionView == self.searchCollectionView && isSearching {
                guard let searchText = searchController.searchBar.text else { return }
                Task {
                    await viewModel.searchMovies(query: searchText)
                }
            } else if collectionView == self.collectionView {
                Task {
                    await viewModel.fetchMovies()
                }
            } else if collectionView == popularCollectionView {
                Task {
                    await viewModel.fetchPopularMovies()
                }
            } else if collectionView == upcomingCollectionView {
                Task {
                    await viewModel.fetchUpcomingMovies()
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie: Movie
        if collectionView == self.collectionView {
            movie = viewModel.movies[indexPath.row]
        } else if collectionView == popularCollectionView {
            movie = viewModel.popularMovies[indexPath.row]
        } else if collectionView == upcomingCollectionView {
            movie = viewModel.upcomingMovies[indexPath.row]
        } else if collectionView == searchCollectionView {
            movie = viewModel.searchMovies[indexPath.row]
        }
        else {
            return
        }
        navigateToDetails(movie: movie)
    }
    
    func navigateToDetails(movie: Movie) {
        let detailsVC = MovieDetailsViewController()
        
        detailsVC.movieDetails = movie
        navigationController?.pushViewController(detailsVC, animated: true)
    }
}

extension ViewController {
    func viewStatusBinding() {
            viewModel.$status
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self else { return }
                           self.resetViewStatus()
                           switch status {
                           case .loading, .none:
                               self.presentLoadingStatus()
                           case .loaded:
                               self.presentLoadedStatus()
                           default:
                               break
                           }
            }.store(in: &cancellables)
        }

        private func resetViewStatus() {
            if isSearching {
                searchCollectionView.isHidden = false
            } else {
                searchCollectionView.isHidden = true
            }
            collectionView.isHidden = false
            popularCollectionView.isHidden = false
            upcomingCollectionView.isHidden = false
            loadingContainerView.isHidden = true
            activityIndicator.stopAnimating()
        }

        private func presentLoadingStatus() {
            if isSearching {
                searchCollectionView.isHidden = false
            } else {
                searchCollectionView.isHidden = true
            }
            collectionView.isHidden = false
            popularCollectionView.isHidden = false
            upcomingCollectionView.isHidden = false
            loadingContainerView.isHidden = false
            activityIndicator.startAnimating()
        }
    
    private func presentLoadedStatus() {
        loadingContainerView.isHidden = true
        activityIndicator.stopAnimating()
        
        if isSearching {
            updateCollectionViewData(collectionView: self.searchCollectionView,
                                     currentCount: self.searchCollectionView.numberOfItems(inSection: 0),
                                     newCount: viewModel.searchMovies.count)
            self.collectionView.isHidden = true
            self.popularCollectionView.isHidden = true
            self.upcomingCollectionView.isHidden = true
            return
        }
        else {
            self.searchCollectionView.isHidden = true
        }
        print("Update Collection View Data chamado")
        updateCollectionViewData(collectionView: self.collectionView,
                               currentCount: self.collectionView.numberOfItems(inSection: 0),
                               newCount: viewModel.movies.count)
        
        updateCollectionViewData(collectionView: popularCollectionView,
                               currentCount: popularCollectionView.numberOfItems(inSection: 0),
                               newCount: viewModel.popularMovies.count)
        
        updateCollectionViewData(collectionView: upcomingCollectionView,
                               currentCount: upcomingCollectionView.numberOfItems(inSection: 0),
                               newCount: viewModel.upcomingMovies.count)
    }

    private func updateCollectionViewData(collectionView: UICollectionView, currentCount: Int, newCount: Int) {
        guard newCount > currentCount else {
            collectionView.reloadData()
            return
        }
        
        var indexPaths: [IndexPath] = []
        for i in currentCount..<newCount {
            indexPaths.append(IndexPath(item: i, section: 0))
        }
        
        collectionView.performBatchUpdates({
            collectionView.insertItems(at: indexPaths)
        })
    }

}

extension ViewController: UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate {

    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        var interval = 0.5
        if searchText.isEmpty {
            interval = 0.0
        }
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            guard let self else { return }
            
            self.viewModel.resetSearch()
                Task {
                    await self.viewModel.searchMovies(query: searchText)
                    }
           
            self.searchCollectionView.reloadData()
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchController.searchBar.searchTextField.isHidden = true
    }
}
