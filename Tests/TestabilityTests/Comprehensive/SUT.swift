import Testability
import Foundation

class FileOfTheDayDownloader {
    private let fetch: URLDataFetcher
    private let downloader: FileDownloading
    private let mover: FileMovement

    init(fetch: @escaping URLDataFetcher = URLSession.shared.data(from:),
         downloader: FileDownloading = URLSession.shared,
         mover: FileMovement = FileManager.default) {
        self.fetch = fetch
        self.downloader = downloader
        self.mover = mover
    }

    func doWork() async throws {
        struct Response: Decodable {
            let fileOfTheDay: URL
        }

        let (data, _) = try await fetch(URL(string: "https://fotd/today.json")!)

        let response = try JSONDecoder().decode(Response.self, from: data)

        let (tmpUrl, _) = try await downloader.download(from: response.fileOfTheDay)

        let dstUrl = URL.documentsDirectory.appendingPathComponent("today.mp3")
        try mover.moveItem(at: tmpUrl, to: dstUrl)
    }
}
