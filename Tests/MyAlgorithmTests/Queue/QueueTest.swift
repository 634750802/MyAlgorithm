//
// Created by 高林杰 on 2020/5/28.
//


import XCTest
@testable import MyAlgorithm

final class QueueTest: XCTestCase {

  private func makeData() -> DiscontinuousQueue<Int, ArraySlice<Int>> {
    var queue = DiscontinuousQueue(type: ArraySlice<Int>.self)
    XCTAssertTrue(queue._debugIsLinkNodesGood, "\(queue) is not good")
    queue.enqueue(1)
    XCTAssertEqual(queue._debugBlockCounts, 1)
    XCTAssertEqual(queue.count, 1)
    XCTAssertFalse(queue.isEmpty)

    queue.enqueue([1, 2, 3, 4])
    XCTAssertEqual(queue._debugBlockCounts, 2)
    XCTAssertEqual(queue.count, 5)

    queue.enqueue([1, 2, 3, 4, 5])
    XCTAssertEqual(queue._debugBlockCounts, 3)
    XCTAssertEqual(queue.count, 10)
    XCTAssertTrue(queue._debugIsLinkNodesGood, "\(queue) is not good")
    return queue
  }

  func testInit() {
    let queue = DiscontinuousQueue(type: ArraySlice<Int>.self)
    XCTAssertEqual(queue.count, 0)
    XCTAssertTrue(queue.isEmpty)
    XCTAssertTrue(queue._debugIsLinkNodesGood, "\(queue) is not good")
  }

  func testEnqueue() {
    _ = makeData()
  }

  func testDequeue() {
    var queue = makeData()

    var i = 10
    while let _ = queue.dequeue() {
      i -= 1
      XCTAssertEqual(queue.count, i)
      if i > 0 {
        XCTAssertFalse(queue.isEmpty)
      } else {
        XCTAssertTrue(queue.isEmpty)
      }
    }

    XCTAssertEqual(queue._debugBlockCounts, 0)
    XCTAssertTrue(queue.isEmpty)
    XCTAssertTrue(queue._debugIsLinkNodesGood, "\(queue) is not good")
  }

  func testCopyOnWrite() {
    var queue = makeData()
    let queue2 = queue
    queue.enqueue(1)
    XCTAssertNotEqual(queue.count, queue2.count)
    XCTAssertTrue(queue._debugIsLinkNodesGood, "\(queue) is not good")
    XCTAssertEqual(queue._debugLinkCopyTimes, 1)
    XCTAssertEqual(queue2._debugLinkCopyTimes, 1)
  }

  static var allTests = [
    ("testInit", testInit),
    ("testEnqueue", testEnqueue),
    ("testDequeue", testDequeue),
    ("testCopyOnWrite", testCopyOnWrite)
  ]

}
