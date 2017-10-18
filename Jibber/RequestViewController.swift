//
//  RequestViewController.swift
//  Jibber
//
//  Created by Matthew Cheok on 22/1/15.
//  Copyright (c) 2015 Matthew Cheok. All rights reserved.
//

import Cocoa
import Cartography

internal let RequestViewControllerDidSelectRequest = "RequestViewControllerDidSelectRequest"

class RequestViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    @IBOutlet var tableView: NSTableView!
    @IBOutlet var searchField: NSSearchField!
    
    var device: Device? {
        didSet {
            if let device = device {
                requests = JibberData.sharedInstance.requestsForDevice(device)
                filterRequests()
                selectFirstIfAvailable()
            }
        }
    }
    
    var requests: [Request] = []
    var filteredRequests: [Request] = []
    
    @IBAction func handleTrashButton(_ sender: AnyObject) {
        searchField.stringValue = ""
        
        if let device = device {
            JibberData.sharedInstance.clearDataForDevice(device)
            requests = []
            filterRequests()
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: RequestViewControllerDidSelectRequest), object: nil, userInfo: nil)
        }
    }
 
    @IBAction func handleSearchField(_ sender: AnyObject) {
        filterRequests()
        selectFirstIfAvailable()
    }
    
    func handleRequestNotification(_ notification: Notification) {
        let deviceForRequest = notification.userInfo?[DataUserInfoDeviceKey] as? Device
        
        if device != deviceForRequest {
            return
        }
        else {
            requests = JibberData.sharedInstance.requestsForDevice(deviceForRequest!)
            filterRequests()
        }
    }
    
    func filterRequests() {
        let search = searchField.stringValue
        let components = search.components(separatedBy: " ")
        
        var array = self.requests
        if search.characters.count > 0 {
            array = self.requests.filter({ (request) -> Bool in
                if let first = components.first {
                    if request.method.lowercased().range(of:first.lowercased()) != nil {
                        if components.count > 1 {
                            let rest = (components[1..<components.count]).joined(separator: " ")
                            return request.path.range(of:rest) != nil
                        }
                        else {
                            return true
                        }
                    }
                }
                return request.path.range(of:search) != nil
            })
        }
            
        let selectedRequest: Request? = tableView.selectedRow >= 0 ? filteredRequests[tableView.selectedRow] : nil
        
        filteredRequests = array
        tableView.reloadData()


        if let request = selectedRequest {
            if let index = filteredRequests.index(of: request) {
                let indexset = IndexSet(integer: index)
                self.tableView.selectRowIndexes(indexset, byExtendingSelection: false)
            }
        }
        else {
            self.tableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
        }
    }
    
    func selectFirstIfAvailable() {
        if filteredRequests.count > 0 {
            tableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
        }
        selectCurrentRequest()
    }
    
    func selectCurrentRequest() {
        if tableView.selectedRow >= 0 {
            let request = filteredRequests[tableView.selectedRow]
            let userInfo: [String:AnyObject] = [
                DataUserInfoDeviceKey: self.device!,
                DataUserInfoRequestKey: request
            ]
            NotificationCenter.default.post(name: Notification.Name(rawValue: RequestViewControllerDidSelectRequest), object: nil, userInfo: userInfo)
        }
        else {
            NotificationCenter.default.post(name: Notification.Name(rawValue: RequestViewControllerDidSelectRequest), object: nil, userInfo: nil)
        }
    }
    
    override func keyDown(with event: NSEvent) {
        if let key = event.charactersIgnoringModifiers {
            if key == String(Character(UnicodeScalar(NSDeleteCharacter)!)) {
                let index = tableView.selectedRow
                if index >= 0 {
                    let request = filteredRequests[index]
                    
                    JibberData.sharedInstance.clearRequest(request, forDevice: device!)
                    requests = JibberData.sharedInstance.requestsForDevice(device!)
                    filterRequests()

                    if filteredRequests.count > index {
                        tableView.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
                    }
                    selectCurrentRequest()
                    
                    if let index = requests.index(of: request) {
                        requests.remove(at: index)
                        filterRequests()

           
                    }
                }
                else {
                    NSBeep()
                }
            }
            return
        }
        
        super.keyDown(with: event)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        constrain(view) { view in
            view.width >= 250
            view.width == 250 ~ LayoutPriority(100)
        }
        
        Server.sharedInstance
        
    
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: DeviceViewControllerDidSelectDevice), object: nil, queue: OperationQueue.main) { (notification) -> Void in
            [self]
            if let device = notification.userInfo?[DataUserInfoDeviceKey] as? Device {
                self.device = device
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(RequestViewController.handleRequestNotification(_:)), name: NSNotification.Name(rawValue: DataDidReceiveNewRequestNotification), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: DataDidReceiveNewRequestNotification), object: nil)
    }
    
    // MARK: NSTableViewDataSource
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return filteredRequests.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let view = tableView.make(withIdentifier: "RequestView", owner: self) as! RequestCell
        let request = filteredRequests[row]
        view.request = request
        view.response = JibberData.sharedInstance.responseForRequest(request, inDevice: self.device!)
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

    func tableViewSelectionDidChange(_ notification: Notification) {
        selectCurrentRequest()
    }
}
