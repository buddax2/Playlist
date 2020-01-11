import Vapor

func getCurrentPlaylist(on container: Container, songController: SongController) {
    guard let url = URL(string: "https://radiotrek.rv.ua/apphlp/livelist/composedlist") else { return }
    
    DispatchQueue.global().async {
        if let data = try? Data(contentsOf: url) {
            if let arr = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String]] {
                guard let rawArray = arr else { return }
                
                let songs: [Song] = rawArray.compactMap { obj in
                    guard obj.count == 2 else { return nil }

                    let id = obj[1]
                    let rawTitle = obj[0]
                    
                    return Song(songID: id, rawTitle: rawTitle, isBanned: false)
                }
                
                songController.save(songs: songs)
            }
        }
    }
}

/// Called after your application has initialized.
public func boot(_ app: Application) throws {
    // Your code here
    
    let songController = SongController()
    
    func runRepeatTimer() {
        app.eventLoop.scheduleTask(in: TimeAmount.seconds(180), runRepeatTimer)
        getCurrentPlaylist(on: app, songController: songController)
    }
    runRepeatTimer()
}
