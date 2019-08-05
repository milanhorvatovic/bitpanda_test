//
//  RepositoryListCoordinator.swift
//  bitpanda test
//
//  Created by Milan Horvatovic on 05/08/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation
import UIKit

import Swinject

internal protocol RepositoryListCoordinatorProtocol: CoordinatorProtocol {
    
}

internal protocol RepositoryListCoordinatorDelegate: class {
    
    func request(_ coordiantor: RepositoryListCoordinatorProtocol, openDetail data: Model.Service.Search.Item)
    
}

extension Coordinator.Repository {
    
    internal final class List: Coordinator.Navigation, RepositoryListCoordinatorProtocol {
        
        internal weak var delegate: RepositoryListCoordinatorDelegate?
        
        internal override init(with diContainer: Swinject.Container, navigation navigationController: UINavigationController) {
            super.init(with: diContainer, navigation: navigationController)
            
            navigationController.delegate = self
        }
        
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
    
    internal func request(_ viewController: RepositoryListViewControllerProtocol, openDetail data: Model.Service.Search.Item) {
        self.delegate?.request(self, openDetail: data)
        
        let coordinator: Coordinator.Repository.Detail = .init(with: self.diContainer, navigation: self.navigationController, item: data)
        coordinator.start()
        self.addChildCoordinator(coordinator)
    }
    
}

extension Coordinator.Repository.List: RepositoryDetailCoordinatorDelegate {
    
    internal func requestClose(_ coordinator: RepositoryDetailCoordinatorProtocol) {
        self.removeChildCoordinator(coordinator)
        guard let viewController: UIViewController = self.viewController else {
            return
        }
        self.navigationController.popToViewController(viewController, animated: true)
    }
    
}

extension Coordinator.Repository.List: UINavigationControllerDelegate {
    
    internal func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard self.viewController == viewController else {
            return
        }
        self.removeAllChildrenCoordinator()
    }
    
}
