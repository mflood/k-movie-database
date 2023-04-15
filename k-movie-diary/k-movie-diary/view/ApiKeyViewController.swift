//
//  ApiKeyViewController.swift
//  k-movie-diary
//
//  Created by Matthew Flood on 4/15/23.
//

import UIKit

class ApiKeyViewController: UIViewController {

    @IBOutlet weak var apiKeyTextField: UITextField!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.loadApiKeyValue()
    }
    
    // Load API Key from local storage
    func loadApiKeyValue() {
        if let apiKey = TmdbClient.Auth.apiKey {
            self.apiKeyTextField.text = apiKey
        }
    }
    
    @IBAction func handleStartButtonClicked(_ sender: Any) {
        
        if let apiKeyText = self.apiKeyTextField.text {
            
            TmdbClient.getNewAuthToken(apiKey: apiKeyText,
                                       completion: self.handleRequestTokenResponse)
            print("apiKeyText: \(apiKeyText)")
        } else {
            showAlert(title: "Empty API Key", message: "Please enter a TMBD API key")
        }
    }
    
    @IBAction func handleLoginWithWebClicked(_ sender: Any) {
        if let apiKeyText = self.apiKeyTextField.text {
            
            TmdbClient.getNewAuthToken(apiKey: apiKeyText,
                                       completion: self.handleRequestTokenResponseForWebLogin)
            print("apiKeyText: \(apiKeyText)")
        } else {
            showAlert(title: "Empty API Key", message: "Please enter a TMBD API key")
        }
    }
    
    func handleRequestTokenResponseForWebLogin(successReponse: AuthenticationTokenNewResponseSuccess?, errorString: String?) {
        guard let successReponse = successReponse else {
            DispatchQueue.main.async { [self] in
                self.showAlert(title: "Login Failed", message: errorString!)
            }
            return
        }

        let url = TmdbClient.Endpoint.externalUserAuth(requestToken: successReponse.requestToken).url
        DispatchQueue.main.async { [self] in
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func handleEditingDidEnd(_ sender: Any) {
        if let textfield = sender as? UITextField {
            textfield.resignFirstResponder()
        }
    }
    
    func handleRequestTokenResponse(successReponse: AuthenticationTokenNewResponseSuccess?, errorString: String?) {
        
        guard let successReponse = successReponse else {
            DispatchQueue.main.async { [self] in
                self.showAlert(title: "Login Failed", message: errorString!)
            }
            return
        }
        
        guard let apiKey = TmdbClient.Auth.apiKey else {
            DispatchQueue.main.async { [self] in
                self.showAlert(title: "Login Failed", message: "could not load API Key")
            }
            return
        }
        
        // Save this for use after we log in successfully
        // TmdbClient.Auth.requestToken = successReponse.requestToken
        
        DispatchQueue.main.async {
            TmdbClient.login(apiKey: apiKey,
                             username: self.usernameTextField.text!,
                             password: self.passwordTextField.text!,
                             requestToken: successReponse.requestToken,
                             completion: self.handleLoginResponse)
        }
        
        
        // This was trying to use external Web Login with callback using "kdramadiary" scheme
        // let url = TmdbClient.Endpoint.externalUserAuth(requestToken: successReponse.requestToken).url
        //DispatchQueue.main.async { [self] in
        //    UIApplication.shared.open(url)
        //}
        

        //print("errorString: \(errorString)")
        //print("successReponse: \(successReponse)")
    }
    
    func handleLoginResponse(loginSuccess: LoginResponseSuccess?, errorString: String?) {
        
        if let errorString = errorString {
            DispatchQueue.main.async {
                self.showAlert(title: "Login Failed", message: errorString)
            }
            return
        }
        
        guard let apiKey = TmdbClient.Auth.apiKey else {
            DispatchQueue.main.async { [self] in
                self.showAlert(title: "Login Failed", message: "could not load API Key")
            }
            return
        }
        
        guard let loginSuccess = loginSuccess else {
            DispatchQueue.main.async { [self] in
                self.showAlert(title: "Login Failed", message: "no data in response")
            }
            return
        }
        
        
        
        TmdbClient.newSession(apiKey: apiKey,
                              requestToken: loginSuccess.requestToken,
                              completion: self.handleNewSessionResponse)
        
        print(loginSuccess)
    }
    
    func handleNewSessionResponse(newSessionResponseSuccess: NewSessionResponseSuccess?, errorString: String?) {
        
        if let errorString = errorString {
            DispatchQueue.main.async {
                self.showAlert(title: "Login Failed", message: errorString)
            }
            return
        }
        
        guard let newSessionResponseSuccess = newSessionResponseSuccess else {
            return
        }
        
        TmdbClient.Auth.sessionId = newSessionResponseSuccess.sessionId
        
        if newSessionResponseSuccess.success {
            DispatchQueue.main.async {
                
                //DispatchQueue.main.async {
                //    let otmTabBarController = self.storyboard!.instantiateViewController(withIdentifier: "OtmRootNavigationController") as! UINavigationController
                    
                //    otmTabBarController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
                //    self.present(otmTabBarController, animated: true)
                //}

                self.performSegue(withIdentifier: "SegueToAppRoot", sender: nil)
            }
        }
        
        
        
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        
        // Add an "OK" button to the alert controller
        alertController.addAction(UIAlertAction(title: "OK",
                                                style: .default,
                                                handler: nil))
        
        // Present the alert controller
        present(alertController, animated: true, completion: nil)
    }


}

