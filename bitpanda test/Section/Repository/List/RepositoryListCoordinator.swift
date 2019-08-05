//
//  RepositoryListCoordinator.swift
//  bitpanda test
//
//  Created by Milan Horvatovic on 05/08/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation

internal protocol RepositoryListCoordinatorProtocol: CoordinatorProtocol {
    
}

internal protocol RepositoryListCoordinatorDelegate: class {
    
    func request(_ coordiantor: RepositoryListCoordinatorProtocol, openDetail data: Model.Service.Search.Item)
    
}

extension Coordinator.Repository {
    
    internal final class List: Coordinator.Navigation, RepositoryListCoordinatorProtocol {
        
        internal weak var delegate: RepositoryListCoordinatorDelegate?
        
        internal override func start() {
            super.start()
            guard let viewController: RepositoryListViewController<ViewModel.Repository.List> = self.diContainer.resolve(RepositoryListViewController<ViewModel.Repository.List>.self) else {
                fatalError()
            }
            viewController.delegate = self
            self.viewController = viewController
            self.navigationController.viewControllers = [viewController]
        }
        
    }
    
}

extension Coordinator.Repository.List: RepositoryListViewControllerDelegate {
    
    func request(_ viewController: RepositoryListViewControllerProtocol, openDetail data: Model.Service.Search.Item) {
        self.delegate?.request(self, openDetail: data)
    }
    
}
