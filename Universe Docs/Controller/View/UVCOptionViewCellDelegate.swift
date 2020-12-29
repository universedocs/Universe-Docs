//
//  UVCCollectionViewCellDelegate.swift
//  UniversalViewController
//
//  Created by Kumar Muthaiah on 18/12/18.
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
import UIKit

protocol UVCOptionViewCellDelegate {
    func uvcOptionViewCellOptionSelected(index: Int, level: Int, senderModel: Any, sender: Any)
    func uvcOptionViewCellSelected(index: Int, level: Int, senderModel: [Any],optionViewCell: OptionViewCell)
    func uvcOptionViewCellEditOk(index: Int, level: Int, senderModel: Any, sender: Any)
    func uvcOptionViewCellTextFieldDidChange(index: Int, level: Int, senderModel: Any, sender: Any)
    func uvcOptionViewCellConnfigureOption(index: Int, level: Int, senderModel: [Any], uvcUIViewControllerItemCollection: UVCUIViewControllerItemCollection)
    func optionViewCellEvent(uvcViewItemType: String, eventName: String, uvcObject: Any, uiObject: Any, optionViewCell: OptionViewCell)
    
}
