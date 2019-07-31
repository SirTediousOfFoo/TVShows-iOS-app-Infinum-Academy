//
//  Comment.swift
//  TVShows
//
//  Created by Infinum on 31/07/2019.
//  Copyright © 2019 Infinum Academy. All rights reserved.
//

import Foundation

struct Comment: Codable {
    var text: String
    var episodeId: String
    var userId: String
    var userEmail: String
    var type: String
    var id: String
    
    enum codingKeys: String, CodingKey {
        case text
        case episodeId
        case userId
        case userEmail
        case type
        case id = "_id"
    }
}
