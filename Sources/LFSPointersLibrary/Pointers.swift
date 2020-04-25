//
//  Pointers.swift
//  
//
//  Created by Jeff Lebrun on 4/14/20.
//

import Foundation
import Files
import SwiftShell
import Rainbow
import SwiftyJSON

/// Represents a Git LFS pointer for a file.
///
/// The pointer "Git LFS pointer for file.txt
/// version https://git-lfs.github.com/spec/v1
/// oid sha256:10b2cd328e193dd4b81d921dbe91bda74bda704c37bca43f1e15f41fcd20ac2a
/// size 1455", would look like this:
///
/// ```
/// let pointer = LFSPointer(version: "https://git-lfs.github.com/spec/v1", oid: "10b2cd328e193dd4b81d921dbe91bda74bda704c37bca43f1e15f41fcd20ac2a", size: 1455)
/// ```
///
public struct LFSPointer: Codable, Equatable, Hashable {
	/// The version of the pointer. Example: "https://git-lfs.github.com/spec/v1".
	public let version: String
	
	/// An SHA 256 hash for the pointer.
	public let oid: String
	
	/// The size of the converted file.
	public let size: Int
	
	/// String representation of this pointer.
	public var stringRep: String {
		"version \(self.version)\noid sha256:\(self.oid)\nsize \(self.size)"
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		
		try container.encode(self.version, forKey: .version)
		try container.encode(self.oid, forKey: .oid)
		try container.encode(self.size, forKey: .size)
	}
	
	var json: String {
		"""
		{
			"version": "\(self.version)",
			"oid": "\(self.oid)",
			"size": \(self.size)
		}
		"""
	}
	
	/// Iterates over all files in a directory (excluding hidden files), and generates a LFS pointer for each one.
	/// - Parameters:
	///   - directory: The directory to iterate over.
	///   - recursive: Whether to include subdirectories when iterating.
	///   - type:The search method you want to use.
	///   - printOutput: Whether output should be printed.
	///   - printVerboseOutput: Whether verbose output should be printed.
	///   - statusClosure: Use this closure to determine the status of this function. It will be passed the `URL` of the file or folder being operated on, as well as an enum representing the status of this function.
	/// - Throws: `GitLFSError` if an error occurred while generating pointers, or `LocationError` if the directory path is invalid.
	/// - Returns: An array of tuples that contain the filename, file path, and `LFSPointer`.
	public static func pointers(forDirectory directory: URL,
								searchType type: SearchTypes,
								recursive: Bool = false,
								statusClosure status: ((URL, Status) -> Void)? = nil) throws -> [(filename: String, filePath: URL, pointer: LFSPointer)] {
		var pointers: [(filename: String, filePath: URL, pointer: LFSPointer)] = []
		
		let folder = try Folder(path: directory.path)
		
		if recursive {
			switch type {
				case .fileNames(let fileNames):
					let folder = try Folder(path: directory.path)
					
					let folderNames = folder.files.recursive.names()
					
					for name in fileNames {
						if folderNames.contains(name) {
							let file = folder.files.recursive.first(where: { file in
								file.name == name
							})!
							
							if status != nil { status!(file.url, .generating) }
							
							do {
								let pointer = try self.pointer(forFile: file.url)
								
								pointers.append((file.name, file.url, pointer))
							} catch let error {
								if status != nil { status!(file.url, .error(error)) }
								
								throw error
							}
						}
					}
				
				case .regex(let regex):
					try folder.files.recursive.forEach({ file in
						if regex.matches(file.name) {
							
							if status != nil { status!(file.url, .generating) }
						
							do {
								let pointer = try self.pointer(forFile: file.url)
								
								pointers.append((file.name, file.url, pointer))
								
							} catch let error {
								if status != nil { status!(file.url, .error(error)) }
								
								throw error
							}
							
						} else {
							if status != nil { status!(file.url, .regexDosentMatch(regex)) }
						}
					})
				case .all:
					try folder.files.recursive.forEach({ file in
						if status != nil { status!(file.url, .generating) }
						
						do {
							
							let pointer = try self.pointer(forFile: file.url)
							
							pointers.append((file.name, file.url, pointer))
							
						} catch let error {
							if status != nil { status!(file.url, .error(error)) }
							
							throw error
						}
					})
			}
			
		} else {
			switch type {
				case .fileNames(let fileNames):
					for name in fileNames {
						if folder.containsFile(named: name) {
							let file = try folder.file(named: name)
							
							if status != nil { status!(file.url, .generating) }
							
							do {
								let pointer = try self.pointer(forFile: file.url)
								
								pointers.append((file.name, file.url, pointer))
							} catch let error {
								if status != nil { status!(file.url, .error(error)) }
								
								throw error
							}
						}
					}
				case .regex(let regex):
				
					for file in folder.files {
						if regex.matches(file.name) {
							
							do {
								if status != nil { status!(file.url, .generating) }
								
								let pointer = try self.pointer(forFile: file.url)
								
								pointers.append((file.name, file.url, pointer))
							} catch let error {
								if status != nil { status!(file.url, .error(error)) }
								
								throw error
							}
						} else {
							if status != nil { status!(file.url, .regexDosentMatch(regex)) }
						}
				}
				case .all:
					for file in folder.files {
						do {
							if status != nil { status!(file.url, .generating) }
							
							let pointer = try self.pointer(forFile: file.url)
							
							pointers.append((file.name, file.url, pointer))
							
						} catch let error {
							if status != nil { status!(file.url, .error(error)) }
							
							throw error
						}
					}
			}
		}
		
		return pointers
	}
	
