//
//  ApplicationCoordinator.swift
//  bitpanda_test
//
//  Created by Milan Horvatovic on 05/08/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation
import UIKit

import Swinject

extension Coordinator {
    
    internal final class Application: Common {
        
        private let window: UIWindow
        
        internal override var viewController: UIViewController? {
            get {
                return self.window.rootViewController
            }
            set {
                self.window.rootViewController = newValue
            }
        }
        
        private lazy var _navigationController: UINavigationController = {
            let navigationController = UINavigationController()
            return navigationController
        }()
        
        internal init(with diContainer: Swinject.Container, window: UIWindow) {
            self.window = window
            
            super.init(with: diContainer)
        }
        
        internal override func start() {
            super.start()
         
            self._showList()
        }
        
        fileprivate func _showList() {
            let coordinator: Coordinator.Repository.List = .init(with: self.diContainer, navigation: self._navigationController)
            self.addChildCoordinator(coordinator)
            coordinator.start()
            self.viewController = coordinator.navigationController
        }
        
    }
    
}
