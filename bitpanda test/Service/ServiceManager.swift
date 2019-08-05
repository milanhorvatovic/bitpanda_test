//
//  ServiceManager.swift
//  bitpanda_test
//
//  Created by Milan Horvatovic on 05/08/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation

import Result

internal enum Service {
    
    internal class Manager {
        
        struct Endpoint {
            
            let path: String
            let queryItems: [URLQueryItem]
            
        }
        
        internal let session: URLSession
        
        private let delegateQueue: OperationQueue
        
        private var task: [Int: URLSessionTask]
        
        internal init() {
            self.delegateQueue = .init()
            self.delegateQueue.name = (Bundle.main.bundleIdentifier ?? "") + "service.manager.queue.delegate"
            
            let configuration: URLSessionConfiguration = URLSessionConfiguration.default
            self.session = .init(configuration: configuration, delegate: .none, delegateQueue: self.delegateQueue)
            self.task = [:]
        }
        
        internal func cancel(for taskIdentifier: Int) {
            guard let task: URLSessionTask = self.task[taskIdentifier] else {
                return
            }
            task.cancel()
            self.task.removeValue(forKey: taskIdentifier)
        }
        
        fileprivate func _makeRequest<ResponseType>(at request: URLRequest, closure: @escaping (ResponseType?, Error?) -> ()) -> Int where ResponseType: Decodable {
            var taskIdentifier: Int = 0
            let task: URLSessionDataTask = self.session.dataTask(with: request, completionHandler: { [weak self] (data: Data?, response: URLResponse?, error: Error?) in
                defer {
                    self?.task.removeValue(forKey: taskIdentifier)
                }
                guard case .none = error else {
                    closure(.none, error)
                    return
                }
                guard let data: Data = data else {
                    closure(.none, .none)
                    return
                }
                
                do {
                    let decoder: JSONDecoder = .init()
                    decoder.dateDecodingStrategy = .iso8601
                    let response: ResponseType = try decoder.decode(ResponseType.self, from: data)
                    closure(response, .none)
                }
                catch {
                    closure(.none, error)
                }
            })
            taskIdentifier = task.taskIdentifier
            self.task[taskIdentifier] = task
            defer {
                task.resume()
            }
            return task.taskIdentifier
        }
        
        fileprivate func _makeRequest<ResponseType>(at request: URLRequest, closure: @escaping (Result<ResponseType?, AnyError>) -> ()) -> Int where ResponseType: Decodable {
            //print(request)
            var taskIdentifier: Int = 0
            let task: URLSessionDataTask = self.session.dataTask(with: request, completionHandler: { [weak self] (data: Data?, response: URLResponse?, error: Error?) in
                defer {
                    self?.task.removeValue(forKey: taskIdentifier)
                }
                guard case .none = error else {
                    closure(.init(error: .init(error!)))
                    return
                }
                guard let data: Data = data else {
                    closure(.init(.none))
                    return
                }
                
                do {
                    let decoder: JSONDecoder = .init()
                    decoder.dateDecodingStrategy = .iso8601
                    let response: ResponseType = try decoder.decode(ResponseType.self, from: data)
                    closure(.init(response))
                }
                catch {
                    closure(.init(error: .init(error)))
                }
            })
            taskIdentifier = task.taskIdentifier
            self.task[taskIdentifier] = task
            defer {
                task.resume()
            }
            return task.taskIdentifier
        }
        
    }
    
}

extension Service.Manager.Endpoint {

    internal var url: URL? {
        var components: URLComponents = .init()
        components.scheme = "https"
        components.host = "api.github.com"
        components.path = self.path
        components.queryItems = self.queryItems
        
        return components.url
    }
    
}

extension Service.Manager {
    
    private static let dateFormatter: DateFormatter = {
        let formatter: DateFormatter = .init()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()
    
    @discardableResult
    internal func page(from page: Int, size pageSize: Int = 25, _ closure: @escaping (Result<Model.Service.Search.Result?, AnyError>) -> Void) -> Int {
        let endpoint: Endpoint = .init(
            path: "/search/repositories"
            , queryItems: [
                URLQueryItem(name: "q", value: "language:swift")
                , URLQueryItem(name: "page", value: String(page))
                , URLQueryItem(name: "per_page", value: String(pageSize))
            ]
        )
        let request: URLRequest = .init(url: endpoint.url!)
        return self._makeRequest(at: request, closure: closure)
    }
    
    @discardableResult
    internal func contributors(for object: Model.Service.Search.Item, _ closure: @escaping ([Model.Service.User]?, Error?) -> Void) -> Int {
        let request: URLRequest = { (object: Model.Service.Search.Item) -> URLRequest in
            guard let url: URL = object.contributorsUrl else {
                let endpoint: Endpoint = .init(
                    path: "/repos/\(object.fullName)/contributors"
                    , queryItems: []
                )
                return .init(url: endpoint.url!)
            }
            return .init(url: url)
        }(object)
        return self._makeRequest(at: request, closure: closure)
    }
    
}
