//
//  Pointers.swift
//  
//
//  Created by Jeff Lebrun on 4/14/20.
//

import Foundation
import Files
import CryptoSwift

/// Represents a Git LFS pointer for a file.
///
/// The pointer "Git LFS pointer for file.txt
/// version https://git-lfs.github.com/spec/v1
/// oid sha256:10b2cd328e193dd4b81d921dbe91bda74bda704c37bca43f1e15f41fcd20ac2a
/// size 1455", would look like this:
///
/// ```
/// let pointer = LFSPointer(
/// 	version: "https://git-lfs.github.com/spec/v1",
///  	oid: "10b2cd328e193dd4b81d921dbe91bda74bda704c37bca43f1e15f41fcd20ac2a", size: 1455
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
	
	/// Initializes `self` from a file.
	/// - Parameters:
	///   - path: The path to the file.
	/// - Throws: `LocationError` if the file path is invalid.
	public init(fromFile path: URL) throws {
		let file = try File(path: path.path)
		
		self.version = "https://git-lfs.github.com/spec/v1"
		
		self.oid = try FileHandle(forReadingFrom: file.url).availableData.sha256().toHexString()
		
		let attr = try FileManager.default.attributesOfItem(atPath: file.path)
		
		self.size = attr[.size] as! Int
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
	public static func pointers(
		forDirectory directory: URL,
		searchType type: SearchTypes,
		recursive: Bool = false,
		statusClosure status: ((URL, Status) -> Void)? = nil
	) throws -> [JSONPointer] {
		var pointers: [JSONPointer] = []
		
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
								let pointer = try self.init(fromFile: file.url)
								
								pointers.append(JSONPointer(filename: file.name, filePath: file.path, pointer: pointer))
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
								let pointer = try self.init(fromFile: file.url)
								
								pointers.append(JSONPointer(filename: file.name, filePath: file.path, pointer: pointer))
								
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
							
							let pointer = try self.init(fromFile: file.url)
							
							pointers.append(JSONPointer(filename: file.name, filePath: file.path, pointer: pointer))
							
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
								let pointer = try self.init(fromFile: file.url)
								
								pointers.append(JSONPointer(filename: file.name, filePath: file.path, pointer: pointer))
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
								
								let pointer = try self.init(fromFile: file.url)
								
								pointers.append(JSONPointer(filename: file.name, filePath: file.path, pointer: pointer))
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
							
							let pointer = try self.init(fromFile: file.url)
							
							pointers.append(JSONPointer(filename: file.name, filePath: file.path, pointer: pointer))
							
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
		shouldAppend: Bool = false,
		statusClosure status: ((URL, Status) -> Void)? = nil
	) throws {
		
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

public struct JSONPointer: Codable {
	public let filename: String
	public let filePath: String
	public let pointer: LFSPointer
}

/// Generates a string containing `JSON`.
/// - Parameter array: No description.
/// - Returns: A `String` containing `JSON`.
public func toJSON(array: [JSONPointer], jsonFormat: JSONEncoder.OutputFormatting = .init()) -> String {

	let encoder = JSONEncoder()

	encoder.outputFormatting = jsonFormat

	let jsonBytes = (try? encoder.encode(array)) ?? Data()

	let jsonString = String(data: jsonBytes, encoding: .utf8) ?? ""

	return jsonString
}
