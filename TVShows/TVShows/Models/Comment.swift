//
//  Comment.swift
//  TVShows
//
//  Created by Infinum on 31/07/2019.
//  Copyright © 2019 Infinum Academy. All rights reserved.
//

import Foundation

struct PostedComment: Codable {
    var text: String
    var episodeId: String
    var userId: String
    var userEmail: String
    var type: String
    var id: String
    
    enum CodingKeys: String, CodingKey {
        case text
        case episodeId
        case userId
        case userEmail
        case type
        case id = "_id"
    }
    
    func toComment() -> Comment {
        return Comment(text: text, episodeId: episodeId, userEmail: userEmail, id: id)
    }
}

struct Comment: Codable {
    var text: String
    var episodeId: String
    var userEmail: String
    var id: String
    
    enum CodingKeys: String, CodingKey {
        case text
        case episodeId
        case userEmail
        case id = "_id"
    }
}
