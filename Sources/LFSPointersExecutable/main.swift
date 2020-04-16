import SwiftShell
import Foundation
import ArgumentParser
import Rainbow
import Files
import LFSPointersLibrary

struct LFSPointersCommand: ParsableCommand {
	static let configuration = CommandConfiguration(commandName: "LFSPointers",
		abstract: "Replaces large files in a directory with Git LFS pointers.")
	
	@Flag(name: .shortAndLong, help: "Whether to display verbose output.")
	var verbose: Bool
	
	@Flag(name: .shortAndLong, help: "Don't print to standard output or standard error.")
	var silent: Bool
	
	@Flag(name: .shortAndLong, help: "Repeat this process in all directories.")
	var recursive: Bool
	
	@Option(default: nil, help: "The directory files will be copied to before being processed. Will be created if it does not exist. If no directory is specified, no files will be copied.", transform: URL.init(fileURLWithPath:))
	var backupDirectory: URL?
	
	@Argument(help: "The directory which contains the files you want to convert to LFS pointers.", transform: URL.init(fileURLWithPath:))
	var directory: URL
	
	@Argument(help: "The regular expression used to filter files (\"*\" will match everything). Remember to encapsulate your expression with double quotes so your shell doesn't pass in a list of filenames that match the expression.")
	var regularExpression: String
	
	mutating func validate() throws {
		// Verify the directory actually exists.
		guard FileManager().fileExists(atPath: directory.path) else {
			throw ValidationError("Directory does not exist at \(directory.path).".red)
		}
	}
	
	func run() throws {
		
		do {
			
			
			if let bd = backupDirectory {
				do {
					// Copy the specified directory into the backup directory.
					try Folder(path: directory.absoluteString).copy(to: Folder(path: bd.absoluteString))
				} catch {
					fputs("Unable to copy the contents of the target directory to the backup directory. Check the folder permissions and check that both folders exist.".red, stderr)
					
					Foundation.exit(3)
				}
			}
			
			let regex: NSRegularExpression!
			
			do {
				regex = try NSRegularExpression(pattern: regularExpression)
			} catch let error {
				if !silent {
					fputs("Invalid regular expression.".red, stderr)
				}
			}
			
			try LFSPointer.pointers(forDirectory: directory.absoluteString, regex: regex, recursive: recursive, printOutput: silent, printVerboseOutput: verbose).forEach({ (filename: String, filePath: String, pointer: LFSPointer) in
				
				do {
					try pointer.write(toFile: filePath)
				} catch is LocationError {
					if !silent {
						fputs("Unable to overwrite file \"\(filename)\". Check the file permissions and check that the file exists.".red, stderr)
					}
				} catch let error {
					if !silent {
						fputs("Unable to overwrite file \"\(filename)\". Error: \(error)", stderr)
					}
				}
				
			})
			
		} catch let error {
			if !silent {
				fputs("An error occurred: \(error)".red, stderr)
			}
			
			Foundation.exit(2)
		}
	}
}

LFSPointersCommand.main()


