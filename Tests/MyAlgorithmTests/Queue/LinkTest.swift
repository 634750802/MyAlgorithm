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

  private func makeUnsortedData() -> Link<Int> {
    var link = Link<Int>()
    link.append(1)
    link.append(3)
    link.append(8)
    link.append(9)
    link.append(2)
    link.append(5)
    link.append(7)
    link.append(-1)
    link.append(-9)
    link.append(-6)
    link.append(-4)
    link.append(-19)
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

  func testSort() {
    var link = makeUnsortedData()
    let index = link.partition { $0 > 5 }

    XCTAssertTrue(link[link.startIndex..<index].allSatisfy { $0 <= 5 })
    XCTAssertTrue(link[index...].allSatisfy { $0 > 5 })
  }

  func testMutable() {
    var linkA = makeData(10)
    linkA[linkA.startIndex] = 4
    XCTAssertEqual(linkA.first, 4)

    let linkB = linkA
    XCTAssertEqual(linkB.first, 4)
    linkA[linkA.index(after: linkA.startIndex)] = 5
    XCTAssertEqual(linkA.head?.next?.value, 5)
    XCTAssertEqual(linkB.head?.next?.value, 1)

    let linkC = linkA
    XCTAssertEqual(linkA.dropFirst().first, 5)
    XCTAssertEqual(linkC.first, 4)
  }

  func testEquatable() {
    XCTAssertEqual(makeUnsortedData(), makeUnsortedData())
    XCTAssertEqual(Link<Int>(), Link<Int>())
    XCTAssertNotEqual(Link<Int>(), makeData(1))
    XCTAssertNotEqual(makeData(2), makeData(1))
    XCTAssertNotEqual(makeData(12), makeUnsortedData())
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
    "testInsert": testInsert,
    "testMutable": testMutable,
    "testCopyOnWrite": testCopyOnWrite
  ]
}

