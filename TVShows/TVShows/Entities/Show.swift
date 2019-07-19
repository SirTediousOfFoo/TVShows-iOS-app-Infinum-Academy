//
//  Shows.swift
//  TVShows
//
//  Created by Infinum on 19/07/2019.
//  Copyright © 2019 Infinum Academy. All rights reserved.
//

import Foundation

struct Show: Codable {
    let id: String
    let title: String
    let imageUrl: String
    let likesCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case imageUrl
        case likesCount
    }
}
