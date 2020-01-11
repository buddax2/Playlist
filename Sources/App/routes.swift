import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    let songController = SongController()

    // Basic "It works" example
    router.get { req -> Future<View> in
        return try req.view().render("base")
    }
    
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }

    router.get("all") { req -> Future<View> in

        let songs = try songController.showAll(req).map({ (songs) -> [SimpleSong] in
            return songs.map({ song in
                return song.simpleModel()
            })
        })

        return songs.flatMap { (songs) -> EventLoopFuture<View> in
            return try req.view().render("welcome", ["songs": songs])
        }
    }

    router.get("banned") { req -> Future<View> in

        let songs = try songController.showBanned(req).map({ (songs) -> [SimpleSong] in
            return songs.map({ song in
                return song.simpleModel()
            })
        })

        return songs.flatMap { (songs) -> EventLoopFuture<View> in
            return try req.view().render("welcome", ["songs": songs])
        }
    }

    router.get("playlist") { req -> Future<View> in

        let songs = try songController.showNotBanned(req).map({ (songs) -> [SimpleSong] in
            return songs.map({ song in
                return song.simpleModel()
            })
        })

        return songs.flatMap { (songs) -> EventLoopFuture<View> in
            return try req.view().render("welcome", ["songs": songs])
        }
    }

    router.get("ban", Int.parameter) { req -> Future<Song> in
        let id = try req.parameters.next(Int.self)
        return songController.ban(req: req, songID: id)
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
