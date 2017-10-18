//
//  DeviceCell.swift
//  Jibber
//
//  Created by Matthew Cheok on 6/3/15.
//  Copyright (c) 2015 Matthew Cheok. All rights reserved.
//

import Cocoa

class DeviceCell: NSTableCellView {

    @IBOutlet var appLabel: NSTextField!
    @IBOutlet var bundleLabel: NSTextField!
    @IBOutlet var deviceLabel: NSTextField!
    @IBOutlet var iconImageView: NSImageView!
    @IBOutlet var statusImageView: NSImageView!
    
    var updateTimer: Timer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateTimer = Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(DeviceCell.updateDeviceStatus), userInfo: nil, repeats: true)
    }
    
    deinit {
        updateTimer?.invalidate()
    }
    
    var device: Device? {
        didSet {
            if let device = device {
                appLabel.stringValue = device.bundleName
                appLabel.font = NSFont.jibber_mediumFontOfSize(14)
                
                bundleLabel.stringValue = device.bundleIdentifier
                deviceLabel.stringValue = "\(device.name) (iOS \(device.systemVersion))"
                
                if let url = JibberData.sharedInstance.iconURLForBundleIdentifier(device.bundleIdentifier) {
                    let image = NSImage(contentsOf: url)?.mask(usingMaskImage: NSImage(named: "icon-mask"))
                    iconImageView.image = image
                }
                else {
                    iconImageView.image = NSImage(named: "icon-shape")
                }
                
                updateDeviceStatus()
            }
            else {
                appLabel.stringValue = ""
                bundleLabel.stringValue = ""
                deviceLabel.stringValue = ""
                iconImageView.image = NSImage(named: "icon-shape")
                statusImageView.image = nil
            }
        }
    }
    
    func updateDeviceStatus() {
        statusImageView.image = NSImage(named: "icon-red")
        if let device = device {
            if JibberData.sharedInstance.hasRecentlyConnectedForDevice(device) {
                statusImageView.image = NSImage(named: "icon-green")
            }
        }
    }
    
}
