import SwiftShell
import Foundation
import ArgumentParser
import Rainbow
import Files

struct LFSPointers: ParsableCommand {
	static let configuration = CommandConfiguration(commandName: "LFSPointers",
		abstract: "Replaces large files in a directory with Git LFS pointers.", discussion: "EXIT CODES:\n1 = \"git lfs pointer ==file=file\" failed.\n2 = file manipulation failed (missing file permissions, deleted file, etc).")
	
	@Flag(name: .shortAndLong, help: "Whether to display verbose output.")
	var verbose: Bool
	
	@Flag(name: .shortAndLong, help: "Don't print to standard output or standard error.")
	var silent: Bool
	
	@Flag(name: .shortAndLong, help: "Whether to exit when \"git lfs pointer --file=file\" fails.")
	var exitOnFailure: Bool
	
	@Option(default: nil, help: "The directory files will be copied to before being processed. Will be created if it does not exist.", transform: URL.init(fileURLWithPath:))
	var backupDirectory: URL?
	
	@Argument(help: "The directory which contains the files you want to convert to LFS pointers.", transform: URL.init(fileURLWithPath:))
	var directory: URL
	
	@Argument(help: "The regular expression used to filter files (\"*\" will match everything). Remember to encapsulate your expression with double quotes so your shell doesn't pass in a list of filenames that match the expression.")
	var regularExpression: String
	
	mutating func validate() throws {
		// Verify the file actually exists.
		guard FileManager().fileExists(atPath: directory.path) else {
			throw ValidationError("Directory does not exist at \(directory.path).".red)
		}
	}
	
	func run() throws {
		
		// Create an instance of FileManager.
		let fm = FileManager()
		
		do {
			
			
			
			// Iterate over all the files in the specified directory.
			for file in try fm.contentsOfDirectory(atPath: directory.absoluteString) {
				
				// Create a NSRegularExpression from the string provided at the command line.
				let regex = try NSRegularExpression(pattern: regularExpression)
				
				// If the regex matches the filename in the directory we are iterating over, then covert it to a LFS pointer.
				if regex.matches(file) {
					
					if verbose {
						print("Converting \"\(file)\" to pointer...\n")
						print("git lfs pointer --file=\(file)".blue)
					} else {
						print("Converting \"\(file)\" to pointer...\n")
					}
					
					// Run "git lfs pointer --file=\(file)".
					let r = SwiftShell.run("git", "lfs", "pointer", "--file=\(directory.path + file)")
					
					var result = r.stdout
					var error = r.stderror
					
					// Exit if an error was sent to stderr.
					guard !result.isEmpty && error != "read \(file): is a directory" else {
						if verbose {
							fputs("Could not convert \"\(file)\" to a pointer.\n Git LFS error: \(error)\n".red, stderr)
							
							if exitOnFailure {
								Foundation.exit(1)
							}
							
						} else {
							fputs("Could not convert \"\(file)\" to a pointer.".red, stderr)
						}
						
						result = ""
						error = ""
						
						continue
					}
					
					if verbose {
						print("Removing \"Git LFS pointer for \(file)\" from output of previous command...\n")
					}
					
					// let's remove "Git LFS pointer for \(file)" from the result.
					result = result.replacingOccurrences(of: "Git LFS pointer for \(file)", with: "")
					
					
					if verbose {
						print("Removing large file \"\(file)\"...\n")
					} else {
						print("Replacing file \"\(file)\" with pointer file...\n")
					}
					
					// Lets remove the file...
					try fm.removeItem(atPath: file)
					
					if verbose {
						print("Creating file \"\(file)\" with contents \"\(result)\"...\n")
					}
					
					// ...and replace it with a new containing the contents of the variable called "result".
					fm.createFile(atPath: file, contents: result.data(using: .utf8)!, attributes: nil)
				} else {
					if verbose {
						print("File name \"\(file)\" does not match regular expression \"\(regularExpression)\", continuing...")
					}
				}

			}
			
		} catch let error {
			fputs("An error occurred: \(error)".red, stderr)
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
