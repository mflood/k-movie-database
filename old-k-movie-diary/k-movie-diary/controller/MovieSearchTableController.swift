//
//  MovieSearchTableController.swift
//  k-movie-diary
//
//  Created by Matthew Flood on 4/16/23.
//


import UIKit

class MovieSearchTableController: UIViewController {


    
    @IBOutlet weak var movieTableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!

    var isLoading = false
    var currentSearchTerm: String? = nil
    var movieSearchResponse: MovieSearchResponse? = nil
    var movieListResults: [MovieListResultObject] = []
    
    @IBAction func handleSearchTextValueChanged(_ sender: Any) {


    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.movieTableView.delegate = self
        self.movieTableView.dataSource = self
        
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
        TmdbClient.searchMovie(query:searchText, page: 1, completion: handleSearchResponse)
    }
    
    func handleSearchResponse(movieSearchResponse: MovieSearchResponse?, errorString: String?) {
        
        self.movieSearchResponse = movieSearchResponse
                
        DispatchQueue.main.async { [self] in
            if let errorString = errorString {
                self.showAlert(title: "Search Error", message: errorString)
            } else if let movieSearchResponse = movieSearchResponse {
                if movieSearchResponse.totalResults == 0 {
                    self.showAlert(title: "Search Error", message: "No results")
                }
                
                if movieSearchResponse.page > 1 {
                    self.movieListResults.append(contentsOf: movieSearchResponse.results)
                } else {
                    self.movieListResults = movieSearchResponse.results
                }
            }
            
            self.movieTableView.reloadData()
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

extension MovieSearchTableController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieListResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        let cell = tableView.dequeueReusableCell(withIdentifier: "MoveResultTableCell")!
        
        let movieListResultObject = movieListResults[(indexPath as NSIndexPath).row]
        
        // Set the name and image
        cell.textLabel?.text = "\(movieListResultObject.releaseDate) \(movieListResultObject.title) (\(movieListResultObject.originalTitle))"
        cell.imageView?.image = UIImage(named: "icon_pin")
        
        // If the cell has a detail label, we will put the evil scheme in.
        if let detailTextLabel = cell.detailTextLabel {
            detailTextLabel.text = movieListResultObject.overview
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard self.isLoading == false else {
            return
        }
        
        guard let movieSearchResponse = movieSearchResponse else {
            return
        }
        
        guard movieSearchResponse.page < movieSearchResponse.totalPages else {
            return
        }
        
        guard let currentSearchTerm = currentSearchTerm else {
            return
        }
        
        let lastRowIndex = tableView.numberOfRows(inSection: 0) - 1
        if indexPath.row == lastRowIndex {

            self.isLoading = true
            TmdbClient.searchMovie(query: currentSearchTerm, page: movieSearchResponse.page + 1, completion: handleSearchResponse)
            
        }
    }
}
