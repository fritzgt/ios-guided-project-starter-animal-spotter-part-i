//
//  LoginViewController.swift
//  AnimalSpotter
//
//  Created by Ben Gohlke on 4/16/19.
//  Copyright © 2019 BloomTech. All rights reserved.
//

import UIKit

enum LoginType {
    case signUp
    case signIn
}

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet private weak var usernameTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var loginTypeSegmentedControl: UISegmentedControl!
    @IBOutlet private weak var signInButton: UIButton!
    @IBOutlet private weak var authStackView: UIStackView!
    
    var apiController: APIController?
    var loginType = LoginType.signUp

    override func viewDidLoad() {
        super.viewDidLoad()

        signInButton.backgroundColor = UIColor(hue: 190/360, saturation: 70/100, brightness: 80/100, alpha: 1.0)
            signInButton.tintColor = .white
            signInButton.layer.cornerRadius = 8.0
    }
    
    // MARK: - Action Handlers
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        // perform login or sign up operation based on loginType
        if let userName = usernameTextField.text, !userName.isEmpty, let password = passwordTextField.text, !password.isEmpty {
            let user = User(username: userName, password: password)
            handleLoginType(user: user)
        }
    }
    
    @IBAction func signInTypeChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            loginType = .signUp
            signInButton.setTitle("Sign Up", for: .normal)
        } else {
            loginType = .signIn
            signInButton.setTitle("Sign In", for: .normal)
        }
    }
    
    //MARK: - Private helper methods
    
    private func handleLoginType(user: User) {
        switch loginType {
        case .signUp:
            signUp(with: user)
        case .signIn:
            signIn(with: user)
        }
    }
    
    private func signUp(with user: User) {
        apiController?.signUp(with: user, completion: { result in
            do {
                let success = try result.get()
                if success {
                    self.showAlert(for: success)
                }
            } catch {
                print("Error signing up: \(error)")
            }
        })
    }
    
    private func signIn(with user: User) {
        apiController?.signIn(with: user, completion: { result in
            do {
                let success = try result.get()
                if success {
                    DispatchQueue.main.async {
                        self.dismiss(animated: true)
                    }
                }
            } catch {
                if let error = error as? APIController.NetworkError {
                    switch error {
                    case .failedSignIn:
                        print("Error signing in: \(error)")
                    case .noData, .noToken:
                        print("No data received")
                    default:
                        print("Other error occur during sign in.")
                    }
                }
            }
        })
    }
    
    private func showAlert(for type: Bool) {
        let successTitle = "Sign Up Successful"
        let successMessage = "Now please log in"
        
        let title = type ? successTitle : successTitle
        let message = type ? successMessage : successMessage
        
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let alertAction = UIAlertAction(title: "Ok", style: .default)
            alertController.addAction(alertAction)
            self.present(alertController, animated: true) {
                self.updateLoginType()
            }
        }
    }
    
    private func updateLoginType() {
        self.loginType = .signIn
        self.loginTypeSegmentedControl.selectedSegmentIndex = 1
        self.signInButton.setTitle("Sign In", for: .normal)
    }
}
