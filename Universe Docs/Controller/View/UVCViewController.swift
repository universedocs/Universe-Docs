//
//  UVCViewController.swift
//  UniversalViewController
//
//  Created by Kumar Muthaiah on 07/11/18.
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
import UDocsUtility
import UDocsBrain
import UDocsViewModel

extension UITextField {
    func setCursor(position: Int) {
        let position = self.position(from: beginningOfDocument, offset: position)!
        selectedTextRange = textRange(from: position, to: position)
    }
}

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
}

public class UVCViewController {
    public var uvcUIViewControllerItemCollection = UVCUIViewControllerItemCollection()
    public var uvcViewItemTag: Int = 1
    public var uvcViewModel: UVCViewModel?
    public var view: UIView?
    public var iEditableMode: Bool = false
    public var delegate: UVCViewControllerDelegate?
    public var uvcControllerCollection = [String: Any]()
    
    public init() {
        
    }
    
    private func getUVCController(uvcViewItemType: String) -> Any? {
        if uvcControllerCollection[uvcViewItemType] == nil {
            if uvcViewItemType == "UVCViewItemType.Text" {
                uvcControllerCollection[uvcViewItemType] = UVCTextController()
            } else  if uvcViewItemType == "UVCViewItemType.Button" {
                uvcControllerCollection[uvcViewItemType] = UVCButtonController()
            } else  if uvcViewItemType == "UVCViewItemType.OnOff" {
                uvcControllerCollection[uvcViewItemType] = UVCOnOffController()
            } else  if uvcViewItemType == "UVCViewItemType.Photo" {
                uvcControllerCollection[uvcViewItemType] = UVCPhotoController()
            } else  if uvcViewItemType == "UVCViewItemType.ProgressIndicator" {
                uvcControllerCollection[uvcViewItemType] = UVCProgressIndicator()
            }
            
        }
        
        return uvcControllerCollection[uvcViewItemType]
    }
    
    public func getUdcViewItem() -> String {
        if uvcViewModel!.name.hasPrefix("UVCViewItemType.Text") {
            return "UVCViewItemType.Text"
        } else if uvcViewModel!.name.hasPrefix("UVCViewItemType.Text") {
            return "UVCViewItemType.Text"
        } else if uvcViewModel!.name.hasPrefix("UVCViewItemType.Choie") {
            return "UVCViewItemType.Choie"
        }
        
        return "UVCViewItemType.Text"
    }
    
    public func getSubIndex(tag: Int) -> Int {
        var subIndex: Int = 0
        var found: Bool = false
        for uvcTable in (uvcViewModel?.uvcViewItemCollection.uvcTable)! {
            for uvcRow in uvcTable.uvcTableRow {
                for uvcColumnm in uvcRow.uvcTableColumn {
                    for (uvcItemIndex, uvcItem) in uvcColumnm.uvcViewItem.enumerated() {
                        for
                            uvcuiLabel in uvcUIViewControllerItemCollection.uvcUILabel {
                                if uvcuiLabel.uiLabel.tag == tag && uvcItem.name == uvcuiLabel.name {
                                    found = true
                                    subIndex = uvcItemIndex
                                    break
                                }
                        }
                        for
                            uvcuiTextField in uvcUIViewControllerItemCollection.uvcUITextField {
                                if uvcuiTextField.uiTextField.tag == tag && uvcItem.name == uvcuiTextField.name  {
                                    found = true
                                    subIndex = uvcItemIndex
                                    break
                                }
                        }
                        for
                            uvcuiButton in uvcUIViewControllerItemCollection.uvcUIButton {
                                if uvcuiButton.uiButton.tag == tag && uvcItem.name == uvcuiButton.name  {
                                    found = true
                                    subIndex = uvcItemIndex
                                    break
                                }
                        }
                        for
                            uvcuiOnOff in uvcUIViewControllerItemCollection.uvcUIOnOff {
                                if uvcuiOnOff.uiSwitch.tag == tag && uvcItem.name == uvcuiOnOff.name  {
                                    found = true
                                    subIndex = uvcItemIndex
                                    break
                                }
                        }
                        for
                            uvcuiImageView in uvcUIViewControllerItemCollection.uvcUIImageView {
                                if uvcuiImageView.uiView.tag == tag && uvcItem.name == uvcuiImageView.name  {
                                    found = true
                                    subIndex = uvcItemIndex
                                    break
                                }
                        }
                        if found { break }
                    }
                    if found { break }
                }
                if found { break }
            }
            if found { break }
        }
        
        return subIndex
    }
    
