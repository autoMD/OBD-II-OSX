//
//  ViewController.swift
//  OBD-II
//
//  Created by Manuel Stampfl on 01.11.15.
//  Copyright © 2015 mani1337. All rights reserved.
//

import Cocoa
import CoreBluetooth

class MainViewController: NSViewController, NSTextFieldDelegate, OBDIIDelegate {

    @IBOutlet var obdTextView: NSTextView!
    @IBOutlet var logTextView: NSTextView!
    @IBOutlet var inputTextField: NSTextField!
    @IBOutlet var sendButton: NSButton!
    
    var obd = OBDII()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.inputTextField.delegate = self
    
        obd.delegate = self
        obd.open()
    }

    @IBAction func onSend(sender: AnyObject) {
        let text = self.inputTextField.stringValue
        if obd.write(text) {
            self.inputTextField.stringValue = ""
        } else {
            self.appendLogText("Failed")
        }
    }
    
    func appendLogText(string: String) {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .LongStyle
        formatter.timeStyle = .LongStyle
        
        let date = formatter.stringFromDate(NSDate())
        
        let output = NSAttributedString(string: "[\(date)] \(string)\n")
        self.logTextView.textStorage?.appendAttributedString(output)
        self.logTextView.scrollToEndOfDocument(nil)
    }
    
    func appendOBDLog(string: String) {
        let output = NSAttributedString(string: string)
        self.obdTextView.textStorage?.appendAttributedString(output)
        self.obdTextView.scrollToEndOfDocument(nil)
        
    }
    // MARK: - OBDIIDelegate
    func didConnect(obd: OBDII) {
        self.appendLogText("Connection established")
    }
    
    func didDisconnect(obd: OBDII) {
        self.appendLogText("Disconnected")
        self.connectInOneSecond()
    }
    
    func cantConnect(obd: OBDII) {
        self.appendLogText("Failed to connect")
        self.connectInOneSecond()
    }
    
    func didReceivedData(obd: OBDII, string: String) {
        self.appendOBDLog(string)
    }
    func connectInOneSecond() {
        self.appendLogText("Connection will be reopened in 1 second")
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self.obd, selector: Selector("open"), userInfo: nil, repeats: false)
    }

}

