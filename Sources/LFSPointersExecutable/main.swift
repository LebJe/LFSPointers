//
//  main.swift
//
//
//  Created by Jeff Lebrun on 0/00/20.
//

import ArgumentParser
import Files
import Foundation
import LFSPointersKit
import Rainbow

let jsonStructure = """
[
	{
		"version": "https://git-lfs.github.com/spec/v1",
		"oid": "10b2cd328e193dd4b81d921dbe91bda74bda704c37bca43f1e15f41fcd20ac2a",
		"size": 1455,
		"filename": "foo.txt",
		"filePath": "/path/to/foo.txt"
	},
	{
		"version": "https://git-lfs.github.com/spec/v1",
		"oid": "601952b2d85214ea602104a4784728ffa6b323b3a6131a124044fa5bfc2f7bf2",
		"size": 1285200,
		"filename": "bar.txt",
		"filePath": "/path/to/bar.txt"
	}
]
"""

enum JSONFormat: String, CaseIterable, ExpressibleByArgument {
	case formatted, compact
}

struct LFSPointersCommand: ParsableCommand {
	static let configuration = CommandConfiguration(
		commandName: "LFSPointers",
		abstract: "Replaces large files in a Git repository directory with Git LFS pointers.",
		discussion: "JSON STRUCTURE:\n\(jsonStructure)",
		version: "4.0.0"
	)

	@Flag(name: .shortAndLong, help: "Whether to display verbose output.")
	var verbose: Bool = false

	@Flag(name: .customLong("silent"), help: "Don't print to standard output or standard error.")
	var s: Bool = false

	@Flag(name: .shortAndLong, help: "Repeat this process in all directories.")
	var recursive: Bool = false

	@Flag(name: .shortAndLong, help: "Convert all files to pointers (USE WITH CAUTION!).")
	var all: Bool = false

	@Flag(name: .long, help: "Sends JSON to standard output. The JSON is structured as shown above. This will automatically enable --silent.")
	var json: Bool = false

	@Flag(name: .long, inversion: .prefixedEnableDisable, help: "Whether to send colorized output to the terminal or not.")
	var color: Bool = true

	@Option(
		name: .long,
		help: "The format in which JSON is printed. You can choose either \"compact\" or \"formatted\"."
	)
	var jsonFormat: JSONFormat = .compact

	@Option(
		name: .shortAndLong,
		help: "The directory files will be copied to before being processed. If no directory is specified, no files will be copied.",
		completion: .directory,
		transform: URL.init(fileURLWithPath:)
	)
	var backupDirectory: URL? = nil

	@Argument(
		help: "The directory which contains the files you want to convert to LFS pointers.",
		completion: .directory,
		transform: URL.init(fileURLWithPath:)
	)
	var directory: URL

	@Argument(
		help: "A list of paths to files, relative to the current directory, that represent files to be converted. You can use your shell's regular expression support to pass in a list of files.",
		completion: .file()
	)
	var files: [String] = []

	mutating func validate() throws {
		// Verify the directory actually exists.
		guard FileManager().fileExists(atPath: self.directory.path) else {
			throw ValidationError("Directory does not exist at \"\(self.directory.path)\".".red)
		}

		if !self.files.isEmpty {
			for file in self.files {
				guard Folder.current.containsFile(at: file) == true || Folder.current.containsSubfolder(at: file) else {
					throw ValidationError("File does not exist at \"\(file)\".".red)
				}
			}
		}
	}