    public func getLabel(tag: Int) -> UVCText? {
        let uvcUIText = uvcUIViewControllerItemCollection.getLabel(tag: tag, name: "")
        if uvcUIText == nil {
            return nil
        }
        for uvct in (uvcViewModel?.uvcViewItemCollection.uvcText)! {
            if uvct.name == uvcUIText!.name {
                return uvct
            }
        }
        
        return nil
    }
    
    public func getTextField(tag: Int) -> UVCText? {
        let uvcUIText = uvcUIViewControllerItemCollection.getTextField(tag: tag, name: "")
        
        for uvct in (uvcViewModel?.uvcViewItemCollection.uvcText)! {
            if uvct.name == uvcUIText!.name {
                return uvct
            }
        }
        
        return nil
    }
    
    public func getTextField() -> UVCText? {
        let uvcUIText = uvcUIViewControllerItemCollection.getTextField()
        for uvct in (uvcViewModel?.uvcViewItemCollection.uvcText)! {
            if uvct.name == uvcUIText!.name {
                return uvct
            }
        }
        
        return nil
      }
      
    
    public func getOnOff(tag: Int) -> UVCOnOff? {
        let uvcUIOnOff = uvcUIViewControllerItemCollection.getOnOff(tag: tag, name: "")
        if uvcUIOnOff == nil {
            return nil
        }
        
        for uvcoo in (uvcViewModel?.uvcViewItemCollection.uvcOnOff)! {
            if uvcoo.name == uvcUIOnOff!.name {
                return uvcoo
            }
        }
        
        return nil
    }
    
    public func getChoiceItem(tag: Int) -> UVCText? {
        let uvcUIButton = uvcUIViewControllerItemCollection.getButton(tag: tag, name: "")
        if uvcUIButton == nil {
            return nil
        }
        for uvct in (uvcViewModel?.uvcViewItemCollection.uvcText)! {
            if uvct.name == uvcUIButton!.name {
                return uvct
            }
        }
        
        return nil
    }
    
    
    public func getButton(tag: Int) -> UVCButton? {
        let uvcUIButton = uvcUIViewControllerItemCollection.getButton(tag: tag, name: "")
        if uvcUIButton == nil {
            return nil
        }
        for uvcb in (uvcViewModel?.uvcViewItemCollection.uvcButton)! {
            if uvcb.name == uvcUIButton!.name {
                return uvcb
            }
        }
        
        return nil
    }
    
    public func getPhoto(tag: Int) -> UVCPhoto? {
        let uvcuiImageView = uvcUIViewControllerItemCollection.getPhoto(tag: tag, name: "")
        if uvcuiImageView == nil {
            return nil
        }
        for uvcp in (uvcViewModel?.uvcViewItemCollection.uvcPhoto)! {
            if uvcp.name == uvcuiImageView!.name {
                return uvcp
            }
        }
        
        return nil
    }
    
    
    public func getPhoto() -> UVCPhoto? {
        let uvcuiImageView = uvcUIViewControllerItemCollection.getPhoto()
        if uvcuiImageView == nil {
            return nil
        }
        for uvcp in (uvcViewModel?.uvcViewItemCollection.uvcPhoto)! {
            if uvcp.name == uvcuiImageView!.name {
                return uvcp
            }
        }
        
        return nil
    }
    public func getImageView() -> UIImageView? {
        let uvcuiImageView = uvcUIViewControllerItemCollection.getPhoto()
        return uvcuiImageView?.uiView.subviews[0] as! UIImageView
    }
    
    public func getOptionButton(tag: Int) -> UVCButton? {
        let uvcUIButton = uvcUIViewControllerItemCollection.getButton(tag: tag, name: "")
        if uvcUIButton == nil {
            return nil
        }
        for uvcb in (uvcViewModel?.uvcViewItemCollection.uvcButton)! {
            if (uvcUIButton != nil) && uvcb.name == uvcUIButton!.name {
                return uvcb
            }
        }
        
        return nil
    }
    