	/// Generates a LFS pointer for a file.
	/// - Parameters:
	///   - path: The path to the file.
	///   - statusClosure: Use this closure to determine the status of this function. It will be passed the `URL` of the file or folder being operated on, as well as an enum representing the status of this function.
	/// - Throws: `GitLFSError` if an error occurred while generating pointers, or `LocationError` if the file path is invalid.
	/// - Returns: A `LFSPointer`.
	public static func pointer(forFile path: URL) throws -> LFSPointer {
		let file = try File(path: path.path)
		
		let r = SwiftShell.run("git", "lfs", "pointer", "--file=\(file.path)")
		
		guard !r.stdout.isEmpty && r.stderror != "read \(file): is a directory" else { throw GitLFSError.generic(message: "Git LFS error: \(r.stderror)") }
		
		let components = r.stdout.components(separatedBy: "\n")
		
		guard components.count >= 3 else { throw GitLFSError.malformedGitLFSCommandOutput(output: r.stdout) }
		
		let pointer = LFSPointer(version: components[0].replacingOccurrences(of: "version ", with: ""), oid: components[1].replacingOccurrences(of: "oid sha256:", with: ""), size: Int(components[2].replacingOccurrences(of: "size ", with: "")) ?? 0)
		
		return pointer
	}
	
	/// Write `self` (`LFSPointer`) to a file.
	/// - Parameters:
	///   - file: The file to write or append to.
	///   - shouldAppend: If the file should be appended to.
	///   - statusClosure: Use this closure to determine the status of this function. It will be passed the `URL` of the file or folder being operated on, as well as an enum representing the status of this function.
	///   - printOutput: Whether output should be printed.
	///   - printVerboseOutput: Whether verbose output should be printed.
	/// - Throws: `LocationError` if the file path is invalid, or `WriteError` if the file could not be written.
	public func write(toFile file: URL,
					  shouldAppend: Bool = false,
					  statusClosure status: ((URL, Status) -> Void)? = nil) throws {
		
		let file = try File(path: file.path)
		
		if shouldAppend {
			if status != nil { status!(file.url, .appending(self)) }
			
			try file.append("version \(self.version)\noid sha256:\(self.oid)\nsize \(self.size)", encoding: .utf8)
		} else {
			if status != nil { status!(file.url, .writing(self)) }
			
			try file.write("version \(self.version)\noid sha256:\(self.oid)\nsize \(self.size)", encoding: .utf8)
		}
	}
	
	enum CodingKeys: String, CodingKey {
		case version, oid, size
	}
}

extension LFSPointer: CustomDebugStringConvertible {
	public var debugDescription: String {
		"version \(self.version)\noid sha256:\(self.oid)\nsize \(self.size)"
	}
}

/// Generates a string containing `JSON`.
/// - Parameter array: No description.
/// - Returns: A `String` containing `JSON`.
public func toJSON(array: [(filename: String, filePath: URL, pointer: LFSPointer)]) -> String {
	var arrayOfDict: [[String: Any]] = []
	
	for val in array {
		arrayOfDict.append(["filename": val.filename, "filePath": val.filePath.path, "pointer": ["version": val.pointer.version, "oid": val.pointer.oid, "size": val.pointer.size]])
	}
	
	let json = JSON(arrayOfDict)
	
	return json.description
}
