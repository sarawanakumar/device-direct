//
//  ReverseMapOperation.swift
//  DeviceDirect
//
//  Created by Saravanakumar S on 15/01/17.
//  Copyright © 2017 ibm. All rights reserved.
//

import Foundation
import CoreData

class ReverseMapOperation: Operation {
    var intendedEntity: Entities
    var managedObject: [NSManagedObject]
    var payload: Data?
    var delegate: OperationObserverDelegate?
    
    init(_ entity: Entities, data: [NSManagedObject]) {
        intendedEntity = entity
        managedObject = data
    }
    
    override func main() {
        if managedObject.count > 1 {
            var json: [[String:AnyObject]] = []
            for obj in managedObject {
                json.append(self.reverseMapEntity(obj))
            }
            if json.count > 0 {
                self.payload = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            }
        }
        else if managedObject.count == 1 {
            let json = self.reverseMapEntity(self.managedObject.first!)
            if json.keys.count > 0 {
                self.payload = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            }
        }
        else {
            //error
        }
        delegate?.operationCompleted(.reverseMap, data: self.payload, error: nil)
    }
    
    func reverseMapEntity(_ object: NSManagedObject) -> [String:AnyObject] {
        var jsonDict: [String:AnyObject] = [:]
        let cdAttributes = object.entity.attributesByName
        for attr in cdAttributes.keys {
            if let type = cdAttributes[attr]?.attributeType {
                if type == NSAttributeType.dateAttributeType {
                    if let date = object.value(forKey: attr) as? Date {
                        jsonDict[attr] = getFormattedDateString(fromDate: date) as AnyObject?
                    }
                    else {
                        jsonDict[attr] = "_" as AnyObject?
                    }
                }
                else if type == NSAttributeType.transformableAttributeType {
                    //need to impl
                    var resultant = NSArray()
                    if let val = object.value(forKey: attr) {
                        resultant = val as! NSArray
                    }
                    jsonDict[attr] = resultant as AnyObject?
                }
                else {
                    jsonDict[attr] = "\(object.value(forKey: attr) ?? "CORE_EMPTY_STRING")" as AnyObject?
                }
            }
        }
        return jsonDict
    }
}
