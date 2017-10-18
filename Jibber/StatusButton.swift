//
//  StatusButton.swift
//  Jibber
//
//  Created by Matthew Cheok on 26/3/15.
//  Copyright (c) 2015 Matthew Cheok. All rights reserved.
//

import Cocoa

class StatusButton: NSButton {

    var device: Device? {
        didSet {
            if let cell = cell! as? StatusButtonCell {
                cell.device = device
                setNeedsDisplay()
            }
        }
    }

    var updateTimer: Timer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateTimer = Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(CALayer.setNeedsDisplay), userInfo: nil, repeats: true)
    }
    
    deinit {
        updateTimer?.invalidate()
    }

}
