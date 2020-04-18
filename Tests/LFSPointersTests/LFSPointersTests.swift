import XCTest
import SwiftShell
import Files
@testable import LFSPointersLibrary
import class Foundation.Bundle

final class LFSPointersTests: XCTestCase {
    func testConvertFileToPointer() throws {

        // Some of the APIs that we use below are available in macOS 10.13 and above.
        guard #available(macOS 10.13, *) else {
            return
		}

		let pointer = try LFSPointer.pointer(forFile: Folder.current.subfolder(named: "Resources").file(named: "foo.txt").path)
		
		XCTAssertEqual(915616, pointer.size)
		XCTAssertEqual("7460be75572755e82af8be291eb5113bcfe4a5e929578f1a4690c8b364f83207", pointer.oid)
		
    }
	
	func testRecursivelyGeneratePointersForFilesInSubdirectoriesAndOverwriteSaidFilesWithOriginalContents() throws {
		// Resources directory.
		let resources = try Folder.current.subfolder(named: "Resources")
		
		// "Resources/recursive" directory.
		let recursive = try resources.subfolder(named: "recursive")
		
		// "Resources/foo.txt"
		let fooFile = try resources.file(named: "foo.txt")
		
		// "Resources/recursive/bar.txt"
		let barFile = try recursive.file(named: "bar.txt")
		
		// Get the text from "foo.txt" and "recursive/bar.txt".
		let foo = try fooFile.readAsString()
		let bar = try barFile.readAsString()
		
		XCTAssertNoThrow(try LFSPointer.pointers(forDirectory: resources.path, searchType: .all, recursive: true))
		
		// Get a list of pointers.
		let pointers = try LFSPointer.pointers(forDirectory: resources.path, searchType: .regex(try NSRegularExpression(pattern: "^*$")), recursive: true)
		
		// Make sure there are two pointers ("foo.txt" and "recursive/bar.txt").
		XCTAssertEqual(2, pointers.count)
		
		// Try writing the pointer to "foo.txt".
		XCTAssertNoThrow(try pointers[0].pointer.write(toFile: fooFile.path, shouldAppend: false, printOutput: true, printVerboseOutput: true))
		
		// Try writing the pointer to "recursive/bar.txt".
		XCTAssertNoThrow(try pointers[1].pointer.write(toFile: barFile.path, shouldAppend: false, printOutput: true, printVerboseOutput: true))
		
		// Restore the contents of "foo.txt".
		XCTAssertNoThrow(try foo.write(to: URL(fileURLWithPath: fooFile.path), atomically: false, encoding: .utf8))
		
		// Restore the contents of "recursive/bar.txt".
		XCTAssertNoThrow(try bar.write(to: URL(fileURLWithPath: barFile.path), atomically: false, encoding: .utf8))
	}

    /// Returns path to the built products directory.
    var productsDirectory: URL {
      #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
      #else
        return Bundle.main.bundleURL
      #endif
    }

    static var allTests = [
        ("Test converting a file to pointer", testConvertFileToPointer),
		("Test recursively generating pointers for files in subdirectories and overwrite those files with their original contents", testRecursivelyGeneratePointersForFilesInSubdirectoriesAndOverwriteSaidFilesWithOriginalContents)
    ]
}
