//
//  DocumentGraphChangeItemRequest.swift
//  Universe Docs Brain
//
//  Created by Kumar Muthaiah on 20/02/19.
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
import UDocsDocumentModel

public class DocumentGraphChangeItemRequest : Codable {
    public var _id: String = ""
    /// In which tree level the category exist?
    public var level: Int = 0
    /// In the tree level, which list item?
    public var nodeIndex: Int = 0
    public var itemIndex: Int = 0
    public var subItemIndex: Int = 0
    public var viewModelIndex: Int = 0
    public var sentenceIndex: Int = 0
    public var documentId: String = ""
    public var item: String = ""
    public var itemId: String = ""
    public var parentId: String = ""
    public var nodeId: String = ""
    public var udcDocumentTypeIdName: String = ""
    public var udcProfile = [UDCProfile]()
    public var optionItemId: String = ""
    public var optionItemNameIndex: Int = 0
    public var optionItemObjectName: String = ""
    public var optionDocumentIdName: String = ""
    public var udcViewItemCollection = UDCViewItemCollection()
    public var objectControllerRequest = ObjectControllerRequest()
    public var upcApplicationProfileId: String = ""
    public var upcCompanyProfileId: String = ""
    public var documentLanguage: String = ""
    public var isDocumentItemEditable: Bool = false
    
    public init() {
        
    }
}


