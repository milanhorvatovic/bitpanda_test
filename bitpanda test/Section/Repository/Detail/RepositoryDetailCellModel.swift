//
//  RepositoryListCellModel.swift
//  bitpanda test
//
//  Created by Milan Horvatovic on 05/08/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation

internal protocol RepositoryDetailCellModelProtocol {
    
    var avatarUrl: URL? { get }
    var username: String { get }
    var commits: Int { get }
    
}

extension Model.Repository {
    
    internal enum Detail {
        
    }
    
}

extension Model.Repository.Detail {
    
    internal struct Cell: RepositoryDetailCellModelProtocol {
        
        internal let avatarUrl: URL?
        internal let username: String
        internal let commits: Int
        
    }
    
}

extension Model.Repository.Detail.Cell {
    
    internal init(with model: Model.Service.Stats.Contributor) {
        self.init(
            avatarUrl: model.author.avatarUrl
            , username: model.author.login
            , commits: model.total
        )
    }
    
}

extension Model.Repository.Detail.Cell: Hashable {
    
    internal func hash(into hasher: inout Hasher) {
        hasher.combine(self.avatarUrl)
        hasher.combine(self.username)
        hasher.combine(self.commits)
    }
    
}
