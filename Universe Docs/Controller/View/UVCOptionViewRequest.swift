//
//  UVCOptionViewRequest.swift
//  Universe Docs
//
//  Created by Kumar Muthaiah on 29/01/19.
//  Copyright © 2019 Universe Docs. All rights reserved.
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
import UDocsBrain
import UDocsViewModel

public class UVCOptionViewRequest : Codable {
    public var _id: String = ""
    public var operationName: String = ""
    public var rightButton = [String]()
    public var path = [String]()
    public var pathIdName = [String]()
    public var uvcOptionViewModel: [UVCOptionViewModel]?
    public var isAppended: Bool = false
    public var errorMessage: String = ""
    public var title: String = ""
    public var binaryData: Data?
    
    public init() {
        
    }
}
