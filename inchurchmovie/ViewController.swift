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
    private var viewModel: MovieViewModel!
    private var isSearching: Bool {
        return searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true)
    }
    private var loadingContainerView: UIView!
    private var activityIndicator: UIActivityIndicatorView!
    private var loadingLabel: UILabel!
    var cancellables = Set<AnyCancellable>()
    var isCurrentlyLoading: Bool = false
    var timer: Timer!
    var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCollectionView()
        viewModel = MovieViewModel()
        self.setupLoadingView()
        self.viewStatusBinding()
        self.presentLoadingStatus()
        self.setupNavigationBarButton()
        setupSearchController()
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
            searchController.searchBar.placeholder = "Buscar filmes..."
            searchController.searchBar.delegate = self
            searchController.searchBar.searchTextField.isHidden = true

            navigationItem.searchController = searchController
        }


        @objc func searchButtonTapped() {
            print("Botão de busca (lupa) pressionado!")
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
    }
    
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return isSearching ? viewModel.searchMovies.count : viewModel.movies.count
     }

     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MovieCollectionViewCell
             let movie = isSearching ? viewModel.searchMovies[indexPath.row] : viewModel.movies[indexPath.row]
             cell.configure(with: movie)
             return cell
     }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == viewModel.movies.count - 1 {
                  if isSearching
                    {
                      guard let searchText = searchController.searchBar.text else { return }
                        Task {
                          await viewModel.searchMoviesNextPage(query: searchText)
                      }
                      return
                    }
                        Task {
                       await viewModel.fetchMovies()
                        }
               }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigateToDetails(movie: viewModel.movies[indexPath.row])
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
                               print("chamado aqui loaded")
                               self.presentLoadedStatus()
                           default:
                               break
                           }
            }.store(in: &cancellables)
        }

        private func resetViewStatus() {
            collectionView.isHidden = false
            loadingContainerView.isHidden = true
            activityIndicator.stopAnimating()
        }

        private func presentLoadingStatus() {
            collectionView.isHidden = false
            loadingContainerView.isHidden = false
            activityIndicator.startAnimating()
        }
    
    private func presentLoadedStatus() {
        loadingContainerView.isHidden = true
        activityIndicator.stopAnimating()
        if isSearching {
                self.collectionView.reloadData()
                return
            }
            
        let currentItemCount = self.collectionView.numberOfItems(inSection: 0)
        let newItemsCount = viewModel.movies.count
        
        guard newItemsCount > currentItemCount else {
            self.collectionView.reloadData()
            return
        }
        
        var indexPaths = [] as [IndexPath]
        for i in currentItemCount..<newItemsCount {
            indexPaths.append(IndexPath(item: i, section: 0))
        }
        self.collectionView.performBatchUpdates({self.collectionView.insertItems(at: indexPaths)})
       
    }

}

extension ViewController: UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate {

    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        viewModel.resetSearch()
        Task {
                await viewModel.searchMovies(query: searchText)
            }
        self.collectionView.reloadData()
    }
    // MARK: - UISearchBarDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        print("Botão de busca clicado para: \(searchText)")
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("Busca cancelada")
        searchController.searchBar.searchTextField.isHidden = true
    }
}
