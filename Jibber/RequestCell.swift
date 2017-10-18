//
//  RequestCell.swift
//  Jibber
//
//  Created by Matthew Cheok on 29/1/15.
//  Copyright (c) 2015 Matthew Cheok. All rights reserved.
//

import Cocoa

private let HTTPCodeDescription = [
    100: "Continue",
    101: "Switching Protocols",
    
    200: "OK",
    201: "Created",
    202: "Accepted",
    203: "Non-Authoritative Information",
    204: "No Content",
    205: "Reset Content",
    206: "Partial Content",
    
    300: "Multiple Choices",
    301: "Moved Permanently",
    302: "Found",
    303: "See Other",
    304: "Not Modified",
    305: "Use Proxy",
    306: "",
    307: "Temporary Redirect",
    
    400: "Bad Request",
    401: "Unauthorized",
    402: "Payment Required",
    403: "Forbidden",
    404: "Not Found",
    405: "Method Not Allowed",
    406: "Not Acceptable",
    407: "Proxy Authentication Required",
    408: "Request Timeout",
    409: "Conflict",
    410: "Gone",
    411: "Length Required",
    412: "Precondition Failed",
    413: "Request Entity Too Large",
    414: "Request-URI Too Long",
    415: "Unsupported Media Type",
    416: "Requested Range Not Satisfiable",
    417: "Expectation Failed",
    
    500: "Internal Server Error",
    501: "Not Implemented",
    502: "Bad Gateway",
    503: "Service Unavailable",
    504: "Gateway Timeout",
    505: "Version Not Supported"
]

private let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .medium
    return formatter
    }()

class RequestCell: NSTableCellView {

    @IBOutlet var methodTextField: NSTextField!
    @IBOutlet var pathTextField: NSTextField!
    @IBOutlet var statusTextField: NSTextField!
    @IBOutlet var timeTextField: NSTextField!
    @IBOutlet var durationTextField: NSTextField!
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func colorForStatusCode(_ statusCode: Int) -> NSColor {
        if statusCode >= 500 {
            return NSColor.jibber_redColor
        }
        else if statusCode >= 400 {
            return NSColor.jibber_orangeColor
        }
        else if statusCode >= 200 {
            return NSColor.jibber_greenColor
        }
        else if statusCode == DataRequestFailureStatusCode {
            return NSColor.jibber_redColor
        }
        else {
            return NSColor.jibber_darkNavyColor
        }
    }
    
    func setup() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: DataDidReceiveNewResponseNotification), object: nil, queue: nil) { (notification) -> Void in
            [self]
            if let response = notification.userInfo?[DataUserInfoResponseKey] as? Response {
                if let request = self.request {
                    if request.uuid == response.uuid {
                        self.response = response
                    }
                }
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: DataDidReceiveNewResponseNotification), object: nil)
    }
    
    var request: Request? {
        didSet {
            if let request = request {
                var path = request.path
                if let components = URLComponents(string: request.path) {
                    path = components.path
                }

                if request.method == DataRemoteNotificationMethodName {
                    methodTextField.stringValue = "REMOTE NOTIFICATION"
                    pathTextField.stringValue = ""
                }
                else {
                    methodTextField.stringValue = request.method
                    pathTextField.stringValue = (path?.characters.count)! > 0 ? path! : "/"
                }
                timeTextField.stringValue = timeFormatter.string(from: request.date)
            }
            else {
                methodTextField.stringValue = ""
                pathTextField.stringValue = ""
                timeTextField.stringValue = ""
            }
        }
    }
    
    var response: Response? {
        didSet {
            if let response = response {
                if response.statusCode == DataRequestFailureStatusCode {
                    let color = NSColor.jibber_redColor
                    
                    statusTextField.stringValue = "FAILED"
                    statusTextField.textColor = color
                    (statusTextField.cell! as? PillTextFieldCell)?.tintColor = color
                    
                    durationTextField.stringValue = ""
                }
                else if response.statusCode == DataRemoteNotificationStatusCode {
                    let color = NSColor.jibber_darkNavyColor
                    
                    statusTextField.stringValue = "RECEIVED"
                    statusTextField.textColor = color
                    (statusTextField.cell! as? PillTextFieldCell)?.tintColor = color
                    
                    durationTextField.stringValue = ""
                }
                else {
                    let string = NSMutableAttributedString(string: "\(response.statusCode)")
                    let range = NSMakeRange(0, string.length)
                    
                    if let desc = HTTPCodeDescription[response.statusCode] {
                        string.append(NSAttributedString(string: " \(desc.uppercased())"))
                    }
                    
                    let color = colorForStatusCode(response.statusCode)
                    
                    string.addAttribute(NSFontAttributeName, value: NSFont.jibber_lightFontOfSize(14), range: NSMakeRange(0, string.length))
                    string.addAttribute(NSFontAttributeName, value: NSFont.jibber_standardFontOfSize(14), range: range)
                    string.addAttribute(NSForegroundColorAttributeName, value: color, range: NSMakeRange(0, string.length))
                
                    (statusTextField.cell! as? PillTextFieldCell)?.tintColor = color
                    statusTextField.attributedStringValue = string
                    durationTextField.stringValue = String(format: "%.3fs", response.duration)
                }
            }
            else {
                let color = NSColor.jibber_darkNavyColor
                
                statusTextField.stringValue = "WAITING..."
                statusTextField.textColor = color
                (statusTextField.cell! as? PillTextFieldCell)?.tintColor = color
                
                durationTextField.stringValue = ""
            }
        }
    }
    
//    override var backgroundStyle: NSBackgroundStyle {
//        didSet {
//            println("style \(backgroundStyle.rawValue)")
//        }
//    }
    
}
