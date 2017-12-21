//
//  ButtonTableViewCell.swift
//  Spearmint
//
//  Created by Sebastian Shanus on 11/25/17.
//  Copyright © 2017 Sebastian Shanus. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ButtonTableViewCell: UITableViewCell, FLTableCellView {
    typealias ViewModel = ButtonCellViewModel
    let button = UIButton(type: .roundedRect)
    let disposeBag = DisposeBag()
    required init(_ reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubViewNoTranslating(button)
        let constraints = [
            self.button.fl_leading == self.contentView.fl_leading,
            self.button.fl_trailing == self.contentView.fl_trailing,
            self.button.fl_top == self.contentView.fl_top,
            self.button.fl_bottom == self.contentView.fl_bottom
        ]
        constraints.activate()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(with viewModel: ButtonCellViewModel) {
        self.button.setTitle(viewModel.title, for: .normal)
        self.button.rx.tap
            .bind(to: viewModel.buttonTap)
            .addDisposableTo(disposeBag)
    }
}

struct ButtonCellViewModel : FLTableCellViewModel {
    typealias Model = ButtonCellModel
    var title: String
    var buttonTap = PublishSubject<Void>()
    
    init(title: String) {
        self.title = title
    }
    
    mutating func setTitle(title: String) {
        self.title = title
    }
    
    func buildModel() -> ButtonCellModel {
        return ButtonCellModel(title: title)
    }
}

struct ButtonCellModel {
    let title: String
}
