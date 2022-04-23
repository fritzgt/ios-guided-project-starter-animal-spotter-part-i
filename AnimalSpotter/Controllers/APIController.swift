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
        case failedSignIn
        case noToken
    }
    
    // API docs: https://github.com/bloominstituteoftechnology/ios-animal-spotter-api
    
    private let baseURL = URL(string: "https://lambdaanimalspotter.herokuapp.com/api")!
    private lazy var signUpURL = baseURL.appendingPathComponent("/users/signup")
    private lazy var signInURL = baseURL.appendingPathComponent("/users/login")
    
    var bearer: Bearer? {
        didSet{
//            UserDefaults.standard.set(bearer?.token, forKey: "lambdaanimalspotterBearer")
        }
    }
    var fullName: PersonNameComponents?
    
    // create function for sign up
    func signUp(with user: User, completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        var request = postRequest(for: signUpURL)
        
        do {
            //Convert the JSON data into an string
            let jsonData = try JSONEncoder().encode(user)
            print(String(data: jsonData, encoding: .utf8)!)
            request.httpBody = jsonData
            
            URLSession.shared.dataTask(with: request) { _, response, error in
                if let error = error {
                    print("🚨 Sign up failed with error: \(error)")
                    completion(.failure(.failedSignUp))
                    return
                }
                
                guard let response = response as? HTTPURLResponse, response.statusCode == 200  else {
                    print("🚨 Sign up was unsucessful")
                    completion(.failure(.failedSignUp))
                    return
                }

                completion(.success(true))
                
            }.resume()
            
        } catch  {
            print("🚨 Error: \(error)")
            completion(.failure(.failedSignUp))
            return
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
    func signIn(with user: User, completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        var request = postRequest(for: signInURL)
        
        do {
            let jsonData = try JSONEncoder().encode(user)
            request.httpBody = jsonData
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(.failedSignIn))
                    print("Sign in failed with error: \(error)")
                    return
                }
                
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    print("🚨 Sign in unsucessful")
                    completion(.failure(.failedSignIn))
                    return
                }
                
                
                guard let data = data else {
                    print("🚨 Data was not received")
                    completion(.failure(.noData))
                    return
                }
                
                do{
                    self.bearer = try JSONDecoder().decode(Bearer.self, from: data)
                    completion(.success(true))
                }catch{
                   print("🚨 Error decoding bearer: \(error)")
                    completion(.failure(.noToken))
                }
            }.resume()
            
        } catch {
            print("🚨 \(error)")
            completion(.failure(.failedSignIn))
        }
    }
    
    // create function for fetching all animal names
    
    // create function for fetching animal details
    
    // create function to fetch image
}
