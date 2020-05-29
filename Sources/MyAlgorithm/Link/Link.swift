//
// Created by 高林杰 on 2020/5/28.
//

// TODO: Prove it!
fileprivate let defaultCopySize: Int = MemoryLayout<Int>.size + MemoryLayout<Int>.size

public struct Link<T> {
  fileprivate let contentMemoryLayoutSize = MemoryLayout<T>.size
  @usableFromInline private(set) var head: Node? = nil
  @usableFromInline private(set) weak var tail: Node? = nil

  #if DEBUG
    @usableFromInline var copyTimesHolder = CopyTimesHolder()
  #endif

  init() {
  }

  // Call only when want to copy on write.
  @discardableResult
  @inlinable public mutating func ensureCopyOnWrite(function: String = #function, file: String = #file, line: Int = #line) -> Bool {
    if head != nil {
      var tailHolder: Node? = nil
      if (MyAlgorithm.copyIfNeeded(&head) { (tail) in tailHolder = tail }) {
        #if DEBUG
          print("[DEBUG] Copy link on write: \(function) \(file):\(line)")
          recordCopyTimes(self.copyTimesHolder)
        #endif
        self.tail = tailHolder
        return true
      }
    }
    return false
  }

  @inlinable public mutating func append(_ value: T) {
    ensureCopyOnWrite()
    if let tail = tail {
      tail.next = Node(value)
      self.tail = tail.next
    } else {
      head = Node(value)
      tail = head
    }
  }

  @inlinable public mutating func removeHead() {
    ensureCopyOnWrite()
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

  }
}

extension Link.Node: COWSafeType {
  public class func makeCopyContext() -> Link<T>.Node? { nil }

  @usableFromInline func copy(_ tail: inout Link<T>.Node?) -> Self {
    let newNode = Self.init(value)
    newNode.next = self.next?.copy(&tail)
    if self.next != nil {
      tail = newNode
    }
    return newNode
  }
}

extension Link.Node where T: COWSafeType {
  @usableFromInline func copy(_ tail: inout Link<T>.Node?) -> Self {
    var valueContext = T.makeCopyContext()
    let newNode = Self.init(value.copy(&valueContext))
    newNode.next = self.next?.copy(&tail)
    if self.next != nil {
      tail = newNode
    }
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
    @usableFromInline weak var previousNode: Node?

    @inlinable init(head: Node?, currentNode: Node?, previousNode: Node?) {
      self.head = head
      self.currentNode = currentNode
      self.previousNode = previousNode
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
          fatalError("Two index was not from one link. Note that indices are not shared between links. (\(a!), \(b!))", file: file, line: line)
        }
      #endif
    }

    @inlinable public static func <(lhs: Index, rhs: Index) -> Bool {
      Index.makeSureFromSameLink(lhs, rhs)
      guard let l = lhs.currentNode else {
        return false
      }
      guard let r = rhs.currentNode else {
        return true
      }
      guard ObjectIdentifier(l) != ObjectIdentifier(r) else {
        return false
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
    Index(head: head, currentNode: head, previousNode: nil)
  }
  public var endIndex: Index {
    Index(head: head, currentNode: nil, previousNode: tail)
  }
  public subscript(position: Index) -> T {
    get {
      position.makeSureHeadAvailable()
      guard let node = position.currentNode else {
        fatalError("Index out of range")
      }
      return node.value
    }
    set {
      // HACK
      position.makeSureHeadAvailable()
      let oldValue = position.currentNode!.value
      position.currentNode!.value = newValue
      if ensureCopyOnWrite() {
        position.currentNode!.value = oldValue
      }
    }
  }

  public func index(after i: Index) -> Index {
    i.makeSureHeadAvailable()
    guard let node = i.currentNode else {
      fatalError("Index out of range")
    }
    return Index(head: i.head, currentNode: node.next, previousNode: node)
  }

}

extension Link: MutableCollection {
  @usableFromInline typealias RawLink = (head: Node?, tail: Node?)

  @inlinable static func rawAppend(_ link: inout RawLink, _ node: Node) {
    if link.head == nil {
      link.head = node
      link.tail = node
    } else {
      link.tail!.next = node
      link.tail = node
    }
  }

  public mutating func partition(by belongsInSecondPartition: (T) throws -> Bool) rethrows -> Index {
    if isEmpty {
      return endIndex
    }
    ensureCopyOnWrite()

    var firstPartition: RawLink = (nil, nil)
    var secondPartition: RawLink = (nil, nil)

    var current = head
    while let node = current {
      if try belongsInSecondPartition(node.value) {
        Link.rawAppend(&secondPartition, node)
      } else {
        Link.rawAppend(&firstPartition, node)
      }
      current = node.next
      node.next = nil
    }
    firstPartition.tail?.next = secondPartition.head
    head = firstPartition.head ?? secondPartition.head
    tail = secondPartition.tail ?? firstPartition.tail
    return Index(head: head, currentNode: secondPartition.head, previousNode: nil)
  }

  mutating public func swapAt(_ i: Index, _ j: Index) {
    Index.makeSureFromSameLink(i, j)
    if contentMemoryLayoutSize <= defaultCopySize {
      swap(&i.currentNode!.value, &j.currentNode!.value)
    } else {
      // TODO: Use pointer
      #if DEBUG
        print("[WARN] Unsupported big node swap for link.")
      #endif
      swap(&i.currentNode!.value, &j.currentNode!.value)
    }
  }

  public func withContiguousMutableStorageIfAvailable<R>(_ body: (inout UnsafeMutableBufferPointer<T>) throws -> R) rethrows -> R? { nil }
}

extension Link: Equatable where T: Equatable {
  public static func ==(lhs: Link<T>, rhs: Link<T>) -> Bool {
    var li = lhs.startIndex
    var ri = rhs.startIndex
    while li != lhs.endIndex && ri != rhs.endIndex {
      if li.currentNode?.value != ri.currentNode?.value {
        return false
      }
      li = lhs.index(after: li)
      ri = rhs.index(after: ri)
    }
    return li == lhs.endIndex && ri == rhs.endIndex
  }
}

#if DEBUG

  extension Link.Node {
    @usableFromInline var tail: Link<T>.Node {
      if let next = next {
        return next.tail
      } else {
        return self
      }
    }
  }

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

  extension Link.Node: CustomDebugStringConvertible {
    public var debugDescription: String {
      " -> \(value)\(next?.debugDescription ?? "")"
    }
  }

  extension Link.Index: CustomDebugStringConvertible {
    public var debugDescription: String {
      guard let head = head else {
        return "Link.Index<bad index>"
      }
      if let currentNode = currentNode {
        if ObjectIdentifier(head) == ObjectIdentifier(currentNode) {
          return "Link.Index<\(ObjectIdentifier(head)):startIndex>"
        } else {
          return "Link.Index<\(ObjectIdentifier(head)):\(currentNode.debugDescription)>"
        }
      } else {
        return "Link.Index<\(ObjectIdentifier(head)):endIndex>"
      }
    }
  }

#endif
