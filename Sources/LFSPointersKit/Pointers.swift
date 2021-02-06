//
//  Pointers.swift
//
//
//  Created by Jeff Lebrun on 4/14/20.
//

import Crypto
import Files
import struct Foundation.Data
import struct Foundation.URL
import struct SystemPackage.FileDescriptor
import struct SystemPackage.FilePath

/// Represents a Git LFS pointer for a file.
///
/// The pointer
///
/// ```
/// Git LFS pointer for file.txt
/// version https://git-lfs.github.com/spec/v1
/// oid sha256:10b2cd328e193dd4b81d921dbe91bda74bda704c37bca43f1e15f41fcd20ac2a
/// size 1455
/// ```
/// would look like this:
///
/// ```
/// let pointer = try LFSPointer(fromFile: URL(fileURLWithPath: "file.txt"))
/// pointer.oid // 10b2cd328e193dd4b81d921dbe91bda74bda704c37bca43f1e15f41fcd20ac2a
/// pointer.size // 1455
/// pointer.version // https://git-lfs.github.com/spec/v1
/// ```
///
public struct LFSPointer: Codable, Equatable, Hashable {
	/// The version of the pointer.
	///
	/// Example: "https://git-lfs.github.com/spec/v1".
	public let version: String

	/// An SHA 256 hash for the pointer.
	public let oid: String

	/// The size of the converted file.
	public let size: Int

	/// The name of the file.
	public let filename: String

	/// The full path of the file.
	public let filePath: String

	/// String representation of this pointer.
	public var stringRep: String {
		"version \(self.version)\noid sha256:\(self.oid)\nsize \(self.size)"
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: Self.CodingKeys.self)

		try container.encode(self.version, forKey: .version)
		try container.encode(self.oid, forKey: .oid)
		try container.encode(self.size, forKey: .size)
		try container.encode(self.filename, forKey: .filename)
		try container.encode(self.filePath, forKey: .filePath)
	}

	/// Initializes `self` from a file.
	/// - Parameters:
	///   - path: The path to the file.
	/// - Throws: `LocationError` if the file path is invalid.
	public init(fromFile path: URL) throws {
		let file = try File(path: path.path)

		self.version = "https://git-lfs.github.com/spec/v1"

		let fd = try FileDescriptor.open(FilePath(file.path), .readOnly)
		defer {
			try! fd.close()
		}

		self.size = Int(try fd.seek(offset: 0, from: .end))

		try fd.seek(offset: 0, from: .start)

		let buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: Int(self.size), alignment: 4)

		_ = try fd.read(into: buffer)

		var hasher = SHA256()
		hasher.update(data: Data(buffer))

		self.oid = String(hexEncoding: Data(hasher.finalize()))

		self.filename = file.name
		self.filePath = file.path
	}

	/// Iterates over all files in a directory (excluding hidden files), and generates a LFS pointer for each one.
	///
	/// - Parameters:
	///   - directory: The directory to iterate over.
	///   - recursive: Whether to include subdirectories when iterating.
	///   - type:The search method you want to use.
	///   - status: Use this closure to determine the status of this function. It will be passed the `URL` of the file or folder being operated on, as well as an enum representing the status of this function.
	/// - Throws: `LocationError` if the directory path is invalid.
	/// - Returns: An array of `LFSPointer`.
	///
	public static func pointers(
		forDirectory directory: URL,
		searchType type: SearchTypes,
		recursive: Bool = false,
		statusClosure status: ((URL, Status) -> Void)? = nil
	) throws -> [LFSPointer] {
		var pointers: [LFSPointer] = []

		let folder = try Folder(path: directory.path)

		if recursive {
			switch type {
				case let .fileNames(fileNames):
					var files: [File] = []

					for file in fileNames {
						if let f = (try? File(path: file.path)) {
							files.append(f)
						}
					}

					let folder = try Folder(path: directory.path)

					let folderNames = folder.files.recursive.names()

					for f in files {
						if folderNames.contains(f.name) {
							status?(f.url, .generating)

							do {
								pointers.append(try self.init(fromFile: f.url))
							} catch {
								status?(f.url, .error(error))

								throw error
							}
						}
					}

				case let .regex(regex):
					return try folder.files.recursive.compactMap({ file in
						if regex.matches(file.name) {
							return try singleFile(file: file, statusClosure: status)
						} else {
							status?(file.url, .regexDoesntMatch(regex))
							return nil
						}
					})
				case .all:
					return try all(folder: folder, recursive: true, statusClosure: status)
			}

		} else {
			switch type {
				case let .fileNames(fileNames):
					var files: [File] = []

					for file in fileNames {
						if let f = (try? File(path: file.path)) {
							files.append(f)
						}
					}

					for f in files {
						if folder.containsFile(named: f.name) {
							status?(f.url, .generating)

							do {
								pointers.append(try self.init(fromFile: f.url))
							} catch {
								status?(f.url, .error(error))

								throw error
							}
						}
					}
				case let .regex(regex):
					return try folder.files.compactMap({ file in
						if regex.matches(file.name) {
							return try singleFile(file: file, statusClosure: status)
						} else {
							status?(file.url, .regexDoesntMatch(regex))
							return nil
						}
					})
				case .all:
					return try all(folder: folder, statusClosure: status)
			}
		}

		return pointers
	}

	/// Write `self` (`LFSPointer`) to a file.
	///
	/// - Parameters:
	///   - file: The file to write or append to.
	///   - shouldAppend: If the file should be appended to.
	///   - status: Use this closure to determine the status of this function. It will be passed the `URL` of the file or folder being operated on, as well as an enum representing the status of this function.
	/// - Throws: `LocationError` if the file path is invalid, or `WriteError` if the file could not be written.
	///
	public func write(
		toFile file: URL,
		shouldAppend: Bool = false,
		statusClosure status: ((URL, Status) -> Void)? = nil
	) throws {
		let file = try File(path: file.path)

		if shouldAppend {
			if status != nil { status!(file.url, .appending(self)) }

			try file.append("version \(self.version)\noid sha256:\(self.oid)\nsize \(self.size)\n", encoding: .utf8)
		} else {
			if status != nil { status!(file.url, .writing(self)) }

			try file.write("version \(self.version)\noid sha256:\(self.oid)\nsize \(self.size)\n", encoding: .utf8)
		}
	}

	enum CodingKeys: String, CodingKey {
		case version, oid, size, filename, filePath
	}
}
