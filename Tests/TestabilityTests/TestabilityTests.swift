import Foundation
import Testing
@testable import Testability

@Test func example() async throws {
    // GIVEN
    let spyMover = SpyMover()
    let sut = ThingThatMovesFiles(fileMover: spyMover)

    // WHEN a file move is triggered
    try sut.doSomething()

    // THEN a single move is recorded, with the correct source and destination
    #expect(spyMover.moves.count == 1)
    #expect(spyMover.moves.first?.src.path() == "/some/source/path")
    #expect(spyMover.moves.first?.dst.path() == "/other/destination")
}

struct ThingThatMovesFiles {
    private let fileMover: FileMovement

    init(fileMover: FileMovement = FileManager.default) {
        self.fileMover = fileMover
    }

    func doSomething() throws {
        try fileMover.moveItem(at: URL(fileURLWithPath: "/some/source/path"),
                               to: URL(fileURLWithPath: "/other/destination"))
    }
}

class SpyMover: FileMovement {
    private(set) var moves: [(src: URL, dst: URL)] = []

    func moveItem(at srcURL: URL, to dstURL: URL) throws {
        moves.append((srcURL, dstURL))
    }
}
