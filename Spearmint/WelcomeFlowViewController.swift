//
//  WelcomeFlowViewController.swift
//  Spearmint
//
//  Created by Sebastian Shanus on 10/18/17.
//  Copyright © 2017 Sebastian Shanus. All rights reserved.
//

import FirebaseAuth
import RxSwift
import RxCocoa
import UIKit

enum WelcomeFlowState {
    case signup, signin
}

enum WelcomeFlowSections : String {
    case loginDetails = "loginDetails"
    case actionButton = "actionButton"
    case switchStateButton = "switchStateButton"
}

class WelcomeFlowTableViewController : UITableViewController, FLViewContoroller {
    typealias CompletionObserver = BehaviorSubject<WelcomeFlowCompletionStates>
    private let disposeBag = DisposeBag()
    private let xTableView = WelcomeFlowTableView()
    private let welcomeFlowViewModel:  WelcomeFlowTableViewModel
    private let completionObserver : CompletionObserver
    
    required init(completionObserver: BehaviorSubject<WelcomeFlowCompletionStates>) {
        self.completionObserver = completionObserver
        self.welcomeFlowViewModel = WelcomeFlowTableViewModel(completionObserver: completionObserver)
        super.init(style: .grouped)
    }
    
    override func viewDidLoad() {
        self.tableView = self.xTableView
        self.xTableView.bind(with: welcomeFlowViewModel)
        self.navigationItem.hidesBackButton = true
        self.title = "Welcome to Spearmint"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class WelcomeFlowTableView : TableBuilderView, FLView {
    typealias ViewModel = WelcomeFlowTableViewModel
    
    init() {
        super.init(frame: .zero, style: .grouped)
        self.estimatedRowHeight = 44.0
        self.rowHeight = UITableViewAutomaticDimension
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(with viewModel: WelcomeFlowTableViewModel) {
        self.bindTableView(to: viewModel)
    }
}


class WelcomeFlowTableViewModel : TableBuilderViewModel {
    let completionObserver: BehaviorSubject<WelcomeFlowCompletionStates>
    let welcomeFlowStateSubject = BehaviorSubject<WelcomeFlowState>(value: .signup)
    let disposeBag = DisposeBag()
    let userContext = UserContext()
    init(completionObserver: BehaviorSubject<WelcomeFlowCompletionStates>) {
        self.completionObserver = completionObserver
        super.init()
        // Create sections
        let sections = [
            TableBuilderSection(
                sectionKey: WelcomeFlowSections.loginDetails.rawValue,
                sectionOrder: 0,
                rows: Variable<[SectionRow]>([])
            ),
            TableBuilderSection(
                sectionKey: WelcomeFlowSections.actionButton.rawValue,
                sectionOrder: 1,
                rows: Variable<[SectionRow]>([])
            ),
            TableBuilderSection(
                sectionKey: WelcomeFlowSections.switchStateButton.rawValue,
                sectionOrder: 2,
                rows: Variable<[SectionRow]>([])
            )
        ]
        self.addSections(sections)
        
        // Bind login details section
        let emailViewModel = TextFieldCellViewModel(placeHolderText: "Email",
                                                textFieldText: nil,
                                                protectedText: false)
        let passwordViewModel = TextFieldCellViewModel(placeHolderText: "Password",
                                                       textFieldText:nil,
                                                       protectedText:true)
        let confirmPasswordViewModel = TextFieldCellViewModel(placeHolderText: "Confirm Password",
                                                              textFieldText:nil,
                                                              protectedText:true)
        let loginDetails = Observable.combineLatest(emailViewModel.rx_text, passwordViewModel.rx_text, welcomeFlowStateSubject) { ($0, $1, $2) }
        welcomeFlowStateSubject
            .map { (state) -> [SectionRow] in
                switch state {
                case .signin:
                    return [
                        TableBuilderRow<TextFieldTableCell, TextFieldCellViewModel>(
                            cell: TextFieldTableCell.init(_:),
                            viewModel: emailViewModel
                        ),
                        TableBuilderRow<TextFieldTableCell, TextFieldCellViewModel>(
                            cell: TextFieldTableCell.init(_:),
                            viewModel: passwordViewModel
                        )
                    ]
                case .signup:
                    return [
                        TableBuilderRow<TextFieldTableCell, TextFieldCellViewModel>(
                            cell: TextFieldTableCell.init(_:),
                            viewModel: emailViewModel
                        ),
                        TableBuilderRow<TextFieldTableCell, TextFieldCellViewModel>(
                            cell: TextFieldTableCell.init(_:),
                            viewModel: passwordViewModel
                        ),
                        TableBuilderRow<TextFieldTableCell, TextFieldCellViewModel>(
                            cell: TextFieldTableCell.init(_:),
                            viewModel: confirmPasswordViewModel
                        )
                    ]
                }
            }
            .bind(to: sectionWithKey(WelcomeFlowSections.loginDetails.rawValue).rows)
            .addDisposableTo(disposeBag)
        
        // Bind action button section
        var buttonCellViewModel = ButtonCellViewModel(title: "Sign In")
        buttonCellViewModel.buttonTap
            .withLatestFrom(loginDetails)
            .subscribe(onNext: self.performLoginSignup)
            .addDisposableTo(self.disposeBag)
        welcomeFlowStateSubject
            .map { (state) -> [SectionRow] in
                let buttonTitle = state == .signup ? "Sign up" : "Sign in"
                buttonCellViewModel.setTitle(title: buttonTitle)
                return [
                    TableBuilderRow<ButtonTableViewCell, ButtonCellViewModel>(
                        cell: ButtonTableViewCell.init(_:),
                        viewModel: buttonCellViewModel
                    )
                ]
            }.bind(to: sectionWithKey(WelcomeFlowSections.actionButton.rawValue).rows)
            .addDisposableTo(disposeBag)
        
        // Bind switch state section
        var switchStateViewModel = ButtonCellViewModel(title: "Sign Up")
        switchStateViewModel.buttonTap
            .withLatestFrom(welcomeFlowStateSubject)
            .subscribe(onNext: { [weak self] state in
                if (state == .signup) {
                    self?.welcomeFlowStateSubject.onNext(.signin)
                } else {
                    self?.welcomeFlowStateSubject.onNext(.signup)
                }
            })
            .addDisposableTo(disposeBag)
        welcomeFlowStateSubject
            .map { (state) -> [SectionRow] in
                let buttonTitle = state == .signup ? "Sign in" : "Sign up"
                switchStateViewModel.setTitle(title: buttonTitle)
                return [
                    TableBuilderRow<ButtonTableViewCell, ButtonCellViewModel>(
                        cell: ButtonTableViewCell.init(_:),
                        viewModel: switchStateViewModel
                    )
                ]
            }.bind(to: sectionWithKey(WelcomeFlowSections.switchStateButton.rawValue).rows)
            .addDisposableTo(disposeBag)
    }
    
    private func performLoginSignup(_ email: String?, _ password: String?, _ state: WelcomeFlowState) {
        switch state {
        case .signin:
            Auth.auth().signIn(withEmail: email!, password: password!, completion: { (user, error) in
                // TODO:
                //guard let user = user else {
                //    print(error!)
                //}
                
            })
        case .signup:
            Auth.auth().createUser(withEmail: email!, password: password!, completion: { (user, error) in
                guard let user = user else {
                    // TODO: ERROR
                    return
                }
                let newUser = self.userContext.createUser(from: user.uid)
                self.completionObserver.onNext(.authenticatedWithoutBank(newUser))
            })
        }
    }
}






