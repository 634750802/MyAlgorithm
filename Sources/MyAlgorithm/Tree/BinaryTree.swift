//
// Created by 高林杰 on 2020/5/29.
//

public struct BinaryTree<T> {
  @usableFromInline var rootNode: Node?

  @inlinable public var root: NodeRef {
    mutating get {
      if let rootNode = rootNode {
        return NodeRef(node: rootNode)
      } else {
        return NodeRef(tree: &self)
      }
    }
    set {
      if let node = newValue.type.referencedNode {
        self.rootNode = node
      } else {
        self.rootNode = nil
      }
    }
  }

  @inlinable public var immutableRoot: ImmutableNodeRef {
    if let rootNode = rootNode {
      return ImmutableNodeRef(node: rootNode)
    } else {
      return ImmutableNodeRef(tree: self)
    }
  }

  public func copy() -> Self {
    var newTree = self
    var void: Void = ()
    newTree.rootNode = rootNode?.copy(&void)
    return newTree
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

  public struct ImmutableNodeRef {
    @usableFromInline var type: ImmutableRefType

    @usableFromInline init(tree: BinaryTree) {
      self.type = .root(withUnsafePointer(to: tree) { $0 })
    }

    @usableFromInline init(node: Node) {
      self.type = .node(node)
    }

    @inlinable public var value: T {
      switch type {
        case .node(let node):
          return node.value
        case .root(let pointer):
          return pointer.pointee.rootNode!.value
      }
    }

    @inlinable public var parent: ImmutableNodeRef {
      switch type {
        case .node(let node):
          if let parent = node.parent {
            return ImmutableNodeRef(node: parent)
          } else {
            return nil!
          }
        case .root:
          return nil!
      }
    }

    @inlinable public var hasLeft: Bool {
      type.referencedNode?.left != nil
    }

    @inlinable public var left: ImmutableNodeRef {
      if let left = type.referencedNode?.left {
        return ImmutableNodeRef(node: left)
      } else {
        return nil!
      }
    }

    @inlinable public var hasRight: Bool {
      type.referencedNode?.right != nil
    }

    @inlinable public var right: ImmutableNodeRef {
      if let right = type.referencedNode?.right {
        return ImmutableNodeRef(node: right)
      } else {
        return nil!
      }
    }
  }

  public struct NodeRef {
    @usableFromInline var type: RefType

    public init(_ value: T) {
      self.type = .node(.init(value))
    }

    @usableFromInline init(tree: inout BinaryTree) {
      self.type = .root(withUnsafeMutablePointer(to: &tree) { $0 })
    }

    @usableFromInline init(node: Node) {
      self.type = .node(node)
    }

    @usableFromInline init(parentNode: Node, leaf: WritableKeyPath<Node, Node?>) {
      self.type = .visualNode(parentNode, leaf)
    }

    @inlinable public var value: T {
      get {
        switch type {
          case .node(let node):
            return node.value
          case .visualNode(let node, let leaf):
            return node[keyPath: leaf]!.value
          case .root(let pointer):
            return pointer.pointee.rootNode!.value
        }
      }
      nonmutating set {
        switch type {
          case .node(let node):
            node.value = newValue
          case .visualNode(var parentNode, let leaf):
            if let node = parentNode[keyPath: leaf] {
              node.value = newValue
            } else {
              parentNode[keyPath: leaf] = Node(newValue)
            }
          case .root(let pointer):
            pointer.pointee.rootNode = Node(newValue)
        }
      }
    }

    @inlinable public var parent: NodeRef {
      switch type {
        case .node(let node):
          if let parent = node.parent {
            return NodeRef(node: parent)
          } else {
            return NodeRef(parentNode: node, leaf: \.parent)
          }
        case .visualNode(let node, let leaf):
          if leaf == \.parent {
            if let parent = node.parent {
              return NodeRef(node: parent)
            } else {
              return nil!
            }
          } else {
            return NodeRef(node: node)
          }
        case .root:
          return nil!
      }
    }

    @inlinable public var hasLeft: Bool {
      type.referencedNode?.left != nil
    }

    @inlinable public var left: NodeRef {
      if let left = type.referencedNode?.left {
        return NodeRef(node: left)
      } else {
        return NodeRef(parentNode: type.referencedNode!, leaf: \.left)
      }
    }

    @inlinable public var hasRight: Bool {
      type.referencedNode?.right != nil
    }

    @inlinable public var right: NodeRef {
      if let right = type.referencedNode?.right {
        return NodeRef(node: right)
      } else {
        return NodeRef(parentNode: type.referencedNode!, leaf: \.right)
      }
    }

    @inlinable public func isChildOrEqual(of ref: NodeRef) -> Bool {

      guard let node = self.type.referencedNode, let refNode = ref.type.referencedNode else {
        return false
      }
      var parent = node.parent
      while let parentNode = parent {
        if parentNode == refNode {
          return true
        }
        parent = parent?.parent
      }
      return false
    }
  }

  @usableFromInline enum ImmutableRefType {
    case root(UnsafePointer<BinaryTree>)
    case node(Node)

    @usableFromInline var referencedNode: Node? {
      switch self {
        case .node(let node):
          return node
        case .root(let pointer):
          return pointer.pointee.rootNode
      }
    }
  }

  @usableFromInline enum RefType {
    case root(UnsafeMutablePointer<BinaryTree>)
    case node(Node)
    case visualNode(Node, WritableKeyPath<Node, Node?>)

    @usableFromInline var referencedNode: Node? {
      switch self {
        case .node(let node):
          return node
        case .visualNode(let node, let leaf):
          return node[keyPath: leaf]
        case .root(let pointer):
          return pointer.pointee.rootNode
      }
    }
  }
}

extension BinaryTree {
  @usableFromInline func traversalPre(node: Node, consumer: (T) -> Void) {
    consumer(node.value)
    if let left = node.left {
      traversalPre(node: left, consumer: consumer)
    }
    if let right = node.right {
      traversalPre(node: right, consumer: consumer)
    }
  }

  @usableFromInline func traversalIn(node: Node, consumer: (T) -> Void) {
    if let left = node.left {
      traversalIn(node: left, consumer: consumer)
    }
    consumer(node.value)
    if let right = node.right {
      traversalIn(node: right, consumer: consumer)
    }
  }

  @usableFromInline func traversalPost(node: Node, consumer: (T) -> Void) {
    if let left = node.left {
      traversalPost(node: left, consumer: consumer)
    }
    if let right = node.right {
      traversalPost(node: right, consumer: consumer)
    }
    consumer(node.value)
  }

  @inlinable public func traversal(order: TreeTraversalOrder = .pre, consumer: (T) -> Void) {
    guard let node = rootNode else {
      return
    }
    switch order {
      case .pre:
        traversalPre(node: node, consumer: consumer)
      case .in:
        traversalIn(node: node, consumer: consumer)
      case .post:
        traversalPost(node: node, consumer: consumer)
    }
  }
}


public enum TreeTraversalOrder {
  case pre
  case `in`
  case post
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
    lhs.type.referencedNode?.value == rhs.type.referencedNode?.value
  }
}

extension BinaryTree.NodeRef: Comparable where T: Comparable {
  public static func <(lhs: BinaryTree.NodeRef, rhs: BinaryTree.NodeRef) -> Bool {
    if let lv = lhs.type.referencedNode?.value, let rv = rhs.type.referencedNode?.value {
      return lv < rv
    } else {
      return false
    }
  }
}
