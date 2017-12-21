//
//  LoadingViewController.swift
//  Spearmint
//
//  Created by Sebastian Shanus on 10/11/17.
//  Copyright © 2017 Sebastian Shanus. All rights reserved.
//

import Firebase
import UIKit
import RxSwift
import LinkKit

class LoadingViewController: UIViewController, FLViewContoroller {
    typealias CompletionObserver = PublishSubject<AuthenticationState>
    let loadingView = LoadingView()
    let viewModel: LoadingViewModel
    let completion: CompletionObserver
    
    required init(completionObserver: CompletionObserver) {
        self.completion = completionObserver
        self.viewModel = LoadingViewModel(completionObserver: completion)
        super.init(nibName: nil, bundle: nil)
        self.view = loadingView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadingView.bind(with: viewModel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct LoadingViewModel : FLViewModel {
    typealias Model = Void
    let disposeBag = DisposeBag()
    let completionObserver: PublishSubject<AuthenticationState>
    
    func loadServices() {
        // Static services to load
        loadFirebase()
        
        // Dynamic services to load
        let _ = Observable.zip(loadPlaid(), loadAuthenticationState()) { (success, state) in
            return (success, state)
        }.subscribe(onNext: { (success, state) in
            print(success)
            self.completionObserver.onNext(state)
        }).addDisposableTo(disposeBag)
    }
    
    private func loadFirebase() {
        FirebaseApp.configure()
    }
    
    private func loadPlaid() -> Observable<Bool> {
        let plaidLinkSubject = PublishSubject<Bool>()
        PLKPlaidLink.setup { (success, error) in
            if (success) {
                // Handle success here, e.g. by posting a notification
                NSLog("Plaid Link setup was successful")
                plaidLinkSubject.onNext(true)
            }
            else if let error = error {
                NSLog("Unable to setup Plaid Link due to: \(error.localizedDescription)")
                plaidLinkSubject.onNext(false)
            }
            else {
                NSLog("Unable to setup Plaid Link")
                plaidLinkSubject.onNext(false)
            }
        }
        return plaidLinkSubject.asObservable()
    }
    
    private func loadAuthenticationState() -> Observable<AuthenticationState> {
        let authState = PublishSubject<AuthenticationState>()
        let _ = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let _ = user {
                authState.onNext(.authenticated)
            } else {
                authState.onNext(.unauthenticated)
            }
        }
        return authState.asObservable()
    }
    
    func buildModel() {}
}

class LoadingView : UIView, FLView {
    typealias ViewModel = LoadingViewModel
    private let loadingLabel = UILabel()
    
    init() {
        super.init(frame: .zero)
        
        loadingLabel.text = "Loading..."
        loadingLabel.font = UIFont.boldSystemFont(ofSize: 18)
        loadingLabel.textColor = UIColor.darkGray
        self.addSubViewNoTranslating(loadingLabel)
        
        [loadingLabel.fl_centerX == self.fl_centerX,
         loadingLabel.fl_centerY == self.fl_centerY].activate()
    }
    
    func bind(with viewModel: LoadingViewModel) {
        viewModel.loadServices()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
