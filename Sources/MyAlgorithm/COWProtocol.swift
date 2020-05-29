//
// Created by 高林杰 on 2020/5/28.
//

public protocol COWSafeType: class {
  associatedtype CopyContext = Void
  func copy(_ context: inout CopyContext) -> Self
  static func makeCopyContext() -> CopyContext
}

extension COWSafeType where CopyContext == Void {
  public static func makeCopyContext() -> Void {}
}

@usableFromInline final class CopyTimesHolder {}

#if DEBUG

  @usableFromInline var copyTimes: [ObjectIdentifier: Int] = [:]

  @inlinable func recordCopyTimes<T: AnyObject>(_ object: T) {
    let id = ObjectIdentifier(object)
    copyTimes[id] = (copyTimes[id] ?? 0) + 1
  }

  @inlinable func getCopyTimes<T: AnyObject>(_ object: T) -> Int {
    let id = ObjectIdentifier(object)
    return copyTimes[id] ?? 0
  }

#endif

@inlinable public func copyIfNeeded<T: COWSafeType>(_ some: inout T?, completeHandler: ((T.CopyContext) -> Void)? = nil) -> Bool {
  if !isKnownUniquelyReferenced(&some) {
    if some != nil {
      #if DEBUG
        if some != nil {
          recordCopyTimes(some!)
        }
      #endif
      var context = T.makeCopyContext()
      some = some?.copy(&context)
      completeHandler?(context)
      return true
    } else {
      return false
    }
  }
  return false
}
