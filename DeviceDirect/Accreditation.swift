//
//  Accreditation.swift
//  DeviceDirect
//
//  Created by kumarsaravana on 8/25/16.
//  Copyright © 2016 ibm. All rights reserved.
//

import Foundation
import CoreData

@objc(Accreditation)
class Accreditation: NSManagedObject {
    @NSManaged var id: Int
    @NSManaged var accredited_on: Date?
    @NSManaged var returned_on: Date?
    @NSManaged var active: Bool
    @NSManaged var authorized_by: String
    @NSManaged var device_id: Int
    @NSManaged var employee_id: String
    @NSManaged var with_cord: Bool
    //@NSManaged var employee: Employee
    //@NSManaged var device: Device
    
    class func createAccreditation(_ completion: (_ data: Accreditation)->()) {
        let accreditation = dataController.createManagedObject("Accreditation") as! Accreditation
        completion(accreditation)
    }
    
    class func getAccreditation(withId id: Int) -> Accreditation? {
        let predicate = NSPredicate(format: "id == %@", String(id))
        let accreditations = dataController.fetchFromPersistentStore("Accreditation", withPredicate: predicate) as! [Accreditation]
        return accreditations.first ?? nil
    }
    
    /*class func addAccreditation(forDevice device: Device, withEmployee employee: Employee, completion: ()->()) {
        Accreditation.createAccreditation { (acc) in
            acc.id = 10001
            acc.accredited_on = NSDate()
            acc.active = true
            acc.authorized_by = "DeviceAdmin"
            acc.device = device
            acc.employee = employee
            var allAccs = acc.employee.accreditations?.allObjects
            allAccs?.append(acc)
            acc.employee.accreditations = NSSet(array: allAccs!)
            
            dataController.saveToPersistentStore()
            completion()
        }
    }*/
//    class func addAccreditation(forDevice device: Device, withEmployee employee: Employee, withCord: Bool, completion: ResponseStatus) {
//        let id = Accreditation.getNewAccreditationId()
//        
//        Accreditation.createAccreditation { (acc) in
//            acc.id = id
//            acc.accredited_on = NSDate()
//            acc.active = true
//            acc.authorized_by = "DeviceAdmin"
//            acc.device_id = device.id
//            acc.employee_id = employee.id
//            acc.with_cord = withCord
//            if let _ = employee.accreditations {
//                employee.accreditations?.append(acc.id)
//            }
//            else {
//                employee.accreditations = [acc.id]
//            }
//            
//            device.accreditation_id = acc.id
//            device.device_status = DeviceFilter.InUse.rawValue
//            
//            dataController.saveToPersistentStore()
//            completion(success: true, errorMessage: nil)
//        }
//    }
    
    /*class func removeAccreditation(havingId accId: Int, completion: ()->()) {
        if let acc = Accreditation.getAccreditation(withId: String(accId)) {
            acc.returned_on = NSDate()
            acc.active = false
            acc.device.accreditation = nil
            let allAccs = acc.employee.accreditations?.allObjects
            let accr = allAccs?.filter({$0 as! Accreditation != acc})
            acc.employee.accreditations = NSSet(array: accr!)
            
            dataController.saveToPersistentStore()
        }
    }*/
//    class func removeAccreditation(havingId accId: Int, completion: ()->()) {
//        if let acc = Accreditation.getAccreditation(withId: accId) {
//            let device = Device.getDeviceById(acc.device_id)
//            let employee = Employee.getEmployeeById(acc.employee_id)
//            acc.returned_on = NSDate()
//            acc.active = false
//            device?.device_status = DeviceFilter.Available.rawValue
//            device?.accreditation_id = -1
//            employee?.accreditations = employee?.accreditations?.filter { $0 != acc.id }
//            
//            dataController.saveToPersistentStore()
//            completion()
//        }
//    }
//    
    class func getNewAccreditationId() -> Int {
        /*let allAccs = dataController.fetchFromPersistentStore("Accreditation") as! [Accreditation]
        var accId = 10000
        for acc in allAccs {
            if acc.id > accId {
                accId = acc.id
            }
        }
        let aaccId = allAccs.sort({>})
        return accId+1*/
        if let data = getListOfAccredIds().sorted(by: >).first {
            return data + 1
        }
        
