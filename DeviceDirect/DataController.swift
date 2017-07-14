//
//  DataController.swift
//  DeviceDirect
//
//  Created by kumarsaravana on 8/25/16.
//  Copyright © 2016 ibm. All rights reserved.
//

import Foundation
import CoreData

enum Entities: String {
    case device = "Device"
    case employee = "Employee"
    case accreditation = "Accreditation"
    case contract = "Contract"
    case deviceModelType = "DeviceModelType"
    case users = "Users"
    
    static func enumerate() -> [Entities] {
        return [.device, .employee, .accreditation, .contract, .deviceModelType]
    }
    
    func getResourcePath() -> String {
        switch self {
        case .device:
            return "/devices"
        case .employee:
            return "/employees"
        case .accreditation:
            return "/accreditations"
        case .contract:
            return "/contracts"
        case .deviceModelType:
            return "/DeviceModelTypes"
        case .users:
            return "/Users"
        }
    }
    
    func getDefaultResourcePath() -> String {
        switch self {
        case .device:
            return "/devices?filter[where][active]=true"
        case .employee:
            return "/employees?filter[where][active]=true"
        case .accreditation:
            return "/accreditations"
        case .contract:
            return "/contracts"
        case .deviceModelType:
            return "/DeviceModelTypes"
        case .users:
            return "/Users"
        }
    }
}

enum OptionType {
    case deviceTypes
    case deviceModels(String)
    case industry
    case manager
}

enum DeviceDetailsView {
    case newDevice
    case existingDevice
}

let deviceTypes = ["Pad", "Phone", "Watch"]
let deviceModels = [deviceTypes[0]: ["iPad Mini", "iPad Air", "iPad Air 2", "iPad Pro"], deviceTypes[1]: ["iPhone 5S","iPhone 6", "iPhone 6S", "iPhone 7"], deviceTypes[2]: ["iWatch 2.0", "iWatch 2.2", "iWatch 3.0"]]
let industry = ["Banking", "Insurance", "Retail", "Talent & Change", "Energy & Utility", "Education", "Travel & Transport", "Telco"]
let manager = ["Ramkumar", "Senthil", "Ramesh", "Aparna", "Sankara"]

let dataController = DataController()
let alertsManager = AlertManager()

let DISPATCH_AFTER_500MS = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)

class DataController: NSObject {
    private var managedObjectContext: NSManagedObjectContext
    
    var context: NSManagedObjectContext {
        return self.managedObjectContext
    }
    
    override init() {
        guard let modelUrl = Bundle.main.url(forResource: "DeviceDirect", withExtension: "momd")
            else { fatalError("error in loading data model") }
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelUrl)
            else { fatalError("error in creating managed object model") }
        
        let persistentStoreCoord = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        
        managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoord
        
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
        let urls = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
        let docUrl = urls[urls.endIndex-1]
        let storeUrl = docUrl.appendingPathComponent("DeviceDirect.sqlite")
        do {
            //Important: options to be set for automatic coredata migration of new apps
            let options = [NSMigratePersistentStoresAutomaticallyOption: true,NSInferMappingModelAutomaticallyOption: true]
            try persistentStoreCoord.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeUrl, options: options)
        }
        catch let e as NSError {
            print("fatal error: while migrating store \(e)")
        }
        // }
    }
    
    func createManagedObject(_ name: String) -> NSManagedObject {
        let entityObject = NSEntityDescription.insertNewObject(forEntityName: name, into: self.managedObjectContext)
        return entityObject
    }
    
    func createManagedObject(_ name: String, completion: (_ dataObject: NSManagedObject)->()) {
        let entityObject = NSEntityDescription.insertNewObject(forEntityName: name, into: self.managedObjectContext)
        completion(entityObject)
    }
    
    
    func saveToPersistentStore1() -> Void {
        do {
            if managedObjectContext.hasChanges {
                try self.managedObjectContext.save()
            }
            
        }
        catch let error {
            fatalError("failed to save: \(error.localizedDescription)")
        }
    }
    
    func saveToPersistentStore(completion: (_ errorMessage: String?)->()) -> Void {
        do {
            if managedObjectContext.hasChanges {
                try self.managedObjectContext.save()
            }
            completion(nil)
        }
        catch let error {
            //fatalError("failed to save: \(error.localizedDescription)")
            completion(error.localizedDescription)
        }
    }
    
    func fetchFromPersistentStore(_ entity: String, withPredicate predicate: NSPredicate? = nil) -> [NSManagedObject] {
        let fetchRequest : NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entity)
        if let pred = predicate {
            fetchRequest.predicate = pred
        }
        let fetchedObj: [NSManagedObject]!
        do {
            fetchedObj = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
        }
        catch {
            fatalError("failed to fetch")
        }
        return fetchedObj
    }
    
    func fetchSortedDataFromPersistentStore(_ entity: String, withPredicate predicate: NSPredicate? = nil, sortAttribute keyAttr: String, byAscending ascending: Bool = true, fetchLimit: Int = 0) -> [NSManagedObject] {
        let fromSortDesc = NSSortDescriptor(key: keyAttr, ascending: ascending)
        //let predicate = NSPredicate(format: "returned_on == nil")
        
        
        let fetchRequest : NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entity)
        fetchRequest.sortDescriptors = [fromSortDesc]
        fetchRequest.fetchLimit = fetchLimit
        fetchRequest.predicate = predicate
        
        let fetchedObj: [NSManagedObject]!
        do {
            fetchedObj = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
        }
        catch {
            fatalError("failed to fetch")
        }
        return fetchedObj
    }
    
    func deleteEntityObject(_ entity: String, withPredicate predicate: NSPredicate? = nil) -> Bool {
        var deleteSuccess = false
        let fetchRequest : NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entity)
        
        if let pred = predicate {
            fetchRequest.predicate = pred
        }
        do {
            let fetchObj = try self.managedObjectContext.fetch(fetchRequest)
            if fetchObj.count >= 1 {
                for obj in fetchObj {
                    self.managedObjectContext.delete(obj as! NSManagedObject)
                }
                deleteSuccess = true
            }
        }
        catch {
            fatalError("unable to delete the student object")
        }
        return deleteSuccess
    }
    
    func deleteObject(_ object: NSManagedObject) {
        self.managedObjectContext.delete(object)
    }
    
    func deleteAllData(_ entity: String)
    {
        let ReqVar : NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entity)
        let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: ReqVar)
        do { try managedObjectContext.execute(DelAllReqVar) }
        catch { print(error) }
    }
    
