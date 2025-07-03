//
//  MovieDetailsSceneDelegate.swift
//  inchurchmovie
//
//  Created by João Flavio Cardoso de Freitas Souza on 30/06/25.
//
import UIKit

class MovieDetailsSceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = MovieDetailsViewController()
        window?.makeKeyAndVisible()
    }
}
