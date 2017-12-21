//
//  FLAutoLayout.swift
//  Spearmint
//
//  Created by Sebastian Shanus on 11/25/17.
//  Copyright © 2017 Sebastian Shanus. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func addSubViewNoTranslating(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)
    }
}

class FL_LayoutAttributes : NSObject {
    var view: UIView
    var attribute: NSLayoutAttribute
    var multipler: CGFloat = 1.0
    var constant: CGFloat = 0.0
    init(view: UIView, attribute: NSLayoutAttribute) {
        self.view = view
        self.attribute = attribute
        super.init()
    }
    
    static func ==(lhs:FL_LayoutAttributes, rhs: FL_LayoutAttributes) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: lhs.view, attribute: lhs.attribute, relatedBy: .equal, toItem: rhs.view, attribute: rhs.attribute, multiplier: rhs.multipler, constant:rhs.constant)
    }
    static func +(lhs:FL_LayoutAttributes, rhs: CGFloat) -> FL_LayoutAttributes {
        lhs.constant = rhs
        return lhs
    }
    static func -(lhs:FL_LayoutAttributes, rhs: CGFloat) -> FL_LayoutAttributes {
        lhs.constant = -rhs
        return lhs
    }
}

extension UIView {
    var fl_leading : FL_LayoutAttributes { return FL_LayoutAttributes(view: self, attribute: .leading) }
    var fl_trailing : FL_LayoutAttributes { return FL_LayoutAttributes(view: self, attribute: .trailing) }
    var fl_leadingMargin : FL_LayoutAttributes { return FL_LayoutAttributes(view: self, attribute: .leadingMargin) }
    var fl_trailingMargin : FL_LayoutAttributes { return FL_LayoutAttributes(view: self, attribute: .trailingMargin) }
    var fl_top : FL_LayoutAttributes { return FL_LayoutAttributes(view: self, attribute: .top) }
    var fl_bottom : FL_LayoutAttributes { return FL_LayoutAttributes(view: self, attribute: .bottom) }
    var fl_topMargin : FL_LayoutAttributes { return FL_LayoutAttributes(view: self, attribute: .topMargin) }
    var fl_bottomMargin : FL_LayoutAttributes { return FL_LayoutAttributes(view: self, attribute: .bottomMargin) }
    var fl_centerX : FL_LayoutAttributes { return FL_LayoutAttributes(view: self, attribute: .centerX) }
    var fl_centerY : FL_LayoutAttributes { return FL_LayoutAttributes(view: self, attribute: .centerY) }
}

extension Array where Element:NSLayoutConstraint {
    func activate() {
        _ = map({ $0.isActive = true })
    }
    func deactivate() {
        _ = map({ $0.isActive = false })
    }
}
