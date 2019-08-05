//
//  ModelServiceSearchItem.swift
//  bitpanda test
//
//  Created by Milan Horvatovic on 05/08/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation

extension Model.Service.Search {
    
    internal struct Item: Codable {
        
        internal let identifier: Int
        internal let owner: Model.Service.User
        internal let name: String
        internal let fullName: String
        internal let createdAt: Date
        internal let size: Int
        internal let starsCount: Int
        internal let forksCount: Int
        
        internal let contributorsUrlValue: String
        
        private enum CodingKeys: String, CodingKey {
            
            case identifier = "id"
            case owner
            case name
            case fullName = "full_name"
            case createdAt = "created_at"
            case size
            case starsCount = "stargazers_count"
            case forksCount = "forks_count"
            case contributorsUrlValue = "contributors_url"
            
        }
        
    }
    
}

extension Model.Service.Search.Item {
    
    internal var contributorsUrl: URL? {
        get {
            guard case false = self.contributorsUrlValue.isEmpty else {
                return .none
            }
            return URL(string: self.contributorsUrlValue)
        }
    }
    
}

extension Model.Service.Search.Item: Equatable {
    
    internal static func == (lhs: Model.Service.Search.Item, rhs: Model.Service.Search.Item) -> Bool {
        return lhs.identifier == rhs.identifier
            && lhs.owner == rhs.owner
            && lhs.name == rhs.name
            && lhs.fullName == rhs.fullName
            && lhs.createdAt == rhs.createdAt
            && lhs.size == rhs.size
            && lhs.starsCount == rhs.starsCount
            && lhs.forksCount == rhs.forksCount
            && lhs.contributorsUrlValue == rhs.contributorsUrlValue
    }
    
}

extension Model.Service.Search.Item: Hashable {
    
    internal func hash(into hasher: inout Hasher) {
        hasher.combine(self.identifier)
        hasher.combine(self.owner)
        hasher.combine(self.fullName)
        hasher.combine(self.createdAt)
        hasher.combine(self.size)
        hasher.combine(self.starsCount)
        hasher.combine(self.forksCount)
        hasher.combine(self.contributorsUrlValue)
    }
    
}
