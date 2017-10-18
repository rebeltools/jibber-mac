//
//  ViewController.swift
//  PeerTalk Demo OSX
//
//  Created by Matthew Cheok on 11/10/15.
//  Copyright © 2015 Matthew Cheok. All rights reserved.
//

import Cocoa
import PeerTalk

class ViewController: NSViewController, PeerTalkServerDelegate {
    var server: PeerTalkServer?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("Startng OSX Demo")
        server = PeerTalkServer()
        server?.delegate = self
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    // MARK: - PeerTalkServerDelegate
    
    func peerTalkServer(peerTalkServer: PeerTalkServer, didConnectToClient client: String?) {
        print("connected", client)
        
        guard let data = "This is a test from server".dataUsingEncoding(NSUTF8StringEncoding) else {
            return
        }
        peerTalkServer.sendData(data)
    }
    
    func peerTalkServer(peerTalkServer: PeerTalkServer, didDisconnectFromClient client: String?) {
        print("disconnected", client)
    }
    
    func peerTalkServer(peerTalkServer: PeerTalkServer, didReceiveData data: NSData) {
        let result = NSString(data: data, encoding: NSUTF8StringEncoding)
        print("recevied", result)
    }

}

