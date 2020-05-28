//
// Created by 高林杰 on 2020/5/28.
//

import XCTest
@testable import MyAlgorithm

final class LinkTest: XCTestCase {

  private func makeData(_ n: Int) -> Link<Int> {
    var link = Link<Int>()
    for i in 0..<n {
      link.append(i)
    }
    XCTAssertTrue(link._debugIsGood)
    return link
  }

  func testInit() {
    let link = Link<Int>()
    XCTAssertEqual(link.count, 0)
    XCTAssertTrue(link.isEmpty)
    XCTAssertNil(link.first)
    XCTAssertNil(link.head)
    XCTAssertNil(link.tail)
    XCTAssertEqual(link.startIndex, link.endIndex)
  }

  func testInsert() {
    let link = makeData(10)
    XCTAssertEqual(link.count, 10)
    XCTAssertEqual(link.map { $0 }, Array(stride(from: 0, to: 10, by: 1)))
    XCTAssertEqual(link.first, 0)
    XCTAssertEqual(link[link.startIndex], 0)
    XCTAssertEqual(link[link.index(after: link.startIndex)], 1)
    XCTAssertEqual(link[link.index(link.startIndex, offsetBy: 9)], 9)
    XCTAssertEqual(link.index(link.startIndex, offsetBy: 10), link.endIndex)
  }

  func testCopyOnWrite() {
    var link = makeData(10)
    XCTAssertEqual(link._debugCopyTimes, 0)
    link.ensureCopyOnWrite()
    XCTAssertEqual(link._debugCopyTimes, 0)

    var other = link
    XCTAssertEqual(link._debugCopyTimes, 0)
    XCTAssertEqual(other._debugCopyTimes, 0)
    link.ensureCopyOnWrite()
    XCTAssertEqual(link._debugCopyTimes, 1)
    XCTAssertEqual(other._debugCopyTimes, 1)
    link.ensureCopyOnWrite()
    other.ensureCopyOnWrite()
    XCTAssertEqual(link._debugCopyTimes, 1)
    XCTAssertEqual(other._debugCopyTimes, 1)
  }

  static var allTests = [
    "testInit": testInit,
    "testInsert": testInsert
  ]
}

