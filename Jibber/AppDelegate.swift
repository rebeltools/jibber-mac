//
//  AppDelegate.swift
//  Jibber
//
//  Created by Matthew Cheok on 17/1/15.
//  Copyright (c) 2015 Matthew Cheok. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    
}
