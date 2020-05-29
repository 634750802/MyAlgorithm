//
// Created by 高林杰 on 2020/5/28.
//

public struct DiscontinuousQueue<Element>: BatchEnqueuedQueue {
  private var link = Link<Node>()

  public mutating func enqueue<S: Collection>(_ elements: S) where S.Element == Element {
    link.append(.init(elements))
  }

  public mutating func enqueue(_ element: Element) {
    link.append(.init(CollectionOfOne(element)))
  }

  public mutating func dequeue() -> Element? {
    weak var head = link.head
    if head == nil {
      return nil
    } else {
      defer {
        head!.value.index = head!.value.elements.index(after: head!.value.index)
        if head!.value.index == head!.value.elements.endIndex {
          link.removeFirst()
        }
      }
      return head!.value.elements[head!.value.index]
    }
  }

  public var isEmpty: Bool {
    link.isEmpty
  }
  public var count: Int {
    link.reduce(0) { $0 + $1.elements.distance(from: $1.index, to: $1.elements.endIndex) }
  }
}

extension DiscontinuousQueue {
  struct Node {
    var elements: LazySequence<AnyCollection<Element>>
    var index: LazySequence<AnyCollection<Element>>.Index

    init<S: Collection>(_ elements: S) where S.Element == Element {
      self.elements = AnyCollection(elements).lazy
      self.index = self.elements.startIndex
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
      "(count: \(elements.count), currentIndex: \(index))"
    }

  }
#endif
