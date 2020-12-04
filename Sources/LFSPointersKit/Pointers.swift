//
//  Pointers.swift
//  
//
//  Created by Jeff Lebrun on 4/14/20.
//

import Foundation
import Files
import Crypto

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
/// let pointer = try LFSPointer(
/// 	version: "https://git-lfs.github.com/spec/v1",
///  	oid: "10b2cd328e193dd4b81d921dbe91bda74bda704c37bca43f1e15f41fcd20ac2a",
///  	size: 1455
/// )
///
/// ```
public struct LFSPointer: Codable, Equatable, Hashable {
	/// The version of the pointer. Example: "https://git-lfs.github.com/spec/v1".
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
		var container = encoder.container(keyedBy: CodingKeys.self)
		
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

		let handle = try FileHandle(forReadingFrom: file.url)

		let readSize = 8192
		var hasher = SHA256()

		while true {
			let data = handle.readData(ofLength: readSize)
			if data.count == 0 {
				break
			}

			hasher.update(data: data)
		}

		self.oid = String(hexEncoding: Data(hasher.finalize()))
		
		let attr = try FileManager.default.attributesOfItem(atPath: file.path)

		self.size = (attr[.size] as? Int) ?? 0

		self.filename = file.name
		self.filePath = file.path
	}
	
	/// Iterates over all files in a directory (excluding hidden files), and generates a LFS pointer for each one.
	/// - Parameters:
	///   - directory: The directory to iterate over.
	///   - recursive: Whether to include subdirectories when iterating.
	///   - type:The search method you want to use.
	///   - printOutput: Whether output should be printed.
	///   - printVerboseOutput: Whether verbose output should be printed.
	///   - statusClosure: Use this closure to determine the status of this function. It will be passed the `URL` of the file or folder being operated on, as well as an enum representing the status of this function.
	/// - Throws: `LocationError` if the directory path is invalid.
	/// - Returns: An array of `LFSPointer`.
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
				case .fileNames(let fileNames):
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
							if status != nil { status!(f.url, .generating) }
							
							do {
								pointers.append(try self.init(fromFile: f.url))
							} catch let error {
								if status != nil { status!(f.url, .error(error)) }
								
								throw error
							}
						}
					}
				
				case .regex(let regex):
					try folder.files.recursive.forEach({ file in
						if regex.matches(file.name) {
							
							if status != nil { status!(file.url, .generating) }
						
							do {
								pointers.append(try self.init(fromFile: file.url))
							} catch let error {
								if status != nil { status!(file.url, .error(error)) }
								
								throw error
							}
							
						} else {
							if status != nil { status!(file.url, .regexDoesntMatch(regex)) }
						}
					})
				case .all:
					try folder.files.recursive.forEach({ file in
						if status != nil { status!(file.url, .generating) }
						
						do {
							pointers.append(try self.init(fromFile: file.url))
						} catch let error {
							if status != nil { status!(file.url, .error(error)) }
							
							throw error
						}
					})
			}
			
		} else {
			switch type {
				case .fileNames(let fileNames):
					var files: [File] = []

					for file in fileNames {
						if let f = (try? File(path: file.path)) {
							files.append(f)
						}
					}

					for f in files {
						if folder.containsFile(named: f.name) {
							if status != nil { status!(f.url, .generating) }
							
							do {
								pointers.append(try self.init(fromFile: f.url))
							} catch let error {
								if status != nil { status!(f.url, .error(error)) }
								
								throw error
							}
						}
					}
				case .regex(let regex):
				
					for file in folder.files {
						if regex.matches(file.name) {
							
							do {
								if status != nil { status!(file.url, .generating) }
								
								pointers.append(try self.init(fromFile: file.url))
							} catch let error {
								if status != nil { status!(file.url, .error(error)) }
								
								throw error
							}
						} else {
							if status != nil { status!(file.url, .regexDoesntMatch(regex)) }
						}
				}
				case .all:
					for file in folder.files {
						do {
							if status != nil { status!(file.url, .generating) }
							
							pointers.append(try self.init(fromFile: file.url))
						} catch let error {
							if status != nil { status!(file.url, .error(error)) }
							
							throw error
						}
					}
			}
		}
		
		return pointers
	}
	
	/// Write `self` (`LFSPointer`) to a file.
	/// - Parameters:
	///   - file: The file to write or append to.
	///   - shouldAppend: If the file should be appended to.
	///   - statusClosure: Use this closure to determine the status of this function. It will be passed the `URL` of the file or folder being operated on, as well as an enum representing the status of this function.
	///   - printOutput: Whether output should be printed.
	///   - printVerboseOutput: Whether verbose output should be printed.
	/// - Throws: `LocationError` if the file path is invalid, or `WriteError` if the file could not be written.
	public func write(
		toFile file: URL,
		withNewline: Bool = false,
		shouldAppend: Bool = false,
		statusClosure status: ((URL, Status) -> Void)? = nil
	) throws {
		
		let file = try File(path: file.path)
		
		if shouldAppend {
			if status != nil { status!(file.url, .appending(self)) }
			
			try file.append("version \(self.version)\noid sha256:\(self.oid)\nsize \(self.size)\(withNewline ? "\n" : "")", encoding: .utf8)
		} else {
			if status != nil { status!(file.url, .writing(self)) }
			
			try file.write("version \(self.version)\noid sha256:\(self.oid)\nsize \(self.size)\(withNewline ? "\n" : "")", encoding: .utf8)
		}
	}
	
	enum CodingKeys: String, CodingKey {
		case version, oid, size, filename, filePath
	}
}

extension LFSPointer: CustomDebugStringConvertible {
	public var debugDescription: String {
		"version \(self.version)\noid sha256:\(self.oid)\nsize \(self.size)"
	}
}

public extension Array where Self.Element == LFSPointer {
	/// Converts and `Array` of `LFSPointer`s to `JSON`.
	/// - Parameter jsonFormat: The format of the generated `JSON`.
	/// - Throws: `EncodingError` when generating `JSON` fails.
	/// - Returns: `Data` containing the generated `JSON`.
	func toJSON(inFormat jsonFormat: JSONEncoder.OutputFormatting = .init()) throws -> Data {
		let encoder = JSONEncoder()
		encoder.outputFormatting = jsonFormat
		return try encoder.encode(self)
	}
}
