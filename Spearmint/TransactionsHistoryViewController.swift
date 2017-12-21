//
//  TransactionsHistoryViewController.swift
//  Spearmint
//
//  Created by Sebastian Shanus on 12/17/17.
//  Copyright © 2017 Sebastian Shanus. All rights reserved.
//

import Foundation
import UIKit

class TransactionsHistoryViewController : UIViewController {
    let user: User
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
