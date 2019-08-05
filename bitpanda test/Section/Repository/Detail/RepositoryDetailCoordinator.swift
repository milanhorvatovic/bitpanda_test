//
//  RepositoryDetailCoordinator.swift
//  bitpanda test
//
//  Created by Milan Horvatovic on 05/08/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation

import Swinject

internal protocol RepositoryDetailCoordinatorProtocol: CoordinatorProtocol {
    
}

internal protocol RepositoryDetailCoordinatorDelegate: class {
    
    func requestClose(_ coordinator: RepositoryDetailCoordinatorProtocol)
    
}

extension Coordinator.Repository {
    
    internal final class Detail: Coordinator.Navigation, RepositoryDetailCoordinatorProtocol {
        
        internal weak var delegate: RepositoryDetailCoordinatorDelegate?
        
        private let data: Model.Service.Search.Item
        
        internal init(with diContainer: Swinject.Container, navigation navigationController: UINavigationController, item: Model.Service.Search.Item) {
            self.data = item
            
            super.init(with: diContainer, navigation: navigationController)
        }
        
        internal override func start() {
            super.start()
            let viewController: RepositoryDetailViewController<ViewModel.Repository.Detail> = .init(with: .init(service: self.diContainer.resolve(Service.Manager.self)!, item: self.data))
            viewController.delegate = self
            self.viewController = viewController
            self.navigationController.pushViewController(viewController, animated: true)
        }
        
    }
    
}

extension Coordinator.Repository.Detail: RepositoryDetailViewControllerDelegate {
    
    internal func requestClose(_ viewController: RepositoryDetailViewControllerProtocol) {
        self.delegate?.requestClose(self)
    }
    
}
