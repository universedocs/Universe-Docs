//
//  UVCPicture.swift
//  Universe_Docs_View
//
//  Created by Kumar Muthaiah on 16/12/18.
//  Copyright © 2018 Kumar Muthaiah. All rights reserved.
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

public class UVCPhoto : Codable {
    public var _id: String = ""
    public var name: String = ""
    public var maskName: String?
    public var value: String = ""
    public var isEditable: Bool = false
    public var description: String? = ""
    public var optionObjectCategoryIdName: String = ""
    public var optionObjectIdName: String = ""
    public var optionObjectName: String = ""
    public var uvcText: UVCText?
    public var uvcFillType = UVCFillType.None.name
    public var uvcTextPositionType = UVCPositionType.Bottom.name
    public var isWithText: Bool = false
    public var isBorderEnabled: Bool = false
    public var isSelected: Bool? = false
    public var isSelectable: Bool? = false
    public var borderWidth: Double = 0
    public var borderColor: String = "UVCColor.Black"
    public var uvcPhotoSizeType = UVCPhotoSizeType.Regular.name
    public var uvcLoadingPriorityType = UVCLoadingPriorityType.None.name
    public var uvcMeasurement = [UVCMeasurement]()
    public var uvcPhotoFileType = UVCPhotoFileType.Png.name
    public var uvcShapeType = UVCShapeType.RectangleHorizontal.name
    public var modelValuePath: String = ""
    public var memoryObject: String? = ""
    public var isChanged: Bool? = false
    public var isOptionAvailable: Bool? = false
    public var isDeviceOptionsAvailable: Bool? = false
    public var isCategory: Bool? = false
    public var uvcAlignment = UVCAlignment()
    public var parentId = [String]()
    public var childrenId = [String]()
    public var path = [String]()
    public var binaryData: Data?
    public var isReloaded: Bool = false

    public init() {
    }
    
    public static func getName() -> String {
        return "UVCPhoto"
    }
    
    public func getMeasurement(type: String) -> UVCMeasurement? {
        for measurement in uvcMeasurement {
            if measurement.type == type {
                return measurement
            }
        }
        
        return nil
    }
}
