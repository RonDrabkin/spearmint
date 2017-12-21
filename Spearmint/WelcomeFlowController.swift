//
//  WelcomeFlowController.swift
//  Spearmint
//
//  Created by Sebastian Shanus on 10/18/17.
//  Copyright © 2017 Sebastian Shanus. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

enum WelcomeFlowCompletionStates {
    case authenticatedWithBank(User), authenticatedWithoutBank(User), unauthenticated
}

class WelcomeFlowController : FLFlowController {
    var dismissFlow: (() -> Void)?
    var disposeBag = DisposeBag()
    let welcomeFlowSubject = BehaviorSubject<WelcomeFlowCompletionStates>(value: .unauthenticated)
    
    func configureRootViewController() -> UIViewController {
        welcomeFlowSubject
            .subscribe(onNext: { [weak self] (state) in
                guard let `self` = self else { return }
                switch state {
                case .authenticatedWithBank(let user):
                    let appFlowController = AppFlowController(user: user)
                    self.present(appFlowController, usingPresent: {
                        self.sharedElements.navigationController.pushViewController(appFlowController.rootViewController, animated: true)
                    }, usingDismiss: nil)
                case .authenticatedWithoutBank(let user):
                    self.sharedElements.navigationController.pushViewController(self.makeBankLinkViewController(user: user), animated: true)
                case .unauthenticated: break
                    // TODO:
                }
            }).addDisposableTo(disposeBag)
        return self.makeRootViewController()
    }
    
    func makeRootViewController() -> UIViewController {
        let welcomeFlowController = WelcomeFlowTableViewController(completionObserver: welcomeFlowSubject)
        return welcomeFlowController
    }
    
    func makeBankLinkViewController(user: User) -> UIViewController {
        let bankLinkViewController = BankLinkViewController(completionObserver: welcomeFlowSubject, user: user)
        return bankLinkViewController
    }
}
