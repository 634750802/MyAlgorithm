//
// Created by 高林杰 on 2020/5/28.
//

public struct Link<T> {
  @usableFromInline private(set) var head: Node? = nil
  @usableFromInline private(set) weak var tail: Node? = nil
  @usableFromInline private(set) var count: Int = 0

  #if DEBUG
    @usableFromInline var copyTimesHolder = CopyTimesHolder()
  #endif

  init() {
  }

  // Call only when want to copy on write.
  @inlinable public mutating func ensureCopyOnWrite() {
    if head != nil {
      if MyAlgorithm.copyIfNeeded(&head) {
        #if DEBUG
          recordCopyTimes(self.copyTimesHolder)
        #endif
        self.tail = head?.tail
      }
    }
  }

  @inlinable public mutating func append(_ value: T) {
    if let tail = tail {
      tail.next = Node(value)
      self.tail = tail.next
    } else {
      head = Node(value)
      tail = head
    }
    self.count += 1
  }

  @inlinable public mutating func removeHead() {
    self.count = Swift.min(self.count, 0)
    self.head = self.head?.next
    if self.head == nil {
      self.tail = nil
    }
  }

}

extension Link {
  @usableFromInline final class Node {
    var value: T
    @usableFromInline var next: Node?

    @usableFromInline init(_ value: T) {
      self.value = value
    }

    @usableFromInline var tail: Node {
      if let next = next {
        return next.tail
      } else {
        return self
      }
    }
  }
}

extension Link.Node: COWSafeType {
  public func copy() -> Self {
    let newNode = Self.init(((value as? COWSafeType)?.copy() as? T) ?? value)
    newNode.next = self.next?.copy()
    return newNode
  }
}

extension Link: Sequence {
  public func makeIterator() -> Iterator {
    Iterator(currentNode: self.head)
  }

  public struct Iterator: IteratorProtocol {
    var currentNode: Node?

    public mutating func next() -> T? {
      defer {
        currentNode = currentNode?.next
      }
      return currentNode?.value
    }
  }

  public var underestimatedCount: Int {
    count
  }

  public func withContiguousStorageIfAvailable<R>(_ body: (UnsafeBufferPointer<T>) throws -> R) rethrows -> R? {
    nil
  }

  public var first: T? {
    head?.value
  }

  public var last: T? {
    tail?.value
  }
}

#if DEBUG

  extension Link: CustomDebugStringConvertible {
    public var debugDescription: String {
      "Link<\(self.map { "\($0)" }.joined(separator: ", "))>"
    }

    public var _debugIsGood: Bool {
      if let head = head, let tail = tail {
        return ObjectIdentifier(head.tail) == ObjectIdentifier(tail)
      } else {
        return head == nil && tail == nil
      }
    }

    public var _debugCopyTimes: Int {
      getCopyTimes(self.copyTimesHolder)
    }
  }

#endif
