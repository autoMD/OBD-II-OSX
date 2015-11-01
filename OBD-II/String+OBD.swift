//
//  String+OBD.swift
//  OBD-II
//
//  Created by Manuel Stampfl on 01.11.15.
//  Copyright © 2015 mani1337. All rights reserved.
//

import Foundation

extension String {
    var isValidOBD: Bool {
        return self.toOBD != nil
    }
    
    var toOBD: [UInt8]? {
        if self.isEmpty {
            return nil
        }
        
        var bytes = [UInt8]()
        let tokens = self.characters.split { $0 ==   " " }.map(String.init)
        for token in tokens {
            guard let byte = UInt8(token, radix: 16) else {
                return nil
            }
            
            bytes.append(byte)
        }
        
        return bytes
    }
}