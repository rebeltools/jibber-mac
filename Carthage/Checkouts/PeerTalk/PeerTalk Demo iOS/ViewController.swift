//
//  ViewController.swift
//  PeerTalk Demo iOS
//
//  Created by Matthew Cheok on 3/10/15.
//  Copyright © 2015 Matthew Cheok. All rights reserved.
//

import UIKit
import PeerTalk

class ViewController: UIViewController, PeerTalkClientDelegate {
    var client: PeerTalkClient?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("Starting iOS Demo")
        client = PeerTalkClient()
        client?.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - PeerTalkClientDelegate
    
    func peerTalkClient(peerTalkClient: PeerTalkClient, didConnectToServer server: String?) {
        print("connected", server)
        
        guard let data = "This is a test from client".dataUsingEncoding(NSUTF8StringEncoding) else {
            return
        }
        peerTalkClient.sendData(data)
    }
    
    func peerTalkClient(peerTalkClient: PeerTalkClient, didDisconnectFromServer server: String?) {
        print("disconnected", server)
    }
    
    func peerTalkClient(peerTalkClient: PeerTalkClient, didReceiveData data: NSData) {
        let result = NSString(data: data, encoding: NSUTF8StringEncoding)
        print("recevied", result)
    }
}

