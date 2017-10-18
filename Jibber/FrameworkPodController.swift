//
//  FrameworkPodController.swift
//  Jibber
//
//  Created by Matthew Cheok on 8/3/15.
//  Copyright (c) 2015 Matthew Cheok. All rights reserved.
//

import Cocoa

class FrameworkPodController: FrameworkLinkController {

    @IBOutlet var cocoapodsLabel: NSTextField!
    
    @IBAction func copyButtonClicked(_ sender: AnyObject) {
        NSPasteboard.general().clearContents()
        NSPasteboard.general().setString(DataPodfileCopyText, forType: NSStringPboardType)

        let alert = NSAlert()
        alert.addButton(withTitle: "OK")
        alert.messageText = "Install with Cocoapods"
        alert.informativeText = "Copied. You should paste into your project's Podfile."
        alert.runModal()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cocoapodsLabel.stringValue = DataPodfileCopyText
    }
    
}
