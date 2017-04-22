//
//  Employee.swift
//  DeviceDirect
//
//  Created by kumarsaravana on 8/22/16.
//  Copyright © 2016 ibm. All rights reserved.
//

import Foundation
import CoreData

@objc(Employee)
class Employee: NSManagedObject {
    @NSManaged var id: String
    @NSManaged var industry: String?
    @NSManaged var manager: String?
    @NSManaged var name: String
    @NSManaged var project: String?
    @NSManaged var accreditations: [Int]?
    @NSManaged var active: Bool
    @NSManaged var email_id: String?
    //@NSManaged var accreditations: NSSet?
    
    class func createEmployee(_ comletion: (_ data: Employee)->()) {
        let employee = dataController.createManagedObject("Employee") as! Employee
        comletion(employee)
    }
    
    class func getAllEmployees() -> [Employee]? {
        var empData = [Employee]()
        let pred = NSPredicate(format: "active == true")
        empData = dataController.fetchFromPersistentStore("Employee", withPredicate: pred) as! [Employee]
        
        return empData
    }
    
    class func getEmployeeById(_ employeeId: String) -> Employee? {
        var employee: Employee?
        let fetchPredicate = NSPredicate(format: "id == %@", employeeId)
        let employeeData = dataController.fetchFromPersistentStore("Employee", withPredicate: fetchPredicate) as! [Employee]
        if employeeData.count > 0 {
            employee = employeeData.first
        }
        return employee
    }
    
    class func deleteEmployeeWithId(_ id: String, completion: @escaping (_ data: Bool)->()) -> () {
        if let employee = Employee.getEmployeeById(id) {
            //    dataController.managedObjectContext.deleteObject(device)
            employee.active = false
            completion(true)
            return
        }
        else {
            completion(false)
        }
    }
    
    class func createDefaultEmployee() -> () {
        Employee.createEmployee { (employee) in
            employee.name = "Logesh Balu"
            employee.id = "0689R"
            employee.industry = "Telco"
            employee.project = "Fast Fix"
            employee.manager = "Senthil"
        }
        Employee.createEmployee { (employee) in
            employee.name = "Abinesh Solairaj"
            employee.id = "7089T"
            employee.industry = "Telco"
            employee.project = "Fast Fix"
            employee.manager = "Senthil"
        }
        Employee.createEmployee { (employee) in
            employee.name = "BharathRam C"
            employee.id = "6083W"
            employee.industry = "Banking"
            employee.project = "Open Account"
            employee.manager = "Sudheendra"
            //employee.devices = [Device.getDeviceById("1111")!]
            //employee.dev_count = Int16((employee.devices?.count)!)
        }
        //dataController.saveToPersistentStore()
    }
    
    class func getEmployeeWithIds(_ empList: [String]) -> [Employee] {
        var result = [Employee]()
        let fetchPredicate = NSPredicate(format: "id IN %@", empList)
        result = dataController.fetchFromPersistentStore("Employee", withPredicate: fetchPredicate) as! [Employee]
        return result
    }
    
    class func employeeNameForId(_ empId: String) -> String? {
        let pred = NSPredicate(format: "id == %@", empId)
        let res = dataController.fetchFromPersistentStore("Employee", withPredicate: pred)
        if res.count > 0 {
            return res.first?.value(forKey: "name") as? String
        }
        return nil
    }
    
    class func getAllEmployeeNames() -> [String]? {
        let pred = NSPredicate(format: "active == true")
        let res = dataController.fetchFromPersistentStore("Employee", withPredicate: pred)
        var allEmpName:[String] = []
        for i in 0 ..< res.count
        {
            allEmpName.append((res[i].value(forKey: "name") as? String)!)
        }
        if res.count > 0 {
            return allEmpName
        }
        return nil
    }
    
    func matchesWith(_ text: String) -> Bool {
        var match = false
        match = match || (name.lowercased().contains(text.lowercased()))
        match = match || (id.lowercased().contains(text.lowercased()))
        match = match || (industry?.lowercased().contains(text.lowercased()))!
        return match
    }
}
