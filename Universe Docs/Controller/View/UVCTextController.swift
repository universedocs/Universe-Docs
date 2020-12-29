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

extension UITextField {
    func customBorder() {
        let border = CALayer()
        let lineWidth = CGFloat(0)
        border.backgroundColor = UIColor.clear.cgColor
//        border.backgroundColor = UIColor.white.cgColor
//        border.borderColor = UIColor.black.cgColor
        border.borderWidth = lineWidth
        border.cornerRadius = 0
        border.style = .none
        self.layer.addSublayer(border)
//        self.layer.masksToBounds = true
    }
    
}

public protocol DeleteBackwardDelegate {
    func deleteBackward();
}

public class CustomTextField : UITextField {
    public var deleteBackwardDelegate: DeleteBackwardDelegate?
    override public func deleteBackward() {
        if text == "" {
            deleteBackwardDelegate?.deleteBackward()
        }
        // do something for every backspace
        super.deleteBackward()
    }
}
public class UVCTextController : DeleteBackwardDelegate {
    public var delegate: UVCViewControllerDelegate?
    public var uvcViewController: UVCViewController?
    private var textFieldTaped: Bool = false
    private var textFieldBeginEditing: Bool = false
    public func getView(uvcText: UVCText, view: UIView, uvcUIViewControllerCollection: UVCUIViewControllerItemCollection, uvcViewItemTag: Int, iEditableMode: Bool) -> UIView {
        let uvcMeasurementArray = uvcText.uvcMeasurement
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
        var isEditable = iEditableMode
        if isEditable == false {
            uvcText.isEditable = false
        } else if isEditable == true && uvcText.isEditable == false {
            isEditable = false
        }
        var uvcTextType: String = ""
        if uvcText.uvcViewItemType != nil {
            uvcTextType = uvcText.uvcViewItemType
        }
        
        if uvcText.isEditable && !uvcText.isOptionAvailable {
            let textField = CustomTextField(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(width), height: CGFloat(view.bounds.height)))
            textField.deleteBackwardDelegate = self
            textField.text = uvcText.value
            textField.borderStyle = .roundedRect
//            textField.customBorder()
            textField.backgroundColor = getUIColor(uvcColorName: uvcText.uvcTextStyle.backgroundColor, type: "Background")
            textField.textColor = getUIColor(uvcColorName: uvcText.uvcTextStyle.textColor, type: "Foreground")
            textField.placeholder = uvcText.helpText
            textField.layer.cornerRadius = 2
            textField.layer.borderWidth = 1
            textField.textColor = UIColor { traitCollection in
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
            textField.backgroundColor = UIColor { traitCollection in
                        // 2
                        switch traitCollection.userInterfaceStyle {
                        case .dark:
                          // 3
                          return UIColor(white: 0.3, alpha: 1.0)
                        default:
                          // 4
                            return UIColor.white
                        }
                    }
//            textField.tintColor = .clear
//            UITextField.appearance().tintColor = .black
            textField.tintColor = getUIColor(uvcColorName: UVCColor.get("UVCColor.DarkGreen").name, type: "Foreground")
            textField.layer.borderColor = getUIColor(uvcColorName: UVCColor.get("UVCColor.DarkGreen").name, type: "Foreground").cgColor
            textField.font = UIFont(name: "Helvetica",
                                             size: CGFloat( UVCTextSizeType.Regular.size - 2))
            textField.borderRect(forBounds: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(width), height: CGFloat(height)))
            textField.isUserInteractionEnabled = true
            textField.tag = uvcViewItemTag
            let uvcUITextField = UVCUITextField()
            uvcUITextField.name = uvcText.name
            uvcUITextField.uiTextField = textField
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(textFieldTaped(_:)))
            uvcUITextField.uiTextField.isUserInteractionEnabled = true
            uvcUITextField.uiTextField.addGestureRecognizer(tapGestureRecognizer)
            uvcUITextField.uiTextField.addTarget(self, action: #selector(textFieldDidBeginEditing(_:)), for: .editingDidBegin)
            uvcUITextField.uiTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
//            uvcUITextField.uiTextField.addTarget(self, action: #selector(textAllEditingEvents(_:)), for: .allEditingEvents)
            uvcUIViewControllerCollection.uvcUITextField.append(uvcUITextField)
            return textField
        } else {
            let label = UILabel(frame: CGRect(x: CGFloat(xAxis), y: CGFloat(yAxis), width: CGFloat(width), height: CGFloat(view.bounds.height)))
            label.text = uvcText.value
            label.font.withSize(CGFloat(uvcText.uvcTextSize.value))
//            var textColor = uvcText.uvcTextStyle.textColor
//            if textColor == "UVCColor.Black" {
//                if view.traitCollection.userInterfaceStyle == .dark {
//                    textColor = "UVCColor.White"
//                }
//            }
                
            label.textColor =  getUIColor(uvcColorName: uvcText.uvcTextStyle.textColor, type: "Foreground")
//            label.backgroundColor =  getUIColor(uvcColorName: uvcText.uvcTextStyle.backgroundColor, type: "Background")
//            label.textColor = UIColor { [self] traitCollection in
//                                                // 2
//                                                switch traitCollection.userInterfaceStyle {
//                                                case .dark:
//                                                  // 3
//                                                    return getUIColor(uvcColorName: uvcText.uvcTextStyle.textColor, type: "Foreground")
//                                                default:
//                                                  // 4
//                                                    return return getUIColor(uvcColorName: uvcText.uvcTextStyle.textColor, type: "Foreground")
//                                                }
//                                            }
            label.backgroundColor = UIColor { traitCollection in
                                    // 2
                                    switch traitCollection.userInterfaceStyle {
                                    case .dark:
                                      // 3
                                      return UIColor(white: 0.1, alpha: 1.0)
//                                        return UIColor.black
                                    default:
                                      // 4
                                        return UIColor.white
                                    }
                                }
            if uvcText.isMultiline {
                label.numberOfLines = 2
                label.lineBreakMode = .byWordWrapping
            }
            let uvcTextSize = uvcText.uvcTextSize
            label.tag = uvcViewItemTag
            label.isUserInteractionEnabled = true
//            label.layer.borderWidth = 1
//            label.layer.borderColor = UIColor.red.cgColor
            
            let uvcTexStyle = uvcText.uvcTextStyle
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
                }  else if uvcTextSize.uvcTextSizeType == UVCTextSizeType.ExtraLarge.name {
                    label.font = UIFont(name: "Helvetica",
                                        size: CGFloat( UVCTextSizeType.ExtraLarge.size))
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
                } else if uvcTextSize.uvcTextSizeType == UVCTextSizeType.ExtraLarge.name {
                    label.font = UIFont(name: "Helvetica-Bold",
                                        size: CGFloat( UVCTextSizeType.ExtraLarge.size))
                } else {
                    label.font = UIFont(name: "Helvetica-Bold",
                                    size: CGFloat(uvcTextSize.value))
                }
            }
                
            let uvcUILabel = UVCUILabel()
            uvcUILabel.name = uvcText.name
            uvcUILabel.uiLabel = label
            uvcUIViewControllerCollection.uvcUILabel.append(uvcUILabel)
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(labelTaped(_:)))
            uvcUILabel.uiLabel.isUserInteractionEnabled = true
            uvcUILabel.uiLabel.addGestureRecognizer(tapGestureRecognizer)
            return label
        }
