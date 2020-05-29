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
    while index != storage.startIndex {
      if comparator(storage[index], storage[index >> 1]) {
        storage.swapAt(index, index >> 1)
        index = index >> 1
      } else {
        break
      }
    }
  }

  @inlinable mutating func refactorT2B() {
    var index = storage.startIndex
    while index < storage.endIndex {
      let then = ((index + 1) << 1) - 1
      let value = storage[index]

      guard then < storage.endIndex else {
        break
      }

      if then + 1 < storage.endIndex {
        let a = storage[then]
        let b = storage[then + 1]
        if comparator(a, value) {
          if comparator(a, b) {
            storage.swapAt(index, then)
          } else {
            storage.swapAt(index, then + 1)
          }
        } else {
          break
        }
      } else if then < storage.endIndex {
        if comparator(storage[then], storage[index]) {
          index = then
        } else {
          break
        }
      } else {
        break
      }
    }
  }
}

extension Heap where T: Comparable {
  @inlinable public init() {
    self.init(comparator: <)
  }
}