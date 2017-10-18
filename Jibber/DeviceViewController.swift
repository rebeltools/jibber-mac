//
//  DeviceViewController.swift
//  Jibber
//
//  Created by Matthew Cheok on 6/3/15.
//  Copyright (c) 2015 Matthew Cheok. All rights reserved.
//

import Cocoa

internal let DeviceViewControllerDidSelectDevice = "DeviceViewControllerDidSelectDevice"

protocol DeviceViewControllerDelegate: class {
    func deviceViewControllerDidFinishSelectingDevice(_ deviceViewController: DeviceViewController)
}

class DeviceViewController: NSViewController {
    
    weak var delegate: DeviceViewControllerDelegate?
    @IBOutlet var tableView: NSTableView!
    
    var observer: AnyObject?
    var devices: [Device] = []
    
    func loadDevices() {
        devices = JibberData.sharedInstance.allDevices()
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        observer = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: DataDidReceiveNewDeviceNotification), object: nil, queue: OperationQueue.main) { (notification) -> Void in
            [self]
            self.loadDevices()
        }
        
        self.loadDevices()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(observer!)
    }
    
    // MARK: NSTableViewDataSource
    
    func numberOfRowsInTableView(_ tableView: NSTableView) -> Int {
        return devices.count
    }
    
    func tableView(_ tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let view = tableView.make(withIdentifier: "DeviceView", owner: self) as! DeviceCell
        let device = devices[row]
        view.device = device
        return view
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        var view = tableView.make(withIdentifier: "RowView", owner: self) as! NSTableRowView!
        
        if view == nil {
            view = TableRowView()
            view?.identifier = "RowView"
        }
        
        return view
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        let device = devices[row]
        DispatchQueue.main.async{
            let userInfo: [String:AnyObject] = [
                DataUserInfoDeviceKey: device
            ]
            NotificationCenter.default.post(name: Notification.Name(rawValue: DeviceViewControllerDidSelectDevice), object: nil, userInfo: userInfo)
        }
        delegate?.deviceViewControllerDidFinishSelectingDevice(self)
        
        return true
    }
    
}
