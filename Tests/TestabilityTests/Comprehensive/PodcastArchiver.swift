import Testability
import Foundation

class PodcastArchiver {
    private let fetch: URLDataFetcher
    private let downloader: FileDownloading
    private let mover: FileMovement
    private let modifier: FileAttributes

    init(fetch: @escaping URLDataFetcher = URLSession.shared.data(from:),
         downloader: FileDownloading = URLSession.shared,
         mover: FileMovement = FileManager.default,
         modifier: FileAttributes = FileManager.default) {
        self.fetch = fetch
        self.downloader = downloader
        self.mover = mover
        self.modifier = modifier
    }

    func fetchAllPodcasts(from url: URL) async throws {
        struct Episode: Decodable {
            let url: URL
            let title: String
            let published: String
        }

        let (data, _) = try await fetch(URL(string: "https://some.podcast/feed.json")!)

        let response = try JSONDecoder().decode([Episode].self, from: data)

        for episode in response {
            let (tmpUrl, _) = try await downloader.download(from: episode.url)
            let dstUrl = URL.documentsDirectory.appendingPathComponent("\(episode.title).mp3")
            try mover.moveItem(at: tmpUrl, to: dstUrl)
            let published = Self.formatter.date(from: episode.published)!
            try modifier.setAttributes([FileAttributeKey.creationDate: published as NSDate],
                                       ofItemAtPath: dstUrl.path(percentEncoded: false))
        }
    }
    
    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss ZZZZ"
        return formatter
    }()
}
