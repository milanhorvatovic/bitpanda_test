//
//  RepositoryListViewController.swift
//  bitpanda test
//
//  Created by Milan Horvatovic on 05/08/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation
import UIKit

import ReactiveSwift
import ReactiveCocoa
import Cartography

internal protocol RepositoryListViewControllerProtocol {
    
}

internal protocol RepositoryListViewControllerDelegate: class {
    
    func request(_ viewController: RepositoryListViewControllerProtocol, openDetail data: Model.Service.Search.Item)
    
}

internal final class RepositoryListViewController<ViewModelType>: CommonViewController<ViewModelType>
    , RepositoryListViewControllerProtocol
    , UITableViewDataSource
    , UITableViewDelegate
    where ViewModelType: RepositoryListViewModel
{
    
    internal private(set) weak var tableView: UITableView!
    internal private(set) weak var pullToRefresh: UIRefreshControl!
    
    internal private(set) weak var loadingOverlayView: UIView!
    internal private(set) weak var errorOverlayView: UIView!
    internal private(set) weak var reloadButton: UIButton!
    
    internal weak var delegate: RepositoryListViewControllerDelegate?
    
    internal override func loadView() {
        super.loadView()
        
        //  TableView
        do {
            let tableView: UITableView = .init(frame: .zero, style: .plain)
            tableView.translatesAutoresizingMaskIntoConstraints = false
            tableView.backgroundColor = .clear
            self.tableView = tableView
            self.view.addSubview(tableView)
            Cartography.constrain(self.view, tableView, block: { (
                superview: Cartography.ViewProxy
                , tableView: Cartography.ViewProxy
                ) in
                tableView.left == superview.left
                tableView.top == superview.top
                tableView.right == superview.right
                tableView.bottom == superview.bottom
            })
        }
        
        //  PullToRefresh
        do {
            let refresh: UIRefreshControl = .init()
            refresh.attributedTitle = .init(string: "Refreshing...")
            if #available(iOS 10.0, *) {
                self.tableView.refreshControl = refresh
            }
            else {
                self.tableView.addSubview(refresh)
            }
            self.pullToRefresh = refresh
        }
        
        //  Loading view
        do {
            let view: UIView = .init()
            let colorSpecter: CGFloat = 0.75 / 255.0
            view.backgroundColor = .init(white: colorSpecter, alpha: 0.45)
            view.translatesAutoresizingMaskIntoConstraints = false
            let label: UILabel = .init()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "Loading..."
            let indicator: UIActivityIndicatorView = .init(style: .white)
            indicator.startAnimating()
            let stack: UIStackView = .init(arrangedSubviews: [label, indicator])
            stack.alignment = .center
            stack.axis = .vertical
            stack.distribution = .fillProportionally
            stack.spacing = 10.0
            
            view.addSubview(stack)
            self.loadingOverlayView = view
            self.view.addSubview(view)
            Cartography.constrain(self.view, view, stack, block: { (
                superview: Cartography.ViewProxy
                , view: Cartography.ViewProxy
                , content: Cartography.ViewProxy
                ) in
                view.edges == superview.edges
                
                content.center == view.center
                content.leading >= superview.leadingMargin
                content.top >= superview.topMargin
            })
        }
        
        //  Error view
        do {
            let view: UIView = .init()
            let colorSpecter: CGFloat = 0.75 / 255.0
            view.backgroundColor = .init(white: colorSpecter, alpha: 0.45)
            view.translatesAutoresizingMaskIntoConstraints = false
            let label: UILabel = .init()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "Failed transactions...\nSomething went wrong, try it again."
            let button: UIButton = .init()
            button.setTitle("Retry", for: .normal)
            let stack: UIStackView = .init(arrangedSubviews: [label, button])
            stack.alignment = .center
            stack.axis = .vertical
            stack.distribution = .fillProportionally
            stack.spacing = 10.0
            
            view.addSubview(stack)
            self.errorOverlayView = view
            self.reloadButton = button
            self.view.addSubview(view)
            Cartography.constrain(self.view, view, stack, block: { (
                superview: Cartography.ViewProxy
                , view: Cartography.ViewProxy
                , content: Cartography.ViewProxy
                ) in
                view.edges == superview.edges
                
                content.center == view.center
                content.leading >= superview.leadingMargin
                content.top >= superview.topMargin
            })
        }
    }
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Repositories list"
        self.navigationItem.title = "Repositories list"
        
        self.loadingOverlayView.alpha = 0.0
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.tableView.register(.init(nibName: "RepositoryListCell", bundle: .none), forCellReuseIdentifier: "RepositoryListCell")
        
        self.disposables += self.viewModel
            .reloadingState
            .producer
            .observe(on: QueueScheduler.main)
            .startWithValues({ [weak self] (state: ViewModel.Repository.List.LoadingState) in
                guard let selfStrong = self else {
                    return
                }
                switch state {
                case .unknown:
                    selfStrong.pullToRefresh.endRefreshing()
                    selfStrong.loadingOverlayView.alpha = 0.0
                    selfStrong.errorOverlayView.alpha = 1.0
                case .loaded(_):
                    selfStrong.pullToRefresh.endRefreshing()
                    selfStrong.tableView.isHidden = false
                    selfStrong.loadingOverlayView.alpha = 0.0
                    selfStrong.errorOverlayView.alpha = 0.0
                    selfStrong.tableView.reloadData()
                case .loading:
                    selfStrong.pullToRefresh.beginRefreshing()
                    selfStrong.tableView.isHidden = true
                    selfStrong.loadingOverlayView.alpha = 1.0
                    selfStrong.errorOverlayView.alpha = 0.0
                    selfStrong.navigationItem.title = .none
                case .failed:
                    selfStrong.pullToRefresh.endRefreshing()
                    selfStrong.tableView.isHidden = true
                    selfStrong.loadingOverlayView.alpha = 0.0
                    selfStrong.errorOverlayView.alpha = 1.0
                    selfStrong.navigationItem.title = nil
                }
            })
        
        self.disposables += self.viewModel
            .loadingState
            .producer
            .observe(on: QueueScheduler.main)
            .startWithValues({ [weak self] (state: ViewModel.Repository.List.LoadingState) in
                guard let selfStrong = self else {
                    return
                }
                switch state {
                case .loaded(_):
                    selfStrong.tableView.reloadData()
                default:
                    break
                }
            })
        
        self.disposables += self.pullToRefresh.reactive
            .controlEvents(.valueChanged)
            .observeValues({ [weak self] (_: UIRefreshControl) in
                guard let selfStrong = self else {
                    return
                }
                selfStrong.viewModel.reload()
            })
        
        self.disposables += self.reloadButton.reactive
            .controlEvents(.touchUpInside)
            .observeValues({ [weak self] (_: UIButton) in
                guard let selfStrong = self else {
                    return
                }
                selfStrong.viewModel.reload()
            })
    }
    
    //  MARK: UITableViewDataSource
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.viewModel.loadedState.value {
        case .loaded(let data):
            return data.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: RepositoryListCell = tableView.dequeueReusableCell(withIdentifier: "RepositoryListCell") as? RepositoryListCell else {
            fatalError()
        }
        
        guard let data: RepositoryListCellModelProtocol = self.viewModel.retrieveCellData(at: indexPath) else {
            return cell
        }
        cell.configure(with: data)
        
        return cell
    }
    
    //  MARK: UITableViewDelegate
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard let selected: Model.Service.Search.Item = self.viewModel.retrieveData(at: indexPath) else {
            return
        }
        self.delegate?.request(self, openDetail: selected)
    }
    
}
