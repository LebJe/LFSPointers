import XCTest
import SwiftShell
import Files
import class Foundation.Bundle

final class LFSPointersTests: XCTestCase {
    func testExample() throws {

        // Some of the APIs that we use below are available in macOS 10.13 and above.
        guard #available(macOS 10.13, *) else {
            return
        }
		
		let fm = FileManager()

        let lp = productsDirectory.appendingPathComponent("LFSPointers")
		
		try Folder(path: fm.currentDirectoryPath + "/Resources").files.recursive.forEach({ file in
			
			let r = SwiftShell.run("git", "lfs", "pointer", "--file=\(file.path)")
			
			let components = r.stdout.components(separatedBy: "\n")
			
			guard components.count >= 3 else { return }
			
			struct LFSPointer {
				let version: String
				let oid: String
				let size: Int
			}
			
			let pointer = LFSPointer(version: components[0].replacingOccurrences(of: "version ", with: ""), oid: components[1].replacingOccurrences(of: "oid sha256:", with: ""), size: Int(components[2].replacingOccurrences(of: "size ", with: "") ?? "0") ?? 0)
			
			print("\n\n\n\(pointer)\n\n\n")
			
		})
		
		
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
        ("testExample", testExample),
    ]
}
