//
//  ModelServiceUser.swift
//  bitpanda test
//
//  Created by Milan Horvatovic on 05/08/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation

extension Model.Service {
    
    internal struct User: Codable {
        
        internal let identifier: Int
        internal let login: String
        internal let avatarUrlValue: String
        
        private enum CodingKeys: String, CodingKey {
            
            case identifier = "id"
            case login
            case avatarUrlValue = "avatar_url"
            
        }
        
    }
    
}

extension Model.Service.User {
    
    internal var avatarUrl: URL? {
        get {
            guard case false = self.avatarUrlValue.isEmpty else {
                return .none
            }
            return URL(string: self.avatarUrlValue)
        }
    }
    
}

extension Model.Service.User: Equatable {
    
    internal static func == (lhs: Model.Service.User, rhs: Model.Service.User) -> Bool {
        return lhs.identifier == rhs.identifier
            && lhs.login == rhs.login
            && lhs.avatarUrlValue == rhs.avatarUrlValue
    }
    
}

extension Model.Service.User: Hashable {
    
    internal func hash(into hasher: inout Hasher) {
        hasher.combine(self.identifier)
        hasher.combine(self.login)
        hasher.combine(self.avatarUrlValue)
    }
    
}
