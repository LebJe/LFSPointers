import XCTest

#if !canImport(ObjectiveC)
	public func allTests() -> [XCTestCaseEntry] {
		[
			testCase(LFSPointersTests.allTests),
		]
	}
#endif
