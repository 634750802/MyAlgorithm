//
// Created by 高林杰 on 2020/5/28.
//

public protocol Queue {
  associatedtype Element

  mutating func enqueue(_ element: Element)
  mutating func dequeue() -> Element?
  var isEmpty: Bool { get }
  var count: Int { get }
}


public protocol BatchEnqueuedQueue: Queue {
  associatedtype S: Collection where S.Element == Self.Element

  mutating func enqueue(_ elements: S)
}

