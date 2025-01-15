
import Foundation
import Testing
@testable import Testability

@Test func exampleAttributeRead() async throws {
    let spy = SpyFileAttributes()
    try spy.setAttributes([FileAttributeKey.creationDate: Date(timeIntervalSince1970: 0)], ofItemAtPath: "/some/path")
    let sut = DummySut(fileAttributes: spy)

    let creationDate = try sut.getCreation(of: "/some/path")

    #expect(creationDate == Date(timeIntervalSince1970: 0))
}

@Test func exampleAttributeWrite() async throws {
    let spy = SpyFileAttributes()
    let sut = DummySut(fileAttributes: spy)

    try sut.setCreation(of: "/some/path", date: Date(timeIntervalSince1970: 1234))

    let appliedDate = try spy.attributesOfItem(atPath: "/some/path")[FileAttributeKey.creationDate] as? Date

    #expect(appliedDate == Date(timeIntervalSince1970:1234))
}

/// A trivial potential SUT. In reality there would be logic to fetch, calculate or
/// otherwise determine what date to be applying, and *that* is what we would be testing.
class DummySut {
    private let fileAttributes: FileAttributes

    init(fileAttributes: FileAttributes) {
        self.fileAttributes = fileAttributes
    }

    func setCreation(of path: String, date: Date) throws {
        try fileAttributes.setAttributes([FileAttributeKey.creationDate: date as NSDate], ofItemAtPath: path)
    }

    func getCreation(of path: String) throws -> Date? {
        try fileAttributes.attributesOfItem(atPath: path)[FileAttributeKey.creationDate] as? Date
    }
}

class SpyFileAttributes: FileAttributes {
    private(set) var attributes: [String: [FileAttributeKey : Any]] = [:]

    struct FileNotFoundError: Error {}

    func setAttributes(_ attributes: [FileAttributeKey : Any], ofItemAtPath path: String) throws {
        for (key, value) in attributes {
            self.attributes[path, default: [:]][key] = value
        }
    }
    
    func attributesOfItem(atPath path: String) throws -> [FileAttributeKey : Any] {
        guard let attributes = attributes[path] else {
            throw FileNotFoundError()
        }
        return attributes
    }
}
