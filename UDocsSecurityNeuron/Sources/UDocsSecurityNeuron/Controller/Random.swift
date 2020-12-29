//
//  File.swift
//  UniversalSecurityController
//
//  Created by Kumar Muthaiah on 25/10/18.
//
//Copyright 2020 Kumar Muthaiah
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
import Foundation
/**
 Random is a pluggable random number generator that depends on the OS provided.
 */
public protocol Random {
    
    /// Get a byte array of random UInt8s
    func random(numBytes: Int) -> [UInt8]
    
    /// Get a random int8
    var int8: Int8 { get }
    
    /// Get a random uint8
    var uint8: UInt8 { get }
    
    /// Get a random int16
    var int16: Int16 { get }
    
    /// Get a random uint16
    var uint16: UInt16 { get }
    
    /// Get a random int32
    var int32: Int32 { get }
    
    /// Get a random uint32
    var uint32: UInt32 { get }
    
    /// Get a random int64
    var int64: Int64 { get }
    
    /// Get a random uint64
    var uint64: UInt64 { get }
    
    /// Get a random int
    var int: Int { get }
    
    /// Get a random uint
    var uint: UInt { get }
    
    /// Get a random string usable for authentication purposes
    var secureToken: String { get }
}
