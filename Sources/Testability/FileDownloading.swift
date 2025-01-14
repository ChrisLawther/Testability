import Foundation

public typealias URLFileDownloader = @Sendable (URL) async throws -> (URL, URLResponse)
public typealias URLRequestFileDownloader = @Sendable (URLRequest) async throws -> (URL, URLResponse)

public protocol FileDownloading {
    func download(from: URL, delegate: (any URLSessionTaskDelegate)?) async throws -> (URL, URLResponse)
    func download(for: URLRequest, delegate: (any URLSessionTaskDelegate)?) async throws -> (URL, URLResponse)
}

public extension FileDownloading {
    func download(from url: URL) async throws -> (URL, URLResponse) {
        try await download(from: url, delegate: nil)
    }

    func download(for request: URLRequest) async throws -> (URL, URLResponse) {
        try await download(for: request, delegate: nil)
    }
}

extension URLSession: FileDownloading {}
