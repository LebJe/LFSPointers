#!/usr/bin/env swift

import Foundation
import Darwin.C

extension Process {
	public static func execute(_ command: String, args: String...) throws -> (stdout: String?, stderr: String?) {
		let process = Process()
		let stdoutPipe = Pipe()
		let stderrPipe = Pipe()

		let path = (ProcessInfo.processInfo.environment["PATH"] ?? "")
			.components(separatedBy: ":")
			.filter({
            	let url = URL(fileURLWithPath: $0).appendingPathComponent(command)
                return FileManager.default.fileExists(atPath: url.path)
            })

			process.standardError = stderrPipe
			process.standardOutput = stdoutPipe
			process.executableURL = URL(fileURLWithPath: path[0]).appendingPathComponent(command)
			process.arguments = args
			try process.run()

		let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
		let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
		let stdoutString = String(data: stdoutData, encoding: .utf8)
		let stderrString = String(data: stderrData, encoding: .utf8)
		return (stdoutString, stderrString)
	}
}

let help = """
	USAGE: ./make <sub-command>
	
	SUBCOMMANDS:
	  build			Build LFSPointers.
	  gen-man		Generate the manpage using `pandoc` (`pandoc` must be installed and visible in `PATH`).
	  gen-changelog 	Generate the CHANGELOG using `conventional-changelog-cli` (`npm` must be installed and visible in `PATH`).
	"""

if CommandLine.argc < 2 {
	print(help)
} else {
	switch CommandLine.arguments[1] {
		case "gen-man":
			print(try Process.execute("pandoc", args: "--standalone", "--to", "man", "LFSPointers.1.md", "-o", "LFSPointers.1").stdout ?? "")
		case "gen-changelog":
			print("Make sure NPM is installed.")
			print("Installing conventional-changelog-cli...")
			print(try Process.execute("npm", args: "install", "-g", "conventional-changelog-cli").stdout ?? "")
			print("Generating CHANGELOG...")
			let changelog = try Process.execute("conventional-changelog", args: "-p jscs", "-r", "0", "-u").stdout!
			try changelog.data(using: .utf8)!.write(to: URL(fileURLWithPath: "CHANGELOG.md"))
			print("Generated CHANGELOG.")
		case "build":
			print("Building...")
			print(try Process.execute("swift", args: "build", "-c", "release").stderr ?? "")
			print("Built LFSPointers.")
		case "--help", "-h", "-?":
			print(help)
		default:
			print("Unknown argument: \(CommandLine.arguments[1])")
	}
}