    public func getView(uvcViewModel: UVCViewModel, view: UIView, iEditableMode: Bool) throws -> UIView {
        var returnView: UIView?
        self.view = view
        uvcUIViewControllerItemCollection.removeAll()
        uvcControllerCollection.removeAll()
        self.uvcViewModel = nil
        do {
            let jsonUtility = JsonUtility<UVCViewModel>()
            self.uvcViewModel = uvcViewModel

            
            
            let uvcViewItemArray = uvcViewModel.uvcViewItem
            var tableFound: Bool = false
            for item in uvcViewItemArray {
                if(item.type == "UVCViewItemType.Table") {
                    tableFound = true
                    break
                }
            }
            if tableFound == true {
                let uvcViewCollection = uvcViewModel.uvcViewItemCollection
                returnView = try getTable(uvcViewCollection: uvcViewCollection, uvcViewTable: uvcViewCollection.uvcTable[0], view: view, iEditableMode: iEditableMode)
            }
        } catch {
            print(error)
            throw error
        }
        if returnView == nil {
            throw UVCViewError.failedToGenerateView
        }
        
        return returnView!
    }
    
    public func getTable(uvcViewCollection: UVCViewItemCollection, uvcViewTable: UVCTable, view: UIView, iEditableMode: Bool) throws -> UIView {
        let stackView   = UIStackView()
        stackView.axis  = NSLayoutConstraint.Axis.vertical
        stackView.distribution  = UIStackView.Distribution.fillProportionally
        if (uvcViewTable.uvcAlignment.count > 0) && uvcViewTable.uvcAlignment[0].uvcPositionType == UVCPositionType.Center.name {
            stackView.alignment = UIStackView.Alignment.center
        } else {
            stackView.alignment = UIStackView.Alignment.leading
        }
        stackView.spacing   = 16.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isUserInteractionEnabled = true
        
        
        let uvcUIStackView = UVCUIStackView()
        uvcUIStackView.name = uvcViewTable.name
        uvcUIStackView.uiStackView = stackView
        stackView.tag = uvcViewItemTag
        uvcViewItemTag += 1
        let uvcViewTableRowArray = uvcViewTable.uvcTableRow
        for uvcViewTableRow in uvcViewTableRowArray {
            let uvcViewTableColumnArray = uvcViewTableRow.uvcTableColumn
            
            
            for uvcViewTableColumn in uvcViewTableColumnArray {
                let uvcViewItemArray = uvcViewTableColumn.uvcViewItem
                
                let columnCount = uvcViewItemArray.count
                let stackSubView = UIStackView()

                if (columnCount > 1) {
                    
                    if uvcViewTableColumn.uvcDirectionType == UVCDirectionType.Vertical.name {
                        stackSubView.axis  = NSLayoutConstraint.Axis.vertical
                    } else {
                        stackSubView.axis  = NSLayoutConstraint.Axis.horizontal
                    }
                    stackSubView.distribution  = UIStackView.Distribution.fillProportionally
                    stackSubView.spacing   = 5.0
                    stackSubView.isUserInteractionEnabled = true
                    stackSubView.translatesAutoresizingMaskIntoConstraints = false
                    let uvcUIStackView = UVCUIStackView()
                    uvcUIStackView.name = uvcViewTable.name
                    uvcUIStackView.uiStackView = stackSubView
                    uvcUIViewControllerItemCollection.uvcUIStackView.append(uvcUIStackView)

                    
                    uvcViewItemTag += 1
                }
                
                for uvcViewItem in uvcViewItemArray {
                    if uvcViewItem.uvcAlignment.uvcPositionType == UVCPositionType.Left.name {
                        stackSubView.alignment = UIStackView.Alignment.leading
                    } else {
                        stackSubView.alignment = UIStackView.Alignment.center
                    }
                    

                    if (columnCount > 1) {

                        if uvcViewItem.type == "UVCViewItemType.Text" || uvcViewItem.type == "UVCViewItemType.Text" {
                            let uvcViewTextCollectionArray = uvcViewCollection.uvcText
                            
                            let uitol = try getText(name: uvcViewItem.name, uvcTextArray: uvcViewTextCollectionArray, view: view, uvcUIViewControllerCollection: uvcUIViewControllerItemCollection, uvcViewItemTag: uvcViewItemTag, iEditableMode: iEditableMode)
                            stackSubView.addArrangedSubview(uitol)
                            
                        } else if uvcViewItem.type == "UVCViewItemType.Button" {
                            let uvcViewButtonCollectionArray = uvcViewCollection.uvcButton
                            var noNeedButton = false
                            for uvcButton in uvcViewButtonCollectionArray {
                                if (uvcButton.value == "..." || ((uvcButton.uvcPhoto != nil) && uvcButton.uvcPhoto!.name == "DeleteRow")) && !iEditableMode && uvcButton.name != "OptionsButton" {
                                    noNeedButton = true
                                    break
                                }
                            }
                            if noNeedButton {
                                continue
                            }
                            let uib = try getButton(name: uvcViewItem.name, uvcButtonArray: uvcViewButtonCollectionArray, view: view, uvcUIViewControllerCollection: uvcUIViewControllerItemCollection, uvcViewItemTag: uvcViewItemTag, iEditableMode: iEditableMode)
                            
                            stackSubView.addArrangedSubview(uib)
                            
                        } else if uvcViewItem.type == "UVCViewItemType.Photo" {
                            let uvcViewPictureCollectionArray = uvcViewCollection.uvcPhoto
                            
                            let uip = try getPhoto(name: uvcViewItem.name, uvcPhotoArray: uvcViewPictureCollectionArray, view: view, uvcUIViewControllerCollection: uvcUIViewControllerItemCollection, uvcViewItemTag: uvcViewItemTag, iEditableMode: iEditableMode)
                            
                            stackSubView.addArrangedSubview(uip)
                            
                        } else if uvcViewItem.type == "UVCViewItemType.Table" {
                            let uvcViewTextCollectionArray = uvcViewCollection.uvcTable
                            
                            let uit = try getTableWithName(name: uvcViewItem.name, uvcTableArray: uvcViewTextCollectionArray, view: view, iEditableMode: iEditableMode, uvcViewItemCollection: uvcViewCollection)
                            stackSubView.addArrangedSubview(uit)
                            
                        } else if uvcViewItem.type == "UVCViewItemType.ProgressIndicator" {
                            let uvcProgressIndicatorArray = uvcViewCollection.uvcProgressIndicator
                            
                            let uipi = try getProgressIndicator(name: uvcViewItem.name, uvcProgressIndicatorArray: uvcProgressIndicatorArray, view: view, uvcUIViewControllerCollection: uvcUIViewControllerItemCollection, uvcViewItemTag: uvcViewItemTag, iEditableMode: iEditableMode)
                            stackSubView.addArrangedSubview(uipi)
                        } else if uvcViewItem.type == "UVCViewItemType.OnOff" {
                            let uvcOnOffArray = uvcViewCollection.uvcOnOff
                            
                            let uic = try getOnOff(name: uvcViewItem.name, uvcOnOffArray: uvcOnOffArray, view: view, uvcUIViewControllerCollection: uvcUIViewControllerItemCollection, uvcViewItemTag: uvcViewItemTag, iEditableMode: iEditableMode)
                            stackSubView.addArrangedSubview(uic)
                        }
                        
                        
                    } else {
                        if uvcViewItem.type == "UVCViewItemType.Text" || uvcViewItem.type == "UVCViewItemType.Text" {
                            let uvcViewTextCollectionArray = uvcViewCollection.uvcText
                            
                            let uitol = try getText(name: uvcViewItem.name, uvcTextArray: uvcViewTextCollectionArray, view: view, uvcUIViewControllerCollection: uvcUIViewControllerItemCollection, uvcViewItemTag: uvcViewItemTag, iEditableMode: iEditableMode)
                            
                            stackView.addArrangedSubview(uitol)
                            
                        } else if uvcViewItem.type == "UVCViewItemType.Button" {
                            let uvcViewButtonCollectionArray = uvcViewCollection.uvcButton
                            var noNeedButton = false
                            for uvcButton in uvcViewButtonCollectionArray {
                                if (uvcButton.value == "..." ||  ((uvcButton.uvcPhoto != nil) && uvcButton.uvcPhoto!.name == "DeleteRow")) && !iEditableMode && uvcButton.name != "OptionsButton" {
                                    noNeedButton = true
                                    break
                                }
                            }
                            if noNeedButton {
                                continue
                            }

                            let uib = try getButton(name: uvcViewItem.name, uvcButtonArray: uvcViewButtonCollectionArray, view: view, uvcUIViewControllerCollection: uvcUIViewControllerItemCollection, uvcViewItemTag: uvcViewItemTag, iEditableMode: iEditableMode)
                            stackView.addArrangedSubview(uib)
                        }else if uvcViewItem.type == "UVCViewItemType.Photo" {
                            let uvcViewPictureCollectionArray = uvcViewCollection.uvcPhoto
                            
                            let uip = try getPhoto(name: uvcViewItem.name, uvcPhotoArray: uvcViewPictureCollectionArray, view: view, uvcUIViewControllerCollection: uvcUIViewControllerItemCollection, uvcViewItemTag: uvcViewItemTag, iEditableMode: iEditableMode)
                            
                            stackView.addArrangedSubview(uip)
                            
                        } else if uvcViewItem.type == "UVCViewItemType.Table" {
                            let uvcViewTextCollectionArray = uvcViewCollection.uvcTable
                            
                            let uit = try getTableWithName(name: uvcViewItem.name, uvcTableArray: uvcViewTextCollectionArray, view: view, iEditableMode: iEditableMode, uvcViewItemCollection: uvcViewCollection)
                            stackView.addArrangedSubview(uit)
                            
                        } else if uvcViewItem.type == "UVCViewItemType.ProgressIndicator" {
                            let uvcProgressIndicatorArray = uvcViewCollection.uvcProgressIndicator
                            
                            let uipi = try getProgressIndicator(name: uvcViewItem.name, uvcProgressIndicatorArray: uvcProgressIndicatorArray, view: view, uvcUIViewControllerCollection: uvcUIViewControllerItemCollection, uvcViewItemTag: uvcViewItemTag, iEditableMode: iEditableMode)
                            stackView.addArrangedSubview(uipi)
                            
                        } else if uvcViewItem.type == "UVCViewItemType.Choice" {
                            let uvcOnOffArray = uvcViewCollection.uvcOnOff
                            
                            let uic = try getOnOff(name: uvcViewItem.name, uvcOnOffArray: uvcOnOffArray, view: view, uvcUIViewControllerCollection: uvcUIViewControllerItemCollection, uvcViewItemTag: uvcViewItemTag, iEditableMode: iEditableMode)
                            stackView.addArrangedSubview(uic)
                        }
                    }
                    uvcViewItemTag += 1
                }
                if (columnCount > 1) {
                    stackView.addArrangedSubview(stackSubView)
                }
            }
            
        }
        
        return stackView
    }
    
