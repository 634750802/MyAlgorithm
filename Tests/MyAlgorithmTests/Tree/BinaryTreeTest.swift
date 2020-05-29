//
// Created by 高林杰 on 2020/5/29.
//

import XCTest
@testable import MyAlgorithm

final class BinaryTreeTest: XCTestCase {
  func testInit() {
    _ = BinaryTree<Int>()
  }

  func testInsert() {
    var tree = BinaryTree<Int>()
    tree.root = .init(1)
    XCTAssertEqual(tree.root.value, 1)
  }

  func testPaths() {
    var tree = BinaryTree<Int>()
    tree.root = .init(1)
    tree.root.left.value = 2
    tree.root.left.left.value = 3
    tree.root.left.right.value = 4

    XCTAssertEqual(tree.immutableRoot.value, 1)
    XCTAssertEqual(tree.immutableRoot.left.value, 2)
    XCTAssertEqual(tree.immutableRoot.left.left.value, 3)
    XCTAssertEqual(tree.immutableRoot.left.right.value, 4)
    var arr: [Int] = []
    tree.traversal(order: .pre) { arr.append($0) }
    XCTAssertEqual(arr, [1, 2, 3, 4])
  }

  func testTraversal() {
    var tree = BinaryTree<Int>()
    tree.root = .init(1)
    tree.root.left.value = 2
    tree.root.left.left.value = 3
    tree.root.left.right.value = 4

    var arr: [Int] = []
    tree.traversal(order: .pre) { arr.append($0) }
    XCTAssertEqual(arr, [1, 2, 3, 4])

    arr = []
    tree.traversal(order: .in) { arr.append($0) }
    XCTAssertEqual(arr, [3, 2, 4, 1])

    arr = []
    tree.traversal(order: .post) { arr.append($0) }
    XCTAssertEqual(arr, [3, 4, 2, 1])
  }

  static var allTests = [
    "testInit": testInit,
    "testPaths": testPaths,
    "testTraversal": testTraversal
  ]
}