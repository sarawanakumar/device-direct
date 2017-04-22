//
//  Device.swift
//  DeviceDirect
//
//  Created by kumarsaravana on 8/22/16.
//  Copyright © 2016 ibm. All rights reserved.
//

import Foundation
import CoreData

enum DeviceFilter: Int16 {
    case available = 0
    case inUse = 1
    case inRepair = 2
    case inContract = 3
}

@objc(Device)
class Device: NSManagedObject {
    @NSManaged var device_status: Int16
    @NSManaged var id: Int
    @NSManaged var model: String?
    @NSManaged var os_version: String?
    @NSManaged var type: String?
    @NSManaged var accreditation_id: Int
    @NSManaged var udid: String
    @NSManaged var owned_by: String
    @NSManaged var contract_id: Int
    @NSManaged var active: Bool
    //@NSManaged var accreditation: Accreditation?
    
    class func createDevice(_ comletion: (_ data: Device)->()) {
        let dev = dataController.createManagedObject("Device") as! Device
        comletion(dev)
    }
    
    class func createDefaultDevice() {
        createDevice { device in
        device.device_status = 0
        device.id = 1111
        device.model = "iPad Air 2"
        device.type = "Pad"
        device.os_version = "10.1"
        }
        createDevice { device1 in
        device1.device_status = 0
        device1.id = 2222
        device1.model = "iPhone 6S"
        device1.type = "Phone"
        device1.os_version = "10.2"
           /* Employee.createEmployee { employee in
                employee.id = "9999"
                employee.industry = "telco"
                employee.manager = "ram"
                employee.name = "logi"
                employee.project = "fastfix"
                let aSet = NSSet(array: [device1])
                employee.devices = aSet
                device1.held_by = employee
            }*/
        }
        
        createDevice { device2 in
        device2.device_status = 2
        device2.id = 3333
        device2.model = "iPad Air"
        device2.type = "Pad"
        device2.os_version = "10.3"
        }
        dataController.saveToPersistentStore { errMsg in
            
        }
    }
    
    class func getDevices(filteredBy filter: DeviceFilter?) -> [Device]? {
        var deviceData = [Device]()
        
        if let vFilter = filter {
            let fetchPredicate = NSPredicate(format: "device_status == %@ AND active == true", String(vFilter.rawValue))
            deviceData = dataController.fetchFromPersistentStore("Device", withPredicate: fetchPredicate) as! [Device]
        }
        else {
            let fetchPredicate = NSPredicate(format: "active == true")
            deviceData = dataController.fetchFromPersistentStore("Device", withPredicate: fetchPredicate) as! [Device]
        }
        return deviceData
    }
    
    class func getDeviceById(_ deviceId: Int) -> Device? {
        var device: Device?
        let fetchPredicate = NSPredicate(format: "id == %@", String(deviceId))
        let deviceData = dataController.fetchFromPersistentStore("Device", withPredicate: fetchPredicate) as! [Device]
        if deviceData.count > 0 {
            device = deviceData.first
        }
        return device
    }
    
    func updateDeviceWithVersion(_ version: String, andOwner owner: String = currentUser!.userName!) -> () {
        self.os_version = version
        self.owned_by = owner
        //dataController.saveToPersistentStore()
    }
    
    func deviceExistsWithId(_ deviceId: Int) -> Bool {
        var exists = false
        if let _ = Device.getDeviceById(deviceId) {
            exists = true
        }
        return exists
    }
    
    func changeDeviceStatus(_ toStatus: DeviceFilter, completion: @escaping (String?)->()) {
        self.device_status = toStatus.rawValue
        dataController.saveToPersistentStore { msg in
            completion(msg)
        }
    }
    
    func matchesWith(_ text: String) -> Bool {
        var match = false
        let text = text.lowercased()
        let scope = String(describing: DeviceFilter(rawValue: device_status)!)
        let dev_id = String(id)
        match = match || (model?.lowercased().contains(text))!
        match = match || (type?.lowercased().contains(text))!
        match = match || (os_version?.contains(text))!
        match = match || scope.lowercased().contains(text)
        match = match || dev_id.contains(text)
        match = match || owned_by.lowercased().contains(text)
        match = match || udid.contains(text)
        return match
    }
    
