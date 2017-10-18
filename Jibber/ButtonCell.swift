//
//  ButtonCell.swift
//  Jibber
//
//  Created by Matthew Cheok on 5/3/15.
//  Copyright (c) 2015 Matthew Cheok. All rights reserved.
//

import Cocoa

private let kPillRadius: CGFloat = 4

class ButtonCell: NSButtonCell {
    @IBInspectable var topInset: CGFloat = 0
    @IBInspectable var sideInset: CGFloat = 4

    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        let attributedString = NSMutableAttributedString(string: title)
        let range = NSRange(location: 0, length: attributedString.length)
        
        var size = attributedString.size
        attributedString.removeAttribute("NSOriginalFont", range: range)
        
        while size().width + sideInset*2 > cellFrame.size.width {
            let font = attributedString.attribute(NSFontAttributeName, at: 0, effectiveRange: nil) as! NSFont
            
            let fontSize = (font.fontDescriptor.object(forKey: NSFontSizeAttribute)! as AnyObject).floatValue
            let updatedFont = NSFont(name: font.fontName, size: CGFloat(fontSize!-0.5))!
            
            attributedString.addAttribute(NSFontAttributeName, value: updatedFont, range: range)
            size = attributedString.size
        }
        
        if !isEnabled {
            attributedString.addAttribute(NSForegroundColorAttributeName, value: NSColor.gray, range: range)
        }
        else if state == 1 {
            attributedString.addAttribute(NSForegroundColorAttributeName, value: NSColor.white, range: range)
        }
        
        var rect = cellFrame
        rect.size.height = size().height
        rect.origin.y += (cellFrame.height - size().height) / 2 + topInset
        rect.origin.x += (cellFrame.width - size().width) / 2
        attributedString.draw(in: rect)
    }
    
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        let path = NSBezierPath(roundedRect: cellFrame, xRadius: kPillRadius, yRadius: kPillRadius)
        path.addClip()
        
        if state == 1 {
            NSColor.jibber_navyColor.setFill()
            path.fill()
        }
        
        super.draw(withFrame: cellFrame, in: controlView)
    }
    
    override func highlight(_ flag: Bool, withFrame cellFrame: NSRect, in controlView: NSView) {
        let path = NSBezierPath(roundedRect: cellFrame, xRadius: kPillRadius, yRadius: kPillRadius)
        path.addClip()
        
        if state == 1 {
            NSColor.jibber_navyColor.setFill()
            path.fill()
        }
        
        super.draw(withFrame: cellFrame, in: controlView)
    }

}
