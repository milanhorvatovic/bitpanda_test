//
//  RepositoryDetailViewController.swift
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

internal protocol RepositoryDetailViewControllerProtocol {
    
}

internal protocol RepositoryDetailViewControllerDelegate: class {
    
    func requestClose(_ viewController: RepositoryDetailViewControllerProtocol)
    
}

internal final class RepositoryDetailViewController<ViewModelType>: CommonViewController<ViewModelType>
    , RepositoryDetailViewControllerProtocol
    , UITableViewDataSource
    , UITableViewDelegate
    where ViewModelType: RepositoryDetailViewModel
{
    
    internal private(set) weak var nameLabel: UILabel!
    internal private(set) weak var sizeLabel: UILabel!
    internal private(set) weak var stargazersLabel: UILabel!
    internal private(set) weak var forksCountLabel: UILabel!
    internal private(set) weak var contributorsCountLabel: UILabel!
    
    internal private(set) weak var tableView: UITableView!
    
    internal private(set) weak var loadingOverlayView: UIView!
    internal private(set) weak var errorOverlayView: UIView!
    internal private(set) weak var reloadButton: UIButton!
    
    internal weak var delegate: RepositoryDetailViewControllerDelegate?
    
    internal override func loadView() {
        super.loadView()
        
        self.navigationItem.title = self.viewModel.item.name
        
        //  Container
        let container: UIScrollView = .init()
        container.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(container)
        Cartography.constrain(self.view, container, block: { (
            superview: Cartography.ViewProxy
            , container: Cartography.ViewProxy
            ) in
            container.left == superview.left
            container.top == superview.top
            container.right == superview.right
            container.bottom == superview.bottom
        })
        
        var top: UIView? = .none
        
        do {
            let spacer: UIView = .init()
            spacer.translatesAutoresizingMaskIntoConstraints = false
            spacer.backgroundColor = .red
            spacer.isHidden = true
            container.addSubview(spacer)
            Cartography.constrain(self.view, container, spacer, block: { (
                superview: Cartography.ViewProxy
                , container: Cartography.ViewProxy
                , spacer: Cartography.ViewProxy
                ) in
                spacer.width == 1
                spacer.leading == container.leading
                spacer.top == container.top
                spacer.bottom == container.bottom
                spacer.height == superview.safeAreaLayoutGuide.height
            })
        }
        do {
            let spacer: UIView = .init()
            spacer.translatesAutoresizingMaskIntoConstraints = false
            spacer.backgroundColor = .blue
            spacer.isHidden = true
            container.addSubview(spacer)
            Cartography.constrain(self.view, container, spacer, block: { (
                superview: Cartography.ViewProxy
                , container: Cartography.ViewProxy
                , spacer: Cartography.ViewProxy
                ) in
                spacer.height == 1
                spacer.leading == container.leading
                spacer.top == container.top
                spacer.trailing == container.trailing
                spacer.width == superview.width
            })
        }
        
        //  Name
        do {
            let construct: (String) -> (UIView, UILabel) = { (labelText: String) -> (UIView, UILabel) in
                let label: UILabel = .init()
                label.translatesAutoresizingMaskIntoConstraints = false
                label.text = labelText
                label.setContentHuggingPriority(.required, for: .horizontal)
                let value: UILabel = .init()
                value.translatesAutoresizingMaskIntoConstraints = false
                value.setContentHuggingPriority(.defaultLow, for: .horizontal)
                let stack: UIStackView = .init(arrangedSubviews: [label, value])
                stack.alignment = .fill
                stack.axis = .horizontal
                stack.distribution = .fill
                stack.spacing = 5.0
                return (stack, value)
            }
            
            let (stack1, nameLabel): (UIView, UILabel) = construct("Repository name:")
            self.nameLabel = nameLabel
            let (stack2, sizeLabel): (UIView, UILabel) = construct("Size:")
            self.sizeLabel = sizeLabel
            let (stack3, stargazersLabel): (UIView, UILabel) = construct("Stargazers:")
            self.stargazersLabel = stargazersLabel
            let (stack4, forksCountLabel): (UIView, UILabel) = construct("Number of forks:")
            self.forksCountLabel = forksCountLabel
            let (stack5, contributorsCountLabel): (UIView, UILabel) = construct("Number of contributors:")
            self.contributorsCountLabel = contributorsCountLabel
            
            let stack: UIStackView = .init(arrangedSubviews: [stack1, stack2, stack3, stack4, stack5])
            stack.alignment = .fill
            stack.axis = .vertical
            stack.distribution = .fill
            stack.spacing = 5.0
            container.addSubview(stack)
            Cartography.constrain(self.view, container, stack, block: { (
                superview: Cartography.ViewProxy
                , container: Cartography.ViewProxy
                , content: Cartography.ViewProxy
                ) in
                
                content.leading == container.leadingMargin
                content.trailing == container.trailingMargin
                content.top == container.top
            })
            
            top = stack
        }
        
        //  TableView
        do {
            let tableView: UITableView = .init(frame: .zero, style: .plain)
            tableView.translatesAutoresizingMaskIntoConstraints = false
            tableView.backgroundColor = .clear
            //tableView.isScrollEnabled = false
            self.tableView = tableView
            container.addSubview(tableView)
            Cartography.constrain(self.view, container, top!, tableView, block: { (
                superview: Cartography.ViewProxy
                , container: Cartography.ViewProxy
                , top: Cartography.ViewProxy
                , tableView: Cartography.ViewProxy
                ) in
                
                tableView.left == container.left
                tableView.top == top.bottom
                tableView.right == container.right
                tableView.bottom == container.bottom
            })
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
            label.text = "Loading failed...\nSomething went wrong, try it again."
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
        
        self.navigationItem.title = self.viewModel.item.name
        
        self.loadingOverlayView.alpha = 0.0
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(.init(nibName: "RepositoryDetailCell", bundle: .none), forCellReuseIdentifier: "RepositoryDetailCell")
        self.tableView.rowHeight = 60
        
        self.nameLabel.text = self.viewModel.item.name
        self.sizeLabel.text = String(self.viewModel.item.size)
        self.stargazersLabel.text = String(self.viewModel.item.starsCount)
        self.forksCountLabel.text = String(self.viewModel.item.forksCount)
        
        self.disposables += self.viewModel
            .loadingState
            .producer
            .observe(on: QueueScheduler.main)
            .startWithValues({ [weak self] (state: ViewModel.Repository.Detail.LoadingState) in
                guard let selfStrong = self else {
                    return
                }
                switch state {
                case .unknown:
                    selfStrong.contributorsCountLabel.text = "-"
                    selfStrong.loadingOverlayView.alpha = 0.0
                    selfStrong.errorOverlayView.alpha = 1.0
                case .loaded(let data):
                    selfStrong.contributorsCountLabel.text = String(data.count)
                    selfStrong.tableView.isHidden = false
                    selfStrong.loadingOverlayView.alpha = 0.0
                    selfStrong.errorOverlayView.alpha = 0.0
                    selfStrong.tableView.reloadData()
                case .loading:
                    selfStrong.contributorsCountLabel.text = "-"
                    selfStrong.tableView.isHidden = true
                    selfStrong.loadingOverlayView.alpha = 1.0
                    selfStrong.errorOverlayView.alpha = 0.0
                    selfStrong.navigationItem.title = .none
                case .failed:
                    selfStrong.contributorsCountLabel.text = "-"
                    selfStrong.tableView.isHidden = true
                    selfStrong.loadingOverlayView.alpha = 0.0
                    selfStrong.errorOverlayView.alpha = 1.0
                    selfStrong.navigationItem.title = nil
                }
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
    
    internal override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = self.viewModel.item.name
    }
    
    //  MARK: UITableViewDataSource
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.viewModel.loadingState.value {
        case .loaded(let data):
            return data.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: RepositoryDetailCell = tableView.dequeueReusableCell(withIdentifier: "RepositoryDetailCell") as? RepositoryDetailCell else {
            fatalError()
        }
        
        guard let data: RepositoryDetailCellModelProtocol = self.viewModel.retrieveCellData(at: indexPath) else {
            return cell
        }
        cell.configure(with: data)
        
        return cell
    }
    
    //  MARK: UITableViewDelegate
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
}
