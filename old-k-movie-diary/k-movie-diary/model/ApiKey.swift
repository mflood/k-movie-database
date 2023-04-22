//
//  ApiKey.swift
//  k-movie-diary
//
//  Created by Matthew Flood on 4/15/23.
//

import Foundation

func loadTmdbApiKey(){
    
    if let path = Bundle.main.path(forResource: "tmdb_api", ofType: "plist") {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            
            let propertyListDecoder = PropertyListDecoder()
            let apiKey = try? propertyListDecoder.decode(TmdbApiKey.self, from: data)
            TmdbClient.Auth.apiKey = apiKey?.apiKey
            print("Loaded TmdbClient.Auth.apiKey: \(TmdbClient.Auth.apiKey ?? "no api Key")")
        } catch {
            // Handle error here
            print(error)
        }
    }
}




struct TmdbApiKey: Codable {
    var apiKey: String
}

func getTmdbApiKeyFileUrl() -> URL {
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let archiveURL = documentsDirectory.appendingPathComponent("tmbd_api_key").appendingPathExtension("plist")
    return archiveURL
}

