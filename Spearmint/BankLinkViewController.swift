//
//  BankLinkViewController.swift
//  Spearmint
//
//  Created by Sebastian Shanus on 12/11/17.
//  Copyright © 2017 Sebastian Shanus. All rights reserved.
//

import Foundation
import LinkKit
import RxSwift
import UIKit

class BankLinkViewController : UIViewController, FLViewContoroller {
    typealias CompletionObserver = BehaviorSubject<WelcomeFlowCompletionStates>
    let completionObserver: CompletionObserver
    let bankLinkViewModel: BankLinkViewModel
    required init(completionObserver: CompletionObserver, user: User) {
        self.completionObserver = completionObserver
        self.bankLinkViewModel = BankLinkViewModel(completionObserver: completionObserver, user: user)
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let linkViewController = PLKPlaidLinkViewController(delegate: bankLinkViewModel)
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            linkViewController.modalPresentationStyle = .formSheet;
        }
        self.present(linkViewController, animated: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class BankLinkViewModel : NSObject, FLViewModel {
    typealias Model = Void
    func buildModel() -> () {}
    let disposeBag = DisposeBag()
    let userContext = UserContext()
    
    let completionObserver: BehaviorSubject<WelcomeFlowCompletionStates>
    var user: User
    init(completionObserver: BehaviorSubject<WelcomeFlowCompletionStates>, user: User) {
        self.completionObserver = completionObserver
        self.user = user
        super.init()
    }
}

extension BankLinkViewModel : PLKPlaidLinkViewDelegate {
    func linkViewController(_ linkViewController: PLKPlaidLinkViewController, didExitWithError error: Error?, metadata: [String : Any]?) {
        // TODO: Handle error
    }
    
    func linkViewController(_ linkViewController: PLKPlaidLinkViewController, didSucceedWithPublicToken publicToken: String, metadata: [String : Any]?) {
        Plaid.exchangeToAccessToken(with: publicToken)
            .subscribe(onNext: { [weak self] accessToken in
                guard let `self` = self else { return }
                self.user.accessToken = accessToken!
                self.userContext.update(self.user)
                self.completionObserver.onNext(WelcomeFlowCompletionStates.authenticatedWithBank(self.user))
            }).addDisposableTo(disposeBag)
    }
}
