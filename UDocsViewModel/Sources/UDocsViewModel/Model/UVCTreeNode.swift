//
//  UVCTreeNode.swift
//  UniversalViewController
//
//  Created by Kumar Muthaiah on 07/12/18.
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
//import UIKit

public class UVCTreeNode : Codable {
    public var _id: String = ""
    public var isOptionAvailable: Bool = false
    public var isEditable: Bool = false
    public var parentId = [String]()
    public var children = [UVCTreeNode]()
    public var childrenId = [String]()
    public var isChidlrenOnDemandLoading: Bool = false
    public var isReference: Bool = false
    public var level: Int = 0
    public var uvcViewModel = UVCViewModel()
    public var modelValuePath: String = ""
    public var language: String = "en"
    public var path = [String]()
    public var pathIdName = [String]()
    public var objectId: String?
    public var objectType: String = ""
    
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
    
//    public func getTextWidth(index: Int, section: Int, isParentNode: Bool) -> CGFloat {
//            var width = CGFloat(0)
//            var nonEditableText = false
//            var isBold = false
//            var font: UIFont?
//            if isParentNode {
//                font = UIFont(name: "Helvetica", size: CGFloat( 24))
//            } else {
//                font = UIFont(name: "Helvetica", size: CGFloat( UVCTextSizeType.Regular.size))
//            }
//            let fontAttributes = [NSAttributedString.Key.font: font]
//
//            for uvcText in uvcViewModel.uvcViewItemCollection.uvcText {
//                if uvcText.uvcTextStyle.intensity > 50 {
//                    isBold = true
//                }
//                if uvcText.isOptionAvailable {
//                    nonEditableText = true
//                    if uvcText.uvcViewItemType == "UVCViewItemType.Choice" {
//                        width += (uvcText.value as! NSString).size(withAttributes: fontAttributes).width + 45
//                    } else {
//                        width += (uvcText.value as! NSString).size(withAttributes: fontAttributes).width + 10
//                    }
//                    if isBold {
//                        width += 5
//                    }
//                    if isParentNode {
//                        width += 15
//                    }
//                } else if uvcText.isEditable {
//                    width += (uvcText.helpText as! NSString).size(withAttributes: fontAttributes).width + 15
//                }else {
//                    nonEditableText = true
//                    if uvcText.value.count == 1 {
//                        width += (uvcText.value as NSString).size(withAttributes: fontAttributes).width + 5
//                    } else {
//                        width += (uvcText.value as NSString).size(withAttributes: fontAttributes).width + 5
//                    }
//                }
//            }
//            for uvcPhoto in uvcViewModel.uvcViewItemCollection.uvcPhoto {
//                for uvcMeasurement in uvcPhoto.uvcMeasurement {
//                    if uvcMeasurement.type == UVCMeasurementType.Width.name {
//                        width = width + CGFloat(uvcMeasurement.value)
//                        break
//                    }
//                }
//            }
//            for uvcButton in uvcViewModel.uvcViewItemCollection.uvcButton {
//                if uvcButton.uvcPhoto != nil {
//                    for uvcPhoto in uvcViewModel.uvcViewItemCollection.uvcPhoto {
//                        if uvcPhoto.name == "CheckBox" || uvcPhoto.name == "Elipsis" || uvcPhoto.name == "LeftDirectionArrow" || uvcPhoto.name == "UpDirectionArrow" || uvcPhoto.name == "DownDirectionArrow" || uvcPhoto.name == "RightDirectionArrow" {
//                            width += 5
//                        }
//                    }
//                } else {
//                    width += (uvcButton.value as NSString).size(withAttributes: fontAttributes).width + 25
//                }
//            }
//
//            if nonEditableText && !isBold {
//                return width
//            } else {
//                return width + 5
//            }
//        }
//
//
//        public func getTextHeight(index: Int, section: Int, isParentNode: Bool) -> CGFloat {
//            var height = CGFloat(0)
//            var font: UIFont?
//            if isParentNode {
//                font = UIFont(name: "Helvetica", size: CGFloat( 24))
//            } else {
//                font = UIFont(name: "Helvetica", size: CGFloat( UVCTextSizeType.Regular.size))
//            }
//            let fontAttributes = [NSAttributedString.Key.font: font]
//            var rowLength = CGFloat(0)
//            for uvcText in uvcViewModel.uvcViewItemCollection.uvcText {
//                height += (uvcText.value as NSString).size(withAttributes: fontAttributes).height
//                rowLength = CGFloat(uvcViewModel.rowLength!)
//            }
//            if height == 0 {
//                for uvcButton in uvcViewModel.uvcViewItemCollection.uvcButton {
//                    height += (uvcButton.value as NSString).size(withAttributes: fontAttributes).height
//                }
//                height += 10
//            }
//            for uvcPhoto in uvcViewModel.uvcViewItemCollection.uvcPhoto {
//                for uvcMeasurement in uvcPhoto.uvcMeasurement {
//                    if uvcMeasurement.type == UVCMeasurementType.Height.name {
//                        height = height + CGFloat(uvcMeasurement.value)
//                        break
//                    }
//                }
//            }
//            if rowLength > 1 {
//                height = rowLength * height
//            }
//            if isParentNode {
//                height += 10
//            }
//    //        return height + 40
//            return height + 5
//        }
   
}
