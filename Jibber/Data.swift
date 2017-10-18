//
//  Data.swift
//  Jibber
//
//  Created by Matthew Cheok on 29/1/15.
//  Copyright (c) 2015 Matthew Cheok. All rights reserved.
//

import Cocoa

internal var DataFrameworkVersion = "2.0.0"
internal let DataFrameworkInstallText = "You need to add the Jibber framework to your Xcode project for Jibber to work properly."
internal let DataFrameworkUpdateText = "You need to update the Jibber framework in your Xcode project for Jibber to work properly."
internal let DataPodfileCopyText = "pod 'Jibber-Framework', '~> 2.0.0', :configurations => ['Debug']"

internal let DataDidReceiveNewRequestNotification = "DataDidReceiveNewRequestNotification"
internal let DataDidReceiveNewResponseNotification = "DataDidReceiveNewResponseNotification"
internal let DataDidReceiveNewDeviceNotification = "DataDidReceiveNewDeviceNotification"

internal let DataUserInfoRequestKey  = "DataUserInfoRequestKey"
internal let DataUserInfoResponseKey = "DataUserInfoResponseKey"
internal let DataUserInfoDeviceKey   = "DataUserInfoDeviceKey"

internal let DataRemoteNotificationMethodName  = "NOTE"
internal let DataRemoteNotificationStatusCode  = -100
internal let DataRequestFailureStatusCode      = 0

private let _sharedInstance = JibberData()

class JibberData: NSObject {
    class var sharedInstance: JibberData {
        return _sharedInstance
    }

    fileprivate let devices = NSMapTable<AnyObject, AnyObject>.strongToStrongObjects()
    fileprivate let requests = NSMapTable<AnyObject, AnyObject>.strongToStrongObjects()
    fileprivate let responses = NSMapTable<AnyObject, AnyObject>.strongToStrongObjects()
    
    func allDevices() -> [Device] {
        if let array = devices.keyEnumerator().allObjects as? [Device] {
            return array
        }
        else {
            return []
        }
    }
    
    func lastUpdatedForDevice(_ device: Device) -> Date? {
        return devices.object(forKey: device) as? NSDate as! Date
    }
    
    func recordLastUpdatedForDevice(_ device: Device) {
        let firstSeen = devices.object(forKey: device) == nil
        devices.setObject(Date() as AnyObject, forKey: device)
        
        if firstSeen {
            let userInfo: [String: AnyObject] = [
                DataUserInfoDeviceKey: device
            ]
            NotificationCenter.default.post(name: Notification.Name(rawValue: DataDidReceiveNewDeviceNotification), object: nil, userInfo: userInfo)
        }
    }
    
    func hasRecentlyConnectedForDevice(_ device: Device) -> Bool {
        if let date = lastUpdatedForDevice(device) {
            if Date().timeIntervalSince(date) < 7 {
                return true
            }
        }
        return false
    }
    
    func clearDataForDevice(_ device: Device) {
        requests.setObject([AnyObject]() as AnyObject, forKey: device)
        responses.setObject([AnyObject]() as AnyObject, forKey: device)
    }
    
    func addRequest(_ request: Request, forDevice device: Device) {
        recordLastUpdatedForDevice(device)
        
        var changed = false
        if var array = requests.object(forKey: device) as? [Request] {
            if !array.contains(request) {
                array.append(request)
                requests.setObject(array as AnyObject, forKey: device)
                changed = true
            }
        }
        else {
            let request = [AnyObject]() as AnyObject
            requests.setObject(request, forKey: device)
            changed = true
        }
        
        if changed {
            let userInfo: [String: AnyObject] = [
                DataUserInfoDeviceKey: device,
                DataUserInfoRequestKey: request
            ]
            NotificationCenter.default.post(name: Notification.Name(rawValue: DataDidReceiveNewRequestNotification), object: nil, userInfo: userInfo)
        }
    }
    
    func requestsForDevice(_ device: Device) -> [Request] {
        if let array = requests.object(forKey: device) as? [Request] {
            return array.sorted(by: { (req1, req2) -> Bool in
                return req1.date.compare(req2.date) == .orderedAscending
            }).reversed()
        }
        else {
            return []
        }
    }
    
