//
//  FLFlowController.swift
//  Spearmint
//
//  Created by Sebastian Shanus on 11/25/17.
//  Copyright © 2017 Sebastian Shanus. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

protocol FLFlowController : class {
    var disposeBag : DisposeBag { get set }
    var dismissFlow : (() -> Void)? { get set }
    func configureRootViewController() -> UIViewController
}

private var sharedElementsKey: UInt8 = 0
extension FLFlowController {
    var rootViewController : UIViewController {
        return configureRootViewController()
    }
    
    func present(_ flow: FLFlowController,
                 usingPresent present: () -> Void,
                 usingDismiss dismiss: (() -> Void)?) {
        flow.dismissFlow = dismiss
        flow.sharedElements = self.sharedElements
        present()
    }
    
    // Some hacky runtime stuff to get this stored property on the extension
    var sharedElements : SharedElements {
        get {
            if let stored = objc_getAssociatedObject(self, &sharedElementsKey) as? SharedElements {
                return stored
            }
            let stored = SharedElements()
            objc_setAssociatedObject(self, &sharedElementsKey, stored, .OBJC_ASSOCIATION_RETAIN)
            return stored
        }
        set {
            objc_setAssociatedObject(self, &sharedElementsKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        
    }
}

/// TODO: Implement this.
protocol FLFlowGlobalState {
    static func flowState() -> Disposable
}

extension FLFlowGlobalState {
    func present(_ flow: FLFlowController,
                 usingPresent present: () -> Void,
                 usingDismiss dismiss: (() -> Void)?) {
        flow.dismissFlow = dismiss
        present()
    }
}