    public func getText(name: String, uvcTextArray: [UVCText], view: UIView, uvcUIViewControllerCollection: UVCUIViewControllerItemCollection, uvcViewItemTag: Int, iEditableMode: Bool) throws -> UIView {
        var uiText: UIView?
        let uvcTextController = getUVCController(uvcViewItemType: "UVCViewItemType.Text") as! UVCTextController
        uvcTextController.uvcViewController = self
        uvcTextController.delegate = delegate
        for uvcText in uvcTextArray {
            if uvcText.name == name {
                uiText = uvcTextController.getView(uvcText: uvcText, view: view, uvcUIViewControllerCollection: uvcUIViewControllerCollection, uvcViewItemTag: uvcViewItemTag, iEditableMode: iEditableMode)
                print("Text Tag: \(uiText!.tag)")
                break
            }
        }
        if  uiText == nil {
            print(name)
            throw UVCViewError.viewItemNotFound(name)
        }
        
        return uiText!
    }
    
    public func getButton(name: String, uvcButtonArray: [UVCButton], view: UIView, uvcUIViewControllerCollection: UVCUIViewControllerItemCollection, uvcViewItemTag: Int, iEditableMode: Bool) throws -> UIView {
        var uiButton: UIView?
        let uvcButtonController = getUVCController(uvcViewItemType: "UVCViewItemType.Button") as! UVCButtonController
        uvcButtonController.uvcViewController = self
        uvcButtonController.delegate = delegate
        for uvcButton in uvcButtonArray {
            if uvcButton.name == name {
                uiButton = uvcButtonController.getView(uvcButton: uvcButton, view: view, uvcUIViewControllerCollection: uvcUIViewControllerCollection, uvcViewItemTag: uvcViewItemTag, iEditableMode: iEditableMode)
                break
            }
        }
        if  uiButton == nil {
            print(name)
            throw UVCViewError.viewItemNotFound(name)
        }
        
        return uiButton!
    }
    
    
    public func getPhoto(name: String, uvcPhotoArray: [UVCPhoto], view: UIView, uvcUIViewControllerCollection: UVCUIViewControllerItemCollection, uvcViewItemTag: Int, iEditableMode: Bool) throws -> UIView {
        var uiImageView: UIView?
        let uvcPhotoController = getUVCController(uvcViewItemType: "UVCViewItemType.Photo") as! UVCPhotoController
        uvcPhotoController.uvcViewController = self
        uvcPhotoController.delegate = delegate
        for uvcPhoto in uvcPhotoArray {
            if uvcPhoto.name == name {
                uiImageView = uvcPhotoController.getView(uvcPhoto: uvcPhoto, view: view, uvcUIViewControllerCollection: uvcUIViewControllerCollection, uvcViewItemTag: uvcViewItemTag, iEditableMode: iEditableMode)
                break
            }
        }
        if  uiImageView == nil {
            print(name)
            throw UVCViewError.viewItemNotFound(name)
        }
        
        return uiImageView!
    }
    
    
    public func getProgressIndicator(name: String, uvcProgressIndicatorArray: [UVCProgressIndicator], view: UIView, uvcUIViewControllerCollection: UVCUIViewControllerItemCollection, uvcViewItemTag: Int, iEditableMode: Bool) throws -> UIView {
        var uiProgressIndicator: UIView?
        let uvcProgressIndicatorController = getUVCController(uvcViewItemType: "UVCViewItemType.ProgressIndicator") as! UVCProgressIndicatorController
        for uvcProgressIndicator in uvcProgressIndicatorArray {
            if uvcProgressIndicator.name == name {
                uiProgressIndicator = uvcProgressIndicatorController.getView(uvcProgressIndicator: uvcProgressIndicator, view: view, uvcUIViewControllerCollection: uvcUIViewControllerCollection, uvcViewItemTag: uvcViewItemTag, iEditableMode: iEditableMode)
                break
            }
        }
        if  uiProgressIndicator == nil {
            print(name)
            throw UVCViewError.viewItemNotFound(name)
        }
        
        return uiProgressIndicator!
    }
    
    
    public func getOnOff(name: String, uvcOnOffArray: [UVCOnOff], view: UIView, uvcUIViewControllerCollection: UVCUIViewControllerItemCollection, uvcViewItemTag: Int, iEditableMode: Bool) throws -> UIView {
        var uiChoice: UIView?
        let uvcOnOffController = getUVCController(uvcViewItemType: "UVCViewItemType.OnOff") as! UVCOnOffController
        uvcOnOffController.uvcViewController = self
        uvcOnOffController.delegate = delegate
        for uvcOnOff in uvcOnOffArray {
            if uvcOnOff.name == name {
                uiChoice = uvcOnOffController.getView(uvcOnOff: uvcOnOff, view: view, uvcUIViewControllerCollection: uvcUIViewControllerCollection, uvcViewItemTag: uvcViewItemTag, iEditableMode: iEditableMode)
                print("Tag: \(uiChoice!.tag)")
                break
            }
        }
        if  uiChoice == nil {
            print(name)
            throw UVCViewError.viewItemNotFound(name)
        }
        
        return uiChoice!
    }
    
    public func getTableWithName(name: String, uvcTableArray: [UVCTable], view: UIView, iEditableMode: Bool, uvcViewItemCollection: UVCViewItemCollection) throws -> UIView {
        var stackView: UIView?
        for (indexUvcTable, uvcTable) in uvcTableArray.enumerated() {
            if indexUvcTable == 0 {
                continue
            }
            if uvcTable.name == name {
                stackView = try getTable(uvcViewCollection: uvcViewItemCollection, uvcViewTable: uvcTable, view: view, iEditableMode: iEditableMode)
                break
            }
        }
        
        if stackView == nil {
            print(name)
            throw UVCViewError.viewItemNotFound(name)
        }
        
        return stackView!
    }
    
}
