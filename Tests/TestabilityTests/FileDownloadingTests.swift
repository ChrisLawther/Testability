import Foundation
import Testing
@testable import Testability

@Test func exampleDownload() async throws {
    let spyDownloader = SpyFileDownloading()
    let sut = ExampleDownloader(downloader: spyDownloader)
    try await sut.fetchFile()

    #expect(spyDownloader.urls.count == 1)
    #expect(spyDownloader.urls.first?.absoluteString == "https://example.com/some/file.ext")
}

@Test @MainActor func exampleDownloadTypealias() async throws {
    class LighteightDownloader {
        private let download: URLFileDownloader

        init(downloader download: @escaping URLFileDownloader = URLSession.shared.download(from:)) {
            self.download = download
        }

        func downloadFile() async throws {
            _ = try await download(URL(string: "https://example.com/downloadable/file")!)
        }
    }

    actor RequestLogger {
        var requestedURL: URL?

        func setURL(_ url: URL) {
            requestedURL = url
        }
    }

    let requestLogger = RequestLogger()

    let sut = LighteightDownloader { url in
        await requestLogger.setURL(url)
        return (URL(filePath: "/tmp/downloaded.file"), HTTPURLResponse())
    }

    try await sut.downloadFile()

    let requestedURL = await requestLogger.requestedURL

    #expect(requestedURL?.absoluteString == "https://example.com/downloadable/file")
}

class ExampleDownloader {
    private let downloader: FileDownloading

    init(downloader: FileDownloading = URLSession.shared) {
        self.downloader = downloader
    }

    func fetchFile() async throws {
        _ = try await downloader.download(from: URL(string: "https://example.com/some/file.ext")!)
    }
}

class SpyFileDownloading: FileDownloading {
    private(set) var urls: [URL] = []
    private(set) var requests: [URLRequest] = []

    func download(from url: URL, delegate: (any URLSessionTaskDelegate)?) async throws -> (URL, URLResponse) {
        urls.append(url)
        return (URL(filePath: "/tmp/somefile"), HTTPURLResponse())
    }

    func download(for request: URLRequest, delegate: (any URLSessionTaskDelegate)?) async throws -> (URL, URLResponse) {
        requests.append(request)
        return (URL(filePath: "/tmp/somefile"), HTTPURLResponse())
    }
}
