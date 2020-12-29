//
//  UVCTextController.swift
//  UniversalViewController
//
//  Created by Kumar Muthaiah on 06/11/18.
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

public class UVCOnOffController {
    public var delegate: UVCViewControllerDelegate?
    public var uvcViewController: UVCViewController?
    
    public func getView(uvcOnOff: UVCOnOff, view: UIView, uvcUIViewControllerCollection: UVCUIViewControllerItemCollection, uvcViewItemTag: Int, iEditableMode: Bool) -> UIView {
        let uvcMeasurementArray = uvcOnOff.uvcText.uvcMeasurement
        var xAxis = 0
        var yAxis = 0
        var width = 0
        for uvcMeasurement in uvcMeasurementArray {
            if uvcMeasurement.type == UVCMeasurementType.XAxis.name {
                xAxis = Int(uvcMeasurement.value)
            } else if uvcMeasurement.type == UVCMeasurementType.YAxis.name {
                yAxis = Int(uvcMeasurement.value)
            } else if uvcMeasurement.type == UVCMeasurementType.Width.name {
                width = Int(uvcMeasurement.value)
            } 
        }
//        if iEditableMode == false {
//            uvcOnOff.isEditable = false
//        }
        if uvcOnOff.isEditable == false {
            
            let label = UILabel(frame: CGRect(x: CGFloat(xAxis), y: CGFloat(yAxis), width: CGFloat(width), height: CGFloat(view.bounds.height)))
            label.text = uvcOnOff.isSelected ? "On" : "Off"
            label.textColor =  getUIColor(uvcColorName: uvcOnOff.uvcText.uvcTextStyle.textColor, type: "Foreground")
            label.backgroundColor =  getUIColor(uvcColorName: uvcOnOff.uvcText.uvcTextStyle.backgroundColor, type: "Background")
            if uvcOnOff.uvcText.isMultiline {
                label.numberOfLines = 2
                label.lineBreakMode = .byWordWrapping
            }
            let uvcTextSize = uvcOnOff.uvcText.uvcTextSize
            label.tag = uvcViewItemTag
            label.isUserInteractionEnabled = true
            
            let uvcTexStyle = uvcOnOff.uvcText.uvcTextStyle
            let intensity = uvcTexStyle.intensity
            if intensity == 0 {
                if uvcTextSize.uvcTextSizeType == UVCTextSizeType.Tiny.name {
                    label.font = UIFont(name: "Helvetica",
                                        size: CGFloat( UVCTextSizeType.Tiny.size))
                } else if uvcTextSize.uvcTextSizeType == UVCTextSizeType.Small.name {
                    label.font = UIFont(name: "Helvetica",
                                        size: CGFloat( UVCTextSizeType.Small.size))
                } else if uvcTextSize.uvcTextSizeType == UVCTextSizeType.Regular.name {
                    label.font = UIFont(name: "Helvetica",
                                        size: CGFloat( UVCTextSizeType.Regular.size))
                }  else {
                    label.font = UIFont(name: "Helvetica",
                                    size: CGFloat(uvcTextSize.value))
                }
            } else if intensity > 50 {
                if uvcTextSize.uvcTextSizeType == UVCTextSizeType.Tiny.name {
                    label.font = UIFont(name: "Helvetica-Bold",
                                        size: CGFloat( UVCTextSizeType.Tiny.size))
                } else if uvcTextSize.uvcTextSizeType == UVCTextSizeType.Small.name {
                    label.font = UIFont(name: "Helvetica-Bold",
                                        size: CGFloat( UVCTextSizeType.Small.size))
                } else if uvcTextSize.uvcTextSizeType == UVCTextSizeType.Regular.name {
                    label.font = UIFont(name: "Helvetica-Bold",
                                        size: CGFloat( UVCTextSizeType.Regular.size))
                } else {
                    label.font = UIFont(name: "Helvetica-Bold",
                                    size: CGFloat(uvcTextSize.value))
                }
            }
            let uvcUIOnOff = UVCUIOnOff()
            uvcUIOnOff.name = uvcOnOff.name
            uvcUIOnOff.uiLabel = label
            uvcUIViewControllerCollection.uvcUIOnOff.append(uvcUIOnOff)
            
            return label
        
        } else {
            let uiSwitch = UISwitch(frame: CGRect(x: CGFloat(xAxis), y: CGFloat(yAxis), width: CGFloat(width), height: CGFloat(view.bounds.height)))
            uiSwitch.setOn(uvcOnOff.isSelected, animated: false)
            uiSwitch.tag = uvcViewItemTag
            uiSwitch.isUserInteractionEnabled = true
            let uvcUIOnOff = UVCUIOnOff()
            uvcUIOnOff.name = uvcOnOff.name
            uvcUIOnOff.uiSwitch = uiSwitch
            uvcUIOnOff.uiSwitch.addTarget(self, action: #selector(handleSwitchPressed(_:)), for: .touchUpInside)
            uvcUIViewControllerCollection.uvcUIOnOff.append(uvcUIOnOff)

           return uiSwitch
        }
        
    }
    
    private func getUIColor(uvcColorName: String?, type: String) -> UIColor {
        if uvcColorName == nil {
            if type == "Foreground" {
                return UIColor.black
            } else {
                return UIColor.white
            }
        } else {
            return UIColor(hexString: UVCColor.get(uvcColorName!).hexString)
        }
    }
    
    @objc private func handleSwitchPressed(_ sender: UISwitch) {
        let uvcOnOff = uvcViewController!.getOnOff(tag: sender.tag)
        delegate!.uvcViewControllerEvent(uvcViewItemType: "UVCViewItemType.OnOff", eventName: "UVCViewItemEvent.OnOff.Pressed", uvcObject: uvcOnOff as Any, uiObject: sender)
    }
}
