//
//  UDCHumanLanguage.swift
//  Universe Docs Brain
//
//  Created by Kumar Muthaiah on 29/04/19.
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
// https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes

public class UDCHumanLanguage : Codable {
    static private var data = [String : UDCHumanLanguageType]()
    public var _id: String = ""
    public var idName: String = ""
    public var name: String = ""
    public var alternateName: [String]? = [String]()
    public var code6392: String? = ""
    public var code6393: String? = ""
    public var code6395: String? = ""
    public var code6391: String? = ""
    public var nativeName: [String]? = [String]()
    public var otherName: [String]? = [String]()
    public var language: String = ""
    
    public init() {
        
    }
 
    
}
