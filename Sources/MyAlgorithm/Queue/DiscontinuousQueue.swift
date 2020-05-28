//
// Created by 高林杰 on 2020/5/28.
//

public struct DiscontinuousQueue<Element, S: Collection>: BatchEnqueuedQueue where S.Element == Element {

  private var link = Link<Node>()

  public init(type: S.Type = S.self) {
  }

  mutating public func enqueue(_ element: Element) {
    fatalError("Unsupported operation. Support it by provided your own extension for \(S.self).")
  }

  mutating public func enqueue(_ elements: S) {
    link.ensureCopyOnWrite()
    link.append(.init(elements))
  }

  mutating public func dequeue() -> Element? {
    link.ensureCopyOnWrite()
    if let headNode = link.first {
      defer {
        headNode.currentIndex = headNode.elements.index(after: headNode.currentIndex)
        if headNode.currentIndex == headNode.elements.endIndex {
          link.removeHead()
        }
      }
      return headNode.elements[headNode.currentIndex]
    } else {
      return nil
    }
  }

  public var isEmpty: Bool { link.first == nil }
  public var count: Int { link.reduce(0) { $0 + $1.elements.distance(from: $1.currentIndex, to: $1.elements.endIndex) } }
}

public extension DiscontinuousQueue where S == ArraySlice<Element> {
  mutating func enqueue(_ element: Element) {
    self.enqueue(ArraySlice(repeating: element, count: 1))
  }

  mutating func enqueue(_ elements: [Element]) {
    self.enqueue(ArraySlice(elements))
  }
}

public extension DiscontinuousQueue where S == Array<Element> {
  mutating func enqueue(_ element: Element) {
    self.enqueue([element])
  }

  mutating func enqueue(_ elements: ArraySlice<Element>) {
    self.enqueue(Array(elements))
  }
}

extension DiscontinuousQueue {
  final class Node {
    var elements: LazySequence<S>
    var currentIndex: LazySequence<S>.Index

    init(_ elements: S) {
      self.elements = elements.lazy
      currentIndex = self.elements.startIndex
    }
  }

}

#if DEBUG

  extension DiscontinuousQueue: CustomDebugStringConvertible {
    public var debugDescription: String {
      "DiscontinuousQueue<\(link.debugDescription)>"
    }

    public var _debugBlockCounts: Int {
      link.count
    }

    public var _debugIsLinkNodesGood: Bool {
      link._debugIsGood
    }

    public var _debugLinkCopyTimes: Int {
      link._debugCopyTimes
    }

  }

  extension DiscontinuousQueue.Node: CustomDebugStringConvertible {
    public var debugDescription: String {
      "(count: \(elements.count), currentIndex: \(currentIndex))"
    }

  }
#endif
