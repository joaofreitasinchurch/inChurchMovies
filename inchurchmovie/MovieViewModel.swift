//
//  MovieViewModel.swift
//  inchurchmovie
//
//  Created by João Flavio Cardoso de Freitas Souza on 03/06/25.
//

import Foundation
import Combine

@MainActor
final class MovieViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var errorMessages: String?
    @Published var status: ViewStatus = .none
    @Published private(set) var searchMovies: [Movie] = []
    @Published private(set) var movies: [Movie] = []
    
    // MARK: - Public Properties
    var search: String = ""
    var searchTotalPages: Int = 1
    var searchCurrentPage: Int = 1
    var totalPages: Int = 1
    var currentPage: Int = 1
    
    // MARK: - Private Properties
    private var hasRequestInProgress: Bool = false
    private let movieService = MovieService()
    
    // MARK: - Initialization
    init() {
        Task {
            await fetchMovies()
        }
    }
    
    // MARK: - Public Methods
    func fetchMovies() async {
        
        guard !hasRequestInProgress else {
            return
        }
        
        guard currentPage <= totalPages else {
            return
        }
        
        hasRequestInProgress = true
        status = .loading
        
        do {
            let result = try await movieService.fetchMovies(page: currentPage)
            
            switch result {
            case .success(let newMovies):
                movies.append(contentsOf: newMovies.results.removingDuplicates())
                status = .loaded
                totalPages = newMovies.totalPages
                currentPage += 1
            case .failure(let error):
                errorMessages = error.localizedDescription
                status = .error(error.localizedDescription)
            }
            
            hasRequestInProgress = false
            
        } catch {
            errorMessages = error.localizedDescription
            status = .error(error.localizedDescription)
            hasRequestInProgress = false
        }
    }
    
    func searchMovies(query: String) async {
        
        guard !hasRequestInProgress else {
            return
        }
        
        guard searchCurrentPage <= searchTotalPages else {
            return
        }
        
        hasRequestInProgress = true
        status = .loading
        
        do {
            let result = try await movieService.searchMovies(page: currentPage, query: query)
            
            switch result {
            case .success(let newMovies):
                movies.append(contentsOf: newMovies.results.removingDuplicates())
                print(newMovies.results)
                status = .loaded
                totalPages = newMovies.totalPages
                currentPage += 1
            case .failure(let error):
                errorMessages = error.localizedDescription
                status = .error(error.localizedDescription)
            }
            
            hasRequestInProgress = false
            
        } catch {
            errorMessages = error.localizedDescription
            status = .error(error.localizedDescription)
            hasRequestInProgress = false
        }
    }
}
