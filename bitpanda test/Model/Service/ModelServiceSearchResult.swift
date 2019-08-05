//
//  ModelServiceSearchResult.swift
//  bitpanda test
//
//  Created by Milan Horvatovic on 05/08/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation

extension Model.Service.Search {
    
    internal struct Result: Codable {
        
        internal let totalCount: Int
        internal let item: [Model.Service.Search.Item]
        
        private enum CodingKeys: String, CodingKey {
            
            case totalCount = "total_count"
            case item = "items"
            
        }
        
    }
    
}

extension Model.Service.Search.Result {
    
    internal static func + (lhs: Model.Service.Search.Result, rhs: Model.Service.Search.Result) -> Model.Service.Search.Result {
        return .init(totalCount: max(lhs.totalCount, rhs.totalCount), item: (lhs.item + rhs.item).unique)
    }
    
    internal static func + (lhs: Model.Service.Search.Result?, rhs: Model.Service.Search.Result) -> Model.Service.Search.Result {
        guard let lhs: Model.Service.Search.Result = lhs else {
            return rhs
        }
        return lhs + rhs
    }
    
}

extension Model.Service.Search.Result: Equatable {
    
    internal static func == (lhs: Model.Service.Search.Result, rhs: Model.Service.Search.Result) -> Bool {
        return lhs.totalCount == rhs.totalCount
            && lhs.item == rhs.item
    }
    
}
