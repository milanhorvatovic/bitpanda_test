//
//  AppDelegate.swift
//  bitpanda_test
//
//  Created by Milan Horvatovic on 05/08/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import UIKit

import Swinject
import SwinjectAutoregistration

@UIApplicationMain
class AppDelegate: UIResponder {

    fileprivate let diContainer: Swinject.Container
    
    internal var window: UIWindow?
    internal var coordinator: Coordinator.Application?

    internal override init() {
        self.diContainer = .init()
        
        super.init()
    }

}

extension AppDelegate: UIApplicationDelegate {

    internal func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        self.setupDependencies()
        
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        #if DEBUG
        print(NSHomeDirectory())
        #endif
        
        let window: UIWindow = UIWindow()
        let coordinator: Coordinator.Application = .init(with: self.diContainer, window: window)
        coordinator.start()
        self.coordinator = coordinator
        self.window = window
        window.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

extension AppDelegate {
    
    internal func setupDependencies() {
        // services
        self.diContainer.autoregister(Service.Manager.self, initializer: Service.Manager.init)
        
        // viewmodels
        self.diContainer.autoregister(ViewModel.Repository.List.self, initializer: ViewModel.Repository.List.init)
        
        // view controllers
        self.diContainer.register(RepositoryListViewController.self, factory: { (resolver: Swinject.Resolver) -> RepositoryListViewController<ViewModel.Repository.List> in
            return .init(with: resolver.resolve(ViewModel.Repository.List.self)!)
        })
    }
    
}
