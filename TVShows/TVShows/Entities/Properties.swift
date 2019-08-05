//
//  PropertyStrings.swift
//  TVShows
//
//  Created by Infinum on 31/07/2019.
//  Copyright © 2019 Infinum Academy. All rights reserved.
//

import Foundation
import KeychainAccess

enum Properties: String {
    case userToken = "userToken"
    case dataPath = "data"
}

struct UserKeychain {
    static let keychain = Keychain(service: "co.petar.imilosevic.TVShows")
}
