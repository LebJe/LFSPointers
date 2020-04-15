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
		
		let fm = FileManager()

        let lp = productsDirectory.appendingPathComponent("LFSPointers")
		
		let pointer = try LFSPointer.pointer(forFile: Folder.current.subfolder(named: "Resources").file(named: "text.txt").path)
		
		XCTAssertEqual(915616, pointer.size)
		
		let r = SwiftShell.run(lp.absoluteString, "--help")
		
		XCTAssertEqual(r.stdout, r.stdout)
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
