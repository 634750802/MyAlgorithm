//
// Created by 高林杰 on 2020/5/29.
//

public typealias Comparator<T> = (T, T) -> Bool

public struct Heap<T> {
  @usableFromInline var comparator: (T, T) -> Bool
  @usableFromInline var storage: [T] = []

  @inlinable public init(comparator: @escaping Comparator<T>) {
    self.comparator = comparator
  }

  @inlinable var count: Int {
    storage.count
  }

  @inlinable var isEmpty: Bool {
    storage.isEmpty
  }

  @inlinable var first: T? {
    storage.first
  }

  public mutating func push(_ value: T) {
    storage.append(value)
    refactorB2T()
  }

  public mutating func pop() -> T? {
    guard let value = storage.first else {
      return nil
    }
    storage[storage.startIndex] = storage[storage.index(before: storage.endIndex)]
    storage.removeLast()
    refactorT2B()
    return value
  }

  @inlinable mutating func refactorB2T() {
    var index = storage.index(before: storage.endIndex)
    while index > storage.startIndex {
      let parent = (index - 1) >> 1
      if !comparator(storage[parent], storage[index]) {
        storage.swapAt(index, parent)
        index = parent
      } else {
        break
      }
    }
    #if DEBUG
      _debugIsOk()
    #endif
  }

  @inlinable mutating func refactorT2B() {
    var index = storage.startIndex
    while index < storage.endIndex {
      let leftIndex = (index << 1) + 1
      let rightIndex = leftIndex + 1
      let value = storage[index]

      if rightIndex < storage.endIndex {
        let left = storage[leftIndex]
        let right = storage[rightIndex]
        if comparator(left, right) {
          if !comparator(value, left) {
            storage.swapAt(index, leftIndex)
            index = leftIndex
          } else {
            break
          }
        } else {
          if !comparator(value, right) {
            storage.swapAt(rightIndex, index)
            index = rightIndex
          } else {
            break
          }
        }
      } else if leftIndex < storage.endIndex {
        if !comparator(value, storage[leftIndex]) {
          storage.swapAt(index, leftIndex)
          index = leftIndex
        } else {
          break
        }
      } else {
        break
      }
    }
    #if DEBUG
      _debugIsOk()
    #endif
  }
}

extension Heap where T: Comparable {
  @inlinable public init() {
    self.init(comparator: <)
  }
}

extension Heap {
  #if DEBUG

  #endif
}

extension Heap {
  @inlinable public func _debugIsOk(file: StaticString = #file, line: UInt = #line) {
    for i in storage.startIndex..<storage.endIndex {
      let left = (i << 1) + 1
      let right = left + 1
      if left < storage.endIndex {
        assert(!comparator(storage[left], storage[i]), file: file, line: line)
      } else {
        break
      }
      if right < storage.endIndex {
        assert(!comparator(storage[right], storage[i]), file: file, line: line)
      }
    }
  }
}

extension Sequence where Element: Comparable {
  func max(count: Int) -> [Element] {
    var iter = makeIterator()
    var heap = Heap<Element>(comparator: >)
    while let element = iter.next() {
      heap.push(element)
    }
    var result: [Element] = []
    let n = Swift.min(count, heap.count)
    result.reserveCapacity(n)
    for _ in 0..<n {
      result.append(heap.pop()!)
    }
    return result
  }

  func min(count: Int) -> [Element] {
    var iter = makeIterator()
    var heap = Heap<Element>(comparator: <)
    while let element = iter.next() {
      heap.push(element)
    }
    var result: [Element] = []
    let n = Swift.min(count, heap.count)
    result.reserveCapacity(n)
    for _ in 0..<n {
      result.append(heap.pop()!)
    }
    return result
  }
}