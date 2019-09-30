//
//  BridgeNodeType.swift
//  Bridge
//
//  Created by Alexey Pichukov on 27/09/2019.
//

import Foundation

/**
 * Describes a type for the Node in Bridge system
 *
 * The most useful implementation would be an enum confirming the protocol:
 *
 * struct MyType: BridgeNodeTypable {
 *     case rootController
 *     case childController
 * }
 */
public protocol BridgeNodeTypable: Hashable {}