        return 10000
    }
    
    class func getAllAccreditations(byAscending ascending: Bool = true) -> [Accreditation] {
        let allAccs = dataController.fetchSortedDataFromPersistentStore("Accreditation", sortAttribute: "accredited_on", byAscending: ascending) as? [Accreditation]
        //let allAccs = dataController.fetchFromPersistentStore("Accreditation") as? [Accreditation]
        if allAccs != nil {
            return allAccs!
        }
        else {
            return [Accreditation]()
        }
    }
    
    class func getAccreditationDictionary() -> (accreditationDict: [Int:Accreditation],deviceList: [Int],empList: [String]) {
        var accreditationDict = [Int:Accreditation]()
        var devList = [Int]()
        var emplList = [String]()
        let allAccs = dataController.fetchFromPersistentStore("Accreditation") as? [Accreditation]
        if let accs = allAccs {
            for acc in accs {
                accreditationDict[acc.id] = acc
                devList.append(acc.device_id)
                emplList.append(acc.employee_id)
            }
        }
        return (accreditationDict, devList, emplList)
    }
    
    class func getListOfAccredIds() -> [Int] {
        var accList = [Int]()
        let rawAccs = dataController.fetchFromPersistentStore("Accreditation")
        /*for acc in rawAccs {
            accList.append(acc.valueForKey("id") as! String)
        }*/
        if rawAccs.count > 0 {
            accList = rawAccs.map { $0.value(forKey: "id") as! Int }
        }
        return accList
    }
    
    class func accreditationModelMapper(_ allAccreditations: [Accreditation]) -> [String:[AccreditationModel]] {
     //   let allAccreditations = Accreditation.getAllAccreditations(byAscending: false)
        let deviceList = Array(Set(allAccreditations.map { $0.device_id }))
        let empList = Array(Set(allAccreditations.map { $0.employee_id }))
        
        let devicesForAccreditation = Device.getDeviceWithIds(deviceList)
        let employeesForAccreditation = Employee.getEmployeeWithIds(empList)
        var accreditationDictionary = [String:[AccreditationModel]]()
        for acc in allAccreditations {
            let accreditedDate = getFormattedDateString(fromDate: acc.accredited_on!)
            
            var model = AccreditationModel()
            model.accId = acc.id
            if let ret = acc.returned_on {
                model.retDate = getFormattedDateString(fromDate: ret)
            }
            else {
                model.retDate = nil
            }
            let dev = devicesForAccreditation.filter { $0.id == acc.device_id }.first
            model.devModel = dev?.model
            model.devId = dev?.id
            model.model = dev?.type
            let emp = employeesForAccreditation.filter { $0.id == acc.employee_id }.first
            model.empName = emp?.name
            model.empId = emp?.id
            //accModel.append(model)
            if let _ = accreditationDictionary[accreditedDate] {
                accreditationDictionary[accreditedDate]?.append(model)
            }
            else {
                accreditationDictionary[accreditedDate] = [AccreditationModel]()
                accreditationDictionary[accreditedDate]?.append(model)
            }
        }
        /*for acc in allAccreditations {
            var model = AccreditationModel()
            model.accId = acc.id
            model.accreditation = acc
            model.device = devicesForAccreditation.filter { $0.accreditation_id == acc.id }.first
            model.employee = employeesForAccreditation.filter { ($0.accreditations?.contains(acc.id))! }.first
            accModel.append(model)
        }*/
        return accreditationDictionary
    }
    
    class func fetchTopAccreditations() -> [Accreditation]? {
        let predicate = NSPredicate(format: "returned_on == nil")
        let result = dataController.fetchSortedDataFromPersistentStore("Accreditation", withPredicate: predicate, sortAttribute: "accredited_on", byAscending: false, fetchLimit: 10) as? [Accreditation]
        
        //return result?.filter { $0.returned_on == nil }
        return result
    }
}
