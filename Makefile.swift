// beak: JohnSundell/ShellOut @ 2.0.0
// beak: onevcat/Rainbow @ 3.1.5
// beak: JohnSundell/Files @ 4.1.1

import ShellOut
import Rainbow
import Files
import Foundation

let cwd = Folder.current

func checkForSwift() -> String {
	
	let result = try? shellOut(to: "which", arguments: ["swift"])
	guard result != nil else {
		fputs("Please install Swift before continuing".red, stderr)
		exit(2)
	}
	
	return result!
}

/// Installs this program.
public func install() {
	do {
		let path = checkForSwift()
		
		print("Building...")
		
		let handle = FileHandle()
		
		let result = try? shellOut(to: path, arguments: ["build", "-c release"], errorHandle: handle)
		
		if result != nil {
			print(result!.blue)
		} else {
			fputs("Unable to build project. Error: \(String(data: handle.availableData, encoding: .utf8)!)".red, stderr)
			exit(1)
		}
		
		print("installing...")
		
		try shellOut(to: "mv", arguments: [".build/release/LFSPointers", "/usr/local/bin/"])
	} catch let error {
		print("There was an error: \(error)")
	}
}
