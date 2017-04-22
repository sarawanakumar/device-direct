//
//  EmployeeDataController.swift
//  DeviceDirect
//
//  Created by Devika  Devaraju on 23/10/16.
//  Copyright © 2016 ibm. All rights reserved.
//

import Foundation
class EmployeeDataController {
    var id: String?
    var industry: String?
    var manager: String?
    var name: String?
    var project: String?
    var accreditations: [Int]?
    var active: Bool?
    var email: String?
    
    func updateEmployee(with data: [String:AnyObject], completion: @escaping ResponseStatus) {
        ServiceManager.shared.patchEntity(.employee, having: id!, with: data) { result in
            DataController.processResult(result) { (res, msg) in
                completion(res, msg)
            }
        }
    }
    
    func deleteEmployee(_ completion: @escaping ResponseStatus) {
        
        ServiceManager.shared.patchEntity(.employee, having: "\(self.id!)", with: ["active": false as AnyObject]) { (result) in
            if case OperationResult.success = result {
                Employee.deleteEmployeeWithId(self.id!) {_ in
                    DataController.processResult(result) { (res, msg) in
                        completion(res, msg)
                    }
                }
            }
            else {
                dataController.context.reset()
                DataController.processResult(result) { (res, msg) in
                    completion(res, msg)
                }
            }
        }
    }
    
    func createAndSaveEmployee(completion: @escaping ResponseStatus ){
        Employee.createEmployee { (emp) in
            emp.name = name ?? "NO_VALUE"
            emp.id = id ?? "NO_VALUE"
            emp.project = project
            emp.industry = industry
            emp.active = true
            emp.email_id = self.email
            ServiceManager.shared.postEntity(.employee, with: emp) { (result) in
                DataController.processResult(result) { (res, msg) in
                    completion(res, msg)
                }
            }
        }
    }

    class func getAllEmployeeDetails(_ completion: @escaping ResponseStatus) {
        ServiceManager.shared.getEntitiesAndMap(.employee) { (result) in
            DataController.processResult(result) { (res, msg) in
                completion(res, msg)
            }
        }
    }
}
