//
//  Episode.swift
//  TVShows
//
//  Created by Infinum on 23/07/2019.
//  Copyright © 2019 Infinum Academy. All rights reserved.
//

import Foundation

struct Episode: Codable {
    let id: String
    let title: String
    let description: String
    let imageUrl: String
    let episodeNumber: String
    let season: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case description
        case imageUrl
        case episodeNumber
        case season
    }
}

extension Episode: Comparable {
    static func < (lhs: Episode, rhs: Episode) -> Bool {
        return (Int(lhs.season) ?? 0, Int(lhs.episodeNumber) ?? 0) < (Int(rhs.season) ?? 0, Int(rhs.episodeNumber) ?? 0)
    }
}

struct EpisodeDetails: Codable {
    let showId: String
    let id: String
    let title: String
    let description: String
    let imageUrl: String
    let episodeNumber: String
    let season: String
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case description
        case imageUrl
        case episodeNumber
        case season
        case type
        case showId
    }
}
