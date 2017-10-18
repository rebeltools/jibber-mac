//
//  StatusButtonCell.swift
//  Jibber
//
//  Created by Matthew Cheok on 25/3/15.
//  Copyright (c) 2015 Matthew Cheok. All rights reserved.
//

import Cocoa

private let kPillRadius: CGFloat = 4

class StatusButtonCell: NSButtonCell {
    
    var device: Device?
    
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        if let device = device {
            let statusWidth: CGFloat = 50
            let statusFrame = NSRect(x: cellFrame.width-statusWidth-5, y: 6, width: statusWidth, height: cellFrame.height-12)
            
            if JibberData.sharedInstance.hasRecentlyConnectedForDevice(device) {
                drawPillWithText("ONLINE", frame: statusFrame, color: NSColor.jibber_greenColor, offset: -1.5)
            }
            else {
                drawPillWithText("OFFLINE", frame: statusFrame, color: NSColor.jibber_redColor, offset: -1.5)
            }
     
            let textFrame = NSRect(x: statusWidth+10, y: 0, width: cellFrame.width-(statusWidth+10)*2, height: cellFrame.height-5)
            
            let deviceName = NSAttributedString(string: device.bundleName, attributes: [
                NSFontAttributeName: NSFont.jibber_mediumFontOfSize(13)
                ])
            
            let bundleName = NSAttributedString(string: device.name, attributes: [
                NSFontAttributeName: NSFont.jibber_standardFontOfSize(13)
                ])
            
            let paragraphStyle = NSParagraphStyle.default().mutableCopy() as! NSMutableParagraphStyle
            paragraphStyle.lineBreakMode = NSLineBreakMode.byTruncatingTail

            let attributedText = NSMutableAttributedString()
            attributedText.append(deviceName)
            attributedText.append(NSAttributedString(string: " - "))
            attributedText.append(bundleName)
            attributedText.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributedText.length))
            drawTextCentered(attributedText, frame: textFrame, offset: 0.5)
        }
        else {
            let textFrame = NSRect(x: 10, y: 0, width: cellFrame.width-20, height: cellFrame.height-5)
            let paragraphStyle = NSParagraphStyle.default().mutableCopy() as! NSMutableParagraphStyle
            paragraphStyle.lineBreakMode = NSLineBreakMode.byTruncatingTail
            
            let attributedText = NSMutableAttributedString(string: "Waiting for devices...", attributes: [
                NSFontAttributeName: NSFont.jibber_standardFontOfSize(13)
                ])
            drawTextCentered(attributedText, frame: textFrame, offset: 0.5)
        }
    
    }
    
    func drawTextCentered(_ text: NSAttributedString, frame: NSRect, offset: CGFloat = 0) -> CGFloat {
        let size = text.size
        
        var rect = frame
        rect.size.width = min(frame.width, size().width)
        rect.size.height = size().height
        rect.origin.x += (frame.width - size().width) / 2
        rect.origin.y += (frame.height - size().height) / 2 + offset
        
        text.draw(in: rect)
        
        return min(size().width, frame.width)
    }
    
    func drawPillWithText(_ text: String, frame: NSRect, color: NSColor, offset: CGFloat = 0) {
        let attributedText = NSAttributedString(string: text, attributes: [
            NSForegroundColorAttributeName: color,
            NSFontAttributeName: NSFont.jibber_lightFontOfSize(11)
            ])
        let size = attributedText.size
        
        var rect = frame
        rect.size.height = size().height
        rect.origin.y += (frame.height - size().height) / 2 + offset
        rect.origin.x += (frame.width - size().width) / 2
        attributedText.draw(in: rect)
        
        NSGraphicsContext.saveGraphicsState()
        let path = NSBezierPath(roundedRect: frame, xRadius: kPillRadius, yRadius: kPillRadius)
        path.addClip()
        
        color.setStroke()
        path.lineWidth = 2
        path.stroke()
        NSGraphicsContext.restoreGraphicsState()
    }
    
}
