//
//  WeakRef.swift
//  Bridge
//
//  Created by Alexey Pichukov on 27/09/2019.
//

import Foundation

/**
Generic class for keeping weak references
*/
public class WeakRef<Element: AnyObject> {
    
    private(set) weak var value: Element?
    
    required init(withValue value: Element) {
        self.value = value
    }
    
}
