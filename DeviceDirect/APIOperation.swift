//
//  APIOperation.swift
//  DeviceDirect
//
//  Created by Saravanakumar S on 15/01/17.
//  Copyright © 2017 ibm. All rights reserved.
//

import Foundation
import CoreData

protocol OperationObserverDelegate: class {
    func operationCompleted(_ op: AppOperation, data: Data?, error: Error?)
}

class APIOperation: ConcurrentOperation, OperationObserverDelegate {
    
    private let baseURL = "https://mfssamplecloudfoundryapp.mybluemix.net/api"
    //private let baseURL = "http://0.0.0.0:3000/api"
    
    var resourcePath: String
    var method: String
    var intendedEntity: Entities
    var body: Data?
    var responsePayload: Any?
    var responseError: Error?
    var responseStatus: Int?
    
    var delegate:OperationObserverDelegate?
    
    //prop
    var request: URLRequest! {
        if let url = URL(string: location) {
            var req = URLRequest(url: url)
            req.httpMethod = method
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if intendedEntity != .users {
                req.setValue(currentUser!.authToken, forHTTPHeaderField: "Authorization")
            }
            if let b = body {
                req.httpBody = b
            }
            return req
        }
        return nil
    }
    
    var location: String {
        return baseURL + resourcePath
    }
    
    init(_ entity: Entities, path: String, method: HttpMethod, payload: Data? = nil) {
        self.resourcePath = path
        self.method = method.rawValue
        self.intendedEntity = entity
        self.body = payload
    }
    
    override func execute() {
        //prepare a http request object and start the task
        let task = devDirectSession.dataTask(with: request) { (data, response, error) in
            if let d = data, error == nil {
                do {
                    self.responsePayload = try JSONSerialization.jsonObject(with: d, options: JSONSerialization.ReadingOptions.mutableContainers)
                    self.responseError = error
                    self.responseStatus = (response as? HTTPURLResponse)?.statusCode
                }
                catch let error {
                    print(error)
                }
            }
            else {
                print("\(error?.localizedDescription)")
            }
            //self.delegate?.operationCompleted(data: data, error: error)
            self.finish()
        }
        task.resume()
    }
    
    func operationCompleted(_ op: AppOperation, data: Data?, error: Error?) {
        switch op {
        case .reverseMap:
            if let d = data, error == nil {
                self.body = d
            }
        case .map:
            ()
        default:
            ()
        }
    }
}

//A Generic Asynchronous Operation class
class ConcurrentOperation: Operation {
    
    override var isAsynchronous: Bool {
        return true
    }
    
    private var _executing: Bool = false {
        willSet {
            willChangeValue(forKey: "isExecuting")
        }
        didSet {
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    override var isExecuting: Bool {
        return _executing
    }
    
    private var _finished = false {
        willSet {
            willChangeValue(forKey: "isFinished")
        }
        didSet {
            didChangeValue(forKey: "isFinished")
        }
    }
    
    override var isFinished: Bool {
        return _finished
    }
    
    override func start() {
        _executing = true
        execute()
    }
    
    func execute() {
        
    }
    
    func finish() {
        self._executing = false
        self._finished = true
    }
}
