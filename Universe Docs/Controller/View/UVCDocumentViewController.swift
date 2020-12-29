//
//  UVCRecipeViewController2.swift
//  Universe Docs
//
//  Created by Kumar Muthaiah on 26/01/19.
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
import UIKit
import Foundation
import UDocsBrain
import UDocsUtility
import UDocsDocumentUtility
import UDocsViewUtility
import UDocsViewModel
import UDocsNeuronModel
import UDocsOptionMapNeuronModel
import UDocsDocumentGraphNeuronModel
import UDocsDocumentModel
import UDocsDocumentItemNeuronModel
import UDocsGrammarNeuronModel
import UDocsPhotoNeuronModel
import UDocsDocumentMapNeuronModel
import PDFGenerator

public class UVCDocumentViewController : UVCDetailViewCellDelegate,  OptionViewControllerDelegate, SearchOptionDelegate {
    
    
    
    
    var detailViewController: DetailViewController?
    private var optionViewController: OptionViewController?
    private var udcGrammarUtility = UDCGrammarUtility()
    private var isActivityInProgress: Bool = false
    
    private var processingSentence: Bool = false
    private var uvcViewGenerator = UVCViewGenerator()
    private var searchOptionSelection = [false, false, true, false, false]
    private var userProcessingText: Bool = false
    private var isSearchActive: Bool = false
    public static var punctuation : [String] = [
        "~","`","!","@","#","$","%","^","&",
        "*","(",")","-","_","=","+","[","{",
        "]","}","\\","|",";",":","\"","'",
        "<",",",".",">","/","?"
    ]
    
    private func processSelectedItems(itemList: inout [UVCOptionViewModel]) {
        for ovmli in itemList {
            if ovmli.childrenId.count > 0 {
                processSelectedItems(itemList: &ovmli.children)
            }
            if ovmli.isMultiSelect || ovmli.isSingleSelect {
                if ovmli.idName.hasPrefix("UDCHumanLanguage.") {
                    if ApplicationSetting.DocumentLanguage?.lowercased() == ovmli.idName {
                        ovmli.isSelected = true
                    } else {
                        ovmli.isSelected = false
                    }
                } else if ovmli.idName.hasPrefix("UDCDocumentType.") {
                    if ApplicationSetting.DocumentType?.lowercased() == ovmli.idName {
                        ovmli.isSelected = true
                    } else {
                        ovmli.isSelected = false
                    }
                }
            }
        }
    }
    
    public func optionButtonPressed(_ sender: Any) {
        if isActivityInProgress || detailViewController!.documentOptionsOptionViewModelList.count == 0 {
            return
        }
        let uiBarButtonItem = sender as! UIBarButtonItem
        if uiBarButtonItem.image != nil || uiBarButtonItem.image == UIImage(named: "Elipsis") {
            detailViewController!.showPopover(category: detailViewController!.optionTitle["UDCOptionMap.DocumentOptions"]!, uvcOptionViewModel: detailViewController!.documentOptionsOptionViewModelList, width: 350, height: 300, sender: sender, delegate: detailViewController! as UIPopoverPresentationControllerDelegate, optionDelegate: self, goToOption: "", isDismissedAutomatically: false, optionViewControllerName: "UDCOptionMap.DoumentOptions", rightButton: ["", "", ""], idName: "UDCOptionMap.DocumentOptions", operationName: "UDCOptionMap.DocumentOptions", documentGraphItemSearchRequest: nil, documentGraphItemReferenceRequest: nil, typeRequest: nil, documentGraphItemViewData: nil, documentMapSearchDocumentRequest: nil)
        } else if uiBarButtonItem.title == detailViewController!.optionLabel["UDCOptionMapNode.Done"] {
            if detailViewController!.isPopup {
                CallBrainControllerNeuron.tabNotificationCount -= 1
                detailViewController!.removeTab(name: DetailViewController.sourceNameTabItemName[detailViewController!.sourceName]!)
                detailViewController!.isPopup = false
                detailViewController!.popupUdcDocumentTypeIdName = ""
                detailViewController!.masterViewController?.detailViewController = detailViewController!.parentDetailViewController
            } else {
                detailViewController!.setEditable(editable: false)
                getDocumentView(editMode: detailViewController!.isEditableMode, objectType: ApplicationSetting.DocumentType!, isToGetDuplicate: false, isToCheckIfFound: false, language: nil, isToLaunchDetailedView: false, isToLaunchConfigurationView: false, isDocumentMapView: false, isFormatView: false)
            }
        } else if uiBarButtonItem.title == detailViewController!.optionLabel["UDCOptionMapNode.SearchForDocument"] {
            let documentMapSearchDocumentRequest = DocumentMapSearchDocumentRequest()
            documentMapSearchDocumentRequest.udcDocumentId = detailViewController!.documentId
            detailViewController!.showPopover(category: "", uvcOptionViewModel: nil, width: 350, height: 300, sender: nil, delegate: detailViewController!, optionDelegate: self, goToOption: "", isDismissedAutomatically: false, optionViewControllerName: "Document Search", rightButton: ["", "", ""], idName: "", operationName: "DocumentMapNeuron.Search.Document", documentGraphItemSearchRequest: nil, documentGraphItemReferenceRequest: nil, typeRequest: nil, documentGraphItemViewData: nil, documentMapSearchDocumentRequest: documentMapSearchDocumentRequest)
        }
    }
    
