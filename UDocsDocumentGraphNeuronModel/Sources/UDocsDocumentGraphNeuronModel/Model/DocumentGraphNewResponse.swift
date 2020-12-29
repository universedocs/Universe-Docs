//
//  DocumentGraphNewResponse.swift
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
import UDocsViewModel

public class DocumentGraphNewResponse : Codable {
    public var _id: String = ""
    public var documentId: String = ""
    public var documentTitle: String = ""
    public var uvcDocumentGraphModel = [UVCDocumentGraphModel]()
    /// In which tree level
    public var currentLevel: Int = 0
    /// In the tree level, which list item?
    public var currentNodeIndex: Int = 0
    public var currentItemIndex: Int = 0
    public var currentSentenceIndex: Int = 0
    public var toolbarView = UVCToolbarView()
    public var objectControllerView = UVCToolbarView()
    public var objectControllerOptions = [UVCOptionViewModel]()
    public var documentItemOptions = [UVCOptionViewModel]()
    public var documentOptions = [UVCOptionViewModel]()
    public var categoryOptions = [String: [UVCOptionViewModel]]()
    public var photoOptions = [UVCOptionViewModel]()
    public var objectControllerResponse = ObjectControllerResponse()
    public var documentLanguage: String = ""
    
    public init() {
        
    }
}
