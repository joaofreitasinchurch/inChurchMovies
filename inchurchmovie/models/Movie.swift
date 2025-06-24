//
//  Movie.swift
//  inchurchmovie
//
//  Created by João Flavio Cardoso de Freitas Souza on 03/06/25.
//

struct MovieResponse: Decodable {
    let results: [Movie]
    let page: Int
    let totalPages: Int
    
    enum CodingKeys: String, CodingKey {
        case results
        case page
        case totalPages = "total_pages"
    }
}

struct Movie: Decodable, Hashable {
        let id: Int
        let title: String
        let posterPath: String?
    
    
    enum CodingKeys: String, CodingKey {
            case id, title
            case posterPath = "poster_path"
        }
}
