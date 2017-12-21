//
//  ViewController.swift
//  Spearmint
//
//  Created by Sebastian Shanus on 9/26/17.
//  Copyright © 2017 Sebastian Shanus. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

enum AuthenticationState {
    case authenticated, unauthenticated
}

enum LifecycleState {
    case unauthenticated, authenticatedWithBank, authenticatedWithoutBank
}

class RootFlowController : FLFlowController {
    var disposeBag = DisposeBag()
    var dismissFlow: (() -> Void)?
    let welcomeFlowController = WelcomeFlowController()
    
    func configureRootViewController() -> UIViewController {
        self.sharedElements.navigationController.setViewControllers([makeLoadingViewController()], animated: true)
        return self.sharedElements.navigationController
    }
    
    func makeLoadingViewController() -> UIViewController {
        let authenticatedStateObserver = PublishSubject<AuthenticationState>()
        authenticatedStateObserver
            .subscribe(onNext: { [weak self] (state) in
                guard let `self` = self else {
                    return
                }
                switch state {
                case .authenticated:
                    /// Present logged in screen
                    let appFlowController = AppFlowController()
                    self.present(self.appFlowController, usingPresent: { 
                        self.sharedElements.navigationController.pushViewController(self.appFlowController.rootViewController, animated: true)
                    }, usingDismiss: nil)
                case .unauthenticated:
                    /// Present welcome screen
                    self.present(self.welcomeFlowController, usingPresent: {
                        self.sharedElements.navigationController.pushViewController(self.welcomeFlowController.rootViewController, animated: true)
                    }, usingDismiss: nil)
                }
            }).addDisposableTo(disposeBag)
        return LoadingViewController(completionObserver: authenticatedStateObserver)
    }
    
}