	func run() throws {
		var silent = false
		if self.s { silent = true }
		silent = self.json ? true : silent

		Rainbow.enabled = self.color
		Log.isSilent = silent
		Log.isVerbose = self.verbose

		let printClosure: (URL, Status) -> Void = { url, status in
			switch status {
				case let .appending(pointer):
					let file = try! File(path: url.path)
					Log.info(
						"Appending pointer to file \"\(file.name)\"...",
						verboseMessage: "Appending \"\("version \(pointer.version)\noid sha256:\(pointer.oid)\nsize \(pointer.size)")\" to file \"\(file.name)\"..."
					)
				case let .error(error):
					let file = try! File(path: url.path)

					Log.info(
						"Could not convert \"\(file.name)\" to a pointer.".red,
						verboseMessage: "Could not convert \"\(file.name)\" to a pointer.\n error: \(error)\n".red
					)
				case .generating:
					let file = try! File(path: url.path)

					Log.info("Converting \"\(file.name)\" to pointer...\n")
				case let .regexDoesntMatch(regex):
					let file = try! File(path: url.path)
					Log.info("", verboseMessage: "File name \"\(file.name)\" does not match regular expression \"\(regex.pattern)\", continuing...")

				case let .writing(pointer):
					let file = try! File(path: url.path)
					Log.info(
						"Overwriting file \"\(file.name)\" with pointer...",
						verboseMessage: "Overwriting file \"\(file.name)\" with \"\("version \(pointer.version)\noid sha256:\(pointer.oid)\nsize \(pointer.size)")\"..."
					)
			}
		}

		do {
			if self.all, !self.json {
				print("Are you sure? [Y(es)\\N(o)] ", terminator: "")
				let answer = readLine() ?? ""

				switch answer.lowercased() {
					case "y", "yes":
						break
					default:
						Foundation.exit(0)
				}
			}

			if let bd = backupDirectory {
				do {
					Log.info("Copying files to backup directory...")

					// Copy the specified directory into the backup directory.
					try Folder(path: self.directory.path).copy(to: Folder(path: bd.path))
				} catch {
					Log.error("Unable to copy the contents of the target directory to the backup directory. Check the folder permissions and check that both folders exist.")
					Foundation.exit(4)
				}
			}

			if self.all {
				let pointers = try LFSPointer.pointers(
					forDirectory: self.directory,
					searchType: .all,
					recursive: self.recursive,
					statusClosure: printClosure
				)

				if !self.json {
					pointers.forEach({ p in
						do {
							try p.write(
								toFile: URL(fileURLWithPath: p.filePath),
								statusClosure: printClosure
							)
						} catch is LocationError {
							Log.error("Unable to overwrite file \"\(p.filename)\". Check the file permissions and check that the file exists.")
						} catch {
							Log.error("Unable to overwrite file \"\(p.filename)\". Error: \(error)")
						}

					})
				} else {
					do {
						let encoder = JSONEncoder()
						encoder.outputFormatting = [self.jsonFormat == .compact ? .init() : .prettyPrinted, .withoutEscapingSlashes]

						let result = String(data: try encoder.encode(pointers), encoding: .utf8) ?? "{\"error\": \"Failed to generate JSON\"}"

						print(result)
					} catch {
						if !silent {
							fputs("Unable to generate JSON. Error: \(error)", stderr)
						} else {
							print("{\"error\": \"\(error)\"}")
						}
					}
				}

			} else {
				let urls = self.files.map({ URL(string: $0)! })

				let pointers = try LFSPointer.pointers(
					forDirectory: self.directory,
					searchType: .fileNames(urls),
					recursive: self.recursive,
					statusClosure: printClosure
				)

				if !self.json {
					pointers.forEach({ p in
						do {
							try p.write(
								toFile: URL(fileURLWithPath: p.filePath),
								statusClosure: printClosure
							)
						} catch is LocationError {
							Log.error("Unable to overwrite file \"\(p.filename)\". Check the file permissions and check that the file exists.")
						} catch {
							Log.error("Unable to overwrite file \"\(p.filename)\". Error: \(error)")
						}
					})
				} else {
					do {
						let encoder = JSONEncoder()
						encoder.outputFormatting = [self.jsonFormat == .compact ? .init() : .prettyPrinted, .withoutEscapingSlashes]

						let result = String(data: try encoder.encode(pointers), encoding: .utf8) ?? "{\"error\": \"Failed to generate JSON\"}"

						print(result)
					} catch {
						print("{\"error\": \"\(error)\"}")
					}
				}
			}

		} catch {
			Log.error("An error occurred: \(error)")
			Foundation.exit(2)
		}

		Log.info("Done!".green)
	}
}

LFSPointersCommand.main()

enum Log {
	static var isSilent: Bool = false
	static var isVerbose: Bool = false

	static func error(_ message: String, file: UnsafeMutablePointer<FILE> = stderr) {
		if !self.isSilent {
			fputs(message.red, file)
		}
	}

	static func info(_ message: String, verboseMessage: String? = nil) {
		if !Self.isSilent {
			if Self.isVerbose {
				print(verboseMessage ?? message)
			} else {
				print(message)
			}
		}
	}
}
