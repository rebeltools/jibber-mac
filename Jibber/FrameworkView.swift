//
//  FrameworkView.swift
//  Jibber
//
//  Created by Matthew Cheok on 3/2/15.
//  Copyright (c) 2015 Matthew Cheok. All rights reserved.
//

import AppKit
import Async
import SSZipArchive

private let kFrameworkExtractionDateKey = "kFrameworkExtractionDateKey"

protocol FrameworkViewDelegate: class {
    func frameworkView(frameworkViewDidStartDragging view: FrameworkView)
}

class FrameworkView: NSImageView, NSDraggingSource {
    weak var delegate: FrameworkViewDelegate?

    func extractFramework() {
        if let path = Bundle.main.path(forResource: "Jibber.framework", ofType: "zip") {
            let outputPath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("Jibber.framework")
            
            var shouldExtract = true
            if FileManager.default.fileExists(atPath: outputPath.path) {
                Swift.print("Framework path \(path)")
                let attributes: NSDictionary = try! FileManager.default.attributesOfItem(atPath: path) as NSDictionary
                if let creationDate = attributes.fileCreationDate() {
                    if let extractedDate = UserDefaults.standard.object(forKey: kFrameworkExtractionDateKey) as? Date {
                        Swift.print("Extracted \(extractedDate) Framework \(creationDate)")
                        if extractedDate.compare(creationDate) == ComparisonResult.orderedDescending {
                            shouldExtract = false
                        }
                    }
                }
            }
            
            if shouldExtract {
                if FileManager.default.fileExists(atPath: outputPath.path) {
                    do {
                        try FileManager.default.removeItem(atPath: outputPath.path)
                    } catch _ {
                    }
                }
                
                Swift.print("Extracting framework!")
                
                UserDefaults.standard.set(Date(), forKey: kFrameworkExtractionDateKey)

                Async.background({ () -> Void in
                    SSZipArchive.unzipFile(atPath: path, toDestination: NSTemporaryDirectory())
                }).main({ () -> Void in
                    self.print("Done extracting framework!")
                })

            }
            else {
                Swift.print("Framework is recent enough")
            }
        }
        

        
    }
    
    func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
        if context == .outsideApplication {
            return .copy
        }
        else {
            return NSDragOperation()
        }
    }
    
    override func acceptsFirstMouse(for theEvent: NSEvent?) -> Bool {
        return true
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        let output = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("Jibber.framework")
        if FileManager.default.fileExists(atPath: output.path) {
            let point = convert(theEvent.locationInWindow, from: nil)
            let rect = NSMakeRect(point.x, point.y, 50, 50)
            dragFile(output.path, from: rect, slideBack: true, event: theEvent)
            delegate?.frameworkView(frameworkViewDidStartDragging: self)
        }
    }
}
