//
//  MovieService.swift
//  inchurchmovie
//
//  Created by João Flavio Cardoso de Freitas Souza on 03/06/25.
//

// MovieService.swift
// inchurchmovie

import Foundation

enum MovieServiceError: Error {
    case serviceError(MovieError)
    case unknown(String)
    case invalidResponse
    case invalidData
    case invalidDecoding(String)
}

class MovieService {
    
    static let shared = MovieService()
    
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetchMovies(page: Int) async throws -> APIResult<MovieResponse> {
        let apiKey = "448437debdee32834cb0047792a88c72"
        
        let urlStr =  "https://api.themoviedb.org/3/trending/movie/day?api_key=\(apiKey)&language=pt-BR&page=\(page)"
        
        guard let url = URL(string: urlStr) else {
            throw MovieServiceError.unknown("Invalid URL string")
        }
        
        do {
         let (data, _) = try await session.data(from: url)
        let decodedResponse = try JSONDecoder().decode(MovieResponse.self, from: data)
            return .success(decodedResponse)
        } catch {
            throw MovieServiceError.unknown(error.localizedDescription)
        }
    }
    
    func fetchPopularMovies(page: Int) async throws -> APIResult<MovieResponse> {
        let apiKey = "448437debdee32834cb0047792a88c72"
        
        let urlStr =  "https://api.themoviedb.org/3/movie/popular?api_key=\(apiKey)&language=pt-BR&page=\(page)"
        
        guard let url = URL(string: urlStr) else {
            throw MovieServiceError.unknown("Invalid URL string")
        }
        
        do {
         let (data, _) = try await session.data(from: url)
        let decodedResponse = try JSONDecoder().decode(MovieResponse.self, from: data)
            return .success(decodedResponse)
        } catch {
            throw MovieServiceError.unknown(error.localizedDescription)
        }
    }
    
    func fetchUpcomingMovies(page: Int) async throws -> APIResult<MovieResponse> {
        let apiKey = "448437debdee32834cb0047792a88c72"
        
        let urlStr =  "https://api.themoviedb.org/3/movie/upcoming?api_key=\(apiKey)&language=pt-BR&page=\(page)"
        
        guard let url = URL(string: urlStr) else {
            throw MovieServiceError.unknown("Invalid URL string")
        }
        
        do {
         let (data, _) = try await session.data(from: url)
        let decodedResponse = try JSONDecoder().decode(MovieResponse.self, from: data)
            return .success(decodedResponse)
        } catch {
            throw MovieServiceError.unknown(error.localizedDescription)
        }
    }
    
    func searchMovies(page: Int, query: String) async throws -> APIResult<MovieResponse> {
        let apiKey = "448437debdee32834cb0047792a88c72"
        
        let urlStr =  "https://api.themoviedb.org/3/search/movie?api_key=\(apiKey)&language=pt-BR&query=\(query)&page=\(page)"
        
        guard let url = URL(string: urlStr) else {
            throw MovieServiceError.unknown("Invalid URL string")
        }
        
        do {
         let (data, _) = try await session.data(from: url)
        let decodedResponse = try JSONDecoder().decode(MovieResponse.self, from: data)
            return .success(decodedResponse)
        } catch {
            throw MovieServiceError.unknown(error.localizedDescription)
        }
    }
}



// Adicione uma estrutura para mensagens de erro específicas
struct MovieError: Codable {
    let message: String
}
