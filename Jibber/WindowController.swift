//
//  WindowController.swift
//  Jibber
//
//  Created by Matthew Cheok on 22/1/15.
//  Copyright (c) 2015 Matthew Cheok. All rights reserved.
//

import Cocoa
import EDSemver
import Async

class WindowController: NSWindowController, DeviceViewControllerDelegate {
    @IBOutlet var deviceButton: StatusButton!
    @IBOutlet var frameworkButton: NSButton!
    
    var popover: NSPopover?
    var device: Device? {
        didSet {
            deviceButton.device = device
            
            frameworkButton.font = NSFont.jibber_standardFontOfSize(13)
            frameworkButton.title = "Framework"
            
            if let device = device {
                let deviceVersion = EDSemver(string: device.frameworkVersion)
                let currentVersion = EDSemver(string: DataFrameworkVersion)
                
                if deviceVersion.isLessThan(currentVersion) {
                    frameworkButton.font = NSFont.jibber_mediumFontOfSize(13)
                    frameworkButton.title = "Update"
                }
            }
        }
    }
    
    func checkLatestVersionOfFramework() {
        let task = URLSession.shared.dataTask(with: URL(string: "https://api.github.com/repos/rebeltools/Jibber-Framework/releases/latest")!, completionHandler: { (data, response, error) in
            let jsonResult = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
            DataFrameworkVersion = jsonResult["tag_name"] as! String
        })
        task.resume()
    }

    @IBAction func deviceButtonClicked(_ sender: AnyObject) {
        var height: CGFloat = CGFloat(JibberData.sharedInstance.allDevices().count) * 80.0
        if height < 200 {
            height = 200
        }
        else if height > 440 {
            height = 440
        }
        
        let rect = NSMakeRect(0, 0, 360, height)
        let controller = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "DeviceViewController") as! DeviceViewController
        controller.delegate = self
        
        self.popover?.close()
        
        let popover = NSPopover()
        popover.contentViewController = controller
        popover.behavior = .transient
        popover.contentSize = rect.size
        
        let button = sender as! NSButton
        popover.show(relativeTo: button.frame, of: button.superview!, preferredEdge: NSRectEdge.maxY)
        self.popover = popover
    }
    
    @IBAction func addButtonClicked(_ sender: AnyObject) {
        let controller = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "FrameworkSelectController") as! FrameworkSelectController

        let navController = BFNavigationController(frame: NSMakeRect(0, 0, 450, 300), rootViewController: controller)
        controller.navigationController = navController
        controller.device = device
        
        self.contentViewController?.presentViewControllerAsSheet(navController!)
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.windowFrameAutosaveName = "JibberWindowController"
        self.window?.titleVisibility = NSWindowTitleVisibility.hidden
        self.device = nil
        
        if let splitView = contentViewController?.view as? NSSplitView {
            splitView.restoreAutosavedPositions()
        }
    
        NotificationCenter.default.addObserver(self, selector: #selector(WindowController.handleDeviceNotification(_:)), name: NSNotification.Name(rawValue: DeviceViewControllerDidSelectDevice), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(WindowController.handleDeviceNotification(_:)), name: NSNotification.Name(rawValue: DataDidReceiveNewDeviceNotification), object: nil)
        
        checkLatestVersionOfFramework()
        
        if UserDefaults.standard.value(forKey: "frameworkOnboarding") == nil {
            Async.main(after: 0) { () -> Void in
                [self]
                self.addButtonClicked(self)
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: DeviceViewControllerDidSelectDevice), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: DataDidReceiveNewDeviceNotification), object: nil)
    }
    
    func handleDeviceNotification(_ notification: Notification) {
        if let device = notification.userInfo?[DataUserInfoDeviceKey] as? Device {
            if notification.name.rawValue == DataDidReceiveNewDeviceNotification && self.device == nil {
                DispatchQueue.main.async{
                    let userInfo: [String:AnyObject] = [
                        DataUserInfoDeviceKey: device
                    ]
                    NotificationCenter.default.post(name: Notification.Name(rawValue: DeviceViewControllerDidSelectDevice), object: nil, userInfo: userInfo)
                }
            }
            else if notification.name.rawValue == DeviceViewControllerDidSelectDevice {
                self.device = device
            }
        }
    }

    // MARK: DeviceViewControllerDelegate
    
    func deviceViewControllerDidFinishSelectingDevice(_ deviceViewController: DeviceViewController) {
        Async.main(after: 0.3) { () -> Void in
            [self]
            self.popover?.close()
            self.popover = nil
        }
    }
    
}
