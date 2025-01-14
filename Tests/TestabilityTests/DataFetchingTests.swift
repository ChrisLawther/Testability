import Foundation
import Testing
@testable import Testability

@Test func exampleDataFetch() async throws {
    let stubFetcher = SpyDataFetching()
    let sut = ExampleFetcher(fetcher: stubFetcher)
    try await sut.fetchData()

    #expect(stubFetcher.urls.count == 1)
    #expect(stubFetcher.urls.first?.absoluteString == "https://example.com")
}

@Test @MainActor func exampleFetchTypealias() async throws {
    class LighteightFetcher {
        private let fetch: URLDataFetcher

        init(fetch: @escaping URLDataFetcher = URLSession.shared.data(from:)) {
            self.fetch = fetch
        }

        func doStuff() async throws {
            _ = try await fetch(URL(string: "https://example.com")!)
        }
    }

    actor RequestLogger {
        var requestedURL: URL?

        func setURL(_ url: URL) {
            requestedURL = url
        }
    }

    let requestLogger = RequestLogger()

    let sut = LighteightFetcher { url in
        await requestLogger.setURL(url)
        return ("Response body text".data(using: .utf8)!, HTTPURLResponse())
    }

    try await sut.doStuff()

    let requestedURL = await requestLogger.requestedURL

    #expect(requestedURL?.absoluteString == "https://example.com")
}

class ExampleFetcher {
    private let fetcher: DataFetching

    init(fetcher: DataFetching = URLSession.shared) {
        self.fetcher = fetcher
    }

    func fetchData() async throws {
        _ = try await fetcher.data(from: URL(string: "https://example.com")!)
    }
}

class SpyDataFetching: DataFetching {
    private(set) var urls: [URL] = []
    private(set) var requests: [URLRequest] = []

    func data(from url: URL, delegate: (any URLSessionTaskDelegate)?) async throws -> (Data, URLResponse) {
        urls.append(url)
        return (Data(), HTTPURLResponse())
    }

    func data(for request: URLRequest, delegate: (any URLSessionTaskDelegate)?) async throws -> (Data, URLResponse) {
        requests.append(request)
        return (Data(), HTTPURLResponse())
    }
}
