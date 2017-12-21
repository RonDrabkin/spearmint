//
//  TextFieldTableCell.swift
//  Spearmint
//
//  Created by Sebastian Shanus on 10/22/17.
//  Copyright © 2017 Sebastian Shanus. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

class TextFieldTableCell : UITableViewCell, FLTableCellView {
    typealias ViewModel = TextFieldCellViewModel
    let textField = UITextField()
    let disposeBag = DisposeBag()
    required init(_ reuseIdentifier:String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubViewNoTranslating(self.textField)
        
        let constraints = [
            self.textField.fl_leading == self.contentView.fl_leading,
            self.textField.fl_trailing == self.contentView.fl_trailing,
            self.textField.fl_top == self.contentView.fl_top,
            self.textField.fl_bottom == self.contentView.fl_bottom
        ]
        constraints.activate()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(with viewModel: TextFieldCellViewModel) {
        self.textField.placeholder = viewModel.placeHolderText
        self.textField.text = viewModel.textFieldText
        self.textField.isSecureTextEntry = viewModel.protectedText
        self.textField
            .rx.text
            .bind(to: viewModel.rx_text)
            .addDisposableTo(disposeBag)
    }
}

struct TextFieldCellViewModel: FLTableCellViewModel {
    typealias Model = TextFieldCellModel
    var rx_text: PublishSubject<String?>
    fileprivate let placeHolderText: String
    fileprivate let textFieldText: String?
    fileprivate let protectedText: Bool
    
    init(placeHolderText: String, textFieldText: String?, protectedText: Bool) {
        self.placeHolderText = placeHolderText
        self.textFieldText = textFieldText
        self.protectedText = protectedText
        self.rx_text = PublishSubject<String?>()
    }
    
    func buildModel() -> TextFieldCellModel {
        return TextFieldCellModel(placeHolderText: placeHolderText, textFieldText: textFieldText, protectedText: protectedText)
    }
}

struct TextFieldCellModel {
    let placeHolderText: String
    let textFieldText: String?
    let protectedText: Bool
}
