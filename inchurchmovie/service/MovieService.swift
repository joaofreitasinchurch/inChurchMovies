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
    private let apiKey = Constants.apiKey
    private let baseURL = Constants.baseURL
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetchMovies(page: Int) async throws -> APIResult<MovieResponse> {
        
        let urlStr =  "\(baseURL)trending/movie/day?api_key=\(apiKey)&language=en-ES&page=\(page)"
        
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
        
        let urlStr =  "\(baseURL)movie/popular?api_key=\(apiKey)&language=en-ES&page=\(page)"
        
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
       
        let urlStr =  "\(baseURL)movie/upcoming?api_key=\(apiKey)&language=en-ES&page=\(page)"
        
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
        
        let urlStr =  "\(baseURL)search/movie?api_key=\(apiKey)&language=en-ES&query=\(query)&page=\(page)"
        
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
