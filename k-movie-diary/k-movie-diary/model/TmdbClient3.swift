//
//  TmdbClient.swift
//  k-movie-diary
//
//  Created by Matthew Flood on 4/15/23.
//

import Foundation


class TmdbClient {
    
    enum Endpoint {
        
        static let base = "https://api.themoviedb.org/3/"
        
        case authToken(apiKey: String)
        case userAuth(requestToken: String)

        var stringValue: String {
            switch self {
            case let .authToken(apiKey):
                return Endpoint.base + "authentication/token/new?api_key=" + apiKey
            case let .userAuth(requestToken):
                return "https://www.themoviedb.org/authenticate/\(requestToken)?redirect_to=kdramadiary://auth/approved"
            }
        }
        
        var url: URL {
            return URL(string: self.stringValue)!
        }
    }
}



func getNewAuthToken(apiKey: String, completion: @escaping (AuthenticationTokenNewResponseSuccess?, _ errorString:  String?) -> Void) {
    
    let url = TmdbClient.Endpoint.authToken(apiKey: apiKey).url
    print("url: \(url)")
    let task = URLSession.shared.dataTask(with: url)  {data, response, error in
       
        guard let data = data else {
            completion(nil, error?.localizedDescription)
            return
        }
        
        let decoder = JSONDecoder()
        do {
            let successResponseObject = try decoder.decode(AuthenticationTokenNewResponseSuccess.self, from: data)
            completion(successResponseObject, nil)
            return
        } catch {
            do {
                let failureResponseObject = try decoder.decode(AuthenticationTokenNewResponseFailure.self, from: data)
                completion(nil, failureResponseObject.status_message)
            } catch {
                completion(nil, error.localizedDescription)
            }
        }
    }
    task.resume()
}
