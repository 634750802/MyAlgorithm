import XCTest

import MyAlgorithmTests

var tests = [XCTestCaseEntry]()
tests += QueueTest.allTests()
tests += LinkTest.allTests()
tests += HeapTest.allTests()
XCTMain(tests)
