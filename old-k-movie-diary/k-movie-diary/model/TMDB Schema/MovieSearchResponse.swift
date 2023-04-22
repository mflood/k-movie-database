//
//  MovieSearchResponse.swift
//  k-movie-diary
//
//  Created by Matthew Flood on 4/16/23.
//

import Foundation

struct MovieListResultObject: Codable {
    var posterPath: String?
    var adult: Bool
    var overview: String
    var releaseDate: String
    var genreIds: [Int32]
    var id: Int32
    var originalTitle: String
    var originalLanguage: String
    var title: String
    var backdropPath: String?
    var popularity: Double
    var voteCount: Int32
    var video: Bool
    var voteAverage: Double
    
    enum CodingKeys: String, CodingKey {
        case posterPath = "poster_path"
        case adult
        case overview
        case releaseDate = "release_date"
        case genreIds = "genre_ids"
        case id
        case originalTitle = "original_title"
        case originalLanguage = "original_language"
        case title
        case backdropPath = "backdrop_path"
        case popularity
        case voteCount = "vote_count"
        case video
        case voteAverage = "vote_average"
    }
}

struct MovieSearchResponse: Codable {
    var page: Int32
    var results: [MovieListResultObject]
    var totalResults: Int32
    var totalPages: Int32
    
    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalResults = "total_results"
        case totalPages = "total_pages"
    }
}
