//
//  TmdbClient.swift
//  k-movie-diary
//
//  Created by Matthew Flood on 4/15/23.
//

import Foundation


class TmdbClient {
    
    struct Auth {
        static var apiKey: String? = nil
        static var requestToken: String? = nil
    }
    
    enum Endpoint {
        
        static let base = "https://api.themoviedb.org/3/"
        
        case authToken(apiKey: String)
        case externalUserAuth(requestToken: String)
        case internalLogin(apiKey: String)

        var stringValue: String {
            switch self {
            case let .authToken(apiKey):
                return Endpoint.base + "authentication/token/new?api_key=" + apiKey
            case let .externalUserAuth(requestToken):
                return "https://www.themoviedb.org/authenticate/\(requestToken)?redirect_to=kdramadiary:auth/approved"
            case .internalLogin(apiKey: let apiKey):
                return Endpoint.base + "authentication/token/validate_with_login?api_key=" + apiKey
            }
        }
        
        var url: URL {
            return URL(string: self.stringValue)!
        }
    }
    
    class func login(apiKey: String,
                     username: String,
                     password: String,
                     requestToken: String,
                     completion: @escaping (LoginResponseSuccess?, _ errorString:  String?) -> Void) {
        
        let url = TmdbClient.Endpoint.internalLogin(apiKey: apiKey).url
        print("url: \(url)")
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = LoginRequest(username: username, password: password, requestToken: requestToken)
        urlRequest.httpBody = try! JSONEncoder().encode(body)
        
        
        let task = URLSession.shared.dataTask(with: urlRequest) {(data, response, error) in
           
            guard let data = data else {
                completion(nil, error?.localizedDescription)
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let successResponseObject = try decoder.decode(LoginResponseSuccess.self, from: data)
                completion(successResponseObject, nil)
                return
            } catch {
                do {
                    let failureResponseObject = try decoder.decode(TmdbApiFailureResponse.self, from: data)
                    completion(nil, failureResponseObject.statusMessage)
                } catch {
                    completion(nil, error.localizedDescription)
                }
            }
        }
        task.resume()
    }

    
    class func getNewAuthToken(apiKey: String, completion: @escaping (AuthenticationTokenNewResponseSuccess?, _ errorString:  String?) -> Void) {
        
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
                    let failureResponseObject = try decoder.decode(TmdbApiFailureResponse.self, from: data)
                    completion(nil, failureResponseObject.statusMessage)
                } catch {
                    completion(nil, error.localizedDescription)
                }
            }
        }
        task.resume()
    }

}


