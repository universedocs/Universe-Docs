//
//  UDCSortOrder.swift
//  BSON
//
//  Created by Kumar Muthaiah on 15/11/18.
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

public class UDBCSortOrder : Codable {
    static public var None = UDBCSortOrder("UDBCSortOrder.None", "None")
    static public var Ascending = UDBCSortOrder("UDBCSortOrder.Ascending", "Ascending")
    static public var Descending = UDBCSortOrder("UDBCSortOrder.Descending", "Descending")
    public var _id: String = ""
    public var name: String = ""
    public var description: String = ""
    
    private init(_ name: String, _ description: String) {
        self.name = name
        self.description = description
    }
    
}
