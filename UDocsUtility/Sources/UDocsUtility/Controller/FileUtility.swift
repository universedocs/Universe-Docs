//
//  FileUtility.swift
//  Universe Docs Brain
//
//  Created by Kumar Muthaiah on 24/07/19.
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
import Cocoa

#if targetEnvironment(macCatalyst)
    import AppKit
#endif

public class FileUtility {
    
    public func writeFile(fileName: String, contents: String)
    {
        #if targetEnvironment(macCatalyst)
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(fileName)
            
            //writing
            do {
                try contents.write(to: fileURL, atomically: false, encoding: .utf8)
            }
            catch {
                print("FileUtility: \(error)")
            }
        }
        #endif
    }
    
    public func getFileLines(fileUrl: String) -> [String] {
        var lines = [String]()
        // make sure the file exists
        guard FileManager.default.fileExists(atPath: fileUrl) else {
            preconditionFailure("file expected at \(fileUrl) is missing")
        }

        // open the file for reading
        // note: user should be prompted the first time to allow reading from this location
        guard let filePointer:UnsafeMutablePointer<FILE> = fopen(fileUrl,"r") else {
            preconditionFailure("Could not open file at \(fileUrl)")
        }

        // a pointer to a null-terminated, UTF-8 encoded sequence of bytes
        var lineByteArrayPointer: UnsafeMutablePointer<CChar>? = nil

        // the smallest multiple of 16 that will fit the byte array for this line
        var lineCap: Int = 0

        // initial iteration
        var bytesRead = getline(&lineByteArrayPointer, &lineCap, filePointer)

        defer {
            // remember to close the file when done
            fclose(filePointer)
        }

        while (bytesRead > 0) {

            // note: this translates the sequence of bytes to a string using UTF-8 interpretation
            let lineAsString = String.init(cString:lineByteArrayPointer!)

            // do whatever you need to do with this single line of text`
            // for debugging, can print it
            lines.append(lineAsString)

            // updates number of bytes read, for the next iteration
            bytesRead = getline(&lineByteArrayPointer, &lineCap, filePointer)
        }
        
        return lines
    }
    
    /**
     
     
     //reading
     do {
     let text2 = try String(contentsOf: fileURL, encoding: .utf8)
     }
     catch {/* error handling here */}
     
     */
    
}
