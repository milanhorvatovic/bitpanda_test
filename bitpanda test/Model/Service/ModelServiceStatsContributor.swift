//
//  ModelServiceStatsContributor.swift
//  bitpanda test
//
//  Created by Milan Horvatovic on 05/08/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation

extension Model.Service.Stats {
    
    internal struct Contributor: Codable {
        
        internal let total: Int
        internal let author: Model.Service.User
        
    }
    
}

extension Model.Service.Stats.Contributor: Equatable {
    
    internal static func == (lhs: Model.Service.Stats.Contributor, rhs: Model.Service.Stats.Contributor) -> Bool {
        return lhs.total == rhs.total
            && lhs.author == rhs.author
    }
    
}
