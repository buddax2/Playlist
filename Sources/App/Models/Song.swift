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
    
    func simpleModel() -> SimpleSong {
        let title = self.rawTitle.trimmingCharacters(in: .whitespacesAndNewlines).htmlEscaped()
        let yURL = "https://www.youtube.com/results?search_query=\(title)"
        let mURL = "https://music.youtube.com/search?q=\(title)"
        return SimpleSong(id: self.id, songID: self.songID, title: self.rawTitle, youtubeURL: yURL, musicURL: mURL)
    }
}

struct SimpleSong: Codable {
    let id: Int?
    let songID: String
    let title: String
    let youtubeURL: String
    let musicURL: String
}

/// Allows `Song` to be used as a dynamic migration.
extension Song: Migration { }

/// Allows `Song` to be encoded to and decoded from HTTP messages.
extension Song: Content { }

/// Allows `Song` to be used as a dynamic parameter in route definitions.
extension Song: Parameter { }

