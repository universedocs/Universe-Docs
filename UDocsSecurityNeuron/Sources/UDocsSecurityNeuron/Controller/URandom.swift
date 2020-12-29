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

#if os(Linux) || os(FreeBSD)
import Glibc
#else
import Darwin
#endif

/**
 URandom represents a file connection to /dev/urandom on Unix systems.
 /dev/urandom is a cryptographically secure random generator provided
 by the OS.
 */
public class URandom: Random {
    private let file = fopen("/dev/urandom", "r")
    
    /// Random singleton. Keep in mind that using this will leave the file connection open.
    public static let sharedRandom: Random = URandom()
    
    /// Initialize URandom
    public init() {}
    
    deinit {
        fclose(file)
    }
    
    private func read(numBytes: Int) -> [Int8] {
        // Initialize an empty array with numBytes+1 for null terminated string
        var bytes = [Int8](repeating: 0, count: numBytes)
        fread(&bytes, 1, numBytes, file)
        
        return bytes
    }
    
    /// Get a byte array of random UInt8s
    public func random(numBytes: Int) -> [UInt8] {
        return unsafeBitCast(read(numBytes: numBytes), to: [UInt8].self)
    }
    
    /// Get a random int8
    public var int8: Int8 {
        return Int8(read(numBytes: 1)[0])
    }
    
    /// Get a random uint8
    public var uint8: UInt8 {
        return UInt8(bitPattern: int8)
    }
    
    /// Get a random int16
    public var int16: Int16 {
        let bytes = read(numBytes: 2)
        return UnsafeMutableRawPointer(mutating: bytes).assumingMemoryBound(to: Int16.self).pointee
    }
    
    /// Get a random uint16
    public var uint16: UInt16 {
        return UInt16(bitPattern: int16)
    }
    
    /// Get a random int32
    public var int32: Int32 {
        let bytes = read(numBytes: 4)
        return UnsafeMutableRawPointer(mutating: bytes).assumingMemoryBound(to: Int32.self).pointee
    }
    
    /// Get a random uint32
    public var uint32: UInt32 {
        return UInt32(bitPattern: int32)
    }
    
    /// Get a random int64
    public var int64: Int64 {
        let bytes = read(numBytes: 8)
        return UnsafeMutableRawPointer(mutating: bytes).assumingMemoryBound(to: Int64.self).pointee
    }
    
    /// Get a random uint64
    public var uint64: UInt64 {
        return UInt64(bitPattern: int64)
    }
    
    /// Get a random int
    public var int: Int {
        let bytes = read(numBytes: MemoryLayout<Int>.size)
        return UnsafeMutableRawPointer(mutating: bytes).assumingMemoryBound(to: Int.self).pointee
    }
    
    /// Get a random uint
    public var uint: UInt {
        return UInt(bitPattern: int)
    }
    
    /// Get a random string usable for authentication purposes
    public var secureToken: String {
        return Data(bytes: random(numBytes: 16)).base64UrlEncodedString
    }
}

extension Data {
    var base64UrlEncodedString: String {
        return base64EncodedString()
            .replacingOccurrences(of: "=", with: "")
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
    }
}
