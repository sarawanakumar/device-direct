//
//  DeviceType.swift
//  DeviceDirect
//
//  Created by Devika  Devaraju on 21/10/16.
//  Copyright © 2016 ibm. All rights reserved.
//

import Foundation
import CoreData

@objc(DeviceModelType)

class DeviceModelType: NSManagedObject {
    @NSManaged var device_type: String
    @NSManaged var device_model: String
    
    class func createDeviceModel(_ comletion: (_ data: DeviceModelType)->()) {
        let deviceModel = dataController.createManagedObject("DeviceModelType") as! DeviceModelType
        comletion(deviceModel)
    }
    
    
    class func getDeviceModel(_ type: String) -> [String]? {
        var filteredDeviceModel: [String] = []
        let fetchPredicate = NSPredicate(format: "device_type == %@", type)
        let res = dataController.fetchFromPersistentStore("DeviceModelType", withPredicate: fetchPredicate) as! [DeviceModelType]
        for i in 0 ..< res.count
        {
            filteredDeviceModel.append((res[i].value(forKey: "device_model") as? String)!)
        }
        if res.count > 0 {
            return filteredDeviceModel
        }
        return nil
    }
    
    class func createDefaultDeviceType() -> () {
        
        DeviceModelType.createDeviceModel { (deviceModel) in
            deviceModel.device_type = "Pad"
            deviceModel.device_model = "iPad Mini"
        }
        
        DeviceModelType.createDeviceModel { (deviceModel) in
            deviceModel.device_type = "Pad"
            deviceModel.device_model = "iPad Air"
        }
        
        DeviceModelType.createDeviceModel { (deviceModel) in
            deviceModel.device_type = "Pad"
            deviceModel.device_model = "iPad Air 2"
        }
        
        DeviceModelType.createDeviceModel { (deviceModel) in
            deviceModel.device_type = "Pad"
            deviceModel.device_model = "iPad Pro"
        }
        
        DeviceModelType.createDeviceModel { (deviceModel) in
            deviceModel.device_type = "Phone"
            deviceModel.device_model = "iPhone 5S"
        }
        
        DeviceModelType.createDeviceModel { (deviceModel) in
            deviceModel.device_type = "Phone"
            deviceModel.device_model = "iPhone 6"
        }
        
        DeviceModelType.createDeviceModel { (deviceModel) in
            deviceModel.device_type = "Phone"
            deviceModel.device_model = "iPhone 6S"
        }
        
        DeviceModelType.createDeviceModel { (deviceModel) in
            deviceModel.device_type = "Phone"
            deviceModel.device_model = "iPhone 7"
        }

        
        DeviceModelType.createDeviceModel { (deviceModel) in
            deviceModel.device_type = "Watch"
            deviceModel.device_model = "iWatch 2.0"
        }
        
        
        dataController.saveToPersistentStore { (err) in
            
        }
    }


}