    class func getDeviceCount(inType filter: DeviceFilter?) -> Int {
        return getDevices(filteredBy: filter)?.count ?? 0
    }
    
    class func removeDevice(withId id: Int, completion: (_ data: Bool)->()) {
        if let device = Device.getDeviceById(id) {
        //    dataController.managedObjectContext.deleteObject(device)
            device.active = false
            completion(true)
            return
        }
        completion(false)
    }
    
    class func getDeviceWithIds(_ devList: [Int]) -> [Device] {
        var result = [Device]()
        let devListString = devList.map { String($0) }
        let fetchPredicate = NSPredicate(format: "id IN %@", devListString)
        result = dataController.fetchFromPersistentStore("Device", withPredicate: fetchPredicate) as! [Device]
        return result
    }
    
    class func deviceModelForId(_ devId: Int) -> String? {
        let fetchPredicate = NSPredicate(format: "id == %@", String(devId))
        let device = dataController.fetchFromPersistentStore("Device", withPredicate: fetchPredicate)
        if device.count > 0 {
            return device.first?.value(forKey: "model") as? String
        }
        return nil
    }
    
    func mapDeviceModel(withDevices devArray: [[String: AnyObject]]) -> () {
        for devDict in devArray {
            Device.createDevice{ (data) in
                data.id = devDict["id"] as! Int
                data.device_status = devDict["device_status"] as! Int16
                data.model = devDict["model"] as? String
                data.os_version = devDict["os_version"] as? String
                data.type = devDict["type"] as? String
                data.accreditation_id = devDict["accreditation_id"] as! Int
                data.udid = devDict["udid"] as! String
                data.owned_by = devDict["owned_by"] as! String
                data.contract_id = devDict["contract_id"] as! Int
            }
        }
        //dataController.saveToPersistentStore()
    }
    
    func mapDeviceModel(withDevice device: [String: AnyObject]) -> () {
        Device.createDevice{ (data) in
            data.id = device["id"] as! Int
            data.device_status = device["device_status"] as! Int16
            data.model = device["model"] as? String
            data.os_version = device["os_version"] as? String
            data.type = device["type"] as? String
            data.accreditation_id = device["accreditation_id"] as! Int
            data.udid = device["udid"] as! String
            data.owned_by = device["owned_by"] as! String
            data.contract_id = device["contract_id"] as! Int
        }
        //dataController.saveToPersistentStore()
    }
    
    func mapDeviceEntity(forJson json: [String: AnyObject]) -> () {
        Device.createDevice { (data) in
            let cdAttributes = data.entity.attributesByName
            for attr in cdAttributes.keys {
                if let val = json[attr],
                let type = cdAttributes[attr]?.attributeType {
                    if type == NSAttributeType.stringAttributeType && val.isKind(of: NSNumber.self) {
                        data.setValue(String(describing: val), forKey: attr)
                    }
                    else  if (type == NSAttributeType.integer16AttributeType || type == .integer32AttributeType) && (val.isKind(of: NSString.self)) {
                           data.setValue(Int(val as! String), forKey: attr)
                    }
                    else if type == NSAttributeType.floatAttributeType && val.isKind(of: NSString.self) {
                        data.setValue(Double(val as! String), forKey: attr)
                    }
                    else if type == .booleanAttributeType && val.isKind(of: NSString.self) {
                        data.setValue(Bool(val as! NSNumber), forKey: attr)
                    }
                    else if type == NSAttributeType.dateAttributeType && val.isKind(of: NSString.self) {
                        //NEED TO IMPLEMENT FOR DATE
                    }
                    else {
                        data.setValue(val, forKey: attr)
                    }
                }
            }
            //dataController.saveToPersistentStore()
        }
    }
        
}
