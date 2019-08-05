//
//  CommonCoordinator.swift
//  bitpanda_test
//
//  Created by Milan Horvatovic on 05/08/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation
import UIKit

import Swinject

internal protocol CoordinatorProtocol: class {
    
    var diContainer: Swinject.Container { get }
    
    var viewController: UIViewController? { get }
    
    var childCoordinators: [CoordinatorProtocol] { get set }
    
    func start()
    
    func addChildCoordinator(_ childCoordinator: CoordinatorProtocol)
    func removeChildCoordinator(_ childCoordinator: CoordinatorProtocol)
    func removeAllChildrenCoordinator()
}

extension CoordinatorProtocol {
    
    internal func addChildCoordinator(_ childCoordinator: CoordinatorProtocol) {
        self.childCoordinators.append(childCoordinator)
    }
    
    internal func removeChildCoordinator(_ childCoordinator: CoordinatorProtocol) {
        self.childCoordinators = self.childCoordinators.filter { $0 !== childCoordinator }
    }
    
    internal func removeAllChildrenCoordinator() {
        self.childCoordinators.removeAll()
    }
    
}

extension Coordinator {
    
    internal class Common: NSObject, CoordinatorProtocol {
        
        internal let diContainer: Swinject.Container
        
        internal var viewController: UIViewController?
        
        internal var childCoordinators: [CoordinatorProtocol]
        
        internal init(with diContainer: Swinject.Container) {
            self.diContainer = diContainer
            self.childCoordinators = []
        }
        
        internal func start() {
            
        }
        
    }
    
}
