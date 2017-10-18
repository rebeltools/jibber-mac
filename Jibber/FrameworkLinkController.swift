//
//  FrameworkLinkController.swift
//  Jibber
//
//  Created by Matthew Cheok on 5/2/15.
//  Copyright (c) 2015 Matthew Cheok. All rights reserved.
//

import Cocoa

class FrameworkLinkController: NSViewController {
    weak var navigationController: BFNavigationController?
    @IBInspectable var nextControllerIdentifier: String?

    @IBAction func cancelButtonClicked(_ sender: AnyObject) {
        UserDefaults.standard.setValue(true, forKey:"frameworkOnboarding")
        navigationController?.dismissViewController(navigationController!)
    }
    
    @IBAction func backButtonClicked(_ sender: AnyObject) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextButtonClicked(_ sender: AnyObject) {
        if let identifier = nextControllerIdentifier {
            let controller = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: identifier) as! FrameworkLinkController
            controller.navigationController = navigationController
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
