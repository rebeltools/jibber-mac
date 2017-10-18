//
//  Server.swift
//  Jibber
//
//  Created by Matthew Cheok on 29/1/15.
//  Copyright (c) 2015 Matthew Cheok. All rights reserved.
//

import Cocoa
import Brotli
import PeerTalk
import GCDWebServer

private let _sharedInstance = Server()

class Server: NSObject {
    class var sharedInstance: Server {
        return _sharedInstance
    }
    
    let webServer = GCDWebServer()
//    let serverSim = PeerTalkServer(connectionType: .Simulator)
//    let serverUsb = PeerTalkServer(connectionType: .USB)
    
    func addRequest(_ jsonObject: AnyObject) -> Bool {
        var iconUploadRequired = false

        var device: Device?
        if let deviceJSON = jsonObject["device"] as? [AnyHashable: Any] {
            device = try? Device(jsonDictionary: deviceJSON)
        }
        
        var request: Request?
        if let requestJSON = jsonObject["request"] as? [AnyHashable: Any] {
            request = try? Request(jsonDictionary:requestJSON)
        }
        
        switch (device, request) {
        case let (.some(device), .some(request)):
            iconUploadRequired = JibberData.sharedInstance.iconURLForBundleIdentifier(device.bundleIdentifier ?? "") == nil
            
            DispatchQueue.main.async(execute: {
                JibberData.sharedInstance.addRequest(request, forDevice: device)
            })
        default:
            ()
        }
        
        return iconUploadRequired
    }
    
    func addResponse(_ jsonObject: AnyObject) {
        var device: Device?
        if let deviceJSON = jsonObject["device"] as? [AnyHashable: Any] {
            device = try? Device(jsonDictionary:deviceJSON)
        }
        
        var response: Response?
        if let responseJSON = jsonObject["response"] as? [AnyHashable: Any] {
            response = try? Response(jsonDictionary: responseJSON)
        }
        
        switch (device, response) {
        case let (.some(device), .some(response)):
            DispatchQueue.main.async(execute: {
                if response.statusCode == -100 {
                    let request = Request()
                    request?.uuid = response.uuid
                    request?.date = response.date
                    request?.method = DataRemoteNotificationMethodName
                    request?.path = ""
                    request?.body = ""
                    
                    JibberData.sharedInstance.addRequest(request!, forDevice: device)
                }
                
                JibberData.sharedInstance.addResponse(response, forDevice: device)
            })
        default:
            ()
        }
    }

    func addHeartbeat(_ jsonObject: AnyObject) {
        var device: Device?
        if let deviceJSON = jsonObject["device"] as? [AnyHashable: Any] {
            device = try? Device(jsonDictionary:deviceJSON)
        }
        
        if let device = device {
            DispatchQueue.main.async {
                JibberData.sharedInstance.recordLastUpdatedForDevice(device)
            }
        }
    }
    
    override init() {
        super.init()
//        
//        serverSim.delegate = self
//        serverUsb.delegate = self
        webServer.addHandler(forMethod: "POST", path: "/requests", request: GCDWebServerDataRequest.self, processBlock: { (req) -> GCDWebServerResponse! in
            
            var iconUploadRequired = false
            if let req = req as? GCDWebServerDataRequest {
                iconUploadRequired = self.addRequest(req.jsonObject as AnyObject)
            }
            
            
            return GCDWebServerDataResponse(jsonObject: [
                "requires-icon-upload": iconUploadRequired,
                "status": "OK"
                ])
        })
        
        webServer.addHandler(forMethod: "POST", path: "/responses", request: GCDWebServerDataRequest.self, processBlock: { (req) -> GCDWebServerResponse! in
            
            if let req = req as? GCDWebServerDataRequest {
                self.addResponse(req.jsonObject as AnyObject)
            }
            
            return GCDWebServerDataResponse(jsonObject: [
                "status": "OK"
                ])
        })
        
        webServer.addHandler(forMethod: "POST", path: "/heartbeat", request: GCDWebServerDataRequest.self, processBlock: { (req) -> GCDWebServerResponse! in
            
            if let req = req as? GCDWebServerDataRequest {
                self.addHeartbeat(req.jsonObject as AnyObject)
            }
            
            return GCDWebServerDataResponse(jsonObject: [
                "status": "OK"
                ])
        })
        
        webServer.addHandler(forMethod: "POST", pathRegex: "/icons/[a-zA-Z0-9\\-\\.]*+", request: GCDWebServerFileRequest.self, processBlock: { (req) -> GCDWebServerResponse! in
            if let req = req as? GCDWebServerFileRequest {
                let bundleIdentifier = req.path.substring(to: req.path.index(req.path.startIndex, offsetBy: 7))
                JibberData.sharedInstance.saveIcon(req.temporaryPath as NSString, forBundleIdentifier: bundleIdentifier as NSString)
                
                print("uploaded icon for bundle id \(bundleIdentifier)")
            }
            
            return GCDWebServerDataResponse(jsonObject: [
                "status": "OK"
                ])
        })
        
        webServer.addDefaultHandler(forMethod: "GET", request: GCDWebServerRequest.self, processBlock:{ request in
            return GCDWebServerDataResponse(jsonObject: [
                "status": "OK"
                ])
        })
        
        do {
            try webServer.start(options: [
                GCDWebServerOption_BonjourType: "_jibber._tcp",
                GCDWebServerOption_BonjourName: "JibberServer"
                ])
        } catch _ {
        }
        
        print("Visit \(webServer.serverURL) in your web browser \(webServer.bonjourName) \(webServer.bonjourType)")
    }
    
//    func peerTalkServer(_ peerTalkServer: PeerTalkServer, didConnectToClient client: String?) {
//        print("client", client)
//    }
//    
//    func peerTalkServer(_ peerTalkServer: PeerTalkServer, didDisconnectFromClient client: String?) {
//        print("disconnect", client)
//    }
//    
//    func peerTalkServer(_ peerTalkServer: PeerTalkServer, didReceiveData data: Foundation.Data) {
//        webServer.stop()
    
//        webServer.removeAllHandlers()
//        guard let decompressed = (data as NSData).decompressed() else {
//            return
//        }
//
//        if let JSON = (try? JSONSerialization.jsonObject(with: decompressed, options: JSONSerialization.ReadingOptions(rawValue: 0))) as? [NSString: AnyObject] {
//            if let request: AnyObject = JSON["request"] {
//                let iconUploadRequired = addRequest(request)
//                if iconUploadRequired {
//                    peerTalkServer.sendData("Hello".dataUsingEncoding(String.Encoding.utf8)!)
//                }
//            }
//            else if let response: AnyObject = JSON["response"] {
//                addResponse(response)
//            }
//            else if let heartbeat: AnyObject = JSON["heartbeat"] {
//                addHeartbeat(heartbeat)
//            }
//            else if let image: AnyObject = JSON["image"] {
//                guard let device = image["device"] else {
//                    return
//                }
//                guard let bundleId = device?["bundle_identifier"] as? String else {
//                    return
//                }
//                guard let string = image["data"] as? String else {
//                    return
//                }
//                guard let data = Foundation.Data(base64Encoded: string, options: []) else {
//                    return
//                }
//                Data.sharedInstance.saveIconData(data, forBundleIdentifier: bundleId)
//                print(image)
//            }
//        }
    }
    
    // mark: CBClientDelegate
    


