//
//  FLSharedElements.swift
//  Spearmint
//
//  Created by Sebastian Shanus on 12/11/17.
//  Copyright © 2017 Sebastian Shanus. All rights reserved.
//

import Foundation
import UIKit

private let shared = SharedElements()
class SharedElements {
    let navigationController = UINavigationController()
    class var sharedElements: SharedElements {
        return shared
    }
}
