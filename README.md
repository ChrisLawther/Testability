#  Testability

A selection of protocols matching commonly used elements of Foundation, such that production code can use Foundation, but tests can trivially switch to alternative implementations.

## File Management

Commonly used file-related functionality, currently extending to:

 * `protocol FileMovement` for moving files on disk
 
 * `protocol FileInspection` for checking the existence and readability of a file
 
 * `protocol FileListing` for querying locations for their contents
 
 * `protocol FileManagement` as an agregation of the first three, with the addition of URL creation

It is recommended that code depend on the smallest set of functionality (i.e. it shouldn't 'depend on a `FileManagement` if `FileMovement` is all that is needed). This will reduce the amount of code required by alternative spy/stub/mock implementations.

The standard `FileManager` is extended to conform to `FileManagement`. At point of consumption, code may look something like this:

```swift
struct ThingThatMovesFiles {
    private let fileMover: FileMovement
    
    init(fileMover: FileMovement = FileManager.shared) {
        self.fileMover = fileMover
    }
    
    func doStuff() {
        try fileMover.moveItem(at: srcUrl, to: dstUrl)
    }
}
```

A corresponding spy implementation that only records which moves had been _requested_ might then look like this:

```swift
class SpyFileMover: FileMovement {
    private(set) var moves: [(URL, URL)] = []
    
    func moveItem(at srcURL: URL, to dstURL: URL) throws {
        moves.append((srcURL, dstURL))
    }
}
```

## Data fetching

A single protocol for the fetching of data:

 * `protocol DataFetching` for retrieving the data and response from a `URL` or `URLRequest`
 
As an even lighter weight solution, `public typealias DataFetcher` describes the signature of `URLSession.data(for:)`, so can be satisfied by passing a simple closure rather than needing an object.

## File downloading

Very similar to `DataFetching`, but dealing in on-disk files rather than in-memory data:

 * `protocol FileDownloading` for retrieving the content and response from a `URL` or `URLRequest` to store in a local file

Again, as an even lighter weight solution `public typealias FileDownloader` describes the signature of `URLSession.download(for:)`, which can also be satisfied by passing a simple closure rather than needing to define a type and pass an instance.
