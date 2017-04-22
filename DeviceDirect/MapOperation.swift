//
//  MapOperation.swift
//  DeviceDirect
//
//  Created by Saravanakumar S on 15/01/17.
//  Copyright © 2017 ibm. All rights reserved.
//

import Foundation
import CoreData

class MapOperation: Operation {
    var intendedEntity: Entities
    
    init(_ entity: Entities) {
        intendedEntity = entity
    }
    
    override func main() {
        //op :: check for isCancelled before a
        if let downloadOp = self.dependencies.last as? APIOperation {
            if let json = downloadOp.responsePayload as? [[String: AnyObject]] {
                //create entities for the json array
                for object in json {
                    mapEntity(for: object)
                }
            } else if let json = downloadOp.responsePayload as? [String: AnyObject] {
                mapEntity(for: json)
            }
        }
    }
    
    private func createEntity(completion: (_ object: NSManagedObject)->()) -> () {
        completion(NSEntityDescription.insertNewObject(forEntityName: self.intendedEntity.rawValue, into: dataController.context))
    }
    
    private func mapEntity(for jsonObject: [String: AnyObject]) {
        createEntity { (data) in
            let cdAttributes = data.entity.attributesByName
            for attr in cdAttributes.keys {
                if let val = jsonObject[attr],
                    let type = cdAttributes[attr]?.attributeType {
                    if type == NSAttributeType.stringAttributeType && val.isKind(of: NSNumber.self) {
                        data.setValue(String(describing: val), forKey: attr)
                    }
                    else  if (type == NSAttributeType.integer16AttributeType || type == .integer32AttributeType || type == .integer64AttributeType) && (val.isKind(of: NSString.self)) {
                        data.setValue(Int(val as! String), forKey: attr)
                    }
                    else if type == NSAttributeType.floatAttributeType && val.isKind(of: NSString.self) {
                        data.setValue(Double(val as! String), forKey: attr)
                    }
                    else if type == .booleanAttributeType && val.isKind(of: NSString.self) {
                        data.setValue(Bool(val as! NSNumber), forKey: attr)
                    }
                    else if type == NSAttributeType.dateAttributeType && val.isKind(of: NSString.self) {
                        data.setValue(getOptionalDateFromString(fromString: val as! String), forKey: attr)
                    }
                    else if type == NSAttributeType.transformableAttributeType {
                        let array = val as! NSArray
                        var intArray: [Int] = []
                        for item in array{
                            intArray.append((item as! NSString).integerValue)
                        }
                        data.setValue(intArray, forKey: attr)
                    }
                    else {
                        data.setValue(val, forKey: attr)
                    }
                }
            }
        }
    }
}
