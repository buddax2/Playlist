import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    let songController = SongController()

    // Basic "It works" example
    router.get { req -> String in
        return "It works!"
    }
    
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }

    router.get("songs") { req -> Future<View> in

        struct SSong: Codable {
            let id: String
            let title: String
            let youtubeURL: String
            let musicURL: String
        }
        
        let songs = Song.query(on: req).all().map({ (songs) -> [SSong] in
            return songs.map({ song in
                let title = song.rawTitle.trimmingCharacters(in: .whitespacesAndNewlines).htmlEscaped()
                let yURL = "https://www.youtube.com/results?search_query=\(title)"
                let mURL = "https://music.youtube.com/search?q=\(title)"
                return SSong(id: song.songID, title: song.rawTitle, youtubeURL: yURL, musicURL: mURL)
            })
        })

        return songs.flatMap { (songs) -> EventLoopFuture<View> in
            return try req.view().render("hello", ["songs": songs])
        }
    }

    router.post("songs", use: songController.create)
}

extension String {
    /// Escapes HTML entities in a `String`.
    func htmlEscaped() -> String {
        /// FIXME: performance
        return replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#39;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
        .replacingOccurrences(of: " ", with: "+")
    }
}
