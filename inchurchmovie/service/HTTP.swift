//
//  HTTP.swift
//  inchurchmovie
//
//  Created by João Flavio Cardoso de Freitas Souza on 03/06/25.
//

import Foundation

enum HTTP {
    
    enum Method: String {
        case get = "GET"
        case post = "POST"
    }
    
    enum Headers {
        
        enum Key: String {
            case contentType = "Content-Type"
            case apiKey = "Your Api Key"
        }
        
        enum Value: String {
            case applicationJson = "application/json"
        }
    }
}
