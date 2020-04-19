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
public struct LFSPointer: Codable {
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
	///   - type:
	///   - printOutput: Whether output should be printed.
	///   - printVerboseOutput: Whether verbose output should be printed.
	/// - Throws: `GitLFSError` if an error occurred while generating pointers, or `LocationError` if the directory path is invalid.
	/// - Returns: An array of tuples that contain the filename, file path, and `LFSPointer`.
	public static func pointers(forDirectory directory: String,
								searchType type: SearchTypes,
								recursive: Bool = false,
								printOutput: Bool = false,
								printVerboseOutput: Bool = false) throws -> [(filename: String, filePath: String, pointer: LFSPointer)] {
		var pointers: [(filename: String, filePath: String, pointer: LFSPointer)] = []
		
		let folder = try Folder(path: directory)
		
		if recursive {
			switch type {
				case .fileNames(let fileNames):
					let folder = try Folder(path: directory)
					
					let folderNames = folder.files.recursive.names()
					
					for name in fileNames {
						if folderNames.contains(name) {
							let file = folder.files.recursive.first(where: { file in
								file.name == name
							})!
							
							if printOutput && printVerboseOutput {
								print("Converting \"\(file.name)\" to pointer...\n")
								print("git lfs pointer --file=\(file.name)".blue)
							} else if printOutput {
								print("Converting \"\(file.name)\" to pointer...\n")
							}
							
							if printOutput {
								do {
									let pointer = try self.pointer(forFile: file.path)
									pointers.append((file.name, file.path, pointer))
								} catch let error {
									if printVerboseOutput && printOutput {
										fputs("Could not convert \"\(file.name)\" to a pointer.\n Git LFS error: \(error)\n".red, stderr)
										
									} else if printOutput {
										fputs("Could not convert \"\(file.name)\" to a pointer.".red, stderr)
									}
								}
								
							} else {
								let pointer = try self.pointer(forFile: file.path)
								pointers.append((file.name, file.path, pointer))
							}
							
						}
					}
				
				case .regex(let regex):
					try folder.files.recursive.forEach({ file in
						if regex.matches(file.name) {
							
							if printOutput && printVerboseOutput {
								print("Converting \"\(file.name)\" to pointer...\n")
								print("git lfs pointer --file=\(file.name)".blue)
							} else if printOutput {
								print("Converting \"\(file.name)\" to pointer...\n")
							}
							
							if printOutput {
								do {
									
									let pointer = try self.pointer(forFile: file.path)
									pointers.append((file.name, file.path, pointer))
									
								} catch let error {
									if printVerboseOutput && printOutput {
										fputs("Could not convert \"\(file.name)\" to a pointer.\n Git LFS error: \(error)\n".red, stderr)
										
									} else if printOutput {
										fputs("Could not convert \"\(file.name)\" to a pointer.".red, stderr)
									}
									
								}
							} else {
								let pointer = try self.pointer(forFile: file.path)
								pointers.append((file.name, file.path, pointer))
							}
							
						} else {
							if printOutput && printVerboseOutput {
								print("File name \"\(file.name)\" does not match regular expression \"\(regex.pattern)\", continuing...")
							}
						}
					})
				case .all:
					try folder.files.recursive.forEach({ file in
							
						if printOutput && printVerboseOutput {
							print("Converting \"\(file.name)\" to pointer...\n")
							print("git lfs pointer --file=\(file.name)".blue)
						} else if printOutput {
							print("Converting \"\(file.name)\" to pointer...\n")
						}
						
						if printOutput {
							do {
								
								let pointer = try self.pointer(forFile: file.path)
								pointers.append((file.name, file.path, pointer))
								
							} catch let error {
								if printVerboseOutput && printOutput {
									fputs("Could not convert \"\(file.name)\" to a pointer.\n Git LFS error: \(error)\n".red, stderr)
									
								} else if printOutput {
									fputs("Could not convert \"\(file.name)\" to a pointer.".red, stderr)
								}
								
							}
						} else {
							let pointer = try self.pointer(forFile: file.path)
							pointers.append((file.name, file.path, pointer))
						}

					})
			}
			
		} else {
			switch type {
				case .fileNames(let fileNames):
					for name in fileNames {
						if folder.containsFile(named: name) {
							let file = try folder.file(named: name)
							
							if printOutput && printVerboseOutput {
								print("Converting \"\(file.name)\" to pointer...\n")
								print("git lfs pointer --file=\(file.name)".blue)
							} else if printOutput {
								print("Converting \"\(file.name)\" to pointer...\n")
							}
							
							if printOutput {
								do {
								
									let pointer = try self.pointer(forFile: file.path)
									pointers.append((file.name, file.path, pointer))
									
								} catch let error {
									if printVerboseOutput && printOutput {
										fputs("Could not convert \"\(file.name)\" to a pointer.\n Git LFS error: \(error)\n".red, stderr)
										
									} else if printOutput {
										fputs("Could not convert \"\(file.name)\" to a pointer.".red, stderr)
									}
									
								}
							} else {
								let pointer = try self.pointer(forFile: file.path)
								pointers.append((file.name, file.path, pointer))
							}

						}
					}
				case .regex(let regex):
				
					for file in folder.files {
						if regex.matches(file.name) {
							
							if printOutput {
								do {
									if printOutput && printVerboseOutput {
										print("Converting \"\(file.name)\" to pointer...\n")
										print("git lfs pointer --file=\(file.name)".blue)
									} else if printOutput {
										print("Converting \"\(file.name)\" to pointer...\n")
									}
									
									let pointer = try self.pointer(forFile: file.path)
									pointers.append((file.name, file.path, pointer))
									
								} catch let error {
									if printVerboseOutput && printOutput {
										fputs("Could not convert \"\(file.name)\" to a pointer.\n Git LFS error: \(error)\n".red, stderr)
										
									} else if printOutput {
										fputs("Could not convert \"\(file.name)\" to a pointer.".red, stderr)
									}
									
								}
							} else {
								if printOutput && printVerboseOutput {
									print("Converting \"\(file.name)\" to pointer...\n")
									print("git lfs pointer --file=\(file.name)".blue)
								} else if printOutput {
									print("Converting \"\(file.name)\" to pointer...\n")
								}
								
								let pointer = try self.pointer(forFile: file.path)
								pointers.append((file.name, file.path, pointer))
							}
						}
				}
				case .all:
					for file in folder.files {
													
						if printOutput {
							do {
								if printOutput && printVerboseOutput {
									print("Converting \"\(file.name)\" to pointer...\n")
									print("git lfs pointer --file=\(file.name)".blue)
								} else if printOutput {
									print("Converting \"\(file.name)\" to pointer...\n")
								}
								
								let pointer = try self.pointer(forFile: file.path)
								pointers.append((file.name, file.path, pointer))
								
							} catch let error {
								if printVerboseOutput && printOutput {
									fputs("Could not convert \"\(file.name)\" to a pointer.\n Git LFS error: \(error)\n".red, stderr)
									
								} else if printOutput {
									fputs("Could not convert \"\(file.name)\" to a pointer.".red, stderr)
								}
								
							}
						} else {
							if printOutput && printVerboseOutput {
								print("Converting \"\(file.name)\" to pointer...\n")
								print("git lfs pointer --file=\(file.name)".blue)
							} else if printOutput {
								print("Converting \"\(file.name)\" to pointer...\n")
							}
							
							let pointer = try self.pointer(forFile: file.path)
							pointers.append((file.name, file.path, pointer))
						}
					
				}
			}
		}
		
		return pointers
	}
	