//    class func initializeCoreData(_ completion: @escaping ResponseStatus)
//    {
////        readFileData("/Devices")
////        readFileData("/Employees")
////        readFileData("/DeviceModelTypes")
//        dataController.deleteAllData("Device")
//                dataController.deleteAllData("Employee")
//                dataController.deleteAllData("Accreditation")
//                dataController.deleteAllData("Contract")
//                dataController.deleteAllData("DeviceModelType")
//                
//                DeviceDataController.getAllDeviceDetails(){success,_ in
//                    if success == true{
//                        EmployeeDataController.getAllEmployeeDetails(){success,_ in
//                            if success == true {
//                                AccreditationDataController.getAllAccreditationDetails(){success,_ in
//                                    if success == true {
//                                        ContractDataController.getAllContractDetails(){success,_ in
//                                            if success == true {
//                                                DeviceModelTypeDataController.getAllDeviceModelType(){success,_ in
//                                                    completion(true,nil)
//                                                }
//                                            }
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    }
//        
//                    else
//                    {
//                        completion(false, "Network Error")
//                    }
//        }
//    }



    class func readFileData(_ filepath: String)
    {
        var dataDictArr = [[String:AnyObject]]()
        let basePath = "/Users/niranjanadevi/Desktop"
        var attrib = [String]()
        if let data = try? Data(contentsOf: URL(fileURLWithPath: basePath+filepath+".csv")) {
            var keys = true
            if let content = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                let lines:[String] = content.components(separatedBy: CharacterSet.newlines) as [String]
                print(lines)
                for line in lines {
                    var dataDict = [String:AnyObject]()
                    if keys
                    {
                        attrib = line.components(separatedBy: ",")
                        keys = false
                    }
                    else {
                    if line != "" {
                        let values = line.components(separatedBy: ",")
                        for i in 0 ..< attrib.count {
                            if values[i] != "" {
                            dataDict.updateValue(values[i] as AnyObject, forKey: attrib[i])
                            }
                        }
                        dataDictArr.append(dataDict)
                    }
                    }
                }

            }
        }
        
        serviceManager.bulkPost(filepath, forDataDict: dataDictArr) { (data, error) in
        }
       
    }

    
    class func mapEntities(forJson json: [[String: AnyObject]],type: Entities) -> () {
        for deviceData in json {
            // Device.createDevice { (data) in
            let data = createEntity(type)
            let cdAttributes = data!.entity.attributesByName
            for attr in cdAttributes.keys {
                if let val = deviceData[attr],
                    let type = cdAttributes[attr]?.attributeType {
                    if type == NSAttributeType.stringAttributeType && val.isKind(of: NSNumber.self) {
                        data!.setValue(String(describing: val), forKey: attr)
                    }
                    else  if (type == NSAttributeType.integer16AttributeType || type == .integer32AttributeType) && (val.isKind(of: NSString.self)) {
                        data!.setValue(Int(val as! String), forKey: attr)
                    }
                    else if type == NSAttributeType.floatAttributeType && val.isKind(of: NSString.self) {
                        data!.setValue(Double(val as! String), forKey: attr)
                    }
                    else if type == .booleanAttributeType && val.isKind(of: NSString.self) {
                        data!.setValue(Bool(val as! NSNumber), forKey: attr)
                    }
                    else if type == NSAttributeType.dateAttributeType && val.isKind(of: NSString.self) {
                        //NEED TO IMPLEMENT FOR DATE
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        var date = val as! String
                        date = String(date[date.startIndex...date.characters.index(date.startIndex, offsetBy: 9)])
                        data!.setValue(formatter.date(from: date), forKey: attr)
                    }
                    else {
                        data!.setValue(val, forKey: attr)
                    }
                }
            }
            // }
        }
        dataController.saveToPersistentStore { msg in
            if let e = msg {
                //Throw Logout
            }
        }
    }
    
    class func createEntity(_ type: Entities ) -> NSManagedObject? {
        var modelData: NSManagedObject?
        switch type
        {
        case .device:
            Device.createDevice { (data) in
                modelData = data
                // return data
            }
        case .employee:
            Employee.createEmployee{ (data) in
                modelData = data
            }
        case .accreditation:
            Accreditation.createAccreditation{ (data) in
                modelData = data
            }
        case .contract:
            Contract.createNewContract{ (data) in
                modelData = data
            }
        case .deviceModelType:
            DeviceModelType.createDeviceModel{ (data) in
                modelData = data
            }
        default:
            ()
        }
        return modelData
    }
    
    class func processResult(_ result: OperationResult, completion: @escaping ResponseStatus) -> () {
        switch result {
        case .success:
            dataController.saveToPersistentStore { errMsg in
                if let msg = errMsg {
                    completion(false, msg)
                    return
                }
                completion(true, nil)
            }
        case .failed(let msg):
            dataController.context.reset()
            completion(false, msg)
        case .unknown:
            completion(false,"Unknown error occurred")
        }
    }

}
