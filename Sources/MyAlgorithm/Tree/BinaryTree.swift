//
// Created by 高林杰 on 2020/5/29.
//

public class BinaryTree<T> {
  @usableFromInline var rootNode: Node?

  @inlinable public var root: NodeRef {
    NodeRef(node: rootNode)
  }
}

extension BinaryTree {
  @usableFromInline class Node {
    @usableFromInline var value: T
    @usableFromInline weak var parent: Node? = nil
    @usableFromInline var left: Node? = nil
    @usableFromInline var right: Node? = nil

    @usableFromInline required init(_ value: T, left: Node? = nil, right: Node? = nil) {
      self.value = value
      self.left = left
      self.right = right
    }

    @inlinable func tryDetachFromParent() {
      parent?.detach(node: self)
    }

    @inlinable func detach(node: Node) {
      guard node.parent == self else {
        fatalError("Detaching node is not child of tree node")
      }
      if left == node {
        left?.parent = nil
        left = nil
      } else {
        right?.parent = nil
        right = nil
      }
    }

    @inlinable func attach(left node: Node) {
      node.tryDetachFromParent()
      left = node
      node.parent = self
    }

    @inlinable func attach(right node: Node) {
      node.tryDetachFromParent()
      right = node
      node.parent = self
    }
  }

  public struct NodeRef {
    @usableFromInline weak var root: Node?
    @usableFromInline weak var node: Node?

    @usableFromInline init(node: Node?) {
      self.node = node
    }

    subscript<S: Sequence>(_ sequence: S) -> NodeRef where S.Element == WritableKeyPath<NodeRef, NodeRef> {
      get {
        var ref = self
        var iter = sequence.makeIterator()
        while let keyPath = iter.next() {
          ref = ref[keyPath: keyPath]
        }
        return ref
      }
      set {
        var ref = self
        var iter = sequence.makeIterator()
        while let keyPath = iter.next() {
          ref = ref[keyPath: keyPath]
        }
        let parent = ref.parent
        if parent.left.node == ref.node {
          ref.node?.tryDetachFromParent()
          parent.node?.left = newValue.node
        } else {
          ref.node?.tryDetachFromParent()
          parent.node?.right = newValue.node
        }
      }
    }

    @inlinable public var value: T {
      get {
        node!.value
      }
      set {
        node!.value = newValue
      }
    }

    @inlinable public var parent: NodeRef {
      NodeRef(node: node?.parent)
    }

    @inlinable public var left: NodeRef {
      get {
        NodeRef(node: node?.left)
      }
      set {
        node!.attach(left: newValue.node!)
      }
    }

    @inlinable public var right: NodeRef {
      get {
        NodeRef(node: node?.right)
      }
      set {
        node!.attach(right: newValue.node!)
      }
    }
  }
}


extension BinaryTree.Node: Equatable {
  public static func ==(lhs: BinaryTree.Node, rhs: BinaryTree.Node) -> Bool {
    ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
  }
}

extension BinaryTree.Node: COWSafeType {
  public func copy(_ context: inout Void) -> Self {
    Self.init(value, left: left?.copy(&context), right: right?.copy(&context))
  }
}

extension BinaryTree.NodeRef: Equatable where T: Equatable {
  public static func ==(lhs: BinaryTree.NodeRef, rhs: BinaryTree.NodeRef) -> Bool {
    lhs.node?.value == rhs.node?.value
  }
}

extension BinaryTree.NodeRef: Comparable where T: Comparable {
  public static func <(lhs: BinaryTree.NodeRef, rhs: BinaryTree.NodeRef) -> Bool {
    if let lv = lhs.node?.value, let rv = rhs.node?.value {
      return lv < rv
    } else {
      return false
    }
  }
}
