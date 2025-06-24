//
//  Endpoint.swift
//  inchurchmovie
//
//  Created by João Flavio Cardoso de Freitas Souza on 03/06/25.
//
import Foundation

enum Endpoint {
    case fetchMovies(url: String = "/3/movie/popular")
    
    var request: URLRequest? {
        guard let url = self.url else {return nil}
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValues(for: self)
        return request
    }
    
    private var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.themoviedb.org"
        components.path = self.path
        components.queryItems = self.queryItems
        return components.url
    }
    
    private var path: String {
        switch self {
        case .fetchMovies(url: let url):
            return url
        }
    }
    
    private var queryItems: [URLQueryItem]? {
        switch self {
            case .fetchMovies:
            return [
            ]
        }
    }
    
    private var httpMethod: String {
            switch self {
            case .fetchMovies:
                return HTTP.Method.get.rawValue
            }
        }
}

extension URLRequest {
    mutating func addValues(for endpoint: Endpoint) {
        switch endpoint {
        case .fetchMovies:
            self.setValue(HTTP.Headers.Value.applicationJson.rawValue, forHTTPHeaderField: HTTP.Headers.Key.contentType.rawValue)
            self.setValue(Constants.apiKey, forHTTPHeaderField: HTTP.Headers.Key.apiKey.rawValue)
        }
    }
}
