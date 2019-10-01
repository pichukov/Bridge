# BridgeNet

[![CI Status](https://img.shields.io/travis/pichukov/Bridge.svg?style=flat)](https://travis-ci.org/pichukov/Bridge)
[![Version](https://img.shields.io/cocoapods/v/Bridge.svg?style=flat)](https://cocoapods.org/pods/Bridge)
[![License](https://img.shields.io/cocoapods/l/Bridge.svg?style=flat)](https://cocoapods.org/pods/Bridge)
[![Platform](https://img.shields.io/cocoapods/p/Bridge.svg?style=flat)](https://cocoapods.org/pods/Bridge)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

Bridge is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'BridgeNet'
```

## Description

`BridgeNet` is a lightweight library for implementing the messages delivery system within the app. It can be a replacement for `NotificationCenter` or `Observer Observable` pattern in the application. 

We can explain the `BridgeNet` as an undirected graph. Each node of the graph has `Type` and `ID`. `ID` is a unique `UUID` string and `Type` is an `enum` usually or any other `Hashable` type you prefer for storing it.  

The main idea of the `BridgeNet` is to make messages delivery system flexible and not coupled with a specific implementation. To keep it, the `BridgeNet` doesn't have the adjacency list or adjacency matrix for node connections storing for the graph. You don't need any global object or `Singleton` to send the message from one node to another. The only thing you need to know is the destination `Type`. If you have more than one node in the system with the same `Type` but you want to send the message to the specific node you also have to specify the `ID` of the destination node.

For example you have an object structure in the app that can be presented as a graph from the picture:

![Platform](https://i.ibb.co/w7VkRRr/graph.png)

#### Node types

The `Type` of all objects can be described as an `enum`:

```swift
enum NodeType: BridgeNodeTypable {
    case root
    case blue
    case green
    case red
}
```

#### Node holder implementation

Each object that wants to send and receive messages throw the `BridgeNet` should confirm several protocols:

- `BridgeNodeConnectable` to have the ability connect nodes to each other
- `BridgeCallable` to implement the recieving functionality

For example, that's how the simple `UIView` that presents the `red` node from the picture could look like:

```swift
class RedView: UIView {

    var bridgeNode: BridgeNode<NodeType>?

    func initBridge() {
        bridgeNode = BridgeNode<NodeType>(withAddress: BridgeNodeAddress<NodeType>(withAutogeneratedIdAndType: .red))
        bridgeNode?.add(delegate: self)
    }
}

extension RedView: BridgeNodeConnectable {}

extension RedView: BridgeCallable {

    func recieve<NodeType>(message: BridgeMessage<NodeType>) {
        guard let color = message.value as? UIColor else { return }
        backgroundColor = color
    }

}
```

This view is just getting messages from other nodes, and changes there own background color according to the color been getting from the message.

The functionality of the node connection is already implemented in the `BridgeNodeConnectable` protocol extension.  

> IMPORTANT: when you create the `BridgeNode` element, you also can specify the working Queue and the completion Queue for it. By default `BridgeNet` is using there own concurrent DispatchQueue as a working one and the Main Queue for completion. The thread-safety of the message delivery process is guaranteed by the internal architecture but only in case of using the same threads for each `BridgeNode` element

#### Nodes connection

To add the new BridgeNode to the graph, you have to connect it to the existing one. For example, let's take a look at how to connect the `redView` to the current object:

```swift
bridgeNode!.add(node: redView.connect(node: bridgeNode!))
```

#### Message sending

To send any information by the `BridgeNet` you need to create the `BridgeMessage` object. For the message you have to specify:

- the source node of the message
- the destination node
- the data you want to send
- the optional callback that can be called by the destination object after receiving the message

If you want to send the message to all the nodes of a specific type, you can create it like this: 

```swift
let message = BridgeMessage<NodeType>(fromSourse: bridgeNode!.address,
                                      toDestination: BridgeNodeAddress<NodeType>(withOnlyType: .red),
                                      withValue: UIColor.white)
```

to create the message to the specific node in this type you also have to specify the `ID`

To send the message call `send` from the `BridgeNode` object:

```swift
bridgeNode!.send(message: message)
```

## Author

Alexey Pichukov ,  pichukov@gmail.com

## License

Bridge is available under the MIT license. See the LICENSE file for more info.
