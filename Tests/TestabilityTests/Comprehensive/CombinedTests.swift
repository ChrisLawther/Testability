import Foundation
import Testing
@testable import Testability

@Test func comprehensiveExample() async throws {
    // GIVEN
    let responseData = """
    [
      {
        "url": "https://some.podcast/some/episode.mp3",
        "title": "The very first episode ever!",
        "published": "Mon, 10 Jan 2025 13:00:00 GMT"
      }
    ]
    """.data(using: .utf8)!

    let logger = RequestLogger()
    let spyDownloader = SpyDownloader(logger: logger)
    let spyMover = SpyMover()
    let spyAttributes = SpyFileAttributes()
    
    let sut = PodcastArchiver(
        fetch: { url in
            await logger.log(url)
            return (responseData, HTTPURLResponse())
        },
        downloader: spyDownloader,
        mover: spyMover,
        modifier: spyAttributes
    )

    // WHEN
    try await sut.fetchAllPodcasts(from: URL(string: "https://some.podcast/feed.json")!)

    // THEN
    // There should be exactly 2 requests
    #expect((await logger.urls.count) == 2)
    #expect((await logger.urls.first?.absoluteString) == "https://some.podcast/feed.json")
    #expect((await logger.urls.last?.absoluteString) == "https://some.podcast/some/episode.mp3")
    
    // There should be exactly 1 move
    #expect(spyMover.moves.count == 1)
    #expect(spyMover.moves.first?.src.path(percentEncoded: false) == "/tmp/some/download.mp3")
    let expectedDstPath = "/Users/chris/Documents/The very first episode ever!.mp3"
    #expect(spyMover.moves.first?.dst.path(percentEncoded: false) == expectedDstPath)
    
    // The created date should have been set
    #expect(spyAttributes.attributes[expectedDstPath]?[FileAttributeKey.creationDate] as? Date == Date(timeIntervalSince1970: 1736514000))
}

actor RequestLogger {
    private(set) var urls: [URL] = []

    func log(_ url: URL) {
        urls.append(url)
    }
}

class SpyDownloader: FileDownloading {
    private let logger: RequestLogger

    init(logger: RequestLogger) {
        self.logger = logger
    }

    func download(from url: URL, delegate: (any URLSessionTaskDelegate)?) async throws -> (URL, URLResponse) {
        await logger.log(url)
        return (URL(filePath: "/tmp/some/download.mp3"), HTTPURLResponse())
    }

    func download(for: URLRequest, delegate: (any URLSessionTaskDelegate)?) async throws -> (URL, URLResponse) {
        fatalError("Not implemented")
    }
}

/// Keeps a log of **requested** moves. Never *actually* moves anything
class SpyFileMover: FileMovement {
    private(set) var moves: [(src: URL, dst: URL)] = []

    func moveItem(at srcURL: URL, to dstURL: URL) throws {
        moves.append((src: srcURL, dst: dstURL))
    }
}
