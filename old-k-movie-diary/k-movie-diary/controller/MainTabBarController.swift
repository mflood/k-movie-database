//
//  MainNavigationController.swift
//  k-movie-diary
//
//  Created by Matthew Flood on 4/15/23.
//

import Foundation

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
        
        let logoutButton = UIBarButtonItem(title: "Logout", image: nil, target: self, action: #selector(logout))
        self.navigationItem.leftBarButtonItem = logoutButton
    }

    @objc func logout() {
        TmdbClient.deleteSession(completion: handleDeleteSession)
    }
    
    func handleDeleteSession(errorString: String?) {
        DispatchQueue.main.async {
            let loginViewController = self.storyboard!.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            loginViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            self.present(loginViewController, animated: true)
            // self.present(loginViewController, animated: true)
        }
    }

}
