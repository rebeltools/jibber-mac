//
//  FrameworkDragController.swift
//  Jibber
//
//  Created by Matthew Cheok on 5/2/15.
//  Copyright (c) 2015 Matthew Cheok. All rights reserved.
//

import Cocoa

class FrameworkDragController: FrameworkLinkController, FrameworkViewDelegate {
    @IBOutlet var draggingView: FrameworkView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        draggingView.delegate = self
        draggingView.extractFramework()
    }
    
    // MARK: FrameworkViewDelegate
    
    func frameworkView(frameworkViewDidStartDragging view: FrameworkView) {
        nextButtonClicked(self)
    }
}
