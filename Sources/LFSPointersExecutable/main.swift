import SwiftShell
import Foundation
import ArgumentParser
import Rainbow
import Files
import LFSPointersLibrary

let jsonStructure = """
[
	{
		"filename": "foo.txt",
		"filePath": "/path/to/foo.txt",
		"pointer": {
					"version": "https://git-lfs.github.com/spec/v1",
					"oid": "10b2cd328e193dd4b81d921dbe91bda74bda704c37bca43f1e15f41fcd20ac2a",
					"size": 1455
				   }
	},
	{
		"filename": "bar.txt",
		"filePath": "/path/to/bar.txt",
		"pointer": {
					"version": "https://git-lfs.github.com/spec/v1",
					"oid": "601952b2d85214ea602104a4784728ffa6b323b3a6131a124044fa5bfc2f7bf2",
					"size": 1285200
				   }
	}
]
"""

struct LFSPointersCommand: ParsableCommand {
	static let configuration = CommandConfiguration(commandName: "LFSPointers",
		abstract: "Replaces large files in a directory with Git LFS pointers.", discussion: "JSON STRUCTURE:\n\(jsonStructure)")
	
	@Flag(name: .shortAndLong, help: "Whether to display verbose output.")
	var verbose: Bool
	
	@Flag(name: .shortAndLong, help: "Don't print to standard output or standard error.")
	var silent: Bool
	
	@Flag(name: .shortAndLong, help: "Repeat this process in all directories.")
	var recursive: Bool
	
	@Flag(name: .shortAndLong, help: "Convert all files to pointers (USE WITH CAUTION!).")
	var all: Bool
	
	@Flag(name: .long, help: "Sends JSON to standard output. The JSON is structured as shown above. This will automatically enable --silent.")
	var json: Bool
	
	@Option(name: .shortAndLong, default: nil, help: "The directory files will be copied to before being processed. Will be created if it does not exist. If no directory is specified, no files will be copied.", transform: URL.init(fileURLWithPath:))
	var backupDirectory: URL?
	
	@Argument(help: "The directory which contains the files you want to convert to LFS pointers.", transform: URL.init(fileURLWithPath:))
	var directory: URL
	
	@Argument(help: "A list of filenames that represent files to be converted. Use your shell's regular expression support to pass in a list of files.")
	var files: [String]
	
	mutating func validate() throws {
		// Verify the directory actually exists.
		guard FileManager().fileExists(atPath: directory.path) else {
			throw ValidationError("Directory does not exist at \(directory.path).".red)
		}
	}
	
	mutating func run() throws {
		
		if json {
			silent = true
		}
		
		do {
			
			if let bd = backupDirectory {
				do {
					if !silent {
						print("Copying files to backup directory...")
					}
					
					// Copy the specified directory into the backup directory.
					try Folder(path: directory.path).copy(to: Folder(path: bd.path))
				} catch {
					fputs("Unable to copy the contents of the target directory to the backup directory. Check the folder permissions and check that both folders exist.".red, stderr)
					
					Foundation.exit(4)
				}
			}
			
			if all {
				let pointers = try LFSPointer.pointers(forDirectory: directory.path, searchType: .all, recursive: recursive, printOutput: silent == false ? true : false, printVerboseOutput: verbose)
				
				if !json {
					pointers.forEach({ (filename: String, filePath: String, pointer: LFSPointer) in
						
						do {
							try pointer.write(toFile: filePath, printOutput: silent == false ? true : false, printVerboseOutput: verbose)
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
				} else {
					print(toJSON(array: pointers))
				}

			} else {
				let pointers = try LFSPointer.pointers(forDirectory: directory.path, searchType: .fileNames(files), recursive: recursive, printOutput: silent == false ? true : false, printVerboseOutput: verbose)
				
				if !json {
					pointers.forEach({ (filename: String, filePath: String, pointer: LFSPointer) in
						
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
				} else {
					print(toJSON(array: pointers))
				}

			}
			
		} catch let error {
			if !silent {
				fputs("An error occurred: \(error)".red, stderr)
			}
			
			Foundation.exit(2)
		}
		
		print("Done!".green)
	}
}

LFSPointersCommand.main()


