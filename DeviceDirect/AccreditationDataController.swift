//
//  AccreditationDataController.swift
//  DeviceDirect
//
//  Created by Devika  Devaraju on 24/10/16.
//  Copyright © 2016 ibm. All rights reserved.
//

import Foundation

class AccreditationDataController {
    var id: Int?
    var accredited_on: String?
    var returned_on: Date?
    var active: Bool?
    var authorized_by: String?
    var device_id: Int?
    var employee_id: String?
    var with_cord: Bool?
   
    
    
    class func todayDate() -> String
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: Date())
    }

    func addAccreditation(forDevice device: Device, withEmployee employee: Employee, withCord: Bool, completion: @escaping ResponseStatus)
    {
        Accreditation.createAccreditation { (acc) in
            acc.id = self.id!
            acc.accredited_on = Date()
            acc.active = self.active!
            acc.authorized_by = self.authorized_by!
            acc.device_id = self.device_id!
            acc.employee_id = self.employee_id!
            acc.with_cord = self.with_cord!
            
            device.accreditation_id = acc.id
            device.device_status = DeviceFilter.inUse.rawValue
            
            if let _ = employee.accreditations {
                employee.accreditations?.append(acc.id)
            }
            else {
                employee.accreditations = [acc.id]
            }
            
            ServiceManager.shared.customPostOnEntity(.accreditation, action: "add", with: acc) {
                (result) in
                DataController.processResult(result) { (res, msg) in
                    completion(res, msg)
                }
            }
            
        }
    }
    
    class func removeAccreditation(havingId accId: Int, completion: @escaping ResponseStatus)
    {
        if let acc = Accreditation.getAccreditation(withId: accId) {
            let device = Device.getDeviceById(acc.device_id)
            let employee = Employee.getEmployeeById(acc.employee_id)
            acc.returned_on = Date()
            acc.active = false
            device?.device_status = DeviceFilter.available.rawValue
            device?.accreditation_id = -1
            employee?.accreditations = employee?.accreditations?.filter { $0 != acc.id }
            
            //perform op.
            ServiceManager.shared.customPostOnEntity(.accreditation, action: "remove", with: acc) {
                (result) in
                DataController.processResult(result) { (res, msg) in
                    completion(res, msg)
                }
            }
        }
        else {
            completion(false, "No data found")
        }
    }
    
    class func getAllAccreditationDetails(_ completion: @escaping ResponseStatus) {
        serviceManager.fetchRequest("/Accreditations") { (data, error) in
            if let error = error {
                
                completion(false, error.localizedDescription)
            }
            else {
                let accreditations = data as! [[String: AnyObject]]
                DataController.mapEntities(forJson: accreditations, type: Entities.accreditation)
                completion(true, nil)
            }
        }
    }

}
