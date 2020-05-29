import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    [
        testCase(QueueTest.allTests),
        testCase(LinkTest.allTests),
        testCase(HeapTest.allTests)
    ]
}
#endif
