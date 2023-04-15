//
//  ApiKey.swift
//  k-movie-diary
//
//  Created by Matthew Flood on 4/15/23.
//

import Foundation

struct TmdbApiKey: Codable {
    var apiKey: String
}

func getTmdbApiKeyFileUrl() -> URL {
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let archiveURL = documentsDirectory.appendingPathComponent("tmbd_api_key").appendingPathExtension("plist")
    return archiveURL
}

func saveTmdbApiKey(apiKey: TmdbApiKey) {
    let archiveURL = getTmdbApiKeyFileUrl()
    
    // encode the data
    let propertyListEncoder = PropertyListEncoder()
    let encodedApiKey = try? propertyListEncoder.encode(apiKey)

    try? encodedApiKey?.write(to: archiveURL, options: .noFileProtection)
}

func getExistingApiKey() -> TmdbApiKey? {
    
    let archiveURL = getTmdbApiKeyFileUrl()
    guard let data = try? Data(contentsOf: archiveURL) else {
        return nil
    }
    
    let propertyListDecoder = PropertyListDecoder()
    let apiKey = try? propertyListDecoder.decode(TmdbApiKey.self, from: data)
    
    return apiKey
}

