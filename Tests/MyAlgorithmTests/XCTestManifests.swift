import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(QueueTest.allTests),
        testCase(LinkTest.allTests)
    ]
}
#endif
