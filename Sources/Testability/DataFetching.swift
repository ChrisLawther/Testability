import Foundation

public typealias URLDataFetcher = @Sendable (URL) async throws -> (Data, URLResponse)
public typealias URLRequestDataFetcher = @Sendable (URLRequest) async throws -> (Data, URLResponse)

public protocol DataFetching {
    func data(from: URL, delegate: (any URLSessionTaskDelegate)?) async throws -> (Data, URLResponse)
    func data(for: URLRequest, delegate: (any URLSessionTaskDelegate)?) async throws -> (Data, URLResponse)
}

public extension DataFetching {
    func data(from url: URL) async throws -> (Data, URLResponse) {
        try await data(from: url, delegate: nil)
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await data(for: request, delegate: nil)
    }
}

extension URLSession: DataFetching {}
