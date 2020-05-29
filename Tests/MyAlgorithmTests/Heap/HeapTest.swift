//
// Created by 高林杰 on 2020/5/29.
//

import XCTest
@testable import MyAlgorithm

final class HeapTest: XCTestCase {

  func testInit() {
    _ = Heap<Int>()
  }

  func testPush() {
    var heap = Heap<Int>()
    for i in 0 ..< 10 {
      heap.push(i)
    }
    XCTAssertEqual(heap.count, 10)
    XCTAssertFalse(heap.isEmpty)
    XCTAssertEqual(heap.first, 0)

    heap = Heap()
    for i in 0 ..< 10 {
      heap.push(9 - i)
    }
    XCTAssertEqual(heap.first, 0)

    heap = Heap(comparator: >)
    for i in 0 ..< 10 {
      heap.push(i)
    }
    XCTAssertEqual(heap.first, 9)

    heap = Heap(comparator: >)
    for i in 0 ..< 10 {
      heap.push(9 - i)
    }
    XCTAssertEqual(heap.first, 9)
  }


  func testPop() {
    var heap = Heap<Int>()
    for i in 0 ..< 10 {
      heap.push(i)
    }
    XCTAssertEqual(heap.count, 10)
    XCTAssertFalse(heap.isEmpty)
    XCTAssertEqual(heap.first, 0)
    _ = heap.pop()
    XCTAssertEqual(heap.first, 1)

    heap = Heap()
    for i in 0 ..< 10 {
      heap.push(9 - i)
    }
    XCTAssertEqual(heap.first, 0)
    _ = heap.pop()
    XCTAssertEqual(heap.first, 1)

    heap = Heap(comparator: >)
    for i in 0 ..< 10 {
      heap.push(i)
    }
    XCTAssertEqual(heap.first, 9)
    _ = heap.pop()
    XCTAssertEqual(heap.first, 8)

    heap = Heap(comparator: >)
    for i in 0 ..< 10 {
      heap.push(9 - i)
    }
    XCTAssertEqual(heap.first, 9)
    _ = heap.pop()
    XCTAssertEqual(heap.first, 8)
  }


  static var allTests = [
    "testInit": testInit,
    "testPush": testPush
  ]
}