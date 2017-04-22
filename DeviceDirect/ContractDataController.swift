//
//  ContractDataController.swift
//  DeviceDirect
//
//  Created by Devika  Devaraju on 24/10/16.
//  Copyright © 2016 ibm. All rights reserved.
//

import Foundation

class ContractDataController
{
    var id: Int?
    var employee_name: String?
    var employee_id: String?
    var to_team: String?
    var device_id: Int?
    var authorized_by: String?
    var contracted_on: Date?
    var returned_on: Date?
    
    var deviceController = DeviceDataController()
    
    
    func addContract(_ completion:@escaping (_ success: Bool, _ errorMessage: String?)->Void) {
        Contract.createNewContract({ (newContract) in
            let device = Device.getDeviceById(self.device_id!)
            device?.device_status = DeviceFilter.inContract.rawValue
            device?.contract_id = self.id!
            
            newContract.id = self.id!
            newContract.to_team = self.to_team!
            newContract.employee_name = self.employee_name!
            newContract.employee_id = self.employee_id!
            newContract.authorized_by = self.authorized_by!
            newContract.device_id = self.device_id!
            newContract.contracted_on = Date()
            
            ServiceManager.shared.customPostOnEntity(.contract, action: "add", with: newContract) { (result) in
                DataController.processResult(result) { (res, msg) in
                    completion(res, msg)
                }
            }
        })
    }
    
    func removeContract(_ device: Device?, _ contract: Contract?, completion:@escaping (_ success: Bool, _ errorMessage: String?)->Void)  {
        if let d = device,
            let c = contract {
            c.returned_on = Date()
            d.device_status = DeviceFilter.available.rawValue
            d.contract_id = 0
            
            ServiceManager.shared.customPostOnEntity(.contract, action: "remove", with: c) { (result) in
                DataController.processResult(result) { (res, msg) in
                    completion(res, msg)
                }
            }
        }
    }

    
    func todayDate() ->String
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    class func getAllContractDetails(_ completion: @escaping ResponseStatus) {
        serviceManager.fetchRequest("/Contracts") { (data, error) in
            if let error = error {
                
                completion(false, error.localizedDescription)
            }
            else {
                let contracts = data as! [[String: AnyObject]]
                DataController.mapEntities(forJson: contracts, type: Entities.contract)
                completion(true, nil)
            }
        }
    }

}
