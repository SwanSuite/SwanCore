//
//  FileStorage.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-16.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

import Foundation

/// Specific execution errors thrown by the file storage backend system.
public enum FileStorageError: Error {
    /// Indicates that the requested system `SearchPathDirectory` path could not be resolved inside the active sandbox environment context boundaries.
    case searchPathDirectoryNotFound
}

/// A thread-safe, disk-bound implementation of a key-value persistent storage engine.
///
/// `FileStorage` encapsulates `FileManager` primitives to serialize and store raw dynamic binary payloads (`Data`)
/// within isolated sandbox filesystem structures (such as `.documentDirectory` or `.cachesDirectory`).
///
/// All write mutations invoke thread-resilient atomic file writing options to fully shield the storage container from unexpected crashes.
///
/// ### Swift 6 Concurrency Semantics
/// Explicitly tagged as `@unchecked Sendable`. Because its internal configuration architecture properties are declared via immutable `let` statements,
/// and native `FileManager` execution methods are intrinsically isolated under core system design, this structure is safe to pass across asynchronous tasks.
public struct FileStorage: PersistentStorage, @unchecked Sendable {

    /// The fully qualified target directory filesystem base URL path managed by the receiver instance.
    public let url: URL

    private let fileManager: FileManager

    /// Initializes a disk-bound persistent storage instance targeting an explicit isolated filesystem branch path.
    ///
    /// The initializer verifies boundaries immediately. It performs an upfront verification cycle ensuring all required
    /// subfolder path layers are structurally created before any operational read or write tasks are allowed to take place.
    ///
    /// - Parameters:
    ///   - directory: The root system search path catalog framework context target layout. Defaults to `.documentDirectory`.
    ///   - path: An optional custom nested subfolder path hierarchy pattern to append onto the root URL.
    ///   - fileManager: The underlying file manager provider context instance used for executing I/O disk actions. Defaults to `.default`.
    /// - Throws: A ``FileStorageError/searchPathDirectoryNotFound`` exception if the sandbox environment context prevents the type from resolving paths.
    public init(
        _ directory: FileManager.SearchPathDirectory = .documentDirectory,
        path: String = "",
        fileManager: FileManager = .default
    ) throws {
        self.fileManager = fileManager

        guard let baseURL = fileManager.urls(for: directory, in: .userDomainMask).first else {
            throw FileStorageError.searchPathDirectoryNotFound
        }

        if path.isEmpty {
            self.url = baseURL
        } else {
            self.url = baseURL.appendingPathComponent(path)
        }

        // Ensures the base sub-folders exist immediately before any read/write operations occur.
        try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
    }

    /// Remotely removes a target object file entry associated with the specified key token identifier path.
    ///
    /// This method enforces standard filesystem deletion mechanics. If the target file is missing,
    /// it lets the native system `FileManager` throw a standard exception up the call stack context.
    ///
    /// - Parameter key: The unique filename string identifying the file layout entry.
    /// - Throws: An error if the item is missing or if active disk permissions restrict the file deletion.
    public func removeObject(forKey key: String) throws {
        try fileManager.removeItem(at: fileURL(key))
    }

    /// Retrieves raw binary data buffers associated with the specified filename key token path.
    ///
    /// - Parameter key: The unique storage filename key string.
    /// - Returns: The extracted `Data` buffer representation payload, or `nil` if the file doesn't exist on disk.
    public func data(forKey key: String) -> Data? {
        let filePath = fileURL(key).path(percentEncoded: false)
        return fileManager.contents(atPath: filePath)
    }

    /// Saves raw binary data buffers atomically under the specified filename key token path location.
    ///
    /// - Parameters:
    ///   - data: The source raw binary data container payload block to persist.
    ///   - key: The unique storage target filename key string.
    /// - Throws: An operation error if the underlying atomic write loop fails due to insufficient storage space or permissions.
    public func save(_ data: Data, forKey key: String) throws {
        try data.write(to: fileURL(key), options: .atomic)
    }

    // MARK: - Private Core Inline Utility Helpers

    @inline(__always)
    private func fileURL(_ key: String) -> URL {
        return url.appendingPathComponent(key)
    }
}
