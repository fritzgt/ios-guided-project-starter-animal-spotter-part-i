//
//  APIController.swift
//  AnimalSpotter
//
//  Created by Ben Gohlke on 4/16/19.
//  Copyright © 2019 BloomTech. All rights reserved.
//

import Foundation
import UIKit

final class APIController {
    
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
    }
    
    enum NetworkError: Error {
        case noData
        case failedSignUp
    }
    
    // API docs: https://github.com/bloominstituteoftechnology/ios-animal-spotter-api
    
    private let baseURL = URL(string: "https://lambdaanimalspotter.herokuapp.cloud/api")!
    private lazy var signUpURL = baseURL.appendingPathComponent("/users/signup")
    private lazy var signInURL = baseURL.appendingPathComponent("/users/login")
    
    // create function for sign up
    func signUp(with user: User, completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        var request = postRequest(for: baseURL)
        
        do {
            //Convert the JSON data into an string
            let jsonData = try JSONEncoder().encode(user)
            print(String(data: jsonData, encoding: .utf8)!)
            request.httpBody = jsonData
            
            URLSession.shared.dataTask(with: request) { _, response, error in
                if let error = error {
                    print("Sign up failed with error: \(error)")
                    completion(.failure(.failedSignUp))
                    return
                }
                
                guard let response = response as? HTTPURLResponse, response.statusCode == 200  else {
                    print("Sign up was unsucessful")
                    completion(.failure(.failedSignUp))
                    return
                }

                completion(.success(true))
                
            }.resume()
            
        } catch  {
            print("🚨 \(error)")
        }
    }
    
    // Helper method for posting
    func postRequest(for url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    // create function for sign in
    
    // create function for fetching all animal names
    
    // create function for fetching animal details
    
    // create function to fetch image
}
