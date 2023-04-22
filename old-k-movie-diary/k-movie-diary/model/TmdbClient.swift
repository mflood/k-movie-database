//
//  TmdbClient.swift
//  k-movie-diary
//
//  Created by Matthew Flood on 4/15/23.
//

import Foundation

import NaturalLanguage

class TmdbClient {
    
    struct Auth {
        static var apiKey: String? = nil
        static var requestToken: String? = nil
        static var sessionId: String? = nil
    }
    
    enum Endpoint {
        
        static let base = "https://api.themoviedb.org/3/"
        
        case authToken(apiKey: String)
        case externalUserAuth(requestToken: String)
        case internalLogin(apiKey: String)
        case newSession(apiKey: String)
        case deleteSession
        case searchMovie(query: String, page: Int32)
        case searchTv(query: String, page: Int32)

        var stringValue: String {
            switch self {
            case let .authToken(apiKey):
                return Endpoint.base + "authentication/token/new?api_key=" + apiKey
            case let .externalUserAuth(requestToken):
                return "https://www.themoviedb.org/authenticate/\(requestToken)?redirect_to=kdramadiary:auth/approved"
            case .internalLogin(apiKey: let apiKey):
                return Endpoint.base + "authentication/token/validate_with_login?api_key=" + apiKey
            case .newSession(apiKey: let apiKey):
                return Endpoint.base + "authentication/session/new?api_key=" + apiKey
            case .deleteSession:
                return Endpoint.base + "authentication/session?api_key=" + TmdbClient.Auth.apiKey!
            case .searchMovie(query: let query, page: let page):
                
                let tagger = NLTagger(tagSchemes: [.language])
                tagger.string = query
                let detectedLanguage = tagger.dominantLanguage?.rawValue ?? "und"
                print("Detected language: \(detectedLanguage)")
                
                var language = "ko-KR"
                if detectedLanguage == "ko" {
                    language = "ko-KR"
                }
                
                let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                return Endpoint.base + "search/movie?api_key=" + Auth.apiKey! + "&include_adult=false&language=\(language)&page=\(page)&query=" + encodedQuery!
            case .searchTv(query: let query, page: let page):
                
                let tagger = NLTagger(tagSchemes: [.language])
                tagger.string = query
                let detectedLanguage = tagger.dominantLanguage?.rawValue ?? "und"
                print("Detected language: \(detectedLanguage)")
                
                var language = "ko-KR"
                if detectedLanguage == "ko" {
                    language = "ko-KR"
                }
                
                let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                return Endpoint.base + "search/tv?api_key=" + Auth.apiKey! + "&include_adult=false&language=\(language)&page=\(page)&query=" + encodedQuery!
            }
        }
        
        var url: URL {
            return URL(string: self.stringValue)!
        }
    }
    
    
    class func searchTv(query:  String, page: Int32, completion: @escaping (_ tvSearchResponse: TvSearchResponse?, _ errorString: String?) -> Void) {
        
        let url = TmdbClient.Endpoint.searchTv(query: query, page: page).url
        
        print("url: \(url)")
        
        let task = URLSession.shared.dataTask(with: url)  {data, response, error in
           
            guard let data = data else {
                completion(nil, error?.localizedDescription)
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let tvSearchResponse = try decoder.decode(TvSearchResponse.self, from: data)
                completion(tvSearchResponse, nil)
                return
            } catch {
                do {
                    let failureResponseObject = try decoder.decode(Tmdb401Response.self, from: data)
                    completion(nil, failureResponseObject.statusMessage)
                } catch {
                    completion(nil, error.localizedDescription)
                }
            }
        }
        task.resume()
    }
    
    
    class func searchMovie(query:  String, page: Int32, completion: @escaping (_ movieSearchResponse: MovieSearchResponse?, _ errorString: String?) -> Void) {
        
        let url = TmdbClient.Endpoint.searchMovie(query: query, page: page).url
        
        print("url: \(url)")
        
        let task = URLSession.shared.dataTask(with: url)  {data, response, error in
           
            guard let data = data else {
                completion(nil, error?.localizedDescription)
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let movieSearchResponse = try decoder.decode(MovieSearchResponse.self, from: data)
                completion(movieSearchResponse, nil)
                return
            } catch {
                do {
                    let failureResponseObject = try decoder.decode(Tmdb401Response.self, from: data)
                    completion(nil, failureResponseObject.statusMessage)
                } catch {
                    completion(nil, error.localizedDescription)
                }
            }
        }
        task.resume()
    }
   
    class func deleteSession(completion: @escaping (_ errorString:  String?) -> Void) {
        
        guard let sessionId = TmdbClient.Auth.sessionId else {
            completion(nil)
            return
        }
        let url = TmdbClient.Endpoint.deleteSession.url
        print("url: \(url)")
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = DeleteSessionRequest(sessionId: sessionId)
        urlRequest.httpBody = try! JSONEncoder().encode(body)
        
        let task = URLSession.shared.dataTask(with: urlRequest) {(data, response, error) in
           
            completion(nil)
            guard let data = data else {
                completion(error?.localizedDescription)
                return
            }
            TmdbClient.Auth.sessionId = nil
        }
        task.resume()
    }
    class func newSession(apiKey: String,
                     requestToken: String,
                     completion: @escaping (NewSessionResponseSuccess?, _ errorString:  String?) -> Void) {
        
        let url = TmdbClient.Endpoint.newSession(apiKey: apiKey).url
        print("url: \(url)")
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = NewSessionRequest(requestToken: requestToken)
        urlRequest.httpBody = try! JSONEncoder().encode(body)
        
        let task = URLSession.shared.dataTask(with: urlRequest) {(data, response, error) in
           
            guard let data = data else {
                completion(nil, error?.localizedDescription)
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let newSessionResponseObject = try decoder.decode(NewSessionResponseSuccess.self, from: data)
                completion(newSessionResponseObject, nil)
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
                TmdbClient.Auth.requestToken = successResponseObject.requestToken
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


