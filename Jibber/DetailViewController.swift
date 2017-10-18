//
//  DetailPlaneController.swift
//  Jibber
//
//  Created by Matthew Cheok on 5/3/15.
//  Copyright (c) 2015 Matthew Cheok. All rights reserved.
//

import Cocoa
import Cartography
import JSONSyntaxHighlight

class DetailViewController: NSViewController {
    @IBOutlet fileprivate var headersButton: NSButton!
    @IBOutlet fileprivate var textButton: NSButton!
    @IBOutlet fileprivate var jsonButton: NSButton!
    
    @IBOutlet fileprivate var tabView: NSTabView!
    @IBOutlet fileprivate var textView: NSTextView!
    @IBOutlet fileprivate var headersOutlineView: NSOutlineView!
    @IBOutlet fileprivate var objectsOutlineView: NSOutlineView!
    
    @IBOutlet var headersDataSource: HeadersDataSource!
    @IBOutlet var outlineDataSource: OutlineDataSource!
    
    @IBOutlet fileprivate var placeholderImageView: NSImageView!
    @IBOutlet fileprivate var placeholderLabel: NSTextField!
    
    enum ToggleMode: Int {
        case headers = 1
        case text
        case json
    }

    var toggleButtons: [NSButton]!
    var toggleIndex: ToggleMode = .text {
        didSet {
            updateContent()
        }
    }

    var placeholderImage: NSImage?
    var placeholderMessage: String = ""
    
    var emptyContent: Bool = true
    var jsonContent: AnyObject? {
        didSet {
            let contentAvailable = jsonContent != nil
            jsonButton.isEnabled = contentAvailable
            emptyContent = !contentAvailable
            
            outlineDataSource.jsonObject = jsonContent
            objectsOutlineView.reloadData()
            
            if let parameters: AnyObject = jsonContent {
                let text = attributedTextForJSON(parameters)
                updateTextView(textView, text: text)
            }
        }
    }
    
    var content: Displayable? {
        didSet {
            if let content = content {
                headersDataSource.headers = content.headers
                headersOutlineView.reloadData()

                emptyContent = true
                let data = Foundation.Data(base64Encoded: content.body, options: [])!
                if headersContainJSONContent(content.headers as! NSDictionary) {
                    jsonContent = try? JSONSerialization.jsonObject(with: data, options: []) as AnyObject
                }
                else {
                    jsonContent = nil
                    if toggleIndex == .json {
                        toggleIndex = .text
                    }
                    
                    if let body = String(data: data, encoding: .utf8) {
                        if body.utf16.count > 0 {
                            let text = NSAttributedString(string: body)
                            updateTextView(textView, text: text)
                            emptyContent = false
                        }
                    }
                }
                
                if let request = content as? Request {
                    if request.method == "GET" {
                        if let components = URLComponents(string: request.path) {
                            jsonContent = components.query?.queryDictionary() as AnyObject
                        }
                    }
                }
            }
            else {
                jsonContent = nil
            }
            
            updateContent()
        }
    }
    
    func headersContainJSONContent(_ headers: NSDictionary) -> Bool {
        if let contentType = headers["Content-Type"] as? String {
            let lowercaseString = contentType.lowercased()
            return lowercaseString.range(of: "application/json") != nil || lowercaseString.range(of: "text/javascript") != nil
        }
        return false
    }
    
    func attributedTextForJSON(_ object: AnyObject) -> NSAttributedString {
        let json = JSONSyntaxHighlight(json: object) as! JSONSyntaxHighlight
        json.nonStringAttributes = [
            NSForegroundColorAttributeName: NSColor.jibber_darkGreenColor
        ]
        json.stringAttributes = [
            NSForegroundColorAttributeName: NSColor.jibber_navyColor
        ]
        json.keyAttributes = [
            NSForegroundColorAttributeName: NSColor.jibber_darkRedColor
        ]
        return json.highlightJSON()
    }
    
    func updateContent() {
        for (index, button) in toggleButtons.enumerated() {
            button.state = (toggleIndex.rawValue == index+1) ? 1 : 0
        }

        if let _ = content {
            switch toggleIndex {
            case .headers:
                tabView.selectTabViewItem(at: toggleIndex.rawValue)
            case .text:
                tabView.selectTabViewItem(at: emptyContent ? 0 : toggleIndex.rawValue)
            case .json:
                tabView.selectTabViewItem(at: jsonContent == nil ? 0 : toggleIndex.rawValue)
            }

        }
        else {
            tabView.selectTabViewItem(at: 0)
        }
    }
    
    @IBAction func handleToggleButtons(_ sender: AnyObject) {
        if let button = sender as? NSButton {
            if let index = toggleButtons.index(of: button) {
                toggleIndex = ToggleMode(rawValue: index+1)!
            }
        }
    }
    
    func updateTextView(_ textView: NSTextView, text: NSAttributedString?) {
        if let textStorage = textView.textStorage {
            if let text = text {
                textStorage.replaceCharacters(in: NSMakeRange(0, textStorage.length), with:text)
                textStorage.font = NSFont(name: "Monaco", size: 13)
            }
            else {
                textStorage.deleteCharacters(in: NSMakeRange(0, textStorage.length))
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        constrain(view) { view in
            ()
            view.height >= 220
        }

        toggleButtons = [headersButton, textButton, jsonButton]
        toggleIndex = .text
        
        placeholderImageView.image = placeholderImage
        placeholderLabel.stringValue = placeholderMessage
        
        content = nil
    }

}
