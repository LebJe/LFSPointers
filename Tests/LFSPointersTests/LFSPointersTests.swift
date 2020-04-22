import XCTest
import SwiftShell
import Files
@testable import LFSPointersLibrary
import class Foundation.Bundle

final class LFSPointersTests: XCTestCase {
	let resources = try! Folder.current.subfolder(named: "Resources")
	
	func testConvertFileToPointer() throws {
		let pointer = try LFSPointer.pointer(forFile: resources.file(named: "foo.txt").url)
		
		XCTAssertEqual(915616, pointer.size)
		XCTAssertEqual("7460be75572755e82af8be291eb5113bcfe4a5e929578f1a4690c8b364f83207", pointer.oid)
    }
	
	func testRecursivelyGeneratePointersForFilesInSubdirectories() throws {
		// "Resources/recursive" directory.
		let recursive = try resources.subfolder(named: "recursive")
		
		// "Resources/foo.txt"
		let fooFile = try resources.file(named: "foo.txt")
		
		// "Resources/recursive/bar.txt"
		let barFile = try recursive.file(named: "bar.txt")
		
		// Get the text from "foo.txt" and "recursive/bar.txt".
		let foo = try fooFile.readAsString()
		let bar = try barFile.readAsString()
		
		XCTAssertNoThrow(try LFSPointer.pointers(forDirectory: resources.url, searchType: .all, recursive: true))
		
		// Get a list of pointers.
		let pointers = try LFSPointer.pointers(forDirectory: resources.url, searchType: .regex(try NSRegularExpression(pattern: "^*$")), recursive: true)
		
		// Make sure there are two pointers ("foo.txt" and "recursive/bar.txt").
		XCTAssertEqual(2, pointers.count)
		
		// Try writing the pointer to "foo.txt".
		XCTAssertNoThrow(try pointers[0].pointer.write(toFile: fooFile.url, shouldAppend: false))
		
		// Try writing the pointer to "recursive/bar.txt".
		XCTAssertNoThrow(try pointers[1].pointer.write(toFile: barFile.url, shouldAppend: false))
		
		// Restore the contents of "foo.txt".
		XCTAssertNoThrow(try foo.write(to: fooFile.url, atomically: false, encoding: .utf8))
		
		// Restore the contents of "recursive/bar.txt".
		XCTAssertNoThrow(try bar.write(to: barFile.url, atomically: false, encoding: .utf8))
	}
	
	// MARK: - Test search types.
	func testSearchTypeAll() throws {
		
		// Make sure LFSPointer.pointers(...) doesn't throw.
		XCTAssertNoThrow(try LFSPointer.pointers(forDirectory: resources.url, searchType: .all, recursive: true))
		
		// Get a list of pointers.
		let pointers = try LFSPointer.pointers(forDirectory: resources.url, searchType: .all, recursive: true)
		
		// Make sure there are two pointers.
		XCTAssertEqual(pointers.count, 2)
	}
	
	func testSearchTypeRegex() throws {
		let regex = try NSRegularExpression(pattern: "^*.txt$")
		
		// Make sure LFSPointer.pointers(...) doesn't throw.
		XCTAssertNoThrow(try LFSPointer.pointers(forDirectory: resources.url, searchType: .regex(regex), recursive: true))
		
		// Get a list of pointers.
		let pointers = try LFSPointer.pointers(forDirectory: resources.url, searchType: .regex(regex), recursive: true)
		
		// Make sure there are two pointers.
		XCTAssertEqual(pointers.count, 2)
	}
	
	func testSearchTypeFilenames() throws {
		let filenames = ["bar.txt"]
		
		// Make sure LFSPointer.pointers(...) doesn't throw.
		XCTAssertNoThrow(try LFSPointer.pointers(forDirectory: resources.url, searchType: .fileNames(filenames), recursive: true))
		
		// Get a list of pointers.
		let pointers = try LFSPointer.pointers(forDirectory: resources.url, searchType: .fileNames(filenames), recursive: true)
		
		// Make sure there are two pointers.
		XCTAssertEqual(pointers.count, 1)
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
		("Test recursively generating pointers for files in subdirectories and overwrite those files with their original contents", testRecursivelyGeneratePointersForFilesInSubdirectories),
		("Test searching for all files", testSearchTypeAll),
		("Test searching for a file whose name matches a regular expression", testSearchTypeRegex),
		("Test searching for a file with a specified filename", testSearchTypeFilenames)
    ]
}
