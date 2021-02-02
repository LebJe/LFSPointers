import Files
@testable import LFSPointersKit
import XCTest

final class LFSPointersTests: XCTestCase {
	let resources = try! Folder.temporary.createSubfolder(named: "Resources")

	override func setUpWithError() throws {
		let recursive = try resources.createSubfolderIfNeeded(withName: "recursive")
		_ = try? self.resources.createFileIfNeeded(at: "foo.txt", contents: "Foo".data(using: .utf8))
		_ = try? recursive.createFileIfNeeded(at: "bar.txt", contents: "BarBar".data(using: .utf8))
	}

	func testConvertFileToPointer() throws {
		let pointer = try LFSPointer(fromFile: resources.file(named: "foo.txt").url)
		XCTAssertEqual(3, pointer.size)
		XCTAssertEqual("1cbec737f863e4922cee63cc2ebbfaafcd1cff8b790d8cfd2e6a5d550b648afa", pointer.oid)
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

		// Get a list of pointers.
		let pointers = try LFSPointer.pointers(forDirectory: self.resources.url, searchType: .regex(try NSRegularExpression(pattern: "^*$")), recursive: true)

		// Make sure there are two pointers ("foo.txt" and "recursive/bar.txt").
		XCTAssertEqual(2, pointers.count)

		// Try writing the pointer to "foo.txt".
		try pointers[0].write(toFile: fooFile.url, shouldAppend: false)

		// Try writing the pointer to "recursive/bar.txt".
		try pointers[1].write(toFile: barFile.url, shouldAppend: false)

		// Restore the contents of "foo.txt".
		try foo.write(to: fooFile.url, atomically: false, encoding: .utf8)

		// Restore the contents of "recursive/bar.txt".
		try bar.write(to: barFile.url, atomically: false, encoding: .utf8)
	}

	// MARK: - Test search types.

	func testSearchTypeAll() throws {
		// Get a list of pointers.
		let pointers = try LFSPointer.pointers(forDirectory: self.resources.url, searchType: .all, recursive: true)

		// Make sure there are two pointers.
		XCTAssertEqual(pointers.count, 2)
	}

	func testSearchTypeRegex() throws {
		let regex = try NSRegularExpression(pattern: "^*.txt$")

		// Get a list of pointers.
		let pointers = try LFSPointer.pointers(forDirectory: self.resources.url, searchType: .regex(regex), recursive: true)

		// Make sure there are two pointers.
		XCTAssertEqual(pointers.count, 2)
	}

	func testSearchTypeFilenames() throws {
		let filenames = [try! self.resources.file(at: "recursive/bar.txt")]

		// Get a list of pointers.
		let pointers = try LFSPointer.pointers(forDirectory: self.resources.url, searchType: .fileNames(filenames.map(\.url)), recursive: true)

		// Make sure there are two pointers.
		XCTAssertEqual(pointers.count, 1)

		XCTAssertEqual(pointers[0].filename, filenames[0].name)
	}

	func testLFSPointerIsEquatable() throws {
		let p1 = try LFSPointer(fromFile: resources.file(named: "foo.txt").url)
		let p2 = try LFSPointer(fromFile: resources.file(named: "foo.txt").url)

		// Make sure these are equal.
		XCTAssertEqual(p1, p2)
	}

	static var allTests = [
		("Test converting a file to pointer", testConvertFileToPointer),
		("Test recursively generating pointers for files in subdirectories and overwrite those files with their original contents", testRecursivelyGeneratePointersForFilesInSubdirectories),
		("Test searching for all files", testSearchTypeAll),
		("Test searching for a file whose name matches a regular expression", testSearchTypeRegex),
		("Test searching for a file with a specified filename", testSearchTypeFilenames),
		("Test LFSPointer is Equatable", testLFSPointerIsEquatable),
	]
}
