//
//  DeviceModelTypeDataController.swift
//  DeviceDirect
//
//  Created by Niranjana Devi on 05/11/16.
//  Copyright © 2016 ibm. All rights reserved.
//

import Foundation

class DeviceModelTypeDataController
{
    var device_model: String?
    var device_type: String?

    
//    class func getAllDeviceModelType(_ completion: @escaping ResponseStatus) {
//        serviceManager.fetchRequest("/DeviceModelTypes") { (data, error) in
//            if let error = error {
//                
//                completion(false, error.localizedDescription)
//            }
//            else {
//                let deviceModels = data as! [[String: AnyObject]]
//                DataController.mapEntities(forJson: deviceModels, type: Entities.deviceModelType)
//                completion(true, nil)
//            }
//        }
//    }
    
    func saveDeviceModel(_ completion: @escaping ResponseStatus) {
        DeviceModelType.createDeviceModel { (deviceModel) in
            deviceModel.device_type = self.device_type!
            deviceModel.device_model = self.device_model!
            ServiceManager.shared.postEntity(.deviceModelType, with: deviceModel) { (result) in
                DataController.processResult(result) { (res, msg) in
                    completion(res, msg)
                }
            }
        }
        
    }
}
