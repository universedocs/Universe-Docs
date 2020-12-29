//
//  UVCChoiceItem.swift
//  Universe Docs View
//
//  Created by Kumar Muthaiah on 12/02/19.
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

public class UVCChoiceItem : Codable {
    public var _id: String = ""
    public var name: String = ""
    /// Tick mark button followed by a button
    public var choiceMark = UVCButton()
    public var text = UVCText()
    // Object details of the text in the choice item
    public var editObjectCategoryIdName: String = ""
    public var editObjectIdName: String = ""
    public var editObjectName: String = ""
    public var parentId = [String]()
    public var childrenId = [String]()
    public var path = [String]()

    public init() {
        
    }
}
