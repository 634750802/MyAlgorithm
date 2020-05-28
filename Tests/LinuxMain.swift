import XCTest

import MyAlgorithmTests

var tests = [XCTestCaseEntry]()
tests += QueueTests.allTests()
tests += LinkTests.allTests()
XCTMain(tests)
