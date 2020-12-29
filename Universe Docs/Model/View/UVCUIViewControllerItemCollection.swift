//
//  UVCUIViewControllerCollection.swift
//  UniversalViewController
//
//  Created by Kumar Muthaiah on 08/11/18.
//  Copyright © 2018 Kumar Muthaiah. All rights reserved.
//

import Foundation

public class UVCUIViewControllerItemCollection {
    public var uvcUILabel = [UVCUILabel]()
    public var uvcUITextField = [UVCUITextField]()
    public var uvcUIButton = [UVCUIButton]()
    public var uvcUIView = [UVCUIView]()
    public var uvcUIImageView = [UVCUIImageView]()
    public var uvcUIStackView = [UVCUIStackView]()
    public var uvcUIProgressIndicator = [UVCUIProgressIndicator]()
    public var uvcUIOnOff = [UVCUIOnOff]()
    
    public init() {
        
    }
    
    
    
    public func removeAll() {
        uvcUIView.removeAll()
        uvcUILabel.removeAll()
        uvcUIButton.removeAll()
        uvcUIImageView.removeAll()
        uvcUIStackView.removeAll()
        uvcUITextField.removeAll()
        uvcUIProgressIndicator.removeAll()
    }
    
    
    public func getOnOff(tag: Int, name: String) -> UVCUIOnOff? {
        for uvcUIOnOffLocal in uvcUIOnOff {
            if uvcUIOnOffLocal.uiSwitch.tag == tag || name == uvcUIOnOffLocal.name  {
                return uvcUIOnOffLocal
            }
        }
        
        return nil
    }
    
    public func getTextField(tag: Int, name: String) -> UVCUITextField? {
        for uvcUITextField in uvcUITextField {
            if uvcUITextField.uiTextField.tag == tag || name == uvcUITextField.name  {
                return uvcUITextField
            }
        }
        
        return nil
    }
    
    public func getTextField() -> UVCUITextField? {
        if uvcUITextField.count > 0 {
           return uvcUITextField[0]
       }
        
        return nil
    }
    
    
    public func getLabel(tag: Int, name: String) -> UVCUILabel? {
        for uvcUILabel in uvcUILabel {
            if uvcUILabel.uiLabel.tag == tag || name == uvcUILabel.name {
                return uvcUILabel
            }
        }
        
        return nil
    }
    
    public func getButton(tag: Int, name: String) -> UVCUIButton? {
        for uvcUIButton in uvcUIButton {
            print(uvcUIButton.uiButton.tag)
            if uvcUIButton.uiButton.tag == tag || name == uvcUIButton.name {
                return uvcUIButton
            }
        }
        
        return nil
    }
    
    public func getPhoto(tag: Int, name: String) -> UVCUIImageView? {
        for uvcUIImageView in uvcUIImageView {
            print(uvcUIImageView.uiView.tag)
            if uvcUIImageView.uiView.subviews[0].tag == tag || name == uvcUIImageView.name {
                return uvcUIImageView
            }
        }
        
        return nil
    }
    
    
    public func getPhoto() -> UVCUIImageView? {
        if uvcUIImageView.count > 0 {
            return uvcUIImageView[0]
            
        }
        
        return nil
    }
    
    public func getProgressIndicator(tag: Int, name: String) -> UVCUIProgressIndicator? {
        for uvcUIProgressIndicator in uvcUIProgressIndicator {
            print(uvcUIProgressIndicator.uiActivityIndicatorView.tag)
            if uvcUIProgressIndicator.uiActivityIndicatorView.tag == tag || name == uvcUIProgressIndicator.name {
                return uvcUIProgressIndicator
            }
        }
        
        return nil
    }
}
