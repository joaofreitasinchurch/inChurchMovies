//
//  ImageService.swift
//  inchurchmovie
//
//  Created by João Flavio Cardoso de Freitas Souza on 05/06/25.
//
import Foundation

class ImageService {
    func loadImage(from urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw MovieServiceError.unknown("Invalid URL string")
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        } catch {
            throw MovieServiceError.unknown(error.localizedDescription)
        }
    }
}
