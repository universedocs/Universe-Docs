//
//  UVCButtonController.swift
//  UniversalViewController
//
//  Created by Kumar Muthaiah on 07/11/18.
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
import UDocsBrain
import UDocsViewModel

extension UIButton {
    func customBorder() {
        let border = CALayer()
        let lineWidth = CGFloat(1)
        border.backgroundColor = UIColor.white.cgColor
        border.borderColor = UIColor.black.cgColor
        border.borderWidth = lineWidth
        border.cornerRadius = 2
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}

public class UVCButtonController {
    public var delegate: UVCViewControllerDelegate?
    public var uvcViewController: UVCViewController?
    
    public func getView(uvcButton: UVCButton, view: UIView, uvcUIViewControllerCollection: UVCUIViewControllerItemCollection, uvcViewItemTag: Int, iEditableMode: Bool) -> UIView {
        let uvcMeasurementArray = uvcButton.uvcMeasurement
        var xAxis = 0
        var yAxis = 0
        var width = 0
        var height = 0
        for uvcMeasurement in uvcMeasurementArray {
            if uvcMeasurement.type == UVCMeasurementType.XAxis.name {
                xAxis = Int(uvcMeasurement.value)
            } else if uvcMeasurement.type == UVCMeasurementType.YAxis.name {
                yAxis = Int(uvcMeasurement.value)
            } else if uvcMeasurement.type == UVCMeasurementType.Width.name {
                width = Int(uvcMeasurement.value)
            } else if uvcMeasurement.type == UVCMeasurementType.Height.name {
                height = Int(uvcMeasurement.value)
            }
        }
        
        let button = UIButton(frame: CGRect(x: CGFloat(xAxis), y: CGFloat(yAxis), width: CGFloat(width), height: CGFloat(view.bounds.height)))
        let value = uvcButton.value
        
        button.isUserInteractionEnabled = true
        button.tag = uvcViewItemTag
        button.setTitleColor(getUIColor(uvcColorName: uvcButton.uvcTextStyle.textColor, type: "Foreground"), for: .normal)
        button.backgroundColor = getUIColor(uvcColorName: uvcButton.uvcTextStyle.backgroundColor, type: "Background")
        button.titleLabel!.font = UIFont(name: "Helvetica",
                                         size: CGFloat( UVCTextSizeType.Regular.size))
        button.contentEdgeInsets = UIEdgeInsets(top: 5,left: 5,bottom: 5,right: 5)
        button.layer.cornerRadius = 5
//        button.layer.borderWidth = 1
//        button.layer.borderColor = UIColor.white.cgColor
        let uvcUIButton = UVCUIButton()
        if uvcButton.value == "..." {
            button.setImage(UIImage(named: "Elipsis"), for: .normal)
            button.contentMode = .scaleAspectFill
        } else if uvcButton.value == "|" {
            button.setImage(UIImage(named: "ElipsisVertical"), for: .normal)
            button.contentMode = .scaleAspectFill
        } else if uvcButton.value == ">" {
            button.setImage(UIImage(named: "RightArrow"), for: .normal)
            button.contentMode = .scaleAspectFill
        } else if uvcButton.value == "[X]" {
            button.setImage(UIImage(named: "CheckBox"), for: .normal)
            button.contentMode = .scaleAspectFill
        } else if uvcButton.uvcPhoto != nil {
            if !(uvcButton.uvcPhoto?.name.isEmpty)! {
                button.setImage(UIImage(named: (uvcButton.uvcPhoto?.name)!), for: .normal)
            }
            button.contentMode = .scaleAspectFill
        } else {
            button.setTitleColor(.darkGray, for: .normal)
            button.setTitle(value, for: .normal)
        }
        uvcUIButton.name = uvcButton.name
        uvcUIButton.uiButton = button
        uvcUIButton.uiButton.addTarget(self, action: #selector(handleButtonPressed(_:)), for: .touchUpInside)
        uvcUIViewControllerCollection.uvcUIButton.append(uvcUIButton)
        return button
    }
    
    private func getUIColor(uvcColorName: String?, type: String) -> UIColor {
           if uvcColorName == nil {
               return getDefaultColor(type: type)
           } else {
               if uvcColorName!.isEmpty {
                   return getDefaultColor(type: type)
               } else {
                   return UIColor(hexString: UVCColor.get(uvcColorName!).hexString)
               }
           }
       }
    private func getDefaultColor(type: String) -> UIColor {
            if type == "Foreground" {
                            return UIColor { traitCollection in
                                // 2
                                switch traitCollection.userInterfaceStyle {
                                case .dark:
                                  // 3
                                    return UIColor.white
                                default:
                                  // 4
                                    return UIColor.black
                                }
                            }
                        } else {
                            return UIColor { traitCollection in
                                                            // 2
                                                            switch traitCollection.userInterfaceStyle {
                                                            case .dark:
                                                              // 3
                                                                return UIColor(white: 0.1, alpha: 0.1)
                                                            default:
                                                              // 4
                                                                return UIColor.white
                                                            }
                                                        }
                            
                        }
        }
    @objc private func handleButtonPressed(_ sender: UIButton) {
//        let uvcButton = uvcViewController!.getChoiceItem(tag: sender.tag)
        let uvcButton = uvcViewController!.getButton(tag: sender.tag)
        delegate!.uvcViewControllerEvent(uvcViewItemType: "UVCViewItemType.Button", eventName: "UVCViewItemEvent.Button.Pressed", uvcObject: uvcButton as Any, uiObject: sender)
    }
}
