//
// Created by 高林杰 on 2020/5/28.
//

public struct Link<T> {
  @usableFromInline private(set) var head: Node? = nil
  @usableFromInline private(set) weak var tail: Node? = nil

  #if DEBUG
    @usableFromInline var copyTimesHolder = CopyTimesHolder()
  #endif

  init() {
  }

  // Call only when want to copy on write.
  @inlinable public mutating func ensureCopyOnWrite(function: String = #function, file: String = #file, line: Int = #line) {
    if head != nil {
      if MyAlgorithm.copyIfNeeded(&head) {
        #if DEBUG
          print("[DEBUG] Copy link on write: \(function) \(file):\(line)")
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
  }

  @inlinable public mutating func removeHead() {
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

}

extension Link: Collection {

  public struct Index: Comparable {
    @usableFromInline weak var head: Node?
    @usableFromInline weak var currentNode: Node?

    @inlinable init(head: Node?, currentNode: Node?) {
      self.head = head
      self.currentNode = currentNode
    }

    @inlinable func makeSureHeadAvailable(file: StaticString = #file, line: UInt = #line) {
      #if DEBUG
        guard head != nil else {
          fatalError("Index was leak from an link. Make sure the index was used in the lifecycle of the link. Note that indices are not shared between links.", file: file, line: line)
        }
      #endif
    }

    @inlinable static func makeSureFromSameLink(_ a: Index?, _ b: Index?, file: StaticString = #file, line: UInt = #line) {
      #if DEBUG
        if a?.head == nil && b?.head == nil {
          return
        }
        guard let aHead = a?.head, let bHead = b?.head, ObjectIdentifier(aHead) == ObjectIdentifier(bHead) else {
          fatalError("Two index was not from one link. Note that indices are not shared between links.", file: file, line: line)
        }
      #endif
    }

    @inlinable public static func <(lhs: Index, rhs: Index) -> Bool {
      Index.makeSureFromSameLink(lhs, rhs)
      guard let l = lhs.currentNode else {
        return false
      }
      guard let r = rhs.currentNode, ObjectIdentifier(l) != ObjectIdentifier(r) else {
        return true
      }
      var i = l
      while let c = i.next {
        if ObjectIdentifier(c) == ObjectIdentifier(r) {
          return true
        }
        i = c
      }
      return false
    }

    @inlinable public static func ==(lhs: Index, rhs: Index) -> Bool {
      Index.makeSureFromSameLink(lhs, rhs)
      guard let l = lhs.currentNode, let r = rhs.currentNode else {
        return lhs.currentNode == nil && rhs.currentNode == nil
      }
      return ObjectIdentifier(l) == ObjectIdentifier(r)
    }
  }

  @inlinable public var startIndex: Index {
    Index(head: head, currentNode: head)
  }
  public var endIndex: Index {
    Index(head: head, currentNode: nil)
  }
  public subscript(position: Index) -> T {
    position.makeSureHeadAvailable()
    guard let node = position.currentNode else {
      fatalError("Index out of range")
    }
    return node.value
  }

  public func index(after i: Index) -> Index {
    i.makeSureHeadAvailable()
    guard let node = i.currentNode else {
      fatalError("Index out of range")
    }
    return Index(head: i.head, currentNode: node.next)
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
