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

        let lp = productsDirectory.appendingPathComponent("LFSPointers")

		let pointer = try LFSPointer.pointer(forFile: Folder.current.subfolder(named: "Resources").file(named: "foo.txt").path)
		
		XCTAssertEqual(915616, pointer.size)
		XCTAssertEqual("7460be75572755e82af8be291eb5113bcfe4a5e929578f1a4690c8b364f83207", pointer.oid)
		
		
    }
	
	func testRecursivelyGeneratePointersForFilesInSubdirectoriesAndOverwriteSaidFiles() throws {
		// Resources directory.
		let resources = try Folder.current.subfolder(named: "Resources")
		
		// Get the text from "foo.txt" and "recursive/bar.txt".
		let foo = try resources.file(named: "foo.txt").readAsString()
		let bar = try resources.subfolder(named: "recursive").file(named: "bar.txt").readAsString()
		
		XCTAssertNoThrow(try LFSPointer.pointers(forDirectory: resources.path, searchType: .regex(try NSRegularExpression(pattern: "^*$")), recursive: true))
		
		let pointers = try LFSPointer.pointers(forDirectory: resources.path, searchType: .regex(try NSRegularExpression(pattern: "^*$")), recursive: true)
		
		// Make sure there are two pointers ("foo.txt" and "recursive/bar.txt").
		XCTAssertEqual(2, pointers.count)
		
		// Try writing the pointer to "foo.txt".
		XCTAssertNoThrow(try pointers[0].pointer.write(toFile: resources.file(named: "foo.txt").path, shouldAppend: false, printOutput: true, printVerboseOutput: true))
		
		// Restore the contents of "foo.txt".
		XCTAssertNoThrow(try foo.write(to: URL(fileURLWithPath: resources.file(named: "foo.txt").path), atomically: false, encoding: .utf8))
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
        ("testConvertFileToPointer", testConvertFileToPointer),
    ]
}
