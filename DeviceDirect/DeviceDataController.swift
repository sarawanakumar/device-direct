//
//  DeviceServiceManager.swift
//  DeviceDirect
//
//  Created by kumarsaravana on 10/16/16.
//  Copyright © 2016 ibm. All rights reserved.
//

import Foundation
typealias ResponseStatus = (_ success: Bool, _ errorMessage: String?)->Void
class DeviceDataController {
    
    //Device properties
    var deviceId: Int?
    var deviceType: String?
    var deviceModel: String?
    var deviceUdid: String?
    var deviceVersion: String?
    var deviceOwnedBy: String?
    var active: Bool?
    
    func isDeviceIdUnique(_ devId: Int, completion: @escaping (_ unique: Bool)->()) -> () {
        if Device.getDeviceById(devId) == nil {
            ServiceManager.shared.entityExists(.device, with: "\(devId)") { (exists) in
                completion(!exists)
            }
        }
        else {
            completion(false)
        }
    }
    
    func createAndSaveNewDevice(_ completion:@escaping (_ success: Bool, _ errorMessage: String?)->Void) -> () {
        Device.createDevice { newDevice in
            newDevice.device_status = DeviceFilter.available.rawValue
            
            newDevice.id = self.deviceId!
            newDevice.udid = self.self.deviceUdid!
            newDevice.os_version = self.deviceVersion!
            newDevice.type = self.deviceType
            newDevice.model = self.deviceModel
            newDevice.owned_by = self.deviceOwnedBy ?? "Unowned"
            newDevice.active = true
            
            //perform post, if success save or discard
            ServiceManager.shared.postEntity(.device, with: newDevice) { (result) in
                DataController.processResult(result) { (res, msg) in
                    completion(res, msg)
                }
            }
            /*dataController.saveToPersistentStore()
            completion(true, nil)*/
        }
    }
    
    func updateDeviceDetails(_ device: Device, completion: @escaping ResponseStatus) {
        let bodyDict = ["os_version": self.deviceVersion! as AnyObject, "owned_by": self.deviceOwnedBy! as AnyObject]
        ServiceManager.shared.patchEntity(.device, having: "\(self.deviceId!)", with: bodyDict) { (result) in
            if case OperationResult.success = result {
                device.updateDeviceWithVersion(self.deviceVersion!, andOwner: self.deviceOwnedBy!)
            }
            DataController.processResult(result) { (res, msg) in
                completion(res, msg)
            }
        }
    }
    
    func removeDevice(_ completion: @escaping ResponseStatus) {
        ServiceManager.shared.patchEntity(.device, having: "\(self.deviceId!)", with: ["active": false as AnyObject]) { (result) in
            if case OperationResult.success = result {
                Device.removeDevice(withId: self.deviceId!) { (data) in
                    DataController.processResult(result) { (res, msg) in
                        completion(res, msg)
                    }
                }
            }
        }
    }
    
    func updateDeviceStatus(bodyDict: [String: AnyObject], completion: @escaping ResponseStatus) {
        //  let bodyDict = ["device_status": Int(status.rawValue) ]
        //serviceManager.fetchRequest("/Devices/\(self.deviceId!)", forDataDict: bodyDict, requestType: .PATCH) { (data, error) in
        ServiceManager.shared.patchEntity(.device, having: "\(self.deviceId!)", with: bodyDict) { (result) in
            DataController.processResult(result) { (res, msg) in
                completion(res, msg)
            }
        }
    }
    
    class func getAllDeviceDetails(_ completion: @escaping ResponseStatus) {
        ServiceManager.shared.getEntitiesAndMap(.device) { (result) in
        //serviceManager.fetchRequest("/Devices") { (data, error) in
            DataController.processResult(result) { (res, msg) in
                completion(res, msg)
            }
        }
    }
}
