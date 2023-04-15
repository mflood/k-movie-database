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
    var expires_at: String
    var request_token: String
}

struct AuthenticationTokenNewResponseFailure: Codable {
    var success: Bool
    var status_code: Int32
    var status_message: String
}
