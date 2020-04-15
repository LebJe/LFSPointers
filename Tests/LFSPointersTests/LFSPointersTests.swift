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
	
	func testRecursivelyGeneratePointersForFilesInSubdirectories() throws {
		XCTAssertNoThrow(try LFSPointer.pointers(forDirectory: Folder.current.subfolder(named: "Resources").path, regex: NSRegularExpression(pattern: "^*$"), recursive: true))
		
		let pointers = try LFSPointer.pointers(forDirectory: Folder.current.subfolder(named: "Resources").path, regex: NSRegularExpression(pattern: "^*$"), recursive: true)
		
		print("\n\n\(pointers[0].pointer)\n\n")
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
