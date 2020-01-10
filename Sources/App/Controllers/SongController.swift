//
//  SongController.swift
//  App
//
//  Created by Oleksandr Yakubchyk on 10.01.2020.
//

import FluentPostgreSQL
import Vapor

final class SongController {
    
    func index(_ req: Request) throws -> Future<[Song]> {
        return Song.query(on: req).all()
    }

    func create(_ req: Request) throws -> Future<Song> {
        return try req.content.decode(Song.self).flatMap { song in
            song.save(on: req)
        }
    }
    
    func save(songs: [Song]) {
        let config = PostgreSQLDatabaseConfig(hostname: "localhost", port: 5431, username: "bx2", database: "playlist", password: nil, transport: .cleartext)
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
