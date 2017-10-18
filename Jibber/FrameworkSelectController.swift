//
//  FrameworkSelectController.swift
//  Jibber
//
//  Created by Matthew Cheok on 8/3/15.
//  Copyright (c) 2015 Matthew Cheok. All rights reserved.
//

import Cocoa
import EDSemver

class FrameworkSelectController: FrameworkLinkController {
    
    var device: Device?
    
    @IBOutlet var messageLabel: NSTextField!
    
    @IBAction func cocoapodsButtonClicked(_ sender: AnyObject) {
        nextControllerIdentifier = "FrameworkPodsController"
        nextButtonClicked(self)
    }
    
    @IBAction func frameworkButtonClicked(_ sender: AnyObject) {
        nextControllerIdentifier = "FrameworkDragController"
        nextButtonClicked(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        var needsUpdate = false
        if let device = device {
            let deviceVersion = EDSemver(string: device.frameworkVersion)
            let currentVersion = EDSemver(string: DataFrameworkVersion)
            needsUpdate = deviceVersion.isLessThan(currentVersion)
        }
        
        let text = needsUpdate ? DataFrameworkUpdateText : DataFrameworkInstallText
        let attributedText = NSMutableAttributedString(string: text)
        
        for item in ["add", "update"] {
            let range = (text as NSString).range(of: item)
            if range.location >= 0 {
                attributedText.addAttribute(NSFontAttributeName, value: NSFont.jibber_mediumFontOfSize(13), range: range)
            }
        }
        
        if needsUpdate {
            attributedText.append(NSAttributedString(string: " (Installed: \(device!.frameworkVersion), Current: \(DataFrameworkVersion))"))
        }
        messageLabel.attributedStringValue = attributedText
    }
    
}
