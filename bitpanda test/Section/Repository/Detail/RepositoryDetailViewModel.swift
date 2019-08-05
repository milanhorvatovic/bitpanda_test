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

internal protocol RepositoryDetailViewModel: ViewModelProtocol {
    
    var item: Model.Service.Search.Item { get }
    var loadingState: MutableProperty<ViewModel.Repository.Detail.LoadingState> { get }
    
    func reload()
    
    func retrieveCellData(at indexPath: IndexPath) -> RepositoryDetailCellModelProtocol?
    
}

extension ViewModel.Repository {
    
    internal final class Detail: ViewModel.Common, RepositoryDetailViewModel {
        
        fileprivate typealias SelfType = Detail
        
        internal enum LoadingState {
            
            case unknown
            case loading
            case loaded(data: [RepositoryDetailCellModelProtocol])
            case failed
            
        }
        
        fileprivate static let pageSize: Int = 25
        
        private let _lock: NSRecursiveLock = {
            let lock: NSRecursiveLock = .init()
            lock.name = (Bundle.main.bundleIdentifier ?? "") + ".viewModel.repository.detail.lock." + UUID().uuidString
            return lock
        }()
        
        private let service: Service.Manager
        internal let item: Model.Service.Search.Item
        private var data: [Model.Service.Stats.Contributor]?
        internal let loadingState: MutableProperty<LoadingState>
        
        internal init(service: Service.Manager, item: Model.Service.Search.Item) {
            self.service = service
            self.item = item
            self.data = .none
            self.loadingState = .init(.unknown)
            
            super.init()
            
            self._reloadData()
        }
        
        internal func reload() {
            self._reloadData()
        }
        
        internal func retrieveCellData(at indexPath: IndexPath) -> RepositoryDetailCellModelProtocol? {
            return self._safe(in: self._lock, strongify(weak: self, return: .none, closure: { (selfStrong: SelfType) -> RepositoryDetailCellModelProtocol? in
                guard case .loaded(let data) = selfStrong.loadingState.value else {
                    return .none
                }
                guard indexPath.row < data.count else {
                    return .none
                }
                return data[indexPath.row]
            }))
        }
        
        private func _reloadData() {
            self._safe(in: self._lock, strongify(weak: self, closure: { (selfStrong: SelfType) in
                selfStrong.loadingState.swap(.loading)
            }))
            
            self.service.contributors(
                for: self.item
                , strongify(
                    weak: self
                    , closure: { (selfStrong: SelfType, result: Result<[Model.Service.Stats.Contributor]?, AnyError>) in
                        switch result {
                        case .success(let result):
                            guard let result: [Model.Service.Stats.Contributor] = result else {
                                selfStrong._safe(in: selfStrong._lock, {
                                    selfStrong.data = .none
                                    selfStrong.loadingState.swap(.loaded(data: []))
                                })
                                return
                            }
                            selfStrong._safe(in: selfStrong._lock, {
                                selfStrong.data = result
                                let data: [Model.Repository.Detail.Cell] = result
                                    .map({ (object: Model.Service.Stats.Contributor) -> Model.Repository.Detail.Cell in
                                        return .init(with: object)
                                    })
                                selfStrong.loadingState.swap(.loaded(data: data))
                            })
                        case .failure(_):
                            selfStrong._safe(in: selfStrong._lock, {
                                selfStrong.data = .none
                                selfStrong.loadingState.swap(.failed)
                            })
                        }
                })
            )
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
