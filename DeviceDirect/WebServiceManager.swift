//
//  WebServiceManager.swift
//  DeviceDirect
//
//  Created by kumarsaravana on 10/9/16.
//  Copyright © 2016 ibm. All rights reserved.
//

import Foundation

enum RequestType {
    case get
    case post
    case put
    case delete
    case PATCH
}

let serviceManager = WebServiceManager()

typealias ServiceResponse = ( _ data: AnyObject?, _ error: NSError?) -> ()

protocol ServiceResponseDelegate {
    func responseForRequest(_ request: URLRequest, withData data: AnyObject?, error: NSError?) -> ()
}

class WebServiceManager {
    
    var baseURL = "http://localhost:3000/api"
    var delegate: ServiceResponseDelegate?
    
    func fetchRequest(_ path: String, forDataDict dataDict: [String: AnyObject]? = [String: AnyObject](), requestType type: RequestType = .get, completion: @escaping ServiceResponse) {
        let url = baseURL + path
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        if let requestURL = URL(string: url) {
            var request = URLRequest(url: requestURL)
            request.httpMethod = String(describing: type)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let dict = dataDict , type != .get {
                do {
                    let data = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.prettyPrinted)
                    request.httpBody = data
                }
                catch {
                    print("fatal error while parsing JSON")
                }
            }
            let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
                if let error = error {
                    completion(nil, error as NSError?)
                }
                else if let response = response as? HTTPURLResponse
                {
                    if response.statusCode == 404 {
                        completion(nil, nil)
                    }
                    else if response.statusCode == 200,
                        let data = data {
                        do {
                            let data = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                            completion(data as AnyObject?, nil)
                        }
                        catch {
                            print("fatal error while parsing DATA")
                        }
                    }
                }
                else {
                    print("Print some other errors")
                }
            }) 
            task.resume()
        }
        
    }
    
    func bulkPost(_ path: String, forDataDict dataDict: [[String: AnyObject]]? , requestType type: RequestType = .post, completion: @escaping ServiceResponse) {
        let url = baseURL + path
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        if let requestURL = URL(string: url) {
            var request = URLRequest(url: requestURL)
            request.httpMethod = String(describing: type)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let dict = dataDict , type != .get {
                do {
                    let data = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.prettyPrinted)
                    print(NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String)
                    request.httpBody = data
                }
                catch {
                    print("fatal error while parsing JSON")
                }
            }
            let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
                if let error = error {
                    completion(nil, error as NSError?)
                }
                else if let response = response as? HTTPURLResponse
                {
                    if response.statusCode == 404 {
                        completion(nil, nil)
                    }
                    else if response.statusCode == 200,
                        let data = data {
                        do {
                            let data = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                            completion(data as AnyObject?, nil)
                        }
                        catch {
                            print("fatal error while parsing DATA")
                        }
                    }
                }
                else {
                    print("Print some other errors")
                }
            }) 
            task.resume()
        }
        
    }
}
