//
//  OBD_IITests.swift
//  OBD-IITests
//
//  Created by Manuel Stampfl on 13.11.15.
//  Copyright © 2015 mani1337. All rights reserved.
//

import XCTest

class OBD_IITests: XCTestCase {
    
    let entry = OBDIIPIDEntry(mode: 0x01, pid: 0x1D, responseLength: 1, identifier: OBDIISpeed) { data in
        return Double(data[0])
    }
    
    func testDebug() {
        let res = "AT Z\r>01 01>34".split(">")
        for i in res {
            NSLog(i)
        }
    }
    
    func testCreateOBDIIMessage() {
        XCTAssert(entry.createMessage() == "01 1D 1")
    }
    
    func testParseOBDIIMessage() {
        XCTAssert((try? entry.parseMessage("41 1D 10")) == 16.0)
    }
}
