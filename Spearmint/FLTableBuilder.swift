//
//  FLTableBuilder.swift
//  Spearmint
//
//  Created by Sebastian Shanus on 11/25/17.
//  Copyright © 2017 Sebastian Shanus. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class TableBuilderView : UITableView {
    private let disposeBag = DisposeBag()
    
    func bindTableView(to viewModel: TableBuilderViewModel) {
        self.dataSource = viewModel
        viewModel.tableUpdateSubject
            .subscribe(onNext: { (_) in
                self.reloadData()
            })
            .addDisposableTo(disposeBag)
    }
}

class TableBuilderViewModel : NSObject, UITableViewDataSource {
    private let disposeBag = DisposeBag()
    private var sections = [String:TableBuilderSection]()
    private var rankedSections = [TableBuilderSection]()
    let tableUpdateSubject = BehaviorSubject<Bool>(value: true)
    
    func addSection(_ section: TableBuilderSection) {
        self.sections[section.sectionKey] = section
        section.rows
            .asObservable()
            .subscribe(onNext: { [weak self] (rows) in
                self?.tableUpdateSubject.onNext(true)
            })
            .addDisposableTo(disposeBag)
        self.updateRank()
    }
    
    
    func addSections(_ sections: [TableBuilderSection]) {
        _ = sections.map {
            self.sections[$0.sectionKey] = $0
            $0.rows
                .asObservable()
                .subscribe(onNext: { [weak self] (rows) in
                    self?.tableUpdateSubject.onNext(true)
                })
                .addDisposableTo(disposeBag)
        }
        self.updateRank()
    }
    
    func sectionWithKey(_ key: String) -> TableBuilderSection {
        return sections[key]!
    }
    
    func rowsFromKey(_ key: String) -> Variable<[SectionRow]> {
        return sections[key]!.rows
    }
    
    private func updateRank() {
        self.rankedSections = Array(sections.values).sorted(by: { (lhs, rhs) -> Bool in
            return lhs.sectionOrder < rhs.sectionOrder
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return rankedSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rankedSections[section].rows.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rows = rankedSections[indexPath.section].rows.value
        return rows[indexPath.row].buildTableCell()
    }
}

struct TableBuilderSection {
    var sectionKey : String
    var sectionOrder : Int
    var rows : Variable<[SectionRow]>
}

protocol SectionRow {
    func buildTableCell() -> UITableViewCell
}

struct TableBuilderRow<Cell:FLTableCellView, ViewModel:FLTableCellViewModel> : SectionRow where Cell.ViewModel == ViewModel {
    var cell: (_ reuseIdentifier:String?) -> Cell
    var viewModel : ViewModel
    
    func buildTableCell() -> UITableViewCell {
        let tableCell = cell(nil)
        tableCell.bind(with: viewModel)
        return tableCell as! UITableViewCell
    }
}
