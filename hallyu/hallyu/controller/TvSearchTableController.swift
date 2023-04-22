//
//  TvSearchTableController.swift
//  hallyu
//
//  Created by Matthew Flood on 4/22/23.
//

import Foundation


import UIKit

class TvSearchTableController: UIViewController {

    @IBOutlet weak var tvTableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!

    var isLoading = false
    var currentSearchTerm: String? = nil
    var tvSearchResponse: TvSearchResponse? = nil
    var tvListResults: [TvListResultObject] = []
    
    @IBAction func handleSearchTextValueChanged(_ sender: Any) {


    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.tvTableView.delegate = self
        self.tvTableView.dataSource = self
        
        self.unsubscribeFromKeyboardNotifications()
        self.subscribeToKeyboardNotifications()
    }
    
    @IBAction func handleSearchButtonClicked(_ sender: Any) {
        self.searchTextField.resignFirstResponder()
        
        guard let searchText = self.searchTextField.text,
              searchText != "" else {
            return
        }
        
        guard self.isLoading == false else {
            return
        }

        self.isLoading = true
        self.currentSearchTerm = searchText
        TmdbClient.searchTv(query:searchText, page: 1, completion: handleSearchResponse)
    }
    
    func handleSearchResponse(tvSearchResponse: TvSearchResponse?, errorString: String?) {
        
        self.tvSearchResponse = tvSearchResponse
                
        DispatchQueue.main.async { [self] in
            if let errorString = errorString {
                self.showAlert(title: "Search Error", message: errorString)
            } else if let tvSearchResponse = tvSearchResponse {
                if tvSearchResponse.totalResults == 0 {
                    self.showAlert(title: "Search Error", message: "No results")
                }
                
                if tvSearchResponse.page > 1 {
                    self.tvListResults.append(contentsOf: tvSearchResponse.results)
                } else {
                    self.tvListResults = tvSearchResponse.results
                }
            }
            
            self.tvTableView.reloadData()
            self.isLoading = false
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


    
    
     // MARK: - Keyboard adjusts view position
     
     func subscribeToKeyboardNotifications() {

         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
         
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
     }

     func unsubscribeFromKeyboardNotifications() {

         NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
             
             NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
     }
     
     @objc func keyboardWillShow(_ notification:Notification) {
         view.frame.origin.y = -getKeyboardHeight(notification)
     }
     
     @objc func keyboardWillHide(_ notification:Notification) {
         view.frame.origin.y = 0
     }

     func getKeyboardHeight(_ notification:Notification) -> CGFloat {

         let userInfo = notification.userInfo
         let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
         return keyboardSize.cgRectValue.height
     }
  
}

extension TvSearchTableController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(tvListResults.count)
        return tvListResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        let cell = tableView.dequeueReusableCell(withIdentifier: "TvResultTableCell")!
        
        let tvListResultObject = tvListResults[(indexPath as NSIndexPath).row]
        
        // Set the name and image
        cell.textLabel?.text = "\(tvListResultObject.firstAirDate) \(tvListResultObject.name) (\(tvListResultObject.originalName))"
        cell.imageView?.image = UIImage(named: "icon_pin")
        
        // If the cell has a detail label, we will put the evil scheme in.
        if let detailTextLabel = cell.detailTextLabel {
            detailTextLabel.text = tvListResultObject.overview
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard self.isLoading == false else {
            return
        }
        
        guard let tvSearchResponse = tvSearchResponse else {
            return
        }
        
        guard tvSearchResponse.page < tvSearchResponse.totalPages else {
            return
        }
        
        guard let currentSearchTerm = currentSearchTerm else {
            return
        }
        
        let lastRowIndex = tableView.numberOfRows(inSection: 0) - 1
        if indexPath.row == lastRowIndex {

            self.isLoading = true
            TmdbClient.searchTv(query: currentSearchTerm, page: tvSearchResponse.page + 1, completion: handleSearchResponse)
            
        }
    }
}
