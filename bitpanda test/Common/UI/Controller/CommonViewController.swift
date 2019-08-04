//
//  CommonViewController.swift
//  bitpanda_test
//
//  Created by Milan Horvatovic on 05/08/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation
import UIKit

import ReactiveSwift

internal class CommonViewController<ViewModelType>: UIViewController where ViewModelType: ViewModelProtocol {
    
    internal var disposables: CompositeDisposable
    
    internal let viewModel: ViewModelType
    
    internal init(with viewModel: ViewModelType) {
        self.disposables = .init()
        
        self.viewModel = viewModel
        
        super.init(nibName: .none, bundle: .none)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("This allocation form is permitted!")
    }
    
    deinit {
        self.disposables.dispose()
    }
    
    internal override func loadView() {
        super.loadView()
        
        self.view.backgroundColor = .white
    }
    
}
