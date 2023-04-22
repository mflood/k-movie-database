//
//  SettingsViewController.swift
//  k-movie-diary
//
//  Created by Matthew Flood on 4/15/23.
//

import Foundation

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var apiKeyLabel: UILabel!
    @IBOutlet weak var requestTokenLabel: UILabel!
    @IBOutlet weak var sessionIdLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        apiKeyLabel.text = TmdbClient.Auth.apiKey ?? "api"
        requestTokenLabel.text = TmdbClient.Auth.requestToken ?? "api"
        sessionIdLabel.text = TmdbClient.Auth.sessionId ?? "api"
    }


}
