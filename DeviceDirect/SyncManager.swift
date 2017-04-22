//
//  SyncManager.swift
//  DeviceDirect
//
//  Created by kumarsaravana on 1/4/17.
//  Copyright © 2017 ibm. All rights reserved.
//

import Foundation
import CoreData

//COMMON
enum OperationResult {
    case success
    case failed(String)
    case unknown
}

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case delete = "DELETE"
    case head = "HEAD"
}

enum AppOperation: String {
    case api = "Api"
    case map = "Map"
    case reverseMap = "RevMap"
    case syncComplete = "SyncComplete"
}

var currentUser: User?
struct User {
    private var _usr: String?
    private var _loggedIn: Bool = false
    private var _authToken: String?
    
    var userName: String? {
        return self._usr
    }
    var authenticated: Bool {
        return self._loggedIn
    }
    var authToken: String? {
        return self._authToken
    }
    
    init(_ user: String, _ token: String) {
        self._usr = user
        self._authToken = token
        self._loggedIn = true
    }
}

typealias OperationResponse = (_ data: Any?, _ error: Error?)->()
typealias EndPointResponse = (_ data: Any?, _ error: Error?, _ status: Int?)->()

let syncCompletedNotification = Notification.Name(rawValue: "SYNC_COMPLETED")

let devDirectSession = {
    return URLSession(configuration: URLSessionConfiguration.default)
}()

//CLASS
class ServiceManager {
    
    //1.prepare for the calls
    //2.Make the calls
    //3.Map to core data
    
    //Each api call in server should correspond to an instance method in this class. To call an api, invoke respective method, with the entity enum
    //This class also include custom operations like initialSync
    
    static let shared = ServiceManager()
    
    private init() {}
    
    private var syncQueue: OperationQueue? = {
        let queue = OperationQueue()
        queue.name = "syncQ"
        queue.maxConcurrentOperationCount = 3
        return queue
    }()
    
    //API User: /user/login
    func login(with username: String, and password: String, completion: @escaping EndPointResponse) -> () {
        let credentials = ["username": username, "password": password]
        if let credData = try? JSONSerialization.data(withJSONObject: credentials, options: .prettyPrinted) {
            let loginOp = APIOperation(.users, path: "/Users/login", method: .post)
            loginOp.body = credData
            loginOp.completionBlock = {
                completion(loginOp.responsePayload, loginOp.responseError, loginOp.responseStatus)
            }
            
            loginOp.start()
        }
        else {
            //:TODO no cred
        }
    }
    
    func logout(completion: @escaping EndPointResponse) {
        let logoutOp = APIOperation(.users, path: "/Users/logout", method: .post)
        logoutOp.completionBlock = {
            completion(nil,nil,logoutOp.responseStatus)
        }
        logoutOp.start()
    }
    
    //Initial Sync operation Custom
    func performInitialSyncOperation(with blockingIndicator: BlockingUIIndicatorView) {
        //Delete Coredata before sync
        deleteAllData()
        
        //Add Download and Map operations 1by1 and start the queue
        var syncOperations = [Operation]()
        let completion = CompletionOperation(blockingIndicator)
        for entity in Entities.enumerate() {
            let downloadOperation = APIOperation(entity, path: entity.getDefaultResourcePath(), method: .get)
            let mapOperation = MapOperation(entity)
            mapOperation.addDependency(downloadOperation)
            completion.addDependency(mapOperation)
            syncOperations.append(contentsOf: [downloadOperation, mapOperation])
        }
        syncQueue?.addOperations(syncOperations, waitUntilFinished: false)
        syncQueue?.addOperation(completion)
    }
    
    //API:get
    func getEntities(_ entity: Entities, completion: @escaping (OperationResult)->()) {
        let downloadOperation = APIOperation(entity, path: entity.getResourcePath(), method: .get)
        downloadOperation.completionBlock = {
            completion(self.parseResponse(downloadOperation.responsePayload, downloadOperation.responseError, downloadOperation.responseStatus))
        }
        downloadOperation.start()
    }
    
