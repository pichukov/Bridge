//
//  GeneralView.swift
//  Bridge_Example
//
//  Created by Alexey Pichukov on 30/09/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import Bridge

class GeneralView: UIView {

    var bridgeNode: BridgeNode<EntityType>?
    
    func initBridge() {
        bridgeNode = BridgeNode<EntityType>(withAddress: BridgeNodeAddress<EntityType>(withAutogeneratedIdAndType: .general))
        bridgeNode?.add(delegate: self)
    }
}

extension GeneralView: BridgeNodeConnectable {}

extension GeneralView: BridgeCallable {
    
    func recieve<EntityType>(message: BridgeMessage<EntityType>) {
        guard let color = message.value as? UIColor else { return }
        backgroundColor = color
    }
    
}