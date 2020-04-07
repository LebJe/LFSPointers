import SwiftShell
import Foundation
import ArgumentParser
import Rainbow

struct LFSPointers: ParsableCommand {
	static let configuration = CommandConfiguration(
		abstract: "Replaces all large files with Git LFS pointers.")
	
	@Argument(help: "The directory which contains the files you want to convert to LFS pointers.")
	var directory: String
	
	@Argument(help: "The regular expression used to filter files (\"*\" will match everything).")
	var regularExpression: String
	
	@Flag(help: "Whether to display verbose output.")
	var verbose: Bool
	
	func run() throws {
		let fm = FileManager()
		
		do {
			
			for file in try fm.contentsOfDirectory(atPath: directory) {
				
				let regex = try NSRegularExpression(pattern: regularExpression)
				
				if regex.matches(file) {
					if verbose {
						print("Converting \"\(file)\" to pointer using \"git lfs pointer --file=\(file)\"...\n")
					} else {
						print("Converting \"\(file)\" to pointer...\n")
					}
					
					let r = SwiftShell.run("git", "lfs", "pointer", "--file=\(directory + file)")
					var result = r.stdout
					var error = r.stderror
					
					guard !result.isEmpty && error != "read \(file): is a directory" else {
						if verbose {
							print("Could not convert \"\(file)\" to a pointer.\n Git LFS error: \(error)\n".red)
						} else {
							print("Could not convert \"\(file)\" to a pointer.".red)
						}
						
						result = ""
						error = ""
						
						continue
					}
					
					if verbose {
						print("Removing \"Git LFS pointer for \(file)\" from output of previous command...\n")
					}
					
					result = result.replacingOccurrences(of: "Git LFS pointer for \(file)", with: "")
					
					
					if verbose {
						print("Removing large file \"\(file)\"...\n")
					} else {
						print("Replacing file \"\(file)\" with pointer file...\n")
					}
					
					try fm.removeItem(atPath: file)
					
					if verbose {
						print("Creating file \"\(file)\" with contents \"\(result)\"...\n")
					}
					
					fm.createFile(atPath: file, contents: result.data(using: .utf8)!, attributes: nil)
				} else {
					if verbose {
						print("File name \"\(file)\" does not match regular expression \"\(regularExpression)\", continuing...")
					}
				}

			}
			
		} catch let error {
			print("An error occurred: \(error)".red)
			Foundation.exit(2)
		}
	}
}

LFSPointers.main()

extension NSRegularExpression {
	func matches(_ string: String) -> Bool {
		let range = NSRange(location: 0, length: string.utf16.count)
		return firstMatch(in: string, options: [], range: range) != nil
	}
}
