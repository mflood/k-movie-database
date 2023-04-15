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
            
            // getNewAuthToken(apiKey: apiKeyText, completion: self.handleRequestTokenResponse)
            
            print("apiKeyText: \(apiKeyText)")
        } else {
            showAlert(title: "Empty API Key", message: "Please enter a TMBD API key")
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
                self.showAlert(title: "could not auth", message: errorString!)
            }
            return
        }
        
        // Save this for use after we get callback from Web Auth
        TmdbClient.Auth.requestToken = successReponse.requestToken
        
        let url = TmdbClient.Endpoint.externalUserAuth(requestToken: successReponse.requestToken).url
        
        DispatchQueue.main.async { [self] in
            UIApplication.shared.open(url)
        }
        

        //print("errorString: \(errorString)")
        //print("successReponse: \(successReponse)")
    }
    
    func handleLoginResponse() {
        
        
        
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

