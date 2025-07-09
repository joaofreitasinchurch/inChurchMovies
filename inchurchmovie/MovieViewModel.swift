//
//  MovieViewModel.swift
//  inchurchmovie
//
//  Created by João Flavio Cardoso de Freitas Souza on 03/06/25.
//

import Foundation
import Combine

final class MovieViewModel: ObservableObject {
    
    @Published var errorMessages: String?
    @Published var status: ViewStatus = .none
    @Published private(set) var searchMovies: [Movie] = []
    @Published private(set) var movies: [Movie] = []
    @Published private(set) var popularMovies: [Movie] = []
    @Published private(set) var trendingMovies: [Movie] = []
    @Published private(set) var upcomingMovies: [Movie] = []
    
    var search: String = ""
    var searchTotalPages: Int = 1
    var searchCurrentPage: Int = 1
    var totalPages: Int = 1
    var currentPage: Int = 1
    var popularTotalPages: Int = 1
    var popularCurrentPage: Int = 1
    var upcomingTotalPages: Int = 1
    var upcomingCurrentPage: Int = 1
    
    private var hasRequestInProgress: Bool = false
    private let movieService = MovieService()
    
    init() {
        Task {
            await fetchMovies()
            await fetchPopularMovies()
            await fetchUpcomingMovies()
        }
    }
    
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
    
    func fetchPopularMovies() async {
        guard !hasRequestInProgress else {
            return
        }
        
        guard popularCurrentPage <= popularTotalPages else {
            return
        }
        
        hasRequestInProgress = true
        status = .loading
        
        do {
            let result = try await movieService.fetchPopularMovies(page: currentPage)
            
            switch result {
            case .success(let newMovies):
                popularMovies.append(contentsOf: newMovies.results.removingDuplicates())
                status = .loaded
                popularTotalPages = newMovies.totalPages
                popularCurrentPage += 1
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
    
    func fetchUpcomingMovies() async {
        
        guard !hasRequestInProgress else {
            return
        }
        
        guard upcomingCurrentPage <= upcomingTotalPages else {
            return
        }
        
        hasRequestInProgress = true
        status = .loading
        
        do {
            let result = try await movieService.fetchUpcomingMovies(page: currentPage)
            
            switch result {
            case .success(let newMovies):
                upcomingMovies.append(contentsOf: newMovies.results.removingDuplicates())
                status = .loaded
                upcomingTotalPages = newMovies.totalPages
                upcomingCurrentPage += 1
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
            let result = try await movieService.searchMovies(page: searchCurrentPage, query: query)
            
            switch result {
            case .success(let newMovies):
                searchMovies.append(contentsOf:newMovies.results.removingDuplicates())
                status = .loaded
                searchTotalPages = newMovies.totalPages
                searchCurrentPage += 1
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
    
    func resetSearch() {
        searchMovies.removeAll()
        searchCurrentPage = 1
        searchTotalPages = 1
    }
}
