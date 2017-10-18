//
//  CenteredButtonCell.swift
//  Jibber
//
//  Created by Matthew Cheok on 30/3/15.
//  Copyright (c) 2015 Matthew Cheok. All rights reserved.
//

import Cocoa

class CenteredButtonCell: NSButtonCell {
    
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        let textFrame = NSRect(x: 0, y: 0, width: cellFrame.width, height: cellFrame.height-5)

        let title = attributedTitle.mutableCopy() as! NSMutableAttributedString
        
        drawTextCentered(title, frame: textFrame, offset: 0.5)
    }
    
    func drawTextCentered(_ text: NSAttributedString, frame: NSRect, offset: CGFloat = 0) -> CGFloat {
        let size = text.size
        
        var rect = frame
        rect.size.width = min(frame.width, size().width)
        rect.size.height = size().height
        rect.origin.x += (frame.width - size().width) / 2
        rect.origin.y += (frame.height - size().height) / 2 + offset

        text.draw(in: rect)
        
        return rect.size.width
    }
    
}
