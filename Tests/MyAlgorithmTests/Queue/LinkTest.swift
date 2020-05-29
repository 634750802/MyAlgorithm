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
    link.insert(2, at: link.startIndex)
    link.insert(5, at: link.startIndex)
    link.insert(7, at: link.startIndex)
    link.append(-1)
    link.append(-9)
    link.append(-6)
    link.append(-4)
    link.append(-19)
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

  func testRemove() {
    var link = makeData(10)
    for i in 0..<10 {
      XCTAssertEqual(link.removeFirst(), i)
      XCTAssertEqual(link.count, 9 - i)
      XCTAssertTrue(link._debugIsGood)
    }

    link = makeData(10)
    for i in 0..<10 {
      XCTAssertEqual(link.remove(at: link.index(link.startIndex, offsetBy: link.count - 1)), 9 - i)
      XCTAssertEqual(link.count, 9 - i)
      XCTAssertTrue(link._debugIsGood)
    }

    link = makeData(10)
    let link2 = link
    for i in 0..<10 {
      XCTAssertEqual(link.remove(at: link.index(link.startIndex, offsetBy: link.count - 1)), 9 - i)
      XCTAssertEqual(link.count, 9 - i)
      XCTAssertTrue(link._debugIsGood)
    }
    XCTAssertEqual(getCopyTimes(link2.copyTimesHolder), 1)
    XCTAssertNotEqual(link, link2)
  }

  func testReplace() {
    var link: Link<Int>

    link = makeData(10)
    link.replaceSubrange(link.index(link.startIndex, offsetBy: 0)..<link.index(link.startIndex, offsetBy: 2), with: [10, 10, 10])
    XCTAssertEqual(link, Link([10, 10, 10, 2, 3, 4, 5, 6, 7, 8, 9]))

    link = makeData(10)
    link.replaceSubrange(link.index(link.startIndex, offsetBy: 1)..<link.index(link.startIndex, offsetBy: 2), with: [10, 10, 10])
    XCTAssertEqual(link, Link([0, 10, 10, 10, 2, 3, 4, 5, 6, 7, 8, 9]))

    link = makeData(10)
    link.replaceSubrange(link.index(link.startIndex, offsetBy: 2)..<link.index(link.startIndex, offsetBy: 2), with: [10, 10, 10])
    XCTAssertEqual(link, Link([0, 1, 10, 10, 10, 2, 3, 4, 5, 6, 7, 8, 9]))

    link = makeData(10)
    link.replaceSubrange(link.index(link.startIndex, offsetBy: 0)..<link.endIndex, with: [10, 10, 10])
    XCTAssertEqual(link, Link([10, 10, 10]))

    link = makeData(10)
    link.replaceSubrange(link.index(link.startIndex, offsetBy: 1)..<link.endIndex, with: [10, 10, 10])
    XCTAssertEqual(link, Link([0, 10, 10, 10]))

    link = makeData(10)
    link.replaceSubrange(link.index(link.startIndex, offsetBy: 2)..<link.endIndex, with: [10, 10, 10])
    XCTAssertEqual(link, Link([0, 1, 10, 10, 10]))
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

  func testCollection() {
    let data = makeUnsortedData()

    var index = data.startIndex
    var it = data.makeIterator()
    while index != data.endIndex, let element = it.next() {
      XCTAssertEqual(element, data[index])
      index = data.index(after: index)
    }
    XCTAssertEqual(index, data.endIndex)
    XCTAssertEqual(it.next(), nil)
  }

  func testSubRange() {
    XCTAssertEqual(Link(makeData(10).prefix(4)), Link([0, 1, 2, 3]))
    XCTAssertEqual(Link(makeData(10).suffix(2)), Link([8, 9]))
    XCTAssertEqual(Link(makeData(10).prefix(4).suffix(2)), Link([2, 3]))
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
    "testRemove": testRemove,
    "testReplace": testReplace,
    "testSort": testSort,
    "testMutable": testMutable,
    "testEquatable": testEquatable,
    "testCollection": testCollection,
    "testCopyOnWrite": testCopyOnWrite
  ]
}

