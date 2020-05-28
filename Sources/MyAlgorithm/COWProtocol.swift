//
// Created by 高林杰 on 2020/5/28.
//

public protocol COWSafeType: class {
  func copy() -> Self
}

@usableFromInline final class CopyTimesHolder {}

@usableFromInline var copyTimes: [ObjectIdentifier: Int] = [:]

@inlinable func recordCopyTimes<T: AnyObject>(_ object: T) {
  let id = ObjectIdentifier(object)
  copyTimes[id] = (copyTimes[id] ?? 0) + 1
}

@inlinable func getCopyTimes<T: AnyObject>(_ object: T) -> Int {
  let id = ObjectIdentifier(object)
  return copyTimes[id] ?? 0
}

@inlinable public func copyIfNeeded<T: COWSafeType>(_ some: inout T?) -> Bool {
  if !isKnownUniquelyReferenced(&some) {
    if some != nil {
      #if DEBUG
        if some != nil {
          recordCopyTimes(some!)
        }
      #endif
      some = some?.copy()
      return true
    } else {
      return false
    }
  }
  return false
}
