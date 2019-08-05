//
//  RepositoryListViewModel.swift
//  bitpanda test
//
//  Created by Milan Horvatovic on 05/08/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation

import Strongify
import Result
import ReactiveSwift

internal protocol RepositoryListViewModel: ViewModelProtocol {
    
    var reloadingState: MutableProperty<ViewModel.Repository.List.LoadingState> { get }
    var loadingState: MutableProperty<ViewModel.Repository.List.LoadingState> { get }
    
    var loadedState: MutableProperty<ViewModel.Repository.List.LoadingState> { get }
    
    func reload()
    func retrieveCellData(at indexPath: IndexPath) -> RepositoryListCellModelProtocol?
    func retrieveData(at indexPath: IndexPath) -> Model.Service.Search.Item?
    
}

extension ViewModel.Repository {
    
    internal final class List: ViewModel.Common, RepositoryListViewModel {
        
        fileprivate typealias SelfType = List
        
        internal enum LoadingState {
            
            case unknown
            case loading
            case loaded(data: [RepositoryListCellModelProtocol])
            case failed
            
        }
        
        fileprivate static let pageSize: Int = 25
        
        private let _lock: NSRecursiveLock = {
            let lock: NSRecursiveLock = .init()
            lock.name = (Bundle.main.bundleIdentifier ?? "") + ".viewModel.repository.list.lock." + UUID().uuidString
            return lock
        }()
        
        private let service: Service.Manager
        private var data: Model.Service.Search.Result?
        internal let reloadingState: MutableProperty<LoadingState>
        internal let loadingState: MutableProperty<LoadingState>
        internal let loadedState: MutableProperty<LoadingState>
        
        internal init(service: Service.Manager) {
            self.service = service
            self.data = .none
            self.reloadingState = .init(.unknown)
            self.loadingState = .init(.unknown)
            self.loadedState = .init(.unknown)
            
            super.init()
            
            self._reloadData()
        }
        
        internal func reload() {
            self._reloadData()
        }
        
        internal func retrieveCellData(at indexPath: IndexPath) -> RepositoryListCellModelProtocol? {
            return self._safe(in: self._lock, strongify(weak: self, return: .none, closure: { (selfStrong: SelfType) -> RepositoryListCellModelProtocol? in
                guard case .loaded(let data) = selfStrong.loadedState.value else {
                    return .none
                }
                guard indexPath.row < data.count else {
                    return .none
                }
                defer {
                    self._safe(in: self._lock, strongify(weak: self, closure: { (selfStrong: SelfType) in
                        if case .loading = selfStrong.loadingState.value {
                        }
                        else if indexPath.row == Int(Double(data.count) * 0.85) {
                            selfStrong._loadNextData()
                        }
                    }))
                }
                return data[indexPath.row]
            }))
        }
        
        internal func retrieveData(at indexPath: IndexPath) -> Model.Service.Search.Item? {
            return self._safe(in: self._lock, strongify(weak: self, return: .none, closure: { (selfStrong: SelfType) -> Model.Service.Search.Item? in
                guard let data: Model.Service.Search.Result = selfStrong.data else {
                    return .none
                }
                guard indexPath.row < data.item.count else {
                    return .none
                }
                return data.item[indexPath.row]
            }))
        }
        
        private func _reloadData() {
            self._safe(in: self._lock, strongify(weak: self, closure: { (selfStrong: SelfType) in
                selfStrong.reloadingState.swap(.loading)
            }))
            
            self.service.page(
                from: 1
                , strongify(
                    weak: self
                    , closure: { (selfStrong: SelfType, result: Result<Model.Service.Search.Result?, AnyError>) in
                        switch result {
                        case .success(let result):
                            guard let result: Model.Service.Search.Result = result else {
                                selfStrong._safe(in: selfStrong._lock, {
                                    selfStrong.data = .none
                                    selfStrong.reloadingState.swap(.loaded(data: []))
                                    selfStrong.loadedState.swap(.loaded(data: []))
                                })
                                return
                            }
                            selfStrong._safe(in: selfStrong._lock, {
                                selfStrong.data = result
                                let data: [Model.Repository.List.Cell] = result
                                    .item
                                    .map({ (object: Model.Service.Search.Item) -> Model.Repository.List.Cell in
                                        return .init(with: object)
                                    })
                                selfStrong.reloadingState.swap(.loaded(data: data))
                                selfStrong.loadedState.swap(.loaded(data: data))
                            })
                        case .failure(_):
                            selfStrong._safe(in: selfStrong._lock, {
                                selfStrong.data = .none
                                selfStrong.reloadingState.swap(.failed)
                                selfStrong.loadedState.swap(.failed)
                            })
                        }
                })
            )
        }
        
        private func _loadNextData() {
            let count: Int = self.data?.totalCount ?? 0
            guard case .loaded(let data) = self.loadedState.value else {
                return
            }
            guard data.count < count else {
                return
            }
            
            self._safe(in: self._lock, strongify(weak: self, closure: { (selfStrong: SelfType) in
                selfStrong.loadingState.swap(.loading)
            }))
            
            let page: Int = (data.count / type(of: self).pageSize) + 1
            
            self.service.page(
                from: page
                , size: type(of: self).pageSize
                , strongify(
                    weak: self
                    , closure: { (selfStrong: SelfType, result: Result<Model.Service.Search.Result?, AnyError>) in
                        switch result {
                        case .success(let result):
                            guard let result: Model.Service.Search.Result = result else {
                                selfStrong._safe(in: selfStrong._lock, {
                                    selfStrong.loadingState.swap(.loaded(data: []))
                                })
                                return
                            }
                            selfStrong._safe(in: selfStrong._lock, {
                                selfStrong.data = selfStrong.data + result
                                let data: [Model.Repository.List.Cell] = result
                                    .item
                                    .map({ (object: Model.Service.Search.Item) -> Model.Repository.List.Cell in
                                        return .init(with: object)
                                    })
                                if case .loaded(let oldData) = selfStrong.loadedState.value {
                                    selfStrong.loadedState.swap(.loaded(data: oldData + data))
                                }
                                else {
                                    selfStrong.loadedState.swap(
                                        .loaded(data: selfStrong.data?
                                            .item
                                            .map({ (object: Model.Service.Search.Item) -> Model.Repository.List.Cell in
                                                return .init(with: object)
                                            })
                                            .unique
                                            ?? []
                                        )
                                    )
                                }
                                selfStrong.loadingState.swap(.loaded(data: data))
                            })
                        case .failure(_):
                            selfStrong._safe(in: selfStrong._lock, {
                                selfStrong.loadingState.swap(.failed)
                            })
                        }
                }))
        }
        
        @discardableResult
        fileprivate func _safe<ValueType>(in lock: NSLocking, _ block: () -> ValueType?) -> ValueType? {
            lock.lock()
            defer {
                lock.unlock()
            }
            return block()
        }
        
    }
    
}
