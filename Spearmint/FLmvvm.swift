//
//  FLmvvm.swift
//  Spearmint
//
//  Created by Sebastian Shanus on 11/25/17.
//  Copyright © 2017 Sebastian Shanus. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol FLViewContoroller {
    associatedtype CompletionObserver
}

protocol FLView {
    associatedtype ViewModel
    func bind(with viewModel: ViewModel)
}

protocol FLTableCellView : FLView {
    init(_ reuseIdentifier: String?)
}

protocol FLViewModel {
    associatedtype Model
    func buildModel() -> Model
}

protocol FLTableCellViewModel : FLViewModel { }

extension FLViewModel {
    var model : Model {
        get {
            return buildModel()
        }
    }
}
