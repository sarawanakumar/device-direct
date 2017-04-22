//
//  Contract.swift
//  DeviceDirect
//
//  Created by kumarsaravana on 9/26/16.
//  Copyright © 2016 ibm. All rights reserved.
//

import Foundation
import CoreData

@objc(Contract)
class Contract: NSManagedObject {
    @NSManaged var id: Int
    @NSManaged var employee_name: String
    @NSManaged var employee_id: String
    @NSManaged var to_team: String
    @NSManaged var device_id: Int
    @NSManaged var authorized_by: String
    @NSManaged var contracted_on: Date
    @NSManaged var returned_on: Date?
    
    
    class func getContractById(_ id: Int) -> Contract? {
        var contract: Contract!
        let predicate = NSPredicate(format: "id == %@", String(id))
        let result = dataController.fetchFromPersistentStore("Contract", withPredicate: predicate) as! [Contract]
        contract = result.first
        return contract
    }
    
    class func createNewContract(_ completion: (_ data: Contract)->()) {
        let contract = dataController.createManagedObject("Contract") as! Contract
        completion(contract)
    }
    
    class func getNewContractId() -> Int {
        let topContract = dataController.fetchSortedDataFromPersistentStore("Contract", withPredicate: nil, sortAttribute: "id", byAscending: false, fetchLimit: 1)
        if topContract.count > 0 {
            return (topContract.first!.value(forKey: "id") as! Int)+1
        }
        return 35000
    }
}
