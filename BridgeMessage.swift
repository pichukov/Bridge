//
//  BridgeMessage.swift
//  Bridge
//
//  Created by Alexey Pichukov on 27/09/2019.
//

import Foundation

/**
 * Message object in the Bridge system
 *
 * NOTE: The message is a reference type for keeping low memory usage during the message delivery process
 *
 * - id:          the unique UUID String of the message
 * - sourse:      the Sourse Node address
 * - destination: the Destination Node address
 * - value:       the main data that should be delivered by the message
 * - callback:    an optional callback for the message, can be called from the destination Node
 *
 */
public class BridgeMessage<Type: BridgeNodeTypable> {
    
    public let value: Any
    public var callback: ((_ result: Result<Any, Error>) -> Void)?
    
    let id: String
    let sourse: BridgeNodeAddress<Type>
    let destination: BridgeNodeAddress<Type>
    
    private var visitedNodes: [String] = []
    /// The queue for make thread safty access to the visitedNodes array
    private let nodesAccessQueue = DispatchQueue(label: "com.bridge.synchronize.visited.nodes.array", attributes: .concurrent)
    
    public init(fromSourse sourse: BridgeNodeAddress<Type>,
         toDestination destination: BridgeNodeAddress<Type>,
         withValue value: Any,
         callback: ((_ result: Result<Any, Error>) -> Void)? = nil) {
        self.id = UUID().uuidString
        self.sourse = sourse
        self.destination = destination
        self.value = value
        self.callback = callback
        self.visitedNodes.append(self.id)
    }
    
    /**
     Internal method for adding Node to the visitedNodes array
     */
    func addVisited(nodeWithId id: String?) {
        guard id != nil else { return }
        nodesAccessQueue.async(flags: .barrier) {
            self.visitedNodes.append(id!)
        }
    }
    
    /**
    Internal method for checking the Node for been visited
    */
    func visited(nodeWithId id: String?) -> Bool {
        guard id != nil else { return false }
        var contains = false
        nodesAccessQueue.sync {
            contains = self.visitedNodes.contains(id!)
        }
        return contains
    }
}
