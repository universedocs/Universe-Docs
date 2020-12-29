//
//  UVCShape.swift
//  Universe Docs Brain
//
//  Created by Kumar Muthaiah on 02/06/19.
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

public class UVCShapeType {
    static public var RectangleHorizontal = UVCShapeType("RectangleHorizontal", "RectangleHorizontal")
    static public var RectangleVertical = UVCShapeType("RectangleVertical", "Rectangle Vertical")
    static public var Square = UVCShapeType("Square", "Square")
    static public var Circle = UVCShapeType("Circle", "Circle")
    static public var Eclipse = UVCShapeType("Eclipse", "Eclipse")
    static public var Triangle = UVCShapeType("Triangle", "Triangle")
    static public var Star = UVCShapeType("Star", "Star")

    public var name: String = ""
    public var description: String = ""
    
    private func getName() -> String {
        return "UVCShapeType"
    }
    
    private init(_ name: String, _ description: String) {
        self.name = "\(getName()).\(name)"
        self.description = description
    }
}
