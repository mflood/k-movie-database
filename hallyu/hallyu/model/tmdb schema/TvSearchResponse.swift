//
//  TvSearchResponse.swift
//  hallyu
//
//  Created by Matthew Flood on 4/22/23.
//

import Foundation


struct TvListResultObject: Codable {
    var adult: Bool
    var backdropPath: String?
    var genreIds: [Int32]
    var id: Int32
    var originCountry: [String]
    var originalLanguage: String
    var originalName: String
    var overview: String
    var popularity: Double
    var posterPath: String?
    var firstAirDate: String
    var name: String
    var voteCount: Int32
    var voteAverage: Double
    
    enum CodingKeys: String, CodingKey {
        case adult
        case backdropPath = "backdrop_path"
        case genreIds = "genre_ids"
        case id
        case originCountry = "origin_country"
        case originalLanguage = "original_language"
        case originalName = "original_name"
        case overview
        case popularity
        case posterPath = "poster_path"
        case firstAirDate = "first_air_date"
        case name
        case voteCount = "vote_count"
        case voteAverage = "vote_average"
    }
}

struct TvSearchResponse: Codable {
    var page: Int32
    var results: [TvListResultObject]
    var totalResults: Int32
    var totalPages: Int32
    
    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalResults = "total_results"
        case totalPages = "total_pages"
    }
}
