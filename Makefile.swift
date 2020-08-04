// beak: JohnSundell/ShellOut @ 2.0.0
// beak: onevcat/Rainbow @ 3.1.5
// beak: JohnSundell/Files @ 4.1.1
// beak: Alamofire/Alamofire @ 5.0.0
// beak: sharplet/Regex @ 2.1.1

import ShellOut
import Rainbow
import Files
import Alamofire
import Regex
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

public func updateMainDotSwift(usingVersion version: String) {
	// MARK: - Update tag in main.swift.
	print("\nUpdating tag in main.swift...".green)
	
	var file = ""
	let mainDotSwift: File!
	
	do {
		mainDotSwift = try cwd.subfolder(at: "Sources/LFSPointersExecutable/").file(named: "main.swift")
	} catch {
		print(#"Unable to find "main.swift""#.red)
		exit(4)
	}
	
	file = try! mainDotSwift.readAsString().replacingFirst(matching: Regex(#"version: "\d+\.\d+\.\d+"\)"#, options: [.ignoreCase]), with: #"version: "\#(version)")"#)
	
	try! mainDotSwift.write(file)
	
}

public func updateHomebrewFormulae(usingVersion version: String) {
	// MARK: - Update tag in homebrew-formulae/lfs-pointers.rb.
	var file = ""
	
	let hbfURL = "git@github.com:LebJe/homebrew-formulae.git"
	
	print("Creating temporary directory for \(hbfURL)...".green)
	
	// Create temporary directory.
	guard let homebrewFormulae = try? cwd.createSubfolder(named: "\(Int.random(in: 1000...100000000))") else {
		fputs("Unable to create subdirectory for homebrew-formulae.".red, stderr)
		exit(5)
	}
	
	// Clone the repository.
	
	print("Cloning \(hbfURL)...".green)
	
	do {
		try shellOut(to: "git", arguments: ["clone", hbfURL, homebrewFormulae.name])
	} catch let error {
		fputs("Unable to clone \(hbfURL). Error: ".red + error.localizedDescription, stderr)
		exit(6)
	}
	
	// Get the file called "lfs-pointers.rb".
	guard let lfspointers = try? homebrewFormulae.file(named: "lfs-pointers.rb") else {
		fputs(#"Unable to find "lfs-pointers.rb" in "\#(homebrewFormulae.name)""#.red, stderr)
		exit(7)
	}
	
	print("Replacing old version with new version in file \"lfs-pointers.rb\"".green)
	
	// Replace the version in that file with the new version.
	file = try! lfspointers.readAsString().replacingFirst(matching: Regex(#":tag => "\d+\.\d+\.\d+""#), with: #":tag => "\#(version)""#)
	
	try! lfspointers.write(file)
	
	// git add . && git commit -m "Update tag." && git push origin master.
	try! shellOut(to: "git", arguments: ["add", "."], at: homebrewFormulae.path)
	
	try! shellOut(to: "git", arguments: ["commit", "-m", #""Update tag.""#], at: homebrewFormulae.path)
	
	try! shellOut(to: "git", arguments: ["push", "origin", "master"], at: homebrewFormulae.path)
	
	do {
	try homebrewFormulae.delete()
	} catch {
		fputs(#"Unable to delete "\#(homebrewFormulae.name)". Please delete it yourself."#, stderr)
		exit(8)
	}
}

public func updateReadme(usingVersion version: String) {
	guard let readme = try? cwd.file(named: "README.md") else {
		fputs("Unable to find README.md".red, stderr)
		exit(10)
	}
	
	print("Updating README.md...".green)
	
	try! readme.write(readme.readAsString().replacingFirst(matching: Regex(#"\.upToNextMinor\(from: "\d+\.\d+\.\d+"\)"#), with: #"\.upToNextMinor\(from: "\#(version)"\)"#))
	
}

/// Releases a new version of this project.
///
/// This will update [homebrew-formulae/lfs-pointers.rb](https://github.com/LebJe/homebrew-formulae/blob/master/lfs-pointers.rb#L5), the [README](https://github.com/LebJe/LFSPointers/blob/master/README.md), [main.swift](https://github.com/LebJe/LFSPointers/blob/master/Sources/LFSPointersExecutable/main.swift#L34), and the current Git tag for this repository
///
/// - Parameter version: The version you wish to release.
public func release(version: String) {
	
	updateMainDotSwift(usingVersion: version)
	
	// MARK: - Update tag in homebrew-formulae/lfs-pointers.rb.
	updateHomebrewFormulae(usingVersion: version)
	
	// MARK: - Update README.
	updateReadme(usingVersion: version)
	
	// MARK: - Add, commit, tag, push.
	print("Provide a commit message for these modified files: ".green + "\n\(try! shellOut(to: "git", arguments: ["status"])) ".blue, terminator: "")
	
	let message = readLine(strippingNewline: false) ?? "Updated tag."
	
	print("git add .".blue)
	print(try! shellOut(to: "git", arguments: ["add", "."]).blue)
	
	print("git commit -m \"\(message)\"\n".blue)
	print(try! shellOut(to: "git", arguments: ["commit", "-m", "\(message)"]).blue)
	
	// Tag latest commit.
	print("Tagging latest commit...".green)
	
	print("git tag \(version)".blue)
	
	let errorHandle = FileHandle()
	
	let value = try? shellOut(to: "git", arguments: ["tag", version], errorHandle: errorHandle)
	
	if value == nil {
		let errorMessage = String(data: errorHandle.availableData, encoding: .utf8) ?? "Unable to retrieve error".red
		
		print("Previous command failed: ".red + errorMessage)
		exit(3)
	}
	
	print(value!.blue)
	
	print("Would you like to push these changes to \"origin\", on the master branch? (y/n/yes/no) ".green, terminator: "")
	let answer = readLine()?.lowercased()
	
	switch answer {
		case "yes", "y":
			do {
				print(try shellOut(to: "git", arguments: ["push", "origin", "master", "--tags"]).blue + "\n")
			} catch let error {
				exit(9)
			}
		default:
			print("version \(version) was " + "\"\("git tag".blue)ged\"" + "and all files were updated!".green)
			
	}
	
}
