import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(HTMLKit_Vapor_ProviderTests.allTests),
    ]
}
#endif
