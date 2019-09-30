//
//  BridgeNode.swift
//  Bridge
//
//  Created by Alexey Pichukov on 27/09/2019.
//

import Foundation

/**
 * The Protocol for the single Node representation
 */
public protocol BridgeNodable: AnyObject {
    associatedtype BridgeNodeType: BridgeNodeTypable
    
    var address: BridgeNodeAddress<BridgeNodeType> { get }
    func add(node: BridgeNode<BridgeNodeType>?)
    func send(message: BridgeMessage<BridgeNodeType>)
}

/**
 * The Protocol for Node recieving functionality
 */
public protocol BridgeCallable: class {
    func recieve<Type>(message: BridgeMessage<Type>)
}

/**
 * Returning bridge node item 
 */
public protocol BridgeNodeConnectable: class {
    associatedtype BridgeNodeType: BridgeNodeTypable
    
    var bridgeNode: BridgeNode<BridgeNodeType>? { get }
}

extension BridgeNodeConnectable {
    
    public func connect(node: BridgeNode<BridgeNodeType>) -> BridgeNode<BridgeNodeType>? {
        bridgeNode?.add(node: node)
        return bridgeNode
    }
}

/**
 * The main Bridge Node representation
 *
 * - address:         Bridge Node address
 * - nodes:           the disciionary of Type <-> Nodes connections
 * - bridgeQueue:     the concurrent DispatchQueue that manages all Messages in the Bridge
 * - completionQueue: the DispatchQueue (main by default) for calling the completion block after the message recieved
 * 
 */
public class BridgeNode<Type: BridgeNodeTypable> {

    public let address: BridgeNodeAddress<Type>
    
    private var nodes: [Type: [WeakRef<BridgeNode>]] = [:]
    private weak var delegate: BridgeCallable?
    /// Operatiion queues for messages sending
    private let bridgeQueue: DispatchQueue
    private let completionQueue: DispatchQueue
    
    public init(withAddress address: BridgeNodeAddress<Type>,
         delegate: BridgeCallable? = nil,
         bridgeQueue: DispatchQueue = DispatchQueue(label: "com.bridge.cuncurrent.working.queue", attributes: .concurrent),
         completionQueue: DispatchQueue = DispatchQueue.main) {
        self.address = address
        self.delegate = delegate
        self.bridgeQueue = bridgeQueue
        self.completionQueue = completionQueue
    }
    
    /**
     Adding the callback delegate for the BridgeNode (usually it's the BridgeNode owner)
     */
    public func add(delegate: BridgeCallable) {
        self.delegate = delegate
    }
}

/**
 * The extension for sending message implementation
 */
extension BridgeNode: BridgeNodable {
    
    public typealias BridgeNodeType = Type
    
    /**
     Adding the new Bridge Node to the list
     Should be the BridgeNode object type as well
     */
    public func add(node: BridgeNode?) {
        guard node != nil else {
            assert(false, "⚠️ Bridge Error: the node provided as a BridgeNode is nil")
            return
        }
        guard var sameTypeNodes = nodes[node!.address.type] else {
            nodes[node!.address.type] = [WeakRef(withValue: node!)]
            return
        }
        var needToAdd = true
        /// Remove all no longer existing nodes
        /// check for having the node we've been asked to add
        sameTypeNodes.removeAll {
            if $0.value === node {
                needToAdd = false
            }
            return $0.value == nil
        }
        if needToAdd {
            sameTypeNodes.append(WeakRef(withValue: node!))
        }
        nodes[node!.address.type] = sameTypeNodes
    }
    
    /**
     * Send the Message action that executing in the bridgeQueue
     */
    public func send(message: BridgeMessage<Type>) {
        bridgeQueue.async {
            if let weakDestinationNodes = self.nodes[message.destination.type] {
                let finalNodes = self.destinationNodes(fromNodes: weakDestinationNodes, forDestination: message.destination)
                if !finalNodes.isEmpty {
                    self.send(message: message, toNodes: finalNodes)
                    return
                }
            }
            for key in self.nodes.keys {
                guard let weakNodes = self.nodes[key] else { continue }
                self.send(message: message, toNodes: weakNodes)
            }
        }
    }
    
    private func destinationNodes(fromNodes nodes: [WeakRef<BridgeNode>], forDestination destination: BridgeNodeAddress<Type>) -> [WeakRef<BridgeNode>] {
        for weakElement in nodes {
            guard weakElement.value != nil else { continue }
            guard destination.type == weakElement.value!.address.type else { return [] }
            guard let id = destination.id else { return [] }
            guard let elementId = weakElement.value!.address.id else { continue }
            if id == elementId { return [weakElement] }
        }
        return []
    }
    
    private func send(message: BridgeMessage<Type>, toNodes nodes: [WeakRef<BridgeNode>]) {
        message.addVisited(nodeWithId: address.id)
        for weakNode in nodes {
            guard let node = weakNode.value else { continue }
            node.crossTheBridge(withMessage: message)
        }
    }
    
    private func crossTheBridge(withMessage message: BridgeMessage<Type>) {
        guard !message.visited(nodeWithId: address.id) else { return }
        message.addVisited(nodeWithId: address.id)
        if address |= message.destination {
            completionQueue.async {
                self.delegate?.recieve(message: message)
            }
            if message.destination.id == nil {
                send(message: message)
            }
        } else {
            send(message: message)
        }
    }
}
