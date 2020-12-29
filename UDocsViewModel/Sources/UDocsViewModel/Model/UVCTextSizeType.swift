//
//  UVCTextSizeType.swift
//  Universe_Docs_View
//
//  Created by Kumar Muthaiah on 31/10/18.
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

public class UVCTextSizeType {
    static public var None = UVCTextSizeType("UVCTextSizeType.None", "None", 0)
    static public var Tiny = UVCTextSizeType("UVCTextSizeType.Tiny", "Tiny", 12)
    static public var Small = UVCTextSizeType("UVCTextSizeType.Small", "Small", 14)
    static public var Regular = UVCTextSizeType("UVCTextSizeType.Regular", "Regular", 17)
    static public var Medium = UVCTextSizeType("UVCTextSizeType.Medium", "Medium", 16)
    static public var Large = UVCTextSizeType("UVCTextSizeType.Large", "Large", 18)
    static public var ExtraLarge = UVCTextSizeType("UVCTextSizeType.ExtraLarge", "ExtraLarge", 20)
    
    public var name: String = ""
    public var description: String = ""
    public var size: Double = 0
    
    private init(_ name: String, _ description: String, _ size: Double) {
        self.name = name
        self.description = description
        self.size = size
    }

}

