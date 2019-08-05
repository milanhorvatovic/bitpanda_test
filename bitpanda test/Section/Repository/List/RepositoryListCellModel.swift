//
//  RepositoryListCellModel.swift
//  bitpanda test
//
//  Created by Milan Horvatovic on 05/08/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation

internal protocol RepositoryListCellModelProtocol {
    
    var name: String { get }
    var fullName: String { get }
    var ownerName: String { get }
    var starsCount: Int { get }
    
}

extension Model.Repository {
    
    internal enum List {
        
    }
    
}

extension Model.Repository.List {
    
    internal struct Cell: RepositoryListCellModelProtocol {
        
        internal let name: String
        internal let fullName: String
        internal let ownerName: String
        internal let starsCount: Int
        
    }
    
}

extension Model.Repository.List.Cell {
    
    internal init(with model: Model.Service.Search.Item) {
        self.init(
            name: model.name
            , fullName: model.fullName
            , ownerName: model.owner.login
            , starsCount: model.starsCount
        )
    }
    
}

extension Model.Repository.List.Cell: Hashable {
    
    internal func hash(into hasher: inout Hasher) {
        hasher.combine(self.name)
        hasher.combine(self.fullName)
        hasher.combine(self.ownerName)
        hasher.combine(self.starsCount)
    }
    
}
