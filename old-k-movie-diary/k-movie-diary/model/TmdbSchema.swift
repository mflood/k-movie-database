//
//  TmdbSchema.swift
//  k-movie-diary
//
//  Created by Matthew Flood on 4/15/23.
//

import Foundation


struct Movie: Codable {
    var name: String
}

struct AuthenticationTokenNewResponseSuccess: Codable {
    var success: Bool
    var expiresAt: String
    var requestToken: String
    
    enum CodingKeys: String, CodingKey {
        case success
        case expiresAt = "expires_at"
        case requestToken = "request_token"
    }
}

struct Tmdb401Response: Codable {
    var statusCode: Int32
    var statusMessage: String
    
    enum CodingKeys: String, CodingKey {
        case statusCode = "status_code"
        case statusMessage = "status_message"
    }
}

struct TmdbApiFailureResponse: Codable {
    var success: Bool
    var statusCode: Int32
    var statusMessage: String
    
    enum CodingKeys: String, CodingKey {
        case success
        case statusCode = "status_code"
        case statusMessage = "status_message"
    }
}

struct LoginRequest: Codable {
    var username: String
    var password: String
    var requestToken: String
    
    enum CodingKeys: String, CodingKey {
        case username
        case password
        case requestToken = "request_token"
    }
}

struct LoginResponseSuccess: Codable {
    var success: Bool
    var expiresAt: String
    var requestToken: String
    
    enum CodingKeys: String, CodingKey {
        case success
        case expiresAt = "expires_at"
        case requestToken = "request_token"
    }
}

struct NewSessionRequest: Codable {
    var requestToken: String
    
    enum CodingKeys: String, CodingKey {
        case requestToken = "request_token"
    }
}


struct DeleteSessionRequest: Codable {
    var sessionId: String
    
    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
    }
}


struct NewSessionResponseSuccess: Codable {
    var success: Bool
    var sessionId: String
    
    enum CodingKeys: String, CodingKey {
        case success
        case sessionId = "session_id"
    }
}

