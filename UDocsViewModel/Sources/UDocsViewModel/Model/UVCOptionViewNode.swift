//
//  UVCDocumentGraphModel.swift
//  Universe Docs
//
//  Created by Kumar Muthaiah on 24/01/19.
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

public class UVCOptionViewNode : Codable {
    public var _id: String = ""
    public var isEditableMode: Bool = false
    public var uvcViewModel = UVCViewModel()
    public var model: String = ""
    public var objectName: String = ""
    public var path = [String]()
    public var level: Int = 0
    public var language: String = ""
    public var parentId = [String]()
    public var children = [UVCOptionViewNode]()
    public var childrenId = [String]()
    public var isSelected: Bool = false
    public var isCheckBox: Bool = false
    public var isHidden: Bool = false

    
    public init() {
        
    }
    
    public func setText(name: String, value: String) {
        for uvcText in uvcViewModel.uvcViewItemCollection.uvcText {
            if uvcText.name == name {
                uvcText.value = value
            }
        }
    }
    
    public func getText(name: String) -> UVCText? {
        for uvcText in uvcViewModel.uvcViewItemCollection.uvcText {
            if uvcText.name == name {
                return uvcText
            }
        }
        
        return nil
    }
    
    public func setPicture(name: String, pictureName: String) {
        for uvcPhoto in uvcViewModel.uvcViewItemCollection.uvcPhoto {
            if uvcPhoto.name == name {
                uvcPhoto.name = pictureName
            }
        }
    }
    
    public func getPicture(name: String) -> UVCPhoto? {
        for uvcPhoto in uvcViewModel.uvcViewItemCollection.uvcPhoto {
            if uvcPhoto.name == name {
                return uvcPhoto
            }
        }
        
        return nil
    }
    
    
}
