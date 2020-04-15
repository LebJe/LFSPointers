//
//  Pointer.swift
//  
//
//  Created by Jeff Lebrun on 4/14/20.
//

import Foundation
import Files
import SwiftShell
import Rainbow

let fm = FileManager()

/// Represents a Git LFS pointer for a file.
///
/// This pointer "Git LFS pointer for file.txt
/// version https://git-lfs.github.com/spec/v1
/// oid sha256:10b2cd328e193dd4b81d921dbe91bda74bda704c37bca43f1e15f41fcd20ac2a
/// size 1455", would look like this:
///
/// ```
/// let pointer = LFSPointer(version: "https://git-lfs.github.com/spec/v1", oid: "10b2cd328e193dd4b81d921dbe91bda74bda704c37bca43f1e15f41fcd20ac2a", size: 1455)
/// ```
///
public struct LFSPointer {
	let version: String
	let oid: String
	let size: Int
	
	/// Iterates over all files in a directory (excluding hidden files), and generates a LFS pointer for each one.
	/// - Parameters:
	///   - directory: The directory to iterate over.
	///   - recursive: Whether to include subdirectories when iterating.
	///   - regex: The regular expression used to filter files. NSRegularExpression(pattern: "*") will match all files.
	///   - printOutput: Whether output should be printed.
	///   - printVerboseOutput: Whether verbose output should be printed.
	/// - Throws: `GitLFSError` or `LocationError` if the directory path is invalid.
	/// - Returns: An array of tuples that contain the filename, file path, and `LFSPointer`.
	public static func pointers(forDirectory directory: String, regex: NSRegularExpression, recursive: Bool = false, printOutput: Bool = false, printVerboseOutput: Bool = false) throws -> [(filename: String, filePath: String, pointer: LFSPointer)] {
		var pointers: [(filename: String, filePath: String, pointer: LFSPointer)] = []
		
		if recursive {
			try Folder(path: directory).files.recursive.forEach({ file in
				if regex.matches(file.name) {
					
					if printOutput && printVerboseOutput {
						print("Converting \"\(file.name)\" to pointer...\n")
						print("git lfs pointer --file=\(file.name)".blue)
					} else if printOutput {
						print("Converting \"\(file.name)\" to pointer...\n")
					}
					
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
					if printOutput && printVerboseOutput {
						print("File name \"\(file.name)\" does not match regular expression \"\(regex.pattern)\", continuing...")
					}
				}
				
			})
		} else {
			for file in try Folder(path: directory).files {
				if regex.matches(file.name) {
					
					if printOutput && printVerboseOutput {
						print("Converting \"\(file.name)\" to pointer...\n")
						print("git lfs pointer --file=\(file.name)".blue)
					} else if printOutput {
						print("Converting \"\(file.name)\" to pointer...\n")
					}
					
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
					if printOutput && printVerboseOutput {
						print("File name \"\(file.name)\" does not match regular expression \"\(regex.pattern)\", continuing...")
					}
				}
			}
		}
		
		return pointers
	}
	
	/// Generates a LFS pointer for a file.
	/// - Parameter path: The path to the file.
	/// - Throws: `GitLFSError` or `LocationError` if the file path is invalid.
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
			
			try file.write("version \(self.version)\noidsha256:\(self.oid)\nsize \(self.size)", encoding: .utf8)
		}
	}
}

extension LFSPointer: CustomDebugStringConvertible {
	public var debugDescription: String {
		"version \(self.version)\noid sha256:\(self.oid)\nsize \(self.size)"
	}
	
	
}
