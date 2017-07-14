//
//  DeviceReaderViewController.swift
//  DeviceDirect
//
//  Created by kumarsaravana on 9/18/16.
//  Copyright © 2016 ibm. All rights reserved.
//

import UIKit
import AVFoundation

class DeviceReaderViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var sender: AnyObject?
    var isNewDeviceMode = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //session obj creation
        captureSession = AVCaptureSession()
        
        //set input device for capture
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        //input object
        let videoInput: AVCaptureDeviceInput!
        
        do {
            videoInput = try AVCaptureDeviceInput(device: captureDevice!)
        }
        catch {
            //FOR DEMO
            //let trimmedCode = "8973428"
            //performResultantAction(forCode: trimmedCode)
            
            //Actual Code
            unableToPerformScanning()
            return
        }
        
        //giving input to the session
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }
        else {
            unableToPerformScanning()
        }
        
        //giving o/p to the session
        let metaDataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metaDataOutput) {
            captureSession.addOutput(metaDataOutput)
            
            metaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            //metaDataOutput.metadataObjectTypes = [AVMetadataObjectTypeEAN13Code]
            metaDataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.ean8]
        }
        else {
            unableToPerformScanning()
        }
        
        //layer preview
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        alertsManager.parentController = self
        
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopSession()
    }
    
    func unableToPerformScanning() -> () {
        alertsManager.presentInformationAlert("Scanning cannot be performed", title: "Scanning Failure") {
            self.navigateToHome()
        }
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if let code = metadataObjects.first {
            let readableCode = code as? AVMetadataMachineReadableCodeObject
            if let readable = readableCode,
                let value = readable.stringValue {
                let code = readingSuccessfulWithCode(value)
                performResultantAction(forCode: code)
            }
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            captureSession.stopRunning()
        }
    }
    
    func readingSuccessfulWithCode(_ code: String) -> String {
        let trimmedCode = code.trimmingCharacters(in: CharacterSet.whitespaces)
        print("scanned code: \(trimmedCode)")
        
        var trimmedCodeWithoutZero: String!
        if trimmedCode.hasPrefix("0") && trimmedCode.characters.count > 1 {
            trimmedCodeWithoutZero = String(trimmedCode.characters.dropFirst())
        }
        
        return trimmedCode
    }
    
    func performResultantAction(forCode code: String) {
        
        //present the alert and perform action
        let device = Device.getDeviceById(Int(code)!)
        var message: String!
        var title: String!
        let okAlertAction: ((Device)->())?
        if let d = device {
            switch d.device_status {
            case DeviceFilter.available.rawValue:
                title = "Device Available"
                message = "Do you want to accredit this device (\(code))?"
                okAlertAction = accreditDevice
            case DeviceFilter.inUse.rawValue:
                title = "Device in use"
                message = "Do you want to return back this device (\(code))?"
                okAlertAction = addBackDevice
            case DeviceFilter.inRepair.rawValue:
                title = "Device in repair"
                message = "Do you want to add this device to pool (\(code))?"
                okAlertAction = addBackDeviceFromInRepair
            default:
                okAlertAction = nil
            }
            if !isNewDeviceMode {
                alertsManager.presentActionAlert(message, title: title, okAction: {
                    if let action = okAlertAction {
                        self.stopSession()
                        action(d)
                    }
                }, cancelAction: { self.navigateToHome() })
            }
            else {
                captureSession.stopRunning()
                alertsManager.presentActionAlert("Device with Id (\(code)) already exists! Tap OK to Re-Scan.", title: title, okAction: {
                    self.captureSession.startRunning()
                }, cancelAction: { self.navigateToHome() })
            }
            
        }
        else {
            if !isNewDeviceMode {
                alertsManager.presentActionAlert("Do you want add this device (\(code)) to pool?", title: "New Device", okAction: {
                    if let devId = Int(code) {
                        OperationQueue.main.addOperation {
                            self.performSegue(withIdentifier: "addDeviceWithId", sender: devId)
                        }
                    }
                    }, cancelAction: { self.navigateToHome() })
            }
            else {
                if let devId = Int(code) {
                    OperationQueue.main.addOperation {
                        self.performSegue(withIdentifier: "deviceIdScannedSegue", sender: devId)
                    }
                }
            }
        }
    }
    
    func stopSession() -> () {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func accreditDevice(_ device: Device) -> () {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "readerToAccreditationSegue", sender: device)
        }
    }
    
    func addBackDevice(_ device: Device) -> () {
        AccreditationDataController.removeAccreditation(havingId: device.accreditation_id) { (success, message) in
            if success {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "backToHomeFromReader", sender: nil)
                    print("Device Added Back to pool")
                }
            }
            else {
                self.alertWithErrorMessage(message!)
            }
        }

        
    }
    
    
    func addBackDeviceFromInRepair(_ device: Device) -> () {
        device.changeDeviceStatus(DeviceFilter.available) { msg in
            if let m = msg {
                alertsManager.presentLogoutAlert(m)
            }
            else {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "backToHomeFromReader", sender: nil)
                    print("Device status changed to available")
                }
            }
        }
    }
    
    func navigateToHome() -> () {
        stopSession()
        //self.performSegueWithIdentifier("backToHomeFromReader", sender: nil)
        DispatchQueue.main.async(execute: {
            self.navigationController?.popViewController(animated: true)
        })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier , id == "readerToAccreditationSegue",
            let accrController = segue.destination as? AccreditationViewController {
            accrController.title = "Accredit Device"
            accrController.device = sender as? Device
        }
        else if let id = segue.identifier , id == "addDeviceWithId",
            let devDetailsController = segue.destination as? DeviceDetailsTableViewController {
            devDetailsController.sceneScope = .some(DeviceDetailsView.newDevice)
            devDetailsController.deviceController = DeviceDataController()
            devDetailsController.deviceController.deviceId = sender as? Int
            //devDetailsController.deviceId = sender as? Int
            
            //devDetailsController.deviceIdFromScanner = sender as? Int
            devDetailsController.parentController = self
        }
        else if let id = segue.identifier , id == "deviceIdScannedSegue",
            let devDetailsController = segue.destination as? DeviceDetailsTableViewController {
            devDetailsController.sceneScope = .some(DeviceDetailsView.newDevice)
            devDetailsController.deviceController = DeviceDataController()
            devDetailsController.deviceController.deviceId = sender as? Int
            //devDetailsController.deviceId = sender as? Int
            
            //devDetailsController.deviceIdFromScanner = sender as? Int
        }
    }
}
