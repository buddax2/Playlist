//
//  Song.swift
//  App
//
//  Created by Oleksandr Yakubchyk on 10.01.2020.
//

import FluentPostgreSQL
import Vapor

final class Song: PostgreSQLModel {
    var id: Int?
    
    var songID: String
    var rawTitle: String
    var isBanned: Bool
    
    
    init(id: Int? = nil, songID: String, rawTitle: String, isBanned: Bool = false) {
        self.id = id
        self.songID = songID
        self.rawTitle = rawTitle
        self.isBanned = isBanned
    }
}

/// Allows `Song` to be used as a dynamic migration.
extension Song: Migration { }

/// Allows `Song` to be encoded to and decoded from HTTP messages.
extension Song: Content { }

/// Allows `Song` to be used as a dynamic parameter in route definitions.
extension Song: Parameter { }

