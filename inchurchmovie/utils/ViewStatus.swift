//
//  ViewStatus.swift
//  inchurchmovie
//
//  Created by João Flavio Cardoso de Freitas Souza on 05/06/25.
//

enum ViewStatus: Equatable {
    case loading
    case loaded
    case loadingMore
    case noResults
    case error(String = .init())
    case clientError(String)
    case success
    case unauthorized
    case none
    case waitingThreeDSecureValidation(id: Int)
    case successfulMigration

    init(error: APIError) {
        self = .error(error.errorDescription)
    }
}
