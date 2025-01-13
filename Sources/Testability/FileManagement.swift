import Foundation

public protocol FileMovement {
    func moveItem(at srcURL: URL, to dstURL: URL) throws
}

public protocol FileInspection {
    func isReadableFile(atPath path: String) -> Bool
    func fileExists(atPath path: String) -> Bool
    func fileExists(atPath path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) -> Bool
}

public protocol FileListing {
    var currentDirectoryPath: String { get }
    func contentsOfDirectory(atPath path: String) throws -> [String]
    func subpathsOfDirectory(atPath path: String) throws -> [String]
}

public protocol FileManagement: FileMovement, FileInspection, FileListing {
    func url(for directory: FileManager.SearchPathDirectory,
             in domain: FileManager.SearchPathDomainMask,
             appropriateFor url: URL?,
             create shouldCreate: Bool) throws -> URL
}

extension FileManager: FileManagement {}
