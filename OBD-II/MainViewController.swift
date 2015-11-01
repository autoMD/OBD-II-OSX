//
//  ViewController.swift
//  OBD-II
//
//  Created by Manuel Stampfl on 01.11.15.
//  Copyright © 2015 mani1337. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {

    @IBOutlet var mainTextView: NSTextView!
    @IBOutlet var inputTextField: NSTextField!
    @IBOutlet var sendButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func onSend(sender: AnyObject) {
        NSLog("send " + self.inputTextField.stringValue)
    }
    
    
}

