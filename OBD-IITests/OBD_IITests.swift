//
//  OBD_IITests.swift
//  OBD-IITests
//
//  Created by Manuel Stampfl on 13.11.15.
//  Copyright © 2015 mani1337. All rights reserved.
//

import XCTest

class OBD_IITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreateOBDIIMessage() {
        let entry = OBDIIPIDEntry(mode: 0x01, pid: 0x1D, responseLength: 1, identifier: OBDIISpeed) { data in
            return Double(data[0])
        }
        
        XCTAssert(entry.createMessage() == "01 1D 1\r")
        XCTAssert((try? entry.parseMessage("41 1D 10")) == 16.0)
    }
}
