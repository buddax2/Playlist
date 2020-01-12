import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    let songController = SongController()

    struct ViewData: Content {
        let songs: [SimpleSong]
        let currentPage: String
    }

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
            let data = ViewData(songs: songs, currentPage: "all")
            return try req.view().render("welcome", data)
        }
    }

    router.get("banned") { req -> Future<View> in

        let songs = try songController.showBanned(req).map({ (songs) -> [SimpleSong] in
            return songs.map({ song in
                return song.simpleModel()
            })
        })

        return songs.flatMap { (songs) -> EventLoopFuture<View> in
            let data = ViewData(songs: songs, currentPage: "banned")
            return try req.view().render("welcome", data)
        }
    }

    router.get("playlist") { req -> Future<View> in

        let songs = try songController.showNotBanned(req).map({ (songs) -> [SimpleSong] in
            return songs.map({ song in
                return song.simpleModel()
            })
        })

        return songs.flatMap { (songs) -> EventLoopFuture<View> in
            let data = ViewData(songs: songs, currentPage: "playlist")
            return try req.view().render("welcome", data)
        }
    }

    router.get("ban", Int.parameter, String.parameter) { req -> Future<Response> in
        let id = try req.parameters.next(Int.self)
        let page = try req.parameters.next(String.self)
        let redirectTo = "/\(page)"
        return songController.ban(req: req, songID: id).map { _ in
            return req.redirect(to: redirectTo)
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