    func getEntitiesAndMap(_ entity: Entities, completion: @escaping (OperationResult)->()) {
        let downloadOperation = APIOperation(entity, path: entity.getResourcePath(), method: .get)
        downloadOperation.completionBlock = {
            completion(self.parseResponse(downloadOperation.responsePayload, downloadOperation.responseError, downloadOperation.responseStatus))
        }
        
        let mapOperation = MapOperation(entity)
        mapOperation.addDependency(downloadOperation)
        
        let opQueue = OperationQueue()
        opQueue.addOperation(downloadOperation)
        opQueue.addOperation(mapOperation)
    }
    
    //API: exists
    func entityExists(_ entity: Entities, with id: String, completion: @escaping (Bool)->()) {
        let rscPath = "\(entity.getResourcePath())/\(id)/exists"
        let uniqueEntityIdOp = APIOperation(entity, path: rscPath, method: .get)
        
        uniqueEntityIdOp.completionBlock = {
            if let dict = uniqueEntityIdOp.responsePayload as? [String:AnyObject],
                let exists = dict["exists"] as? Bool {
                completion(exists)
                return
            }
            completion(true)
        }
        uniqueEntityIdOp.start()
    }
    
    func customPostOnEntity(_ entity: Entities, action: String, with data: NSManagedObject, completion: @escaping (OperationResult)->()) -> () {
        let path = "\(entity.getResourcePath())/\(action)"
        //Post Operation and its completion
        let postOperation = APIOperation(entity, path: path, method: .post)
        postOperation.completionBlock = {
            completion(self.parseResponse(postOperation.responsePayload, postOperation.responseError, postOperation.responseStatus))
        }
        
        //Reverse Map the data to json, convert to data,
        let revMapOperation = ReverseMapOperation(entity, data: [data])
        revMapOperation.delegate = postOperation
        
        postOperation.addDependency(revMapOperation)
        
        //Queue
        let queue = OperationQueue()
        queue.addOperation(revMapOperation)
        queue.addOperation(postOperation)
    }
    
    //API: post (single entity)
    func postEntity(_ entity: Entities, with data: NSManagedObject, completion: @escaping (OperationResult)->()) {
        //Post Operation and its completion
        let postOperation = APIOperation(entity, path: entity.getResourcePath(), method: .post)
        postOperation.completionBlock = {
            completion(self.parseResponse(postOperation.responsePayload, postOperation.responseError, postOperation.responseStatus))
        }
        
        //Reverse Map the data to json, convert to data,
        let revMapOperation = ReverseMapOperation(entity, data: [data])
        revMapOperation.delegate = postOperation
        
        postOperation.addDependency(revMapOperation)
        
        //Queue
        let queue = OperationQueue()
        queue.addOperation(revMapOperation)
        queue.addOperation(postOperation)
    }
    
    //API: patch
    func patchEntity(_ entity: Entities, having id: String, with data: [String:AnyObject], completion: @escaping (OperationResult)->()) {
        let path = "\(entity.getResourcePath())/\(id)"
        let patchOp = APIOperation(entity, path: path, method: .patch)
        patchOp.body = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        patchOp.completionBlock = {
            completion(self.parseResponse(patchOp.responsePayload, patchOp.responseError, patchOp.responseStatus))
        }
        patchOp.start()
    }
    
    //Instance helpers
    private func deleteAllData() {
        for entity in Entities.enumerate() {
            dataController.deleteAllData(entity.rawValue)
        }
    }
    
    private func parseResponse(_ data: Any?, _ error: Error?, _ status: Int?) -> OperationResult {
        var result = OperationResult.unknown
        if let e = error {
            result = .failed(e.localizedDescription)
        }
        else if let st = status,
            (st != 200) && (st != 201) {
            result = .failed("Server Response \(st)")
        }
        else if let _ = data {
            result = .success
        }
        return result
    }
}


//When sync completed
class CompletionOperation: Operation {
    let activityIndicatorView: BlockingUIIndicatorView
    init(_ indicator: BlockingUIIndicatorView) {
        self.activityIndicatorView = indicator
    }
    override func main() {
        dataController.saveToPersistentStore { (msg) in
            //Update the UI by notification
            NotificationCenter.default.post(name: syncCompletedNotification, object: nil, userInfo: ["indicator":self.activityIndicatorView, "error":msg as Any])
        }
    }
}



