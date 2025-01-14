import Foundation
import Testing
@testable import Testability

@Test func comprehensiveExample() async throws {
    // GIVEN
    let responseData = """
    {
        "fileOfTheDay": "https://fotd/somefile.mp3"
    }
    """.data(using: .utf8)!

    let logger = RequestLogger()
    let spyDownloader = SpyDownloader(logger: logger)
    let spyMover = SpyMover()

    let sut = FileOfTheDayDownloader(
        fetch: { url in
            await logger.log(url)
            return (responseData, HTTPURLResponse())
        },
        downloader: spyDownloader,
        mover: spyMover)

    // WHEN
    try await sut.doWork()

    // THEN
    // There should be exactly 2 requests
    #expect((await logger.urls.count) == 2)
    #expect((await logger.urls.first?.absoluteString) == "https://fotd/today.json")
    #expect((await logger.urls.last?.absoluteString) == "https://fotd/somefile.mp3")
    // There should be exactly 1 move
    #expect(spyMover.moves.count == 1)
    #expect(spyMover.moves.first?.src.path() == "/tmp/some/download.mp3")
    #expect(spyMover.moves.first?.dst.path() == "/Users/chris/Documents/today.mp3")
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