    func clearRequest(_ request: Request, forDevice device: Device) {
        if var array = requests.object(forKey: device) as? [Request] {
            if let index = array.index(of: request) {
                array.remove(at: index)
            }
            requests.setObject(array as AnyObject, forKey: device)
        }
        
        if var array = responses.object(forKey: device) as? [Response] {
            let matchingResponses = array.filter { (response) -> Bool in
                return response.uuid == request.uuid
            }
            
            if let response = matchingResponses.first {
                if let index = array.index(of: response) {
                    array.remove(at: index)
                }
            }
            responses.setObject(array as AnyObject, forKey: device)
        }
    }
    
    func addResponse(_ response: Response, forDevice device: Device) {
        recordLastUpdatedForDevice(device)
        
        var changed = false
        if var array = responses.object(forKey: device) as? [Response] {
            if !array.contains(response) {
                array.append(response)
                responses.setObject(array as AnyObject, forKey: device)
                changed = true
            }
        }
        else {
            let response = [AnyObject]() as AnyObject
            responses.setObject(response, forKey: device)
            changed = true
        }
        
        if changed {
            let userInfo: NSDictionary = [
                DataUserInfoDeviceKey: device,
                DataUserInfoResponseKey : response
            ]
            NotificationCenter.default.post(name: Notification.Name(rawValue: DataDidReceiveNewResponseNotification), object: nil, userInfo: userInfo as! [AnyHashable: Any])
        }
    }
    
    func responseForRequest(_ request: Request, inDevice device: Device) -> Response? {
        if let array = responses.object(forKey: device) as? [Response] {
            let matchingResponses = array.filter { (response) -> Bool in
                return response.uuid == request.uuid
            }

            if let response = matchingResponses.first {
                return response
            }
        }
        return nil
    }
    
    func iconPathForBundleIdentifier(_ bundleId: String) -> NSString? {
        if bundleId.utf16.count == 0 {
            return nil
        }
        
        let directories = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        if let cachePath = directories.first {
            let folder = cachePath + Bundle.main.bundleIdentifier!
            let path = folder + (bundleId + "/png")
            return path as NSString
        }
        
        return nil
    }
    
    func iconURLForBundleIdentifier(_ bundleId: String) -> URL? {
        if let path = iconPathForBundleIdentifier(bundleId) as? String {
            if FileManager.default.fileExists(atPath: path) {
                return URL(fileURLWithPath: path as String)
            }
        }

        return nil
    }
    
    func saveIcon(_ temporaryPath: NSString, forBundleIdentifier bundleId: NSString) {
        if let path = iconPathForBundleIdentifier(bundleId as String) as? String {
            let folder = (path as NSString).deletingLastPathComponent
            if !FileManager.default.fileExists(atPath: folder) {
                do {
                    try FileManager.default.createDirectory(atPath: folder, withIntermediateDirectories: true, attributes: nil)
                } catch _ {
                }
            }
            
            if FileManager.default.fileExists(atPath: path) {
                do {
                    try FileManager.default.removeItem(atPath: path)
                } catch _ {
                }
            }
            do {
                try FileManager.default.copyItem(atPath: temporaryPath as String, toPath: path)
            } catch _ {
            }
        }
    }
    
    func saveIconData(_ JibberData: Foundation.Data, forBundleIdentifier bundleId: NSString) {
        if let path = iconPathForBundleIdentifier(bundleId as String) as? String {
            let folder = (path as NSString).deletingLastPathComponent
            if !FileManager.default.fileExists(atPath: folder) {
                do {
                    try FileManager.default.createDirectory(atPath: folder, withIntermediateDirectories: true, attributes: nil)
                } catch _ {
                }
            }
            
            if FileManager.default.fileExists(atPath: path) {
                do {
                    try FileManager.default.removeItem(atPath: path)
                } catch _ {
                }
            }

            try? JibberData.write(to: URL(fileURLWithPath: path), options: [.atomic])
        }
    }
}
