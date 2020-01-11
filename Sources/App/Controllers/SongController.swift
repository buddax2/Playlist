//
//  SongController.swift
//  App
//
//  Created by Oleksandr Yakubchyk on 10.01.2020.
//

import FluentPostgreSQL
import Vapor

final class SongController {
    
    func showAll(_ req: Request) throws -> Future<[Song]> {
        return Song.query(on: req).all()
    }

    func showBanned(_ req: Request) throws -> Future<[Song]> {
        return Song.query(on: req).filter(\Song.isBanned == true).all()
    }

    func showNotBanned(_ req: Request) throws -> Future<[Song]> {
        return Song.query(on: req).filter(\Song.isBanned == false).all()
    }

    func create(_ req: Request) throws -> Future<Song> {
        return try req.content.decode(Song.self).flatMap { song in
            song.save(on: req)
        }
    }
    
    func ban(req: Request, songID: Int) -> Future<Song> {
        return Song.find(songID, on: req).flatMap { (song) -> EventLoopFuture<Song> in
            guard let song = song else {
                throw Abort(.badRequest, reason: "Song not found")
            }
            
            song.isBanned.toggle()
            return song.save(on: req)
        }
    }
    
    func save(songs: [Song]) {
        let config = DBConfig.dbConfig()
        let database = PostgreSQLDatabase(config: config)
        let worker = MultiThreadedEventLoopGroup(numberOfThreads: 2)
        let conn = database.newConnection(on: worker)

        _ = songs.compactMap {
            return save(song: $0, connection: conn)
        }.always(on: worker, {
            do {
                try worker.syncShutdownGracefully()
            } catch {
                print(error)
            }
        })
    }
    
    func save(song: Song, connection: EventLoopFuture<PostgreSQLConnection>) -> Future<Song?>? {
        return connection.flatMap { connection in
            return Song.query(on: connection).filter(\Song.songID == song.songID).first().do { (firstSong) in
                if firstSong == nil {
                    _ = song.save(on: connection)
                }
            }
        }
    }
}
