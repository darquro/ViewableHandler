//
//  Visibility.swift
//  Visibility
//
//  Created by yuki.kuroda on 2018/04/13.
//  Copyright © 2018年 darquro. All rights reserved.
//

import Foundation

/// `Visibility` is able to handle a view visibility in the window
/// You can access from the `visibility` property of UIView.
public class Visibility<Base> {
    public let base: Base
    var timer: Timer?
    var state: VisibilityState?
    var config = VisibilityConfig()
    var changedCallback: ((VisibilityState) -> Void)?
    
    public init (_ base: Base) {
        self.base = base
    }
    
    @objc func visibilityTimerTask(_ timer: Timer) {
        guard let view = self.base as? UIView else { return }
        let state = view.visibility.getVisibilityState(of: view)
        if self.state != state {
            self.state = state
            self.changedCallback?(state)
        }
    }
    
}

public protocol VisibilityCompatible {
    associatedtype Compatible
    var visibility: Visibility<Compatible> { get }
}

public extension VisibilityCompatible {
    
    /// `visibility` is able to handle a view visibility in the window
    public var visibility: Visibility<Self> {
        if let instance = objc_getAssociatedObject(self, &associatedObjectKey) as? Visibility<Self> {
            return instance
        }
        let instance = Visibility(self)
        objc_setAssociatedObject(self, &associatedObjectKey, instance, .OBJC_ASSOCIATION_RETAIN)
        return instance
    }
}

private var associatedObjectKey: UInt8 = 0
