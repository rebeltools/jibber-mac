//
//  DetailSplitController.swift
//  Jibber
//
//  Created by Matthew Cheok on 5/3/15.
//  Copyright (c) 2015 Matthew Cheok. All rights reserved.
//

import Cocoa

class DetailSplitController: NSSplitViewController {
    
    var device: Device?
    var request: Request? {
        didSet {
            if request == oldValue {
                return
            }
            
            self.detailHeaderController.request = request
            self.requestDetailController.content = request
        }
    }
    
    var response: Response? {
        didSet {
            if response == oldValue {
                return
            }
            
            self.responseDetailController.content = response
        }
    }
    
    let detailHeaderController: DetailHeaderController = {
        let controller = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "DetailHeaderController") as! DetailHeaderController
        return controller
    }()
    
    let requestDetailController: DetailViewController = {
        let controller = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "DetailViewController") as! DetailViewController
        controller.placeholderImage = NSImage(named: "cloud_upload")
        controller.placeholderMessage = "No request parameters"
        return controller
    }()

    let responseDetailController: DetailViewController = {
        let controller = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "DetailViewController") as! DetailViewController
        controller.placeholderImage = NSImage(named: "cloud_download")
        controller.placeholderMessage = "No response parameters"
        return controller
    }()
    
    var requestObserver: AnyObject?
    var responseObserver: AnyObject?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        splitViewItems = [
            NSSplitViewItem(viewController: detailHeaderController),
            NSSplitViewItem(viewController: requestDetailController),
            NSSplitViewItem(viewController: responseDetailController)
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        splitView.restoreAutosavedPositions()
        
        requestObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: RequestViewControllerDidSelectRequest), object: nil, queue: OperationQueue.main) { (notification) -> Void in
            [self]
            
            if let device = notification.userInfo?[DataUserInfoDeviceKey] as? Device {
                self.device = device
            }
            if let request = notification.userInfo?[DataUserInfoRequestKey] as? Request {
                self.request = request
                self.response = JibberData.sharedInstance.responseForRequest(request, inDevice: self.device!)
            }
            else {
                self.request = nil
                self.response = nil
            }
        }
        
        responseObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: DataDidReceiveNewResponseNotification), object: nil, queue: OperationQueue.main) { (notification) -> Void in
            [self]
            
            if let response = notification.userInfo?[DataUserInfoResponseKey] as? Response {
                
                if let request = self.request {
                    if response.uuid == request.uuid {
                        self.response = response
                    }
                }
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(requestObserver!)
        NotificationCenter.default.removeObserver(responseObserver!)
    }
}
