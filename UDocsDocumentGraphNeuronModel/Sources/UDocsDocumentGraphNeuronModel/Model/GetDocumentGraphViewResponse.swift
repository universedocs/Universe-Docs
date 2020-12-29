//
//  GetDocumentGraphViewResponse.swift
//  Universe Docs Brain
//
//  Created by Kumar Muthaiah on 11/09/19.
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
import UDocsViewModel
import UDocsDocumentModel

public class GetDocumentGraphViewResponse : Codable {
    public var _id: String = ""
    public var documentItemViewInsertData = [DocumentGraphItemViewData]()
    public var documentItemViewDeleteData = [DocumentGraphItemViewData]()
    public var documentItemViewChangeData = [DocumentGraphItemViewData]()
    public var documentItemViewHideData = [DocumentGraphItemViewData]()
    public var udcViewItemCollection = UDCViewItemCollection()
    public var objectControllerResponse = ObjectControllerResponse()
    public var documentTitle: String = ""
    public var isDeleteAllView: Bool = false
    public var currentNodeIndex = 0
    public var currentItemIndex = 0
    public var currentSentenceIndex = 0
    public var currentLevel = 0
    public var toolbarView = UVCToolbarView()
    public var objectControllerView = UVCToolbarView()
    public var objectControllerOptions = [UVCOptionViewModel]()
    public var documentOptions = [UVCOptionViewModel]()
    public var documentItemOptions = [UVCOptionViewModel]()
    public var categoryOptions = [String: [UVCOptionViewModel]]()
    public var photoOptions = [UVCOptionViewModel]()
    public var documentLanguage: String = ""
    public var isDocumentNotFound: Bool = false
    public var isToCheckIfFound: Bool = false
    public var documentId: String = ""
    public var documentIdName: String = ""
    public var isShowPopup: Bool = false
    public var isDetailedView: Bool = false
    public var isFormatView: Bool = false
    public var popupUdcDocumentTypeIdName: String = ""
    public var isConfigurationView: Bool = false
    
    public init() {
        
    }
}
