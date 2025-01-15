import Foundation

public protocol FileAttributes {
    func setAttributes(_ attributes: [FileAttributeKey: Any], ofItemAtPath path: String) throws
    func attributesOfItem(atPath path: String) throws -> [FileAttributeKey: Any]
}

extension FileManager: FileAttributes {}
