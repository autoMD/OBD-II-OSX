//
//  OBD-II.swift
//  OBD-II
//
//  Created by Manuel Stampfl on 02.11.15.
//  Copyright © 2015 mani1337. All rights reserved.
//

import Foundation
import CoreFoundation

@objc protocol OBDIIDelegate {
    func didConnect(obd: OBDII)
    func didDisconnect(obd: OBDII)
    func cantConnect(obd: OBDII)
    func didReceivedData(obd: OBDII, string: String)
}

class OBDII : NSObject, NSStreamDelegate {
    weak var delegate: OBDIIDelegate?
    
    let serverAddress = "192.168.0.10"
    let serverPort: UInt32 = 35000
    
    //let serverAddress = "localhost"
    //let serverPort: UInt32 = 3000
  
    private var inStream: NSInputStream?
    private var outStream: NSOutputStream?
    
    override init() {
        super.init()

    }

    func open() {
        self.close()
        
        var cfIStream: Unmanaged<CFReadStream>?
        var cfOStream: Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(nil, self.serverAddress, self.serverPort, &cfIStream, &cfOStream)
        
        self.inStream = cfIStream!.takeRetainedValue()
        self.outStream = cfOStream!.takeRetainedValue()
        
        self.inStream?.delegate = self
        self.outStream?.delegate = self
        
        self.inStream?.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        self.outStream?.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        
        self.inStream?.open()
        self.outStream?.open()
    }
    
    func write(data: String) -> Bool {
        if data.isEmpty || self.outStream ==  nil {
            return false
        }
        
        if self.outStream!.streamStatus != NSStreamStatus.Open {
            return false
        }
        
        if !self.outStream!.hasSpaceAvailable {
            return false
        }
        
        let length = data.lengthOfBytesUsingEncoding(NSASCIIStringEncoding)
        return self.outStream!.write(data, maxLength: length) == length
    }
    
    func close() {
        self.inStream?.close()
        self.outStream?.close()
    }
    
    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        
        if(aStream == self.inStream) {
            self.inputStreamEvent(eventCode)
        } else if(aStream == self.outStream) {
            self.outputStreamEvent(eventCode)
        }
    }
    
    func inputStreamEvent(event: NSStreamEvent) {
        NSLog("\(event)")
        switch event {
        case NSStreamEvent.OpenCompleted:
            self.delegate?.didConnect(self)
            break
        case NSStreamEvent.HasBytesAvailable:
            self.processInputStreamData()
            break
        case NSStreamEvent.EndEncountered:
            self.delegate?.didDisconnect(self)
            break
        case NSStreamEvent.ErrorOccurred:
            self.delegate?.cantConnect(self)
            break
        default:
            break
        }
    }
    
    func outputStreamEvent(event: NSStreamEvent) {
        
    }
    
    func processInputStreamData() {
        guard let stream = self.inStream else {
            return
        }
        
        var buffer = [UInt8](count: 1024, repeatedValue: 0)
        let length = stream.read(&buffer, maxLength: buffer.count)
        if length == -1 || length == 0{
            self.delegate?.didDisconnect(self)
            return
        } else {
            self.delegate?.didReceivedData(self, string: NSString(bytes: &buffer, length: length, encoding: NSASCIIStringEncoding)! as String)
        }
    }
}