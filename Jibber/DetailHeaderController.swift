//
//  DetailHeaderController.swift
//  Jibber
//
//  Created by Matthew Cheok on 5/3/15.
//  Copyright (c) 2015 Matthew Cheok. All rights reserved.
//

import Cocoa
import Cartography

class DetailHeaderController: NSViewController {

    @IBOutlet var methodLabel: NSTextField!
    @IBOutlet var urlLabel: NSTextField!
    
    var request: Request? {
        didSet {
            if let request = request {
                methodLabel.isHidden = false
                urlLabel.isHidden = false
                
                if request.method == DataRemoteNotificationMethodName {
                    methodLabel.stringValue = "REMOTE NOTIFICATION"
                    urlLabel.stringValue = "Apple Push Notification Service"
                }
                else {
                    methodLabel.stringValue = request.method
                    urlLabel.stringValue = request.path
                }
            }
            else {
                methodLabel.stringValue = ""
                methodLabel.isHidden = true
                
                urlLabel.stringValue = ""
                urlLabel.isHidden = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        constrain(view) { view in
            ()
            view.height == 30
        }
        
        request = nil
    }
    
}
