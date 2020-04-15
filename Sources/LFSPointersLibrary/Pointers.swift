//
//  Pointer.swift
//  
//
//  Created by Jeff Lebrun on 4/14/20.
//

import Foundation
import Files
import SwiftShell

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
	///   - recursive: Include subdirectories when iterating.
	/// - Throws: `GitLFSError` or `LocationError` if the directory path is invalid.
	/// - Returns: An array of tuples that contain the filename, file path, and `LFSPointer`.
	public static func pointers(forDirectory directory: String, regex: NSRegularExpression, recursive: Bool = false) throws -> [(filename: String, filePath: String, pointer: LFSPointer)] {
		var pointers: [(filename: String, filePath: String, pointer: LFSPointer)] = []
		
		if recursive {
			try Folder(path: directory).files.recursive.forEach({ file in
				if regex.matches(file.name) {
					let pointer = try self.pointer(forFile: file.path)
					
					pointers.append((file.name, file.path, pointer))
				}
				
			})
		} else {
			for file in try Folder(path: directory).files {
				if regex.matches(file.name) {
					
					let pointer = try self.pointer(forFile: file.path)
					
					pointers.append((file.name, file.path, pointer))
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
	/// - Throws: `LocationError` if the file path is invalid, or `WriteError` if the file could not be written.
	public func write(toFile file: String, shouldAppend: Bool = false) throws {
		
		let file = try File(path: file)
		
		if shouldAppend {
			try file.append("version \(self.version)\noidsha256:\(self.oid)\nsize \(self.size)", encoding: .utf8)
		} else {
			try file.write("version \(self.version)\noidsha256:\(self.oid)\nsize \(self.size)", encoding: .utf8)
		}
	}
}
