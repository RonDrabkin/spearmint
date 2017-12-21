//
//  AppFlowController.swift
//  Spearmint
//
//  Created by Sebastian Shanus on 12/17/17.
//  Copyright © 2017 Sebastian Shanus. All rights reserved.
//

import RxSwift
import Foundation

class AppFlowController : FLFlowController {
    internal var dismissFlow: (() -> Void)?
    var disposeBag = DisposeBag()
    let user: User
    init(user: User) {
        self.user = user
    }
    
    func configureRootViewController() -> UIViewController {
        let tabBarController = UITabBarController()
        tabBarController.setViewControllers(
            [
                configureTransactionsViewController()
            ], animated: true)
        return tabBarController
    }
    
    func configureTransactionsViewController() -> UIViewController {
        let transactionsViewController = TransactionsHistoryViewController(user: self.user)
        return transactionsViewController
    }
}
