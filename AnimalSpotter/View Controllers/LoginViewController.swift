//
//  LoginViewController.swift
//  AnimalSpotter
//
//  Created by Ben Gohlke on 4/16/19.
//  Copyright © 2019 BloomTech. All rights reserved.
//

import UIKit
import AuthenticationServices

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
        setupProviderLoginView()
        setupUI()
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
                    self.showAlert(success: true)
                }
            } catch {
                print("Error signing up: \(error)")
                self.showAlert(success: false)
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
    
    private func showAlert(success: Bool) {
        let successTitle = "Sign Up Successful"
        let successMessage = "Now please log in"
        
        let failedTitle = "Sign Up Unsuccessful"
        let failedMessage = "Try again later."
        
        let title = success ? successTitle : failedTitle
        let message = success ? successMessage : failedMessage
        
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
    
    func setupUI()  {
        //Button
        signInButton.tintColor = .white
        signInButton.layer.cornerRadius = 5.0
        
        //Segmented control
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        loginTypeSegmentedControl.setTitleTextAttributes(titleTextAttributes, for: .normal)
        
        //Text field
        let userNameText = NSAttributedString(string: "User Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        usernameTextField.attributedPlaceholder = userNameText
        
        let passwordText = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        passwordTextField.attributedPlaceholder = passwordText
        
    }
    
    //MARK: - Sign in with Apple
    
    private func setupProviderLoginView() {
        let button = ASAuthorizationAppleIDButton()
        button.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        self.authStackView.addArrangedSubview(button)
    }
    
    @objc func handleAuthorizationAppleIDButtonPress() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        
        controller.delegate = self
        
        controller.performRequests()
    }
}

//MARK: - ASAuthorizationControllerDelegate

extension LoginViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let bearer = Bearer(token: userIdentifier)
            
            apiController?.bearer = bearer
            if let fullName = fullName {
                apiController?.fullName = fullName
            }

            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
        }
        
        func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            
        }
    }
}