    public func configureView() {
        if detailViewController == nil {
            return
        }
        if !detailViewController!.isPopup {
            if let detailItem = detailViewController!.detailItem {
                if detailViewController!.detailItem?.operationName == "DocumentView.Get.DocumentOptions" {
                    detailViewController!.groupUVCViewItemType = "UVCViewItemType.Text"
                    getDocumentOptions()
                } else if detailViewController!.detailItem?.operationName == "DocumentView.GetDocument" {
                    detailViewController!.setEditable(editable: detailItem.isEditable)
                    detailViewController!.documentId = detailItem.uvcTreeNode.objectId!
                    detailViewController!.documentMapNodeId = detailItem.uvcTreeNode._id
                    detailViewController!.documentMapPathIdName.append(contentsOf: detailItem.uvcTreeNode.pathIdName)
                    ApplicationSetting.DocumentType = detailItem.uvcTreeNode.objectType
                    ApplicationSetting.DocumentLanguage = detailItem.uvcTreeNode.language
                    getDocumentView(editMode: detailViewController!.isEditableMode, objectType: detailItem.uvcTreeNode.objectType, isToGetDuplicate: false, isToCheckIfFound: false, language: nil, isToLaunchDetailedView: false, isToLaunchConfigurationView: false, isDocumentMapView: false, isFormatView: false)
                } else if detailViewController!.detailItem?.operationName == "DocumentView.DeleteDocument" {
                    detailViewController!.showAlertViewOKCancel(name: "DocumentGraphNeuron.Document.Delete", message: "Do you want to Delete?", data: detailItem)
                }
            } else {
                detailViewController!.neuronName = "DocumentGraphNeuron"
                if let _ = ApplicationSetting.SecurityToken {
                    
                }
            }
        } else {
            if let detailItem = detailViewController!.detailItem {
                detailViewController!.setEditable(editable: detailItem.isEditable)
                detailViewController!.documentId = detailItem.uvcTreeNode.objectId!
                detailViewController!.documentMapNodeId = detailItem.uvcTreeNode._id
                detailViewController!.documentMapPathIdName.append(contentsOf: detailItem.uvcTreeNode.pathIdName)
                ApplicationSetting.DocumentType = detailItem.uvcTreeNode.objectType
                ApplicationSetting.DocumentLanguage = detailItem.uvcTreeNode.language
                getDocumentView(editMode: detailViewController!.isEditableMode, objectType: detailViewController!.popupUdcDocumentTypeIdName, isToGetDuplicate: false, isToCheckIfFound: false, language: nil, isToLaunchDetailedView: false, isToLaunchConfigurationView: false, isDocumentMapView: false, isFormatView: false)
            } else {
                getDocumentView(editMode: detailViewController!.isEditableMode, objectType: detailViewController!.popupUdcDocumentTypeIdName, isToGetDuplicate: false, isToCheckIfFound: false, language: nil, isToLaunchDetailedView: false, isToLaunchConfigurationView: false, isDocumentMapView: false, isFormatView: false)
            }
        }
    }
    
    
    public func getDocumentView(editMode: Bool, objectType: String, isToGetDuplicate: Bool, isToCheckIfFound: Bool, language: String?, isToLaunchDetailedView: Bool, isToLaunchConfigurationView: Bool, isDocumentMapView: Bool, isFormatView: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            
            
            // Send to the server
            let getDocumentGraphViewRequest = GetDocumentGraphViewRequest()
            getDocumentGraphViewRequest.darkMode = self.detailViewController!.view.traitCollection.userInterfaceStyle == .dark
            getDocumentGraphViewRequest.documentId = self.detailViewController!.documentId
            getDocumentGraphViewRequest.documentIdName = self.detailViewController!.documentIdName
            getDocumentGraphViewRequest.editMode = self.detailViewController!.isEditableMode
            getDocumentGraphViewRequest.documentMapNodeId = self.detailViewController!.documentMapNodeId
            getDocumentGraphViewRequest.documentMapPathIdName.append(contentsOf: self.detailViewController!.documentMapPathIdName)
            getDocumentGraphViewRequest.isToCheckIfFound = isToCheckIfFound
            getDocumentGraphViewRequest.isToGetDuplicate = isToGetDuplicate
            getDocumentGraphViewRequest.isDetailedView = isToLaunchDetailedView
            getDocumentGraphViewRequest.isConfigurationView = isToLaunchConfigurationView
            getDocumentGraphViewRequest.isDocumentMapView = isDocumentMapView
            getDocumentGraphViewRequest.isFormatView = isFormatView
            if isToLaunchDetailedView || isToLaunchConfigurationView || isDocumentMapView || isFormatView {
                getDocumentGraphViewRequest.nodeId = self.detailViewController!.uvcDocumentGraphModelList[self.detailViewController!.currentNodeIndex]._id
                if self.detailViewController!.uvcDocumentGraphModelList[self.detailViewController!.currentNodeIndex].parentId.count > 0 {
                    getDocumentGraphViewRequest.parentId = self.detailViewController!.uvcDocumentGraphModelList[self.detailViewController!.currentNodeIndex].parentId[0]
                }
                getDocumentGraphViewRequest.nodeIndex = self.detailViewController!.currentNodeIndex
                // the item left to the search box is the item to get view if it is detailed view
                if self.detailViewController!.uvcDocumentGraphModelList[self.detailViewController!.currentNodeIndex].uvcViewModel.count == 1 {
                    getDocumentGraphViewRequest.itemIndex = 0
                } else {
                    getDocumentGraphViewRequest.itemIndex = self.detailViewController!.currentItemIndex - 1
                }
            }
            var udcDocumentTypeIdName = ""
            if self.detailViewController!.isPopup {
                udcDocumentTypeIdName = self.detailViewController!.popupUdcDocumentTypeIdName
            } else {
                udcDocumentTypeIdName = objectType
            }
            getDocumentGraphViewRequest.udcDocumentTypeIdName = udcDocumentTypeIdName
            
            self.detailViewController!.setCurrentOperation(name: "DocumentGraphNeuron.Document.Get.View")
            if language == nil {
                getDocumentGraphViewRequest.documentLanguage = ApplicationSetting.DocumentLanguage!
            } else {
                if isToGetDuplicate {
                    getDocumentGraphViewRequest.documentLanguage = ApplicationSetting.DocumentLanguage!
                    getDocumentGraphViewRequest.duplicateToDocumentLanguage = language!
                } else {
                    getDocumentGraphViewRequest.documentLanguage = language!
                }
            }
            self.detailViewController!.setCurrentOperationData(data: [self.detailViewController!.getCurrentOperation(): [
                "getDocumentGraphViewRequest" : getDocumentGraphViewRequest,
                "neuronName": self.detailViewController!.neuronName]])
            
            self.detailViewController!.sendRequest(sourceName: self.detailViewController!.sourceName)
        }
    }
    
    public func getCollectionView() -> UICollectionView {
        return detailViewController!.collectionView
    }
    
    public func setImagePickerControllerImage(uiImage: UIImage, uvcPhoto: UVCPhoto) {
        //        let documentGraphGetPhotoRequest = DocumentGraphGetPhotoRequest()
        //        documentGraphGetPhotoRequest.udcPhotoDataId = "5d528f89f5831d3e324c52f4"
        //        detailViewController!.setCurrentOperation(name: "PhotoNeuron.Get.Item.Photo")
        //        detailViewController!.setCurrentOperationData(data: [detailViewController!.getCurrentOperation(): [
        //            "language": ApplicationSetting.DocumentLanguage!,
        //            "documentGraphGetPhotoRequest": documentGraphGetPhotoRequest]])
        //        detailViewController!.sendRequest(source: self)
        
        let documentGraphStorePhotoRequest = DocumentStorePhotoRequest()
        documentGraphStorePhotoRequest.udcPhoto._id = uvcPhoto.optionObjectIdName
        documentGraphStorePhotoRequest.udcDocumentTypeIdName = ApplicationSetting.DocumentType!
        var uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.Width.name
        uvcMeasurement.value = Double(uiImage.size.width)
        documentGraphStorePhotoRequest.udcPhoto.uvcMeasurement.append(uvcMeasurement)
        uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.Height.name
        uvcMeasurement.value = Double(uiImage.size.height)
        documentGraphStorePhotoRequest.udcPhoto.uvcMeasurement.append(uvcMeasurement)
        documentGraphStorePhotoRequest.udcPhoto.uvcPhotoFileType = UVCPhotoFileType.Png.name
        documentGraphStorePhotoRequest.itemIndex = detailViewController!.currentItemIndex - 1
        documentGraphStorePhotoRequest.sentenceIndex = detailViewController!.currentSentenceIndex
        documentGraphStorePhotoRequest.treeLevel = detailViewController!.currentLevel
        documentGraphStorePhotoRequest.nodeIndex = detailViewController!.currentNodeIndex
        
        var pictureNameArray = [String]()
        for (uvcvmIndex, uvcvm) in detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel.enumerated() {
            if uvcvmIndex >= detailViewController!.currentItemIndex + 1 && uvcvm.uvcViewItemCollection.uvcText.count > 0 {
                pictureNameArray.append(uvcvm.uvcViewItemCollection.uvcText[0].value)
            }
        }
        documentGraphStorePhotoRequest.item = pictureNameArray.joined(separator: " ")
        documentGraphStorePhotoRequest.objectControllerRequest.viewConfigPathIdName.append(contentsOf: detailViewController!.viewConfigPathIdName)
        documentGraphStorePhotoRequest.objectControllerRequest.uvcViewItemType = detailViewController!.uvcViewItemType
        documentGraphStorePhotoRequest.objectControllerRequest.editMode = detailViewController!.objectEditMode
        documentGraphStorePhotoRequest.objectControllerRequest.groupUVCViewItemType = detailViewController!.groupUVCViewItemType
        documentGraphStorePhotoRequest.objectControllerRequest.udcViewItemName = detailViewController!.udcViewItemName
        documentGraphStorePhotoRequest.objectControllerRequest.udcViewItemId = detailViewController!.udcViewItemId
        
        detailViewController!.setCurrentOperation(name: "PhotoNeuron.Store.Item.Photo")
        detailViewController!.setCurrentOperationData(data: [detailViewController!.getCurrentOperation(): [
            "language": ApplicationSetting.DocumentLanguage as Any,
            "documentGraphStorePhotoRequest": documentGraphStorePhotoRequest,
            "neuronName": "PhotoNeuron",
            "binaryData": uiImage.pngData() as Any]])
        detailViewController!.sendRequest(sourceName: detailViewController!.sourceName)
        //        let imageBase64 = uiImage.pngData()?.base64EncodedString()
        //        detailViewController!.uvcViewItemType = "UVCViewItemType.Photo"
        //        let documentGraphInsertItemRequest = DocumentGraphInsertItemRequest()
        //        let resolution = CGSize(width: uiImage.size.width * uiImage.scale, height: uiImage.size.height * uiImage.scale)
        //        var uvcMeasurement = UVCMeasurement()
        //        uvcMeasurement.type = UVCMeasurementType.XAxis.name
        //        uvcMeasurement.value = 0
        //        documentGraphInsertItemRequest.udcPhoto.uvcMeasurement.append(uvcMeasurement)
        //        uvcMeasurement = UVCMeasurement()
        //        uvcMeasurement.type = UVCMeasurementType.YAxis.name
        //        uvcMeasurement.value = 0
        //        documentGraphInsertItemRequest.udcPhoto.uvcMeasurement.append(uvcMeasurement)
        //        uvcMeasurement = UVCMeasurement()
        //        uvcMeasurement.type = UVCMeasurementType.Width.name
        //        uvcMeasurement.value = Double(uiImage.size.width)
        //        documentGraphInsertItemRequest.udcPhoto.uvcMeasurement.append(uvcMeasurement)
        //        uvcMeasurement = UVCMeasurement()
        //        uvcMeasurement.type = UVCMeasurementType.Height.name
        //        uvcMeasurement.value = Double(uiImage.size.height)
        //        documentGraphInsertItemRequest.udcPhoto.uvcMeasurement.append(uvcMeasurement)
        //        insertItem(section: detailViewController!.currentNodeIndex, index: detailViewController!.currentItemIndex, level: detailViewController!.currentLevel, searchText: "Tick Mark", itemData: imageBase64!, uvOptionViewModel: UVCOptionViewModel(), documentGraphInsertItemRequestParam: documentGraphInsertItemRequest)
    }
    
    private func documentNew() {
        ApplicationSetting.CursorMode = "false"
        let documentGraphNewRequest = DocumentGraphNewRequest()
        documentGraphNewRequest.udcDocumentTypeIdName = ApplicationSetting.DocumentType!
        detailViewController!.setCurrentOperation(name: "DocumentGraphNeuron.Document.New")
        detailViewController!.setCurrentOperationData(data: [detailViewController!.getCurrentOperation(): [
            "documentGraphNewRequest": documentGraphNewRequest,
            "neuronName": detailViewController!.neuronName]])
        detailViewController!.sendRequest(sourceName: detailViewController!.sourceName)
    }
    
    public func getOptionMap() {
        var getOptionMapRequest = GetOptionMapRequest()
        getOptionMapRequest = GetOptionMapRequest()
        getOptionMapRequest.name = "UDCOptionMap.DocumentItemOptions"
        detailViewController!.setCurrentOperation(name: "OptionMapNeuron.OptionMap.Get.SearchOption")
        detailViewController!.setCurrentOperationData(data: [detailViewController!.getCurrentOperation(): [
            "getOptionMapRequest": getOptionMapRequest,
            "neuronName": detailViewController!.neuronName]])
        detailViewController!.sendRequest(sourceName: detailViewController!.sourceName)
    }
    
    private func getDocumentOptions() {
        var getOptionMapRequest = GetOptionMapRequest()
        getOptionMapRequest = GetOptionMapRequest()
        getOptionMapRequest.name = "UDCOptionMap.DocumentOptions"
        detailViewController!.setCurrentOperation(name: "OptionMapNeuron.OptionMap.Get.DocumentOptions")
        detailViewController!.setCurrentOperationData(data: [detailViewController!.getCurrentOperation(): [
            "getOptionMapRequest": getOptionMapRequest,
            "neuronName": detailViewController!.neuronName]])
        detailViewController!.sendRequest(sourceName: detailViewController!.sourceName)
    }
    
    public func getObjectControllerOptions() {
        var getOptionMapRequest = GetOptionMapRequest()
        getOptionMapRequest = GetOptionMapRequest()
        getOptionMapRequest.name = "UDCOptionMap.ViewOptions"
        detailViewController!.setCurrentOperation(name: "OptionMapNeuron.OptionMap.Get.ObjectControllerOption")
        detailViewController!.setCurrentOperationData(data: [detailViewController!.getCurrentOperation(): [
            "getOptionMapRequest": getOptionMapRequest,
            "neuronName": detailViewController!.neuronName]])
        detailViewController!.sendRequest(sourceName: detailViewController!.sourceName)
    }
    
    func searchBoxEvent(uvcViewItemType: String, eventName: String, uiObject: Any) {
        print("\(uvcViewItemType): \(eventName)")
        let uiTextField = uiObject as! UITextField
        detailViewController!.searchText = uiTextField.text!
        if eventName == "UVCViewItemEvent.Word.Editable.BeginEditing" {
            detailViewController!.loadObjectControllerView(uiTextFiled: uiTextField)
            //            detailViewController!.scrollToCurrent()
            return
        } else if eventName == "UVCViewItemEvent.Word.Editable.ReturnKeyPressed" {
            newLine()
            return
        } else if eventName == "UVCViewItemEvent.Word.Editable.DidChange" {
            
        }
    }
    
    
    func detailViewCellEvent(uvcViewItemType: String, eventName: String, uvcObject: Any, uiObject: Any, detailViewCell: DetailViewCell) {
        print("\(uvcViewItemType): \(eventName)")
        
        if uvcViewItemType == "UVCViewItemType.Button" {
            let uvcButton = uvcObject as! UVCButton
            let uiButton = uiObject as! UIButton
            if eventName == "UVCViewItemEvent.Button.Pressed" {
                if !detailViewController!.isEditableMode {
                    
                    print("Button: \(uvcViewItemType): \(eventName)")
                    return
                }
            }
            
        }
        
        if isActivityInProgress || !detailViewController!.isEditableMode {
            return
        }
        var name: String = ""
        if uiObject is UITextField {
            let uvcText = uvcObject as! UVCText
            name = uvcText.name
        }
        
        if uvcViewItemType == "UVCViewItemType.Photo" && eventName == "UVCViewItemEvent.Photo.Taped" {
            let uvcPhoto = uvcObject as! UVCPhoto
            if uvcPhoto.name == "BlackVerticalLine" {
                if detailViewController!.isSearchBoxVisible {
                    detailViewController!.isSearchBoxVisible = false
                    let uiTextFiled = detailViewCell.uvcViewController.uvcUIViewControllerItemCollection.getTextField(tag: 0, name: "UDCDocumentItemMapNode.SearchDocumentItems")?.uiTextField
                    uiTextFiled?.isHidden = true
                    uiTextFiled?.frame.size = CGSize(width: 0, height: 0)
                    
                } else {
                    detailViewController!.isSearchBoxVisible = true
                    let uiTextFiled = detailViewCell.uvcViewController.uvcUIViewControllerItemCollection.getTextField(tag: 0, name: "UDCDocumentItemMapNode.SearchDocumentItems")?.uiTextField
                    uiTextFiled?.isHidden = false
                    uiTextFiled?.frame.size = CGSize(width: 45, height: 30)
                }
                return
            }
        }
        
        //        if detailViewCell.index != detailViewController!.currentItemIndex {
        //            // De select the previous item
        //            if  detailViewController!.currentNodeIndex >= 0 && detailViewController!.currentItemIndex >= 0 {
        //                let uvcmPrev = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel[detailViewController!.currentItemIndex]
        //                if uvcmPrev.uvcViewItemType == "UVCViewItemType.Text" {
        //                    let uvcText = uvcmPrev.uvcViewItemCollection.uvcText[0]
        //                    uvcText.isEditable = false
        //                } else if uvcmPrev.uvcViewItemType == "UVCViewItemType.Text" {
        //                    let uvcPhoto = uvcmPrev.uvcViewItemCollection.uvcPhoto[0]
        //                    uvcPhoto.isEditable = false
        //                }
        //                self.detailViewController!.collectionView.reloadItems(at: [NSIndexPath(item: detailViewController!.currentItemIndex, section: detailViewController!.currentNodeIndex) as IndexPath])
        //            }
        //
        //            // Select the current item
        //            let uvcmCurrent = detailViewController!.uvcDocumentGraphModelList[detailViewCell.section].uvcViewModel[detailViewCell.index]
        //            if uvcmCurrent.uvcViewItemType == "UVCViewItemType.Text" {
        //                let uvcText = uvcObject as! UVCText
        //                uvcText.isEditable = true
        //            } else if uvcmCurrent.uvcViewItemType == "UVCViewItemType.Text" {
        //                let uvcPhoto = uvcObject as! UVCPhoto
        //                uvcPhoto.isEditable = true
        //            }
        //            self.detailViewController!.collectionView.reloadItems(at: [NSIndexPath(item: detailViewCell.index, section: detailViewCell.section) as IndexPath])
        
        // Read only model. User not allowed to move search box here
        var touchedModel: UVCViewModel?
        if detailViewCell.index <= detailViewController!.uvcDocumentGraphModelList[detailViewCell.section].uvcViewModel.count - 1 {
            touchedModel = detailViewController!.uvcDocumentGraphModelList[detailViewCell.section].uvcViewModel[detailViewCell.index]
        }
        if (touchedModel != nil) && !touchedModel!.isReadOnly {
            let count = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel.count
            if ((detailViewController!.currentItemIndex - 1 != detailViewCell.index && detailViewController!.currentItemIndex >= 0 && detailViewCell.section == detailViewController!.currentNodeIndex) ||
                detailViewCell.section != detailViewController!.currentNodeIndex) && !name.hasSuffix("UDCDocumentItemMapNode.SearchDocumentItems") {
                let searchBoxModel = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel[detailViewController!.currentItemIndex]
                
                detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel.remove(at: detailViewController!.currentItemIndex)
                // If cursor is before the user selected position so no plus 1 and also same section
                if detailViewController!.currentItemIndex < detailViewCell.index && detailViewController!.currentNodeIndex == detailViewCell.section {
                    detailViewController!.currentItemIndex = detailViewCell.index
                } else {
                    detailViewController!.currentItemIndex = detailViewCell.index + 1
                }
                let prevSection = detailViewController!.currentNodeIndex
                detailViewController!.currentNodeIndex = detailViewCell.section
                // At the last so append and also same section
                if detailViewController!.currentItemIndex > count - 1 && prevSection == detailViewController!.currentNodeIndex { detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel.append(searchBoxModel)
                } else {
                    detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel.insert(searchBoxModel, at: detailViewController!.currentItemIndex)
                }
                if detailViewController!.currentItemIndex > 0 {
                    detailViewController!.udcViewItemName = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel[detailViewController!.currentItemIndex - 1].udcViewItemName
                    detailViewController!.udcViewItemId =  detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel[detailViewController!.currentItemIndex - 1].udcViewItemId
                    if detailViewController!.objectEditMode {
                        detailViewController!.uvcViewItemType = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel[detailViewController!.currentItemIndex - 1].uvcViewItemType
                    } else {
                        detailViewController!.uvcViewItemType = "UVCViewItemType.Text"
                    }
                    detailViewController!.groupUVCViewItemType = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel[detailViewController!.currentItemIndex - 1].groupUVCViewItemType
                }
                detailViewController!.collectionView.reloadData()
                
                print("section: \(detailViewController!.currentNodeIndex)")
                print("index: \(detailViewController!.currentItemIndex)")
                
                #if !targetEnvironment(macCatalyst)
                detailViewController!.collectionView.scrollToItem(at: IndexPath(item: detailViewController!.currentItemIndex,
                                                                                section: detailViewController!.currentNodeIndex), at: .bottom, animated: true)
                if uiObject is UITextField {
                    focusTextField(uiTextField: uiObject as! UITextField)
                }
                #endif

                //                detailViewController!.scrollToCurrent()
                    return
            }
        }
        //            detailViewController!.currentNodeIndex = detailViewCell.section
        //            detailViewController!.currentItemIndex = detailViewCell.index
        
        
        //        }
        // Start: Pointer code should called if not any of the above **********************
        
        //            return
        //        }
        // End: Pointer code should called if not any of the above **********************
        
        
        if uvcViewItemType == "UVCViewItemType.Button" && eventName == "UVCViewItemEvent.Button.Pressed" {
            let uvcButton = uvcObject as! UVCButton
            let uiButton = uiObject as! UIButton
            if uvcButton.isOptionAvailable && detailViewController!.isEditableMode {
                showDocumentItemOption(uvcObject: uvcObject, index: detailViewCell.index, subIndex: 0, section: detailViewCell.section, sender: uiButton)
            }
            return
        }
        
        
        if uvcViewItemType == "UVCViewItemType.Photo" && eventName == "UVCViewItemEvent.Photo.Taped" {
            let uvcPhoto = uvcObject as! UVCPhoto
            let uiImageView = uiObject as! UIImageView
            
            if uvcPhoto.isDeviceOptionsAvailable! {
                CallBrainControllerNeuron.delegateMap["uvcPhoto"] = uvcPhoto
                CallBrainControllerNeuron.delegateMap["uiImageView"] = uiImageView
                CallBrainControllerNeuron.delegateMap["DocumentItem.Get.Section"] = detailViewCell.section
                CallBrainControllerNeuron.delegateMap["DocumentItem.Get.Index"]  = detailViewCell.index
                CallBrainControllerNeuron.delegateMap["DocumentItem.Get.SubIndex"] = 0
                CallBrainControllerNeuron.delegateMap["DocumentItem.Get.ObjectName"] = "UDCPhoto"
                detailViewController!.showPopover(category: detailViewController!.optionTitle["UDCOptionMap.PhotoOptions"]!, uvcOptionViewModel: detailViewController!.photoOptionViewModelList, width: 350, height: 300, sender: uiImageView, delegate: detailViewController! as UIPopoverPresentationControllerDelegate, optionDelegate: self, goToOption: "", isDismissedAutomatically: false, optionViewControllerName: "UDCOptionMap.PhotoOptions", rightButton: ["", "", ""], idName: "UDCOptionMap.PhotoOptions", operationName: "UDCOptionMap.PhotoOptions", documentGraphItemSearchRequest: nil, documentGraphItemReferenceRequest: nil, typeRequest: nil, documentGraphItemViewData: nil, documentMapSearchDocumentRequest: nil)
            } else if uvcPhoto.isOptionAvailable! {
                showDocumentItemOption(uvcObject: uvcObject, index: detailViewCell.index, subIndex: 0, section: detailViewCell.section, sender: uiImageView)
            }
            return
        }
        if uvcViewItemType == "UVCViewItemType.Text" && eventName == "UVCViewItemEvent.Word.Editable.Taped" {
            focusTextField(uiTextField: uiObject as! UITextField)
            return
        }
        
        //        if uvcViewItemType == "UVCViewItemType.Text" && eventName == "UVCViewItemEvent.Word.Editable.DidBeginEditing" {
        //            var index = 0
        //            if detailViewController!.currentItemIndex < detailViewCell.index  && detailViewController!.currentNodeIndex == detailViewCell.section {
        //                index = detailViewCell.index + 1
        //            } else {
        //                index = detailViewCell.index - 1
        //            }
        //            if detailViewController!.uvcDocumentGraphModelList[detailViewCell.section].uvcViewModel[detailViewCell.index].uvcViewItemCollection.uvcText[0].name == "UDCDocumentItemMapNode.SearchDocumentItems" && detailViewController!.isNonSearchEdited {
        //                detailViewController!.isNonSearchEdited = false
        //                let uvcText = uvcObject as! UVCText
        //                let uiTextField = uiObject as! UITextField
        //
        //                let uvcDocumentGraphModel = detailViewCell.uvcDocumentGraphModel!
        //                var processedText = uiTextField.text!
        //                processedText = processedText.trimmingCharacters(in: .whitespaces)
        //                if processedText.isEmpty {
        //                    return
        //                }
        //                let documentGraphChangeItemRequest = DocumentGraphChangeItemRequest()
        //                if detailViewController!.uvcDocumentGraphModelList[detailViewCell.section].parentId.count > 0 {
        //                    documentGraphChangeItemRequest.parentId.append(detailViewController!.uvcDocumentGraphModelList[detailViewCell.section].parentId[0])
        //                }
        //                documentGraphChangeItemRequest.nodeId = detailViewController!.uvcDocumentGraphModelList[detailViewCell.section]._id
        //                documentGraphChangeItemRequest.item = processedText
        //                documentGraphChangeItemRequest.documentId = detailViewController!.documentId
        //                documentGraphChangeItemRequest.itemIndex = index
        //                documentGraphChangeItemRequest.nodeIndex = detailViewCell.section
        //                documentGraphChangeItemRequest.level = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].level
        //                documentGraphChangeItemRequest.sentenceIndex = detailViewController!.currentSentenceIndex
        //                documentGraphChangeItemRequest.udcDocumentTypeIdName = ApplicationSetting.DocumentType!
        //                documentGraphChangeItemRequest.objectControllerRequest = ObjectControllerRequest()
        //                documentGraphChangeItemRequest.objectControllerRequest.viewConfigPathIdName.append(contentsOf: detailViewController!.viewConfigPathIdName)
        //                documentGraphChangeItemRequest.objectControllerRequest.uvcViewItemType = detailViewController!.uvcViewItemType
        //                documentGraphChangeItemRequest.objectControllerRequest.editMode = detailViewController!.objectEditMode
        //                documentGraphChangeItemRequest.objectControllerRequest.groupUVCViewItemType = detailViewController!.groupUVCViewItemType
        //                documentGraphChangeItemRequest.objectControllerRequest.udcViewItemName = detailViewController!.udcViewItemName
        //                documentGraphChangeItemRequest.objectControllerRequest.udcViewItemId = detailViewController!.udcViewItemId
        //
        //                detailViewController!.setCurrentOperation(name: "DocumentGraphNeuron.Document.Item.Change")
        //                detailViewController!.setCurrentOperationData(data: [detailViewController!.getCurrentOperation(): [
        //                    "documentGraphChangeItemRequest": documentGraphChangeItemRequest,
        //                    "neuronName": detailViewController!.neuronName]])
        //                detailViewController!.sendRequest(source: self)
        //            }
        //            return
        //        }
        
        if uvcViewItemType == "UVCViewItemType.Text" && eventName == "UVCViewItemEvent.Word.Editable.DidChange" {
            let uvcText = uvcObject as! UVCText
            let uiTextField = uiObject as! UITextField
            let uvcDocumentGraphModel = detailViewCell.uvcDocumentGraphModel!
            if detailViewController!.uvcDocumentGraphModelList[detailViewCell.section].uvcViewModel[detailViewCell.index].uvcViewItemCollection.uvcText[0].name == "UDCDocumentItemMapNode.SearchDocumentItems" {
                let searchText = uiTextField.text!.trimmingCharacters(in: .whitespaces)
                if searchText.isEmpty {
                    uiTextField.text = ""
                    return
                }
                detailViewController!.searchText = searchText
//                if uiTextField.text!.characters.last == " " && !detailViewController!.isLetterSpaceLocked {
//                    if detailViewController!.isSearchEnabled {
//                        let newSender = (detailViewController!.collectionView.cellForItem(at: NSIndexPath(item: detailViewController!.currentItemIndex, section: detailViewController!.currentNodeIndex) as IndexPath) as! DetailViewCell).getViewController().uvcUIViewControllerItemCollection.getTextField()?.uiTextField
//                        print(newSender?.text)
//                        searchAndinsertItem(section: detailViewController!.currentNodeIndex, index: detailViewController!.currentItemIndex, level: detailViewController!.currentLevel, sender: newSender)
//                    } else {
//                        insertItem(section: detailViewCell.section, index: detailViewCell.index, level: detailViewCell.level, searchText: searchText, itemData: "", uvOptionViewModel: UVCOptionViewModel(), documentGraphInsertItemRequestParam: nil, parentIndex: 0)
//                    }
//                    return
//                }
            }
        } else if uvcViewItemType == "UVCViewItemType.Button" && eventName == "UVCViewItemEvent.Button.Pressed" {
            let uvcButton = uvcObject as! UVCButton
            let uiButton = uiObject as! UIButton
            if uvcButton.name == "OptionsButtonUDCDocumentItemMapNode.SearchDocumentItems" {
                print("Search option selected")
                detailViewController!.showPopover(category: detailViewController!.optionTitle["UDCOptionMap.DocumentItemOptions"]!, uvcOptionViewModel: detailViewController!.documentItemOptionViewModelList, width: 350, height: 350, sender: uiButton, delegate: detailViewController! as UIPopoverPresentationControllerDelegate, optionDelegate: self, goToOption: "", isDismissedAutomatically: false, optionViewControllerName: "UDCOptionMap.DocumentItemOptions", rightButton: ["", "", ""], idName: "", operationName: "UDCOptionMap.DocumentItemOptions", documentGraphItemSearchRequest: nil, documentGraphItemReferenceRequest: nil, typeRequest: nil, documentGraphItemViewData: nil, documentMapSearchDocumentRequest: nil)
                
                return
            }
            
            if uvcButton.name.hasPrefix("Backspace") {
                // It is the root of the document so return
                let documentGraphDeleteItemRequest = DocumentGraphDeleteItemRequest()
                documentGraphDeleteItemRequest.documentId = detailViewController!.documentId
                if detailViewController!.uvcDocumentGraphModelList[detailViewCell.section].parentId.count > 0 {
                    documentGraphDeleteItemRequest.parentId.append(detailViewController!.uvcDocumentGraphModelList[detailViewCell.section].parentId[0])
                }
                documentGraphDeleteItemRequest.nodeId = detailViewController!.uvcDocumentGraphModelList[detailViewCell.section]._id
                let uvcDocumentGraphModel = detailViewCell.uvcDocumentGraphModel as! UVCDocumentGraphModel
                documentGraphDeleteItemRequest.nodeId = uvcDocumentGraphModel._id
                documentGraphDeleteItemRequest.itemIndex = detailViewCell.index - 1
                documentGraphDeleteItemRequest.nodeIndex = detailViewCell.section
                //                if detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].parentId.count > 0 {
                //                    documentGraphDeleteItemRequest.treeLevel = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex - 1].level + 1
                //                } else {
                documentGraphDeleteItemRequest.treeLevel = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].level
                //                }
                documentGraphDeleteItemRequest.sentenceIndex = detailViewController!.currentSentenceIndex
                documentGraphDeleteItemRequest.udcDocumentTypeIdName = ApplicationSetting.DocumentType!
                documentGraphDeleteItemRequest.objectControllerRequest.viewConfigPathIdName.append(contentsOf: detailViewController!.viewConfigPathIdName)
                if detailViewController!.uvcViewItemType.isEmpty {
                    detailViewController!.uvcViewItemType = "UVCViewItemType.Text"
                }
                documentGraphDeleteItemRequest.isDocumentItemEditable = detailViewController!.isDocumentItemEditable
                documentGraphDeleteItemRequest.objectControllerRequest.uvcViewItemType = detailViewController!.uvcViewItemType
                documentGraphDeleteItemRequest.objectControllerRequest.editMode = detailViewController!.objectEditMode
                documentGraphDeleteItemRequest.objectControllerRequest.groupUVCViewItemType = detailViewController!.groupUVCViewItemType
                documentGraphDeleteItemRequest.objectControllerRequest.udcViewItemName = detailViewController!.udcViewItemName
                documentGraphDeleteItemRequest.objectControllerRequest.udcViewItemId = detailViewController!.udcViewItemId
                detailViewController!.setCurrentOperation(name: "DocumentGraphNeuron.Document.Item.Delete")
                detailViewController!.setCurrentOperationData(data: [detailViewController!.getCurrentOperation(): [
                    "documentGraphDeleteItemRequest": documentGraphDeleteItemRequest,
                    "neuronName": detailViewController!.neuronName]])
                detailViewController!.sendRequest(sourceName: detailViewController!.sourceName)
                return
            }
            
            
            if uvcButton.name.hasPrefix("ObjectController") {
                return
            }
        } else if uvcViewItemType == "UVCViewItemType.Text" && eventName == "UVCViewItemEvent.Word.Taped" {
            let uvcText = uvcObject as! UVCText
            let uiLabel = uiObject as! UILabel
            
            if uvcText.isOptionAvailable {
                showDocumentItemOption(uvcObject: uvcObject, index: detailViewCell.index, subIndex: 0, section: detailViewCell.section, sender: uiLabel)
            }
        }
        
        
    }
    
    private func deleteItem() {
        //            It is the root of the document so return
        let documentGraphDeleteItemRequest = DocumentGraphDeleteItemRequest()
        documentGraphDeleteItemRequest.documentId = detailViewController!.documentId
        if detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].parentId.count > 0 {
            documentGraphDeleteItemRequest.parentId.append(detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].parentId[0])
        }
        documentGraphDeleteItemRequest.nodeId = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex]._id
        documentGraphDeleteItemRequest.itemIndex = detailViewController!.currentItemIndex - 1
        documentGraphDeleteItemRequest.nodeIndex = detailViewController!.currentNodeIndex
        documentGraphDeleteItemRequest.treeLevel = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].level
        documentGraphDeleteItemRequest.sentenceIndex = detailViewController!.currentSentenceIndex
        documentGraphDeleteItemRequest.isDocumentItemEditable = detailViewController!.isDocumentItemEditable
        var udcDocumentTypeIdName = ""
        if detailViewController!.isPopup {
            udcDocumentTypeIdName = detailViewController!.popupUdcDocumentTypeIdName
        } else {
            udcDocumentTypeIdName = ApplicationSetting.DocumentType!
        }
        
        documentGraphDeleteItemRequest.udcDocumentTypeIdName = udcDocumentTypeIdName
        documentGraphDeleteItemRequest.objectControllerRequest = ObjectControllerRequest()
        documentGraphDeleteItemRequest.objectControllerRequest.viewConfigPathIdName.append(contentsOf: detailViewController!.viewConfigPathIdName)
        documentGraphDeleteItemRequest.objectControllerRequest.uvcViewItemType = detailViewController!.uvcViewItemType
        documentGraphDeleteItemRequest.objectControllerRequest.editMode = detailViewController!.objectEditMode
        documentGraphDeleteItemRequest.objectControllerRequest.groupUVCViewItemType = detailViewController!.groupUVCViewItemType
        documentGraphDeleteItemRequest.objectControllerRequest.udcViewItemName = detailViewController!.udcViewItemName
        documentGraphDeleteItemRequest.objectControllerRequest.udcViewItemId = detailViewController!.udcViewItemId
        
        detailViewController!.setCurrentOperation(name: "DocumentGraphNeuron.Document.Item.Delete")
        detailViewController!.setCurrentOperationData(data: [detailViewController!.getCurrentOperation(): [
            "documentGraphDeleteItemRequest": documentGraphDeleteItemRequest,
            "neuronName": detailViewController!.neuronName]])
        detailViewController!.sendRequest(sourceName: self.detailViewController!.sourceName)
        return
    }
    
    private func deleteLine() {
        detailViewController!.setCurrentOperation(name: "DocumentGraphNeuron.Document.Delete.Line")
        let documentGraphDeleteLineRequest = DocumentGraphDeleteLineRequest()
        documentGraphDeleteLineRequest.level = detailViewController!.currentLevel
        if detailViewController!.currentNodeIndex ==  detailViewController!.uvcDocumentGraphModelList.count - 1 && detailViewController!.currentNodeIndex != 0 {
            documentGraphDeleteLineRequest.nearbyNodeId = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex - 1]._id
        } else if detailViewController!.currentNodeIndex + 1 == detailViewController!.uvcDocumentGraphModelList.count - 1 {
            documentGraphDeleteLineRequest.nearbyNodeId = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex + 1]._id
        }
        if detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].parentId.count > 0 {
            documentGraphDeleteLineRequest.parentId = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].parentId[0]
        }
        documentGraphDeleteLineRequest.nodeId = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex]._id
        documentGraphDeleteLineRequest.udcDocumentTypeIdName = ApplicationSetting.DocumentType!
        documentGraphDeleteLineRequest.documentId = detailViewController!.documentId
        documentGraphDeleteLineRequest.nodeIndex = detailViewController!.currentNodeIndex
        detailViewController!.setCurrentOperationData(data: [detailViewController!.getCurrentOperation(): [
            "language": ApplicationSetting.DocumentLanguage as Any,
            "documentGraphDeleteLineRequest": documentGraphDeleteLineRequest,
            "neuronName": detailViewController?.neuronName as Any]])
        detailViewController!.sendRequest(sourceName: detailViewController!.sourceName)
    }

    
    private func searchPressed() {
        if detailViewController!.isSearchEnabled && !detailViewController!.isLetterSpaceLocked {
            let newSender = (detailViewController!.collectionView.cellForItem(at: NSIndexPath(item: detailViewController!.currentItemIndex, section: detailViewController!.currentNodeIndex) as IndexPath) as! DetailViewCell).getViewController().uvcUIViewControllerItemCollection.getTextField()?.uiTextField
            print(newSender?.text)
            searchAndinsertItem(section: detailViewController!.currentNodeIndex, index: detailViewController!.currentItemIndex, level: detailViewController!.currentLevel, sender: newSender)
        } else {
            insertItem(section: detailViewController!.currentNodeIndex, index: detailViewController!.currentItemIndex, level: detailViewController!.currentLevel, searchText: detailViewController!.searchText, itemData: "", uvOptionViewModel: UVCOptionViewModel(), documentGraphInsertItemRequestParam: nil, parentIndex: 0)
        }
        return
        
    }
    
    @objc public func deleteLinePressed(keyCommand: UIKeyCommand)
    {
        deleteLine()
    }
    
    public func deletePressed(keyCommand: UIKeyCommand)
    {
        deleteItem()
    }
    
    public func configurationPressed(keyCommand: UIKeyCommand)
    {
        getDocumentView(editMode: detailViewController!.isEditableMode, objectType: ApplicationSetting.DocumentType!, isToGetDuplicate: false, isToCheckIfFound: false, language: nil, isToLaunchDetailedView: false, isToLaunchConfigurationView: true, isDocumentMapView: false, isFormatView: false)
    }
    
    public func documentMapPressed(keyCommand: UIKeyCommand)
    {
        getDocumentView(editMode: detailViewController!.isEditableMode, objectType: ApplicationSetting.DocumentType!, isToGetDuplicate: false, isToCheckIfFound: false, language: nil, isToLaunchDetailedView: false, isToLaunchConfigurationView: false, isDocumentMapView: true, isFormatView: false)
    }
    
    public func informationPressed(keyCommand: UIKeyCommand)
    {
        getDocumentView(editMode: detailViewController!.isEditableMode, objectType: ApplicationSetting.DocumentType!, isToGetDuplicate: false, isToCheckIfFound: false, language: nil, isToLaunchDetailedView: true, isToLaunchConfigurationView: false, isDocumentMapView: false, isFormatView: false)
    }
    
    private func viewAction(sender: Any?) {
        var senderLocal: Any? = sender
        if senderLocal == nil {
            let searchBoxObject = detailViewController!.collectionView.cellForItem(at: NSIndexPath(item: (detailViewController?.currentItemIndex)!, section: detailViewController!.currentNodeIndex) as IndexPath)
            let searchBox = searchBoxObject as! DetailViewCell
            let uiTextField = searchBox.uvcViewController.uvcUIViewControllerItemCollection.getTextField(tag: 0, name: "UDCDocumentItemMapNode.SearchDocumentItems")?.uiTextField
            senderLocal = uiTextField
        }
        for (ocovmlIndex, ocovml) in detailViewController!.objectControllerOptionViewModelList.enumerated() {
            if ocovml.idName == detailViewController!.uvcViewItemType {
                ocovml.changeCheckBox(name:  "CheckBoxButton", enabled: true)
            } else {
                ocovml.changeCheckBox(name:  "CheckBoxButton", enabled: false)
            }
        }
        detailViewController!.showPopover(category: detailViewController!.optionTitle["UDCOptionMap.ViewOptions"]!, uvcOptionViewModel: detailViewController!.objectControllerOptionViewModelList, width: 400, height: 350, sender: senderLocal!, delegate: detailViewController! as UIPopoverPresentationControllerDelegate, optionDelegate: self, goToOption: "", isDismissedAutomatically: false, optionViewControllerName: "UDCOptionMap.ViewOptions", rightButton: ["", "", ""], idName: "", operationName: "UDCOptionMap.ViewOptions", documentGraphItemSearchRequest: nil, documentGraphItemReferenceRequest: nil, typeRequest: nil, documentGraphItemViewData: nil, documentMapSearchDocumentRequest: nil)
    }
    
    public func viewPressed(keyCommand: UIKeyCommand)
    {
        viewAction(sender: nil)
    }
    
    private func optionAction(sender: Any?) {
        var senderLocal: Any? = sender
        if senderLocal == nil {
            let searchBoxObject = detailViewController!.collectionView.cellForItem(at: NSIndexPath(item: (detailViewController?.currentItemIndex)!, section: detailViewController!.currentNodeIndex) as IndexPath)
            let searchBox = searchBoxObject as! DetailViewCell
            let uiTextField = searchBox.uvcViewController.uvcUIViewControllerItemCollection.getTextField(tag: 0, name: "UDCDocumentItemMapNode.SearchDocumentItems")?.uiTextField
            senderLocal = uiTextField
        }
        detailViewController!.showPopover(category: detailViewController!.optionTitle["UDCOptionMap.DocumentItemOptions"]!, uvcOptionViewModel: detailViewController!.documentItemOptionViewModelList, width: 350, height: 350, sender: senderLocal, delegate: detailViewController! as UIPopoverPresentationControllerDelegate, optionDelegate: self, goToOption: "", isDismissedAutomatically: false, optionViewControllerName: "UDCOptionMap.DocumentItemOptions", rightButton: ["", "", ""], idName: "", operationName: "UDCOptionMap.DocumentItemOptions", documentGraphItemSearchRequest: nil, documentGraphItemReferenceRequest: nil, typeRequest: nil, documentGraphItemViewData: nil, documentMapSearchDocumentRequest: nil)
    }
    
    public func optionPressed(keyCommand: UIKeyCommand)
    {
        optionAction(sender: nil)
    }
    
    public func letterSpaceLockPressed(keyCommand: UIKeyCommand)
    {
        if !detailViewController!.isLetterSpaceLocked {
            detailViewController!.isLetterSpaceLocked = true
        } else {
            detailViewController!.isLetterSpaceLocked = false
        }
    }
    
    public func searchOnOffPressed(keyCommand: UIKeyCommand)
    {
        if !detailViewController!.isSearchEnabled {
            detailViewController!.isSearchEnabled = true
        } else {
            detailViewController!.isSearchEnabled = false
        }
    }
    
    public func upArrow(keyCommand: UIKeyCommand)
    {
        handleArrowKeys(name: "UpDirectionArrow")
    }
    
    public func formatPressed(keyCommand: UIKeyCommand)
    {
        getDocumentView(editMode: detailViewController!.isEditableMode, objectType: ApplicationSetting.DocumentType!, isToGetDuplicate: false, isToCheckIfFound: false, language: nil, isToLaunchDetailedView: false, isToLaunchConfigurationView: false, isDocumentMapView: false, isFormatView: true)
    }
    
    public func downArrow(keyCommand: UIKeyCommand)
    {
        handleArrowKeys(name: "DownDirectionArrow")
        
    }
    
    public func leftArrow(keyCommand: UIKeyCommand)
    {
        handleArrowKeys(name: "LeftDirectionArrow")
        
    }
    
    public func rightArrow(keyCommand: UIKeyCommand)
    {
        handleArrowKeys(name: "RightDirectionArrow")
    }
    
    public func homePressed(keyCommand: UIKeyCommand)
    {
        handleArrowKeys(name: "HomeDirectionArrow")
    }
    
    public func endPressed(keyCommand: UIKeyCommand)
    {
        handleArrowKeys(name: "EndDirectionArrow")
    }
    
    public func pageHomePressed(keyCommand: UIKeyCommand)
    {
        handleArrowKeys(name: "PageHomeDirectionArrow")
    }
    
    public func pageEndPressed(keyCommand: UIKeyCommand)
    {
        handleArrowKeys(name: "PageEndDirectionArrow")
    }
    
    public func optionViewControllerEvent(uvcViewItemType: String, eventName: String, uvcObject: Any, uiObject: Any, optionViewCell: OptionViewCell, uvcOptionViewModel: UVCOptionViewModel, parentIndex: Int, callerObject: Any?, operationName: String) {
        detailViewController!.optionViewNavigationController = nil
        if detailViewController!.photoIdArray.count > 0 {
            return
        }
        if operationName == "DocumentMapNeuron.Search.Document" {
            detailViewController!.setEditable(editable: detailViewController!.isEditableMode)
            detailViewController!.documentId = uvcOptionViewModel.objectIdName
            getDocumentView(editMode: detailViewController!.isEditableMode, objectType: uvcOptionViewModel.objectName, isToGetDuplicate: false, isToCheckIfFound: false, language: nil, isToLaunchDetailedView: false, isToLaunchConfigurationView: false, isDocumentMapView: false, isFormatView: false)
            return
        }
        if uvcOptionViewModel.pathIdName[parentIndex].joined(separator: "->").hasPrefix(  "UDCOptionMapNode.DocumentOptions->UDCOptionMapNode.NewDocument") {
            documentNew()
            return
        }
        if uvcOptionViewModel.pathIdName[parentIndex].joined(separator: "->").hasPrefix(
            "UDCOptionMapNode.DocumentOptions->UDCOptionMapNode.Document3") {
            //            detailViewController!.documentId = "5e245312ebe79129e84db64d"
//            ApplicationSetting.DocumentType = "UDCDocumentType.Document"
            ApplicationSetting.DocumentType = "UDCDocumentType.DocumentItem"
            detailViewController!.isEditableMode = true
            ApplicationSetting.DocumentLanguage = "en"
            
            // document item document items
                        detailViewController!.documentId = "5f3ab9039f428041de484be6"
            // document permissions
//            detailViewController!.documentId = "5fc675d92667c07ef864684e"

            // human
//            detailViewController!.documentId = "5fbb69c2c18d2a2f1b50713c"
            // user document items
//                       detailViewController!.documentId = "5fce320ca1a8ba509004461b"
            // document document items
//                        detailViewController!.documentId = "5fba256205e5d053bc2c148f"
            // document (blank)
//            detailViewController!.documentId = "5fba598803a643616b5f98da"
            // document access role document items
//            detailViewController!.documentId = "5fc8ba3d21c33c6fc847110d"
//            self.detailViewController!.addTab(title: "Dictionary", documentId: "5f522cc953fbeb410a5cf373", udcDocumentTypeIdName: "UDCDocumentType.DocumentItem")
//                        try getDocumentView(editMode: true, objectType: "UDCDocumentType.Document", isToGetDuplicate: false, isToCheckIfFound: false, language: nil, isToLaunchDetailedView: false, isToLaunchConfigurationView: false, isDocumentMapView: false, isFormatView: false)
            try getDocumentView(editMode: true, objectType: "UDCDocumentType.DocumentItem", isToGetDuplicate: false, isToCheckIfFound: false, language: nil, isToLaunchDetailedView: false, isToLaunchConfigurationView: false, isDocumentMapView: false, isFormatView: false)
            return
        }
        if uvcOptionViewModel.pathIdName[parentIndex].joined(separator: "->").hasPrefix(
            "UDCOptionMapNode.DocumentOptions->UDCOptionMapNode.Document2") {
//            detailViewController!.documentId = "5e245312ebe79129e84db64d"
            ApplicationSetting.DocumentType = "UDCDocumentType.Document"
                        detailViewController!.isEditableMode = true
                        ApplicationSetting.DocumentLanguage = "en"
//                        detailViewController!.documentId = "5e245312ebe79129e84db64d"
            // software
//            detailViewController!.documentId = "5f5623673ecd276dd06e7480"
            // kumar muthaiah software
//            detailViewController!.documentId = "5fc89d63118ad624606b8438"
            // document access role detail
//            detailViewController!.documentId = "5fc8b198118ad624606b94df"
            // system software
//                        detailViewController!.documentId = "5f4d02ce8f52ef77bc2adcd9"
            // activity
//            detailViewController!.documentId = "5fbbc7afb4888643591f1737"
            // digital media player
//            detailViewController!.documentId = "5fbcea01f35a7f0a877f7e0f"
            // human
//            detailViewController!.documentId = "5fbb69c2c18d2a2f1b50713c"
            // document type
//            detailViewController!.documentId = "5e14a7955e513e7e6019d5eb"
            // food ingredient document
            detailViewController!.documentId = "5fc61c3b46a8a3325d2f9c34"
            // user detail
//            detailViewController!.documentId = "5fccc3ac8874d03a854fcef8"
            // user
//            detailViewController!.documentId = "5fc369a999605f4cfb7548e8"
            // food recipe document items
//            detailViewController!.documentId = "5f3aa1594d65da0cf416e4b7"
            
//            self.detailViewController!.addTab(title: "user detail", documentId: "5fccc3ac8874d03a854fcef8", udcDocumentTypeIdName: "UDCDocumentType.DocumentItem")
            try getDocumentView(editMode: true, objectType: "UDCDocumentType.Document", isToGetDuplicate: false, isToCheckIfFound: false, language: nil, isToLaunchDetailedView: false, isToLaunchConfigurationView: false, isDocumentMapView: false, isFormatView: false)
            return
        }
         if uvcOptionViewModel.pathIdName[parentIndex].joined(separator: "->").hasPrefix(
                    "UDCOptionMapNode.DocumentOptions->UDCOptionMapNode.Document4") {
        //            detailViewController!.documentId = "5e245312ebe79129e84db64d"
                    ApplicationSetting.DocumentType = "UDCDocumentType.DocumentItem"
                                detailViewController!.isEditableMode = true
                                ApplicationSetting.DocumentLanguage = "en"
//                                detailViewController!.documentId = "5f522da23a358d7a1429df34"
            // human
//                        detailViewController!.documentId = "5fbb69c2c18d2a2f1b50713c"
            // software
//                        detailViewController!.documentId = "5f5623673ecd276dd06e7480"
            // computer
//            detailViewController!.documentId = "5f560d0b3ecd276dd06e4a91"
            // document history document items
//            detailViewController!.documentId = "5fc501f6dd1d045c1b0eface"
            
            // gregorian calendar
//            detailViewController!.documentId = "5f4e2fb23a990f01c42e4a6b"
            // time unit details
            detailViewController!.documentId = "5e3c1f145e783f39257c5cd9"
            // document interface photo
//            detailViewController!.documentId = "5e1c852b45627a5634112751"
            // document role
//            detailViewController!.documentId = "5fba598803a643616b5f98da"
            // food ingredient document
//                        detailViewController!.documentId = "5fc61c3b46a8a3325d2f9c34"
            // document detail
            //            detailViewController!.documentId = "5fb8b7054de56272f27537d2"
            // supported device
//            detailViewController!.documentId = "5fc3aa31d7546a045123e02f"
            // initial creation
//            detailViewController!.documentId = "5fc50af8de3d6b63db23a99a"
//            detailViewController!.documentId = "5f531a278e51ad07752d2adb"
            // system software
//            detailViewController!.documentId = "5f4d02ce8f52ef77bc2adcd9"
            // IDE
//            detailViewController!.documentId = "5f5623673ecd276dd06e7480"
        //            self.detailViewController!.addTab(title: "Grammar", documentId: "5e245312ebe79129e84db64d", udcDocumentTypeIdName: "UDCDocumentType.DocumentItem")
                    try getDocumentView(editMode: true, objectType: "UDCDocumentType.DocumentItem", isToGetDuplicate: false, isToCheckIfFound: false, language: nil, isToLaunchDetailedView: false, isToLaunchConfigurationView: false, isDocumentMapView: false, isFormatView: false)
                    return
                }
        if uvcOptionViewModel.pathIdName[parentIndex].joined(separator: "->").hasPrefix(  "UDCOptionMapNode.DocumentOptions->UDCOptionMapNode.Document1") {
//            ApplicationSetting.DocumentType = "UDCDocumentType.KnowledgeOverview"
//            detailViewController!.documentId = "5f4ca8bc4cf0614235058c24"
            //             swift programming language
//            ApplicationSetting.DocumentType = "UDCDocumentType.SwiftProgrammingLanguage"
//            detailViewController!.documentId = "5f522d1d3a358d7a1429de1d"
            
            
//            ApplicationSetting.DocumentType = "UDCDocumentType.Photo"
//            detailViewController!.documentId = "5f675031f308bc3bd34e5a4d"
//            ApplicationSetting.DocumentType = "UDCDocumentType.FoodRecipe"
//            detailViewController!.documentId = "5e4bc9397241cc5b146756c7"
//                        detailViewController!.documentId = "5e4bc61b7241cc5b14674dd4"
//                        ApplicationSetting.DocumentType = "UDCDocumentType.DocumentAccessRole"
            ApplicationSetting.DocumentType = "UDCDocumentType.DocumentItem"
//            ApplicationSetting.DocumentType = "UDCDocumentType.DocumentAccess"
//            ApplicationSetting.DocumentType = "UDCDocumentType.DocumentHistory"
//            ApplicationSetting.DocumentType = "UDCDocumentType.Document"
//            ApplicationSetting.DocumentType = "UDCDocumentType.User"
            detailViewController!.isEditableMode = true
            ApplicationSetting.DocumentLanguage = "en"
//            ApplicationSetting.DocumentLanguage = "ta"
            // photo view detail
//            detailViewController!.documentId = "5f6703870282b7462d636ec2"
            // photo document items
//            detailViewController!.documentId = "5f670d50f308bc3bd34e4de7"
            // user (blank)
//            detailViewController!.documentId = "5fce3425a1a8ba5090044fcc"
            
            
            // food recipe documents
            detailViewController!.documentId = "5fad1275a4cbd255381bb017"
            // document item documents
//            detailViewController!.documentId = "5fae44da34786b642d0ea2bc"
            
            // document item documents
//            detailViewController!.documentId = "5fe0c4d4ce1a4933c7942d37"
            // document item config. documents
//            detailViewController!.documentId = "5fe18c869a7aa5a3a8a3b29a"
            // human language
//            detailViewController!.documentId = "5fafa962c7d1a21a9d05e0f9"
//            detailViewController!.documentId = "5fe2dfe257b97e5eb7303bfc"
            
//            detailViewController!.documentId = "5fe2dfe257b97e5eb7303bf4"
            // ios photo size
//            detailViewController!.documentId = "5fafa93fc7d1a21a9d05e001"
//            ApplicationSetting.DocumentType = "UDCDocumentType.Document"
            // blank document of document type
//            detailViewController!.documentId = "5fba598803a643616b5f98da"
            
            // document detail
//            detailViewController!.documentId = "5fb8b7054de56272f27537d2"
            // user document item
//            detailViewController!.documentId = "5fce320ca1a8ba509004461b"
            // time
//                        detailViewController!.documentId = "5fcb308a35ba2e533f419014"
            // document item documents
//            detailViewController!.documentId = "5fae44da34786b642d0ea2bc"
            // [company][app]document root
//            detailViewController!.documentId = "5fdcd911d3bf2155a546672d"
            
            // document documen items
//            detailViewController!.documentId = "5fba256205e5d053bc2c148f"
            // company
//            detailViewController!.documentId = "5e43b1452b7aa90f265329d5"
            // universe docs company
//            detailViewController!.documentId = "5fd1e73093628e744a23c8f7"
            // kumar muthaiah software
//            detailViewController!.documentId = "5fc89d63118ad624606b8438"
            // software
//            detailViewController!.documentId = "5f5623673ecd276dd06e7480"
            // human
//            detailViewController!.documentId = "5fbb69c2c18d2a2f1b50713c"
            // kumar muthaiah (company)
//            detailViewController!.documentId = "5fbb9ed76453355f70686f2f"
            // system software
//            detailViewController!.documentId = "5f4d02ce8f52ef77bc2adcd9"
            // computer
//            detailViewController!.documentId = "5f560d0b3ecd276dd06e4a91"
            // kumar muthaiah universe docs document permission
//            detailViewController!.documentId = "5fc675d92667c07ef864684e"
            // document access detail
//            detailViewController!.documentId = "5fc9c35094963c40f645ff58"
            // document access document items
//            detailViewController!.documentId = "5fc9c5c194963c40f646022e"
            // kumar muthaiah document access
//            detailViewController!.documentId = "5fc9ccd294963c40f64611b8"
            // food ingredient document access
//            detailViewController!.documentId = "5fc9dd9ced754058400c9a34"
            // document access (blank)
//            detailViewController!.documentId = "5fc9ca5094963c40f6460c8d"
            // portable computer
//            detailViewController!.documentId = "5fbd02eef35a7f0a877f9be2"
            // kumar muthaiah unvierse docs user
//            detailViewController!.documentId = "5fc369a999605f4cfb7548e8"
            // document history detail
//            detailViewController!.documentId = "5fc3b7096aded8236b20e791"
            // document history (blank) english
//            detailViewController!.documentId = "5fc504833d6b2372857d697b"
            // food ingredient document history
//            detailViewController!.documentId = "5fc509a1de3d6b63db23a632"
            // food ingredient document
//            detailViewController!.documentId = "5fc61c3b46a8a3325d2f9c34"
            
            // desktop computer
//            detailViewController!.documentId = "5fbfc0695e60c81b596a7940"
            // smart phone
//            detailViewController!.documentId = "5fbcdf3df35a7f0a877f72bf"
            // smartwatch
//            detailViewController!.documentId = "5fbced90f35a7f0a877f8ad0"
            // tablet computer
//            detailViewController!.documentId = "5fbcdb3af35a7f0a877f6709"
            // document item document items
//                        detailViewController!.documentId = "5fc8ba3d21c33c6fc847110d"
            // administrator (document access role)
//            detailViewController!.documentId = "5fc8cece21c33c6fc8472e07"
            // broadbeans sambar title photo
//            detailViewController!.documentId = "5e514fd414f30e61e21ab7a9"
            // broadbeans sambar photo
//            detailViewController!.documentId = "5e512862710eb465e5172500"
            // document item options
//            detailViewController!.documentId = "5f5a060d120c5d508f77e9b7"
            // document options
//            detailViewController!.documentId = "5f5a0bd9120c5d508f77edd7"
            // view item type
//            detailViewController!.documentId = "5f5f72678ae1ad63db7e35e6"
            // option map document items
//            detailViewController!.documentId = "5f5f7b4313952c453a781ae8"
            // document map options
//            detailViewController!.documentId = "5f5a1b79120c5d508f77f352"
//            detailViewController!.documentId = "5e514fae14f30e61e21ab5f5"
            // swift programming language dictionary
//            detailViewController!.documentId = "5f522cc953fbeb410a5cf373"
//            ApplicationSetting.DocumentLanguage = "ta"
            // Grammar tamil
//            detailViewController!.documentId = "5e25dca4e15230554a667941"
            // document interface photo
//            detailViewController!.documentId = "5e1c852b45627a5634112751"
            // grammar english
//            detailViewController!.documentId = "5e245312ebe79129e84db64d"
            
            // knowledge overview document items
//            detailViewController!.documentId = "5f4ca6c1ab91397600740905"
            // swift programming language document items
//            detailViewController!.documentId = "5f522da23a358d7a1429df34"
            
            // programming language detail
//            detailViewController!.documentId = "5f52612986c1812ede5646f9"
            // programming language feature
//           detailViewController!.documentId =  "5f53090f8e51ad07752d1d3e"
            
//            detailViewController!.documentId =  "5f4e3da4ec0e092aed56bcff"
            // programming language
//            detailViewController!.documentId =  "5f5301618e51ad07752d1285"
            // programming language disadvantage
//            detailViewController!.documentId = "5f5312838e51ad07752d27f0"
//            try getDocumentView(editMode: true, objectType: "UDCDocumentType.Photo", isToGetDuplicate: false, isToCheckIfFound: false, language: nil, isToLaunchDetailedView: false, isToLaunchConfigurationView: false, isDocumentMapView: false, isFormatView: false)
//            try getDocumentView(editMode: true, objectType: "UDCDocumentType.KnowledgeOverview", isToGetDuplicate: false, isToCheckIfFound: false, language: nil, isToLaunchDetailedView: false, isToLaunchConfigurationView: false, isDocumentMapView: false, isFormatView: false)
//            try getDocumentView(editMode: true, objectType: "UDCDocumentType.FoodRecipe", isToGetDuplicate: false, isToCheckIfFound: false, language: nil, isToLaunchDetailedView: false, isToLaunchConfigurationView: false, isDocumentMapView: false, isFormatView: false)
//            try getDocumentView(editMode: true, objectType: "UDCDocumentType.SwiftProgrammingLanguage", isToGetDuplicate: false, isToCheckIfFound: false, language: nil, isToLaunchDetailedView: false, isToLaunchConfigurationView: false, isDocumentMapView: false, isFormatView: false)
            try getDocumentView(editMode: true, objectType: "UDCDocumentType.DocumentItem", isToGetDuplicate: false, isToCheckIfFound: false, language: nil, isToLaunchDetailedView: false, isToLaunchConfigurationView: false, isDocumentMapView: false, isFormatView: false)
//            try getDocumentView(editMode: true, objectType: "UDCDocumentType.Document", isToGetDuplicate: false, isToCheckIfFound: false, language: nil, isToLaunchDetailedView: false, isToLaunchConfigurationView: false, isDocumentMapView: false, isFormatView: false)
//            try getDocumentView(editMode: true, objectType: "UDCDocumentType.DocumentHistory", isToGetDuplicate: false, isToCheckIfFound: false, language: nil, isToLaunchDetailedView: false, isToLaunchConfigurationView: false, isDocumentMapView: false, isFormatView: false)
//            try getDocumentView(editMode: true, objectType: "UDCDocumentType.DocumentAccessRole", isToGetDuplicate: false, isToCheckIfFound: false, language: nil, isToLaunchDetailedView: false, isToLaunchConfigurationView: false, isDocumentMapView: false, isFormatView: false)
//            try getDocumentView(editMode: true, objectType: "UDCDocumentType.DocumentAccess", isToGetDuplicate: false, isToCheckIfFound: false, language: nil, isToLaunchDetailedView: false, isToLaunchConfigurationView: false, isDocumentMapView: false, isFormatView: false)
//                        try getDocumentView(editMode: true, objectType: "UDCDocumentType.User", isToGetDuplicate: false, isToCheckIfFound: false, language: nil, isToLaunchDetailedView: false, isToLaunchConfigurationView: false, isDocumentMapView: false, isFormatView: false)
            return
        }
        if uvcOptionViewModel.pathIdName[parentIndex].joined(separator: "->").hasPrefix(  "UDCOptionMapNode.DocumentItemOptions->UDCOptionMapNode.Line->UDCOptionMapNode.Delete") {
            deleteLine()
//            detailViewController!.setCurrentOperation(name: "DocumentGraphNeuron.Document.Delete.Line")
//            let documentGraphDeleteLineRequest = DocumentGraphDeleteLineRequest()
//            documentGraphDeleteLineRequest.level = detailViewController!.currentLevel
//            if detailViewController!.currentNodeIndex ==  detailViewController!.uvcDocumentGraphModelList.count - 1 && detailViewController!.currentNodeIndex != 0 {
//                documentGraphDeleteLineRequest.nearbyNodeId = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex - 1]._id
//            } else if detailViewController!.currentNodeIndex + 1 == detailViewController!.uvcDocumentGraphModelList.count - 1 {
//                documentGraphDeleteLineRequest.nearbyNodeId = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex + 1]._id
//            }
//            if detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].parentId.count > 0 {
//                documentGraphDeleteLineRequest.parentId = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].parentId[0]
//            }
//            documentGraphDeleteLineRequest.nodeId = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex]._id
//            documentGraphDeleteLineRequest.udcDocumentTypeIdName = ApplicationSetting.DocumentType!
//            documentGraphDeleteLineRequest.documentId = detailViewController!.documentId
//            documentGraphDeleteLineRequest.nodeIndex = detailViewController!.currentNodeIndex
//            detailViewController!.setCurrentOperationData(data: [detailViewController!.getCurrentOperation(): [
//                "language": ApplicationSetting.DocumentLanguage as Any,
//                "documentGraphDeleteLineRequest": documentGraphDeleteLineRequest,
//                "neuronName": detailViewController?.neuronName as Any]])
//            detailViewController!.sendRequest(sourceName: detailViewController!.sourceName)
            return
        }
        if uvcOptionViewModel.pathIdName[parentIndex].joined(separator: "->").hasPrefix(  "UDCOptionMapNode.DocumentOptions->UDCOptionMapNode.SearchForDocument") {
            
            return
        }
        if uvcOptionViewModel.pathIdName[parentIndex].joined(separator: "->").hasPrefix(  "UDCOptionMapNode.PhotoOptions->UDCOptionMapNode.Camera") {
            let uvcPhoto = CallBrainControllerNeuron.delegateMap["uvcPhoto"] as! UVCPhoto
            let uiImageView = CallBrainControllerNeuron.delegateMap["uiImageView"] as! UIImageView
            detailViewController!.showPhotoPicker(sourceType: .camera, uiImageView: uiImageView, uvcPhoto: uvcPhoto)
            return
        }
        if uvcOptionViewModel.pathIdName[parentIndex].joined(separator: "->").hasPrefix(  "UDCOptionMapNode.PhotoOptions->UDCOptionMapNode.PhotoLibrary") {
            let uvcPhoto = CallBrainControllerNeuron.delegateMap["uvcPhoto"] as! UVCPhoto
            let uiImageView = CallBrainControllerNeuron.delegateMap["uiImageView"] as! UIImageView
            detailViewController!.showPhotoPicker(sourceType: .photoLibrary, uiImageView: uiImageView, uvcPhoto: uvcPhoto)
            return
        }
        if uvcOptionViewModel.pathIdName[parentIndex].joined(separator: "->").hasPrefix(  "UDCOptionMapNode.DocumentOptions->UDCOptionMapNode.NewDocument") {
            documentNew()
            return
        }
        if uvcOptionViewModel.pathIdName[parentIndex].joined(separator: "->").hasPrefix(  "UDCOptionMapNode.DocumentOptions->UDCOptionMapNode.EditDocument") {
            detailViewController!.isEditableMode = true
            getDocumentView(editMode: detailViewController!.isEditableMode, objectType: ApplicationSetting.DocumentType!, isToGetDuplicate: false, isToCheckIfFound: false, language: nil, isToLaunchDetailedView: false, isToLaunchConfigurationView: false, isDocumentMapView: false, isFormatView: false)
            return
        }
        if uvcOptionViewModel.pathIdName[parentIndex].joined(separator: "->").hasPrefix(  "UDCOptionMapNode.DocumentOptions->UDCOptionMapNode.DeleteDocument") {
            let detailItem = UVCDocumentMapRequest()
            detailItem.uvcTreeNode.objectId = detailViewController!.documentId
            detailItem.uvcTreeNode.objectType = ApplicationSetting.DocumentType!
            detailItem.uvcTreeNode.language = ApplicationSetting.DocumentLanguage!
            detailViewController!.showAlertViewOKCancel(name: "DocumentGraphNeuron.Document.Delete", message: "Do you want to Delete?", data: detailItem)
            return
        }
        
        if uvcOptionViewModel.pathIdName[parentIndex].joined(separator: "->").hasPrefix(  "UDCOptionMapNode.DocumentOptions->UDCOptionMapNode.SaveAsTemplate") {
            return
        }
        
        if uvcOptionViewModel.pathIdName[parentIndex].joined(separator: "->").hasPrefix(  "UDCOptionMapNode.DocumentOptions->UDCOptionMapNode.SaveAsTemplate") {
            documentSaveAsTemplate()
            return
        }
        if uvcOptionViewModel.pathIdName[parentIndex].joined(separator: "->").hasPrefix("UDCOptionMapNode.DocumentItemOptions->UDCOptionMapNode.CategoryOptions->") {
            let documentCategoryOptionSelectedRequest = DocumentCategoryOptionSelectedRequest()
            documentCategoryOptionSelectedRequest.categoryOptionPathIdName.append(contentsOf: uvcOptionViewModel.pathIdName[parentIndex])
            documentCategoryOptionSelectedRequest.documentId = detailViewController!.documentId
            documentCategoryOptionSelectedRequest.udcDocumentTypeIdName = ApplicationSetting.DocumentType!
            documentCategoryOptionSelectedRequest.sentenceIndex = detailViewController!.currentSentenceIndex
            documentCategoryOptionSelectedRequest.itemIndex = detailViewController!.currentItemIndex
            documentCategoryOptionSelectedRequest.nodeIndex = detailViewController!.currentNodeIndex
            //            if detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].parentId.count > 0 {
            //                documentCategoryOptionSelectedRequest.level = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex - 1].level + 1
            //            } else {
            documentCategoryOptionSelectedRequest.level = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].level
            //            }
            
            if detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].parentId.count > 0 {
                documentCategoryOptionSelectedRequest.parentId = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].parentId[0]
            }
            documentCategoryOptionSelectedRequest.optionItemId = uvcOptionViewModel.objectIdName
            documentCategoryOptionSelectedRequest.optionItemObjectName = uvcOptionViewModel.objectName
            documentCategoryOptionSelectedRequest.nodeId =  detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex]._id
            documentCategoryOptionSelectedRequest.objectControllerRequest = ObjectControllerRequest()
            documentCategoryOptionSelectedRequest.objectControllerRequest.viewConfigPathIdName.append(contentsOf: detailViewController!.viewConfigPathIdName)
            documentCategoryOptionSelectedRequest.objectControllerRequest.uvcViewItemType = detailViewController!.uvcViewItemType
            documentCategoryOptionSelectedRequest.objectControllerRequest.editMode = detailViewController!.objectEditMode
            documentCategoryOptionSelectedRequest.objectControllerRequest.groupUVCViewItemType = detailViewController!.groupUVCViewItemType
            documentCategoryOptionSelectedRequest.objectControllerRequest.udcViewItemName = detailViewController!.udcViewItemName
            documentCategoryOptionSelectedRequest.objectControllerRequest.udcViewItemId = detailViewController!.udcViewItemId
            detailViewController!.setCurrentOperation(name: "DocumentGraphNeuron.Document.Category.Options.Selected")
            detailViewController!.setCurrentOperationData(data: [detailViewController!.getCurrentOperation(): [
                "language": ApplicationSetting.DocumentLanguage as Any,
                "documentCategoryOptionSelectedRequest": documentCategoryOptionSelectedRequest,
                "neuronName": detailViewController?.neuronName as Any]])
            detailViewController!.sendRequest(sourceName: detailViewController!.sourceName)
            return
        }
        if uvcOptionViewModel.pathIdName[parentIndex].joined(separator: "->").hasPrefix("UDCOptionMapNode.DocumentItemOptions->UDCOptionMapNode.Category->") {
            let documentCategorySelectedRequest = DocumentCategorySelectedRequest()
            documentCategorySelectedRequest.categoryIdName = uvcOptionViewModel.pathIdName[parentIndex][uvcOptionViewModel.pathIdName[parentIndex].count - 1]
            documentCategorySelectedRequest.documentId = detailViewController!.documentId
            documentCategorySelectedRequest.udcDocumentTypeIdName = ApplicationSetting.DocumentType!
            documentCategorySelectedRequest.sentenceIndex = detailViewController!.currentSentenceIndex
            documentCategorySelectedRequest.itemIndex = detailViewController!.currentItemIndex
            documentCategorySelectedRequest.nodeIndex = detailViewController!.currentNodeIndex
            documentCategorySelectedRequest.level = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].level
            if detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].parentId.count > 0 {
                documentCategorySelectedRequest.parentId = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].parentId[0]
            }
            documentCategorySelectedRequest.optionItemId = uvcOptionViewModel.objectIdName
            documentCategorySelectedRequest.optionItemObjectName = uvcOptionViewModel.objectName
            documentCategorySelectedRequest.nodeId =  detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex]._id
            documentCategorySelectedRequest.objectControllerRequest = ObjectControllerRequest()
            documentCategorySelectedRequest.objectControllerRequest.viewConfigPathIdName.append(contentsOf: detailViewController!.viewConfigPathIdName)
            documentCategorySelectedRequest.objectControllerRequest.uvcViewItemType = detailViewController!.uvcViewItemType
            documentCategorySelectedRequest.objectControllerRequest.editMode = detailViewController!.objectEditMode
            documentCategorySelectedRequest.objectControllerRequest.groupUVCViewItemType = detailViewController!.groupUVCViewItemType
            documentCategorySelectedRequest.objectControllerRequest.udcViewItemName = detailViewController!.udcViewItemName
            documentCategorySelectedRequest.objectControllerRequest.udcViewItemId = detailViewController!.udcViewItemId
            detailViewController!.setCurrentOperation(name: "DocumentGraphNeuron.Document.Category.Selected")
            detailViewController!.setCurrentOperationData(data: [detailViewController!.getCurrentOperation(): [
                "language": ApplicationSetting.DocumentLanguage as Any,
                "documentCategorySelectedRequest": documentCategorySelectedRequest,
                "neuronName": detailViewController?.neuronName as Any]])
            detailViewController!.sendRequest(sourceName: detailViewController!.sourceName)
            return
        }
        if uvcOptionViewModel.pathIdName[parentIndex].joined(separator: "->") == "UDCOptionMapNode.DocumentItemOptions->UDCOptionMapNode.CategoryOptions" {
            if detailViewController!.categoryOptionsDictionary["UDCOptionMapNode.All"] != nil {
                // All category have same options
                let uvcOptionViewRequest = UVCOptionViewRequest()
                uvcOptionViewRequest.operationName = "OptionViewController.Children.Add"
                uvcOptionViewRequest.pathIdName.append(contentsOf: uvcOptionViewModel.pathIdName[parentIndex])
                uvcOptionViewRequest.uvcOptionViewModel = detailViewController!.categoryOptionsDictionary["UDCOptionMapNode.All"]
            } else {
                // Based on current category the option is chosed
            }
        }
        if uvcOptionViewModel.pathIdName[parentIndex].joined(separator: "->").hasPrefix(  "UDCOptionMapNode.DocumentItemOptions->UDCOptionMapNode.Reference->UDCDocumentReferenceType.SameDocument->UDCDocumentItemMapNode.Sentence->") {
            detailViewController!.setCurrentOperation(name: "DocumentGraphNeuron.Document.Item.Reference")
            let uvcOptionViewRequest = UVCOptionViewRequest()
            uvcOptionViewRequest.operationName = "OptionViewController.Children.DeleteAll"
            var tempPath = uvcOptionViewModel.pathIdName[parentIndex]
            tempPath.remove(at: tempPath.count - 1)
            uvcOptionViewRequest.path.append(contentsOf: tempPath)
            uvcOptionViewRequest.rightButton.append(contentsOf: ["", "",""])
            //            detailViewController!.optionViewController!.request = uvcOptionViewRequest
            
            let documentGraphItemReferenceRequest = DocumentGraphItemReferenceRequest()
            documentGraphItemReferenceRequest.documentId = detailViewController!.documentId
            // Graph model information
            documentGraphItemReferenceRequest.sentenceIndex = detailViewController!.currentSentenceIndex
            documentGraphItemReferenceRequest.itemIndex = detailViewController!.currentItemIndex
            documentGraphItemReferenceRequest.nodeIndex = detailViewController!.currentNodeIndex
            documentGraphItemReferenceRequest.level = detailViewController!.currentLevel
            documentGraphItemReferenceRequest.parentId = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].parentId[0]
            documentGraphItemReferenceRequest.nodeId =  detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex]._id
            // Reference information
            documentGraphItemReferenceRequest.referenceNodeId = uvcOptionViewModel.objectIdName
            let modelComponents = uvcOptionViewModel.model.components(separatedBy: ":")
            documentGraphItemReferenceRequest.referenceNodeIndex = Int(modelComponents[0])!
            //            if documentGraphItemReferenceRequest.nodeIndex == documentGraphItemReferenceRequest.referenceNodeIndex {
            //                return
            //            }
            documentGraphItemReferenceRequest.referenceSentenceIndex = Int(modelComponents[1])!
            documentGraphItemReferenceRequest.pathIdName.append(contentsOf: uvcOptionViewModel.pathIdName[parentIndex])
            documentGraphItemReferenceRequest.udcDocumentTypeIdName = ApplicationSetting.DocumentType!
            detailViewController!.setCurrentOperationData(data: [detailViewController!.getCurrentOperation(): [
                "language": ApplicationSetting.DocumentLanguage as Any,
                "documentGraphItemReferenceRequest": documentGraphItemReferenceRequest,
                "neuronName": detailViewController?.neuronName as Any]])
            detailViewController!.sendRequest(sourceName: detailViewController!.sourceName)
            return
        }
        if uvcOptionViewModel.pathIdName[parentIndex].joined(separator: "->").hasPrefix(  "UDCOptionMapNode.DocumentItemOptions->UDCOptionMapNode.Reference->UDCDocumentReferenceType.SameDocument->UDCDocumentItemMapNode.Word->") {
            detailViewController!.setCurrentOperation(name: "DocumentGraphNeuron.Document.Item.Reference")
            let uvcOptionViewRequest = UVCOptionViewRequest()
            uvcOptionViewRequest.operationName = "OptionViewController.Children.DeleteAll"
            uvcOptionViewRequest.rightButton.append(contentsOf: ["", "",""])
            //            detailViewController!.optionViewController!.request = uvcOptionViewRequest
            
            let documentGraphItemReferenceRequest = DocumentGraphItemReferenceRequest()
            documentGraphItemReferenceRequest.documentId = detailViewController!.documentId
            let modelComponents = uvcOptionViewModel.model.components(separatedBy: ":")
            documentGraphItemReferenceRequest.referenceNodeId = uvcOptionViewModel.objectIdName
            documentGraphItemReferenceRequest.referenceNodeIndex = Int(modelComponents[0])!
            documentGraphItemReferenceRequest.referenceSentenceIndex = Int(modelComponents[1])!
            documentGraphItemReferenceRequest.referenceItemIndex = Int(modelComponents[2])!
            documentGraphItemReferenceRequest.itemIndex = detailViewController!.currentItemIndex
            documentGraphItemReferenceRequest.nodeIndex = detailViewController!.currentNodeIndex
            //            if documentGraphItemReferenceRequest.nodeIndex == documentGraphItemReferenceRequest.referenceNodeIndex {
            //                return
            //            }
            documentGraphItemReferenceRequest.parentId = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].parentId[0]
            documentGraphItemReferenceRequest.nodeId =  detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex]._id
            documentGraphItemReferenceRequest.level = detailViewController!.currentLevel
            documentGraphItemReferenceRequest.pathIdName.append(contentsOf: uvcOptionViewModel.pathIdName[parentIndex])
            documentGraphItemReferenceRequest.udcDocumentTypeIdName = ApplicationSetting.DocumentType!
            documentGraphItemReferenceRequest.item = uvcOptionViewModel.getText(name: "Name")!.value
            detailViewController!.setCurrentOperationData(data: [detailViewController!.getCurrentOperation(): [
                "language": ApplicationSetting.DocumentLanguage as Any,
                "documentGraphItemReferenceRequest": documentGraphItemReferenceRequest,
                "neuronName": detailViewController?.neuronName as Any]])
            detailViewController!.sendRequest(sourceName: detailViewController!.sourceName)
            return
        }
        if uvcOptionViewModel.pathIdName[parentIndex].joined(separator: "->").hasPrefix(  "UDCOptionMapNode.DocumentItemOptions->UDCOptionMapNode.Reference->UDCDocumentReferenceType.SameDocument->UDCDocumentItemMapNode.Sentence") {
            detailViewController!.setCurrentOperation(name: "DocumentGraphNeuron.Document.Item.Reference")
            let documentGraphItemReferenceRequest = DocumentGraphItemReferenceRequest()
            documentGraphItemReferenceRequest.documentId = detailViewController!.documentId
            documentGraphItemReferenceRequest.parentId = uvcOptionViewModel.parentId[0]
            documentGraphItemReferenceRequest.optionId = uvcOptionViewModel.objectIdName
            documentGraphItemReferenceRequest.optionObjectName = uvcOptionViewModel.objectName
            documentGraphItemReferenceRequest.pathIdName.append(contentsOf: uvcOptionViewModel.pathIdName[parentIndex])
            documentGraphItemReferenceRequest.udcDocumentTypeIdName = ApplicationSetting.DocumentType!
            detailViewController!.setCurrentOperationData(data: [detailViewController!.getCurrentOperation(): [
                "language": ApplicationSetting.DocumentLanguage as Any,
                "documentGraphItemReferenceRequest": documentGraphItemReferenceRequest,
                "neuronName": detailViewController?.neuronName as Any]])
            detailViewController!.sendRequest(sourceName: detailViewController!.sourceName)
            return
        }
        if uvcOptionViewModel.pathIdName[parentIndex].joined(separator: "->").hasPrefix(  "UDCOptionMapNode.DocumentItemOptions->UDCOptionMapNode.Reference->UDCDocumentReferenceType.SameDocument") {
            detailViewController!.setCurrentOperation(name: "DocumentGraphNeuron.Document.Item.Reference")
            let documentGraphItemReferenceRequest = DocumentGraphItemReferenceRequest()
            documentGraphItemReferenceRequest.documentId = detailViewController!.documentId
            documentGraphItemReferenceRequest.parentId = uvcOptionViewModel.parentId[0]
            documentGraphItemReferenceRequest.optionId = uvcOptionViewModel.objectIdName
            documentGraphItemReferenceRequest.optionObjectName = uvcOptionViewModel.objectName
            documentGraphItemReferenceRequest.pathIdName.append(contentsOf: uvcOptionViewModel.pathIdName[parentIndex])
            documentGraphItemReferenceRequest.udcDocumentTypeIdName = ApplicationSetting.DocumentType!
            detailViewController!.setCurrentOperationData(data: [detailViewController!.getCurrentOperation(): [
                "language": ApplicationSetting.DocumentLanguage as Any,
                "documentGraphItemReferenceRequest": documentGraphItemReferenceRequest,
                "neuronName": detailViewController?.neuronName as Any]])
            detailViewController!.sendRequest(sourceName: detailViewController!.sourceName)
            return
        }
        if uvcOptionViewModel.pathIdName[parentIndex].joined(separator: "->").hasPrefix(  "UDCOptionMapNode.DocumentItemSearchOptions->UDCOptionMapNode.DeleteRow") {
            let searchBoxModel = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel[detailViewController!.currentItemIndex]
            detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel.removeAll()
            detailViewController!.currentItemIndex = 0
            detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel.insert(searchBoxModel, at: detailViewController!.currentItemIndex)
            detailViewController!.collectionView.reloadData()
            print("itemIndex: \(detailViewController!.currentItemIndex)")
            print("nodeIndex: \(detailViewController!.currentNodeIndex)")
            return
        }
        if uvcOptionViewModel.pathIdName[parentIndex].joined(separator: "->").hasPrefix(  "UDCOptionMapNode.DocumentOptions->UDCOptionMapNode.DocumentLanguage->") {
            let jsonUtility = JsonUtility<UDCHumanLanguageType>()
            let udcHumanLanguageType = jsonUtility.convertJsonToAnyObject(json: uvcOptionViewModel.model)
            detailViewController!.isEditableMode = detailViewController!.isEditableMode
            getDocumentView(editMode: detailViewController!.isEditableMode, objectType: ApplicationSetting.DocumentType!, isToGetDuplicate: false, isToCheckIfFound: true, language: udcHumanLanguageType.code6391, isToLaunchDetailedView: false, isToLaunchConfigurationView: false, isDocumentMapView: false, isFormatView: false)
            return
        }
        if uvcOptionViewModel.pathIdName[parentIndex].joined(separator: "->").hasPrefix(  "UDCOptionMapNode.DocumentOptions->UDCOptionMapNode.DocumentType->") {
            ApplicationSetting.DocumentType = uvcOptionViewModel.idName
            resetValues()
            detailViewController!.documentId = ""
            detailViewController!.setEditable(editable: false)
            detailViewController!.collectionView.reloadData()
            refreshDocumentMap()
            return
        }
        if uvcOptionViewModel.pathIdName[parentIndex].joined(separator: "->").hasPrefix( "UDCOptionMapNode.Sentence->") {
            detailViewController!.viewConfigPathIdName.append(contentsOf: uvcOptionViewModel.pathIdName[parentIndex])
            return
        }
        if uvcOptionViewModel.pathIdName[parentIndex].joined(separator: "->").hasPrefix( "UDCOptionMapNode.ViewOptions->") {
            if uvcOptionViewModel.pathIdName[parentIndex][1] == "UVCViewItemType.GraphParentNode" {
                detailViewController!.isParentNode = true
                return
            } else if uvcOptionViewModel.pathIdName[parentIndex][1] == "UVCViewItemType.GraphChildNode" {
                detailViewController!.isParentNode = false
                return
            } else if uvcOptionViewModel.pathIdName[parentIndex][1] == "UVCViewItemType.Editable" {
                detailViewController!.isDocumentItemEditable = true
                return
            } else if uvcOptionViewModel.pathIdName[parentIndex][1] == "UVCViewItemType.NotEditable" {
                detailViewController!.isDocumentItemEditable = false
                return
            }  else if uvcOptionViewModel.pathIdName[parentIndex][1] == "UVCViewItemType.DocumentItemSeparator" {
                let getDocumentInterfacePhotoRequest = GetDocumentInterfacePhotoRequest()
                getDocumentInterfacePhotoRequest.idName = "UDCDocumentItem.DocumentItemSeparator"
                detailViewController!.setCurrentOperation(name: "DocumentGraphNeuron.Document.Get.InterfacePhoto")
                detailViewController!.setCurrentOperationData(data: [detailViewController!.getCurrentOperation(): [
                    "getDocumentInterfacePhotoRequest": getDocumentInterfacePhotoRequest,
                    "neuronName": detailViewController!.neuronName]])
                detailViewController!.sendRequest(sourceName: detailViewController!.sourceName)
                return
            }  else if uvcOptionViewModel.pathIdName[parentIndex][1] == "UVCViewItemType.TranslationSeparator" {
                let getDocumentInterfacePhotoRequest = GetDocumentInterfacePhotoRequest()
                getDocumentInterfacePhotoRequest.idName = "UDCDocumentItem.TranslationSeparator"
                detailViewController!.setCurrentOperation(name: "DocumentGraphNeuron.Document.Get.InterfacePhoto")
                detailViewController!.setCurrentOperationData(data: [detailViewController!.getCurrentOperation(): [
                    "getDocumentInterfacePhotoRequest": getDocumentInterfacePhotoRequest,
                    "neuronName": detailViewController!.neuronName]])
                detailViewController!.sendRequest(sourceName: detailViewController!.sourceName)
                return
            }  else if uvcOptionViewModel.pathIdName[parentIndex][1] == "UVCViewItemType.SentencePatternNode" {
                let getDocumentInterfacePhotoRequest = GetDocumentInterfacePhotoRequest()
                getDocumentInterfacePhotoRequest.idName = "UDCDocumentItem.SentencePatternNode"
                detailViewController!.setCurrentOperation(name: "DocumentGraphNeuron.Document.Get.InterfacePhoto")
                detailViewController!.setCurrentOperationData(data: [detailViewController!.getCurrentOperation(): [
                    "getDocumentInterfacePhotoRequest": getDocumentInterfacePhotoRequest,
                    "neuronName": detailViewController!.neuronName]])
                detailViewController!.sendRequest(sourceName: detailViewController!.sourceName)
                return
            } else if uvcOptionViewModel.isSelected || uvcOptionViewModel.pathIdName[parentIndex][1] == "UVCViewItemType.Photo" {
                uvcOptionViewModel.objectIdName = "photoId"
                detailViewController!.uvcViewItemType = uvcOptionViewModel.pathIdName[parentIndex][1]
                detailViewController!.viewPathIdName.removeAll()
                detailViewController!.viewPathIdName.append(contentsOf: uvcOptionViewModel.pathIdName[parentIndex])
                insertItem(section: detailViewController!.currentNodeIndex, index: detailViewController!.currentItemIndex, level: detailViewController!.currentLevel, searchText: "photo", itemData: "", uvOptionViewModel:  uvcOptionViewModel, documentGraphInsertItemRequestParam: nil, parentIndex: parentIndex)
                //                detailViewController!.objectEditMode = true
                //                detailViewController!.collectionView.reloadData()
                //                detailViewController!.viewConfigPathIdName.append(contentsOf: uvcOptionViewModel.pathIdName[parentIndex])
                //                detailViewController!.groupUVCViewItemType = uvcOptionViewModel.pathIdName[parentIndex][uvcOptionViewModel.pathIdName[parentIndex].count - 1]
                //                detailViewController!.uvcViewItemType = uvcOptionViewModel.pathIdName[parentIndex][uvcOptionViewModel.pathIdName[parentIndex].count - 1]
                //                let key = "UDCOptionMap.\(detailViewController!.uvcViewItemType.split(separator: ".")[1])Configuration"
                //                if detailViewController!.viewConfigurationOptionViewModelList.count == 0 || detailViewController!.viewTypeConfigurationDictionary[key] == nil {
                //                    let documentGetViewConfigurationOptionsRequest = DocumentGetViewConfigurationOptionsRequest()
                //                    documentGetViewConfigurationOptionsRequest.uvcViewItemType = detailViewController!.uvcViewItemType
                //                    detailViewController!.setCurrentOperation(name: "DocumentGraphNeuron.Get.View.Configuration.Options")
                //                    detailViewController!.setCurrentOperationData(data: [detailViewController!.getCurrentOperation(): [
                //                        "language": ApplicationSetting.DocumentLanguage!,
                //                        "documentGetViewConfigurationOptionsRequest": documentGetViewConfigurationOptionsRequest,
                //                        "neuronName": detailViewController!.neuronName]])
                //                    detailViewController!.sendRequest(source: self)
                //                }
            }
            return
        }
        if uvcOptionViewModel.pathIdName[parentIndex].joined(separator: "->") == "UDCOptionMapNode.DocumentItemOptions->UDCOptionMapNode.ConfigureSearch->UDCOptionMapNode.ConfigureSearchView"  {
            if uvcViewItemType == "UVCViewItemType.OnOff" {
                let uvcOnOff = uvcObject as! UVCOnOff
                let uiSwitch = uiObject as! UISwitch
                if uvcOnOff.name == "UDCOptionMapNode.ByCategory.OnOff" {
                    searchOptionSelection[0] = uiSwitch.isOn
                } else if uvcOnOff.name == "UDCOptionMapNode.BySubCategory.OnOff" {
                    searchOptionSelection[1] = uiSwitch.isOn
                } else if uvcOnOff.name == "UDCOptionMapNode.ByName.OnOff" {
                    searchOptionSelection[2] = uiSwitch.isOn
                } else if uvcOnOff.name == "UDCOptionMapNode.IncludeGrammar.OnOff" {
                    searchOptionSelection[3] = uiSwitch.isOn
                } else if uvcOnOff.name == "UDCOptionMapNode.SentencePattern.OnOff" {
                    searchOptionSelection[4] = uiSwitch.isOn
                }
            }
            return
        } else if uvcOptionViewModel.pathIdName[parentIndex].joined(separator: "->") == "UDCOptionMapNode.DocumentItemSearchOptions->UDCOptionMapNode.Sentence->UDCOptionMapNode.AddToDictionary" {
//            detailViewController!.setCurrentOperation(name: "DocumentGraphNeuron.User.SentencePattern.Add")
//            let userSentencePatternAddRequest = UserSentencePatternAddRequest()
//            for uvcdml in detailViewController!.uvcDocumentGraphModelList {
//                if uvcdml._id == detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].parentId[0] {
//                    userSentencePatternAddRequest.parentObjectId = uvcdml.getText(index: 0, name: "Name")!.optionObjectIdName
//                    userSentencePatternAddRequest.parentObjectName = uvcdml.getText(index: 0, name: "Name")!.optionObjectName
//                    break
//                }
//            }
//            userSentencePatternAddRequest.parentId = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].parentId[0]
//            userSentencePatternAddRequest.nodeId = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex]._id
//            userSentencePatternAddRequest.fromItemIndex = 0
//            userSentencePatternAddRequest.toItemIndex = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel.count - 1
//            userSentencePatternAddRequest.sentenceIndex = detailViewController!.currentSentenceIndex
//
//            detailViewController!.setCurrentOperationData(data: [detailViewController!.getCurrentOperation(): [
//                "userSentencePatternAddRequest": userSentencePatternAddRequest]])
//            detailViewController!.sendRequest(sourceName: detailViewController!.sourceName)
        }
        
        if detailViewController!.currentOptionCategory == "Document Item Search Options" {
            detailViewController!.showOptionPopover(category: "Search Option", width: 400, height: 200, sender: detailViewController!.documentOptionsButton, delegate: detailViewController! as UIPopoverPresentationControllerDelegate, optionLabel: ["By Category", "Include Grammar", "By Name", "By Related"], optionSelection: searchOptionSelection, searchOptionDelegate: self)
        } else {
            if uvcOptionViewModel.pathIdName[parentIndex].joined(separator: "->").hasPrefix( "UDCDocumentItemMapNode.DocumentItems") || uvcOptionViewModel.pathIdName[parentIndex].joined(separator: "->").hasPrefix( "UDCDocumentItem.Grammar") {
                //                detailViewController!.optionViewController!.dismiss(animated: true, completion: nil)
                detailViewController!.documetSentenceSearchBox?.text = uvcOptionViewModel.getText(name: "Name")!.value
                let documentGraphInsertItemRequestParam = DocumentGraphInsertItemRequest()
                documentGraphInsertItemRequestParam.isOption = true
                if uvcOptionViewModel.idName.hasPrefix("UDCPhotoDocument") {
                    detailViewController!.uvcViewItemType = "UVCViewItemType.Photo"
                } else {
                    detailViewController!.uvcViewItemType = "UVCViewItemType.Text"
                }
                insertItem(section: 0, index: optionViewCell.index, level: optionViewCell.level, searchText: uvcOptionViewModel.getText(name: "Name")!.value, itemData: "", uvOptionViewModel: uvcOptionViewModel, documentGraphInsertItemRequestParam: documentGraphInsertItemRequestParam, parentIndex: parentIndex)
            } else if uvcOptionViewModel.pathIdName[parentIndex].joined(separator: "->").hasPrefix( "UDCDocumentItemMapNode.DocumentItemOption") {
                let processedText = uvcOptionViewModel.getText(name: "Name")!.value
                let documentGraphChangeItemRequest = DocumentGraphChangeItemRequest()
                documentGraphChangeItemRequest.documentId = detailViewController!.documentId
                let documentGraphItemViewData = callerObject as! DocumentGraphItemViewData
                let uvcViewModel = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel[detailViewController!.currentItemIndex - 1]
                var index = 0
                if uvcViewModel.uvcViewItemCollection.uvcPhoto.count > 0 {
                    if uvcViewModel.uvcViewItemCollection.uvcPhoto.count > 1 {
                        index = 1
                    }
                    if uvcViewModel.uvcViewItemCollection.uvcPhoto[index].optionObjectIdName != uvcOptionViewModel.objectIdName {
                        uvcViewModel.uvcViewItemCollection.uvcPhoto[index].isChanged = true
                    }
                }
                //                let section = CallBrainControllerNeuron.delegateMap["DocumentItem.Get.Section"] as! Int
                //                let itemIndex = CallBrainControllerNeuron.delegateMap["DocumentItem.Get.Index"] as! Int
                //                let subIndex = CallBrainControllerNeuron.delegateMap["DocumentItem.Get.SubIndex"] as! Int
                //                let objectName = CallBrainControllerNeuron.delegateMap["DocumentItem.Get.ObjectName"] as! String
                //
                //                if CallBrainControllerNeuron.delegateMap["DocumentItem.Get.SenderObject"] is UVCPhoto {
                //                    let uvcPhoto = CallBrainControllerNeuron.delegateMap["DocumentItem.Get.SenderObject"] as! UVCPhoto
                //                    if uvcPhoto.optionObjectIdName != uvcOptionViewModel.objectIdName {
                //                        uvcPhoto.isChanged = true
                //                    }
                //                }
                //                if CallBrainControllerNeuron.delegateMap["DocumentItem.Get.SenderObject"] is UVCText {
                //                    let uvcText = CallBrainControllerNeuron.delegateMap["DocumentItem.Get.SenderObject"] as! UVCText
                //                    if uvcText.optionObjectIdName != uvcOptionViewModel.objectIdName {
                //                        uvcText.isChanged = true
                //                    }
                //                }
                if detailViewController!.uvcDocumentGraphModelList[documentGraphItemViewData.nodeIndex].parentId.count > 0 {
                    documentGraphChangeItemRequest.parentId.append(detailViewController!.uvcDocumentGraphModelList[documentGraphItemViewData.nodeIndex].parentId[0])
                }
                documentGraphChangeItemRequest.nodeId = detailViewController!.uvcDocumentGraphModelList[documentGraphItemViewData.nodeIndex]._id
                documentGraphChangeItemRequest.item = uvcOptionViewModel.getText(name: "Name")!.value
                //                if uvcViewModel.uvcViewItemCollection.uvcPhoto.count > 0 {
                //                    documentGraphChangeItemRequest.optionItemId = uvcOptionViewModel.objectIdName
                //                    documentGraphChangeItemRequest.optionItemObjectName = uvcOptionViewModel.objectName
                //                } else {
                documentGraphChangeItemRequest.optionItemId = uvcOptionViewModel.objectIdName
                documentGraphChangeItemRequest.optionItemObjectName = uvcOptionViewModel.objectName
                documentGraphChangeItemRequest.optionItemNameIndex = uvcOptionViewModel.objectNameIndex
                //                }
                if detailViewController!.currentItemIndex < documentGraphItemViewData.itemIndex && detailViewController!.currentNodeIndex == 0 {
                    documentGraphChangeItemRequest.itemIndex = documentGraphItemViewData.itemIndex - 1
                } else {
                    documentGraphChangeItemRequest.itemIndex = documentGraphItemViewData.itemIndex
                }
                documentGraphChangeItemRequest.subItemIndex = 0
                documentGraphChangeItemRequest.nodeIndex = documentGraphItemViewData.nodeIndex
                documentGraphChangeItemRequest.sentenceIndex = detailViewController!.currentSentenceIndex
                var udcDocumentTypeIdName = ""
                if detailViewController!.isPopup {
                    udcDocumentTypeIdName = detailViewController!.popupUdcDocumentTypeIdName
                } else {
                    udcDocumentTypeIdName = ApplicationSetting.DocumentType!
                }
                documentGraphChangeItemRequest.udcDocumentTypeIdName = udcDocumentTypeIdName
                documentGraphChangeItemRequest.objectControllerRequest = ObjectControllerRequest()
                documentGraphChangeItemRequest.objectControllerRequest.viewConfigPathIdName.append(contentsOf: detailViewController!.viewConfigPathIdName)
                documentGraphChangeItemRequest.objectControllerRequest.uvcViewItemType = detailViewController!.uvcViewItemType
                documentGraphChangeItemRequest.objectControllerRequest.editMode = detailViewController!.objectEditMode
                documentGraphChangeItemRequest.objectControllerRequest.groupUVCViewItemType = detailViewController!.groupUVCViewItemType
                documentGraphChangeItemRequest.objectControllerRequest.udcViewItemName = detailViewController!.udcViewItemName
                documentGraphChangeItemRequest.objectControllerRequest.udcViewItemId = detailViewController!.udcViewItemId
                detailViewController!.setCurrentOperation(name: "DocumentGraphNeuron.Document.Item.Change")
                detailViewController!.setCurrentOperationData(data: [detailViewController!.getCurrentOperation(): [
                    "documentGraphChangeItemRequest": documentGraphChangeItemRequest,
                    "neuronName": detailViewController!.neuronName]])
                detailViewController!.sendRequest(sourceName: detailViewController!.sourceName)
            }
        }
    }
    
    
    //    private func addOption(name: String, path: [String], level: Int, objectName: String, toParent: inout UVCOptionViewModel, isChildrenExist: Bool) -> UVCOptionViewModel {
    //        let uvcOptionViewModelSubChild = UVCOptionViewModel()
    //        let uvcViewModel = uvcViewGenerator.getOptionViewModel(name: name, description: "", category: "", language: ApplicationSetting.DocumentLanguage!, isChildrenExist: isChildrenExist, isEditable: false)
    //        uvcOptionViewModelSubChild._id = NSUUID().uuidString
    //        uvcOptionViewModelSubChild.parentId.append("7")
    //        uvcOptionViewModelSubChild.uvcViewModel = uvcViewModel
    //        uvcOptionViewModelSubChild.level = level
    //        uvcOptionViewModelSubChild.objectName = objectName
    //        toParent.children.append(uvcOptionViewModelSubChild)
    //        toParent.childrenId.append(uvcOptionViewModelSubChild._id)
    //        return uvcOptionViewModelSubChild
    //    }
    
    
    public func uvcOptionViewCellSelected(index: Int, level: Int, senderModel: [Any], sender: Any) {
        //        if isActivityProgress {
        //            return
        //        }
        //        if senderModel is UVCOptionViewModel {
        //            let uvcovm = senderModel as! UVCOptionViewModel
        //            let path = uvcovm.path.joined(separator: "->")
        //            if grammarFormMode {
        //                selectedGrammarItem = uvcovm.getText(name: "Name")!.value
        //                var uvcOptionViewRequest = UVCOptionViewRequest()
        //                uvcOptionViewRequest.operationName = "OptionViewController.Children.DeleteSelectedItems"
        //                uvcOptionViewRequest.path.append(contentsOf: ["Build", "Sentences"])
        ////                OptionViewController.optionViewControllers["Build"]?.request = uvcOptionViewRequest
        //                for item in uvcSelectedItem {
        //                    sentenceResponseList.removeValue(forKey: item._id)
        //                }
        //                if sentenceRequestList.count > 1 {
        //                    var udcSentenceGrammarPatternListLocal = [UDCSentenceGrammarPattern]()
        //                    var udcSentencePatternRequestListLocal = [UDCSentencePatternRequest]()
        //                    for srl in sentenceRequestList {
        //                        udcSentenceGrammarPatternListLocal.append(srl.udcSentenceGrammarPattern)
        //                        udcSentencePatternRequestListLocal.append(srl.udcSentencePatternRequest)
        //                    }
        //                    let udcSentenceGrammarPatternLocal = udcGrammarUtility.getConjunctionSentenceGrammarPattern(item: selectedGrammarItem, udcSentenceGrammarPattern: udcSentenceGrammarPatternListLocal)
        //                    let udcSentencePatternRequestLocal  = udcGrammarUtility.getConjunctionSentencePatternRequest(udcSentencePatternRequest: udcSentencePatternRequestListLocal)
        //                    var sentenceRequest = SentenceRequest()
        //                    sentenceRequest.udcSentenceGrammarPattern = udcSentenceGrammarPatternLocal
        //                    sentenceRequest.udcSentencePatternRequest = udcSentencePatternRequestLocal
        //                    sentenceRequestList.removeAll()
        //                    sentenceRequestList.append(sentenceRequest)
        //                    let jsonUtility = JsonUtility<SentenceRequest>()
        //                    print(jsonUtility.convertAnyObjectToJson(jsonObject: sentenceRequest))
        //                    detailViewController!.setCurrentOperation(name: "GrammarNeuron.Sentence.GrammarCategory.Generate"
        //                    currentOperationData.removeAll()
        //                    detailViewController!.setCurrentOperationData(data: [
        //                        "sentenceRequest": sentenceRequest,
        //                        "neuronName": detailViewController!.neuronName]
        //                    detailViewController!.sendRequest(source: self)
        //                    return
        //                }
        //
        //                grammarFormMode = false
        //                uvcOptionViewRequest = UVCOptionViewRequest()
        //                uvcOptionViewRequest.operationName = "OptionViewController.RightButton.Change"
        //                uvcOptionViewRequest.rightButton.append(contentsOf: ["", "",""])
        ////                OptionViewController.optionViewControllers["Build"]?.request = uvcOptionViewRequest
        //
        //                let selectedGrammarCategory = uvcovm.path[uvcovm.path.count - 2]
        //
        //                let udcGrammarUtilityRequest = UDCGrammarUtilityRequest()
        //                udcGrammarUtilityRequest.category = selectedGrammarCategory
        //                udcGrammarUtilityRequest.categoryItem = selectedGrammarItem
        //                udcGrammarUtilityRequest.udcGrammarItem.append(contentsOf: udcGrammarItem)
        //                let udcGrammarUtilityResponse = udcGrammarUtility.getGrammarRequest(udcGrammarUtilityRequest: udcGrammarUtilityRequest)
        //                let sentenceRequest = SentenceRequest()
        //                sentenceRequest._id = NSUUID().uuidString
        //                sentenceRequest.udcSentenceGrammarPattern = (udcGrammarUtilityResponse?.udcSentenceGrammarPattern)!
        //                sentenceRequest.udcSentencePatternRequest = (udcGrammarUtilityResponse?.udcSentencePatternRequest)!
        //                sentenceRequestList.append(sentenceRequest)
        //                detailViewController!.setCurrentOperation(name: "GrammarNeuron.Sentence.GrammarCategory.Generate"
        //                currentOperationData.removeAll()
        //                detailViewController!.setCurrentOperationData(data: [
        //                    "sentenceRequest": sentenceRequest,
        //                    "neuronName": detailViewController!.neuronName]
        //                detailViewController!.sendRequest(source: self)
        //            } else {
        //                if path == "Build->Document Items->Ingredient" ||
        //                     path == "Build->Document Items->Measurement" ||
        //                    path == "Build->Document Items->Measurement Unit" ||
        //                    path == "Build->Document Items->Cutting Methods" ||
        //                    path == "Build->Document Items->Action" ||
        //                    path == "Build->Document Items->Item State" ||
        //                    path == "Build->Document Items->Cooking Chef" ||
        //                    path == "Build->Document Items->Duration" ||
        //                    path == "Build->Document Items->Consistency" {
        //                    isActivityProgress = true
        //                    let name = uvcovm.getText(name: "Name")!.name
        //                    print("Selected: \(name)")
        //                    CallBrainControllerNeuron.delegateMap.removeAll()
        //                    CallBrainControllerNeuron.delegateMap["senderModel"] = uvcovm
        //                    CallBrainControllerNeuron.delegateMap["sender"] = sender
        //                    detailViewController!.setCurrentOperation(name: "TypeNeuron.Get"
        //                    currentOperationData.removeAll()
        //                    detailViewController!.setCurrentOperationData(data: [
        //                        "type": uvcovm.objectName,
        //                        "language": ApplicationSetting.DocumentLanguage!,
        //                        "fromText": "",
        //                        "sortedBy": "name",
        //                        "limitedTo": 50,
        //                        "isAll": false]
        //                    detailViewController!.sendRequest(source: self)
        //                } else if path == "Build->Recipe Categories->Basic Details" ||
        //                    path == "Build->Recipe Categories->Ingredient" ||
        //                    path == "Build->Recipe Categories->Pre Cooking Step" ||
        //                    path == "Build->Recipe Categories->Cooking Step" {
        //                    let name = uvcovm.path[uvcovm.path.count - 1]
        //                    if !detailViewController!.checkPathFound(path: "Recipe->\(name)") {
        //                        detailViewController!.addCategory(name: name, path: ["Recipe"])
        ////                        OptionViewController.optionViewControllers["Build"]?.dismiss(animated: true, completion: nil)
        //                    }
        //                }
        //            }
        //        }
    }
    
    public func setActivitiyInProgress(isActivityInProgress: Bool) {
        self.isActivityInProgress = isActivityInProgress
    }
    
    public func getActivitiyInProgress() -> Bool {
        return self.isActivityInProgress
    }
    
    public func handleDocumentInterfacePhoto(neuronRequest: NeuronRequest) {
        let jsonUtilityGetDocumentInterfacePhotoResponse = JsonUtility<GetDocumentInterfacePhotoResponse>()
        let getDocumentInterfacePhotoResponse = jsonUtilityGetDocumentInterfacePhotoResponse.convertJsonToAnyObject(json: neuronRequest.neuronOperation.neuronData.text)
        
        let documentGraphInsertItemRequestParam = DocumentGraphInsertItemRequest()
        documentGraphInsertItemRequestParam.isOption = true
        detailViewController!.uvcViewItemType = "UVCViewItemType.Photo"
        let uvcOptionViewModel = UVCOptionViewModel()
        uvcOptionViewModel.objectIdName = getDocumentInterfacePhotoResponse.objectIdName
        uvcOptionViewModel.objectNameIndex = getDocumentInterfacePhotoResponse.objectNameIndex
        uvcOptionViewModel.objectDocumentIdName = getDocumentInterfacePhotoResponse.objectDocumentIdName
        uvcOptionViewModel.objectName = getDocumentInterfacePhotoResponse.objectName
        
        setActivitiyInProgress(isActivityInProgress: false)
        insertItem(section: detailViewController!.currentNodeIndex, index: detailViewController!.currentItemIndex, level: detailViewController!.currentLevel, searchText: "Photo", itemData: "", uvOptionViewModel: uvcOptionViewModel, documentGraphInsertItemRequestParam: documentGraphInsertItemRequestParam, parentIndex: 0)
    }
    
    public func handleCategoryOptions(neuronRequest: NeuronRequest) {
        let jsonUtilityDocumentCategorySelectedResponse = JsonUtility<DocumentCategorySelectedResponse>()
        
        let documentCategorySelectedResponse = jsonUtilityDocumentCategorySelectedResponse.convertJsonToAnyObject(json: neuronRequest.neuronOperation.neuronData.text)
        detailViewController!.objectEditMode = documentCategorySelectedResponse.objectControllerResponse.editMode
        detailViewController!.uvcViewItemType = documentCategorySelectedResponse.objectControllerResponse.uvcViewItemType
        detailViewController!.udcViewItemName = documentCategorySelectedResponse.objectControllerResponse.udcViewItemName
        detailViewController!.udcViewItemId = documentCategorySelectedResponse.objectControllerResponse.udcViewItemId
        handleDocumentGraphItemViewData(documentItemViewInsertData: documentCategorySelectedResponse.documentItemViewInsertData, documentItemViewChangeData: documentCategorySelectedResponse.documentItemViewChangeData, documentItemViewDeleteData: documentCategorySelectedResponse.documentItemViewDeleteData, uvcViewItemType: documentCategorySelectedResponse.objectControllerResponse.uvcViewItemType, lineAdjustment: detailViewController!.currentNodeIndex, columnAdjustment: detailViewController!.currentItemIndex)
    }
    
    public func handleCategory(neuronRequest: NeuronRequest) {
        let jsonUtilityDocumentCategoryOptionSelectedResponse = JsonUtility<DocumentCategoryOptionSelectedResponse>()
        
        let documentCategoryOptionSelectedResponse = jsonUtilityDocumentCategoryOptionSelectedResponse.convertJsonToAnyObject(json: neuronRequest.neuronOperation.neuronData.text)
        detailViewController!.objectEditMode = documentCategoryOptionSelectedResponse.objectControllerResponse.editMode
        detailViewController!.uvcViewItemType = documentCategoryOptionSelectedResponse.objectControllerResponse.uvcViewItemType
        detailViewController!.udcViewItemName = documentCategoryOptionSelectedResponse.objectControllerResponse.udcViewItemName
        detailViewController!.udcViewItemId = documentCategoryOptionSelectedResponse.objectControllerResponse.udcViewItemId
        handleDocumentGraphItemViewData(documentItemViewInsertData: documentCategoryOptionSelectedResponse.documentItemViewInsertData, documentItemViewChangeData: documentCategoryOptionSelectedResponse.documentItemViewChangeData, documentItemViewDeleteData: documentCategoryOptionSelectedResponse.documentItemViewDeleteData, uvcViewItemType: documentCategoryOptionSelectedResponse.objectControllerResponse.uvcViewItemType, lineAdjustment: detailViewController!.currentNodeIndex, columnAdjustment: detailViewController!.currentItemIndex)
    }
    
    public func handlePhoto(neuronRequest: NeuronRequest) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            
            let binaryData = neuronRequest.neuronOperation.neuronData.binaryData
            var nodeIndex = [Int]()
            var itemIndex = [Int]()
            if self.detailViewController!.photoIdArray.count > 0 {
                for (uvcdgmlIndex, uvcdgml) in self.detailViewController!.uvcDocumentGraphModelList.enumerated() {
                    for (uvcvmIndex, uvcvm) in uvcdgml.uvcViewModel.enumerated() {
                        for uvcPhoto in uvcvm.uvcViewItemCollection.uvcPhoto {
                            print("name: \(uvcPhoto.name):\(self.detailViewController!.photoNameArray[0])")
                            print("id: \(uvcPhoto.optionObjectIdName):\(self.detailViewController!.photoIdArray[0])")
                            if uvcPhoto.optionObjectIdName == self.detailViewController!.photoIdArray[0] {
                                nodeIndex.append(uvcdgmlIndex)
                                itemIndex.append(uvcvmIndex)
                                uvcPhoto.binaryData = binaryData
                                if binaryData != nil {
                                    print("Photo found: \(uvcdgmlIndex), \(uvcdgmlIndex)")
                                }
                                uvcPhoto.isChanged = false
                                uvcPhoto.isReloaded = true
                                if self.detailViewController!.currentOperationNameBeforeGettingPhoto != "DocumentGraphNeuron.Document.Get.View" && self.detailViewController!.currentOperationNameBeforeGettingPhoto == "PhotoNeuron.Get.Item.Photo" {
                                    self.detailViewController!.collectionView.reloadItems(at: [NSIndexPath(item: uvcvmIndex, section: uvcdgmlIndex) as IndexPath])
                                }
                            }
                        }
                    }
                }
                if self.detailViewController!.currentOperationNameBeforeGettingPhoto == "DocumentGraphNeuron.Document.Get.View" {
                    self.detailViewController!.collectionView.reloadData()
                }
                self.detailViewController!.photoNameArray.remove(at: 0)
                self.detailViewController!.photoIdArray.remove(at: 0)
                self.detailViewController!.photoIsOptionArray.remove(at: 0)
                self.isActivityInProgress = false
                print("Photo count: \(self.detailViewController!.photoIdArray.count)")
                if self.detailViewController!.photoIdArray.count > 0 {
                    print("Getting photo: \(self.detailViewController!.photoIdArray[0]):\(self.detailViewController!.photoIsOptionArray[0])")
                    let documentGraphGetPhotoRequest = DocumentGetPhotoRequest()
                    documentGraphGetPhotoRequest.udcDocumentItemId = self.detailViewController!.photoIdArray[0]
                    documentGraphGetPhotoRequest.udcPhotoDataId = self.detailViewController!.photoIdArray[0]
                    documentGraphGetPhotoRequest.isOption = self.detailViewController!.photoIsOptionArray[0]
                    self.detailViewController!.setCurrentOperation(name: "PhotoNeuron.Get.Item.Photo")
                    self.detailViewController!.setCurrentOperationData(data: [self.detailViewController!.getCurrentOperation(): [
                        "language": ApplicationSetting.DocumentLanguage!,
                        "documentGraphGetPhotoRequest": documentGraphGetPhotoRequest]])
                    self.detailViewController!.sendRequest(sourceName: self.detailViewController!.sourceName)
                } else {
//                    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//                    let docDirectoryPath = paths[0]
//                    let pdfPath = docDirectoryPath.appendingPathComponent("viewPdf1.pdf")
//
//                    // writes to Disk directly.
//                    do {
//                        try PDFGenerator.generate([self.detailViewController!.collectionView], to: pdfPath, dpi: .default, password: "test")
//                    } catch (let error) {
//                        print(error)
//                    }
                }
                
            }
        }
        
            
        
    }
    
    public func handleGetViewConfigurationOptions(neuronRequest: NeuronRequest) {
        let jsonUtilityDocumentGetViewConfigurationOptionsResponse = JsonUtility<DocumentGetViewConfigurationOptionsResponse>()
        
        let documentDocumentGetViewConfigurationOptionsResponse = jsonUtilityDocumentGetViewConfigurationOptionsResponse.convertJsonToAnyObject(json: neuronRequest.neuronOperation.neuronData.text)
        
        if documentDocumentGetViewConfigurationOptionsResponse.uvcOptionViewModel.count > 0 {
            handleGetViewConfigurationOptions(uvcOptionViewModel: documentDocumentGetViewConfigurationOptionsResponse.uvcOptionViewModel)
        }
    }
    
    public func handleGetViewConfigurationOptions(uvcOptionViewModel: [UVCOptionViewModel]) {
        
        var viewConfigurationOptionViewModel = [UVCOptionViewModel]()
        detailViewController!.viewConfigurationOptionViewModelList.removeAll()
        for uvcovm in uvcOptionViewModel {
            viewConfigurationOptionViewModel.append(uvcovm)
        }
        let key = "UDCOptionMap.\(detailViewController!.uvcViewItemType.split(separator: ".")[1])Configuration"
        detailViewController!.optionTitle[key] = uvcOptionViewModel[0].getText(name: "Name")!.value
        fillUpOptionViewModelChilds(uvcOptionViewModel: &viewConfigurationOptionViewModel)
        for uvcovm in viewConfigurationOptionViewModel {
            if uvcovm.level == 1 {
                detailViewController!.viewConfigurationOptionViewModelList.append(uvcovm)
            }
        }
        detailViewController!.viewTypeConfigurationDictionary[key] = detailViewController!.viewConfigurationOptionViewModelList
    }
    
    public func handleStoreItemPhoto(neuronRequest: NeuronRequest) {
        let jsonUtilityDocumentGraphStorePhotoResponse = JsonUtility<DocumentStorePhotoResponse>()
        
        let documentGraphStorePhotoResponse = jsonUtilityDocumentGraphStorePhotoResponse.convertJsonToAnyObject(json: neuronRequest.neuronOperation.neuronData.text)
        detailViewController!.objectEditMode = documentGraphStorePhotoResponse.objectControllerResponse.editMode
        detailViewController!.uvcViewItemType = documentGraphStorePhotoResponse.objectControllerResponse.uvcViewItemType
        detailViewController!.udcViewItemName = documentGraphStorePhotoResponse.objectControllerResponse.udcViewItemName
        detailViewController!.udcViewItemId = documentGraphStorePhotoResponse.objectControllerResponse.udcViewItemId
        handleDocumentGraphItemViewData(documentItemViewInsertData: documentGraphStorePhotoResponse.documentItemViewInsertData, documentItemViewChangeData: documentGraphStorePhotoResponse.documentItemViewChangeData, documentItemViewDeleteData: documentGraphStorePhotoResponse.documentItemViewDeleteData, uvcViewItemType: documentGraphStorePhotoResponse.objectControllerResponse.uvcViewItemType, lineAdjustment: detailViewController!.currentNodeIndex, columnAdjustment: detailViewController!.currentItemIndex)
        
        isActivityInProgress = false
        changeItem(uvcOptionViewModel: nil, optionItemId: documentGraphStorePhotoResponse.documentItemViewChangeData[0].itemId, item: "")
        CallBrainControllerNeuron.delegateMap.removeAll()
    }
    
    public func handleDocumentReference(neuronRequest: NeuronRequest) {
        let jsonUtilityDocumentGraphItemReferenceResponse = JsonUtility<DocumentGraphItemReferenceResponse>()
        
        let documentGraphItemReferenceResponse = jsonUtilityDocumentGraphItemReferenceResponse.convertJsonToAnyObject(json: neuronRequest.neuronOperation.neuronData.text)
        if documentGraphItemReferenceResponse.uvcOptionViewModel.count > 0 {
            let uvcOptionViewRequest = UVCOptionViewRequest()
            uvcOptionViewRequest.operationName = "OptionViewController.Children.Add"
            uvcOptionViewRequest.pathIdName.append(contentsOf: documentGraphItemReferenceResponse.pathIdName)
            uvcOptionViewRequest.uvcOptionViewModel = documentGraphItemReferenceResponse.uvcOptionViewModel
            //            detailViewController!.optionViewController!.request = uvcOptionViewRequest
        } else {
            
            if documentGraphItemReferenceResponse.documentItemViewInsertData.count > 0 {
                for documentItemViewInsertData in documentGraphItemReferenceResponse.documentItemViewInsertData {
                    detailViewController!.uvcDocumentGraphModelList[documentItemViewInsertData.nodeIndex].isChildrenAllowed = documentItemViewInsertData.uvcDocumentGraphModel.isChildrenAllowed
                    detailViewController!.currentSentenceIndex = documentItemViewInsertData.sentenceIndex
                    detailViewController!.currentItemIndex += documentItemViewInsertData.uvcDocumentGraphModel.uvcViewModel.count
                    detailViewController!.uvcDocumentGraphModelList[documentItemViewInsertData.nodeIndex]._id = documentItemViewInsertData.uvcDocumentGraphModel._id
                    detailViewController!.uvcDocumentGraphModelList[documentItemViewInsertData.nodeIndex].uvcViewModel.insert(contentsOf: documentItemViewInsertData.uvcDocumentGraphModel.uvcViewModel, at: documentItemViewInsertData.itemIndex)
                    // Copy the id to the search box so that insertion again is possible, in the search box position
                    var itemId = ""
                    let uvcmFrom = detailViewController!.uvcDocumentGraphModelList[documentItemViewInsertData.nodeIndex].uvcViewModel[documentItemViewInsertData.itemIndex + 1]
                    for uvcText in uvcmFrom.uvcViewItemCollection.uvcText {
                        if uvcText.isEditable {
                            itemId = uvcText._id
                            break
                        }
                    }
                    let uvcm = detailViewController!.uvcDocumentGraphModelList[documentItemViewInsertData.nodeIndex].uvcViewModel[documentItemViewInsertData.itemIndex + 1]
                    for uvcText in uvcm.uvcViewItemCollection.uvcText {
                        if uvcText.isEditable {
                            uvcText._id = itemId
                            break
                        }
                    }
                    
                }
                detailViewController!.collectionView.reloadData()
            }
            
            
            detailViewController!.documetSentenceSearchBox?.text = ""
            detailViewController!.collectionView.reloadData()
        }
        
    }
    
    public func handleDocumentDeleteItem(neuronRequest: NeuronRequest) {
        let jsonUtilityDocumentGraphDeleteItemResponse = JsonUtility<DocumentGraphDeleteItemResponse>()
        
        let documentGraphDeleteItemResponse = jsonUtilityDocumentGraphDeleteItemResponse.convertJsonToAnyObject(json: neuronRequest.neuronOperation.neuronData.text)
        
        detailViewController!.objectEditMode = documentGraphDeleteItemResponse.objectControllerResponse.editMode
        detailViewController!.uvcViewItemType = documentGraphDeleteItemResponse.objectControllerResponse.uvcViewItemType
        detailViewController!.udcViewItemName = documentGraphDeleteItemResponse.objectControllerResponse.udcViewItemName
        detailViewController!.udcViewItemId = documentGraphDeleteItemResponse.objectControllerResponse.udcViewItemId
        detailViewController?.groupUVCViewItemType = documentGraphDeleteItemResponse.objectControllerResponse.groupUVCViewItemType
        handleDocumentGraphItemViewData(documentItemViewInsertData: documentGraphDeleteItemResponse.documentItemViewInsertData, documentItemViewChangeData: documentGraphDeleteItemResponse.documentItemViewChangeData, documentItemViewDeleteData: documentGraphDeleteItemResponse.documentItemViewDeleteData, uvcViewItemType: documentGraphDeleteItemResponse.objectControllerResponse.uvcViewItemType, lineAdjustment: documentGraphDeleteItemResponse.lineAdjustment, columnAdjustment: documentGraphDeleteItemResponse.columnAdjustment)
        //        doSearchBoxAdjustmentIfAny(lineAdjustment: documentGraphDeleteItemResponse.lineAdjustment, columnAdjustment: documentGraphDeleteItemResponse.columnAdjustment)
        if documentGraphDeleteItemResponse.refreshDocumentMap {
            refreshDocumentMap()
        }
    }
    
    public func handleDocumentGraphItemViewData(documentItemViewInsertData: [DocumentGraphItemViewData], documentItemViewChangeData: [DocumentGraphItemViewData], documentItemViewDeleteData: [DocumentGraphItemViewData], uvcViewItemType: String, lineAdjustment: Int, columnAdjustment: Int) {
        if documentItemViewInsertData.count > 0 {
            let count = detailViewController!.uvcDocumentGraphModelList.count
            var line = false
            for divid in documentItemViewInsertData {
                if count == 0 {
                    detailViewController!.uvcDocumentGraphModelList.append(divid.uvcDocumentGraphModel)
                } else {
                    if divid.documentInterfaceItemIdName != "UDCDocumentItemMapNode.Line" {
                        detailViewController!.uvcDocumentGraphModelList[divid.nodeIndex].isChildrenAllowed = divid.uvcDocumentGraphModel.isChildrenAllowed
                        detailViewController!.currentSentenceIndex = divid.sentenceIndex
                        detailViewController!.currentItemIndex += divid.uvcDocumentGraphModel.uvcViewModel.count
                        detailViewController!.uvcDocumentGraphModelList[divid.nodeIndex]._id = divid.uvcDocumentGraphModel._id
                        detailViewController!.uvcDocumentGraphModelList[divid.nodeIndex].level = divid.uvcDocumentGraphModel.level
                        detailViewController!.uvcDocumentGraphModelList[divid.nodeIndex].uvcViewModel.insert(contentsOf: divid.uvcDocumentGraphModel.uvcViewModel, at: divid.itemIndex)
                        // Copy the id to the search box so that insertion again is possible, in the search box position
                        var itemId = ""
                        //                        if detailViewController!.currentItemIndex > 1 {
                        if detailViewController!.uvcDocumentGraphModelList[divid.nodeIndex].uvcViewModel.count - 1 >= divid.itemIndex + 1 {
                            let uvcmFrom = detailViewController!.uvcDocumentGraphModelList[divid.nodeIndex].uvcViewModel[divid.itemIndex + 1]
                            for uvcText in uvcmFrom.uvcViewItemCollection.uvcText {
                                if uvcText.isEditable {
                                    itemId = uvcText._id
                                    break
                                }
                            }
                            let uvcm = detailViewController!.uvcDocumentGraphModelList[divid.nodeIndex].uvcViewModel[divid.itemIndex + 1]
                            for uvcText in uvcm.uvcViewItemCollection.uvcText {
                                if uvcText.isEditable {
                                    uvcText._id = itemId
                                    break
                                }
                            }
                        }
                        //                        }
                    } else {
                        line = true
                        detailViewController!.uvcDocumentGraphModelList.insert(divid.uvcDocumentGraphModel, at: divid.nodeIndex)
                        detailViewController!.uvcDocumentGraphModelList[divid.nodeIndex].level = divid.uvcDocumentGraphModel.level
                        detailViewController!.uvcDocumentGraphModelList[divid.nodeIndex].isChildrenAllowed = divid.uvcDocumentGraphModel.isChildrenAllowed
                        detailViewController!.currentSentenceIndex = divid.sentenceIndex
                        detailViewController!.currentItemIndex += divid.uvcDocumentGraphModel.uvcViewModel.count - 1
                        let searchBoxModel = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel[detailViewController!.currentItemIndex]
                        
                        detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel.remove(at: detailViewController!.currentItemIndex)
                        detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex + 1].uvcViewModel.append(searchBoxModel)
                        
                        detailViewController!.currentItemIndex = 1
                        detailViewController!.currentNodeIndex += 1
                        
                    }
                }
                
            }
            //            if !line && detailViewController!.currentNodeIndex != currentNodeIndex || detailViewController!.currentItemIndex != currentItemIndex {
            //                let searchBoxModel = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel[detailViewController!.currentItemIndex]
            //                detailViewController!.currentItemIndex = currentItemIndex
            //                detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel.remove(at: detailViewController!.currentItemIndex)
            //                detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex + 1].uvcViewModel.append(searchBoxModel)
            //
            //            }
            detailViewController!.collectionView.reloadData()
            detailViewController!.collectionView.performBatchUpdates({
                //                if line {
                if detailViewController!.currentNodeIndex > 0 {
                    reloadColelctionViewAll(fromNodeIndex: detailViewController!.currentNodeIndex - 1)
                    
                } else {
                    reloadColelctionViewAll(fromNodeIndex: detailViewController!.currentNodeIndex)
                }
                //                }
            }, completion: collectionViewBatchUpdatesPerformed)
            detailViewController!.documetSentenceSearchBox?.text = ""
            focusSearchBox()
        }
        if documentItemViewDeleteData.count > 0 {
            var line: Bool = false
            for divcd in documentItemViewDeleteData {
                if divcd.documentInterfaceItemIdName == "UDCDocumentItemMapNode.Line" {
                    line = true
                    let searchBoxModel = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel[detailViewController!.currentItemIndex]
                    if detailViewController!.currentNodeIndex == detailViewController!.uvcDocumentGraphModelList.count - 1 {
                        detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel.remove(at: detailViewController!.currentItemIndex)
                        detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex - 1].uvcViewModel.append(searchBoxModel)
                        detailViewController!.currentItemIndex = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex - 1].uvcViewModel.count - 1
                        detailViewController!.currentNodeIndex -= 1
                    } else {
                        detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel.remove(at: detailViewController!.currentItemIndex)
                        detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex + 1].uvcViewModel.append(searchBoxModel)
                        detailViewController!.currentItemIndex = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex + 1].uvcViewModel.count - 1
                    }
                    detailViewController!.uvcDocumentGraphModelList.remove(at: divcd.nodeIndex)
                    detailViewController!.currentSentenceIndex = divcd.sentenceIndex
                } else {
                    detailViewController!.currentSentenceIndex = divcd.sentenceIndex
                    detailViewController!.uvcDocumentGraphModelList[divcd.nodeIndex].uvcViewModel.remove(at: divcd.itemIndex + 1)
                    if divcd.itemIndex + 1 < detailViewController!.currentItemIndex {
                        detailViewController!.currentItemIndex -= 1
                    }
                }
            }
            detailViewController!.collectionView.reloadData()
            //            detailViewController!.collectionView.performBatchUpdates(nil, completion: nil)
            detailViewController!.collectionView.performBatchUpdates({
                if line {
                    if detailViewController!.currentNodeIndex > 0 {
                        reloadColelctionViewAll(fromNodeIndex: detailViewController!.currentNodeIndex - 1)
                    } else {
                        reloadColelctionViewAll(fromNodeIndex: detailViewController!.currentNodeIndex)
                    }
                } else {
                    reloadColelctionViewAll(fromNodeIndex: detailViewController!.currentNodeIndex)
                }
            }, completion: collectionViewBatchUpdatesPerformed)
            focusSearchBox()
        }
        if documentItemViewChangeData.count > 0 {
            for divcd in documentItemViewChangeData {
                // Since we have dedcuted while sending to server
                if detailViewController!.currentItemIndex <= divcd.itemIndex && detailViewController!.currentNodeIndex == divcd.nodeIndex && divcd.documentInterfaceItemIdName != "UDCDocumentItemMapNode.Line"{
                    divcd.itemIndex += 1
                }
                if uvcViewItemType == "UVCViewItemType.Photo" && !divcd.itemId.isEmpty {
                    detailViewController!.photoIdArray.removeAll()
                    detailViewController!.photoNameArray.removeAll()
                    divcd.itemIndex += 1
                }
                let uvcdm =  detailViewController!.uvcDocumentGraphModelList[divcd.nodeIndex].uvcViewModel[divcd.itemIndex]
                detailViewController!.uvcDocumentGraphModelList[divcd.nodeIndex].isChildrenAllowed = divcd.uvcDocumentGraphModel.isChildrenAllowed
                for uvcTable in uvcdm.uvcViewItemCollection.uvcTable {
                    for uvcTableRow in uvcTable.uvcTableRow {
                        for uvcTableColumn in uvcTableRow.uvcTableColumn {
                            for (_, uvcViewItem) in uvcTableColumn.uvcViewItem.enumerated() {
                                if uvcViewItemType != "UVCViewItemType.Choice" && uvcViewItemType != "UVCViewItemType.Photo" {
                                    for uvcButton in uvcdm.uvcViewItemCollection.uvcButton {
                                        if uvcButton.name == uvcViewItem.name {
                                            uvcButton.value = divcd.uvcDocumentGraphModel.uvcViewModel[0].uvcViewItemCollection.uvcButton[0].value
                                            break
                                        }
                                    }
                                    for uvcText in uvcdm.uvcViewItemCollection.uvcText {
                                        if uvcText.name == uvcViewItem.name {
                                            uvcText.value = divcd.uvcDocumentGraphModel.uvcViewModel[0].uvcViewItemCollection.uvcText[0].value
                                            break
                                        }
                                    }
                                } else {
                                    if uvcViewItemType == "UVCViewItemType.Photo" || uvcViewItemType == "UVCViewItemType.PhotoDocument" {
                                        detailViewController!.photoChange = true
                                        if uvcdm.uvcViewItemCollection.uvcPhoto.count > 0 {
                                            var index = 0
                                            if uvcdm.uvcViewItemCollection.uvcPhoto.count  > 1 {
                                                index = 1
                                            }
                                            if !divcd.itemId.isEmpty {
                                                uvcdm.uvcViewItemCollection.uvcPhoto[index].optionObjectIdName = divcd.itemId
                                            } else {
                                                
                                                uvcdm.uvcViewItemCollection.uvcPhoto[index].optionObjectIdName = divcd.uvcDocumentGraphModel.uvcViewModel[0].uvcViewItemCollection.uvcPhoto[0].optionObjectIdName
                                                if uvcdm.uvcViewItemCollection.uvcPhoto[index].isOptionAvailable! { detailViewController!.photoIdArray.append(uvcdm.uvcViewItemCollection.uvcPhoto[index].optionObjectIdName)
                                                    detailViewController!.photoNameArray.append(uvcdm.uvcViewItemCollection.uvcPhoto[index].name)
                                                    detailViewController!.photoIsOptionArray.append(uvcdm.uvcViewItemCollection.uvcPhoto[index].isOptionAvailable!)
                                                }
                                            }
                                            uvcdm.uvcViewItemCollection.uvcPhoto[index].isReloaded = true
                                        }
                                    }
                                }
                                if uvcViewItemType != "UVCViewItemType.Photo" {
                                    for uvcButton in uvcdm.uvcViewItemCollection.uvcButton {
                                        if uvcButton.name == uvcViewItem.name {
                                            uvcButton.value = divcd.uvcDocumentGraphModel.uvcViewModel[0].uvcViewItemCollection.uvcButton[0].value
                                            break
                                        }
                                    }
                                    for uvcText in uvcdm.uvcViewItemCollection.uvcText {
                                        if uvcText.name == uvcViewItem.name {
                                            uvcText.value = divcd.uvcDocumentGraphModel.uvcViewModel[0].uvcViewItemCollection.uvcText[0].value
                                            break
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                self.detailViewController!.collectionView.reloadItems(at: [NSIndexPath(item: divcd.itemIndex, section: divcd.nodeIndex) as IndexPath])
            }
            
            
            loadPhotoData()
            self.detailViewController!.collectionView.reloadItems(at: [NSIndexPath(item: detailViewController!.currentItemIndex, section: detailViewController!.currentNodeIndex) as IndexPath])
            focusSearchBox()
        }
        
        
        
        //        for (uvcdmlIndex, uvcdml) in detailViewController!.uvcDocumentGraphModelList.enumerated() {
        //            let fileUtility = FileUtility()
        //            let jsonUtility = JsonUtility<UVCDocumentGraphModel>()
        //            fileUtility.writeFile(fileName: "UVCDocumentGraphModel\(uvcdmlIndex).json", contents: jsonUtility.convertAnyObjectToJson(jsonObject: uvcdml))
        //
        //        }
        
    }
    
    private func collectionViewBatchUpdatesPerformed(status: Bool) {
        loadPhotoData()
        //        detailViewController!.getSearchBox().perform(#selector(detailViewController!.getSearchBox().becomeFirstResponder), with: nil, afterDelay: 0.1)
        //        detailViewController!.scrollToCurrent()
    }
    
    public func handleDocumentNewLine(neuronRequest: NeuronRequest) {
        let jsonUtilityDocumentGraphInsertNewLineResponse = JsonUtility<DocumentGraphInsertNewLineResponse>()
        
        let documentGraphInsertNewLineResponse = jsonUtilityDocumentGraphInsertNewLineResponse.convertJsonToAnyObject(json: neuronRequest.neuronOperation.neuronData.text)
        handleDocumentGraphItemViewData(documentItemViewInsertData: documentGraphInsertNewLineResponse.documentItemViewInsertData, documentItemViewChangeData: documentGraphInsertNewLineResponse.documentItemViewChangeData, documentItemViewDeleteData: documentGraphInsertNewLineResponse.documentItemViewDeleteData, uvcViewItemType: "UVCViewItemType.Text", lineAdjustment: documentGraphInsertNewLineResponse.currentNodeIndex, columnAdjustment: documentGraphInsertNewLineResponse.currentItemIndex)
        
        
        
    }
    
    private func reloadColelctionViewAll(fromNodeIndex: Int) {
        for nodeIndex in fromNodeIndex...detailViewController!.uvcDocumentGraphModelList.count - 1 {
            if detailViewController!.uvcDocumentGraphModelList[nodeIndex].uvcViewModel.count > 0 {
                for itemIndex in 0...detailViewController!.uvcDocumentGraphModelList[nodeIndex].uvcViewModel.count - 1 {
                    detailViewController!.collectionView.reloadItems(at: [NSIndexPath(item: itemIndex, section: nodeIndex) as IndexPath])
                }
            }
        }
    }
    
    
    public func handleDocumentDeleteLine(neuronRequest: NeuronRequest) {
        let jsonUtilityDocumentDeleteLineResponse = JsonUtility<DocumentGraphDeleteLineResponse>()
        
        let documentDeleteLineResponse = jsonUtilityDocumentDeleteLineResponse.convertJsonToAnyObject(json: neuronRequest.neuronOperation.neuronData.text)
        handleDocumentGraphItemViewData(documentItemViewInsertData: documentDeleteLineResponse.documentItemViewInsertData, documentItemViewChangeData: documentDeleteLineResponse.documentItemViewChangeData, documentItemViewDeleteData: documentDeleteLineResponse.documentItemViewDeleteData, uvcViewItemType: "UVCViewItemType.Text", lineAdjustment: detailViewController!.currentNodeIndex, columnAdjustment: detailViewController!.currentItemIndex)
    }
    
    public func handleDocumentChangeItem(neuronRequest: NeuronRequest) {
        let jsonUtilityDocumentGraphChangeItemResponse = JsonUtility<DocumentGraphChangeItemResponse>()
        
        let documentGraphChangeItemResponse = jsonUtilityDocumentGraphChangeItemResponse.convertJsonToAnyObject(json: neuronRequest.neuronOperation.neuronData.text)
        
        detailViewController!.objectEditMode = documentGraphChangeItemResponse.objectControllerResponse.editMode
        detailViewController!.uvcViewItemType = documentGraphChangeItemResponse.objectControllerResponse.uvcViewItemType
        detailViewController!.udcViewItemName = documentGraphChangeItemResponse.objectControllerResponse.udcViewItemName
        detailViewController!.udcViewItemId = documentGraphChangeItemResponse.objectControllerResponse.udcViewItemId
        detailViewController?.groupUVCViewItemType = documentGraphChangeItemResponse.objectControllerResponse.groupUVCViewItemType
        handleDocumentGraphItemViewData(documentItemViewInsertData: documentGraphChangeItemResponse.documentItemViewInsertData, documentItemViewChangeData: documentGraphChangeItemResponse.documentItemViewChangeData, documentItemViewDeleteData: documentGraphChangeItemResponse.documentItemViewDeleteData, uvcViewItemType: documentGraphChangeItemResponse.objectControllerResponse.uvcViewItemType, lineAdjustment: detailViewController!.currentNodeIndex, columnAdjustment: detailViewController!.currentItemIndex)
        
        if documentGraphChangeItemResponse.refreshDocumentMap {
            refreshDocumentMap()
        }
        
        detailViewController!.documentTitle = documentGraphChangeItemResponse.documentTitle
        //        detailViewController!.scrollToCurrent()
    }
    
    public func alertOk(name: String, data: Any?) {
        if name == "NotFoundWantToCreate" {
            getDocumentView(editMode: detailViewController!.isEditableMode, objectType: ApplicationSetting.DocumentType!, isToGetDuplicate: true, isToCheckIfFound: false, language: data as! String, isToLaunchDetailedView: false, isToLaunchConfigurationView: false, isDocumentMapView: false, isFormatView: false)
        } else if name == "DocumentGraphNeuron.Document.Delete" {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                let detailItem = data as! UVCDocumentMapRequest
                let callBrainControllerNeuron = CallBrainControllerNeuron()
                let documentGraphDeleteRequest = DocumentGraphDeleteRequest()
                documentGraphDeleteRequest.udcDocumentId = detailItem.uvcTreeNode.objectId!
                documentGraphDeleteRequest.udcDocumentTypeIdName = detailItem.uvcTreeNode.objectType
                documentGraphDeleteRequest.documentLanguage = detailItem.uvcTreeNode.language
                callBrainControllerNeuron.documentDelete(sourceName: self.detailViewController!.sourceName, documentGraphDeleteRequest: documentGraphDeleteRequest)
            }
            
        }
    }
    
    public func alertCancel(name: String, data: Any?) {
    }
    
    public func handleDocumentDelete(neuronRequest: NeuronRequest) {
        let jsonUtilityDocumentGraphDeleteResponse = JsonUtility<DocumentGraphDeleteResponse>()
        
        let documentGraphDeleteResponse = jsonUtilityDocumentGraphDeleteResponse.convertJsonToAnyObject(json: neuronRequest.neuronOperation.neuronData.text)
        if detailViewController!.documentId == documentGraphDeleteResponse.udcDocumentId {
            resetValues()
            detailViewController!.documentId = ""
            detailViewController!.setRightButton(name: ["UDCOptionMapNode.Elipsis"])
            detailViewController!.setEditable(editable: false)
            detailViewController!.collectionView.reloadData()
        }
    }
    
    public func handleDocumentGetView(neuronRequest: NeuronRequest) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            let jsonUtilityGetDocumentGraphViewResponse = JsonUtility<GetDocumentGraphViewResponse>()
            
            let getDocumentGraphViewResponse = jsonUtilityGetDocumentGraphViewResponse.convertJsonToAnyObject(json: neuronRequest.neuronOperation.neuronData.text)
            
            if getDocumentGraphViewResponse.isToCheckIfFound && getDocumentGraphViewResponse.isDocumentNotFound {
                for nos in neuronRequest.neuronOperation.neuronOperationStatus.neuronOperationSuccess! {
                    if nos.name == "NotFoundWantToCreate" {
                        self.detailViewController!.showAlertViewOKCancel(name: nos.name, message: nos.description, data: getDocumentGraphViewResponse.documentLanguage)
                        break
                    }
                }
                return
            }
            
            if getDocumentGraphViewResponse.isShowPopup {
                self.detailViewController!.addTab(title: getDocumentGraphViewResponse.documentTitle, documentId: getDocumentGraphViewResponse.documentId, udcDocumentTypeIdName: getDocumentGraphViewResponse.popupUdcDocumentTypeIdName)
                return
            }
            self.resetValues()
            ApplicationSetting.DocumentLanguage = getDocumentGraphViewResponse.documentLanguage
            self.detailViewController!.documentId = getDocumentGraphViewResponse.documentId
            self.detailViewController!.documentIdName = getDocumentGraphViewResponse.documentIdName
            self.detailViewController!.tabBarController?.tabBar.items![self.detailViewController!.tabBarController!.selectedIndex].title = getDocumentGraphViewResponse.documentTitle
            //
            //            self.detailViewController!.setDocumentTitle(title: getDocumentGraphViewResponse.documentTitle)
            self.detailViewController!.objectEditMode = getDocumentGraphViewResponse.objectControllerResponse.editMode
            self.detailViewController!.uvcViewItemType = getDocumentGraphViewResponse.objectControllerResponse.uvcViewItemType
            self.detailViewController!.udcViewItemName = getDocumentGraphViewResponse.objectControllerResponse.udcViewItemName
            self.detailViewController!.udcViewItemId = getDocumentGraphViewResponse.objectControllerResponse.udcViewItemId
            self.detailViewController?.groupUVCViewItemType = getDocumentGraphViewResponse.objectControllerResponse.groupUVCViewItemType
            self.handleDocumentGraphItemViewData(documentItemViewInsertData: getDocumentGraphViewResponse.documentItemViewInsertData, documentItemViewChangeData: getDocumentGraphViewResponse.documentItemViewChangeData, documentItemViewDeleteData: getDocumentGraphViewResponse.documentItemViewDeleteData, uvcViewItemType: getDocumentGraphViewResponse.objectControllerResponse.uvcViewItemType, lineAdjustment: getDocumentGraphViewResponse.currentNodeIndex, columnAdjustment: getDocumentGraphViewResponse.currentItemIndex)
            self.detailViewController!.currentNodeIndex = getDocumentGraphViewResponse.currentNodeIndex
            self.detailViewController!.currentItemIndex = getDocumentGraphViewResponse.currentItemIndex
            self.detailViewController!.currentSentenceIndex = getDocumentGraphViewResponse.currentSentenceIndex
            self.detailViewController!.currentLevel = getDocumentGraphViewResponse.currentLevel
            
            self.detailViewController!.toolbarView = getDocumentGraphViewResponse.toolbarView
            self.detailViewController!.objectControllerView = getDocumentGraphViewResponse.objectControllerView
            
            if self.detailViewController!.isEditableMode {
                if self.detailViewController!.isPopup {
                    self.detailViewController!.setRightButton(name: ["UDCOptionMapNode.Done"])
                } else {
                    self.detailViewController!.setRightButton(name: ["UDCOptionMapNode.Elipsis", "UDCOptionMapNode.Done"])
                }
            } else {
                self.detailViewController!.setRightButton(name: ["UDCOptionMapNode.Elipsis", "", ""])
            }
            
            self.populateDocumentOptions(documentOptions: &getDocumentGraphViewResponse.documentOptions, documentItemOptions: &getDocumentGraphViewResponse.documentItemOptions, categoryOptions: &getDocumentGraphViewResponse.categoryOptions, objectControllerOptions: &getDocumentGraphViewResponse.objectControllerOptions, photoOptions: &getDocumentGraphViewResponse.photoOptions)
            
            self.refreshDocumentMapCurrentDateTimeList()
            //       refreshDocumentMap()
            self.detailViewController!.documentTitle = getDocumentGraphViewResponse.documentTitle.capitalized
            self.detailViewController!.collectionView.reloadData()
            
        
            //        detailViewController!.scrollToCurrent()
            
//            let pdfFileUility = PDFFileUtility()
//            pdfFileUility.generatePdfFromCollectionView(self.detailViewController!.collectionView, filename: "myFancy.pdf") { (filename) in
//            // use your pdf here
//            }
        }
    }
    
    public func optionViewControllerLoadingCompleted() {
        //        if detailViewController!.optionViewController!.photoIdArray.count > 0 {
        //            print("Getting photo: \(detailViewController!.optionViewController!.photoIdArray[0])")
        //            let documentGraphGetPhotoRequest = DocumentGraphGetPhotoRequest()
        ////            documentGraphGetPhotoRequest.udcPhotoDataId = detailViewController!.optionViewController!.photoIdArray[0]
        //            detailViewController!.setCurrentOperation(name: "PhotoNeuron.Get.Item.Photo")
        //            detailViewController!.setCurrentOperationData(data: [detailViewController!.getCurrentOperation(): [
        //                "language": ApplicationSetting.DocumentLanguage!,
        //                "documentGraphGetPhotoRequest": documentGraphGetPhotoRequest]])
        //            detailViewController!.sendRequest(source: self)
        //        }
    }
    
    public func loadPhotoData() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            
            if !self.detailViewController!.photoChange {
                self.detailViewController!.photoIdArray.removeAll()
                self.detailViewController!.photoNameArray.removeAll()
                self.detailViewController!.photoIsOptionArray.removeAll()
                for (uvcdgmlIndex, uvcdgml) in self.detailViewController!.uvcDocumentGraphModelList.enumerated() {
                    for (uvcvmIndex, uvcvm) in uvcdgml.uvcViewModel.enumerated() {
                        var index = 0
                        if uvcvm.uvcViewItemCollection.uvcPhoto.count > 1 {
                            index = 1
                        }
                        for (uvcPhotoIndex, uvcPhoto) in uvcvm.uvcViewItemCollection.uvcPhoto.enumerated() {
                            if (uvcPhoto.binaryData == nil || ((self.detailViewController!.photoIdArray.count > 0) && uvcPhoto.name == self.detailViewController!.photoNameArray[0] && uvcPhoto.optionObjectIdName != self.detailViewController!.photoIdArray[0])) && !uvcPhoto.optionObjectIdName.isEmpty && uvcPhotoIndex == index {
                                print("Found photo at row: \(uvcdgmlIndex),\(uvcvmIndex),\(uvcPhoto.isOptionAvailable!): \(uvcPhoto.optionObjectIdName)")
                                self.detailViewController!.photoIdArray.append(uvcPhoto.optionObjectIdName)
                                self.detailViewController!.photoNameArray.append(uvcPhoto.name)
                                self.detailViewController!.photoIsOptionArray.append(uvcPhoto.isOptionAvailable!)
                            }
                        }
                    }
                }
            } else {
                self.detailViewController!.collectionView.reloadData()
            }
            self.detailViewController!.photoChange = false
            print("Photo count: \(self.detailViewController!.photoIdArray.count)")
            if self.detailViewController!.photoIdArray.count > 0 {
                print("Getting photo: \(self.detailViewController!.photoIdArray[0]):\(self.detailViewController!.photoIsOptionArray[0])")
                let documentGraphGetPhotoRequest = DocumentGetPhotoRequest()
                documentGraphGetPhotoRequest.udcDocumentItemId = self.detailViewController!.photoIdArray[0]
                documentGraphGetPhotoRequest.udcPhotoDataId = self.detailViewController!.photoIdArray[0]
                documentGraphGetPhotoRequest.isOption = self.detailViewController!.photoIsOptionArray[0]
                if self.detailViewController!.getCurrentOperation() != "PhotoNeuron.Get.Item.Photo" {
                    self.detailViewController!.currentOperationNameBeforeGettingPhoto = self.detailViewController!.getCurrentOperation()
                }
                self.detailViewController!.setCurrentOperation(name: "PhotoNeuron.Get.Item.Photo")
                self.detailViewController!.setCurrentOperationData(data: [self.detailViewController!.getCurrentOperation(): [
                    "language": ApplicationSetting.DocumentLanguage!,
                    "documentGraphGetPhotoRequest": documentGraphGetPhotoRequest]])
                
                self.detailViewController!.sendRequest(sourceName: self.detailViewController!.sourceName)
            }
        }
    }
    
    public func handledocumentInsertItem(neuronRequest: NeuronRequest) {
        let jsonUtilitydocumentGraphInsertItemResponse = JsonUtility<DocumentGraphInsertItemResponse>()
        let documentGraphInsertItemResponse = jsonUtilitydocumentGraphInsertItemResponse.convertJsonToAnyObject(json: neuronRequest.neuronOperation.neuronData.text)
        detailViewController!.objectEditMode = documentGraphInsertItemResponse.objectControllerResponse.editMode
        detailViewController!.uvcViewItemType = documentGraphInsertItemResponse.objectControllerResponse.uvcViewItemType
        detailViewController!.udcViewItemName = documentGraphInsertItemResponse.objectControllerResponse.udcViewItemName
        detailViewController!.udcViewItemId = documentGraphInsertItemResponse.objectControllerResponse.udcViewItemId
        detailViewController?.groupUVCViewItemType = documentGraphInsertItemResponse.objectControllerResponse.groupUVCViewItemType
        handleDocumentGraphItemViewData(documentItemViewInsertData: documentGraphInsertItemResponse.documentItemViewInsertData, documentItemViewChangeData: documentGraphInsertItemResponse.documentItemViewChangeData, documentItemViewDeleteData: documentGraphInsertItemResponse.documentItemViewDeleteData, uvcViewItemType: documentGraphInsertItemResponse.objectControllerResponse.uvcViewItemType, lineAdjustment: documentGraphInsertItemResponse.lineAdjustment, columnAdjustment: documentGraphInsertItemResponse.columnAdjustment)
        doSearchBoxAdjustmentIfAny(lineAdjustment: documentGraphInsertItemResponse.lineAdjustment, columnAdjustment: documentGraphInsertItemResponse.columnAdjustment)
        
        //        if documentGraphInsertItemResponse.objectControllerResponse != nil {
        //            if documentGraphInsertItemResponse.objectControllerResponse.viewItemOptions.count > 0 {
        //                handleViewItemOptions(uvcOptionViewModel:  documentGraphInsertItemResponse.objectControllerResponse.viewItemOptions)
        //            }
        //        }
        detailViewController!.setDocumentTitle(title: documentGraphInsertItemResponse.documentTitle)
        //        if documentGraphInsertItemResponse.refreshDocumentMap {
        //            refreshDocumentMap()
        //        }
        
    }
    
    private func doSearchBoxAdjustmentIfAny(lineAdjustment: Int, columnAdjustment: Int) {
        if !detailViewController!.popupUdcDocumentTypeIdName.isEmpty {
            let searchBoxModel = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel[detailViewController!.currentItemIndex]
            if lineAdjustment != 0 {
                detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel.remove(at: detailViewController!.currentItemIndex)
                detailViewController!.currentNodeIndex = detailViewController!.currentNodeIndex + lineAdjustment
            }
            if columnAdjustment != 0 {
                detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel.remove(at: detailViewController!.currentItemIndex)
                detailViewController!.currentItemIndex = detailViewController!.currentItemIndex + columnAdjustment
            }
            if lineAdjustment != 0 || columnAdjustment != 0 {        detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel.insert(searchBoxModel, at: detailViewController!.currentItemIndex)
            }
            self.detailViewController!.collectionView.reloadItems(at: [NSIndexPath(item: detailViewController!.currentItemIndex, section: detailViewController!.currentNodeIndex) as IndexPath])
            
        }
    }
    
    private func focusSearchBox() {
        
        let searchBoxObject = detailViewController!.collectionView.cellForItem(at: NSIndexPath(item: (detailViewController?.currentItemIndex)!, section: detailViewController!.currentNodeIndex) as IndexPath)
        if searchBoxObject != nil {
            let searchBox = searchBoxObject as! DetailViewCell
            let uiTextField = searchBox.uvcViewController.uvcUIViewControllerItemCollection.getTextField(tag: 0, name: "UDCDocumentItemMapNode.SearchDocumentItems")?.uiTextField
            if uiTextField != nil {
                focusTextField(uiTextField: uiTextField!)
            }
        }
    }
    
    private func handleViewItemOptions(uvcOptionViewModel: [UVCOptionViewModel]) {
        detailViewController!.objectControllerOptionViewModel.removeAll()
        detailViewController!.objectControllerOptionViewModelList.removeAll()
        for uvcovm in uvcOptionViewModel {
            detailViewController!.objectControllerOptionViewModel.append(uvcovm)
        }
        detailViewController!.optionTitle["UDCOptionMap.ViewOptions"] = detailViewController!.objectControllerOptionViewModel[0].getText(name: "Name")!.value
        fillUpOptionViewModelChilds(uvcOptionViewModel: &detailViewController!.objectControllerOptionViewModel)
        for uvcovm in detailViewController!.objectControllerOptionViewModel {
            if uvcovm.level == 1 {
                detailViewController!.objectControllerOptionViewModelList.append(uvcovm)
            }
        }
        detailViewController!.objectControllerOptionViewModel = detailViewController!.objectControllerOptionViewModelList
    }
    
    public func handleDocumentNew(neuronRequest: NeuronRequest) {
        resetValues()
        detailViewController!.setEditable(editable: true)
        let jsonUtilityDocumentGraphNewResponse = JsonUtility<DocumentGraphNewResponse>()
        let documentGraphNewResponse = jsonUtilityDocumentGraphNewResponse.convertJsonToAnyObject(json: neuronRequest.neuronOperation.neuronData.text)
        if !documentGraphNewResponse.documentLanguage.isEmpty {
            ApplicationSetting.DocumentLanguage = documentGraphNewResponse.documentLanguage
        }
        detailViewController!.objectEditMode = documentGraphNewResponse.objectControllerResponse.editMode
        detailViewController!.udcViewItemName = documentGraphNewResponse.objectControllerResponse.udcViewItemName
        detailViewController!.groupUVCViewItemType = documentGraphNewResponse.objectControllerResponse.groupUVCViewItemType
        detailViewController!.uvcViewItemType = documentGraphNewResponse.objectControllerResponse.uvcViewItemType
        detailViewController!.documentId = documentGraphNewResponse.documentId
        detailViewController!.uvcDocumentGraphModelList = documentGraphNewResponse.uvcDocumentGraphModel
        detailViewController!.currentLevel = documentGraphNewResponse.currentLevel
        detailViewController!.currentItemIndex =  documentGraphNewResponse.currentItemIndex
        detailViewController!.currentNodeIndex =  documentGraphNewResponse.currentNodeIndex
        detailViewController!.currentSentenceIndex = documentGraphNewResponse.currentSentenceIndex
        
        detailViewController!.toolbarView = documentGraphNewResponse.toolbarView
        detailViewController!.objectControllerView = documentGraphNewResponse.objectControllerView
        
        detailViewController!.setRightButton(name: ["UDCOptionMapNode.Elipsis", "UDCOptionMapNode.Done"])
        
        populateDocumentOptions(documentOptions: &documentGraphNewResponse.documentOptions, documentItemOptions: &documentGraphNewResponse.documentItemOptions, categoryOptions: &documentGraphNewResponse.categoryOptions, objectControllerOptions: &documentGraphNewResponse.objectControllerOptions, photoOptions: &documentGraphNewResponse.photoOptions)
        
        detailViewController!.collectionView.reloadData()
        
        //        refreshDocumentMap()
        
        detailViewController!.setDocumentTitle(title: documentGraphNewResponse.documentTitle)
        
    }
    
    private func populateDocumentOptions(documentOptions: inout [UVCOptionViewModel], documentItemOptions: inout [UVCOptionViewModel], categoryOptions: inout [String: [UVCOptionViewModel]], objectControllerOptions: inout [UVCOptionViewModel], photoOptions: inout [UVCOptionViewModel]) {
        
        detailViewController!.documentOptionsOptionViewModel.removeAll()
        detailViewController!.documentOptionsOptionViewModelList.removeAll()
        for uvcovm in documentOptions {
            detailViewController!.documentOptionsOptionViewModel.append(uvcovm)
        }
        detailViewController!.optionTitle["UDCOptionMap.DocumentOptions"] = detailViewController!.documentOptionsOptionViewModel[0].getText(name: "Name")!.value
        fillUpDocumentOptionsChilds()
        for uvcovm in detailViewController!.documentOptionsOptionViewModel {
            if uvcovm.level == 1 {
                detailViewController!.documentOptionsOptionViewModelList.append(uvcovm)
            }
        }
        detailViewController!.documentOptionsOptionViewModel = detailViewController!.documentOptionsOptionViewModelList
        
        detailViewController!.documentItemOptionViewModel.removeAll()
        detailViewController!.documentItemOptionViewModelList.removeAll()
        for uvcovm in documentItemOptions {
            detailViewController!.documentItemOptionViewModel.append(uvcovm) 
        }
        detailViewController!.optionTitle["UDCOptionMap.DocumentItemOptions"] = detailViewController!.documentItemOptionViewModel[0].getText(name: "Name")!.value
        fillUpRecipeItemSearchOptionChilds()
        for uvcovm in detailViewController!.documentItemOptionViewModel {
            if uvcovm.level == 1 {
                detailViewController!.documentItemOptionViewModelList.append(uvcovm)
            }
        }
        detailViewController!.documentItemOptionViewModel = detailViewController!.documentItemOptionViewModelList
        
        for categoryOptions in  categoryOptions {
            detailViewController!.categoryOptionsOptionViewModel.removeAll()
            detailViewController!.categoryOptionsOptionViewModelList.removeAll()
            for uvcovm in categoryOptions.value {
                detailViewController!.categoryOptionsOptionViewModel.append(uvcovm)
            }
            fillUpOptionViewModelChilds(uvcOptionViewModel: &detailViewController!.categoryOptionsOptionViewModel)
            for uvcovm in detailViewController!.categoryOptionsOptionViewModel {
                if uvcovm.level == 2 {
                    detailViewController!.categoryOptionsOptionViewModelList.append(uvcovm)
                }
            }
            detailViewController!.categoryOptionsOptionViewModel = detailViewController!.categoryOptionsOptionViewModelList
            detailViewController!.categoryOptionsDictionary[categoryOptions.key] = detailViewController!.categoryOptionsOptionViewModelList
        }
        
        handleViewItemOptions(uvcOptionViewModel:  objectControllerOptions)
        
        detailViewController!.photoOptionViewModel.removeAll()
        detailViewController!.photoOptionViewModelList.removeAll()
        for uvcovm in photoOptions {
            detailViewController!.photoOptionViewModel.append(uvcovm)
        }
        detailViewController!.optionTitle["UDCOptionMap.PhotoOptions"] = detailViewController!.photoOptionViewModel[0].getText(name: "Name")!.value
        fillUpOptionViewModelChilds(uvcOptionViewModel: &detailViewController!.photoOptionViewModel)
        for uvcovm in detailViewController!.photoOptionViewModel {
            if uvcovm.level == 1 {
                detailViewController!.photoOptionViewModelList.append(uvcovm)
            }
        }
        detailViewController!.photoOptionViewModel = detailViewController!.photoOptionViewModelList
    }
    
    private func refreshDocumentMap() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            let udcDocumentMapRequest = UVCDocumentMapRequest()
            udcDocumentMapRequest.operationName = "DocumentMap.Refresh"
            self.detailViewController!.masterViewController!.masterItem = udcDocumentMapRequest
        }
    }
    
    private func goToPathInDocumentMap(pathIdNameText: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            let udcDocumentMapRequest = UVCDocumentMapRequest()
            udcDocumentMapRequest.operationName = "DocumentMap.GoTo"
            udcDocumentMapRequest.uvcTreeNode.pathIdName = pathIdNameText.components(separatedBy: "->")
            self.detailViewController!.masterViewController!.masterItem = udcDocumentMapRequest
        }
    }
    
    private func refreshDocumentMapCurrentDateTimeList() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            let udcDocumentMapRequest = UVCDocumentMapRequest()
            udcDocumentMapRequest.operationName = "DocumentMap.RefreshCurrentDateTimeList"
            self.detailViewController!.masterViewController!.masterItem = udcDocumentMapRequest
        }
    }
    
    public func getObjectControllerView() {
        let getObjectControllerViewRequest = GetObjectControllerViewRequest()
        detailViewController!.setCurrentOperation(name: "DocumentGraphNeuron.Get.ViewController.View")
        detailViewController!.setCurrentOperationData(data: [detailViewController!.getCurrentOperation(): [
            "language": ApplicationSetting.DocumentLanguage!,
            "getObjectControllerViewRequest": getObjectControllerViewRequest,
            "neuronName": detailViewController!.neuronName]])
        detailViewController!.sendRequest(sourceName: self.detailViewController!.sourceName)
    }
    
    
    public func optionViewControllerEnteredOption(senderModel: [Any]) {
        let uvcOptionViewModel = senderModel as! [UVCOptionViewModel]
        let pathLocal = uvcOptionViewModel[0].pathIdName[0].joined(separator: "->")
        if pathLocal.hasPrefix("Build->Document Items->Ingredient->") ||
            pathLocal.hasPrefix("Build->Document Items->Measurement->") ||
            pathLocal.hasPrefix("Build->Document Items->Measurement Unit->") ||
            pathLocal.hasPrefix("Build->Document Items->Cutting Methods->") ||
            pathLocal.hasPrefix("Build->Document Items->Action->") ||
            pathLocal.hasPrefix("Build->Document Items->Item State->") ||
            pathLocal.hasPrefix("Build->Document Items->Cooking Chef->") ||
            pathLocal.hasPrefix("Build->Document Items->Duration->") ||
            pathLocal.hasPrefix("Build->Document Items->Consistency->") ||
            pathLocal.hasPrefix("Build->Sentences->"){
            let uvcOptionViewRequest = UVCOptionViewRequest()
            uvcOptionViewRequest.operationName = "OptionViewController.RightButton.Change"
            uvcOptionViewRequest.rightButton.append(contentsOf: ["Grammar", "",""])
            //            OptionViewController.optionViewControllers["Build"]?.request = uvcOptionViewRequest
        } else {
            let uvcOptionViewRequest = UVCOptionViewRequest()
            uvcOptionViewRequest.operationName = "OptionViewController.RightButton.Change"
            uvcOptionViewRequest.rightButton.append(contentsOf: ["", "",""])
            //            OptionViewController.optionViewControllers["Build"]?.request = uvcOptionViewRequest
        }
    }
    
    public func handleType(neuronRequest: NeuronRequest) {
        let jsonUtility = JsonUtility<GetDocumentItemOptionResponse>()
        
        let typeResponse = jsonUtility.convertJsonToAnyObject(json: neuronRequest.neuronOperation.neuronData.text)
        
        if detailViewController!.getCurrentOperation() == "DocumentGraphNeuron.DocumentItem.Get" ||
            detailViewController!.getCurrentOperation() == "DocumentGraphNeuron.DocumentItem.Search" {
            let height = 300
            var uvcOptionViewModelLocal = [UVCOptionViewModel]()
            for uvcovm in typeResponse.uvcOptionViewModel {
                if uvcovm.level == 1 {
                    uvcOptionViewModelLocal.append(uvcovm)
                }
            }
            if !isSearchActive {
                detailViewController!.showPopover(category: typeResponse.uvcOptionViewModel[0].getText(name: "Name")!.value, uvcOptionViewModel: uvcOptionViewModelLocal, width: 350, height: height, sender: CallBrainControllerNeuron.delegateMap["DocumentItem.Get.Sender"], delegate: detailViewController! as UIPopoverPresentationControllerDelegate, optionDelegate: self, goToOption: "", isDismissedAutomatically: false, optionViewControllerName: "Document Items", rightButton: ["", "", ""], idName: typeResponse.uvcOptionViewModel[0].idName, operationName: "Document Items", documentGraphItemSearchRequest: nil, documentGraphItemReferenceRequest: nil, typeRequest: nil, documentGraphItemViewData: nil, documentMapSearchDocumentRequest: nil)
            } else {
                let uvcOptionViewRequest = UVCOptionViewRequest()
                uvcOptionViewRequest.operationName = "OptionViewController.SearchResult"
                uvcOptionViewRequest.uvcOptionViewModel = uvcOptionViewModelLocal
                //                detailViewController!.optionViewController!.request = uvcOptionViewRequest
            }
        } else {
            let uvcOptionViewModel = CallBrainControllerNeuron.delegateMap["senderModel"] as! UVCOptionViewModel
            let height = 600 // 50 * detailViewController!.uvcOptionViewModelList.count
            let uvcOptionViewRequest = UVCOptionViewRequest()
            uvcOptionViewRequest.operationName = "OptionViewController.Children.Add"
            uvcOptionViewRequest.uvcOptionViewModel = typeResponse.uvcOptionViewModel
            //        OptionViewController.optionViewControllers["Build"]?.request = uvcOptionViewRequest
            optionViewControllerEnteredOption(senderModel: [uvcOptionViewModel])
        }
        
    }
    
    public func handleObjectControllerView(neuronRequest: NeuronRequest) {
        let jsonUtility = JsonUtility<UVCToolbarView>()
        detailViewController!.objectControllerView = jsonUtility.convertJsonToAnyObject(json: neuronRequest.neuronOperation.neuronData.text)
        detailViewController!.collectionView.reloadData()
        
    }
    
    public func handleDocumentItemSearch(neuronRequest: NeuronRequest) {
        isActivityInProgress = false
        processingSentence = false
        let jsonUtility = JsonUtility<DocumentGraphItemSearchResponse>()
        
        let documentGraphItemSearchResponse = jsonUtility.convertJsonToAnyObject(json: neuronRequest.neuronOperation.neuronData.text)
        
        // If only one item then insert the item
        let detailViewCell = detailViewController!.collectionView.cellForItem(at: NSIndexPath(item: (detailViewController?.currentItemIndex)!, section: detailViewController!.currentNodeIndex) as IndexPath) as! DetailViewCell
        let searchText = detailViewCell.getViewController().uvcUIViewControllerItemCollection.getTextField(tag: 0, name: "UDCDocumentItemMapNode.SearchDocumentItems")?.uiTextField.text?.trimmingCharacters(in: .whitespaces)
        if documentGraphItemSearchResponse.uvcOptionViewModel.count == 2 && searchText == documentGraphItemSearchResponse.uvcOptionViewModel[1].getText(name: "Name")?.value {
            insertItem(section: detailViewController!.currentNodeIndex, index: detailViewController!.currentItemIndex, level: detailViewController!.currentLevel, searchText: documentGraphItemSearchResponse.uvcOptionViewModel[1].getText(name: "Name")!.value, itemData: "", uvOptionViewModel: documentGraphItemSearchResponse.uvcOptionViewModel[1], documentGraphInsertItemRequestParam: nil, parentIndex: 0)
            return
        }
        
        // More than one item show the list of items
        var uvcOptionViewModelLocal = [UVCOptionViewModel]()
        for uvcovm in documentGraphItemSearchResponse.uvcOptionViewModel {
            if uvcovm.level == 1 {
                uvcOptionViewModelLocal.append(uvcovm)
            }
        }
        let height = 300
        
        detailViewController!.showPopover(category: documentGraphItemSearchResponse.uvcOptionViewModel[0].getText(name: "Name")!.value, uvcOptionViewModel: uvcOptionViewModelLocal, width: 350, height: height, sender: CallBrainControllerNeuron.delegateMap["sender"] as! UITextField, delegate: detailViewController! as UIPopoverPresentationControllerDelegate, optionDelegate: self, goToOption: "", isDismissedAutomatically: false, optionViewControllerName: "Document Search Items", rightButton: [detailViewController!.optionLabel["UDCOptionMapNode.NotInList"]!, "", ""], idName: "", operationName: "Document Search Items", documentGraphItemSearchRequest: nil, documentGraphItemReferenceRequest: nil, typeRequest: nil, documentGraphItemViewData: nil, documentMapSearchDocumentRequest: nil)
        
    }
    
    
    public func handleOptions(neuronRequest: NeuronRequest) {
        let jsonUtility = JsonUtility<GetOptionMapResponse>()
        
        let getOptionMapResponse = jsonUtility.convertJsonToAnyObject(json: neuronRequest.neuronOperation.neuronData.text)
        
        if getOptionMapResponse.name == "UDCOptionMap.DocumentOptions" {
            detailViewController!.documentOptionsOptionViewModel.removeAll()
            detailViewController!.documentOptionsOptionViewModelList.removeAll()
            for uvcovm in getOptionMapResponse.uvcOptionMapViewModel.uvcOptionViewModel {
                detailViewController!.documentOptionsOptionViewModel.append(uvcovm)
            }
            detailViewController!.optionTitle["UDCOptionMap.DocumentOptions"] = detailViewController!.documentOptionsOptionViewModel[0].getText(name: "Name")!.value
            fillUpDocumentOptionsChilds()
            for uvcovm in detailViewController!.documentOptionsOptionViewModel {
                if uvcovm.level == 1 {
                    detailViewController!.documentOptionsOptionViewModelList.append(uvcovm)
                }
            }
            detailViewController!.documentOptionsOptionViewModel = detailViewController!.documentOptionsOptionViewModelList
        }
        
    }
    
    
    private func fillUpDocumentOptionsChilds() {
        for uvcovm in detailViewController!.documentOptionsOptionViewModel {
            if uvcovm.childrenId.count > 0 {
                let uvcovmChilds = getChildrens(uvcOptionViewModelArray: detailViewController!.documentOptionsOptionViewModel, childrenId: uvcovm.childrenId)
                uvcovm.parentId.append(uvcovm._id)
                for child in uvcovmChilds {
                    uvcovm.children.append(child)
                }
                
            }
        }
        
    }
    
    private func fillUpOptionViewModelChilds(uvcOptionViewModel: inout [UVCOptionViewModel]) {
        for uvcovm in uvcOptionViewModel {
            if uvcovm.childrenId.count > 0 {
                let uvcovmChilds = getChildrens(uvcOptionViewModelArray: uvcOptionViewModel, childrenId: uvcovm.childrenId)
                uvcovm.parentId.append(uvcovm._id)
                for child in uvcovmChilds {
                    uvcovm.children.append(child)
                }
                
            }
        }
        
    }
    
    private func fillUpRecipeItemSearchOptionChilds() {
        for uvcovm in detailViewController!.documentItemOptionViewModel {
            if uvcovm.childrenId.count > 0 {
                let uvcovmChilds = getChildrens(uvcOptionViewModelArray: detailViewController!.documentItemOptionViewModel, childrenId: uvcovm.childrenId)
                uvcovm.parentId.append(uvcovm._id)
                for child in uvcovmChilds {
                    uvcovm.children.append(child)
                }
                
            }
        }
        
    }
    
    private func fillUpChilds() {
        for uvcovm in detailViewController!.uvcOptionViewModel {
            if uvcovm.childrenId.count > 0 {
                let uvcovmChilds = getChildrens(uvcOptionViewModelArray: detailViewController!.uvcOptionViewModel, childrenId: uvcovm.childrenId)
                uvcovm.parentId.append(uvcovm._id)
                for child in uvcovmChilds {
                    uvcovm.children.append(child)
                }
                
            }
        }
        
    }
    
    
    private func getChildrens(uvcOptionViewModelArray: [UVCOptionViewModel], childrenId: [String]) -> [UVCOptionViewModel] {
        var uvcOptionViewModelReturn = [UVCOptionViewModel]()
        for children in childrenId {
            for uvcovm in uvcOptionViewModelArray {
                if uvcovm._id == children {
                    uvcOptionViewModelReturn.append(uvcovm)
                }
            }
        }
        
        return uvcOptionViewModelReturn
    }
    
    public func searchOptionsSelected(options: [Bool]) {
        searchOptionSelection = options
    }
    
    private func newLine() {
        let documentGraphInsertNewLineRequest = DocumentGraphInsertNewLineRequest()
        documentGraphInsertNewLineRequest.itemIndex = detailViewController!.currentItemIndex
        documentGraphInsertNewLineRequest.nodeIndex = detailViewController!.currentNodeIndex
        documentGraphInsertNewLineRequest.documentId = detailViewController!.documentId
        documentGraphInsertNewLineRequest.nodeId = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex]._id
        if detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].parentId.count > 0 {
            documentGraphInsertNewLineRequest.parentId = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].parentId[0]
        }
        if detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].isChildrenAllowed {
            documentGraphInsertNewLineRequest.level = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].level + 1
        } else {
            documentGraphInsertNewLineRequest.level = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].level
        }
        documentGraphInsertNewLineRequest.sentenceIndex = detailViewController!.currentSentenceIndex
        var udcDocumentTypeIdName = ""
        if detailViewController!.isPopup {
            udcDocumentTypeIdName = detailViewController!.popupUdcDocumentTypeIdName
        } else {
            udcDocumentTypeIdName = ApplicationSetting.DocumentType!
        }
        documentGraphInsertNewLineRequest.udcDocumentTypeIdName = udcDocumentTypeIdName
        detailViewController!.setCurrentOperation(name: "DocumentGraphNeuron.Document.Insert.NewLine")
        detailViewController!.setCurrentOperationData(data: [detailViewController!.getCurrentOperation(): [
            "language": ApplicationSetting.DocumentLanguage,
            "documentGraphInsertNewLineRequest": documentGraphInsertNewLineRequest,
            "neuronName": detailViewController!.neuronName]])
        detailViewController!.sendRequest(sourceName: self.detailViewController!.sourceName)
        //        let count = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel.count
        //        // If following return
        //        // 1) middle of line
        //        // 2) no parents and child not allowed
        //        if detailViewController!.currentItemIndex < count - 1 || (detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].parentId.count == 0 && !detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].isChildrenAllowed){
        //            return
        //        }
        //        detailViewController!.currentItemIndex = 0
        //        let searchBoxModel = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel[count - 1]
        //        var path = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].path
        //        detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel.remove(at: count - 1)
        //        path.remove(at: path.count - 1)
        //        path.append(["Document Item Search Box"])
        //
        //        let cursorModel = UVCDocumentGraphModel()
        //        cursorModel.level = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].level
        //        if detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].isChildrenAllowed {
        //            cursorModel.parentId.append(detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex]._id)
        //        } else {
        //            cursorModel.parentId.append(detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].parentId[0])
        //        }
        //        cursorModel.path.append(contentsOf: path)
        //        cursorModel.uvcViewModel.append(searchBoxModel)
        //        detailViewController!.uvcDocumentGraphModelList.insert(cursorModel, at: detailViewController!.currentNodeIndex + 1)
        //        detailViewController!.currentNodeIndex += 1
        //        detailViewController!.collectionView.reloadData()
    }
    
    func focusTextField(uiTextField: UITextField) {
        uiTextField.perform(#selector(uiTextField.becomeFirstResponder), with: nil, afterDelay: 0.1)
//        uiTextField.selectAll(nil)
    }
    
    @objc func objectControllerButtonPressed(_ sender: UIBarButtonItem) {
        if (sender.title == nil) || sender.title!.isEmpty {
            if sender.image == UIImage(named: "Elipsis") {
                optionAction(sender: sender)
                return
            } else if sender.image == UIImage(named: "UpDirectionArrow") {
                handleArrowKeys(name: "UpDirectionArrow")
                //                detailViewController!.uvcObjectControllerEvent.uvcObjectControllerButtonIdName = "UVCObjectcontroller.UpDirectionArrow"
                //                insertItem(section: detailViewController!.currentNodeIndex, index: detailViewController!.currentItemIndex, level: detailViewController!.currentLevel, searchText: "ObjectController", itemData: "", uvOptionViewModel: UVCOptionViewModel(), documentGraphInsertItemRequestParam: nil, parentIndex: 0)
                return
            } else if sender.image == UIImage(named: "DownDirectionArrow") {
                handleArrowKeys(name: "DownDirectionArrow")
                //                detailViewController!.uvcObjectControllerEvent.uvcObjectControllerButtonIdName = "UVCObjectcontroller.LeftDirectionArrow"
                //                insertItem(section: detailViewController!.currentNodeIndex, index: detailViewController!.currentItemIndex, level: detailViewController!.currentLevel, searchText: "ObjectController", itemData: "", uvOptionViewModel: UVCOptionViewModel(), documentGraphInsertItemRequestParam: nil, parentIndex: 0)
                return
            } else if sender.image == UIImage(named: "LeftDirectionArrow") {
                handleArrowKeys(name: "LeftDirectionArrow")
                //                detailViewController!.uvcObjectControllerEvent.uvcObjectControllerButtonIdName = "UVCObjectcontroller.LeftDirectionArrow"
                //                insertItem(section: detailViewController!.currentNodeIndex, index: detailViewController!.currentItemIndex, level: detailViewController!.currentLevel, searchText: "ObjectController", itemData: "", uvOptionViewModel: UVCOptionViewModel(), documentGraphInsertItemRequestParam: nil, parentIndex: 0)
                return
            } else if sender.image == UIImage(named: "RightDirectionArrow") {
                handleArrowKeys(name: "RightDirectionArrow")
                //                detailViewController!.uvcObjectControllerEvent.uvcObjectControllerButtonIdName = "UVCObjectcontroller.RightDirectionArrow"
                //                insertItem(section: detailViewController!.currentNodeIndex, index: detailViewController!.currentItemIndex, level: detailViewController!.currentLevel, searchText: "ObjectController", itemData: "", uvOptionViewModel: UVCOptionViewModel(), documentGraphInsertItemRequestParam: nil, parentIndex: 0)
                return
            } else if sender.image == UIImage(named: "Search") {
                let searchText = detailViewController!.searchText.trimmingCharacters(in: .whitespaces)
                let newSender = (detailViewController!.collectionView.cellForItem(at: NSIndexPath(item: detailViewController!.currentItemIndex, section: detailViewController!.currentNodeIndex) as IndexPath) as! DetailViewCell).getViewController().uvcUIViewControllerItemCollection.getTextField()?.uiTextField
                print(newSender?.text)
                searchAndinsertItem(section: detailViewController!.currentNodeIndex, index: detailViewController!.currentItemIndex, level: detailViewController!.currentLevel, sender: newSender)
                return
            } else if sender.image == UIImage(named: "Information") {
                getDocumentView(editMode: detailViewController!.isEditableMode, objectType: ApplicationSetting.DocumentType!, isToGetDuplicate: false, isToCheckIfFound: false, language: nil, isToLaunchDetailedView: true, isToLaunchConfigurationView: false, isDocumentMapView: false, isFormatView: false)
                return
            } else if sender.image == UIImage(named: "Configuration") {
                getDocumentView(editMode: detailViewController!.isEditableMode, objectType: ApplicationSetting.DocumentType!, isToGetDuplicate: false, isToCheckIfFound: false, language: nil, isToLaunchDetailedView: false, isToLaunchConfigurationView: true, isDocumentMapView: false, isFormatView: false)
                return
            } else if sender.image == UIImage(named: "DocumentMap") {
                getDocumentView(editMode: detailViewController!.isEditableMode, objectType: ApplicationSetting.DocumentType!, isToGetDuplicate: false, isToCheckIfFound: false, language: nil, isToLaunchDetailedView: false, isToLaunchConfigurationView: false, isDocumentMapView: true, isFormatView: false)
                return
            }
        } else {
            if sender.title == detailViewController!.optionLabel["UDCOptionMapNode.Delete"] {
                deleteItem()
            } else if sender.title == detailViewController!.optionLabel["UDCOptionMapNode.View"] {
                viewAction(sender: sender)
                return
            } else if sender.title == detailViewController!.optionLabel["UDCOptionMapNode.Format"] {
                let key = "UDCOptionMap.\(detailViewController!.uvcViewItemType.split(separator: ".")[1])Configuration"
                if detailViewController!.viewTypeConfigurationDictionary[key] == nil {
                    return
                }
                detailViewController!.showPopover(category: detailViewController!.optionTitle[key]!, uvcOptionViewModel: detailViewController!.viewTypeConfigurationDictionary[key]!, width: 400, height: 350, sender: sender, delegate: detailViewController! as UIPopoverPresentationControllerDelegate, optionDelegate: self, goToOption: "", isDismissedAutomatically: false, optionViewControllerName: key, rightButton: ["", "", ""], idName: "", operationName: nil, documentGraphItemSearchRequest: nil, documentGraphItemReferenceRequest: nil, typeRequest: nil, documentGraphItemViewData: nil, documentMapSearchDocumentRequest: nil)
                return
            } else if sender.title == detailViewController!.optionLabel["UDCOptionMapNode.Done"] {
                detailViewController!.objectEditMode = false
                detailViewController!.collectionView.reloadData()
            } else if sender.title == detailViewController!.optionLabel["UDCOptionMapNode.Edit"] {
                detailViewController!.objectEditMode = true
                detailViewController!.collectionView.reloadData()
            }
        }
        
    }
    
    private func handleArrowKeys(name: String) {
        if name == "LeftDirectionArrow" {
            if detailViewController!.currentItemIndex == 1 {
                print("cursorIndex: \(detailViewController!.currentItemIndex)")
                print("cursorSection: \(detailViewController!.currentNodeIndex)")
                
                return
            }
            let searchBoxModel = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel[detailViewController!.currentItemIndex]
            detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel.remove(at: detailViewController!.currentItemIndex)
            detailViewController!.currentItemIndex -= 1
            detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel.insert(searchBoxModel, at: detailViewController!.currentItemIndex)
            detailViewController!.collectionView.reloadData()
            print("cursorIndex: \(detailViewController!.currentItemIndex)")
            print("cursorSection: \(detailViewController!.currentNodeIndex)")
            return
        } else if name == "UpDirectionArrow" {
            if detailViewController!.currentNodeIndex == 0 {
                print("itemIndex: \(detailViewController!.currentItemIndex)")
                print("nodeIndex: \(detailViewController!.currentNodeIndex)")
                
                return
            }
            let searchBoxModel = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel[detailViewController!.currentItemIndex]
            detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel.remove(at: detailViewController!.currentItemIndex)
            detailViewController!.currentNodeIndex -= 1
            if detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel.count - 1 == 0 {
                detailViewController!.currentItemIndex = 1
            } else if detailViewController!.currentItemIndex > detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel.count - 1  {
                detailViewController!.currentItemIndex = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel.count
            }
            detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel.insert(searchBoxModel, at: detailViewController!.currentItemIndex)
            detailViewController!.collectionView.reloadData()
            print("itemIndex: \(detailViewController!.currentItemIndex)")
            print("nodeIndex: \(detailViewController!.currentNodeIndex)")
            
            return
        } else if name == "DownDirectionArrow" {
            if detailViewController!.currentNodeIndex == detailViewController!.uvcDocumentGraphModelList.count - 1 {
                print("itemIndex: \(detailViewController!.currentItemIndex)")
                print("nodeIndex: \(detailViewController!.currentNodeIndex)")
                
                return
            }
            let searchBoxModel = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel[detailViewController!.currentItemIndex]
            detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel.remove(at: detailViewController!.currentItemIndex)
            detailViewController!.currentNodeIndex += 1
            if detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel.count - 1 == 0 {
                detailViewController!.currentItemIndex = 1
            } else if detailViewController!.currentItemIndex > detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel.count - 1  {
                detailViewController!.currentItemIndex = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel.count
            }
            detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel.insert(searchBoxModel, at: detailViewController!.currentItemIndex)
            detailViewController!.collectionView.reloadData()
            print("itemIndex: \(detailViewController!.currentItemIndex)")
            print("nodeIndex: \(detailViewController!.currentNodeIndex)")
            
            return
        } else if name == "RightDirectionArrow" {
            if detailViewController!.currentItemIndex == detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel.count - 1 {
                print("itemIndex: \(detailViewController!.currentItemIndex)")
                print("nodeIndex: \(detailViewController!.currentNodeIndex)")
                
                return
            }
            let searchBoxModel = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel[detailViewController!.currentItemIndex]
            detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel.remove(at: detailViewController!.currentItemIndex)
            detailViewController!.currentItemIndex += 1
            detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel.insert(searchBoxModel, at: detailViewController!.currentItemIndex)
            detailViewController!.collectionView.reloadData()
            print("itemIndex: \(detailViewController!.currentItemIndex)")
            print("nodeIndex: \(detailViewController!.currentNodeIndex)")
            
            return
        } else if name == "HomeDirectionArrow" {
            if detailViewController!.currentItemIndex == 0 {
                print("itemIndex: \(detailViewController!.currentItemIndex)")
                print("nodeIndex: \(detailViewController!.currentNodeIndex)")
                
                return
            }
            let searchBoxModel = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel[detailViewController!.currentItemIndex]
            detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel.remove(at: detailViewController!.currentItemIndex)
            detailViewController!.currentItemIndex = 1
            detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel.insert(searchBoxModel, at: detailViewController!.currentItemIndex)
            detailViewController!.collectionView.reloadData()
            print("itemIndex: \(detailViewController!.currentItemIndex)")
            print("nodeIndex: \(detailViewController!.currentNodeIndex)")
            return
        } else if name == "EndDirectionArrow" {
            if detailViewController!.currentItemIndex == detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel.count {
                print("itemIndex: \(detailViewController!.currentItemIndex)")
                print("nodeIndex: \(detailViewController!.currentNodeIndex)")
                
                return
            }
            let searchBoxModel = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel[detailViewController!.currentItemIndex]
            detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel.remove(at: detailViewController!.currentItemIndex)
            detailViewController!.currentItemIndex = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel.count
            detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel.insert(searchBoxModel, at: detailViewController!.currentItemIndex)
            detailViewController!.collectionView.reloadData()
            print("itemIndex: \(detailViewController!.currentItemIndex)")
            print("nodeIndex: \(detailViewController!.currentItemIndex)")
            
            return
        } else if name == "PageHomeDirectionArrow" {
            if detailViewController!.currentItemIndex == 0 && detailViewController!.currentNodeIndex == 0 {
                print("itemIndex: \(detailViewController!.currentItemIndex)")
                print("nodeIndex: \(detailViewController!.currentNodeIndex)")
                
                return
            }
            let searchBoxModel = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel[detailViewController!.currentItemIndex]
            detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel.remove(at: detailViewController!.currentItemIndex)
            detailViewController!.currentItemIndex = 1
            detailViewController!.currentNodeIndex = 0
            detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel.insert(searchBoxModel, at: detailViewController!.currentItemIndex)
            detailViewController!.collectionView.reloadData()
            print("itemIndex: \(detailViewController!.currentItemIndex)")
            print("nodeIndex: \(detailViewController!.currentNodeIndex)")
            detailViewController!.collectionView.scrollToItem(at: IndexPath(item: detailViewController!.currentItemIndex,
            section: detailViewController!.currentNodeIndex), at: .bottom, animated: true)
            return
        } else if name == "PageEndDirectionArrow" {
            if detailViewController!.currentItemIndex == detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel.count && detailViewController!.currentNodeIndex ==  detailViewController!.uvcDocumentGraphModelList.count {
                print("itemIndex: \(detailViewController!.currentItemIndex)")
                print("nodeIndex: \(detailViewController!.currentNodeIndex)")
                
                return
            }
            let searchBoxModel = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel[detailViewController!.currentItemIndex]
            detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel.remove(at: detailViewController!.currentItemIndex)
            detailViewController!.currentNodeIndex = detailViewController!.uvcDocumentGraphModelList.count - 1
            detailViewController!.currentItemIndex = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel.count
            detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel.insert(searchBoxModel, at: detailViewController!.currentItemIndex)
            detailViewController!.collectionView.reloadData()
            print("itemIndex: \(detailViewController!.currentItemIndex)")
            print("nodeIndex: \(detailViewController!.currentItemIndex)")
            detailViewController!.collectionView.scrollToItem(at: IndexPath(item: detailViewController!.currentItemIndex,
            section: detailViewController!.currentNodeIndex), at: .bottom, animated: true)
            return
        }
    }
    
    public func uvcDetalViewCellOptionSelected(uvcViewController: UVCViewController, udcViewItem: String, section: Int, index: Int, subIndex: Int, level: Int, senderModel: Any, sender: Any, senderText: Any) {
        if isActivityInProgress {
            return
        }
        
        
        //        if ApplicationSetting.CursorMode! == "true" {
        var name = ""
        if !(sender is UVCUIButton) {
            if sender is UVCUITextField {
                let uvuiTextField = sender as! UVCUITextField
                name = uvuiTextField.name
            } else {
                let uvcuiLabel = sender as! UVCText
                name = uvcuiLabel.name
            }
        } else {
            let uvcuiButton = sender as! UVCUIButton
            name = uvcuiButton.name
        }
        
        detailViewController!.focusRequiredAferReload = true
        //        detailViewController!.currentItemIndex = index
        //        detailViewController!.currentNodeIndex = sectiond
        // Move cursor wherever the user selects
        if (sender is UVCUIButton) {
            let uvcuiButton = sender as! UVCUIButton
            
            if uvcuiButton.name == "CursorUDCDocumentItemMapNode.SearchDocumentItems" ||
                uvcuiButton.name == "OptionsButtonUDCDocumentItemMapNode.SearchDocumentItems" {
                if uvcuiButton.name == "CursorUDCDocumentItemMapNode.SearchDocumentItems" {
                    if ApplicationSetting.CursorMode == "false" {
                        ApplicationSetting.CursorMode = "true"
                    } else {
                        ApplicationSetting.CursorMode = "false"
                    }
                    
                    //                    handleCursor(uvcViewController: uvcViewController, uvcUIButton: uvcuiButton)
                    //                    return
                }
                //                return
            }
        }
        
        let count = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel.count
        
        // Including search box
        //        var searchBoxRequired = true
        //        if detailViewController!.uvcDocumentGraphModelList[section].isChildrenAllowed == false && index <= detailViewController!.uvcDocumentGraphModelList[section].uvcViewModel.count - 2 {
        //            for uvcText in detailViewController!.uvcDocumentGraphModelList[section].uvcViewModel[index].uvcViewItemCollection.uvcText {
        //                if uvcText.isEditable == false {
        //                    searchBoxRequired = false
        //                    break
        //                }
        //            }
        //        }
        
        // If not in same position
        //        if !(((index ==  count - 1 && detailViewController!.currentItemIndex == count - 1) ||
        //            (index == 0 && detailViewController!.currentItemIndex == 0)) && (section == detailViewController!.currentNodeIndex) || (index > count - 1)) {
        if ((detailViewController!.currentItemIndex - 1 != index && detailViewController!.currentItemIndex >= 0 && section == detailViewController!.currentNodeIndex) ||
            section != detailViewController!.currentNodeIndex) && !name.hasSuffix("UDCDocumentItemMapNode.SearchDocumentItems") /*&&
             searchBoxRequired*/ {
                
                let searchBoxModel = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel[detailViewController!.currentItemIndex]
                
                detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel.remove(at: detailViewController!.currentItemIndex)
                // If cursor is before the user selected position so no plus 1 and also same section
                if detailViewController!.currentItemIndex < index && detailViewController!.currentNodeIndex == section {
                    detailViewController!.currentItemIndex = index
                } else {
                    detailViewController!.currentItemIndex = index + 1
                }
                let prevSection = detailViewController!.currentNodeIndex
                detailViewController!.currentNodeIndex = section
                // At the last so append and also same section
                if detailViewController!.currentItemIndex > count - 1 && prevSection == detailViewController!.currentNodeIndex { detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel.append(searchBoxModel)
                } else {
                    detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel.insert(searchBoxModel, at: detailViewController!.currentItemIndex)
                }
                // Handle empty lines where cursor is not found and delete them, since user cannot navigate there
                //            var indxesToRemove = [Int]()
                //            for (uvcdmlIndex, uvcdml) in detailViewController!.uvcDocumentGraphModelList.enumerated() {
                //                if uvcdml.uvcViewModel.count == 0 && detailViewController!.currentNodeIndex != uvcdmlIndex {
                //                    indxesToRemove.append(uvcdmlIndex)
                //                }
                //            }
                //            for i in indxesToRemove {
                //                if detailViewController!.currentNodeIndex > i {
                //                    detailViewController!.currentNodeIndex = detailViewController!.currentNodeIndex - 1
                //                }
                //                detailViewController!.uvcDocumentGraphModelList.remove(at: i)
                //            }
                detailViewController!.collectionView.reloadData()
                
                print("section: \(detailViewController!.currentNodeIndex)")
                print("index: \(detailViewController!.currentItemIndex)")
                return
        }
        
        //        }
        
        if !(sender is UVCUIButton) {
            if sender is UVCUITextField {
                let uvuiTextField = sender as! UVCUITextField
                focusTextField(uiTextField: uvuiTextField.uiTextField)
            }
            return
        }
        
        let uvcuiButton = sender as! UVCUIButton
        
        //        if uvcuiButton.name == "CursorUDCDocumentItemMapNode.SearchDocumentItems" {
        //            if ApplicationSetting.CursorMode == "false" {
        //                ApplicationSetting.CursorMode = "true"
        //            } else {
        //                ApplicationSetting.CursorMode = "false"
        //            }
        //
        //            handleCursor(uvcViewController: uvcViewController, uvcUIButton: uvcuiButton)
        //            return
        //        }
        let uiButton = uvcuiButton.uiButton
        
        
        if uvcuiButton.name == "OptionsButtonUDCDocumentItemMapNode.SearchDocumentItems" {
            print("Search option selected")
            detailViewController!.showPopover(category: detailViewController!.optionTitle["UDCOptionMap.DocumentItemOptions"]!, uvcOptionViewModel: detailViewController!.documentItemOptionViewModelList, width: 350, height: 350, sender: uiButton, delegate: detailViewController! as UIPopoverPresentationControllerDelegate, optionDelegate: self, goToOption: "", isDismissedAutomatically: false, optionViewControllerName: "UDCOptionMap.DocumentItemOptions", rightButton: ["", "", ""], idName: "", operationName: "UDCOptionMap.DocumentItemOptions", documentGraphItemSearchRequest: nil, documentGraphItemReferenceRequest: nil, typeRequest: nil, documentGraphItemViewData: nil, documentMapSearchDocumentRequest: nil)
            
            return
        }
        
        if uvcuiButton.name.hasPrefix("NextItemButton") {
            newLine()
            return
        }
        
        if uvcuiButton.name.hasPrefix("Backspace") {
            deleteItem()
            return
        }
        
        if uvcuiButton.name.hasPrefix("Cursor") {
            
            
            return
        }
        if uvcuiButton.name.hasPrefix("ObjectController") {
            return
        }
        
        
        //        showDocumentItemOption(uvcViewController: uvcViewController, index: index, subIndex: subIndex, section: section, sender: sender)
        
        
        
        
        //        var itemIndexLocal = 0
        //        if detailViewController!.currentItemIndex == index + 1 && detailViewController!.currentNodeIndex == section {
        //            itemIndexLocal = detailViewController!.currentItemIndex - 1
        //        } else {
        //            itemIndexLocal = detailViewController!.currentItemIndex + 1
        //        }
        //        let detailViewCell = detailViewController!.collectionView.cellForItem(at: NSIndexPath(item: detailViewController!.currentItemIndex - 1, section: detailViewController!.currentNodeIndex) as IndexPath) as! DetailViewCell
        
        
        //        if senderModel is UVCOptionViewModel {
        //            let uvcovm = senderModel as! UVCOptionViewModel
        //        }
        //        else {
        //            grammarFormMode = false
        //            let uvcdm = senderModel as! UVCDocumentGraphModel
        //            let path = uvcdm.path.joined(separator: "->")
        //            let height = 600 //50 * detailViewController!.uvcOptionViewModelList.count
        //            detailViewController!.documentOptionsButton = (sender as! UVCUIButton).uiButton
        //            detailViewController!.showPopover(category: path, uvcOptionViewModel: detailViewController!.uvcOptionViewModelList, width: 600, height: height, sender: uiButton, delegate: detailViewController! as UIPopoverPresentationControllerDelegate, optionDelegate: self, goToOption: "", isDismissedAutomatically: false, optionViewControllerName: "Build", rightButton: [detailViewController!.optionLabel["UDCOptionMapNode.Done"]!, "", ""])
        //        }
    }
    
    public func optionViewControllerButtonBarItemSelected(path: [String], buttonIndex: Int, senderModel: [Any], sender: Any) {
        let uiButtonBarItem = sender as! UIBarButtonItem
        if buttonIndex == 1 && uiButtonBarItem.title == "Retry" {
            detailViewController!.sendRequest(sourceName: self.detailViewController!.sourceName)
            return
        } else if buttonIndex == 1 && uiButtonBarItem.title == detailViewController!.optionLabel["UDCOptionMapNode.NotInList"] {
            insertItem(section: detailViewController!.currentNodeIndex, index: detailViewController!.currentItemIndex, level: detailViewController!.currentLevel, searchText: detailViewController!.searchText, itemData: "", uvOptionViewModel: UVCOptionViewModel(), documentGraphInsertItemRequestParam: nil, parentIndex: 0)
            return
        }
    }
    
    
    public func cancelSelected() {
        //        resetValues()
    }
    
    private func resetValues() {
        detailViewController!.uvcDocumentGraphModelList.removeAll()
        detailViewController!.uvcDocumentGraphModel.removeAll()
        detailViewController!.currentItemIndex = 0
        detailViewController!.currentNodeIndex = 0
        detailViewController!.currentLevel = 0
        detailViewController!.currentSentenceIndex = 0
        detailViewController!.setDocumentTitle(title: "")
    }
    
    private func removeSentences() {
        let uvcOptionViewRequest = UVCOptionViewRequest()
        uvcOptionViewRequest.operationName = "OptionViewController.Children.DeleteAll"
        uvcOptionViewRequest.path.append(contentsOf: ["Recipe Sentences"])
        //        detailViewController!.optionViewController!.request = uvcOptionViewRequest
    }
    
    private func enableBackButton() {
        let uvcOptionViewRequest = UVCOptionViewRequest()
        uvcOptionViewRequest.operationName = "OptionViewController.EnableBackButon"
        uvcOptionViewRequest.path.append(contentsOf: ["Build", "Grammar"])
        //        detailViewController!.optionViewController!.request = uvcOptionViewRequest
    }
    
    private func disableBackButton() {
        let uvcOptionViewRequest = UVCOptionViewRequest()
        uvcOptionViewRequest.operationName = "OptionViewController.DisableBackButon"
        uvcOptionViewRequest.path.append(contentsOf: ["Build", "Grammar"])
        //        detailViewController!.optionViewController!.request = uvcOptionViewRequest
    }
    private func resetSearch() {
        let uvcOptionViewRequest = UVCOptionViewRequest()
        uvcOptionViewRequest.operationName = "OptionViewController.Search.Reset"
        uvcOptionViewRequest.path.append(contentsOf: ["", ""])
        uvcOptionViewRequest.rightButton = [detailViewController!.optionLabel["UDCOptionMapNode.Done"]!, "", ""]
        //        detailViewController!.optionViewController!.request = uvcOptionViewRequest
    }
    
    
    
    func buttonBarItemSelected(buttonIndex: Int, sender: Any) {
        
    }
    
    public func uvcOptionViewCellEditOk(index: Int, level: Int, senderModel: Any, sender: Any) {
        
    }
    
    
    
    
    public func optionViewControllerSelected(index: Int, parentIndex: Int, level: Int, senderModel: [Any]) {
        if senderModel.count == 0 {
            return
        }
        
        //        detailViewController!.optionViewController!.dismiss(animated: true, completion: nil)
        
        let uvcOptionViewModel = senderModel as! [UVCOptionViewModel]
        print(uvcOptionViewModel[0].getText(name: "Name")!.value)
        detailViewController!.documetSentenceSearchBox?.text = uvcOptionViewModel[0].getText(name: "Name")!.value
        detailViewController!.documetSentenceSearchBox?.becomeFirstResponder()
        
    }
    
    public func uvcDetalViewCellTextFieldDidBeginEditing(section: Int, index: Int, level: Int, senderModel: Any, sender: Any)
    {
        
        
    }
    
    public func uvcDetalViewCellTextFieldUpdated(uvuiTextField: UVCUITextField, section: Int, index: Int, level: Int, senderModel: Any) {
        if detailViewController!.photoIdArray.count > 1 || detailViewController!.photoIdArray.count > 0 {
            return
        }
        //        if uvuiTextField.name == "UDCDocumentItemMapNode.SearchDocumentItems" {
        //            if detailViewController!.isSearchBoxVisible {
        //                uvuiTextField.uiTextField.isHidden = false
        //                uvuiTextField.uiTextField.frame.size = CGSize(width: 45, height: 30)
        //            } else {
        //                uvuiTextField.uiTextField.isHidden = true
        //                uvuiTextField.uiTextField.frame.size = CGSize(width: 0, height: 0)
        //            }
        //        }
        if detailViewController!.currentItemIndex - 1 == index && detailViewController!.currentNodeIndex == section && detailViewController!.focusRequiredAferReload {
            detailViewController!.focusRequiredAferReload = false
            if uvuiTextField.uiTextField != nil {
                detailViewController!.loadObjectControllerView(uiTextFiled: uvuiTextField.uiTextField)
                if  detailViewController!.objectEditMode {
                    detailViewController!.enabledObjectControllerButtons(enable: true)
                }
                return
                    uvuiTextField.uiTextField.perform(#selector(uvuiTextField.uiTextField.becomeFirstResponder), with: nil, afterDelay: 0.1)
            }
        } else if detailViewController!.currentItemIndex == index && detailViewController!.currentNodeIndex == section {
            if uvuiTextField.uiTextField != nil {
                detailViewController!.loadObjectControllerView(uiTextFiled: uvuiTextField.uiTextField)
                if  detailViewController!.objectEditMode {
                    detailViewController!.enabledObjectControllerButtons(enable: true)
                }
                uvuiTextField.uiTextField.perform(#selector(uvuiTextField.uiTextField.becomeFirstResponder), with: nil, afterDelay: 0.1)
            }
        }
        
    }
    
    
    private func isPunctuation(text: String) -> Bool {
        for p in UVCDocumentViewController.punctuation {
            if p == text {
                return true
            }
        }
        
        return false
    }
    
    public func uvcDetalViewCellReturnPressed(section: Int, index: Int, level: Int, senderModel: Any, sender: Any) {
        //searchAndinsertItem(section: section, index: index, level: level, senderModel: senderModel, sender: sender)
        let uvcuiTextField = sender as! UVCUITextField
        let uiTextField = uvcuiTextField.uiTextField
        var text = uiTextField.text!
        if text.trimmingCharacters(in: .whitespaces).isEmpty {
            newLine()
            return
        } else {
            searchPressed()
        }
    }
    
    public func optionViewControllerServerResponsded(response: Any) -> UVCOptionViewRequest {
        let uvcOptionViewRequest = UVCOptionViewRequest()
        let neuronRequest = response as! NeuronRequest
        uvcOptionViewRequest.operationName = "OptionViewController.Load.Options"
        
        if neuronRequest.neuronOperation.name == "DocumentItemNeuron.Search.DocumentItem" || neuronRequest.neuronOperation.name == "DocumentGraphNeuron.DocumentItem.Search" {
            let jsonUtility = JsonUtility<DocumentGraphItemSearchResponse>()
            
            let documentGraphItemSearchResponse = jsonUtility.convertJsonToAnyObject(json: neuronRequest.neuronOperation.neuronData.text)
            
            // If no item then insert the search text
            let searchText = detailViewController!.searchText
            
            // More than one item show the list of items
            uvcOptionViewRequest.uvcOptionViewModel = [UVCOptionViewModel]()
            if documentGraphItemSearchResponse.uvcOptionViewModel.count > 0 {
                uvcOptionViewRequest.title = documentGraphItemSearchResponse.uvcOptionViewModel[0].getText(name: "Name")!.value
                for uvcovm in documentGraphItemSearchResponse.uvcOptionViewModel {
                    if uvcovm.level == 1 {
                        uvcOptionViewRequest.uvcOptionViewModel!.append(uvcovm)
                    }
                }
            } else {
                insertItem(section: detailViewController!.currentNodeIndex, index: detailViewController!.currentItemIndex, level: detailViewController!.currentLevel, searchText: searchText, itemData: "", uvOptionViewModel: UVCOptionViewModel(), documentGraphInsertItemRequestParam: nil, parentIndex: 0)
                uvcOptionViewRequest.operationName = "OptionViewController.Dismiss"
                return uvcOptionViewRequest
            }
            return uvcOptionViewRequest
        } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.DocumentItem.Get" || neuronRequest.neuronOperation.name == "DocumentItemNeuron.Get.DocumentItem.Options" {
            let jsonUtility = JsonUtility<GetDocumentItemOptionResponse>()
            if neuronRequest.neuronOperation.neuronData.text.isEmpty {
                uvcOptionViewRequest.operationName = "OptionViewController.Dismiss"
                return uvcOptionViewRequest
            }
            let typeResponse = jsonUtility.convertJsonToAnyObject(json: neuronRequest.neuronOperation.neuronData.text)
            
            uvcOptionViewRequest.uvcOptionViewModel = [UVCOptionViewModel]()
            uvcOptionViewRequest.title = typeResponse.uvcOptionViewModel[0].getText(name: "Name")!.value
            for uvcovm in typeResponse.uvcOptionViewModel {
                if uvcovm.level == 1 {
                    uvcOptionViewRequest.uvcOptionViewModel!.append(uvcovm)
                }
            }
        }
        
        //        else if neuronRequest.neuronOperation.name == "DocumentMapNeuron.Search.Document" {
        //            let jsonUtility = JsonUtility<DocumentMapSearchDocumentResponse>()
        //            let documentMapSearchDocumentResponse = jsonUtility.convertJsonToAnyObject(json: neuronRequest.neuronOperation.neuronData.text)
        //
        //            uvcOptionViewRequest.uvcOptionViewModel = [UVCOptionViewModel]()
        //            for uvcovm in documentMapSearchDocumentResponse.uvcOptionViewModel {
        //                if uvcovm.level == 1 {
        //                    uvcOptionViewRequest.uvcOptionViewModel!.append(uvcovm)
        //                }
        //            }
        //        }
        
        return uvcOptionViewRequest
    }
    
    public func optionViewControllerDismissed() {
        detailViewController!.optionViewNavigationController = nil
        print("Optionview controller set to nil")
    }
    
    public func searchAndinsertItem(section: Int, index: Int, level: Int, sender: Any) {
        let uiTextField = sender as! UITextField
        detailViewController!.searchText = uiTextField.text!.trimmingCharacters(in: .whitespaces)
        if !isPunctuation(text: detailViewController!.searchText) {
            processingSentence = true
            let uvvOptionViewModel = UVCOptionViewModel()
            uvvOptionViewModel._id = NSUUID().uuidString
            let documentGraphItemSearchRequest = DocumentGraphItemSearchRequest()
            documentGraphItemSearchRequest.isByCategory = searchOptionSelection[0]
            documentGraphItemSearchRequest.isBySubCategory = searchOptionSelection[1]
            documentGraphItemSearchRequest.isByName = searchOptionSelection[2]
            documentGraphItemSearchRequest.isIncludeGrammar = searchOptionSelection[3]
            documentGraphItemSearchRequest.isSentencePattern = searchOptionSelection[4]
            // Sending model itself to know the hierarchy the search is coming from
            // and some data based on the selection
            documentGraphItemSearchRequest.optionItemId = uvvOptionViewModel._id
            documentGraphItemSearchRequest.pathIdName.append(contentsOf: uvvOptionViewModel.pathIdName)
            // Always search text in lower case
            documentGraphItemSearchRequest.text = detailViewController!.searchText.lowercased()
            var udcDocumentTypeIdName = ""
            if detailViewController!.isPopup {
                udcDocumentTypeIdName = detailViewController!.popupUdcDocumentTypeIdName
            } else {
                udcDocumentTypeIdName = ApplicationSetting.DocumentType!
            }
            documentGraphItemSearchRequest.udcDocumentTypeIdName = udcDocumentTypeIdName
            documentGraphItemSearchRequest.documentId = detailViewController!.documentId
            CallBrainControllerNeuron.delegateMap.removeValue(forKey: "sender")
            CallBrainControllerNeuron.delegateMap["sender"] = sender as! UITextField
            let typeRequest = GetDocumentItemOptionRequest()
            if detailViewController!.uvcDocumentGraphModelList[section].uvcViewModel[index].uvcViewItemType == "UVCViewItemType.Photo" {
                let uvcPhoto = detailViewController!.uvcDocumentGraphModelList[section].uvcViewModel[index].uvcViewItemCollection.uvcPhoto[0]
                if uvcPhoto.uvcText != nil {
                    typeRequest.text = uvcPhoto.uvcText!.helpText!
                }
                typeRequest.type = uvcPhoto.optionObjectName
                typeRequest.category = uvcPhoto.optionObjectCategoryIdName
                typeRequest.language = ApplicationSetting.DocumentLanguage!
                typeRequest.fromText = ""
                typeRequest.sortedBy = "name"
                typeRequest.limitedTo = 50
                typeRequest.isAll = false
                typeRequest.searchText = ""
                typeRequest.uvcViewItemType = "UVCViewItemType.Photo"
            } else {
                let uvcText = detailViewController!.uvcDocumentGraphModelList[section].uvcViewModel[index].uvcViewItemCollection.uvcText[0]
                typeRequest.text = uvcText.value
                typeRequest.type = uvcText.optionObjectName
                typeRequest.category = uvcText.optionObjectCategoryIdName
                typeRequest.language = ApplicationSetting.DocumentLanguage!
                typeRequest.fromText = ""
                typeRequest.sortedBy = "name"
                typeRequest.limitedTo = 50
                typeRequest.isAll = false
                typeRequest.searchText = ""
                typeRequest.uvcViewItemType = "UVCViewItemType.Text"
            }
            detailViewController!.showPopover(category: "", uvcOptionViewModel: nil, width: 350, height: 300, sender: sender as! UITextField, delegate: detailViewController!, optionDelegate: self, goToOption: "", isDismissedAutomatically: false, optionViewControllerName: "Document Search Items", rightButton: [detailViewController!.optionLabel["UDCOptionMapNode.NotInList"]!, "", ""], idName: "", operationName: "DocumentItemNeuron.Search.DocumentItem", documentGraphItemSearchRequest: documentGraphItemSearchRequest, documentGraphItemReferenceRequest: nil, typeRequest: typeRequest, documentGraphItemViewData: nil, documentMapSearchDocumentRequest: nil)
        } else {
            insertItem(section: section, index: index, level: level, searchText: detailViewController!.searchText, itemData: "", uvOptionViewModel: UVCOptionViewModel(), documentGraphInsertItemRequestParam: nil, parentIndex: 0)
        }
    }
    
    private func insertItem(section: Int, index: Int, level: Int, searchText: String, itemData: String, uvOptionViewModel: UVCOptionViewModel, documentGraphInsertItemRequestParam: DocumentGraphInsertItemRequest?, parentIndex: Int, language: String = "") {
        var processedText = searchText
        processedText = processedText.trimmingCharacters(in: .whitespaces)
        if processedText.isEmpty {
            return
        }
        var udcDocumentTypeIdName = ""
        if detailViewController!.isPopup {
            udcDocumentTypeIdName = detailViewController!.popupUdcDocumentTypeIdName
        } else {
            udcDocumentTypeIdName = ApplicationSetting.DocumentType!
        }
        
        
        let documentGraphInsertItemRequest = DocumentGraphInsertItemRequest()
        if detailViewController!.uvcDocumentGraphModelList.count > 0 {
            if detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].parentId.count > 0 {
                documentGraphInsertItemRequest.parentId = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].parentId[0]
            }
            // If somethings there other than
            documentGraphInsertItemRequest.nodeId = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex]._id
            documentGraphInsertItemRequest.documentId = detailViewController!.documentId
            
            if detailViewController!.currentItemIndex > 0 {
                let uvcm = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel[detailViewController!.currentItemIndex]
                for uvcText in uvcm.uvcViewItemCollection.uvcText {
                    if uvcText.isEditable {
                        documentGraphInsertItemRequest.itemId = uvcText._id
                        break
                    }
                }
            }
            if !isPunctuation(text: searchText) {
                documentGraphInsertItemRequest.optionItemId = uvOptionViewModel.objectIdName
                documentGraphInsertItemRequest.optionItemObjectName = uvOptionViewModel.objectName
                documentGraphInsertItemRequest.optionItemNameIndex = uvOptionViewModel.objectNameIndex
                documentGraphInsertItemRequest.optionDocumentIdName = uvOptionViewModel.objectDocumentIdName
                if uvOptionViewModel.getText(name: "Name") != nil {
                    documentGraphInsertItemRequest.item = uvOptionViewModel.getText(name: "Name")!.value
                }
            }
            documentGraphInsertItemRequest.nodeIndex = detailViewController!.currentNodeIndex
            documentGraphInsertItemRequest.itemIndex = detailViewController!.currentItemIndex
            // Document item value
            documentGraphInsertItemRequest.sentenceIndex = detailViewController!.currentSentenceIndex
            // Document item with prefix, the user need
            documentGraphInsertItemRequest.item = searchText
        }
        if udcDocumentTypeIdName != nil {
            documentGraphInsertItemRequest.udcDocumentTypeIdName = udcDocumentTypeIdName
        } else {
            documentGraphInsertItemRequest.udcDocumentTypeIdName = ApplicationSetting.DocumentType!
        }
        
        documentGraphInsertItemRequest.itemData = itemData
        if documentGraphInsertItemRequestParam != nil {
            documentGraphInsertItemRequest.isOption = documentGraphInsertItemRequestParam!.isOption
            documentGraphInsertItemRequest.item = documentGraphInsertItemRequestParam!.item
            documentGraphInsertItemRequest.udcViewItemCollection.udcPhoto = documentGraphInsertItemRequestParam!.udcViewItemCollection.udcPhoto
        }
        documentGraphInsertItemRequest.level = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].level
        documentGraphInsertItemRequest.isParent = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].isChildrenAllowed || detailViewController!.isParentNode
        documentGraphInsertItemRequest.isDocumentItemEditable = detailViewController!.isDocumentItemEditable
        documentGraphInsertItemRequest.objectControllerRequest = ObjectControllerRequest()
        documentGraphInsertItemRequest.objectControllerRequest.viewConfigPathIdName.append(contentsOf: detailViewController!.viewConfigPathIdName)
        documentGraphInsertItemRequest.objectControllerRequest.uvcViewItemType = detailViewController!.uvcViewItemType
        documentGraphInsertItemRequest.objectControllerRequest.editMode = detailViewController!.objectEditMode
        documentGraphInsertItemRequest.objectControllerRequest.groupUVCViewItemType = detailViewController!.groupUVCViewItemType
        documentGraphInsertItemRequest.objectControllerRequest.udcViewItemName = detailViewController!.udcViewItemName
        documentGraphInsertItemRequest.objectControllerRequest.udcViewItemId = detailViewController!.udcViewItemId
        documentGraphInsertItemRequest.objectControllerRequest.viewPathIdName.append(contentsOf: detailViewController!.viewPathIdName)
        detailViewController!.setCurrentOperation(name: "DocumentGraphNeuron.Document.Item.Insert")
        detailViewController!.setCurrentOperationData(data: [detailViewController!.getCurrentOperation(): [
            "documentGraphInsertItemRequest": documentGraphInsertItemRequest,
            "language": language,
            "neuronName": detailViewController!.neuronName]])
        
        //        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
        //            guard let self = self else {
        //                return
        //            }
        self.detailViewController!.sendRequest(sourceName: self.detailViewController!.sourceName)
        //        }
        userProcessingText = false
        processedText = ""
        return
    }
    
    
    public func uvcDetalViewCellTextFieldDidChange(section: Int, index: Int, level: Int, senderModel: Any, sender: Any) {
        //        if isActivityInProgress {
        //            return
        //        }
        //        let uvcuiTextField = sender as! UVCUITextField
        //        let uiTextField = uvcuiTextField.uiTextField
        //        let uvcDocumentGraphModel = senderModel as! UVCDocumentGraphModel
        //        let path = uvcDocumentGraphModel.path[0].joined(separator: "->")
        //        if detailViewController!.uvcDocumentGraphModelList[section].uvcViewModel[index].uvcViewItemCollection.uvcText[0].name == "UDCDocumentItemMapNode.SearchDocumentItems" {
        //            if ApplicationSetting.DocumentLanguage == "en" {
        //                uiTextField.text = uiTextField.text?.lowercased()
        //            }
        //            detailViewController!.documetSentenceSearchBox = uiTextField
        //            detailViewController!.documentItemSearchInProgress = true
        ////            if processingSentence {
        ////                return
        ////            }
        //            var searchText = uiTextField.text!
        //
        //            if searchText.characters.last == " " {
        //                searchAndinsertItem(section: section, index: index, level: level, senderModel: senderModel, uvcText: UVCTextsender: sender)
        //                return
        //            }
        //        } else {
        //            var processedText = uiTextField.text!
        //            processedText = processedText.trimmingCharacters(in: .whitespaces)
        //            if processedText.isEmpty {
        //                return
        //            }
        //            let documentGraphChangeItemRequest = DocumentGraphChangeItemRequest()
        //            if detailViewController!.uvcDocumentGraphModelList[section].parentId.count > 0 {
        //                documentGraphChangeItemRequest.parentId.append(detailViewController!.uvcDocumentGraphModelList[section].parentId[0])
        //            }
        //            documentGraphChangeItemRequest.nodeId = detailViewController!.uvcDocumentGraphModelList[section]._id
        ////            var itemId = ""
        ////            var itemIndex = 0
        ////            var viewModelIndex = 0
        ////            var found = false
        ////            for (index, uvcm) in detailViewController!.uvcDocumentGraphModelList[section].uvcViewModel.enumerated() {
        ////                for uvcText in uvcm.uvcViewItemCollection.uvcText {
        ////                    if uvcText.isEditable && uvcText.uvcEditType == "UVCEditType.None" {
        ////                        found = true
        ////                        itemId = uvcText._id
        ////                        itemIndex = uvcText.wordIndex
        ////                        viewModelIndex = index
        ////                        break
        ////                    }
        ////                }
        ////                if found { break }
        ////            }
        //            documentGraphChangeItemRequest.item = processedText
        //            documentGraphChangeItemRequest.documentId = detailViewController!.documentId
        //            if detailViewController!.currentItemIndex < index  && detailViewController!.currentNodeIndex == section {
        //                documentGraphChangeItemRequest.itemIndex = index - 1
        //            } else {
        //                documentGraphChangeItemRequest.itemIndex = index
        //            }
        //            documentGraphChangeItemRequest.nodeIndex = section
        //            documentGraphChangeItemRequest.sentenceIndex = detailViewController!.currentSentenceIndex
        //            documentGraphChangeItemRequest.udcDocumentTypeIdName = ApplicationSetting.DocumentType!
        //
        //            detailViewController!.setCurrentOperation(name: "DocumentGraphNeuron.Document.Item.Change")
        //            detailViewController!.setCurrentOperationData(data: [detailViewController!.getCurrentOperation(): [
        //                "documentGraphChangeItemRequest": documentGraphChangeItemRequest,
        //                "neuronName": detailViewController!.neuronName]])
        //            detailViewController!.sendRequest(source: self)
        //        }
    }
    func uvcDetalViewCellSelected(index: Int, level: Int, senderModel: Any, sender: Any) {
        
    }
    
    func uvcDetalViewCellEditOk(index: Int, level: Int, senderModel: Any, sender: Any) {
        
    }
    
    func uvcDetalViewCellGetCollectionView() -> UICollectionView {
        return detailViewController!.collectionView
    }
    
    public func optionViewControllerOptionSelected(index: Int, parentIndex: Int, level: Int, senderModel: Any, sender: Any) {
        
    }
    public func optionViewControllerConnfigureOption(index: Int, parentIndex: Int, level: Int, senderModel: [Any], uvcUIViewControllerItemCollection: UVCUIViewControllerItemCollection) {
        let uvcOptionViewModel = senderModel as! [UVCOptionViewModel]
        if uvcOptionViewModel[0].pathIdName[0].joined(separator: "->") == "UDCOptionMapNode.DocumentItemOptions->UDCOptionMapNode.ConfigureSearch->UDCOptionMapNode.ConfigureSearchView" {
            uvcUIViewControllerItemCollection.getOnOff(tag: 0, name: "UDCOptionMapNode.ByCategory.OnOff")?.uiSwitch.setOn(searchOptionSelection[0], animated: false)
            uvcUIViewControllerItemCollection.getOnOff(tag: 0, name: "UDCOptionMapNode.BySubCategory.OnOff")?.uiSwitch.setOn(searchOptionSelection[1], animated: false)
            uvcUIViewControllerItemCollection.getOnOff(tag: 0, name: "UDCOptionMapNode.ByName.OnOff")?.uiSwitch.setOn(searchOptionSelection[2], animated: false)
            uvcUIViewControllerItemCollection.getOnOff(tag: 0, name: "UDCOptionMapNode.IncludeGrammar.OnOff")?.uiSwitch.setOn(searchOptionSelection[3], animated: false)
            uvcUIViewControllerItemCollection.getOnOff(tag: 0, name: "UDCOptionMapNode.SentencePattern.OnOff")?.uiSwitch.setOn(searchOptionSelection[4], animated: false)
        }
    }
    
    public func uvcOptionViewCellConnfigureOption(index: Int, level: Int, senderModel: [Any], uvcUIViewControllerItemCollection: UVCUIViewControllerItemCollection) {
        
    }
    
    private func documentSaveAsTemplate() {
        detailViewController!.setCurrentOperation(name: "DocumentGraphNeuron.SaveAsTemplate")
        let documentSaveAsTemplateRequest = DocumentGraphSaveAsTemplateRequest()
        documentSaveAsTemplateRequest.documentId = detailViewController!.documentId
        documentSaveAsTemplateRequest.name = detailViewController!.documentName
        documentSaveAsTemplateRequest.englishName = detailViewController!.documentEnglishName
        detailViewController!.setCurrentOperationData(data: [detailViewController!.getCurrentOperation(): [
            "language": ApplicationSetting.DocumentLanguage,
            "documentSaveAsTemplateRequest": documentSaveAsTemplateRequest]])
        detailViewController!.sendRequest(sourceName: self.detailViewController!.sourceName)
    }
    
    public func optionViewControllerSelected(index: Int, parentIndex: Int, level: Int, senderModel: [Any], sender: Any) {
        if senderModel.count == 0 {
            return
        }
        let uvcOptionViewModel = senderModel as! [UVCOptionViewModel]
        if uvcOptionViewModel[0].pathIdName[parentIndex].joined(separator: "->").hasPrefix(  "UDCOptionMapNode.DocumentItemOptions->UDCOptionMapNode.Line->UDCOptionMapNode.Delete") {
            deleteLine()
//            detailViewController!.setCurrentOperation(name: "DocumentGraphNeuron.Document.Delete.Line")
//            let documentGraphDeleteLineRequest = DocumentGraphDeleteLineRequest()
//            documentGraphDeleteLineRequest.level = detailViewController!.currentLevel
//            if detailViewController!.currentNodeIndex ==  detailViewController!.uvcDocumentGraphModelList.count - 1 {
//                documentGraphDeleteLineRequest.nearbyNodeId = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex - 1]._id
//            } else {
//                documentGraphDeleteLineRequest.nearbyNodeId = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex + 1]._id
//            }
//            if detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].parentId.count > 0 {
//                documentGraphDeleteLineRequest.parentId = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].parentId[0]
//            }
//            documentGraphDeleteLineRequest.nodeId = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex]._id
//            documentGraphDeleteLineRequest.udcDocumentTypeIdName = ApplicationSetting.DocumentType!
//            documentGraphDeleteLineRequest.documentId = detailViewController!.documentId
//            documentGraphDeleteLineRequest.nodeIndex = detailViewController!.currentNodeIndex
//            detailViewController!.setCurrentOperationData(data: [detailViewController!.getCurrentOperation(): [
//                "language": ApplicationSetting.DocumentLanguage as Any,
//                "documentGraphDeleteLineRequest": documentGraphDeleteLineRequest,
//                "neuronName": detailViewController?.neuronName as Any]])
//            detailViewController!.sendRequest(sourceName: self.detailViewController!.sourceName)
            return
        }
        if uvcOptionViewModel[0].pathIdName[parentIndex].joined(separator: "->").hasPrefix(  "UDCOptionMapNode.DocumentOptions->UDCOptionMapNode.SearchForDocument") {
            return
        }
        if uvcOptionViewModel[0].pathIdName[parentIndex].joined(separator: "->").hasPrefix(  "UDCOptionMapNode.DocumentOptions->UDCOptionMapNode.NewDocument") {
            documentNew()
            return
        }
        if uvcOptionViewModel[0].pathIdName[parentIndex].joined(separator: "->").hasPrefix(  "UDCOptionMapNode.DocumentOptions->UDCOptionMapNode.iPadDocument") {
            
            return
        }
        if uvcOptionViewModel[0].pathIdName[parentIndex].joined(separator: "->").hasPrefix(  "UDCOptionMapNode.DocumentOptions->UDCOptionMapNode.EditDocument") {
            return
        }
        if uvcOptionViewModel[0].pathIdName[parentIndex].joined(separator: "->").hasPrefix(  "UDCOptionMapNode.DocumentOptions->UDCOptionMapNode.DeleteDocument") {
            return
        }
        if uvcOptionViewModel[0].pathIdName[parentIndex].joined(separator: "->").hasPrefix(  "UDCOptionMapNode.DocumentOptions->UDCOptionMapNode.SearchForDocument") {
            return
        }
        if uvcOptionViewModel[0].pathIdName[parentIndex].joined(separator: "->").hasPrefix(  "UDCOptionMapNode.DocumentOptions->UDCOptionMapNode.SaveAsTemplate") {
            return
        }
        
        if uvcOptionViewModel[0].pathIdName[parentIndex].joined(separator: "->").hasPrefix(  "UDCOptionMapNode.DocumentOptions->UDCOptionMapNode.SaveAsTemplate") {
            documentSaveAsTemplate()
            return
        }
        if uvcOptionViewModel[0].pathIdName[parentIndex].joined(separator: "->").hasPrefix(  "UDCOptionMapNode.DocumentItemOptions->UDCOptionMapNode.Reference->UDCDocumentReferenceType.SameDocument->UDCDocumentItemMapNode.Sentence->") {
            detailViewController!.setCurrentOperation(name: "DocumentGraphNeuron.Document.Item.Reference")
            let documentGraphItemReferenceRequest = DocumentGraphItemReferenceRequest()
            documentGraphItemReferenceRequest.documentId = detailViewController!.documentId
            // Graph model information
            documentGraphItemReferenceRequest.sentenceIndex = detailViewController!.currentSentenceIndex
            documentGraphItemReferenceRequest.itemIndex = detailViewController!.currentItemIndex
            documentGraphItemReferenceRequest.nodeIndex = detailViewController!.currentNodeIndex
            documentGraphItemReferenceRequest.level = detailViewController!.currentLevel
            documentGraphItemReferenceRequest.parentId = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].parentId[0]
            documentGraphItemReferenceRequest.nodeId =  detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex]._id
            // Reference information
            documentGraphItemReferenceRequest.referenceNodeId = uvcOptionViewModel[0].objectIdName
            let modelComponents = uvcOptionViewModel[0].model.components(separatedBy: ":")
            documentGraphItemReferenceRequest.referenceNodeIndex = Int(modelComponents[0])!
            //            if documentGraphItemReferenceRequest.nodeIndex == documentGraphItemReferenceRequest.referenceNodeIndex {
            //                return
            //            }
            documentGraphItemReferenceRequest.referenceSentenceIndex = Int(modelComponents[1])!
            documentGraphItemReferenceRequest.pathIdName.append(contentsOf: uvcOptionViewModel[0].pathIdName[parentIndex])
            documentGraphItemReferenceRequest.udcDocumentTypeIdName = ApplicationSetting.DocumentType!
            detailViewController!.setCurrentOperationData(data: [detailViewController!.getCurrentOperation(): [
                "language": ApplicationSetting.DocumentLanguage as Any,
                "documentGraphItemReferenceRequest": documentGraphItemReferenceRequest,
                "neuronName": detailViewController?.neuronName as Any]])
            detailViewController!.sendRequest(sourceName: self.detailViewController!.sourceName)
            return
        }
        if uvcOptionViewModel[0].pathIdName[parentIndex].joined(separator: "->").hasPrefix(  "UDCOptionMapNode.DocumentItemOptions->UDCOptionMapNode.Reference->UDCDocumentReferenceType.SameDocument->UDCDocumentItemMapNode.Word->") {
            detailViewController!.setCurrentOperation(name: "DocumentGraphNeuron.Document.Item.Reference")
            let documentGraphItemReferenceRequest = DocumentGraphItemReferenceRequest()
            documentGraphItemReferenceRequest.documentId = detailViewController!.documentId
            let modelComponents = uvcOptionViewModel[0].model.components(separatedBy: ":")
            documentGraphItemReferenceRequest.referenceNodeId = uvcOptionViewModel[0].objectIdName
            documentGraphItemReferenceRequest.referenceNodeIndex = Int(modelComponents[0])!
            documentGraphItemReferenceRequest.referenceSentenceIndex = Int(modelComponents[1])!
            documentGraphItemReferenceRequest.referenceItemIndex = Int(modelComponents[2])!
            documentGraphItemReferenceRequest.itemIndex = detailViewController!.currentItemIndex
            documentGraphItemReferenceRequest.nodeIndex = detailViewController!.currentNodeIndex
            //            if documentGraphItemReferenceRequest.nodeIndex == documentGraphItemReferenceRequest.referenceNodeIndex {
            //                return
            //            }
            documentGraphItemReferenceRequest.parentId = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].parentId[0]
            documentGraphItemReferenceRequest.nodeId =  detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex]._id
            documentGraphItemReferenceRequest.level = detailViewController!.currentLevel
            documentGraphItemReferenceRequest.pathIdName.append(contentsOf: uvcOptionViewModel[0].pathIdName[parentIndex])
            documentGraphItemReferenceRequest.udcDocumentTypeIdName = ApplicationSetting.DocumentType!
            documentGraphItemReferenceRequest.item = uvcOptionViewModel[0].getText(name: "Name")!.value
            detailViewController!.setCurrentOperationData(data: [detailViewController!.getCurrentOperation(): [
                "language": ApplicationSetting.DocumentLanguage as Any,
                "documentGraphItemReferenceRequest": documentGraphItemReferenceRequest,
                "neuronName": detailViewController?.neuronName as Any]])
            detailViewController!.sendRequest(sourceName: self.detailViewController!.sourceName)
            return
        }
        if uvcOptionViewModel[0].pathIdName[parentIndex].joined(separator: "->").hasPrefix(  "UDCOptionMapNode.DocumentItemOptions->UDCOptionMapNode.Reference->UDCDocumentReferenceType.SameDocument->UDCDocumentItemMapNode.Sentence") {
            detailViewController!.setCurrentOperation(name: "DocumentGraphNeuron.Document.Item.Reference")
            let documentGraphItemReferenceRequest = DocumentGraphItemReferenceRequest()
            documentGraphItemReferenceRequest.documentId = detailViewController!.documentId
            documentGraphItemReferenceRequest.parentId = uvcOptionViewModel[0].parentId[0]
            documentGraphItemReferenceRequest.optionId = uvcOptionViewModel[0].objectIdName
            documentGraphItemReferenceRequest.optionObjectName = uvcOptionViewModel[0].objectName
            documentGraphItemReferenceRequest.pathIdName.append(contentsOf: uvcOptionViewModel[0].pathIdName[parentIndex])
            documentGraphItemReferenceRequest.udcDocumentTypeIdName = ApplicationSetting.DocumentType!
            detailViewController!.setCurrentOperationData(data: [detailViewController!.getCurrentOperation(): [
                "language": ApplicationSetting.DocumentLanguage as Any,
                "documentGraphItemReferenceRequest": documentGraphItemReferenceRequest,
                "neuronName": detailViewController?.neuronName as Any]])
            detailViewController!.sendRequest(sourceName: self.detailViewController!.sourceName)
            return
        }
        if uvcOptionViewModel[0].pathIdName[parentIndex].joined(separator: "->").hasPrefix(  "UDCOptionMapNode.DocumentItemOptions->UDCOptionMapNode.Reference->UDCDocumentReferenceType.SameDocument") {
            detailViewController!.setCurrentOperation(name: "DocumentGraphNeuron.Document.Item.Reference")
            let documentGraphItemReferenceRequest = DocumentGraphItemReferenceRequest()
            documentGraphItemReferenceRequest.documentId = detailViewController!.documentId
            documentGraphItemReferenceRequest.parentId = uvcOptionViewModel[0].parentId[0]
            documentGraphItemReferenceRequest.optionId = uvcOptionViewModel[0].objectIdName
            documentGraphItemReferenceRequest.optionObjectName = uvcOptionViewModel[0].objectName
            documentGraphItemReferenceRequest.pathIdName.append(contentsOf: uvcOptionViewModel[0].pathIdName[parentIndex])
            documentGraphItemReferenceRequest.udcDocumentTypeIdName = ApplicationSetting.DocumentType!
            detailViewController!.setCurrentOperationData(data: [detailViewController!.getCurrentOperation(): [
                "language": ApplicationSetting.DocumentLanguage as Any,
                "documentGraphItemReferenceRequest": documentGraphItemReferenceRequest,
                "neuronName": detailViewController?.neuronName as Any]])
            detailViewController!.sendRequest(sourceName: self.detailViewController!.sourceName)
            return
        }
        if uvcOptionViewModel[0].pathIdName[parentIndex].joined(separator: "->").hasPrefix(  "UDCOptionMapNode.DocumentItemSearchOptions->UDCOptionMapNode.DeleteRow") {
            let searchBoxModel = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel[detailViewController!.currentItemIndex]
            detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel.removeAll()
            detailViewController!.currentItemIndex = 0
            detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel.insert(searchBoxModel, at: detailViewController!.currentItemIndex)
            detailViewController!.collectionView.reloadData()
            print("itemIndex: \(detailViewController!.currentItemIndex)")
            print("nodeIndex: \(detailViewController!.currentNodeIndex)")
            return
        }
        if uvcOptionViewModel[0].pathIdName[parentIndex].joined(separator: "->").hasPrefix(  "UDCOptionMapNode.DocumentOptions->UDCOptionMapNode.DocumentLanguage->") {
            let jsonUtility = JsonUtility<UDCHumanLanguageType>()
            let udcHumanLanguageType = jsonUtility.convertJsonToAnyObject(json: uvcOptionViewModel[0].model)
            ApplicationSetting.DocumentLanguage = udcHumanLanguageType.code6391
            return
        }
        if uvcOptionViewModel[0].pathIdName[parentIndex].joined(separator: "->").hasPrefix(  "UDCOptionMapNode.DocumentOptions->UDCOptionMapNode.DocumentType->") {
            ApplicationSetting.DocumentType = uvcOptionViewModel[0].idName
            refreshDocumentMap()
            return
        }
        if uvcOptionViewModel[0].pathIdName[parentIndex].joined(separator: "->").hasPrefix( "UDCOptionMapNode.ViewOptions->") {
            if uvcOptionViewModel[0].isSelected {
                detailViewController!.viewConfigPathIdName.append(contentsOf: uvcOptionViewModel[0].pathIdName[parentIndex])
                detailViewController!.uvcViewItemType = uvcOptionViewModel[0].pathIdName[parentIndex][uvcOptionViewModel[0].pathIdName[parentIndex].count - 1]
                detailViewController!.groupUVCViewItemType = detailViewController!.uvcViewItemType
                detailViewController!.objectEditMode = true
                
            }
            return
        }
        if uvcOptionViewModel[0].pathIdName[parentIndex].joined(separator: "->") == "UDCOptionMapNode.DocumentItemOptions->UDCOptionMapNode.ConfigureSearch->UDCOptionMapNode.ConfigureSearchView"  {
            if sender is UVCUIOnOff {
                let uvcuiChoice = sender as! UVCUIOnOff
                if uvcuiChoice.name == "UDCOptionMapNode.ByCategory.OnOff" {
                    searchOptionSelection[0] = uvcuiChoice.uiSwitch.isOn
                } else if uvcuiChoice.name == "UDCOptionMapNode.BySubCategory.OnOff" {
                    searchOptionSelection[1] = uvcuiChoice.uiSwitch.isOn
                } else if uvcuiChoice.name == "UDCOptionMapNode.ByName.OnOff" {
                    searchOptionSelection[2] = uvcuiChoice.uiSwitch.isOn
                } else if uvcuiChoice.name == "UDCOptionMapNode.IncludeGrammar.OnOff" {
                    searchOptionSelection[3] = uvcuiChoice.uiSwitch.isOn
                } else if uvcuiChoice.name == "UDCOptionMapNode.SentencePattern.OnOff" {
                    searchOptionSelection[4] = uvcuiChoice.uiSwitch.isOn
                }
            }
            return
        } else if uvcOptionViewModel[0].pathIdName[parentIndex].joined(separator: "->") == "UDCOptionMapNode.DocumentItemSearchOptions->UDCOptionMapNode.Sentence->UDCOptionMapNode.AddToDictionary" {
//            detailViewController!.setCurrentOperation(name: "DocumentGraphNeuron.User.SentencePattern.Add")
//            let userSentencePatternAddRequest = UserSentencePatternAddRequest()
//            for uvcdml in detailViewController!.uvcDocumentGraphModelList {
//                if uvcdml._id == detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].parentId[0] {
//                    userSentencePatternAddRequest.parentObjectId = uvcdml.getText(index: 0, name: "Name")!.optionObjectIdName
//                    userSentencePatternAddRequest.parentObjectName = uvcdml.getText(index: 0, name: "Name")!.optionObjectName
//                    break
//                }
//            }
//            userSentencePatternAddRequest.parentId = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].parentId[0]
//            userSentencePatternAddRequest.nodeId = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex]._id
//            userSentencePatternAddRequest.fromItemIndex = 0
//            userSentencePatternAddRequest.toItemIndex = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].uvcViewModel.count - 1
//            userSentencePatternAddRequest.sentenceIndex = detailViewController!.currentSentenceIndex
//
//            detailViewController!.setCurrentOperationData(data: [detailViewController!.getCurrentOperation(): [
//                "userSentencePatternAddRequest": userSentencePatternAddRequest]])
//            detailViewController!.sendRequest(sourceName: self.detailViewController!.sourceName)
        }
        
        
        if detailViewController!.currentOptionCategory == "Document Item Search Options" {
            
            detailViewController!.showOptionPopover(category: "Search Option", width: 400, height: 200, sender: detailViewController!.documentOptionsButton, delegate: detailViewController! as UIPopoverPresentationControllerDelegate, optionLabel: ["By Category", "Include Grammar", "By Name", "By Related"], optionSelection: searchOptionSelection, searchOptionDelegate: self)
        } else {
            if uvcOptionViewModel[0].pathIdName[parentIndex].joined(separator: "->").hasPrefix( "UDCDocumentItemMapNode.DocumentItems") {
                
                //                detailViewController!.optionViewController!.dismiss(animated: true, completion: nil)
                
                
                print(uvcOptionViewModel[0].getText(name: "Name")!.value)
                detailViewController!.documetSentenceSearchBox?.text = uvcOptionViewModel[0].getText(name: "Name")!.value
                //                detailViewController!.documetSentenceSearchBox?.becomeFirstResponder()
                insertItem(section: 0, index: index, level: level, searchText: uvcOptionViewModel[0].getText(name: "Name")!.value, itemData: "", uvOptionViewModel: uvcOptionViewModel[0], documentGraphInsertItemRequestParam: nil, parentIndex: parentIndex)
            } else if uvcOptionViewModel[0].pathIdName[parentIndex].joined(separator: "->").hasPrefix( "UDCDocumentItemMapNode.DocumentItemOption") {
                changeItem(uvcOptionViewModel: uvcOptionViewModel, optionItemId: "", item: "")
            }
        }
        
        
    }
    
    private func changeItem(uvcOptionViewModel: [UVCOptionViewModel]?, optionItemId: String, item: String) {
        let documentGraphChangeItemRequest = DocumentGraphChangeItemRequest()
        documentGraphChangeItemRequest.documentId = detailViewController!.documentId
        let section = CallBrainControllerNeuron.delegateMap["DocumentItem.Get.Section"] as! Int
        let itemIndex = CallBrainControllerNeuron.delegateMap["DocumentItem.Get.Index"] as! Int
        let subIndex = CallBrainControllerNeuron.delegateMap["DocumentItem.Get.SubIndex"] as! Int
        let objectName = CallBrainControllerNeuron.delegateMap["DocumentItem.Get.ObjectName"] as! String
        var udcDocumentTypeIdName = ""
        if detailViewController!.isPopup {
            udcDocumentTypeIdName = detailViewController!.popupUdcDocumentTypeIdName
        } else {
            udcDocumentTypeIdName = ApplicationSetting.DocumentType!
        }
        if detailViewController!.uvcDocumentGraphModelList[section].parentId.count > 0 {
            documentGraphChangeItemRequest.parentId.append(detailViewController!.uvcDocumentGraphModelList[section].parentId[0])
        }
        documentGraphChangeItemRequest.nodeId = detailViewController!.uvcDocumentGraphModelList[section]._id
        if uvcOptionViewModel != nil {
            documentGraphChangeItemRequest.item = uvcOptionViewModel![0].getText(name: "Name")!.value
            documentGraphChangeItemRequest.optionItemId = uvcOptionViewModel![0].idName
            documentGraphChangeItemRequest.optionItemNameIndex = uvcOptionViewModel![0].objectNameIndex
            documentGraphChangeItemRequest.optionDocumentIdName = uvcOptionViewModel![0].objectDocumentIdName
        } else {
            documentGraphChangeItemRequest.item = item
            documentGraphChangeItemRequest.itemId = optionItemId
        }
        documentGraphChangeItemRequest.optionItemObjectName = objectName
        if detailViewController!.currentItemIndex < itemIndex && detailViewController!.currentNodeIndex == section {
            documentGraphChangeItemRequest.itemIndex = itemIndex - 1
        } else {
            documentGraphChangeItemRequest.itemIndex = itemIndex
        }
        documentGraphChangeItemRequest.subItemIndex = subIndex
        documentGraphChangeItemRequest.nodeIndex = section
        //        if detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].parentId.count > 0 {
        //            documentGraphChangeItemRequest.level = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex - 1].level + 1
        //        } else {
        documentGraphChangeItemRequest.level = detailViewController!.uvcDocumentGraphModelList[detailViewController!.currentNodeIndex].level
        //        }
        documentGraphChangeItemRequest.isDocumentItemEditable = detailViewController!.isDocumentItemEditable
        documentGraphChangeItemRequest.sentenceIndex = detailViewController!.currentSentenceIndex
        documentGraphChangeItemRequest.udcDocumentTypeIdName = udcDocumentTypeIdName
        documentGraphChangeItemRequest.objectControllerRequest = ObjectControllerRequest()
        documentGraphChangeItemRequest.objectControllerRequest.viewConfigPathIdName.append(contentsOf: detailViewController!.viewConfigPathIdName)
        documentGraphChangeItemRequest.objectControllerRequest.uvcViewItemType = detailViewController!.uvcViewItemType
        documentGraphChangeItemRequest.objectControllerRequest.editMode = detailViewController!.objectEditMode
        documentGraphChangeItemRequest.objectControllerRequest.groupUVCViewItemType = detailViewController!.groupUVCViewItemType
        documentGraphChangeItemRequest.objectControllerRequest.udcViewItemName = detailViewController!.udcViewItemName
        documentGraphChangeItemRequest.objectControllerRequest.udcViewItemId = detailViewController!.udcViewItemId
        documentGraphChangeItemRequest.objectControllerRequest.viewPathIdName.append(contentsOf: detailViewController!.viewPathIdName)
        detailViewController!.setCurrentOperation(name: "DocumentGraphNeuron.Document.Item.Change")
        detailViewController!.setCurrentOperationData(data: [detailViewController!.getCurrentOperation(): [
            "documentGraphChangeItemRequest": documentGraphChangeItemRequest,
            "neuronName": detailViewController!.neuronName]])
        detailViewController!.sendRequest(sourceName: self.detailViewController!.sourceName)
    }
    
    public func optionViewControllerEditOk(index: Int, parentIndex: Int, level: Int, senderModel: Any, sender: Any) {
        
    }
    
    public func optionViewControllerTextFieldDidChange(index: Int, parentIndex: Int, level: Int, senderModel: Any, sender: Any) {
        
    }
    
    
    public func optionViewControllerCancelSelected() {
        
    }
    
    public func optionViewControllerSearch(idName: String, searchText: String) {
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            isSearchActive = false
            return
        }
        if idName == "UDCOptionMap.DocumentOptions" {
            return
        }
        if searchText.last == " " {
            //            detailViewController!.focusRequiredAferReload = false
            //            isSearchActive = true
            //            detailViewController!.setCurrentOperation(name: "DocumentGraphNeuron.DocumentItem.Search")
            //            detailViewController!.setCurrentOperationData(data: [detailViewController!.getCurrentOperation(): [
            //                "DocumentItem.Get.ObjectName" : CallBrainControllerNeuron.delegateMap["DocumentItem.Get.ObjectName"],
            //                "DocumentItem.Get.SearchText" : searchText.trimmingCharacters(in: .whitespaces)]])
            //            detailViewController!.sendRequest(source: self)
        }
    }
    
    func uvcDetalViewCellSelectedImage(uvcViewController: UVCViewController, udcViewItem: String, section: Int, index: Int, subIndex: Int, level: Int, senderModel: Any, sender: Any) {
        
    }
    
    func uvcDetalViewCelButtonUpdated(uvcViewController: UVCViewController, uvcUIButton: UVCUIButton, section: Int, index: Int, level: Int, senderModel: Any, sender: Any) {
        //        if uvcUIButton.name == "CursorUDCDocumentItemMapNode.SearchDocumentItems" {
        //            handleCursor(uvcViewController: uvcViewController, uvcUIButton: uvcUIButton)
        //        }
        //        if sender is UVCUIButton && detailViewController!.currentItemIndex - 1 == index && detailViewController!.currentNodeIndex == section && detailViewController!.focusRequiredAferReload {
        //            showDocumentItemOption(uvcViewController: uvcViewController, index: index, section: section, sender: sender)
        //        }
    }
    
    func showDocumentItemOption(uvcObject: Any, index: Int, subIndex: Int, section: Int, sender: Any) {
        var uvcText: UVCText?
        var uvcButton: UVCButton?
        let typeRequest = GetDocumentItemOptionRequest()
        
        if isActivityInProgress {
            return
        }
        
        if uvcObject is UVCText {
            uvcText = uvcObject as! UVCText
        }
        if uvcObject is UVCButton {
            uvcButton = uvcObject as! UVCButton
        }
        typeRequest.language = ApplicationSetting.DocumentLanguage!
        typeRequest.fromText = ""
        typeRequest.sortedBy = "name"
        typeRequest.limitedTo = 50
        typeRequest.isAll = false
        typeRequest.searchText = ""
        if uvcButton != nil {
            typeRequest.text = uvcButton!.value
            typeRequest.type = uvcButton!.optionObjectName
            typeRequest.category = uvcButton!.optionObjectCategoryIdName
            typeRequest.uvcViewItemType = "UVCViewItemType.Button"
            let documentGraphItemViewData = DocumentGraphItemViewData()
            documentGraphItemViewData.itemIndex = index
            documentGraphItemViewData.nodeIndex = section
            detailViewController!.showPopover(category: "", uvcOptionViewModel: nil, width: 350, height: 300, sender: sender, delegate: detailViewController!, optionDelegate: self, goToOption: "", isDismissedAutomatically: false, optionViewControllerName: "Document Search Items", rightButton: ["", "", ""], idName: "", operationName: "DocumentGraphNeuron.DocumentItem.Get", documentGraphItemSearchRequest: nil, documentGraphItemReferenceRequest: nil, typeRequest: typeRequest, documentGraphItemViewData: documentGraphItemViewData, documentMapSearchDocumentRequest: nil)
        }
        if (uvcText != nil) && !uvcText!.name.hasSuffix("UDCDocumentItemMapNode.SearchDocumentItems") {
            typeRequest.text = uvcText!.value
            typeRequest.type = uvcText!.optionObjectName
            typeRequest.category = uvcText!.optionObjectCategoryIdName
            typeRequest.uvcViewItemType = "UVCViewItemType.Text"
            let documentGraphItemViewData = DocumentGraphItemViewData()
            documentGraphItemViewData.itemIndex = index
            documentGraphItemViewData.nodeIndex = section
            detailViewController!.showPopover(category: "", uvcOptionViewModel: nil, width: 350, height: 300, sender: sender, delegate: detailViewController!, optionDelegate: self, goToOption: "", isDismissedAutomatically: false, optionViewControllerName: "Document Search Items", rightButton: ["", "", ""], idName: "", operationName: "DocumentGraphNeuron.DocumentItem.Get", documentGraphItemSearchRequest: nil, documentGraphItemReferenceRequest: nil, typeRequest: typeRequest, documentGraphItemViewData: documentGraphItemViewData, documentMapSearchDocumentRequest: nil)
        }
        if uvcObject is UVCPhoto {
            let uvcPhoto = uvcObject as! UVCPhoto
            let typeRequest = GetDocumentItemOptionRequest()
            typeRequest.type = uvcPhoto.optionObjectName
            typeRequest.category = uvcPhoto.optionObjectCategoryIdName
            typeRequest.uvcViewItemType = "UVCViewItemType.Photo"
            let documentGraphItemViewData = DocumentGraphItemViewData()
            documentGraphItemViewData.itemIndex = index
            documentGraphItemViewData.nodeIndex = section
            detailViewController!.showPopover(category: "", uvcOptionViewModel: nil, width: 350, height: 300, sender: sender, delegate: detailViewController!, optionDelegate: self, goToOption: "", isDismissedAutomatically: false, optionViewControllerName: "Document Search Items", rightButton: ["Add", "", ""], idName: "", operationName: "DocumentGraphNeuron.DocumentItem.Get", documentGraphItemSearchRequest: nil, documentGraphItemReferenceRequest: nil, typeRequest: typeRequest, documentGraphItemViewData: documentGraphItemViewData, documentMapSearchDocumentRequest: nil)
        }
    }
}