//        } else {
//
//            return getTextField(uvcText: uvcText, view: view, uvcUIViewControllerCollection: uvcUIViewControllerCollection, uvcViewItemTag: uvcViewItemTag, iEditableMode: isEditable, xAxis: xAxis, yAxis: yAxis, width: width, height: height)
        
//            else {
//                let uvcButton = UVCButton()
//                uvcButton.name = uvcText.name
//                uvcButton.uvcEditType = uvcText.uvcEditType
//                uvcButton.editObjectIdName = uvcText.editObjectIdName
//                uvcButton.editObjectName = uvcText.editObjectName
//                uvcButton.editObjectCategoryIdName = uvcText.editObjectCategoryIdName
//                uvcButton.isEditable = uvcText.isEditable
//                uvcViewController!.uvcViewModel?.uvcViewItemCollection.uvcButton.append(uvcButton)
//                return getButton(uvcText: uvcText, view: view, uvcUIViewControllerCollection: uvcUIViewControllerCollection, uvcViewItemTag: uvcViewItemTag, iEditableMode: isEditable, xAxis: xAxis, yAxis: yAxis, width: width, height: height)
//            }
//
           
//        }
        
    }
    
   
//    private func getTextField(uvcText: UVCText, view: UIView, uvcUIViewControllerCollection: UVCUIViewControllerItemCollection, uvcViewItemTag: Int, iEditableMode: Bool, xAxis: Int, yAxis: Int, width: Int, height: Int) -> UIView {
//        let textField = UITextField(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(width), height: CGFloat(view.bounds.height)))
//
//        textField.text = uvcText.value
//        textField.borderStyle = .roundedRect
//        textField.customBorder()
//        textField.backgroundColor = getUIColor(uvcColorName: uvcText.uvcTextStyle.backgroundColor, type: "Background")
//        textField.textColor = getUIColor(uvcColorName: uvcText.uvcTextStyle.textColor, type: "Foreground")
//        textField.placeholder = uvcText.helpText
//        textField.layer.cornerRadius = 2
//        textField.layer.borderWidth = 1
//        textField.font = UIFont(name: "Helvetica",
//                                         size: CGFloat( UVCTextSizeType.Regular.size - 2))
//        textField.borderRect(forBounds: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(width), height: CGFloat(height)))
//        textField.isUserInteractionEnabled = true
//        textField.tag = uvcViewItemTag
//        let uvcUITextField = UVCUITextField()
//        uvcUITextField.name = uvcText.name
//        uvcUITextField.uiTextField = textField
//        uvcUIViewControllerCollection.uvcUITextField.append(uvcUITextField)
//        return textField
//    }
//
//    private func getButton(uvcText: UVCText, view: UIView, uvcUIViewControllerCollection: UVCUIViewControllerItemCollection, uvcViewItemTag: Int, iEditableMode: Bool, xAxis: Int, yAxis: Int, width: Int, height: Int) -> UIView {
//        let button = UIButton(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(width), height: CGFloat(view.bounds.height)))
//        let value = uvcText.value
//        button.setTitle(value, for: .normal)
//        button.isUserInteractionEnabled = true
//        button.titleLabel!.font = UIFont(name: "Helvetica",
//                                                    size: CGFloat( UVCTextSizeType.Regular.size))
//        button.tag = uvcViewItemTag
//        button.backgroundColor = getUIColor(uvcColorName: "UVCColor.Green", type: "Background")
//        button.backgroundRect(forBounds: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(width), height: CGFloat(30)))
//        button.contentEdgeInsets = UIEdgeInsets(top: 5,left: 5,bottom: 5,right: 5)
//        button.setTitleColor(UIColor.black, for: .normal)
//        button.layer.cornerRadius = 2
//        let uvcUIButton = UVCUIButton()
//        uvcUIButton.name = uvcText.name
//        uvcUIButton.uiButton = button
//        uvcUIButton.uiButton.addTarget(self, action: #selector(handleButtonPressed(_:)), for: .touchUpInside)
//        uvcUIViewControllerCollection.uvcUIButton.append(uvcUIButton)
//        return button
//    }

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
                                                return UIColor.black
                                            default:
                                              // 4
                                                return UIColor.white
                                            }
                                        }
                    }
    }
    
    @objc private func labelTaped(_ tapGestureRecognizer: UITapGestureRecognizer) {
        let uiLabel = tapGestureRecognizer.view as! UILabel
        let uvcText = uvcViewController!.getLabel(tag: uiLabel.tag)
        delegate!.uvcViewControllerEvent(uvcViewItemType: "UVCViewItemType.Text", eventName: "UVCViewItemEvent.Word.Taped", uvcObject: uvcText as Any, uiObject: uiLabel)
    }
    
    @objc private func textFieldTaped(_ tapGestureRecognizer: UITapGestureRecognizer) {
        textFieldTaped = true
        let uiTextField = tapGestureRecognizer.view as! UITextField
        let uvcText = uvcViewController!.getTextField(tag: uiTextField.tag)
        delegate!.uvcViewControllerEvent(uvcViewItemType: "UVCViewItemType.Text", eventName: "UVCViewItemEvent.Word.Editable.Taped", uvcObject: uvcText as Any, uiObject: uiTextField)
    }
    
    @objc public func textFieldDidBeginEditing(_ textField: UITextField) {
        textFieldBeginEditing = true
        let uvcText = uvcViewController!.getTextField(tag: textField.tag)
        delegate!.uvcViewControllerEvent(uvcViewItemType: "UVCViewItemType.Text", eventName: "UVCViewItemEvent.Word.Editable.DidBeginEditing", uvcObject: uvcText as Any, uiObject: textField)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        let uvcText = uvcViewController!.getTextField(tag: textField.tag)
        delegate!.uvcViewControllerEvent(uvcViewItemType: "UVCViewItemType.Text", eventName: "UVCViewItemEvent.Word.Editable.DidChange", uvcObject: uvcText as Any, uiObject: textField)
    }
    
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        let uvcText = uvcViewController!.getTextField(tag: textField.tag)
        delegate!.uvcViewControllerEvent(uvcViewItemType: "UVCViewItemType.Text", eventName: "UVCViewItemEvent.Word.Editable.ShouldReturn", uvcObject: uvcText as Any, uiObject: textField)
        return true
    }
    
    @objc func textFieldDidEndEditing(_ textField: UITextField) -> Bool {   //delegate method
        let uvcText = uvcViewController!.getTextField(tag: textField.tag)
        delegate!.uvcViewControllerEvent(uvcViewItemType: "UVCViewItemType.Text", eventName: "UVCViewItemEvent.Word.Editable.DidEndEditing", uvcObject: uvcText as Any, uiObject: textField)
        return true
    }
    
    // Working but need to do it properly
    public func deleteBackward() {
//        let uvcText = uvcViewController!.getTextField(tag: textField.tag)
//        let uvcText = UVCText()
//                        delegate!.uvcViewControllerEvent(uvcViewItemType: "UVCViewItemType.Text", eventName: "UVCViewItemEvent.Word.Editable.BackSpacePressed", uvcObject: uvcText as Any, uiObject: UITextField())
    }
  

}