	/// Generates a LFS pointer for a file.
	/// - Parameter path: The path to the file.
	/// - Throws: `GitLFSError` if an error occurred while generating pointers, or `LocationError` if the file path is invalid.
	/// - Returns: A `LFSPointer`.
	public static func pointer(forFile path: String) throws -> LFSPointer {
		let file = try File(path: path)
		
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
	///   - shouldAppend: If the fie should be appended to.
	///   - printOutput: Whether output should be printed.
	///   - printVerboseOutput: Whether verbose output should be printed.
	/// - Throws: `LocationError` if the file path is invalid, or `WriteError` if the file could not be written.
	public func write(toFile file: String, shouldAppend: Bool = false, printOutput: Bool = false, printVerboseOutput: Bool = false) throws {
		
		let file = try File(path: file)
		
		if shouldAppend {
			if printOutput {
				print("Appending pointer to file \"\(file.name)\"...")
			} else if printVerboseOutput && printOutput {
				print("Appending \"\("version \(self.version)\noid sha256:\(self.oid)\nsize \(self.size)")\" to file \"\(file.name)\"...")
			}
			
			try file.append("version \(self.version)\noid sha256:\(self.oid)\nsize \(self.size)", encoding: .utf8)
		} else {
			if printOutput {
				print("Overwriting file \"\(file.name)\" with pointer...")
			} else if printVerboseOutput && printOutput {
				print("Overwriting file \"\(file.name)\" with \"\("version \(self.version)\noid sha256:\(self.oid)\nsize \(self.size)")\"...")
			}
			
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
/// - Returns: No description.
public func toJSON(array: [(filename: String, filePath: String, pointer: LFSPointer)]) -> String {
	
	
	var arrayOfDict: [[String: Any]] = []
	for val in array {
		arrayOfDict.append(["filename": val.filename, "filePath": val.filePath, "pointer": ["version": val.pointer.version, "oid": val.pointer.oid, "size": val.pointer.size]])
	}
	
	let json = JSON(arrayOfDict)
	
	return json.description
}
