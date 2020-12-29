//
//  DocumentItemConfigurationNeuron.swift
//  UniversalBrainController
//
//  Created by Kumar Muthaiah on 14/11/18.
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
import UDocsUtility
import UDocsDatabaseModel
import UDocsDatabaseUtility
import UDocsNeuronModel
import UDocsNeuronUtility
import UDocsDocumentModel
import UDocsDocumentUtility
import UDocsViewModel
import UDocsViewUtility
import UDocsGrammarNeuronModel
import UDocsDocumentGraphNeuronModel

public class DocumentItemConfigurationNeuron : Neuron {
    public static func getRootResponse(neuronSourceId: String) -> NeuronRequest {
        return NeuronRequest()
    }
    var neuronUtility: NeuronUtility? = nil
    let uvcViewGenerator = UVCViewGenerator()
    let stringUtility = StringUtility()
    let documentParser = DocumentParser()
    var udbcDatabaseOrm: UDBCDatabaseOrm?
    static var dendriteMap: [String : Neuron] = [String : Neuron]()
    private var responseMap: [String : NeuronRequest] = [String : NeuronRequest]()
    static let serialQueue = DispatchQueue(label: "SerialQueue")
    
    
    private func process(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        neuronResponse.neuronOperation.response = true
        print("\(DocumentItemConfigurationNeuron.getName()): process")
        if neuronRequest.neuronOperation.name == "DocumentItemConfigurationNeuron.Document.AddCategory" {
//            try addRecipeCategory(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.SearchResult.DocumentItem" {
            try searchRecipeItem(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Generate.DocumentItem.View.Insert" {
            try generateDocumentItemViewForInsert(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Generate.DocumentItem.View.Change" {
            try generateDocumentItemViewForChange(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Get.SentencePattern.DocumentItem" {
            try getSentencePatternForDocumentItem(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Generate.DocumentItem.View.Reference" {
            try getDocumentSentenceListOptionView(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        }  else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.Validate.Insert" {
            try validateInsertRequest(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        }  else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.Validate.Delete" {
            try validateDeleteRequest(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Get.Categories" {
            try getDocumentCategories(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Get.Category.Options" {
            try getDocumentCategoryOptions(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else if neuronRequest.neuronOperation.name.hasPrefix("DocumentGraphNeuron.Document.Type") {
            try documentGraphTypeProcess(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.IdName" {
            try getDocumentIdName(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        }else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.Validate.Delete.Line" {
            try validateDeleteLineRequest(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        }
        
        
    }
    
    
    // Form the actual sentence as per Grammar rules, based on the sentence pattern
    private func processGrammar(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest, udcSentencePattern: UDCSentencePattern, documentLanguage: String, textStartIndex: Int) throws -> UDCSentencePattern {
        let neuronRequestLocal = NeuronRequest()
        neuronRequestLocal.neuronSource._id = neuronRequest.neuronSource._id
        neuronRequestLocal.neuronOperation.synchronus = true
        neuronRequestLocal.neuronOperation._id = neuronRequest.neuronOperation._id
        neuronRequestLocal.neuronSource.name = DocumentItemConfigurationNeuron.getName()
        neuronRequestLocal.neuronSource.type = DocumentItemConfigurationNeuron.getName();
        neuronRequestLocal.neuronOperation.name = "GrammarNeuron.Sentence.Generate"
        neuronRequestLocal.neuronOperation.parent = true
        let sentenceRequest = SentenceRequest()
        sentenceRequest.udcSentencePattern = udcSentencePattern
        sentenceRequest.documentLanguage = documentLanguage
        sentenceRequest.textStartIndex = textStartIndex
        let jsonUtilitySentenceRequest = JsonUtility<SentenceRequest>()
        neuronRequestLocal.neuronOperation.neuronData.text = jsonUtilitySentenceRequest.convertAnyObjectToJson(jsonObject: sentenceRequest)
        neuronRequestLocal.neuronTarget.name =  "GrammarNeuron"
        
        try callOtherNeuron(neuronRequest: neuronRequestLocal, neuronResponse: &neuronResponse, neuronName: neuronRequestLocal.neuronTarget.name, overWriteResponse: true)
        
        let jsonUtilitySentenceResponse = JsonUtility<SentenceResponse>()
        let sentenceResponse = jsonUtilitySentenceResponse.convertJsonToAnyObject(json: neuronResponse.neuronOperation.neuronData.text)
        
        return sentenceResponse.udcSentencePattern
    }
    
    
    private func generateSentenceViewAsArray(udcDocumentGraphModel: UDCDocumentGraphModel,  uvcViewItemCollection: UVCViewItemCollection?, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest, newView: Bool, isEditable: Bool, level: Int, nodeIndex: Int, itemIndex: Int, documentLanguage: String) -> [UVCViewModel] {
        var uvcViewModelReturn = [UVCViewModel]()
        
        for udcSentencePatternData in udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData {
            for (udcSentencePatternDataGroupIndex, udcSentencePatternDataGroup) in udcSentencePatternData.udcSentencePatternDataGroup.enumerated() {
                
                
                for (udcSentencePatternDataGroupValueIndex, udcSentencePatternDataGroupValue) in udcSentencePatternDataGroup.udcSentencePatternDataGroupValue.enumerated() {
                    
                    let value = udcSentencePatternDataGroupValue.item
                    let objectCategoryId = udcSentencePatternDataGroupValue.endSubCategoryId.isEmpty ?  udcSentencePatternDataGroupValue.endCategoryId : udcSentencePatternDataGroupValue.endSubCategoryId
                    
                    
                    if udcSentencePatternDataGroupValue.uvcViewItemType == "UVCViewItemType.Choice" {
                        uvcViewModelReturn.append(uvcViewGenerator.getChoiceItemModel(item: udcSentencePatternDataGroupValue.item!, isEditable: udcSentencePatternDataGroupValue.isEditable, editObjectCategoryIdName: udcSentencePatternDataGroupValue.endSubCategoryId, editObjectName: getEditObjectName(idName: udcSentencePatternDataGroupValue.endCategoryIdName), editObjectIdName: udcSentencePatternDataGroupValue.itemId))
                    } else if udcSentencePatternDataGroupValue.uvcViewItemType == "UVCViewItemType.Photo" {
                        var photoWidth: Double = 160
                        var photoHeight: Double = 160
                        var udcPhotoId: String = ""
                        var isOptionAvailable = true
                        if udcSentencePatternDataGroupValue.endCategoryIdName.hasSuffix("DocumentItemPhoto") {
                            var udcPhotoDocumentPhoto: UDCPhoto?
                            let databaseOrmUDCDocumentItem = UDCDocumentGraphModel.get(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, id: udcSentencePatternDataGroupValue.itemId, language: documentLanguage)
                            if databaseOrmUDCDocumentItem.databaseOrmError.count > 0 {
                                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentItem.databaseOrmError[0].name, description: databaseOrmUDCDocumentItem.databaseOrmError[0].description))
                                return uvcViewModelReturn
                            }
                            let udcDocumentItem = databaseOrmUDCDocumentItem.object[0]
                            
                            let databaseOrmResultUDCPhoto = UDCPhoto.get(collectionName: "UDCDocumentItemPhoto", udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentItem.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].itemId)
                            if databaseOrmResultUDCPhoto.databaseOrmError.count > 0 {
                                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCPhoto.databaseOrmError[0].name, description: databaseOrmResultUDCPhoto.databaseOrmError[0].description))
                                return uvcViewModelReturn
                            }
                            udcPhotoDocumentPhoto = databaseOrmResultUDCPhoto.object[0]
                            udcPhotoId = udcDocumentItem._id
                            for uvcMeasurement in udcPhotoDocumentPhoto!.uvcMeasurement {
                                if uvcMeasurement.type == "UVCMeasurementType.Width" {
                                    photoWidth = Double(uvcMeasurement.value)
                                } else if uvcMeasurement.type == "UVCMeasurementType.Height" {
                                    photoHeight = Double(uvcMeasurement.value)
                                }
                            }
                        } else {
                            udcPhotoId = udcSentencePatternDataGroupValue.itemId
                            isOptionAvailable = false
                        }
                        uvcViewModelReturn.append(uvcViewGenerator.getPhotoModel(isEditable: udcSentencePatternDataGroupValue.isEditable, editObjectCategoryIdName: objectCategoryId, editObjectName: getEditObjectName(idName: udcSentencePatternDataGroupValue.endCategoryIdName), editObjectIdName: udcPhotoId, level: level, isOptionAvailable: isOptionAvailable, width: photoWidth, height: photoHeight, itemIndex: udcSentencePatternDataGroupValueIndex, isCategory: udcDocumentGraphModel.isChildrenAllowed, isBorderEnabled: true, isDeviceOptionsAvailable: !isOptionAvailable))
                    } else {
                        if udcDocumentGraphModel.isChildrenAllowed { // nodeIndex == 0 && itemIndex >= 0 || (level >= 0 && level <= 1) {
                            uvcViewModelReturn.append(contentsOf: uvcViewGenerator.getCategoryView(value: value!, language: documentLanguage, parentId: udcDocumentGraphModel.parentId, childrenId: udcDocumentGraphModel.childrenId, nodeId: [udcDocumentGraphModel._id], sentenceIndex: [udcSentencePatternDataGroupIndex], wordIndex: [udcSentencePatternDataGroupValueIndex], objectId: udcSentencePatternDataGroupValue.itemId, objectName: getEditObjectName(idName: udcSentencePatternDataGroupValue.endCategoryIdName), objectCategoryIdName: objectCategoryId, level: udcDocumentGraphModel.level))
                        } else {
                            let uvcViewModel = UVCViewModel()
                            uvcViewModel.uvcViewItemType = "UVCViewItemType.Text"
                            uvcViewModel.language = documentLanguage
                            var uvcViewItem = UVCViewItem()
                            uvcViewItem.name = uvcViewGenerator.generateNameWithUniqueId("SentenceTable")
                            uvcViewItem.type = "UVCViewItemType.Table"
                            uvcViewModel.uvcViewItem.append(uvcViewItem)
                            uvcViewItem = UVCViewItem()
                            uvcViewItem.name = uvcViewGenerator.generateNameWithUniqueId("SentenceTexts")
                            uvcViewItem.type = "UVCViewItemType.Text"
                            uvcViewModel.uvcViewItem.append(uvcViewItem)
                            
                            let uvcTable = UVCTable()
                            let uvcTableRow = UVCTableRow()
                            let uvcTableColumn = UVCTableColumn()
                            uvcViewItem = UVCViewItem()
                            
                            
                            //                            if level > 1 && udcSentencePatternDataGroupValueIndex == 0 {
                            //                                let generatedNameSpacer = uvcViewGenerator.generateNameWithUniqueId("Spacer")
                            //                                let uvcPhoto = uvcViewGenerator.getPhoto(name: generatedNameSpacer, description: "", isEditable: false)
                            //                                uvcPhoto.isOptionAvailable = false
                            //                                var uvcMeasurement = UVCMeasurement()
                            //                                uvcMeasurement.type = UVCMeasurementType.XAxis.name
                            //                                uvcMeasurement.value = 0
                            //                                uvcPhoto.uvcMeasurement.append(uvcMeasurement)
                            //                                uvcMeasurement = UVCMeasurement()
                            //                                uvcMeasurement.type = UVCMeasurementType.YAxis.name
                            //                                uvcMeasurement.value = 0
                            //                                uvcPhoto.uvcMeasurement.append(uvcMeasurement)
                            //                                uvcMeasurement = UVCMeasurement()
                            //                                uvcMeasurement.type = UVCMeasurementType.Width.name
                            //                                uvcMeasurement.value = Double(level) * 12
                            //                                uvcPhoto.uvcMeasurement.append(uvcMeasurement)
                            //                                uvcMeasurement = UVCMeasurement()
                            //                                uvcMeasurement.type = UVCMeasurementType.Height.name
                            //                                uvcMeasurement.value = 0
                            //                                uvcPhoto.uvcMeasurement.append(uvcMeasurement)
                            //                                uvcViewModel.uvcViewItemCollection.uvcPhoto.append(uvcPhoto)
                            //                                uvcViewItem = UVCViewItem()
                            //                                uvcViewItem.name = generatedNameSpacer
                            //                                uvcViewItem.type = "UVCViewItemType.Photo"
                            //                                uvcTableColumn.uvcViewItem.append(uvcViewItem)
                            //                            }
                            uvcViewItem = UVCViewItem()
                            let value = udcSentencePatternDataGroupValue.item
                            let name = uvcViewGenerator.generateNameWithUniqueId("Name")
                            
                            uvcViewItem.name = name
                            uvcViewItem.type = "UVCViewItemType.Text"
                            
                            //                            if udcSentencePatternDataGroupValue.endCategory.isEmpty || (udcSentencePatternDataGroupValue.endCategory == "Grammar Item" && udcSentencePatternDataGroupValue.category != "UDCGrammarCategory.Number") {
                            //                                let uvcText = uvcViewGenerator.getText(name: name, value: value!, description: "", isEditable: false)
                            //                                uvcText.uvcTextStyle.textColor = UVCColor.get(level: udcDocumentGraphModel.level)!.name
                            //                                uvcText.parentId.append(contentsOf: udcDocumentGraphModel.parentId)
                            //                                uvcText.childrenId.append(contentsOf: udcDocumentGraphModel.childrenId)
                            //                                uvcText._id = udcDocumentGraphModel._id
                            //                                uvcText.uvcTextSize.uvcTextSizeType = UVCTextSizeType.Regular.name
                            //                                uvcText.uvcViewItemType = "UVCViewItemType.Text"
                            //                                uvcText.optionObjectIdName = udcSentencePatternDataGroupValue.itemIdName
                            //                                uvcText.optionObjectCategoryIdName = udcSentencePatternDataGroupValue.endSubCategory
                            //                                uvcText.optionObjectName = getEditObjectName(idName: udcSentencePatternDataGroupValue.endCategory)
                            //                                uvcViewModel.uvcViewItemCollection.uvcText.append(uvcText)
                            //                                uvcViewModel.name = uvcViewGenerator.generateNameWithUniqueId("UVCViewItemType.Text")
                            //                                uvcViewModel.textLength = uvcText.value.count
                            //                                uvcViewModel.rowLength = 1
                            //                            } else {
                            let uvcText = uvcViewGenerator.getText(name: name, value: value!, description: "", isEditable: isEditable)
                            uvcText.uvcTextStyle.textColor = UVCColor.get(level: udcDocumentGraphModel.level)!.name
                            uvcText.parentId.append(contentsOf: udcDocumentGraphModel.parentId)
                            uvcText.childrenId.append(contentsOf: udcDocumentGraphModel.childrenId)
                            uvcText._id = udcDocumentGraphModel._id
                            
                            
                            if isTextFieldRecipeItem(itemIdName: udcSentencePatternDataGroupValue.itemId) {
                                uvcText.uvcViewItemType = "UVCViewItemType.Text"
                                uvcText.isEditable = true
                                uvcText.helpText = "\(udcSentencePatternDataGroupValue.item!.capitalized)"
                                uvcViewModel.textLength = uvcText.value.count
                                uvcViewModel.name = uvcViewGenerator.generateNameWithUniqueId("UVCViewItemType.Text")
                            } else {
                                if uvcText.value.isEmpty {
                                    uvcText.value = value!
                                }
                                uvcText.uvcViewItemType = "UVCViewItemType.Text"
                                uvcText.helpText = "\(udcSentencePatternDataGroupValue.item!.capitalized)"
                                uvcViewModel.textLength = uvcText.value.count
                                uvcText.isEditable = true
                                uvcText.isOptionAvailable = true
                                uvcViewModel.name = uvcViewGenerator.generateNameWithUniqueId("UVCViewItemType.Text")
                            }
                            
                            uvcText.uvcTextSize.uvcTextSizeType = UVCTextSizeType.Regular.name
                            uvcText.optionObjectIdName = udcSentencePatternDataGroupValue.itemId
                            uvcText.optionObjectCategoryIdName = objectCategoryId
                            uvcText.optionObjectName = getEditObjectName(idName: udcSentencePatternDataGroupValue.endCategoryIdName)
                            uvcViewModel.uvcViewItemCollection.uvcText.append(uvcText)
                            uvcViewModel.rowLength = 1
                            //                            }
                            uvcTableColumn.uvcViewItem.append(uvcViewItem)
                            uvcTableRow.uvcTableColumn.append(uvcTableColumn)
                            uvcTable.uvcTableRow.append(uvcTableRow)
                            uvcViewModel.uvcViewItemCollection.uvcTable.append(uvcTable)
                            uvcViewModelReturn.append(uvcViewModel)
                        }
                    }
                }
            }
        }
        
        return uvcViewModelReturn
    }
    
    private func documentGraphTypeProcess(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let documentGraphTypeProcessRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: DocumentGraphTypeProcessRequest())
        
        let documentGraphTypeProcessResponse = DocumentGraphTypeProcessResponse()
        if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.Type.Process.Post" {
            if documentGraphTypeProcessRequest.nodeIndex == 0 {
                documentGraphTypeProcessResponse.udcSentencePatternUniqueDocumentTitle = documentGraphTypeProcessRequest.udcDocuemntGraphModel.udcSentencePattern
            }/* else if documentGraphTypeProcessRequest.nodeIndex == 1 {
                documentGraphTypeProcessResponse.udcSentencePatternDocumentTitle = documentGraphTypeProcessRequest.udcDocuemntGraphModel.udcSentencePattern
            }*/
            
            
            
            
        } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.Type.Process.Post.AfterSave" {
            if !documentGraphTypeProcessRequest.udcDocuemntGraphModel.name.isEmpty {
                let databaseOrmResultUDCDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphTypeProcessRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: documentGraphTypeProcessRequest.udcDocumentModelId, language: documentGraphTypeProcessRequest.documentLanguage)
                if databaseOrmResultUDCDocumentGraphModel.databaseOrmError.count == 0 {
                    let udcDocumentGraphModel = databaseOrmResultUDCDocumentGraphModel.object[0]
                    var fieldsMap = [String: [UDCSentencePatternDataGroupValue]]()
                    let databaseOrmResultUDCDocumentGraphModelChild = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphTypeProcessRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentGraphModel.childrenId[0], language: documentGraphTypeProcessRequest.documentLanguage)
                    let udcDocumentGraphModelChild = databaseOrmResultUDCDocumentGraphModelChild.object[0]
                    documentParser.getFields(childrenId: udcDocumentGraphModel.childrenId, fieldValue: &fieldsMap, udcDocumentTypeIdName: documentGraphTypeProcessRequest.udcDocumentTypeIdName, documentLanguage: documentGraphTypeProcessRequest.documentLanguage)
                    if documentGraphTypeProcessRequest.nodeIndex > 0 {
                        try findAndProcessDocumentItemMapNode(name: udcDocumentGraphModelChild.name, idName: String(udcDocumentGraphModelChild.idName.split(separator: ".")[1]), fieldsMap: fieldsMap, documentLanguage: documentGraphTypeProcessRequest.documentLanguage, udcProfile: documentGraphTypeProcessRequest.udcProfile, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
                    }
                }
            }
        } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.Type.Process.View.Generated" {
            documentGraphTypeProcessResponse.isProcessed = false
        }
        
        let jsonUtilityDocumentGraphTypeProcessResponse = JsonUtility<DocumentGraphTypeProcessResponse>()
        let jsonDocumentGraphTypeProcessResponse = jsonUtilityDocumentGraphTypeProcessResponse.convertAnyObjectToJson(jsonObject: documentGraphTypeProcessResponse)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonDocumentGraphTypeProcessResponse)
    }
    
    private func findAndProcessDocumentItemMapNode(name: String, idName: String, fieldsMap: [String: [UDCSentencePatternDataGroupValue]], documentLanguage: String, udcProfile: [UDCProfile], neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        // Get the document items for the document langauge
        let databaseUDCDocumentItemMap = UDCDocumentItemMap.get(udbcDatabaseOrm: udbcDatabaseOrm!, idName: "UDCDocumentItemMap.DocumentItems", udcProfile: udcProfile, language: documentLanguage)
        if databaseUDCDocumentItemMap.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseUDCDocumentItemMap.databaseOrmError[0].name, description: databaseUDCDocumentItemMap.databaseOrmError[0].description))
            return
        }
        let udcDocumentItemMap = databaseUDCDocumentItemMap.object[0]
        
        // Process search document type
        // Loop through the childrens for each document type
        for childrenId in udcDocumentItemMap.udcDocumentItemMapNodeId {
            // Get the "document items" child node for each document type
            let databaseUDCDocumentItemMap = UDCDocumentItemMapNode.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: childrenId, language: documentLanguage)
            if databaseUDCDocumentItemMap.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseUDCDocumentItemMap.databaseOrmError[0].name, description: databaseUDCDocumentItemMap.databaseOrmError[0].description))
                return
            }
            let udcDocumentItemMapNode = databaseUDCDocumentItemMap.object[0]
            let parentUDCDocumentTypeIdName = udcDocumentItemMapNode.udcDocumentTypeIdName
            // If no document types in document then delete from current document type if found
            if fieldsMap["UDCDocumentItem.SearchDocumentType"] == nil {
                let _ = UDCDocumentItemMapNode.remove(udbcDatabaseOrm: udbcDatabaseOrm!, idName: "UDCDocumentItemMapNode.\(idName)", language: documentLanguage, udcDocumentTypeIdName: parentUDCDocumentTypeIdName, objectName: "UDCDocumentItem") as DatabaseOrmResult<UDCDocumentItemMapNode>
                continue
            }
            // Loop through the document type given in the document
            var foundParentDocumentType: Bool = false
            for udcspgv in fieldsMap["UDCDocumentItem.SearchDocumentType"]! {
                let udcDocumentTypeIdName: String = "UDCDocumentType.\(udcspgv.itemIdName.split(separator: ".")[1])"
                if parentUDCDocumentTypeIdName == udcDocumentTypeIdName {
                    foundParentDocumentType = true
                    break
                }
            }
            if !foundParentDocumentType {
                let databaseUDCDocumentItemMapNode = UDCDocumentItemMapNode.get(udbcDatabaseOrm: udbcDatabaseOrm!, idName: "UDCDocumentItemMapNode.\(idName)", language: documentLanguage, udcDocumentTypeIdName: parentUDCDocumentTypeIdName, objectName: "UDCDocumentItem")
                if databaseUDCDocumentItemMapNode.databaseOrmError.count == 0 {
                    let databaseUDCDocumentItemMapNodeRemove = UDCDocumentItemMapNode.remove(udbcDatabaseOrm: udbcDatabaseOrm!, idName: "UDCDocumentItemMapNode.\(idName)", language: documentLanguage, udcDocumentTypeIdName: parentUDCDocumentTypeIdName, objectName: "UDCDocumentItem") as DatabaseOrmResult<UDCDocumentItemMapNode>
                    if databaseUDCDocumentItemMapNodeRemove.databaseOrmError.count == 0 {
                        let _ = UDCDocumentItemMapNode.updatePull(udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentItemMapNode._id, childrenId: databaseUDCDocumentItemMapNode.object[0]._id) as DatabaseOrmResult<UDCDocumentItemMapNode>
                    }
                }
                continue
            }
            
            for udcspgv in fieldsMap["UDCDocumentItem.SearchDocumentType"]! {
                let udcDocumentTypeIdName: String = "UDCDocumentType.\(udcspgv.itemIdName.split(separator: ".")[1])"
                // If document type not found then remove if any item already found
                if parentUDCDocumentTypeIdName == udcDocumentTypeIdName {
                    // Check if already found in its childrens
                    let databaseUDCDocumentItemMap = UDCDocumentItemMapNode.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentItemMapNode.childrenId, idName: "UDCDocumentItemMapNode.\(idName)", language: documentLanguage, udcDocumentTypeIdName: udcDocumentTypeIdName, objectName: "UDCDocumentItem")
                    // If not already found insert it
                    if databaseUDCDocumentItemMap.databaseOrmError.count > 0 {
                        let udcDocumentItemMapNodeChild = UDCDocumentItemMapNode()
                        udcDocumentItemMapNodeChild._id = try udbcDatabaseOrm!.generateId()
                        udcDocumentItemMapNodeChild.name = name
                        udcDocumentItemMapNodeChild.idName = "UDCDocumentItemMapNode.\(idName)"
                        udcDocumentItemMapNodeChild.level = 1
                        let databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, udcProfile: udcProfile, udcDocumentTypeIdName: "UDCDocumentType.DocumentItem", idName: "UDCDocument.\(idName)", language: documentLanguage)
                        if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
                            let databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, udcProfile: udcProfile, udcDocumentTypeIdName: "UDCDocumentType.DocumentItem", idName: "UDCDocument.\(idName)", language: "en")
                            udcDocumentItemMapNodeChild.objectId = [databaseOrmResultUDCDocument.object[0]._id]
                        } else {
                            udcDocumentItemMapNodeChild.objectId = [databaseOrmResultUDCDocument.object[0]._id]
                        }
                        udcDocumentItemMapNodeChild.objectName = "UDCDocumentItem"
                        udcDocumentItemMapNodeChild.udcDocumentTypeIdName = udcDocumentTypeIdName
                        udcDocumentItemMapNodeChild.pathIdName.append("UDCDocumentItemMapNode.DocumentItems")
                        udcDocumentItemMapNodeChild.pathIdName.append(udcDocumentItemMapNode.idName)
                        udcDocumentItemMapNodeChild.language = documentLanguage
                        udcDocumentItemMapNodeChild.parentId.append(udcDocumentItemMapNode._id)
                        udcDocumentItemMapNode.childrenId.append(udcDocumentItemMapNodeChild._id)
                        
                        // Save the child
                        let databaseUDCDocumentItemMapChildSave = UDCDocumentItemMapNode.save(udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentItemMapNodeChild)
                        if databaseUDCDocumentItemMapChildSave.databaseOrmError.count > 0 {
                            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseUDCDocumentItemMapChildSave.databaseOrmError[0].name, description: databaseUDCDocumentItemMapChildSave.databaseOrmError[0].description))
                            return
                        }
                        
                        // Save the parent
                        let databaseUDCDocumentItemMapChildUpdate = UDCDocumentItemMapNode.update(udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentItemMapNode)
                        if databaseUDCDocumentItemMapChildUpdate.databaseOrmError.count > 0 {
                            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseUDCDocumentItemMapChildUpdate.databaseOrmError[0].name, description: databaseUDCDocumentItemMapChildUpdate.databaseOrmError[0].description))
                            return
                        }
                    }
                    
                }
                
            }
        }
        
        // Process search document
        for childrenId in udcDocumentItemMap.udcDocumentItemMapNodeId {
            // Get the "document items" child node for each document type
            let databaseUDCDocumentItemMap = UDCDocumentItemMapNode.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: childrenId, language: documentLanguage)
            if databaseUDCDocumentItemMap.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseUDCDocumentItemMap.databaseOrmError[0].name, description: databaseUDCDocumentItemMap.databaseOrmError[0].description))
                return
            }
            let udcDocumentItemMapNode = databaseUDCDocumentItemMap.object[0]
            let parentUDCDocumentTypeIdName = udcDocumentItemMapNode.udcDocumentTypeIdName
            // If no document types in document then delete from current document type if found
            
            if fieldsMap["UDCDocumentItem.SearchDocument"] == nil {
                let _ = UDCDocumentItemMapNode.removeByDocument(udbcDatabaseOrm: udbcDatabaseOrm!, idName: "UDCDocumentItemMapNode.\(idName)", language: documentLanguage, udcDocumentTypeIdName: parentUDCDocumentTypeIdName, objectName: "UDCDocumentItem") as DatabaseOrmResult<UDCDocumentItemMapNode>
                continue
            }
            
            var foundParentDocumentTypeDocumentId = false
            for udcspgv in fieldsMap["UDCDocumentItem.SearchDocument"]! {
                if parentUDCDocumentTypeIdName == udcspgv.endCategoryId {
                    foundParentDocumentTypeDocumentId = true
                    break
                }
            }
            
            for chid in udcDocumentItemMapNode.childrenId {
                var foundDocumentId: Bool = false
                let databaseOrmResultGetIBasedOnId = UDCDocumentItemMapNode.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: chid)
                if databaseOrmResultGetIBasedOnId.databaseOrmError.count == 0 {
                    let parentDocument = databaseOrmResultGetIBasedOnId.object[0]
                    if parentDocument.udcDocumentId.count > 0 {
                        for udcspgv in fieldsMap["UDCDocumentItem.SearchDocument"]! {
                            let udcDocumentId = udcspgv.itemId
                            if udcDocumentId == parentDocument.udcDocumentId && parentUDCDocumentTypeIdName == udcspgv.endCategoryId {
                                foundDocumentId = true
                                break
                            }
                        }
                        if !foundDocumentId {
                            let databaseUDCDocumentItemMapNodeRemove = UDCDocumentItemMapNode.remove(udbcDatabaseOrm: udbcDatabaseOrm!, id: parentDocument._id) as DatabaseOrmResult<UDCDocumentMapNode>
                            if databaseUDCDocumentItemMapNodeRemove.databaseOrmError.count == 0 {
                                let _ = UDCDocumentItemMapNode.updatePull(udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentItemMapNode._id, childrenId: parentDocument._id) as DatabaseOrmResult<UDCDocumentItemMapNode>
                            }
                        }
                    }
                }
                
            }
            if !foundParentDocumentTypeDocumentId {
                continue
            }
        
            for udcspgv in fieldsMap["UDCDocumentItem.SearchDocument"]! {
                let udcDocumentTypeIdName: String = udcspgv.endCategoryId
                let udcDocumentId = udcspgv.itemId
                let databaseUDCDocumentItemMap = UDCDocumentItemMapNode.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentItemMapNode.childrenId, idName: "UDCDocumentItemMapNode.\(idName)", language: documentLanguage, udcDocumentTypeIdName: udcDocumentTypeIdName, objectName: "UDCDocumentItem", udcDocumentId: udcDocumentId)
                if parentUDCDocumentTypeIdName == udcspgv.endCategoryId {
                    // If not already found insert it
                    if databaseUDCDocumentItemMap.databaseOrmError.count > 0 {
                        let udcDocumentItemMapNodeChild = UDCDocumentItemMapNode()
                        udcDocumentItemMapNodeChild._id = try udbcDatabaseOrm!.generateId()
                        udcDocumentItemMapNodeChild.name = name
                        udcDocumentItemMapNodeChild.idName = "UDCDocumentItemMapNode.\(idName)"
                        udcDocumentItemMapNodeChild.level = 1
                        let databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, udcProfile: udcProfile, udcDocumentTypeIdName: "UDCDocumentType.DocumentItem", idName: "UDCDocument.\(idName)", language: documentLanguage)
                        if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
                            let databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, udcProfile: udcProfile, udcDocumentTypeIdName: "UDCDocumentType.DocumentItem", idName: "UDCDocument.\(idName)", language: "en")
                            udcDocumentItemMapNodeChild.objectId = [databaseOrmResultUDCDocument.object[0]._id]
                        } else {
                            udcDocumentItemMapNodeChild.objectId = [databaseOrmResultUDCDocument.object[0]._id]
                        }
                        udcDocumentItemMapNodeChild.udcDocumentId = udcDocumentId
                        udcDocumentItemMapNodeChild.objectName = "UDCDocumentItem"
                        udcDocumentItemMapNodeChild.udcDocumentTypeIdName = udcDocumentTypeIdName
                        udcDocumentItemMapNodeChild.pathIdName.append("UDCDocumentItemMapNode.DocumentItems")
                        udcDocumentItemMapNodeChild.pathIdName.append(udcDocumentItemMapNode.idName)
                        udcDocumentItemMapNodeChild.language = documentLanguage
                        udcDocumentItemMapNodeChild.parentId.append(udcDocumentItemMapNode._id)
                        udcDocumentItemMapNode.childrenId.append(udcDocumentItemMapNodeChild._id)
                        
                        // Save the child
                        let databaseUDCDocumentItemMapChildSave = UDCDocumentItemMapNode.save(udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentItemMapNodeChild)
                        if databaseUDCDocumentItemMapChildSave.databaseOrmError.count > 0 {
                            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseUDCDocumentItemMapChildSave.databaseOrmError[0].name, description: databaseUDCDocumentItemMapChildSave.databaseOrmError[0].description))
                            return
                        }
                        
                        // Save the parent
                        let databaseUDCDocumentItemMapChildUpdate = UDCDocumentItemMapNode.update(udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentItemMapNode)
                        if databaseUDCDocumentItemMapChildUpdate.databaseOrmError.count > 0 {
                            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseUDCDocumentItemMapChildUpdate.databaseOrmError[0].name, description: databaseUDCDocumentItemMapChildUpdate.databaseOrmError[0].description))
                            return
                        }
                    }
                }
            }
            
        }
    }
    
    private func getDocumentCategories(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let getDocumentCategoriesRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: GetDocumentCategoriesRequest())
        
        let documentLanguage = getDocumentCategoriesRequest.documentLanguage
        let interfaceLanguage = getDocumentCategoriesRequest.interfaceLanguage
        let databaseOrmUVCViewItemType = UVCViewItemType.get(udbcDatabaseOrm!, idName: "UVCViewItemType.Text", documentLanguage)
        if databaseOrmUVCViewItemType.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUVCViewItemType.databaseOrmError[0].name, description: databaseOrmUVCViewItemType.databaseOrmError[0].description))
            return
        }
        let uvcViewItemType = databaseOrmUVCViewItemType.object[0]
        
        let getDocumentCategoriesResponse = GetDocumentCategoriesResponse()
        let uvcOptionViewModel = UVCOptionViewModel()
        uvcOptionViewModel.level = 2
        uvcOptionViewModel.pathIdName.append(getDocumentCategoriesRequest.categoryOptionViewModel.pathIdName[0])
        uvcOptionViewModel.pathIdName[0].append(uvcViewItemType.idName)
        uvcOptionViewModel.objectIdName = "UDCSentencePattern.Text"
        uvcOptionViewModel.objectName = "UDCSentencePattern"
        uvcOptionViewModel.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: uvcViewItemType.name, description: "", category: "", subCategory: "", language: interfaceLanguage, isChildrenExist: false, isEditable: false, isCheckBox: false, photoId: nil, photoObjectName: nil)
        getDocumentCategoriesResponse.category.append(uvcOptionViewModel)
        
        let jsonUtilityGetDocumentCategoriesResponse = JsonUtility<GetDocumentCategoriesResponse>()
        let jsonGetDocumentCategoriesResponse = jsonUtilityGetDocumentCategoriesResponse.convertAnyObjectToJson(jsonObject: getDocumentCategoriesResponse)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonGetDocumentCategoriesResponse)
    }
    
    private func getDocumentCategoryOptions(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let getDocumentCategoryOptionsRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: GetDocumentCategoryOptionsRequest())
        
        let documentLanguage = getDocumentCategoryOptionsRequest.documentLanguage
        let interfaceLanguage = getDocumentCategoryOptionsRequest.interfaceLanguage
        
        var databaseOrmUVCViewItemType = UVCViewItemType.get(udbcDatabaseOrm!, idName: "UVCViewItemType.Text", interfaceLanguage)
        if databaseOrmUVCViewItemType.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUVCViewItemType.databaseOrmError[0].name, description: databaseOrmUVCViewItemType.databaseOrmError[0].description))
            return
        }
        let uvcViewItemTypeSentence = databaseOrmUVCViewItemType.object[0]
        
        
        let uvcOptionViewModelSentence = UVCOptionViewModel()
        uvcOptionViewModelSentence._id = (try udbcDatabaseOrm?.generateId())!
        uvcOptionViewModelSentence.level = 2
        uvcOptionViewModelSentence.pathIdName.append(getDocumentCategoryOptionsRequest.categoryOptionsOptionViewModel.pathIdName[0])
        uvcOptionViewModelSentence.pathIdName[0].append(uvcViewItemTypeSentence.idName)
        uvcOptionViewModelSentence.objectIdName = "UVCViewItemType.Text"
        uvcOptionViewModelSentence.objectName = "UVCViewItemType"
        uvcOptionViewModelSentence.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: uvcViewItemTypeSentence.name, description: "", category: "", subCategory: "", language: interfaceLanguage, isChildrenExist: true, isEditable: false, isCheckBox: false, photoId: nil, photoObjectName: nil)
        
        
        let getDocumentCategoryOptionsResponse = GetDocumentCategoryOptionsResponse()
        getDocumentCategoryOptionsResponse.categoryOption["UDCOptionMapNode.All"] = [uvcOptionViewModelSentence]
        let jsonUtilityGetDocumentCategoryOptionsResponse = JsonUtility<GetDocumentCategoryOptionsResponse>()
        let jsonGetDocumentCategoryOptionsResponse = jsonUtilityGetDocumentCategoryOptionsResponse.convertAnyObjectToJson(jsonObject: getDocumentCategoryOptionsResponse)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonGetDocumentCategoryOptionsResponse)
        
    }
    
    private func validateDeleteLineRequest(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let validateDocumentGraphItemForDeleteLineRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: ValidateDocumentGraphItemForDeleteLineRequest())
        
        var photoCount = 0
        var translationSeparatorIndex = 0
        for (udcspdgvIndex, udcspdgv) in validateDocumentGraphItemForDeleteLineRequest.deleteDocumentModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.enumerated() {
            if udcspdgv.uvcViewItemType == "UVCViewItemType.Photo" {
                photoCount += 1
            }
            if photoCount == 2 {
                if validateDocumentGraphItemForDeleteLineRequest.deleteDocumentModel.isChildrenAllowed {
                    translationSeparatorIndex = udcspdgvIndex + 1
                } else {
                    translationSeparatorIndex = udcspdgvIndex
                }
                break
            }
        }
        
        let textLocationNotAtStart = photoCount == 2
        
        let validateDocumentGraphItemForDeleteLineResponse = ValidateDocumentGraphItemForDeleteLineResponse()
        
        if validateDocumentGraphItemForDeleteLineRequest.documentGraphDeleteLineRequest.documentLanguage != "en" && textLocationNotAtStart {
            validateDocumentGraphItemForDeleteLineResponse.result = false
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "CannotDeleteThisLine", description: "Cannot delete this line"))
            return
        }
        
        let jsonUtilityValidateDocumentGraphItemForDeleteLineResponse = JsonUtility<ValidateDocumentGraphItemForDeleteLineResponse>()
        let jsonValidateDocumentGraphItemForDeleteLineResponse = jsonUtilityValidateDocumentGraphItemForDeleteLineResponse.convertAnyObjectToJson(jsonObject: validateDocumentGraphItemForDeleteLineResponse)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonValidateDocumentGraphItemForDeleteLineResponse)
    }
    
    private func validateDeleteRequest(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let validateDocumentGraphItemForDeleteRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: ValidateDocumentGraphItemForDeleteRequest())
        
        let validateDocumentGraphItemForDeleteResponse = ValidateDocumentGraphItemForDeleteResponse()
        validateDocumentGraphItemForDeleteResponse.result = true
        
        //        for udcspdg in validateDocumentGraphItemForDeleteRequest.deleteDocumentModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup {
        //            for udcspdgv in udcspdg.udcSentencePatternDataGroupValue {
        //                if udcspdgv.endCategory.contains(".FoodRecipeCategory") || udcspdgv.endCategory == "UDCGrammarItem.Title" {
        //                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "CannotDeleteThisItem", description: "Cannot Delete this item!"))
        //                    return
        //                }
        //            }`
        //        }
        if validateDocumentGraphItemForDeleteRequest.documentGraphDeleteItemRequest.nodeIndex == 0 {
            validateDocumentGraphItemForDeleteRequest.deleteDocumentModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.remove(at: validateDocumentGraphItemForDeleteRequest.documentGraphDeleteItemRequest.itemIndex)
            let udcGrammarUtility = UDCGrammarUtility()
            var udcSentencePattern = UDCSentencePattern()
            udcGrammarUtility.getSetencePattern(udcSentencePattern: &udcSentencePattern, udcSentencePatternDataGroupValue: validateDocumentGraphItemForDeleteRequest.deleteDocumentModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue)
            udcSentencePattern = try processGrammar(neuronRequest: neuronRequest, neuronResponse: &neuronResponse, udcSentencePattern: udcSentencePattern, documentLanguage: validateDocumentGraphItemForDeleteRequest.documentGraphDeleteItemRequest.documentLanguage, textStartIndex: 0)
            let uniqueTitle = "\(udcSentencePattern.sentence)"
            let possibleIdName = "UDCDocument.\(uniqueTitle.capitalized.trimmingCharacters(in: .whitespaces))"
            let databaseOrmResultUDCDocumentCheck = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!,  udcProfile: validateDocumentGraphItemForDeleteRequest.documentGraphDeleteItemRequest.udcProfile,  idName: possibleIdName, udcDocumentTypeIdName: validateDocumentGraphItemForDeleteRequest.udcDocumentTypeIdName, notEqualsDocumentGroupId: validateDocumentGraphItemForDeleteRequest.udcDocument!.documentGroupId)
            if databaseOrmResultUDCDocumentCheck.databaseOrmError.count == 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "SameDocumentNameAlreadyExists", description: "Same document name already exists"))
                return
            }
        }
        
        let jsonUtilityValidateDocumentGraphItemForDeleteResponse = JsonUtility<ValidateDocumentGraphItemForDeleteResponse>()
        let jsonValidateDocumentGraphItemForDeleteResponse = jsonUtilityValidateDocumentGraphItemForDeleteResponse.convertAnyObjectToJson(jsonObject: validateDocumentGraphItemForDeleteResponse)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonValidateDocumentGraphItemForDeleteResponse)
    }
   
    private func validateInsertRequest(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let validateDocumentGraphItemForInsertRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: ValidateDocumentGraphItemForInsertRequest())
        let documentLanguage = validateDocumentGraphItemForInsertRequest.documentGraphInsertItemRequest.documentLanguage
        let validateDocumentGraphItemForInsertResponse = ValidateDocumentGraphItemForInsertResponse()
        var result = true
        
        var udcSentencePatternGroupValue = [UDCSentencePatternDataGroupValue]()
        if validateDocumentGraphItemForInsertRequest.udcSentencePatternDataGroupValue == nil || validateDocumentGraphItemForInsertRequest.udcSentencePatternDataGroupValue!.count == 0 {
            udcSentencePatternGroupValue = try getSentencePatternDataGroupValue(optionItemObjectName: validateDocumentGraphItemForInsertRequest.documentGraphInsertItemRequest.optionItemObjectName, optionItemIdName: validateDocumentGraphItemForInsertRequest.documentGraphInsertItemRequest.optionItemId, neuronResponse: &neuronResponse, language: documentLanguage)
            if udcSentencePatternGroupValue.count == 0 {
                if validateDocumentGraphItemForInsertRequest.documentGraphInsertItemRequest.optionItemId == "UDCSentencePattern.Text" {
                    let udcSentencePatternDataGroupValueLocal = UDCSentencePatternDataGroupValue()
                    udcSentencePatternDataGroupValueLocal.item = validateDocumentGraphItemForInsertRequest.documentGraphInsertItemRequest.item
                    udcSentencePatternDataGroupValueLocal.itemId = ""
                    udcSentencePatternDataGroupValueLocal.category = "UDCGrammarCategory.CommonNoun"
                    udcSentencePatternDataGroupValueLocal.endCategoryIdName = "UDCDocumentItem.General"
                    udcSentencePatternDataGroupValueLocal.uvcViewItemType = "UVCViewItemType.Text"
                    udcSentencePatternGroupValue = [UDCSentencePatternDataGroupValue]()
                    udcSentencePatternGroupValue.append(udcSentencePatternDataGroupValueLocal)
                }
            }
        } else {
            udcSentencePatternGroupValue.append(contentsOf: validateDocumentGraphItemForInsertRequest.udcSentencePatternDataGroupValue!)
        }
        
        validateDocumentGraphItemForInsertRequest.insertDocumentModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.insert(udcSentencePatternGroupValue[0], at: validateDocumentGraphItemForInsertRequest.documentGraphInsertItemRequest.itemIndex)
        
        var udcSentencePatternDataGroupValueFromParser = [UDCSentencePatternDataGroupValue]()
        var fieldFound = false
        var fieldIdName: String = ""
        var parentIdName: String = ""
        documentParser.getCurrentFieldValue(udcDocumentGraphModel: validateDocumentGraphItemForInsertRequest.insertDocumentModel, currentValue: validateDocumentGraphItemForInsertRequest.documentGraphInsertItemRequest.item, fieldValue: &udcSentencePatternDataGroupValueFromParser, fieldIdName: &fieldIdName, fieldFound: &fieldFound, parentName: &parentIdName, udcDocumentTypeIdName: validateDocumentGraphItemForInsertRequest.documentGraphInsertItemRequest.udcDocumentTypeIdName)
        
        if fieldIdName == "UDCDocumentItem.SearchDocumentType" || fieldIdName == "UDCDocumentItem.EditDocumentType" {
            // Check if valid values found, else throw error
            for udcspdgv in udcSentencePatternDataGroupValueFromParser {
                if udcspdgv.endCategoryIdName != "UDCDocumentItem.DocumentType" {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "InvalidValue", description: "Invalid value!"))
                    return
                }
            }
            
        } else if fieldIdName == "UDCDocumentItem.PhotoSize" {
            // Check if valid values found, else throw error
            for udcspdgv in udcSentencePatternDataGroupValueFromParser {
                if !udcspdgv.endCategoryIdName.hasPrefix("UDCDocumentItem") || !udcspdgv.endCategoryIdName.hasSuffix("PhotoSize") {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "InvalidValue", description: "Invalid value!"))
                    return
                }
            }
        }
        
        let jsonUtilityValidateDocumentGraphItemForInsertResponse = JsonUtility<ValidateDocumentGraphItemForInsertResponse>()
        let jsonValidateDocumentGraphItemForInsertResponse = jsonUtilityValidateDocumentGraphItemForInsertResponse.convertAnyObjectToJson(jsonObject: validateDocumentGraphItemForInsertResponse)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonValidateDocumentGraphItemForInsertResponse)
    }
    
    private func getSentencePatternForDocumentItem(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let getSentencePatternForDocumentItemRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: GetGraphSentencePatternForDocumentItemRequest())
        
        let documentLanguage = getSentencePatternForDocumentItemRequest.documentLanguage
        var udcSentencePatternDataGroupValue: [UDCSentencePatternDataGroupValue]?
        if getSentencePatternForDocumentItemRequest.udcSentencePatternDataGroupValue == nil {
            if !getSentencePatternForDocumentItemRequest.isGeneratedItem {
                udcSentencePatternDataGroupValue = try getSentencePatternDataGroupValue(optionItemObjectName: getSentencePatternForDocumentItemRequest.documentItemObjectName, optionItemIdName: getSentencePatternForDocumentItemRequest.documentItemIdName, neuronResponse: &neuronResponse, language: documentLanguage)
            } else {
                if getSentencePatternForDocumentItemRequest.documentItemIdName == "UDCSentencePattern.Text" {
                    let udcSentencePatternDataGroupValueLocal = UDCSentencePatternDataGroupValue()
                    udcSentencePatternDataGroupValueLocal.item = getSentencePatternForDocumentItemRequest.item
                    udcSentencePatternDataGroupValueLocal.itemId = ""
                    udcSentencePatternDataGroupValueLocal.category = "UDCGrammarCategory.CommonNoun"
                    udcSentencePatternDataGroupValueLocal.endCategoryIdName = "UDCDocumentItem.General"
                    udcSentencePatternDataGroupValueLocal.uvcViewItemType = "UVCViewItemType.Text"
                    udcSentencePatternDataGroupValue = [UDCSentencePatternDataGroupValue]()
                    udcSentencePatternDataGroupValue!.append(udcSentencePatternDataGroupValueLocal)
                }
                //            else if getSentencePatternForDocumentItemRequest.documentItemIdName == "UDCSentencePattern.Photo" {
                //                let udcSentencePatternDataGroupValueLocal = UDCSentencePatternDataGroupValue()
                //                udcSentencePatternDataGroupValueLocal.item = getSentencePatternForDocumentItemRequest.item
                //                udcSentencePatternDataGroupValueLocal.itemIdName = ""
                //                udcSentencePatternDataGroupValueLocal.category = "UDCGrammarCategory.CommonNoun"
                //                udcSentencePatternDataGroupValueLocal.endCategory = "UDCDocumentItem.General"
                //                udcSentencePatternDataGroupValueLocal.uvcViewItemType = "UVCViewItemType.Photo"
                //                udcSentencePatternDataGroupValue = [UDCSentencePatternDataGroupValue]()
                //                udcSentencePatternDataGroupValue!.append(udcSentencePatternDataGroupValueLocal)
                //            }
            }
        } else {
            udcSentencePatternDataGroupValue = getSentencePatternForDocumentItemRequest.udcSentencePatternDataGroupValue
        }
        if !getSentencePatternForDocumentItemRequest.uvcViewItemType.isEmpty && udcSentencePatternDataGroupValue![0].uvcViewItemType != "UVCViewItemType.Photo" {
            udcSentencePatternDataGroupValue![0].uvcViewItemType = getSentencePatternForDocumentItemRequest.uvcViewItemType
        }
        
        let getSentencePatternForDocumentItemResponse = GetGraphSentencePatternForDocumentItemResponse()
        getSentencePatternForDocumentItemResponse.udcSentencePattern.udcSentencePatternData.append(UDCSentencePatternData())
        getSentencePatternForDocumentItemResponse.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup.append(UDCSentencePatternDataGroup())
        getSentencePatternForDocumentItemResponse.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.append(contentsOf: udcSentencePatternDataGroupValue!)
        
        let jsonUtilityGetSentencePatternForDocumentItemResponse = JsonUtility<GetGraphSentencePatternForDocumentItemResponse>()
        let jsonGetSentencePatternForDocumentItemResponse = jsonUtilityGetSentencePatternForDocumentItemResponse.convertAnyObjectToJson(jsonObject: getSentencePatternForDocumentItemResponse)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonGetSentencePatternForDocumentItemResponse)
        //        let getSentencePatternForDocumentItemRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: GetSentencePatternForDocumentItemRequest())
        //
        //        let documentLanguage = getSentencePatternForDocumentItemRequest.documentLanguage
        //
        //
        //        if !getSentencePatternForDocumentItemRequest.isGeneratedItem {
        //        let udcSetnencePatternDataGroupValue = try getSentencePatternDataGroupValue(optionItemObjectName: getSentencePatternForDocumentItemRequest.documentItemObjectName, optionItemIdName: getSentencePatternForDocumentItemRequest.documentItemIdName, neuronResponse: &neuronResponse, language: documentLanguage)
        //        }
        //        if !getSentencePatternForDocumentItemRequest.uvcViewItemType.isEmpty && udcSetnencePatternDataGroupValue[0].uvcViewItemType != "UVCViewItemType.Photo" {
        //            udcSetnencePatternDataGroupValue[0].uvcViewItemType = getSentencePatternForDocumentItemRequest.uvcViewItemType
        //        }
        //
        //        let getSentencePatternForDocumentItemResponse = GetSentencePatternForDocumentItemResponse()
        //        getSentencePatternForDocumentItemResponse.udcSentencePattern.udcSentencePatternData.append(UDCSentencePatternData())
        //        getSentencePatternForDocumentItemResponse.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup.append(UDCSentencePatternDataGroup())
        //        getSentencePatternForDocumentItemResponse.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.append(contentsOf: udcSetnencePatternDataGroupValue)
        //
        //        let jsonUtilityGetSentencePatternForDocumentItemResponse = JsonUtility<GetSentencePatternForDocumentItemResponse>()
        //        let jsonGetSentencePatternForDocumentItemResponse = jsonUtilityGetSentencePatternForDocumentItemResponse.convertAnyObjectToJson(jsonObject: getSentencePatternForDocumentItemResponse)
        //        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonGetSentencePatternForDocumentItemResponse)
    }
    
    
    private func getDocumentIdName(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let getDocumentGraphIdNameRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: GetDocumentGraphIdNameRequest())
        
        let getDocumentGraphIdNameResponse = GetDocumentGraphIdNameResponse()
        
        if getDocumentGraphIdNameRequest.udcDocumentGraphModel.level <= 1 {
            let databaseOrmUDCDocumentItemMapNode = UDCDocumentItemMapNode.get("UDCDocumentItemMapNode.Untitled", udbcDatabaseOrm!, getDocumentGraphIdNameRequest.documentLanguage)
            if databaseOrmUDCDocumentItemMapNode.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentItemMapNode.databaseOrmError[0].name, description: databaseOrmUDCDocumentItemMapNode.databaseOrmError[0].description))
                return
            }
            let untitledItem = databaseOrmUDCDocumentItemMapNode.object[0]
            let name = "\(untitledItem.name)".capitalized
            let untitltedIdNamePrefix = "\(neuronUtility!.getCollectionName(udcDocumentTypeIdName: getDocumentGraphIdNameRequest.udcDocumentTypeIdName)!).\(name)"
            
            getDocumentGraphIdNameResponse.name = getDocumentGraphIdNameRequest.udcDocumentGraphModel.udcSentencePattern.sentence
            if getDocumentGraphIdNameRequest.udcDocumentGraphModel.level == 1 {
                
                if !getDocumentGraphIdNameRequest.udcDocumentGraphModel.idName.contains(untitltedIdNamePrefix) && getDocumentGraphIdNameRequest.udcDocumentGraphModel.language != "en" {
                    getDocumentGraphIdNameResponse.idName = getDocumentGraphIdNameRequest.udcDocumentGraphModel.idName
                } else {
                    getDocumentGraphIdNameResponse.idName = "\(neuronUtility!.getCollectionName(udcDocumentTypeIdName: getDocumentGraphIdNameRequest.udcDocumentTypeIdName)!).\(getDocumentGraphIdNameRequest.udcDocumentGraphModel.udcSentencePattern.sentence.capitalized.replacingOccurrences(of: " ", with: ""))"
                }
            } else {
                getDocumentGraphIdNameResponse.idName = "\(neuronUtility!.getCollectionName(udcDocumentTypeIdName: getDocumentGraphIdNameRequest.udcDocumentTypeIdName)!).\(getDocumentGraphIdNameRequest.udcDocumentGraphModel.udcSentencePattern.sentence.capitalized.replacingOccurrences(of: " ", with: ""))"
            }
            if getDocumentGraphIdNameResponse.idName == "\(neuronUtility!.getCollectionName(udcDocumentTypeIdName: getDocumentGraphIdNameRequest.udcDocumentTypeIdName)!)." {
                let generatedId = NSUUID().uuidString
                getDocumentGraphIdNameResponse.idName = "\(untitltedIdNamePrefix)-\(generatedId)"
                getDocumentGraphIdNameResponse.name = "\(name).\(generatedId)"
            }
            
        } else {
            getDocumentGraphIdNameResponse.name = getDocumentGraphIdNameRequest.udcDocumentGraphModel.name
        }
        
        let jsonUtilityGetDocumentGraphIdNameResponse = JsonUtility<GetDocumentGraphIdNameResponse>()
        let jsonValidateGetDocumentGraphIdNameResponse = jsonUtilityGetDocumentGraphIdNameResponse.convertAnyObjectToJson(jsonObject: getDocumentGraphIdNameResponse)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonValidateGetDocumentGraphIdNameResponse)
    }
    
    private func getSentencePatternDataGroupValue(optionItemObjectName: String, optionItemIdName: String, neuronResponse: inout NeuronRequest, language: String) throws -> [UDCSentencePatternDataGroupValue] {
        
        var udcSentencePatternDataGroupValueArray = [UDCSentencePatternDataGroupValue]()
        let udcSentencePatternDataGroupValue = UDCSentencePatternDataGroupValue()
        udcSentencePatternDataGroupValue.itemType = "UDCJson.String"
        
        /*if optionItemObjectName == "UDCPhotoDocument" {
            let databaseOrmResultParent = UDCDocumentGraphModel.get(collectionName: optionItemObjectName, udbcDatabaseOrm: udbcDatabaseOrm!, id: optionItemIdName, language: language)
            if databaseOrmResultParent.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultParent.databaseOrmError[0].name, description: databaseOrmResultParent.databaseOrmError[0].description))
                udcSentencePatternDataGroupValueArray.append(udcSentencePatternDataGroupValue)
                return udcSentencePatternDataGroupValueArray
            }
            let udcPhotoDocument = databaseOrmResultParent.object[0]
            let databaseOrmResultType = UDCPhoto.get(collectionName: "\(optionItemObjectName)Photo", udbcDatabaseOrm: udbcDatabaseOrm!, id: udcPhotoDocument.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].itemId)
            if databaseOrmResultType.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultType.databaseOrmError[0].name, description: databaseOrmResultType.databaseOrmError[0].description))
                udcSentencePatternDataGroupValueArray.append(udcSentencePatternDataGroupValue)
                return udcSentencePatternDataGroupValueArray
            }
            let type = databaseOrmResultType.object[0]
            udcSentencePatternDataGroupValue.item = ""
            udcSentencePatternDataGroupValue.itemId = type._id
            udcSentencePatternDataGroupValue.itemState = ""
            udcSentencePatternDataGroupValue.uvcViewItemType = "UVCViewItemType.Photo"
            udcSentencePatternDataGroupValue.category = "UDCGrammarCategory.ProperNoun"
            udcSentencePatternDataGroupValue.endCategoryIdName = "UDCDocumentItemMapNode.PhotoDocument"
            udcSentencePatternDataGroupValue.endSubCategoryId = udcPhotoDocument.parentId[0]
        } else if optionItemObjectName == "UDCIngredient" {
            let databaseOrmResultType = UDCIngredientType.get(idName: optionItemIdName, udbcDatabaseOrm!, language)
            if databaseOrmResultType.databaseOrmError.count > 0 {
                let udcDatabaseOrmTypePattern = try UDCWordPatternType.get(idName: optionItemIdName, udbcDatabaseOrm!, language)
                if udcDatabaseOrmTypePattern.databaseOrmError.count > 0 { neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultType.databaseOrmError[0].name, description: databaseOrmResultType.databaseOrmError[0].description))
                    udcSentencePatternDataGroupValueArray.append(udcSentencePatternDataGroupValue)
                    return udcSentencePatternDataGroupValueArray
                } else {
                    let typePattern = udcDatabaseOrmTypePattern.object[0]
                    udcSentencePatternDataGroupValue.item = typePattern.name
                    udcSentencePatternDataGroupValue.itemId = typePattern.idName
                    udcSentencePatternDataGroupValue.itemState = ""
                    udcSentencePatternDataGroupValue.category = ""
                    udcSentencePatternDataGroupValue.endCategoryIdName = "UDCDocumentItemMapNode.Ingredient"
                    udcSentencePatternDataGroupValueArray.append(udcSentencePatternDataGroupValue)
                    return udcSentencePatternDataGroupValueArray
                }
            }
            let type = databaseOrmResultType.object[0]
            udcSentencePatternDataGroupValue.item = type.name
            udcSentencePatternDataGroupValue.itemId = type.idName
            udcSentencePatternDataGroupValue.itemState = type.udcItemStateIdName
            udcSentencePatternDataGroupValue.category = type.grammarCategory
            udcSentencePatternDataGroupValue.endCategoryIdName = "UDCDocumentItemMapNode.Ingredient"
            let databaseOrmResultUDCIngredientCategoryType = UDCIngredientCategoryType.get(type.udcIngredientCategoryIdName, udbcDatabaseOrm!, language)
            if databaseOrmResultUDCIngredientCategoryType.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCIngredientCategoryType.databaseOrmError[0].name, description: databaseOrmResultUDCIngredientCategoryType.databaseOrmError[0].description))
                udcSentencePatternDataGroupValueArray.append(udcSentencePatternDataGroupValue)
                return udcSentencePatternDataGroupValueArray
            }
            let subCategory = databaseOrmResultUDCIngredientCategoryType.object[0].idName
            udcSentencePatternDataGroupValue.endSubCategoryId = subCategory
        } else if optionItemObjectName == "UDCTimeUnit" {
            let databaseOrmResultType = UDCTimeUnitType.get(idName: optionItemIdName, udbcDatabaseOrm!, language)
            if databaseOrmResultType.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultType.databaseOrmError[0].name, description: databaseOrmResultType.databaseOrmError[0].description))
                udcSentencePatternDataGroupValueArray.append(udcSentencePatternDataGroupValue)
                return udcSentencePatternDataGroupValueArray
            }
            let type = databaseOrmResultType.object[0]
            udcSentencePatternDataGroupValue.item = type.name
            udcSentencePatternDataGroupValue.itemId = type.idName
            udcSentencePatternDataGroupValue.category = type.udcGrammarCategory
            udcSentencePatternDataGroupValue.endCategoryIdName = "UDCDocumentItemMapNode.TimeUnit"
        } else if optionItemObjectName == "UDCMassUnit" {
            let databaseOrmResultType = UDCMassUnitType.get(idName: optionItemIdName, udbcDatabaseOrm!, language)
            if databaseOrmResultType.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultType.databaseOrmError[0].name, description: databaseOrmResultType.databaseOrmError[0].description))
                udcSentencePatternDataGroupValueArray.append(udcSentencePatternDataGroupValue)
                return udcSentencePatternDataGroupValueArray
            }
            let type = databaseOrmResultType.object[0]
            udcSentencePatternDataGroupValue.item = type.name
            udcSentencePatternDataGroupValue.itemId = type.idName
            udcSentencePatternDataGroupValue.category = type.udcGrammarCategory
            udcSentencePatternDataGroupValue.endCategoryIdName = "UDCDocumentItemMapNode.MassUnit"
        } else if optionItemObjectName == "UDCVolumeUnit" {
            let databaseOrmResultType = UDCVolumeUnitType.get(idName: optionItemIdName, udbcDatabaseOrm!, language)
            if databaseOrmResultType.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultType.databaseOrmError[0].name, description: databaseOrmResultType.databaseOrmError[0].description))
                udcSentencePatternDataGroupValueArray.append(udcSentencePatternDataGroupValue)
                return udcSentencePatternDataGroupValueArray
            }
            let type = databaseOrmResultType.object[0]
            udcSentencePatternDataGroupValue.item = type.name
            udcSentencePatternDataGroupValue.itemId = type.idName
            udcSentencePatternDataGroupValue.category = type.udcGrammarCategory
            udcSentencePatternDataGroupValue.endCategoryIdName = "UDCDocumentItemMapNode.VolumeUnit"
        } else if optionItemObjectName == "UDCTemperatureUnit" {
            let databaseOrmResultType = UDCTemperatureUnitType.get(idName: optionItemIdName, udbcDatabaseOrm!, language)
            if databaseOrmResultType.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultType.databaseOrmError[0].name, description: databaseOrmResultType.databaseOrmError[0].description))
                udcSentencePatternDataGroupValueArray.append(udcSentencePatternDataGroupValue)
                return udcSentencePatternDataGroupValueArray
            }
            let type = databaseOrmResultType.object[0]
            udcSentencePatternDataGroupValue.item = type.name
            udcSentencePatternDataGroupValue.itemId = type.idName
            udcSentencePatternDataGroupValue.category = type.udcGrammarCategory
            udcSentencePatternDataGroupValue.endCategoryIdName = "UDCDocumentItemMapNode.TemperatureUnit"
        } else if optionItemObjectName == "UDCLengthUnit" {
            let databaseOrmResultType = UDCLengthUnitType.get(idName: optionItemIdName, udbcDatabaseOrm!, language)
            if databaseOrmResultType.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultType.databaseOrmError[0].name, description: databaseOrmResultType.databaseOrmError[0].description))
                udcSentencePatternDataGroupValueArray.append(udcSentencePatternDataGroupValue)
                return udcSentencePatternDataGroupValueArray
            }
            let type = databaseOrmResultType.object[0]
            udcSentencePatternDataGroupValue.item = type.name
            udcSentencePatternDataGroupValue.itemId = type.idName
            udcSentencePatternDataGroupValue.category = type.udcGrammarCategory
            udcSentencePatternDataGroupValue.endCategoryIdName = "UDCDocumentItemMapNode.LengthUnit"
        } else if optionItemObjectName == "UDCFoodCutting" {
            let databaseOrmResultType = UDCFoodCuttingType.get(idName: optionItemIdName, udbcDatabaseOrm!, language)
            if databaseOrmResultType.databaseOrmError.count > 0 {
                let udcDatabaseOrmTypePattern = try UDCWordPatternType.get(idName: optionItemIdName, udbcDatabaseOrm!, language)
                if udcDatabaseOrmTypePattern.databaseOrmError.count > 0 { neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultType.databaseOrmError[0].name, description: databaseOrmResultType.databaseOrmError[0].description))
                    udcSentencePatternDataGroupValueArray.append(udcSentencePatternDataGroupValue)
                    return udcSentencePatternDataGroupValueArray
                } else {
                    let typePattern = udcDatabaseOrmTypePattern.object[0]
                    udcSentencePatternDataGroupValue.item = typePattern.name
                    udcSentencePatternDataGroupValue.itemId = typePattern.idName
                    udcSentencePatternDataGroupValue.itemState = ""
                    udcSentencePatternDataGroupValue.category = ""
                    udcSentencePatternDataGroupValue.endCategoryIdName = "UDCDocumentItemMapNode.FoodCutting"
                    udcSentencePatternDataGroupValueArray.append(udcSentencePatternDataGroupValue)
                    return udcSentencePatternDataGroupValueArray
                }
            }
            let type = databaseOrmResultType.object[0]
            udcSentencePatternDataGroupValue.item = type.name
            udcSentencePatternDataGroupValue.itemId = type.idName
            udcSentencePatternDataGroupValue.category = type.grammarCategory
            udcSentencePatternDataGroupValue.endCategoryIdName = "UDCDocumentItemMapNode.FoodCutting"
        } else if optionItemObjectName == "UDCItemState" {
            let databaseOrmResultType = UDCItemStateType.get(idName: optionItemIdName, udbcDatabaseOrm!, language)
            if databaseOrmResultType.databaseOrmError.count > 0 {
                let udcDatabaseOrmTypePattern = try UDCWordPatternType.get(idName: optionItemIdName, udbcDatabaseOrm!, language)
                if udcDatabaseOrmTypePattern.databaseOrmError.count > 0 { neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultType.databaseOrmError[0].name, description: databaseOrmResultType.databaseOrmError[0].description))
                    udcSentencePatternDataGroupValueArray.append(udcSentencePatternDataGroupValue)
                    return udcSentencePatternDataGroupValueArray
                } else {
                    let typePattern = udcDatabaseOrmTypePattern.object[0]
                    udcSentencePatternDataGroupValue.item = typePattern.name
                    udcSentencePatternDataGroupValue.itemId = typePattern.idName
                    udcSentencePatternDataGroupValue.itemState = ""
                    udcSentencePatternDataGroupValue.category = ""
                    udcSentencePatternDataGroupValue.endCategoryIdName = "UDCDocumentItemMapNode.ItemState"
                    udcSentencePatternDataGroupValueArray.append(udcSentencePatternDataGroupValue)
                    return udcSentencePatternDataGroupValueArray
                }
            }
            let type = databaseOrmResultType.object[0]
            udcSentencePatternDataGroupValue.item = type.name
            udcSentencePatternDataGroupValue.itemId = type.idName
            udcSentencePatternDataGroupValue.category = type.grammarCategory
            udcSentencePatternDataGroupValue.endCategoryIdName = "UDCDocumentItemMapNode.ItemState"
        } else if optionItemObjectName == "UDCCookingDevice" {
            let databaseOrmResultType = UDCCookingDeviceType.get(idName: optionItemIdName, udbcDatabaseOrm!, language)
            if databaseOrmResultType.databaseOrmError.count > 0 {
                let udcDatabaseOrmTypePattern = try UDCWordPatternType.get(idName: optionItemIdName, udbcDatabaseOrm!, language)
                if udcDatabaseOrmTypePattern.databaseOrmError.count > 0 { neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultType.databaseOrmError[0].name, description: databaseOrmResultType.databaseOrmError[0].description))
                    udcSentencePatternDataGroupValueArray.append(udcSentencePatternDataGroupValue)
                    return udcSentencePatternDataGroupValueArray
                } else {
                    let typePattern = udcDatabaseOrmTypePattern.object[0]
                    udcSentencePatternDataGroupValue.item = typePattern.name
                    udcSentencePatternDataGroupValue.itemId = typePattern.idName
                    udcSentencePatternDataGroupValue.itemState = ""
                    udcSentencePatternDataGroupValue.category = ""
                    udcSentencePatternDataGroupValue.endCategoryIdName = "UDCDocumentItemMapNode.CookingDevice"
                    udcSentencePatternDataGroupValueArray.append(udcSentencePatternDataGroupValue)
                    return udcSentencePatternDataGroupValueArray
                }
            }
            let type = databaseOrmResultType.object[0]
            udcSentencePatternDataGroupValue.item = type.name
            udcSentencePatternDataGroupValue.itemId = type.idName
            udcSentencePatternDataGroupValue.category = type.grammarCategory
            udcSentencePatternDataGroupValue.endCategoryIdName = "UDCDocumentItemMapNode.CookingDevice"
        }  else if optionItemObjectName == "UDCGrammarItem" {
            let databaseOrmResultType = UDCGrammarItemType.get(idName: optionItemIdName, udbcDatabaseOrm!, language)
            if databaseOrmResultType.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultType.databaseOrmError[0].name, description: databaseOrmResultType.databaseOrmError[0].description))
                udcSentencePatternDataGroupValueArray.append(udcSentencePatternDataGroupValue)
                return udcSentencePatternDataGroupValueArray
            }
            let type = databaseOrmResultType.object[0]
            udcSentencePatternDataGroupValue.item = type.name
            udcSentencePatternDataGroupValue.itemId = type.idName
            udcSentencePatternDataGroupValue.category = type.udcGrammarCategoryIdName.joined(separator: ", ")
            udcSentencePatternDataGroupValue.endCategoryIdName = "UDCDocumentItem.General"
            udcSentencePatternDataGroupValue.endSubCategoryId = type.udcGrammarCategoryIdName[0]
        } else if optionItemObjectName == "UDCCookingTechnique" {
            let databaseOrmResultType = UDCCookingTechniqueType.get(idName: optionItemIdName, udbcDatabaseOrm!, language)
            if databaseOrmResultType.databaseOrmError.count > 0 {
                let udcDatabaseOrmTypePattern = try UDCWordPatternType.get(idName: optionItemIdName, udbcDatabaseOrm!, language)
                if udcDatabaseOrmTypePattern.databaseOrmError.count > 0 { neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultType.databaseOrmError[0].name, description: databaseOrmResultType.databaseOrmError[0].description))
                    udcSentencePatternDataGroupValueArray.append(udcSentencePatternDataGroupValue)
                    return udcSentencePatternDataGroupValueArray
                } else {
                    let typePattern = udcDatabaseOrmTypePattern.object[0]
                    udcSentencePatternDataGroupValue.item = typePattern.name
                    udcSentencePatternDataGroupValue.itemId = typePattern.idName
                    udcSentencePatternDataGroupValue.itemState = ""
                    udcSentencePatternDataGroupValue.category = ""
                    udcSentencePatternDataGroupValue.endCategoryIdName = "UDCDocumentItemMapNode.CookingTechnique"
                    udcSentencePatternDataGroupValueArray.append(udcSentencePatternDataGroupValue)
                    return udcSentencePatternDataGroupValueArray
                }
            }
            let type = databaseOrmResultType.object[0]
            udcSentencePatternDataGroupValue.item = type.name
            udcSentencePatternDataGroupValue.itemId = type.idName
            udcSentencePatternDataGroupValue.category = type.grammarCategory
            udcSentencePatternDataGroupValue.endCategoryIdName = "UDCDocumentItemMapNode.CookingTechnique"
        } else if optionItemObjectName == "UDCFoodRecipeCategory" {
            let databaseOrmResultType = UDCFoodRecipeCategoryType.get(idName: optionItemIdName, udbcDatabaseOrm!, language)
            if databaseOrmResultType.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultType.databaseOrmError[0].name, description: databaseOrmResultType.databaseOrmError[0].description))
                udcSentencePatternDataGroupValueArray.append(udcSentencePatternDataGroupValue)
                return udcSentencePatternDataGroupValueArray
            }
            let type = databaseOrmResultType.object[0]
            udcSentencePatternDataGroupValue.item = type.name
            udcSentencePatternDataGroupValue.itemId = type.idName
            udcSentencePatternDataGroupValue.category = type.udcGrammarCategory
            udcSentencePatternDataGroupValue.endCategoryIdName = "UDCDocumentItemMapNode.FoodRecipeCategory"
        } else if optionItemObjectName == "UDCFoodRecipeItem" {
            let databaseOrmResultType = UDCFoodRecipeItemType.get(idName: optionItemIdName, udbcDatabaseOrm!, language)
            if databaseOrmResultType.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultType.databaseOrmError[0].name, description: databaseOrmResultType.databaseOrmError[0].description))
                udcSentencePatternDataGroupValueArray.append(udcSentencePatternDataGroupValue)
                return udcSentencePatternDataGroupValueArray
            }
            let type = databaseOrmResultType.object[0]
            udcSentencePatternDataGroupValue.item = type.name
            udcSentencePatternDataGroupValue.itemId = type.idName
            udcSentencePatternDataGroupValue.category = type.udcGrammarCategory
            udcSentencePatternDataGroupValue.endCategoryIdName = "UDCDocumentItemMapNode.FoodRecipeItem"
        } else if optionItemObjectName == "UDCContinent" {
            let databaseOrmResultType = UDCContinentType.get(idName: optionItemIdName, udbcDatabaseOrm!, language)
            if databaseOrmResultType.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultType.databaseOrmError[0].name, description: databaseOrmResultType.databaseOrmError[0].description))
                udcSentencePatternDataGroupValueArray.append(udcSentencePatternDataGroupValue)
                return udcSentencePatternDataGroupValueArray
            }
            let type = databaseOrmResultType.object[0]
            udcSentencePatternDataGroupValue.item = type.name
            udcSentencePatternDataGroupValue.itemId = type.idName
            udcSentencePatternDataGroupValue.category = type.udcGrammarCategory
            udcSentencePatternDataGroupValue.endCategoryIdName = "UDCDocumentItemMapNode.Continent"
        } else if optionItemObjectName == "UDCCountry" {
            let databaseOrmResultType = UDCCountryType.get(idName: optionItemIdName, udbcDatabaseOrm!, language)
            if databaseOrmResultType.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultType.databaseOrmError[0].name, description: databaseOrmResultType.databaseOrmError[0].description))
                udcSentencePatternDataGroupValueArray.append(udcSentencePatternDataGroupValue)
                return udcSentencePatternDataGroupValueArray
            }
            let type = databaseOrmResultType.object[0]
            udcSentencePatternDataGroupValue.item = type.name
            udcSentencePatternDataGroupValue.itemId = type.idName
            udcSentencePatternDataGroupValue.category = type.udcGrammarCategory
            udcSentencePatternDataGroupValue.endCategoryIdName = "UDCDocumentItemMapNode.Country"
        } else if optionItemObjectName == "UDCState" {
            let databaseOrmResultType = UDCCountryType.get(idName: optionItemIdName, udbcDatabaseOrm!, language)
            if databaseOrmResultType.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultType.databaseOrmError[0].name, description: databaseOrmResultType.databaseOrmError[0].description))
                udcSentencePatternDataGroupValueArray.append(udcSentencePatternDataGroupValue)
                return udcSentencePatternDataGroupValueArray
            }
            let type = databaseOrmResultType.object[0]
            udcSentencePatternDataGroupValue.item = type.name
            udcSentencePatternDataGroupValue.itemId = type.idName
            udcSentencePatternDataGroupValue.category = type.udcGrammarCategory
            udcSentencePatternDataGroupValue.endCategoryIdName = "UDCDocumentItemMapNode.State"
        } else if optionItemObjectName == "UDCCity" {
            let databaseOrmResultType = UDCCityType.get(idName: optionItemIdName, udbcDatabaseOrm!, language)
            if databaseOrmResultType.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultType.databaseOrmError[0].name, description: databaseOrmResultType.databaseOrmError[0].description))
                udcSentencePatternDataGroupValueArray.append(udcSentencePatternDataGroupValue)
                return udcSentencePatternDataGroupValueArray
            }
            let type = databaseOrmResultType.object[0]
            udcSentencePatternDataGroupValue.item = type.name
            udcSentencePatternDataGroupValue.itemId = type.idName
            udcSentencePatternDataGroupValue.category = type.udcGrammarCategory
            udcSentencePatternDataGroupValue.endCategoryIdName = "UDCDocumentItemMapNode.City"
        } else if optionItemObjectName == "UDCDistrict" {
            let databaseOrmResultType = UDCDistrictType.get(idName: optionItemIdName, udbcDatabaseOrm!, language)
            if databaseOrmResultType.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultType.databaseOrmError[0].name, description: databaseOrmResultType.databaseOrmError[0].description))
                udcSentencePatternDataGroupValueArray.append(udcSentencePatternDataGroupValue)
                return udcSentencePatternDataGroupValueArray
            }
            let type = databaseOrmResultType.object[0]
            udcSentencePatternDataGroupValue.item = type.name
            udcSentencePatternDataGroupValue.itemId = type.idName
            udcSentencePatternDataGroupValue.category = type.udcGrammarCategory
            udcSentencePatternDataGroupValue.endCategoryIdName = "UDCDocumentItemMapNode.District"
        } else if optionItemObjectName == "UDCVillage" {
            let databaseOrmResultType = UDCVillageType.get(idName: optionItemIdName, udbcDatabaseOrm!, language)
            if databaseOrmResultType.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultType.databaseOrmError[0].name, description: databaseOrmResultType.databaseOrmError[0].description))
                udcSentencePatternDataGroupValueArray.append(udcSentencePatternDataGroupValue)
                return udcSentencePatternDataGroupValueArray
            }
            let type = databaseOrmResultType.object[0]
            udcSentencePatternDataGroupValue.item = type.name
            udcSentencePatternDataGroupValue.itemId = type.idName
            udcSentencePatternDataGroupValue.category = type.udcGrammarCategory
            udcSentencePatternDataGroupValue.endCategoryIdName = "UDCDocumentItemMapNode.Village"
        } else if optionItemObjectName == "UDCTown" {
            let databaseOrmResultType = UDCTownType.get(idName: optionItemIdName, udbcDatabaseOrm!, language)
            if databaseOrmResultType.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultType.databaseOrmError[0].name, description: databaseOrmResultType.databaseOrmError[0].description))
                udcSentencePatternDataGroupValueArray.append(udcSentencePatternDataGroupValue)
                return udcSentencePatternDataGroupValueArray
            }
            let type = databaseOrmResultType.object[0]
            udcSentencePatternDataGroupValue.item = type.name
            udcSentencePatternDataGroupValue.itemId = type.idName
            udcSentencePatternDataGroupValue.category = type.udcGrammarCategory
            udcSentencePatternDataGroupValue.endCategoryIdName = "UDCDocumentItemMapNode.Town"
        } else if optionItemObjectName == "UDCOrderOfMagnitudeTemperature" {
            let databaseOrmResultType = UDCOrderOfMagnitudeTemperatureType.get(idName: optionItemIdName, udbcDatabaseOrm!, language)
            if databaseOrmResultType.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultType.databaseOrmError[0].name, description: databaseOrmResultType.databaseOrmError[0].description))
                udcSentencePatternDataGroupValueArray.append(udcSentencePatternDataGroupValue)
                return udcSentencePatternDataGroupValueArray
            }
            let type = databaseOrmResultType.object[0]
            udcSentencePatternDataGroupValue.item = type.name
            udcSentencePatternDataGroupValue.itemId = type.idName
            udcSentencePatternDataGroupValue.category = type.grammarCategory
            udcSentencePatternDataGroupValue.endCategoryIdName = "UDCDocumentItemMapNode.OrderOfMagnitudeTemperature"
        } else if optionItemObjectName == "UDCOvenTemperature" {
            let databaseOrmResultType = UDCOvenTemperatureType.get(idName: optionItemIdName, udbcDatabaseOrm!, language)
            if databaseOrmResultType.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultType.databaseOrmError[0].name, description: databaseOrmResultType.databaseOrmError[0].description))
                udcSentencePatternDataGroupValueArray.append(udcSentencePatternDataGroupValue)
                return udcSentencePatternDataGroupValueArray
            }
            let type = databaseOrmResultType.object[0]
            udcSentencePatternDataGroupValue.item = type.name
            udcSentencePatternDataGroupValue.itemId = type.idName
            udcSentencePatternDataGroupValue.category = type.grammarCategory
            udcSentencePatternDataGroupValue.endCategoryIdName = "UDCDocumentItemMapNode.OvenTemperature"
        } else if optionItemObjectName == "UDCCuisine" {
            let databaseOrmResultType = UDCCuisineType.get(idName: optionItemIdName, udbcDatabaseOrm!, language)
            if databaseOrmResultType.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultType.databaseOrmError[0].name, description: databaseOrmResultType.databaseOrmError[0].description))
                udcSentencePatternDataGroupValueArray.append(udcSentencePatternDataGroupValue)
                return udcSentencePatternDataGroupValueArray
            }
            let type = databaseOrmResultType.object[0]
            udcSentencePatternDataGroupValue.item = type.name
            udcSentencePatternDataGroupValue.itemId = type.idName
            udcSentencePatternDataGroupValue.category = type.udcGrammarCategory
            udcSentencePatternDataGroupValue.endCategoryIdName = "UDCDocumentItemMapNode.Cuisine"
        } else if optionItemObjectName == "UDCCuisineStyle" {
            let databaseOrmResultType = UDCCuisineStyleType.get(idName: optionItemIdName, udbcDatabaseOrm!, language)
            if databaseOrmResultType.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultType.databaseOrmError[0].name, description: databaseOrmResultType.databaseOrmError[0].description))
                udcSentencePatternDataGroupValueArray.append(udcSentencePatternDataGroupValue)
                return udcSentencePatternDataGroupValueArray
            }
            let type = databaseOrmResultType.object[0]
            udcSentencePatternDataGroupValue.item = type.name
            udcSentencePatternDataGroupValue.itemId = type.idName
            udcSentencePatternDataGroupValue.category = type.udcGrammarCategory
            udcSentencePatternDataGroupValue.endCategoryIdName = "UDCDocumentItemMapNode.CuisineStyle"
        } else if optionItemObjectName == "UDCCuisineHistorical" {
            let databaseOrmResultType = UDCCuisineHistoricalType.get(idName: optionItemIdName, udbcDatabaseOrm!, language)
            if databaseOrmResultType.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultType.databaseOrmError[0].name, description: databaseOrmResultType.databaseOrmError[0].description))
                udcSentencePatternDataGroupValueArray.append(udcSentencePatternDataGroupValue)
                return udcSentencePatternDataGroupValueArray
            }
            let type = databaseOrmResultType.object[0]
            udcSentencePatternDataGroupValue.item = type.name
            udcSentencePatternDataGroupValue.itemId = type.idName
            udcSentencePatternDataGroupValue.category = type.udcGrammarCategory
            udcSentencePatternDataGroupValue.endCategoryIdName = "UDCDocumentItemMapNode.CuisineHistorical"
        } else if optionItemObjectName == "UDCUtensil" {
            let databaseOrmResultType = UDCUtensilType.get(idName: optionItemIdName, udbcDatabaseOrm!, language)
            if databaseOrmResultType.databaseOrmError.count > 0 {
                let udcDatabaseOrmTypePattern = try UDCWordPatternType.get(idName: optionItemIdName, udbcDatabaseOrm!, language)
                if udcDatabaseOrmTypePattern.databaseOrmError.count > 0 { neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultType.databaseOrmError[0].name, description: databaseOrmResultType.databaseOrmError[0].description))
                    udcSentencePatternDataGroupValueArray.append(udcSentencePatternDataGroupValue)
                    return udcSentencePatternDataGroupValueArray
                } else {
                    let typePattern = udcDatabaseOrmTypePattern.object[0]
                    udcSentencePatternDataGroupValue.item = typePattern.name
                    udcSentencePatternDataGroupValue.itemId = typePattern.idName
                    udcSentencePatternDataGroupValue.itemState = ""
                    udcSentencePatternDataGroupValue.category = ""
                    udcSentencePatternDataGroupValue.endCategoryIdName = "UDCDocumentItemMapNode.Utensil"
                    udcSentencePatternDataGroupValueArray.append(udcSentencePatternDataGroupValue)
                    return udcSentencePatternDataGroupValueArray
                }
            }
            let type = databaseOrmResultType.object[0]
            udcSentencePatternDataGroupValue.item = type.name
            udcSentencePatternDataGroupValue.itemId = type.idName
            udcSentencePatternDataGroupValue.category = type.grammarCategory
            udcSentencePatternDataGroupValue.endCategoryIdName = "UDCDocumentItemMapNode.Utensil"
        } else if optionItemObjectName == "UDCFoodTiming" {
            let databaseOrmResultType = UDCFoodTimingType.get(idName: optionItemIdName, udbcDatabaseOrm!, language)
            if databaseOrmResultType.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultType.databaseOrmError[0].name, description: databaseOrmResultType.databaseOrmError[0].description))
                udcSentencePatternDataGroupValueArray.append(udcSentencePatternDataGroupValue)
                return udcSentencePatternDataGroupValueArray
            }
            let type = databaseOrmResultType.object[0]
            udcSentencePatternDataGroupValue.item = type.name
            udcSentencePatternDataGroupValue.itemId = type.idName
            udcSentencePatternDataGroupValue.category = type.udcGrammarCategory
            udcSentencePatternDataGroupValue.endCategoryIdName = "UDCDocumentItemMapNode.FoodTiming"
        } else*/
            
            if optionItemObjectName == "UDCUserWordDictionary" {
            let databaseOrmResultType = UDCUserWordDictionary.get(idName: optionItemIdName, udbcDatabaseOrm!, language)
            if databaseOrmResultType.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultType.databaseOrmError[0].name, description: databaseOrmResultType.databaseOrmError[0].description))
                udcSentencePatternDataGroupValueArray.append(udcSentencePatternDataGroupValue)
                return udcSentencePatternDataGroupValueArray
            }
            let type = databaseOrmResultType.object[0]
            udcSentencePatternDataGroupValue.item = type.word
            udcSentencePatternDataGroupValue.itemId = type.idName
            udcSentencePatternDataGroupValue.category = "UDCGrammarCategory.CommonNoun"
            udcSentencePatternDataGroupValue.endCategoryIdName = "UDCDocumentItemMapNode.UserWordDictionary"
        } /*else if optionItemObjectName == "UDCMathematicalItem" {
            let databaseOrmResultType = UDCMathematicalItemType.get(idName: optionItemIdName, udbcDatabaseOrm!, language)
            if databaseOrmResultType.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultType.databaseOrmError[0].name, description: databaseOrmResultType.databaseOrmError[0].description))
                udcSentencePatternDataGroupValueArray.append(udcSentencePatternDataGroupValue)
                return udcSentencePatternDataGroupValueArray
            }
            let type = databaseOrmResultType.object[0]
            udcSentencePatternDataGroupValue.item = ""
            udcSentencePatternDataGroupValue.itemId = type.idName
            udcSentencePatternDataGroupValue.category = "UDCGrammarCategory.CommonNoun"
            udcSentencePatternDataGroupValue.endCategoryIdName = "UDCDocumentItemMapNode.MathematicalItem"
        }*/
        if udcSentencePatternDataGroupValueArray.count == 0 {
            udcSentencePatternDataGroupValueArray.append(udcSentencePatternDataGroupValue)
        }
        return udcSentencePatternDataGroupValueArray
    }
    //
    /// Checks whether the passed sentence pattern matches with the named sentence pattern
    private func isSentencePatternMatch(name: String, udcSentencePattern: inout UDCSentencePattern, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws -> Bool {
        let udcSentencePatternLocal = try getSentencePattern(name: name, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        
        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
            return false
        }
        
        if udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup.count != udcSentencePatternLocal!.udcSentencePatternData[0].udcSentencePatternDataGroup.count {
            return false
        }
        if udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup.count != udcSentencePatternLocal!.udcSentencePatternData[0].udcSentencePatternDataGroup.count {
            return false
        }
        for (indexGroup, udcSentencePatternDataGroup) in udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup.enumerated() {
            if udcSentencePatternDataGroup.udcSentencePatternDataGroupValue.count != udcSentencePatternLocal!.udcSentencePatternData[0].udcSentencePatternDataGroup[indexGroup].udcSentencePatternDataGroupValue.count {
                return false
            }
            for (indexGroupValue, udcSentencePatternDataGroupValue) in udcSentencePatternDataGroup.udcSentencePatternDataGroupValue.enumerated() {
                if udcSentencePatternDataGroupValue.itemState != udcSentencePatternLocal!.udcSentencePatternData[0].udcSentencePatternDataGroup[indexGroup].udcSentencePatternDataGroupValue[indexGroupValue].itemState {
                    return false
                }
                if udcSentencePatternDataGroupValue.isCountable != udcSentencePatternLocal!.udcSentencePatternData[0].udcSentencePatternDataGroup[indexGroup].udcSentencePatternDataGroupValue[indexGroupValue].isCountable {
                    return false
                }
                if udcSentencePatternDataGroupValue.endCategoryIdName != udcSentencePatternLocal!.udcSentencePatternData[0].udcSentencePatternDataGroup[indexGroup].udcSentencePatternDataGroupValue[indexGroupValue].endCategoryIdName {
                    return false
                }
                if udcSentencePatternDataGroupValue.itemType != udcSentencePatternLocal!.udcSentencePatternData[0].udcSentencePatternDataGroup[indexGroup].udcSentencePatternDataGroupValue[indexGroupValue].itemType {
                    return false
                }
                if udcSentencePatternDataGroupValue.isSubject != udcSentencePatternLocal!.udcSentencePatternData[0].udcSentencePatternDataGroup[indexGroup].udcSentencePatternDataGroupValue[indexGroupValue].isSubject {
                    return false
                }
                if udcSentencePatternDataGroupValue.tense != udcSentencePatternLocal!.udcSentencePatternData[0].udcSentencePatternDataGroup[indexGroup].udcSentencePatternDataGroupValue[indexGroupValue].tense {
                    return false
                }
            }
        }
        
        return true
    }
    
    /// Gets the sentence pattern fromd atabase given its name
    private func getSentencePattern(name: String, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws -> UDCSentencePattern? {
        let databaseOrmResultUDCSentencePattern = UDCSentencePattern.get(name, udbcDatabaseOrm!, "")
        if databaseOrmResultUDCSentencePattern.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCSentencePattern.databaseOrmError[0].name, description: databaseOrmResultUDCSentencePattern.databaseOrmError[0].description))
            return nil
        }
        
        return databaseOrmResultUDCSentencePattern.object[0]
    }
    
    private func generateSentenceViewAsObject(udcDocumentGraphModel: UDCDocumentGraphModel,  neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest, documentLanguage: String) -> UVCViewModel {
        
        let uvcViewModelReturn = UVCViewModel()
        uvcViewModelReturn.language = documentLanguage
        var uvcViewItem = UVCViewItem()
        uvcViewItem.name = uvcViewGenerator.generateNameWithUniqueId("SentenceTable")
        uvcViewItem.type = "UVCViewItemType.Table"
        uvcViewModelReturn.uvcViewItem.append(uvcViewItem)
        uvcViewItem = UVCViewItem()
        uvcViewItem.name = uvcViewGenerator.generateNameWithUniqueId("SentenceTexts")
        uvcViewItem.type = "UVCViewItemType.Text"
        uvcViewModelReturn.uvcViewItem.append(uvcViewItem)
        let uvcTable = UVCTable()
        let uvcTableRow = UVCTableRow()
        let uvcTableColumn = UVCTableColumn()
        
        
        for udcSentencePatternData in udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData {
            for (udcSentencePatternDataGroupIndex, udcSentencePatternDataGroup) in udcSentencePatternData.udcSentencePatternDataGroup.enumerated() {
                
                for (udcSentencePatternDataGroupValueIndex, udcSentencePatternDataGroupValue) in udcSentencePatternDataGroup.udcSentencePatternDataGroupValue.enumerated() {
                    
                    let value = udcSentencePatternDataGroupValue.item
                    let name = uvcViewGenerator.generateNameWithUniqueId("Name")
                    
                    let uvcText = uvcViewGenerator.getText(name: name, value: value!, description: "", isEditable: false)
                    uvcText.uvcTextStyle.textColor = UVCColor.get(level: udcDocumentGraphModel.level)!.name
                    uvcText.parentId.append(contentsOf: udcDocumentGraphModel.parentId)
                    uvcText.childrenId.append(contentsOf: udcDocumentGraphModel.childrenId)
                    uvcText._id = udcDocumentGraphModel._id
                    uvcText.uvcTextSize.uvcTextSizeType = UVCTextSizeType.Regular.name
                    uvcText.uvcViewItemType = "UVCViewItemType.Text"
                    uvcText.optionObjectIdName = udcSentencePatternDataGroupValue.itemId
                    uvcText.optionObjectCategoryIdName = udcSentencePatternDataGroupValue.endSubCategoryId
                    uvcText.optionObjectName = getEditObjectName(idName: udcSentencePatternDataGroupValue.endCategoryIdName)
                    uvcViewModelReturn.uvcViewItemCollection.uvcText.append(uvcText)
                    uvcViewModelReturn.textLength = uvcText.value.count
                    uvcViewModelReturn.rowLength = 1
                    
                    uvcViewItem = UVCViewItem()
                    uvcViewItem.type = "UVCViewItemType.Text"
                    uvcViewItem.name = name
                    uvcTableColumn.uvcViewItem.append(uvcViewItem)
                    
                    
                }
            }
        }
        
        uvcTableRow.uvcTableColumn.append(uvcTableColumn)
        uvcTable.uvcTableRow.append(uvcTableRow)
        uvcViewModelReturn.uvcViewItemCollection.uvcTable.append(uvcTable)
        
        return uvcViewModelReturn
    }
    
    private func isTextFieldRecipeItem(itemIdName: String) -> Bool {
        if itemIdName.hasPrefix("UDCMathematicalItem.") {
            return true
        }
        if itemIdName == "UDCGrammarItem.HumanName" || itemIdName == "UDCGrammarItem.Description" {
            return true
        }
        
        return false
    }
    
    private func isLabelRecipeItem(itemIdName: String) -> Bool {
        if itemIdName.hasPrefix("UDCFoodRecipeItem.") {
            return true
        }
        
        return false
    }
    
    private func getPullStopView(udcDocumentGraphModel: UDCDocumentGraphModel, neuronRequest: NeuronRequest) -> UVCViewModel {
        // Sentence separator: Pull stop
        let uvcViewModel = UVCViewModel()
        uvcViewModel.language = ""
        var uvcViewItem = UVCViewItem()
        uvcViewItem.name = uvcViewGenerator.generateNameWithUniqueId("PullStopTable")
        uvcViewItem.type = "UVCViewItemType.Table"
        uvcViewModel.uvcViewItem.append(uvcViewItem)
        uvcViewItem = UVCViewItem()
        uvcViewItem.name = uvcViewGenerator.generateNameWithUniqueId("PullStopTexts")
        uvcViewItem.type = "UVCViewItemType.Text"
        uvcViewModel.uvcViewItem.append(uvcViewItem)
        
        let uvcTable = UVCTable()
        let uvcTableRow = UVCTableRow()
        let uvcTableColumn = UVCTableColumn()
        
        let name = uvcViewGenerator.generateNameWithUniqueId("PullStop")
        let uvcText = uvcViewGenerator.getText(name: name, value: ".", description: "", isEditable: false)
        uvcText.parentId.append(contentsOf: udcDocumentGraphModel.parentId)
        uvcText.childrenId.append(contentsOf: udcDocumentGraphModel.childrenId)
        uvcText.uvcTextSize.uvcTextSizeType = UVCTextSizeType.Regular.name
        uvcText.uvcViewItemType = "UVCViewItemType.Text"
        uvcText.optionObjectName = ""
        uvcViewModel.uvcViewItemCollection.uvcText.append(uvcText)
        
        uvcViewModel.textLength = uvcText.value.count
        uvcViewModel.rowLength = 1
        uvcViewItem.type = "UVCViewItemType.Text"
        uvcViewItem.name = name
        uvcTableColumn.uvcViewItem.append(uvcViewItem)
        uvcTableRow.uvcTableColumn.append(uvcTableColumn)
        uvcTable.uvcTableRow.append(uvcTableRow)
        uvcViewModel.uvcViewItemCollection.uvcTable.append(uvcTable)
        
        return uvcViewModel
    }
    
    private func copyInput(udcSentencePatternIn: UDCSentencePattern, udcSentencePatternOut: inout UDCSentencePattern) {
        for udcSentencePatternData in udcSentencePatternIn.udcSentencePatternData {
            let udcSentencePatternDataOut = UDCSentencePatternData()
            for udcSentencePatternDataGroup in udcSentencePatternData.udcSentencePatternDataGroup {
                let udcSentencePatternDataGroupOut = UDCSentencePatternDataGroup()
                udcSentencePatternDataGroupOut.category = udcSentencePatternDataGroup.category
                udcSentencePatternDataGroupOut.item = udcSentencePatternDataGroup.item
                udcSentencePatternDataGroupOut.itemType = udcSentencePatternDataGroup.itemType
                for udcSentencePatternDataGroupValue in udcSentencePatternDataGroup.udcSentencePatternDataGroupValue {
                    let udcSentencePatternDataGroupValueOut = UDCSentencePatternDataGroupValue()
                    
                    udcSentencePatternDataGroupValueOut.item = udcSentencePatternDataGroupValue.item!
                    
                    udcSentencePatternDataGroupValueOut.itemState = udcSentencePatternDataGroupValue.itemState
                    udcSentencePatternDataGroupValueOut.category = udcSentencePatternDataGroupValue.category
                    udcSentencePatternDataGroupValueOut.endCategoryIdName = udcSentencePatternDataGroupValue.endCategoryIdName
                    udcSentencePatternDataGroupValueOut.itemType = udcSentencePatternDataGroupValue.itemType
                    udcSentencePatternDataGroupValueOut.isSubject = udcSentencePatternDataGroupValue.isSubject
                    udcSentencePatternDataGroupValueOut.tense = udcSentencePatternDataGroupValue.tense
                    if udcSentencePatternDataGroupValue.udcSentencePattern != nil {
                        copyInput(udcSentencePatternIn: udcSentencePatternDataGroupValue.udcSentencePattern!, udcSentencePatternOut: &udcSentencePatternDataGroupValueOut.udcSentencePattern!)
                    }
                    udcSentencePatternDataGroupOut.udcSentencePatternDataGroupValue.append(udcSentencePatternDataGroupValueOut)
                }
                udcSentencePatternDataOut.udcSentencePatternDataGroup.append(udcSentencePatternDataGroupOut)
            }
            udcSentencePatternOut.udcSentencePatternData.append(udcSentencePatternDataOut)
        }
    }
    
    private func getSentennceOrWordListOptionView(childrenId: [String], documentGraphItemReferenceRequest: DocumentGraphItemReferenceRequest, category: String,  documentId: String, udcDocumentItemMapNodeIdName: String, nodeIndex: inout Int, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws -> [UVCOptionViewModel] {
        var uvcOptionViewModel = [UVCOptionViewModel]()
        
        let interfaceLanguage = documentGraphItemReferenceRequest.interfaceLanguage
        
        for id in childrenId {
            nodeIndex += 1
            let databaseOrmUDCDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphItemReferenceRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: id, language: interfaceLanguage)
            if databaseOrmUDCDocumentGraphModel.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentGraphModel.databaseOrmError[0].name, description: databaseOrmUDCDocumentGraphModel.databaseOrmError[0].description))
                return uvcOptionViewModel
            }
            let udcDocumentGraphModel = databaseOrmUDCDocumentGraphModel.object[0]
            
            // If other than category. Only one category list. There are no child categories
            var uvcOptionViewModelArray = [UVCOptionViewModel]()
            let udcGrammarUtility = UDCGrammarUtility()
            var continueLoop = false
            
            // Form the list of sentnece pattern options
            for (udcspdgIndex, udcspdg) in udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup.enumerated() {
                if udcspdg.udcSentencePatternDataGroupValue.count == 0 {
                    continue
                }
                continueLoop = false
                for udcspdgv in udcspdg.udcSentencePatternDataGroupValue {
                    if udcspdgv.endCategoryIdName.hasSuffix(".FoodRecipeCategory") {
                        continueLoop = true
                    }
                    if udcspdgv.udcDocumentItemGraphReferenceSource.count > 0 && udcDocumentItemMapNodeIdName == "UDCDocumentItemMapNode.Sentence" {
                        continueLoop = true
                    }
                }
                if continueLoop {
                    continue
                }
                var udcSentencePattern = UDCSentencePattern()
                udcGrammarUtility.getSetencePattern(udcSentencePattern: &udcSentencePattern, udcSentencePatternDataGroupValue: udcspdg.udcSentencePatternDataGroupValue)
                udcSentencePattern = try processGrammar(neuronRequest: neuronRequest, neuronResponse: &neuronResponse, udcSentencePattern: udcSentencePattern, documentLanguage: interfaceLanguage, textStartIndex: 0)
                if udcDocumentItemMapNodeIdName == "UDCDocumentItemMapNode.Sentence" {
                    let uvcOptionViewModelChild = UVCOptionViewModel()
                    uvcOptionViewModelChild._id = try (udbcDatabaseOrm?.generateId())!
                    // document graph model id of the sentence
                    uvcOptionViewModelChild.objectIdName = udcDocumentGraphModel._id
                    uvcOptionViewModelChild.objectName = neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphItemReferenceRequest.udcDocumentTypeIdName)!
                    uvcOptionViewModelChild.pathIdName.append(documentGraphItemReferenceRequest.pathIdName)
                    uvcOptionViewModelChild.level = 3
                    
                    // Get sentence view
                    uvcOptionViewModelChild.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: udcSentencePattern.sentence, description: "", category: category, subCategory: "", language: interfaceLanguage, isChildrenExist: false, isEditable: false, isCheckBox: false, photoId: nil, photoObjectName: nil)
                    
                    uvcOptionViewModelChild.pathIdName[0].append(String(udcspdgIndex))
                    uvcOptionViewModelChild.uvcViewModel.rowLength = 2
                    uvcOptionViewModelChild.parentId.append(documentGraphItemReferenceRequest.parentId)
                    
                    // Put sentence index in model (additional information of sentence).
                    // This will be used to add sentence as reference in the interface.
                    uvcOptionViewModelChild.model = "\(nodeIndex):\(udcspdgIndex)"
                    uvcOptionViewModelArray.append(uvcOptionViewModelChild)
                } else {
                    for (udcspdgvIndex, udcspdgv) in udcspdg.udcSentencePatternDataGroupValue.enumerated() {
                        if udcspdgv.udcDocumentItemGraphReferenceSource.count > 0 || udcspdgv.category == "UDCGrammarCategory.Punctuation" {
                            continue
                        }
                        let uvcOptionViewModelChild = UVCOptionViewModel()
                        uvcOptionViewModelChild._id = try (udbcDatabaseOrm?.generateId())!
                        // document graph model id of the sentence
                        uvcOptionViewModelChild.objectIdName = udcDocumentGraphModel._id
                        uvcOptionViewModelChild.objectName = UDCDocumentGraphModel.getName()
                        uvcOptionViewModelChild.pathIdName.append(documentGraphItemReferenceRequest.pathIdName)
                        uvcOptionViewModelChild.level = 3
                        
                        // Get sentence view
                        var subCategory: String = ""
                        let databaseOrmResultUDCDocumentItemMapNode = UDCDocumentItemMapNode.get(udcspdgv.endCategoryIdName, udbcDatabaseOrm!, interfaceLanguage)
                        if databaseOrmResultUDCDocumentItemMapNode.databaseOrmError.count > 0 {
                            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentItemMapNode.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentItemMapNode.databaseOrmError[0].description))
                            return uvcOptionViewModel
                        }
                        subCategory = databaseOrmResultUDCDocumentItemMapNode.object[0].name
                        uvcOptionViewModelChild.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: udcspdgv.item!, description: "", category: category, subCategory: subCategory, language: interfaceLanguage, isChildrenExist: false, isEditable: false, isCheckBox: false, photoId: nil, photoObjectName: nil)
                        
                        uvcOptionViewModelChild.pathIdName[0].append(String(udcspdgIndex))
                        uvcOptionViewModelChild.uvcViewModel.rowLength = 2
                        uvcOptionViewModelChild.parentId.append(documentGraphItemReferenceRequest.parentId)
                        
                        // Put sentence index in model (additional information of sentence).
                        // This will be used to add sentence as reference in the interface.
                        uvcOptionViewModelChild.model = "\(nodeIndex):\(udcspdgIndex):\(udcspdgvIndex)"
                        uvcOptionViewModelArray.append(uvcOptionViewModelChild)
                    }
                }
            }
            uvcOptionViewModel.append(contentsOf: uvcOptionViewModelArray)
            
            
            if udcDocumentGraphModel.childrenId.count > 0 {
                let uvcOptionViewModelLocal = try getSentennceOrWordListOptionView(childrenId: udcDocumentGraphModel.childrenId, documentGraphItemReferenceRequest: documentGraphItemReferenceRequest, category: udcDocumentGraphModel.name, documentId: documentId, udcDocumentItemMapNodeIdName: udcDocumentItemMapNodeIdName, nodeIndex: &nodeIndex, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
                if uvcOptionViewModelLocal.count > 0 {
                    uvcOptionViewModel.append(contentsOf: uvcOptionViewModelLocal)
                }
            }
        }
        
        return uvcOptionViewModel
    }
    
    
    private func getDocumentSentenceListOptionView(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let getDocumentItemListOptionViewRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: GetDocumentItemListOptionViewRequest())
        
        let getDocumentItemListOptionViewResponse = GetDocumentItemListOptionViewResponse()
        
        // Get childs of title node and pass it to recursive function to get sentence list options
        
        // Get the title of the sentence list
        var nodeIndex = 0
        let uvcOptionViewModelArray = try getSentennceOrWordListOptionView(childrenId: getDocumentItemListOptionViewRequest.udcDocumentGraphModel.childrenId, documentGraphItemReferenceRequest: getDocumentItemListOptionViewRequest.documentGraphItemReferenceRequest, category: getDocumentItemListOptionViewRequest.udcDocumentGraphModel.name, documentId: getDocumentItemListOptionViewRequest.udcDocumentGraphModel._id, udcDocumentItemMapNodeIdName: getDocumentItemListOptionViewRequest.udcDocumentItemMapNodeIdName, nodeIndex: &nodeIndex, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        getDocumentItemListOptionViewResponse.uvcOptionViewModel.append(contentsOf: uvcOptionViewModelArray)
        
        let jsonUtilityGetDocumentItemListOptionViewResponse = JsonUtility<GetDocumentItemListOptionViewResponse>()
        let jsonGetDocumentItemListOptionViewResponse = jsonUtilityGetDocumentItemListOptionViewResponse.convertAnyObjectToJson(jsonObject: getDocumentItemListOptionViewResponse)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonGetDocumentItemListOptionViewResponse)
    }
    
    private func generateDocumentItemViewForChange(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let generateDocumentItemViewForChangeRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: GenerateDocumentItemViewForChangeRequest())
        
        let generateDocumentItemViewForChangeResponse = GenerateDocumentItemViewForChangeResponse()
        let documentItemViewChangeData = DocumentGraphItemViewData()
        documentItemViewChangeData.uvcDocumentGraphModel._id = generateDocumentItemViewForChangeRequest.changeDocumentModel._id
        let uvcViewModelArray = generateSentenceViewAsArray(udcDocumentGraphModel: generateDocumentItemViewForChangeRequest.changeDocumentModel, uvcViewItemCollection: nil, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, newView: false, isEditable: true, level: generateDocumentItemViewForChangeRequest.documentGraphChangeItemRequest.level, nodeIndex: generateDocumentItemViewForChangeRequest.documentGraphChangeItemRequest.nodeIndex, itemIndex: generateDocumentItemViewForChangeRequest.documentGraphChangeItemRequest.itemIndex, documentLanguage: generateDocumentItemViewForChangeRequest.documentGraphChangeItemRequest.documentLanguage)
        documentItemViewChangeData.uvcDocumentGraphModel.uvcViewModel.append(uvcViewModelArray[generateDocumentItemViewForChangeRequest.documentGraphChangeItemRequest.itemIndex])
        for (udcspgvIndex, udcspgv) in generateDocumentItemViewForChangeRequest.changeDocumentModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.enumerated() {
            uvcViewModelArray[udcspgvIndex].udcViewItemId = udcspgv.udcViewItemId
            uvcViewModelArray[udcspgvIndex].udcViewItemName = udcspgv.udcViewItemName
            if udcspgvIndex == generateDocumentItemViewForChangeRequest.documentGraphChangeItemRequest.itemIndex {
                generateDocumentItemViewForChangeResponse.objectControllerResponse.groupUVCViewItemType = udcspgv.groupUVCViewItemType
                generateDocumentItemViewForChangeResponse.objectControllerResponse.udcViewItemId = udcspgv.udcViewItemId
                generateDocumentItemViewForChangeResponse.objectControllerResponse.udcViewItemName = udcspgv.udcViewItemName
                generateDocumentItemViewForChangeResponse.objectControllerResponse.uvcViewItemType = udcspgv.uvcViewItemType
            }
        }
        documentItemViewChangeData.treeLevel = generateDocumentItemViewForChangeRequest.documentGraphChangeItemRequest.level
        documentItemViewChangeData.nodeIndex = generateDocumentItemViewForChangeRequest.documentGraphChangeItemRequest.nodeIndex
        documentItemViewChangeData.itemIndex = generateDocumentItemViewForChangeRequest.documentGraphChangeItemRequest.itemIndex + 1
        documentItemViewChangeData.subItemIndex = generateDocumentItemViewForChangeRequest.documentGraphChangeItemRequest.subItemIndex
        documentItemViewChangeData.sentenceIndex = generateDocumentItemViewForChangeRequest.documentGraphChangeItemRequest.sentenceIndex
        
        generateDocumentItemViewForChangeResponse.documentItemViewChangeData.append(documentItemViewChangeData)
        
        let jsonUtilityGenerateDocumentItemViewForChangeResponse = JsonUtility<GenerateDocumentItemViewForChangeResponse>()
        let jsonGenerateDocumentItemViewForChangeResponse = jsonUtilityGenerateDocumentItemViewForChangeResponse.convertAnyObjectToJson(jsonObject: generateDocumentItemViewForChangeResponse)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonGenerateDocumentItemViewForChangeResponse)
    }
    
    private func generateDocumentItemViewForInsert(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let generateDocumentItemViewForInsertRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: GenerateDocumentItemViewForInsertRequest())
        
        let generateDocumentItemViewForInsertResponse = GenerateDocumentItemViewForInsertResponse()
        let documentItemViewInsertData = DocumentGraphItemViewData()
        documentItemViewInsertData.uvcDocumentGraphModel.level = generateDocumentItemViewForInsertRequest.documentGraphInsertItemRequest.level
        documentItemViewInsertData.uvcDocumentGraphModel._id = generateDocumentItemViewForInsertRequest.insertDocumentModel._id
        documentItemViewInsertData.uvcDocumentGraphModel.isChildrenAllowed = generateDocumentItemViewForInsertRequest.documentGraphInsertItemRequest.isParent
        
        var uvcViewModelArray = [UVCViewModel]()
        
        uvcViewModelArray.append(contentsOf: generateSentenceViewAsArray(udcDocumentGraphModel: generateDocumentItemViewForInsertRequest.insertDocumentModel, uvcViewItemCollection: generateDocumentItemViewForInsertRequest.uvcViewItemCollection, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, newView: true, isEditable: generateDocumentItemViewForInsertRequest.isEditable, level: generateDocumentItemViewForInsertRequest.documentGraphInsertItemRequest.level, nodeIndex: generateDocumentItemViewForInsertRequest.documentGraphInsertItemRequest.nodeIndex, itemIndex: generateDocumentItemViewForInsertRequest.documentGraphInsertItemRequest.itemIndex, documentLanguage: generateDocumentItemViewForInsertRequest.documentGraphInsertItemRequest.documentLanguage))
        
        for (udcspgvIndex, udcspgv) in generateDocumentItemViewForInsertRequest.insertDocumentModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.enumerated() {
            uvcViewModelArray[udcspgvIndex].udcViewItemId = udcspgv.udcViewItemId
            uvcViewModelArray[udcspgvIndex].udcViewItemName = udcspgv.udcViewItemName
            if udcspgvIndex == generateDocumentItemViewForInsertRequest.documentGraphInsertItemRequest.itemIndex {
                generateDocumentItemViewForInsertResponse.objectControllerResponse.groupUVCViewItemType = udcspgv.groupUVCViewItemType
                generateDocumentItemViewForInsertResponse.objectControllerResponse.udcViewItemId = udcspgv.udcViewItemId
                generateDocumentItemViewForInsertResponse.objectControllerResponse.udcViewItemName = udcspgv.udcViewItemName
                if udcspgv.uvcViewItemType.isEmpty {
                    udcspgv.uvcViewItemType = "UVCViewItemType.Text"
                }
                generateDocumentItemViewForInsertResponse.objectControllerResponse.uvcViewItemType = udcspgv.uvcViewItemType
            }
        }
        
        if generateDocumentItemViewForInsertRequest.isSentence {
            documentItemViewInsertData.uvcDocumentGraphModel.uvcViewModel.append(contentsOf: uvcViewModelArray)
        } else {
            documentItemViewInsertData.uvcDocumentGraphModel.uvcViewModel.append(uvcViewModelArray[generateDocumentItemViewForInsertRequest.documentGraphInsertItemRequest.itemIndex])
            //           for (uvcvmaIndex, uvcvma) in uvcViewModelArray.enumerated() {
            //                if uvcvmaIndex >= generateDocumentItemViewForInsertRequest.documentGraphInsertItemRequest.itemIndex {
            //                    documentItemViewInsertData.uvcDocumentGraphModel.uvcViewModel.append(uvcvma)
            //                }
            //            }
        }
        documentItemViewInsertData.treeLevel = generateDocumentItemViewForInsertRequest.documentGraphInsertItemRequest.level
        documentItemViewInsertData.nodeIndex = generateDocumentItemViewForInsertRequest.documentGraphInsertItemRequest.nodeIndex
        documentItemViewInsertData.itemIndex = generateDocumentItemViewForInsertRequest.documentGraphInsertItemRequest.itemIndex + 1
        if generateDocumentItemViewForInsertRequest.isNewSentence {
            documentItemViewInsertData.sentenceIndex = generateDocumentItemViewForInsertRequest.documentGraphInsertItemRequest.sentenceIndex + 1
        } else {
            documentItemViewInsertData.sentenceIndex = generateDocumentItemViewForInsertRequest.documentGraphInsertItemRequest.sentenceIndex
        }
        
        generateDocumentItemViewForInsertResponse.documentItemViewInsertData.append(documentItemViewInsertData)
        
        let jsonUtilityGenerateDocumentItemViewForInsertResponse = JsonUtility<GenerateDocumentItemViewForInsertResponse>()
        let jsonGenerateDocumentItemViewForInsertResponse = jsonUtilityGenerateDocumentItemViewForInsertResponse.convertAnyObjectToJson(jsonObject: generateDocumentItemViewForInsertResponse)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonGenerateDocumentItemViewForInsertResponse)
    }
    
    
    //    private func validateRecipeModel(udcDocumentGraphModelParent: UDCDocumentModel, findRecipe: UDCDocumentModel, inRecipe: UDCDocumentModel, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) -> Bool {
    //        var validationResult: Bool = true
    //
    //        for sp in inRecipe.udcSentencePattern {
    //            validationResult = true // For each sentence pattern
    //            for spd in sp.udcSentencePatternData {
    //                for spdg in spd.udcSentencePatternDataGroup {
    //                    for spdgv in spdg.udcSentencePatternDataGroupValue {
    //                        if spdgv.endCategory == "Recipe Item" {
    //                            if neuronRequest.neuronOperation.name == "DocumentItemConfigurationNeuron.Document.Word.Append" {
    //                                // If parent is basic details and only one item and if already found
    //                                if udcDocumentGraphModelParent.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].item == "Basic Details" && checkSentencePatternDataGroupValueFound(inRecipe: inRecipe, udcSentencePatternDataGroupValue: spdgv) && spdg.udcSentencePatternDataGroupValue.count == 1 {
    //                                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "BasicDetailsItemAlreadyExist", description: "Basic Details Item Already Exist"))
    //                                    validationResult = false
    //                                }
    //                            }
    //                        }
    //                    }
    //                }
    //            }
    //        }
    //
    //        return validationResult
    //    }
    
    //    private func checkSentencePatternDataGroupValueFound(inRecipe: UDCDocumentModel, udcSentencePatternDataGroupValue: UDCSentencePatternDataGroupValue) -> Bool {
    //        for sp in inRecipe.udcSentencePattern {
    //            for spd in sp.udcSentencePatternData {
    //                for spdg in spd.udcSentencePatternDataGroup {
    //                    for spdgv in spdg.udcSentencePatternDataGroupValue {
    //                        if spdgv.endCategory == "Recipe Item" {
    //                            if spdgv.item == udcSentencePatternDataGroupValue.item &&
    //                                spdgv.endCategory == udcSentencePatternDataGroupValue.endCategory {
    //                                return true
    //                            }
    //                        }
    //                    }
    //                }
    //            }
    //        }
    //
    //        return false
    //    }
    
    
    
    
    
    
//    private func addRecipeCategory(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
//        let documentAddCategoryRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: DocumentAddCategoryRequest())
//        let documentLanguage = documentAddCategoryRequest.documentLanguage
//        let jsonUtilityudcDocumentGraphModel = JsonUtility<UDCDocumentGraphModel>()
//        let udcDocumentGraphModelCategory = jsonUtilityudcDocumentGraphModel.convertJsonToAnyObject(json: documentAddCategoryRequest.categoryModel)
//        let jsonUtilityudcDocumentGraphModelList = JsonUtility<[UDCDocumentGraphModel]>()
//        var udcDocumentGraphModelList = jsonUtilityudcDocumentGraphModelList.convertJsonToAnyObject(json: documentAddCategoryRequest.udcDocumentGraphModel)
//
//        if udcDocumentGraphModelList.count == 0 {
//            udcDocumentGraphModelList.append(udcDocumentGraphModelCategory)
//        } else {
//            for udcr in udcDocumentGraphModelList {
//                if udcr.pathIdName == udcDocumentGraphModelCategory.pathIdName && udcr.name == udcDocumentGraphModelCategory.name {
//                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "DuplicateRecipeItem", description: "Duplicate Recipe Item"))
//                    return
//                }
//            }
//        }
//        // Save Recipe model
//        udcDocumentGraphModelCategory._id = try udbcDatabaseOrm!.generateId()
//        var profileId = ""
//        for udcp in documentAddCategoryRequest.udcProfile {
//            if udcp.udcProfileItemIdName == "UDCProfileItem.Human" {
//                profileId = udcp.profileId
//            }
//        }
//        let udcDocumentTime = try getUDCDocumentTimeCreated(profileId: profileId, language: documentLanguage)
//        let udcAnalytic = [try getAnalyticAndSaveDocumentTime(udcDocumentTime: udcDocumentTime, objectName: "UDCDocumentTime", profileId: profileId,  neuronRequest: neuronRequest, neuronResponse: &neuronResponse)]
//        udcDocumentGraphModelCategory.udcAnalytic = udcAnalytic
//
//        let databaseOrmResultUDCDocumentModel = UDCDocumentGraphModel.save(collectionName: "UDCRecipe", udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentGraphModelCategory)
//        if databaseOrmResultUDCDocumentModel.databaseOrmError.count > 0 {
//            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentModel.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentModel.databaseOrmError[0].description))
//            return
//        }
//
//        // Save Document model
//        let udcDocument = documentAddCategoryRequest.udcDocument
//        udcDocument.udcAnalytic = udcAnalytic
//
//        if udcDocument._id.isEmpty {
//            udcDocument._id = try (udbcDatabaseOrm?.generateId())!
//            udcDocument.modelName = "Recipe Model"
//            udcDocument.modelVersion = "1.0"
//            udcDocument.modelDescription = "Contains Recipe Model"
//            udcDocument.modelTechnicalName = "udcDocumentGraphModel"
//            udcDocument.udcDocumentHistory.append(UDCDcumentHistory())
//            udcDocument.udcDocumentHistory[0]._id = try (udbcDatabaseOrm?.generateId())!
//            udcDocument.udcDocumentHistory[0].humanProfileId = profileId
//            udcDocument.udcDocumentHistory[0].time = udcDocumentTime.creationTime
//            udcDocument.udcDocumentHistory[0].reason = "Initial Version"
//            udcDocument.udcDocumentHistory[0].version = udcDocument.modelVersion
//            udcDocument.udcDocumentGraphModelId = udcDocumentGraphModelCategory._id
//            let databaseOrmResultUDCDocument = UDCDocument.save(udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocument)
//            if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
//                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocument.databaseOrmError[0].name, description: databaseOrmResultUDCDocument.databaseOrmError[0].description))
//                return
//            }
//        }
//
//        let documentAddCategoryResponse = DocumentAddCategoryResponse()
//        documentAddCategoryResponse.udcDocument = udcDocument
//        documentAddCategoryResponse.treeLevel = documentAddCategoryRequest.treeLevel
//        documentAddCategoryResponse.treeListIndex = documentAddCategoryRequest.treeListIndex
//        documentAddCategoryResponse.udcDocumentGraphModel = jsonUtilityudcDocumentGraphModelList.convertAnyObjectToJson(jsonObject: udcDocumentGraphModelList)
//        documentAddCategoryResponse.uvcDocumentGraphModel.append(UVCDocumentGraphModel())
//        documentAddCategoryResponse.uvcDocumentGraphModel[0].uvcViewModel.append(contentsOf: uvcViewGenerator.getCategoryView(value: udcDocumentGraphModelCategory.name, language: documentLanguage, parentId: [], childrenId: [], nodeId: [udcDocumentGraphModelCategory._id], sentenceIndex: [0], wordIndex: [0], objectId: "", objectName: "", objectCategoryIdName: "", level: documentAddCategoryRequest.treeLevel))
//        let jsonUtilityDocumentAddCategoryResponse = JsonUtility<DocumentAddCategoryResponse>()
//        let jsonDocumentAddCategoryResponse = jsonUtilityDocumentAddCategoryResponse.convertAnyObjectToJson(jsonObject: documentAddCategoryResponse)
//        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonDocumentAddCategoryResponse)
//    }
    
    private func getOptionViewForSentence(_id: String, name: String, category: String, model: String, level: Int, isCheckBox: Bool) -> UVCOptionViewModel {
        let uvcOptionViewModelLocal = UVCOptionViewModel()
        let uvcViewModel = uvcViewGenerator.getOptionViewModel(name: name, description: "", category: category, subCategory: "", language: "en", isChildrenExist: false, isEditable: false, isCheckBox: false, photoId: nil, photoObjectName: nil)
        uvcOptionViewModelLocal._id = _id
        uvcOptionViewModelLocal.uvcViewModel = uvcViewModel
        uvcOptionViewModelLocal.level = level
        uvcOptionViewModelLocal.isMultiSelect = true
        
        return uvcOptionViewModelLocal
    }
    
    
    
    private func getAnalyticAndSaveDocumentTime(udcDocumentTime: UDCDocumentTime, objectName: String, profileId: String, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws -> UDCAnalytic {
        var udcAnalytic = UDCAnalytic()
        
        if objectName == "UDCDocumentTime" {
            let databaseOrmResultUDCDocumentTime = UDCDocumentTime.save(udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentTime)
            if databaseOrmResultUDCDocumentTime.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentTime.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentTime.databaseOrmError[0].description))
                return udcAnalytic
            }
            let documentTimeId = udcDocumentTime._id
            udcAnalytic.udcAnalyticItemCategoryIdName = "UDCAnalyticItemCategory.Document"
            udcAnalytic.udcAnalyticItemIdName = "UDCAnalyticItem.DocumentTime"
            udcAnalytic.objectName = "UDCDocumentTime"
            udcAnalytic.objectId = documentTimeId
        }
        
        return udcAnalytic
    }
    
    private func getUDCDocumentTimeCreated(profileId: String, language: String) throws -> UDCDocumentTime {
        let udcDocumentTime = UDCDocumentTime()
        udcDocumentTime._id = try udbcDatabaseOrm!.generateId()
        udcDocumentTime.creationTime = Date()
        udcDocumentTime.createdBy = profileId
        udcDocumentTime.language = language
        
        return udcDocumentTime
    }
    
    private func getUDCDocumentTimeChanged(profileId: String, language: String) throws -> UDCDocumentTime {
        let udcDocumentTime = UDCDocumentTime()
        udcDocumentTime._id = try udbcDatabaseOrm!.generateId()
        udcDocumentTime.changedTime = Date()
        udcDocumentTime.changedBy = profileId
        udcDocumentTime.language = language
        
        return udcDocumentTime
    }
    
    private func searchRecipeItem(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
//        let documentItemSearchResultRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: DocumentItemSearchResultRequest())
//        
//        let documentItemSearchResultResponse = DocumentItemSearchResultResponse()
//        
//        documentItemSearchResultResponse.status = try! search(text: documentItemSearchResultRequest.documentGraphItemSearchRequest.text, udcDocumentItemMapNode: documentItemSearchResultRequest.udcDocumentItemMapNode, uvcOptionViewModel: &documentItemSearchResultResponse.uvcOptionViewModel, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, documentGraphItemSearchRequest: documentItemSearchResultRequest.documentGraphItemSearchRequest, searchPhase: documentItemSearchResultRequest.searchPhase)
//        
//        let jsonUtilityDocumentItemSearchResultResponse = JsonUtility<DocumentItemSearchResultResponse>()
//        let jsonDocumentItemSearchResultResponse = jsonUtilityDocumentItemSearchResultResponse.convertAnyObjectToJson(jsonObject: documentItemSearchResultResponse)
//        
//        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonDocumentItemSearchResultResponse)
    }
    
    private func getOptionViewModel(parentId: String, parentPath: [String], parentPathIdName: [String], objectName: String, idName: String, name: String, category: String, subCategory: String, subCategoryIdName: String, level: Int, rowLength: Int, language: String, isCheckBox: Bool) -> UVCOptionViewModel {
        var tempPath = parentPath
        tempPath.remove(at: tempPath.count - 1)
        
        let uvcOptionViewModelLocal = UVCOptionViewModel()
        uvcOptionViewModelLocal.objectCategoryIdName = subCategoryIdName
        uvcOptionViewModelLocal.objectIdName = idName
        uvcOptionViewModelLocal.parentId.append(parentId)
        uvcOptionViewModelLocal.objectName = objectName
        uvcOptionViewModelLocal.pathIdName.append(parentPathIdName)
        uvcOptionViewModelLocal.pathIdName[0].append(idName)
        uvcOptionViewModelLocal.level = level
        uvcOptionViewModelLocal.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: name, description: "", category: category, subCategory: subCategory, language: language, isChildrenExist: false, isEditable: false, isCheckBox: isCheckBox, photoId: nil, photoObjectName: nil)
        uvcOptionViewModelLocal.uvcViewModel.rowLength = rowLength
        
        return uvcOptionViewModelLocal
    }
    
//    private func search(text: String, udcDocumentItemMapNode: UDCDocumentItemMapNode, uvcOptionViewModel: inout [UVCOptionViewModel], neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest, documentGraphItemSearchRequest: DocumentGraphItemSearchRequest, searchPhase: Int) throws -> Bool {
//        let documentLanguage = documentGraphItemSearchRequest.documentLanguage
//        var searchResult = false
//        var tempPath = documentGraphItemSearchRequest.path
//        tempPath.remove(at: tempPath.count - 1)
//        let pattern = "\(text)"
//
//        if udcDocumentItemMapNode.idName == "UDCDocumentItemMapNode.Ingredient"  {
//            searchResult = true
//            var databaseOrmResultType : DatabaseOrmResult<UDCIngredientType>?
//            if searchPhase == 1 {
//                databaseOrmResultType = UDCIngredientType.getOne(text, udbcDatabaseOrm!, documentLanguage)
//            } else if documentGraphItemSearchRequest.isByCategory || documentGraphItemSearchRequest.isBySubCategory {
//                databaseOrmResultType = UDCIngredientType.get(limitedTo: 0, sortedBy: "name", category: "", udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            } else {
//                databaseOrmResultType = try UDCIngredientType.search(text: pattern, udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            }
//            if databaseOrmResultType!.databaseOrmError.count == 0 {
//                for udci in databaseOrmResultType!.object {
//                    let databaseOrmResultUDCIngredientCategoryType = UDCIngredientCategoryType.get(udci.udcIngredientCategoryIdName, udbcDatabaseOrm!, documentLanguage)
//                    if databaseOrmResultUDCIngredientCategoryType.databaseOrmError.count > 0 {
//                        for databaseError in databaseOrmResultUDCIngredientCategoryType.databaseOrmError {
//                            neuronResponse = neuronUtility!.getNeuronResponseError(neuronRequest: neuronRequest, errorName: databaseError.name, errorDescription:  databaseError.description)
//                        }
//                        return searchResult
//                    }
//                    let subCategory = databaseOrmResultUDCIngredientCategoryType.object[0].name
//                    if documentGraphItemSearchRequest.isBySubCategory && !subCategory.lowercased().contains(documentGraphItemSearchRequest.text) {
//                        continue
//                    }
//                    let uvcOptionViewModelLocal = getOptionViewModel(parentId: documentGraphItemSearchRequest.optionItemId, parentPath: documentGraphItemSearchRequest.path[0], parentPathIdName: ["UDCDocumentItemMapNode.DocumentItems"], objectName: udcDocumentItemMapNode.objectName, idName: udci.idName, name: udci.name, category: udcDocumentItemMapNode.name.capitalized, subCategory: subCategory, subCategoryIdName: databaseOrmResultUDCIngredientCategoryType.object[0].idName, level: 1, rowLength: 3, language: documentLanguage, isCheckBox: false)
//                    uvcOptionViewModel.append(uvcOptionViewModelLocal)
//                }
//                let databaseOrmResultTypePatttern = try UDCWordPatternType.search(rootWordIdName: "UDCIngredient", text: pattern, udbcDatabaseOrm!, documentLanguage)
//                if databaseOrmResultTypePatttern.databaseOrmError.count == 0 {
//                    var databaseOrmResultUDCIngredientType: DatabaseOrmResult<UDCIngredientType>?
//                    var subCategory: String = ""
//                    var subCategoryIdName: String = ""
//                    for (udciIndex, udci) in databaseOrmResultTypePatttern.object.enumerated() {
//                        if udciIndex == 0 {
//                            databaseOrmResultUDCIngredientType = UDCIngredientType.get(idName: udci.rootWordIdName, udbcDatabaseOrm!, documentLanguage)
//                            let databaseOrmResultUDCIngredientCategoryType = UDCIngredientCategoryType.get(databaseOrmResultUDCIngredientType!.object[0].udcIngredientCategoryIdName, udbcDatabaseOrm!, documentLanguage)
//                            if databaseOrmResultUDCIngredientCategoryType.databaseOrmError.count > 0 {
//                                for databaseError in databaseOrmResultUDCIngredientCategoryType.databaseOrmError {
//                                    neuronResponse = neuronUtility!.getNeuronResponseError(neuronRequest: neuronRequest, errorName: databaseError.name, errorDescription:  databaseError.description)
//                                }
//                                return searchResult
//                            }
//                            subCategory = databaseOrmResultUDCIngredientCategoryType.object[0].name
//                            subCategoryIdName = databaseOrmResultUDCIngredientCategoryType.object[0].idName
//                        }
//                        let uvcOptionViewModelLocal = getOptionViewModel(parentId: documentGraphItemSearchRequest.optionItemId, parentPath: documentGraphItemSearchRequest.path[0], parentPathIdName: ["UDCDocumentItemMapNode.DocumentItems"], objectName: udcDocumentItemMapNode.objectName, idName: udci.idName, name: udci.name, category: udcDocumentItemMapNode.name.capitalized, subCategory: subCategory, subCategoryIdName: subCategoryIdName, level: 1, rowLength: 2, language: documentLanguage, isCheckBox: false)
//                        uvcOptionViewModel.append(uvcOptionViewModelLocal)
//                    }
//                }
//            } else {
//                if searchPhase == 1 {
//                    let databaseOrmResultTypePatttern = try UDCWordPatternType.get(rootWordIdName: "UDCIngredient", name: pattern, udbcDatabaseOrm!, documentLanguage)
//                    if databaseOrmResultTypePatttern.databaseOrmError.count == 0 {
//                        databaseOrmResultType!.databaseOrmError.append(DatabaseOrmError()) // So that cannot process below
//                        var databaseOrmResultUDCIngredientType: DatabaseOrmResult<UDCIngredientType>?
//                        var subCategory: String = ""
//                        var subCategoryIdName: String = ""
//                        for (udciIndex, udci) in databaseOrmResultTypePatttern.object.enumerated() {
//                            if udciIndex == 0 {
//                                databaseOrmResultUDCIngredientType = UDCIngredientType.get(idName: udci.rootWordIdName, udbcDatabaseOrm!, documentLanguage)
//                                let databaseOrmResultUDCIngredientCategoryType = UDCIngredientCategoryType.get(databaseOrmResultUDCIngredientType!.object[0].udcIngredientCategoryIdName, udbcDatabaseOrm!, documentLanguage)
//                                if databaseOrmResultUDCIngredientCategoryType.databaseOrmError.count > 0 {
//                                    for databaseError in databaseOrmResultUDCIngredientCategoryType.databaseOrmError {
//                                        neuronResponse = neuronUtility!.getNeuronResponseError(neuronRequest: neuronRequest, errorName: databaseError.name, errorDescription:  databaseError.description)
//                                    }
//                                    return searchResult
//                                }
//                                subCategory = databaseOrmResultUDCIngredientCategoryType.object[0].name
//                                subCategoryIdName = databaseOrmResultUDCIngredientCategoryType.object[0].idName
//                            }
//                            let uvcOptionViewModelLocal = getOptionViewModel(parentId: documentGraphItemSearchRequest.optionItemId, parentPath: documentGraphItemSearchRequest.path[0], parentPathIdName: ["UDCDocumentItemMapNode.DocumentItems"], objectName: udcDocumentItemMapNode.objectName, idName: udci.idName, name: udci.name, category: udcDocumentItemMapNode.name.capitalized, subCategory: subCategory, subCategoryIdName: subCategoryIdName, level: 1, rowLength: 2, language: documentLanguage, isCheckBox: false)
//                            uvcOptionViewModel.append(uvcOptionViewModelLocal)
//                        }
//                    }
//                }
//            }
//        } else if udcDocumentItemMapNode.idName == "UDCDocumentItemMapNode.TimeUnit" && !documentGraphItemSearchRequest.isBySubCategory {
//            searchResult = true
//            var databaseOrmResultType : DatabaseOrmResult<UDCTimeUnitType>?
//            if searchPhase == 1 {
//                databaseOrmResultType = UDCTimeUnitType.getOne(text, udbcDatabaseOrm!, documentLanguage)
//            } else if documentGraphItemSearchRequest.isByCategory {
//                databaseOrmResultType = UDCTimeUnitType.get(limitedTo: 0, sortedBy: "name", udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            } else {
//                databaseOrmResultType = try UDCTimeUnitType.search(text: text, udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            }
//
//            if databaseOrmResultType!.databaseOrmError.count == 0 {
//                for udci in databaseOrmResultType!.object {
//
//                    let uvcOptionViewModelLocal = UVCOptionViewModel()
//                    uvcOptionViewModelLocal.objectIdName = udci.idName
//                    uvcOptionViewModelLocal.parentId.append(documentGraphItemSearchRequest.optionItemId)
//                    uvcOptionViewModelLocal.objectName = udcDocumentItemMapNode.objectName
//                    uvcOptionViewModelLocal.pathIdName.append(["UDCDocumentItemMapNode.DocumentItems"])
//                    uvcOptionViewModelLocal.pathIdName[0].append(udci.idName)
//                    uvcOptionViewModelLocal.level = 1
//                    uvcOptionViewModelLocal.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: udci.name, description: "", category: udcDocumentItemMapNode.name.capitalized, subCategory: "", language: documentLanguage, isChildrenExist: false, isEditable: false, isCheckBox: false, photoId: nil, photoObjectName: nil)
//                    uvcOptionViewModelLocal.uvcViewModel.rowLength = 2
//                    uvcOptionViewModel.append(uvcOptionViewModelLocal)
//                }
//            }
//        } else if udcDocumentItemMapNode.idName == "UDCDocumentItemMapNode.MassUnit" && !documentGraphItemSearchRequest.isBySubCategory {
//            searchResult = true
//            var databaseOrmResultType : DatabaseOrmResult<UDCMassUnitType>?
//            if searchPhase == 1 {
//                databaseOrmResultType = UDCMassUnitType.getOne(text, udbcDatabaseOrm!, documentLanguage)
//            } else if documentGraphItemSearchRequest.isByCategory {
//                databaseOrmResultType = UDCMassUnitType.get(limitedTo: 0, sortedBy: "name", udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            } else {
//                databaseOrmResultType = try UDCMassUnitType.search(text: text, udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            }
//
//            if databaseOrmResultType!.databaseOrmError.count == 0 {
//                for udci in databaseOrmResultType!.object {
//
//                    let uvcOptionViewModelLocal = UVCOptionViewModel()
//                    uvcOptionViewModelLocal.objectIdName = udci.idName
//                    uvcOptionViewModelLocal.parentId.append(documentGraphItemSearchRequest.optionItemId)
//                    uvcOptionViewModelLocal.objectName = udcDocumentItemMapNode.objectName
//                    uvcOptionViewModelLocal.pathIdName.append(["UDCDocumentItemMapNode.DocumentItems"])
//                    uvcOptionViewModelLocal.pathIdName[0].append(udci.idName)
//                    uvcOptionViewModelLocal.level = 1
//                    uvcOptionViewModelLocal.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: udci.name, description: "", category: udcDocumentItemMapNode.name.capitalized, subCategory: "", language: documentLanguage, isChildrenExist: false, isEditable: false, isCheckBox: false, photoId: nil, photoObjectName: nil)
//                    uvcOptionViewModelLocal.uvcViewModel.rowLength = 2
//                    uvcOptionViewModel.append(uvcOptionViewModelLocal)
//                }
//            }
//        } else if udcDocumentItemMapNode.idName == "UDCDocumentItemMapNode.VolumeUnit" && !documentGraphItemSearchRequest.isBySubCategory {
//            searchResult = true
//            var databaseOrmResultType : DatabaseOrmResult<UDCVolumeUnitType>?
//            if searchPhase == 1 {
//                databaseOrmResultType = UDCVolumeUnitType.getOne(text, udbcDatabaseOrm!, documentLanguage)
//            } else if documentGraphItemSearchRequest.isByCategory {
//                databaseOrmResultType = UDCVolumeUnitType.get(limitedTo: 0, sortedBy: "name", udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            } else {
//                databaseOrmResultType = try UDCVolumeUnitType.search(text: text, udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            }
//
//            if databaseOrmResultType!.databaseOrmError.count == 0 {
//                for udci in databaseOrmResultType!.object {
//
//                    let uvcOptionViewModelLocal = UVCOptionViewModel()
//                    uvcOptionViewModelLocal.objectIdName = udci.idName
//                    uvcOptionViewModelLocal.parentId.append(documentGraphItemSearchRequest.optionItemId)
//                    uvcOptionViewModelLocal.objectName = udcDocumentItemMapNode.objectName
//                    uvcOptionViewModelLocal.pathIdName.append(["UDCDocumentItemMapNode.DocumentItems"])
//                    uvcOptionViewModelLocal.pathIdName[0].append(udci.idName)
//                    uvcOptionViewModelLocal.level = 1
//                    uvcOptionViewModelLocal.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: udci.name, description: "", category: udcDocumentItemMapNode.name.capitalized, subCategory: "", language: documentLanguage, isChildrenExist: false, isEditable: false, isCheckBox: false, photoId: nil, photoObjectName: nil)
//                    uvcOptionViewModelLocal.uvcViewModel.rowLength = 2
//                    uvcOptionViewModel.append(uvcOptionViewModelLocal)
//                }
//            }
//        } else if udcDocumentItemMapNode.idName == "UDCDocumentItemMapNode.TemperatureUnit" && !documentGraphItemSearchRequest.isBySubCategory {
//            searchResult = true
//            var databaseOrmResultType : DatabaseOrmResult<UDCTemperatureUnitType>?
//            if searchPhase == 1 {
//                databaseOrmResultType = UDCTemperatureUnitType.getOne(text, udbcDatabaseOrm!, documentLanguage)
//            } else if documentGraphItemSearchRequest.isByCategory {
//                databaseOrmResultType = UDCTemperatureUnitType.get(limitedTo: 0, sortedBy: "name", udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            } else {
//                databaseOrmResultType = try UDCTemperatureUnitType.search(text: text, udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            }
//
//            if databaseOrmResultType!.databaseOrmError.count == 0 {
//                for udci in databaseOrmResultType!.object {
//
//                    let uvcOptionViewModelLocal = UVCOptionViewModel()
//                    uvcOptionViewModelLocal.objectIdName = udci.idName
//                    uvcOptionViewModelLocal.parentId.append(documentGraphItemSearchRequest.optionItemId)
//                    uvcOptionViewModelLocal.objectName = udcDocumentItemMapNode.objectName
//                    uvcOptionViewModelLocal.pathIdName.append(["UDCDocumentItemMapNode.DocumentItems"])
//                    uvcOptionViewModelLocal.pathIdName[0].append(udci.idName)
//                    uvcOptionViewModelLocal.level = 1
//                    uvcOptionViewModelLocal.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: udci.name, description: "", category: udcDocumentItemMapNode.name.capitalized, subCategory: "", language: documentLanguage, isChildrenExist: false, isEditable: false, isCheckBox: false, photoId: nil, photoObjectName: nil)
//                    uvcOptionViewModelLocal.uvcViewModel.rowLength = 2
//                    uvcOptionViewModel.append(uvcOptionViewModelLocal)
//                }
//            }
//        } else if udcDocumentItemMapNode.idName == "UDCDocumentItemMapNode.LengthUnit" && !documentGraphItemSearchRequest.isBySubCategory {
//            searchResult = true
//            var databaseOrmResultType : DatabaseOrmResult<UDCLengthUnitType>?
//            if searchPhase == 1 {
//                databaseOrmResultType = UDCLengthUnitType.getOne(text, udbcDatabaseOrm!, documentLanguage)
//            } else if documentGraphItemSearchRequest.isByCategory {
//                databaseOrmResultType = UDCLengthUnitType.get(limitedTo: 0, sortedBy: "name", udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            } else {
//                databaseOrmResultType = try UDCLengthUnitType.search(text: text, udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            }
//
//            if databaseOrmResultType!.databaseOrmError.count == 0 {
//                for udci in databaseOrmResultType!.object {
//
//                    let uvcOptionViewModelLocal = UVCOptionViewModel()
//                    uvcOptionViewModelLocal.objectIdName = udci.idName
//                    uvcOptionViewModelLocal.parentId.append(documentGraphItemSearchRequest.optionItemId)
//                    uvcOptionViewModelLocal.objectName = udcDocumentItemMapNode.objectName
//                    uvcOptionViewModelLocal.pathIdName.append(["UDCDocumentItemMapNode.DocumentItems"])
//                    uvcOptionViewModelLocal.pathIdName[0].append(udci.idName)
//                    uvcOptionViewModelLocal.level = 1
//                    uvcOptionViewModelLocal.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: udci.name, description: "", category: udcDocumentItemMapNode.name.capitalized, subCategory: "", language: documentLanguage, isChildrenExist: false, isEditable: false, isCheckBox: false, photoId: nil, photoObjectName: nil)
//                    uvcOptionViewModelLocal.uvcViewModel.rowLength = 2
//                    uvcOptionViewModel.append(uvcOptionViewModelLocal)
//                }
//            }
//        } else if udcDocumentItemMapNode.idName == "UDCDocumentItemMapNode.FoodCutting" && !documentGraphItemSearchRequest.isBySubCategory {
//            searchResult = true
//            var databaseOrmResultType : DatabaseOrmResult<UDCFoodCuttingType>?
//            if searchPhase == 1 {
//                databaseOrmResultType = UDCFoodCuttingType.getOne(text, udbcDatabaseOrm!, documentLanguage)
//            } else if documentGraphItemSearchRequest.isByCategory {
//                databaseOrmResultType = UDCFoodCuttingType.get(limitedTo: 0, sortedBy: "name", udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            } else {
//                databaseOrmResultType = try UDCFoodCuttingType.search(text: text, udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            }
//            if databaseOrmResultType!.databaseOrmError.count == 0 {
//                for udci in databaseOrmResultType!.object {
//
//                    let uvcOptionViewModelLocal = UVCOptionViewModel()
//                    uvcOptionViewModelLocal.objectIdName = udci.idName
//                    uvcOptionViewModelLocal.parentId.append(documentGraphItemSearchRequest.optionItemId)
//                    uvcOptionViewModelLocal.objectName = udcDocumentItemMapNode.objectName
//                    uvcOptionViewModelLocal.pathIdName.append(["UDCDocumentItemMapNode.DocumentItems"])
//                    uvcOptionViewModelLocal.pathIdName[0].append(udci.idName)
//                    uvcOptionViewModelLocal.level = 1
//                    uvcOptionViewModelLocal.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: udci.name, description: "", category: udcDocumentItemMapNode.name.capitalized, subCategory: "", language: documentLanguage, isChildrenExist: false, isEditable: false, isCheckBox: false, photoId: nil, photoObjectName: nil)
//                    uvcOptionViewModelLocal.uvcViewModel.rowLength = 2
//                    uvcOptionViewModel.append(uvcOptionViewModelLocal)
//                }
//                let databaseOrmResultTypePatttern = try UDCWordPatternType.search(rootWordIdName: "UDCFoodCutting", text: pattern, udbcDatabaseOrm!, documentLanguage)
//                if databaseOrmResultTypePatttern.databaseOrmError.count == 0 {
//                    for udci in databaseOrmResultTypePatttern.object {
//                        let uvcOptionViewModelLocal = getOptionViewModel(parentId: documentGraphItemSearchRequest.optionItemId, parentPath: documentGraphItemSearchRequest.path[0], parentPathIdName: ["UDCDocumentItemMapNode.DocumentItems"], objectName: udcDocumentItemMapNode.objectName, idName: udci.idName, name: udci.name, category: udcDocumentItemMapNode.name.capitalized, subCategory: "", subCategoryIdName: "", level: 1, rowLength: 2, language: documentLanguage, isCheckBox: false)
//                        uvcOptionViewModel.append(uvcOptionViewModelLocal)
//                    }
//                }
//            } else {
//                if searchPhase == 1 {
//                    let databaseOrmResultTypePatttern = try UDCWordPatternType.get(rootWordIdName: "UDCFoodCutting", name: pattern, udbcDatabaseOrm!, documentLanguage)
//                    if databaseOrmResultTypePatttern.databaseOrmError.count == 0 {
//                        databaseOrmResultType!.databaseOrmError.append(DatabaseOrmError()) // So that cannot process below
//                        for udci in databaseOrmResultTypePatttern.object {
//                            let uvcOptionViewModelLocal = getOptionViewModel(parentId: documentGraphItemSearchRequest.optionItemId, parentPath: documentGraphItemSearchRequest.path[0], parentPathIdName: ["UDCDocumentItemMapNode.DocumentItems"], objectName: udcDocumentItemMapNode.objectName, idName: udci.idName, name: udci.name, category: udcDocumentItemMapNode.name.capitalized, subCategory: "", subCategoryIdName: "", level: 1, rowLength: 2, language: documentLanguage, isCheckBox: false)
//                            uvcOptionViewModel.append(uvcOptionViewModelLocal)
//                        }
//                    }
//                }
//            }
//        }  else if udcDocumentItemMapNode.idName == "UDCDocumentItemMapNode.ItemState" && !documentGraphItemSearchRequest.isBySubCategory {
//            searchResult = true
//            var databaseOrmResultType : DatabaseOrmResult<UDCItemStateType>?
//            if searchPhase == 1 {
//                databaseOrmResultType = UDCItemStateType.getOne(text, udbcDatabaseOrm!, documentLanguage)
//            } else if documentGraphItemSearchRequest.isByCategory {
//                databaseOrmResultType = UDCItemStateType.get(limitedTo: 0, sortedBy: "name", udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            } else {
//                databaseOrmResultType = try UDCItemStateType.search(text: text, udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            }
//            if databaseOrmResultType!.databaseOrmError.count == 0 {
//                for udci in databaseOrmResultType!.object {
//
//                    let uvcOptionViewModelLocal = UVCOptionViewModel()
//                    uvcOptionViewModelLocal.objectIdName = udci.idName
//                    uvcOptionViewModelLocal.parentId.append(documentGraphItemSearchRequest.optionItemId)
//                    uvcOptionViewModelLocal.objectName = udcDocumentItemMapNode.objectName
//                    uvcOptionViewModelLocal.pathIdName.append(["UDCDocumentItemMapNode.DocumentItems"])
//                    uvcOptionViewModelLocal.pathIdName[0].append(udci.idName)
//                    uvcOptionViewModelLocal.level = 1
//                    uvcOptionViewModelLocal.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: udci.name, description: "", category: udcDocumentItemMapNode.name.capitalized, subCategory: "", language: documentLanguage, isChildrenExist: false, isEditable: false, isCheckBox: false, photoId: nil, photoObjectName: nil)
//                    uvcOptionViewModelLocal.uvcViewModel.rowLength = 2
//                    uvcOptionViewModel.append(uvcOptionViewModelLocal)
//                }
//                let databaseOrmResultTypePatttern = try UDCWordPatternType.search(rootWordIdName: "UDCItemState", text: pattern, udbcDatabaseOrm!, documentLanguage)
//                if databaseOrmResultTypePatttern.databaseOrmError.count == 0 {
//                    for udci in databaseOrmResultTypePatttern.object {
//                        let uvcOptionViewModelLocal = getOptionViewModel(parentId: documentGraphItemSearchRequest.optionItemId, parentPath: documentGraphItemSearchRequest.path[0], parentPathIdName: ["UDCDocumentItemMapNode.DocumentItems"], objectName: udcDocumentItemMapNode.objectName, idName: udci.idName, name: udci.name, category: udcDocumentItemMapNode.name.capitalized, subCategory: "", subCategoryIdName: "", level: 1, rowLength: 2, language: documentLanguage, isCheckBox: false)
//                        uvcOptionViewModel.append(uvcOptionViewModelLocal)
//                    }
//                }
//            } else {
//                if searchPhase == 1 {
//                    let databaseOrmResultTypePatttern = try UDCWordPatternType.get(rootWordIdName: "UDCItemState", name: pattern, udbcDatabaseOrm!, documentLanguage)
//                    if databaseOrmResultTypePatttern.databaseOrmError.count == 0 {
//                        databaseOrmResultType!.databaseOrmError.append(DatabaseOrmError()) // So that cannot process below
//                        for udci in databaseOrmResultTypePatttern.object {
//                            let uvcOptionViewModelLocal = getOptionViewModel(parentId: documentGraphItemSearchRequest.optionItemId, parentPath: documentGraphItemSearchRequest.path[0], parentPathIdName: ["UDCDocumentItemMapNode.DocumentItems"], objectName: udcDocumentItemMapNode.objectName, idName: udci.idName, name: udci.name, category: udcDocumentItemMapNode.name.capitalized, subCategory: "", subCategoryIdName: "", level: 1, rowLength: 2, language: documentLanguage, isCheckBox: false)
//                            uvcOptionViewModel.append(uvcOptionViewModelLocal)
//                        }
//                    }
//                }
//            }
//        } else if udcDocumentItemMapNode.idName == "UDCDocumentItemMapNode.CookingDevice" && !documentGraphItemSearchRequest.isBySubCategory {
//            searchResult = true
//            var databaseOrmResultType : DatabaseOrmResult<UDCCookingDeviceType>?
//            if searchPhase == 1 {
//                databaseOrmResultType = UDCCookingDeviceType.getOne(text, udbcDatabaseOrm!, documentLanguage)
//            } else if documentGraphItemSearchRequest.isByCategory {
//                databaseOrmResultType = UDCCookingDeviceType.get(limitedTo: 0, sortedBy: "name", udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            } else {
//                databaseOrmResultType = try UDCCookingDeviceType.search(text: text, udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            }
//            if databaseOrmResultType!.databaseOrmError.count == 0 {
//                for udci in databaseOrmResultType!.object {
//
//                    let uvcOptionViewModelLocal = UVCOptionViewModel()
//                    uvcOptionViewModelLocal.objectIdName = udci.idName
//                    uvcOptionViewModelLocal.parentId.append(documentGraphItemSearchRequest.optionItemId)
//                    uvcOptionViewModelLocal.objectName = udcDocumentItemMapNode.objectName
//                    uvcOptionViewModelLocal.pathIdName.append(["UDCDocumentItemMapNode.DocumentItems"])
//                    uvcOptionViewModelLocal.pathIdName[0].append(udci.idName)
//                    uvcOptionViewModelLocal.level = 1
//                    uvcOptionViewModelLocal.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: udci.name, description: "", category: udcDocumentItemMapNode.name.capitalized, subCategory: "", language: documentLanguage, isChildrenExist: false, isEditable: false, isCheckBox: false, photoId: nil, photoObjectName: nil)
//                    uvcOptionViewModelLocal.uvcViewModel.rowLength = 2
//                    uvcOptionViewModel.append(uvcOptionViewModelLocal)
//                }
//                let databaseOrmResultTypePatttern = try UDCWordPatternType.search(rootWordIdName: "UDCCookingDevice", text: pattern, udbcDatabaseOrm!, documentLanguage)
//                if databaseOrmResultTypePatttern.databaseOrmError.count == 0 {
//                    for udci in databaseOrmResultTypePatttern.object {
//                        let uvcOptionViewModelLocal = getOptionViewModel(parentId: documentGraphItemSearchRequest.optionItemId, parentPath: documentGraphItemSearchRequest.path[0], parentPathIdName: ["UDCDocumentItemMapNode.DocumentItems"], objectName: udcDocumentItemMapNode.objectName, idName: udci.idName, name: udci.name, category: udcDocumentItemMapNode.name.capitalized, subCategory: "", subCategoryIdName: "", level: 1, rowLength: 2, language: documentLanguage, isCheckBox: false)
//                        uvcOptionViewModel.append(uvcOptionViewModelLocal)
//                    }
//                }
//            } else {
//                if searchPhase == 1 {
//                    let databaseOrmResultTypePatttern = try UDCWordPatternType.get(rootWordIdName: "UDCCookingDevice", name: pattern, udbcDatabaseOrm!, documentLanguage)
//                    if databaseOrmResultTypePatttern.databaseOrmError.count == 0 {
//                        databaseOrmResultType!.databaseOrmError.append(DatabaseOrmError()) // So that cannot process below
//                        for udci in databaseOrmResultTypePatttern.object {
//                            let uvcOptionViewModelLocal = getOptionViewModel(parentId: documentGraphItemSearchRequest.optionItemId, parentPath: documentGraphItemSearchRequest.path[0], parentPathIdName: ["UDCDocumentItemMapNode.DocumentItems"], objectName: udcDocumentItemMapNode.objectName, idName: udci.idName, name: udci.name, category: udcDocumentItemMapNode.name.capitalized, subCategory: "", subCategoryIdName: "", level: 1, rowLength: 2, language: documentLanguage, isCheckBox: false)
//                            uvcOptionViewModel.append(uvcOptionViewModelLocal)
//                        }
//                    }
//                }
//            }
//        }  else if udcDocumentItemMapNode.idName == "UDCDocumentItemMapNode.CookingTechnique" && !documentGraphItemSearchRequest.isBySubCategory {
//            searchResult = true
//            var databaseOrmResultType : DatabaseOrmResult<UDCCookingTechniqueType>?
//            if searchPhase == 1 {
//                databaseOrmResultType = UDCCookingTechniqueType.getOne(text, udbcDatabaseOrm!, documentLanguage)
//            } else if documentGraphItemSearchRequest.isByCategory {
//                databaseOrmResultType = UDCCookingTechniqueType.get(limitedTo: 0, sortedBy: "name", udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            } else {
//                databaseOrmResultType = try UDCCookingTechniqueType.search(text: text, udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            }
//            if databaseOrmResultType!.databaseOrmError.count == 0 {
//                for udci in databaseOrmResultType!.object {
//
//                    let uvcOptionViewModelLocal = UVCOptionViewModel()
//                    uvcOptionViewModelLocal.objectIdName = udci.idName
//                    uvcOptionViewModelLocal.parentId.append(documentGraphItemSearchRequest.optionItemId)
//                    uvcOptionViewModelLocal.objectName = udcDocumentItemMapNode.objectName
//                    uvcOptionViewModelLocal.pathIdName.append(["UDCDocumentItemMapNode.DocumentItems"])
//                    uvcOptionViewModelLocal.pathIdName[0].append(udci.idName)
//                    uvcOptionViewModelLocal.level = 1
//                    uvcOptionViewModelLocal.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: udci.name, description: "", category: udcDocumentItemMapNode.name.capitalized, subCategory: "", language: documentLanguage, isChildrenExist: false, isEditable: false, isCheckBox: false, photoId: nil, photoObjectName: nil)
//                    uvcOptionViewModelLocal.uvcViewModel.rowLength = 2
//                    uvcOptionViewModel.append(uvcOptionViewModelLocal)
//                }
//                let databaseOrmResultTypePatttern = try UDCWordPatternType.search(rootWordIdName: "UDCCookingTechnique", text: pattern, udbcDatabaseOrm!, documentLanguage)
//                if databaseOrmResultTypePatttern.databaseOrmError.count == 0 {
//                    for udci in databaseOrmResultTypePatttern.object {
//                        let uvcOptionViewModelLocal = getOptionViewModel(parentId: documentGraphItemSearchRequest.optionItemId, parentPath: documentGraphItemSearchRequest.path[0], parentPathIdName: ["UDCDocumentItemMapNode.DocumentItems"], objectName: udcDocumentItemMapNode.objectName, idName: udci.idName, name: udci.name, category: udcDocumentItemMapNode.name.capitalized, subCategory: "", subCategoryIdName: "", level: 1, rowLength: 2, language: documentLanguage, isCheckBox: false)
//                        uvcOptionViewModel.append(uvcOptionViewModelLocal)
//                    }
//                }
//            } else {
//                if searchPhase == 1 {
//                    let databaseOrmResultTypePatttern = try UDCWordPatternType.get(rootWordIdName: "UDCCookingTechnique", name: pattern, udbcDatabaseOrm!, documentLanguage)
//                    if databaseOrmResultTypePatttern.databaseOrmError.count == 0 {
//                        databaseOrmResultType!.databaseOrmError.append(DatabaseOrmError()) // So that cannot process below
//                        for udci in databaseOrmResultTypePatttern.object {
//                            let uvcOptionViewModelLocal = getOptionViewModel(parentId: documentGraphItemSearchRequest.optionItemId, parentPath: documentGraphItemSearchRequest.path[0], parentPathIdName: ["UDCDocumentItemMapNode.DocumentItems"], objectName: udcDocumentItemMapNode.objectName, idName: udci.idName, name: udci.name, category: udcDocumentItemMapNode.name.capitalized, subCategory: "", subCategoryIdName: "", level: 1, rowLength: 2, language: documentLanguage, isCheckBox: false)
//                            uvcOptionViewModel.append(uvcOptionViewModelLocal)
//                        }
//                    }
//                }
//            }
//        } else if udcDocumentItemMapNode.idName == "UDCDocumentItemMapNode.Cuisine" && !documentGraphItemSearchRequest.isBySubCategory {
//            searchResult = true
//            var databaseOrmResultType : DatabaseOrmResult<UDCCuisineType>?
//            if searchPhase == 1 {
//                databaseOrmResultType = UDCCuisineType.getOne(text, udbcDatabaseOrm!, documentLanguage)
//            } else if documentGraphItemSearchRequest.isByCategory {
//                databaseOrmResultType = UDCCuisineType.get(limitedTo: 0, sortedBy: "name", udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            } else {
//                databaseOrmResultType = try UDCCuisineType.search(text: text, udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            }
//            if databaseOrmResultType!.databaseOrmError.count == 0 {
//                for udci in databaseOrmResultType!.object {
//                    var subCategory = ""
//                    let databaseOrmResultUDCCountryType = UDCCountryType.get(udci.udcCountryIdName[0], udbcDatabaseOrm!, documentLanguage)
//                    if databaseOrmResultUDCCountryType.databaseOrmError.count == 0 {
//                        subCategory = databaseOrmResultUDCCountryType.object[0].name
//                    }
//                    let uvcOptionViewModelLocal = UVCOptionViewModel()
//                    uvcOptionViewModelLocal.objectIdName = udci.idName
//                    uvcOptionViewModelLocal.parentId.append(documentGraphItemSearchRequest.optionItemId)
//                    uvcOptionViewModelLocal.objectName = udcDocumentItemMapNode.objectName
//                    uvcOptionViewModelLocal.pathIdName.append(["UDCDocumentItemMapNode.DocumentItems"])
//                    uvcOptionViewModelLocal.pathIdName[0].append(udci.idName)
//                    uvcOptionViewModelLocal.level = 1
//                    uvcOptionViewModelLocal.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: udci.name, description: "", category: udcDocumentItemMapNode.name.capitalized, subCategory: subCategory, language: documentLanguage, isChildrenExist: false, isEditable: false, isCheckBox: false, photoId: nil, photoObjectName: nil)
//                    uvcOptionViewModelLocal.uvcViewModel.rowLength = 3
//                    uvcOptionViewModel.append(uvcOptionViewModelLocal)
//                }
//            }
//        }  else if udcDocumentItemMapNode.idName == "UDCDocumentItemMapNode.FoodTiming" && !documentGraphItemSearchRequest.isBySubCategory {
//            searchResult = true
//            var databaseOrmResultType : DatabaseOrmResult<UDCFoodTimingType>?
//            if searchPhase == 1 {
//                databaseOrmResultType = UDCFoodTimingType.getOne(text, udbcDatabaseOrm!, documentLanguage)
//            } else if documentGraphItemSearchRequest.isByCategory {
//                databaseOrmResultType = UDCFoodTimingType.get(limitedTo: 0, sortedBy: "name", udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            } else {
//                databaseOrmResultType = try UDCFoodTimingType.search(text: text, udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            }
//            if databaseOrmResultType!.databaseOrmError.count == 0 {
//                for udci in databaseOrmResultType!.object {
//                    var subCategory = ""
//                    let databaseOrmResultSubCategoryType = UDCFoodTimingCategoryType.get(udci.udcFoodTimingCategoryIdName, udbcDatabaseOrm!, documentLanguage)
//                    if databaseOrmResultSubCategoryType.databaseOrmError.count == 0 {
//                        subCategory = databaseOrmResultSubCategoryType.object[0].name
//                    }
//                    let uvcOptionViewModelLocal = UVCOptionViewModel()
//                    uvcOptionViewModelLocal.objectIdName = udci.idName
//                    uvcOptionViewModelLocal.parentId.append(documentGraphItemSearchRequest.optionItemId)
//                    uvcOptionViewModelLocal.objectName = udcDocumentItemMapNode.objectName
//                    uvcOptionViewModelLocal.pathIdName.append(["UDCDocumentItemMapNode.DocumentItems"])
//                    uvcOptionViewModelLocal.pathIdName[0].append(udci.idName)
//                    uvcOptionViewModelLocal.level = 1
//                    uvcOptionViewModelLocal.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: udci.name, description: "", category: udcDocumentItemMapNode.name.capitalized, subCategory: subCategory, language: documentLanguage, isChildrenExist: false, isEditable: false, isCheckBox: false, photoId: nil, photoObjectName: nil)
//                    uvcOptionViewModelLocal.uvcViewModel.rowLength = 3
//                    uvcOptionViewModel.append(uvcOptionViewModelLocal)
//                }
//            }
//        } else if udcDocumentItemMapNode.idName == "UDCDocumentItemMapNode.CardinalDirection" && !documentGraphItemSearchRequest.isBySubCategory {
//            searchResult = true
//            var databaseOrmResultType : DatabaseOrmResult<UDCCardinalDirectionType>?
//            if searchPhase == 1 {
//                databaseOrmResultType = UDCCardinalDirectionType.getOne(text, udbcDatabaseOrm!, documentLanguage)
//            } else if documentGraphItemSearchRequest.isByCategory {
//                databaseOrmResultType = UDCCardinalDirectionType.get(limitedTo: 0, sortedBy: "name", udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            } else {
//                databaseOrmResultType = try UDCCardinalDirectionType.search(text: text, udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            }
//            if databaseOrmResultType!.databaseOrmError.count == 0 {
//                for udci in databaseOrmResultType!.object {
//
//                    let uvcOptionViewModelLocal = UVCOptionViewModel()
//                    uvcOptionViewModelLocal.objectIdName = udci.idName
//                    uvcOptionViewModelLocal.parentId.append(documentGraphItemSearchRequest.optionItemId)
//                    uvcOptionViewModelLocal.objectName = udcDocumentItemMapNode.objectName
//                    uvcOptionViewModelLocal.pathIdName.append(["UDCDocumentItemMapNode.DocumentItems"])
//                    uvcOptionViewModelLocal.pathIdName[0].append(udci.idName)
//                    uvcOptionViewModelLocal.level = 1
//                    uvcOptionViewModelLocal.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: udci.name, description: "", category: udcDocumentItemMapNode.name.capitalized, subCategory: "", language: documentLanguage, isChildrenExist: false, isEditable: false, isCheckBox: false, photoId: nil, photoObjectName: nil)
//                    uvcOptionViewModelLocal.uvcViewModel.rowLength = 2
//                    uvcOptionViewModel.append(uvcOptionViewModelLocal)
//                }
//            }
//        } else if udcDocumentItemMapNode.idName == "UDCDocumentItemMapNode.Country" && !documentGraphItemSearchRequest.isBySubCategory {
//            searchResult = true
//            var databaseOrmResultType : DatabaseOrmResult<UDCCountryType>?
//            if searchPhase == 1 {
//                databaseOrmResultType = UDCCountryType.getOne(text, udbcDatabaseOrm!, documentLanguage)
//            } else if documentGraphItemSearchRequest.isByCategory {
//                databaseOrmResultType = UDCCountryType.get(limitedTo: 0, sortedBy: "name", udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            } else {
//                databaseOrmResultType = try UDCCountryType.search(text: text, udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            }
//            if databaseOrmResultType!.databaseOrmError.count == 0 {
//                for udci in databaseOrmResultType!.object {
//                    var subCategory = ""
//                    let databaseOrmResultSubCategoryType = UDCContinentType.get(udci.udcContinentIdName, udbcDatabaseOrm!, documentLanguage)
//                    if databaseOrmResultSubCategoryType.databaseOrmError.count == 0 {
//                        subCategory = databaseOrmResultSubCategoryType.object[0].name
//                    }
//                    let uvcOptionViewModelLocal = UVCOptionViewModel()
//                    uvcOptionViewModelLocal.objectIdName = udci.idName
//                    uvcOptionViewModelLocal.parentId.append(documentGraphItemSearchRequest.optionItemId)
//                    uvcOptionViewModelLocal.objectName = udcDocumentItemMapNode.objectName
//                    uvcOptionViewModelLocal.pathIdName.append(["UDCDocumentItemMapNode.DocumentItems"])
//                    uvcOptionViewModelLocal.pathIdName[0].append(udci.idName)
//                    uvcOptionViewModelLocal.level = 1
//                    uvcOptionViewModelLocal.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: udci.name, description: "", category: udcDocumentItemMapNode.name.capitalized, subCategory: subCategory, language: documentLanguage, isChildrenExist: false, isEditable: false, isCheckBox: false, photoId: nil, photoObjectName: nil)
//                    uvcOptionViewModelLocal.uvcViewModel.rowLength = 3
//                    uvcOptionViewModel.append(uvcOptionViewModelLocal)
//                }
//            }
//        } else if udcDocumentItemMapNode.idName == "UDCDocumentItemMapNode.State" && !documentGraphItemSearchRequest.isBySubCategory {
//            searchResult = true
//            var databaseOrmResultType : DatabaseOrmResult<UDCStateType>?
//            if searchPhase == 1 {
//                databaseOrmResultType = UDCStateType.getOne(text, udbcDatabaseOrm!, documentLanguage)
//            } else if documentGraphItemSearchRequest.isByCategory {
//                databaseOrmResultType = UDCStateType.get(limitedTo: 0, sortedBy: "name", udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            } else {
//                databaseOrmResultType = try UDCStateType.search(text: text, udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            }
//            if databaseOrmResultType!.databaseOrmError.count == 0 {
//                for udci in databaseOrmResultType!.object {
//                    var subCategory = ""
//                    let databaseOrmResultSubCategoryType = UDCCountryType.get(udci.udcCountryIdName, udbcDatabaseOrm!, documentLanguage)
//                    if databaseOrmResultSubCategoryType.databaseOrmError.count == 0 {
//                        subCategory = databaseOrmResultSubCategoryType.object[0].name
//                    }
//                    let uvcOptionViewModelLocal = UVCOptionViewModel()
//                    uvcOptionViewModelLocal.objectIdName = udci.idName
//                    uvcOptionViewModelLocal.parentId.append(documentGraphItemSearchRequest.optionItemId)
//                    uvcOptionViewModelLocal.objectName = udcDocumentItemMapNode.objectName
//                    uvcOptionViewModelLocal.pathIdName.append(["UDCDocumentItemMapNode.DocumentItems"])
//                    uvcOptionViewModelLocal.pathIdName[0].append(udci.idName)
//                    uvcOptionViewModelLocal.level = 1
//                    uvcOptionViewModelLocal.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: udci.name, description: "", category: udcDocumentItemMapNode.name.capitalized, subCategory: subCategory, language: documentLanguage, isChildrenExist: false, isEditable: false, isCheckBox: false, photoId: nil, photoObjectName: nil)
//                    uvcOptionViewModelLocal.uvcViewModel.rowLength = 3
//                    uvcOptionViewModel.append(uvcOptionViewModelLocal)
//                }
//            }
//        } else if udcDocumentItemMapNode.idName == "UDCDocumentItemMapNode.Continent" && !documentGraphItemSearchRequest.isBySubCategory {
//            searchResult = true
//            var databaseOrmResultType : DatabaseOrmResult<UDCContinentType>?
//            if searchPhase == 1 {
//                databaseOrmResultType = UDCContinentType.getOne(text, udbcDatabaseOrm!, documentLanguage)
//            } else if documentGraphItemSearchRequest.isByCategory {
//                databaseOrmResultType = UDCContinentType.get(limitedTo: 0, sortedBy: "name", udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            } else {
//                databaseOrmResultType = try UDCContinentType.search(text: text, udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            }
//            if databaseOrmResultType!.databaseOrmError.count == 0 {
//                for udci in databaseOrmResultType!.object {
//                    let uvcOptionViewModelLocal = UVCOptionViewModel()
//                    uvcOptionViewModelLocal.objectIdName = udci.idName
//                    uvcOptionViewModelLocal.parentId.append(documentGraphItemSearchRequest.optionItemId)
//                    uvcOptionViewModelLocal.objectName = udcDocumentItemMapNode.objectName
//                    uvcOptionViewModelLocal.pathIdName.append(["UDCDocumentItemMapNode.DocumentItems"])
//                    uvcOptionViewModelLocal.pathIdName[0].append(udci.idName)
//                    uvcOptionViewModelLocal.level = 1
//                    uvcOptionViewModelLocal.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: udci.name, description: "", category: udcDocumentItemMapNode.name.capitalized, subCategory: "", language: documentLanguage, isChildrenExist: false, isEditable: false, isCheckBox: false, photoId: nil, photoObjectName: nil)
//                    uvcOptionViewModelLocal.uvcViewModel.rowLength = 3
//                    uvcOptionViewModel.append(uvcOptionViewModelLocal)
//                }
//            }
//        }  else if udcDocumentItemMapNode.idName == "UDCDocumentItemMapNode.City" && !documentGraphItemSearchRequest.isBySubCategory {
//            searchResult = true
//            var databaseOrmResultType : DatabaseOrmResult<UDCCityType>?
//            if searchPhase == 1 {
//                databaseOrmResultType = UDCCityType.getOne(text, udbcDatabaseOrm!, documentLanguage)
//            } else if documentGraphItemSearchRequest.isByCategory {
//                databaseOrmResultType = UDCCityType.get(limitedTo: 0, sortedBy: "name", udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            } else {
//                databaseOrmResultType = try UDCCityType.search(text: text, udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            }
//            if databaseOrmResultType!.databaseOrmError.count == 0 {
//                for udci in databaseOrmResultType!.object {
//                    let uvcOptionViewModelLocal = UVCOptionViewModel()
//                    uvcOptionViewModelLocal.objectIdName = udci.idName
//                    uvcOptionViewModelLocal.parentId.append(documentGraphItemSearchRequest.optionItemId)
//                    uvcOptionViewModelLocal.objectName = udcDocumentItemMapNode.objectName
//                    uvcOptionViewModelLocal.pathIdName.append(["UDCDocumentItemMapNode.DocumentItems"])
//                    uvcOptionViewModelLocal.pathIdName[0].append(udci.idName)
//                    uvcOptionViewModelLocal.level = 1
//                    uvcOptionViewModelLocal.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: udci.name, description: "", category: udcDocumentItemMapNode.name.capitalized, subCategory: "", language: documentLanguage, isChildrenExist: false, isEditable: false, isCheckBox: false, photoId: nil, photoObjectName: nil)
//                    uvcOptionViewModelLocal.uvcViewModel.rowLength = 3
//                    uvcOptionViewModel.append(uvcOptionViewModelLocal)
//                }
//            }
//        } else if udcDocumentItemMapNode.idName == "UDCDocumentItemMapNode.District" && !documentGraphItemSearchRequest.isBySubCategory {
//            searchResult = true
//            var databaseOrmResultType : DatabaseOrmResult<UDCDistrictType>?
//            if searchPhase == 1 {
//                databaseOrmResultType = UDCDistrictType.getOne(text, udbcDatabaseOrm!, documentLanguage)
//            } else if documentGraphItemSearchRequest.isByCategory {
//                databaseOrmResultType = UDCDistrictType.get(limitedTo: 0, sortedBy: "name", udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            } else {
//                databaseOrmResultType = try UDCDistrictType.search(text: text, udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            }
//            if databaseOrmResultType!.databaseOrmError.count == 0 {
//                for udci in databaseOrmResultType!.object {
//                    var subCategory = ""
//                    let databaseOrmResultSubCategoryType = UDCStateType.get(udci.udcStateIdName, udbcDatabaseOrm!, documentLanguage)
//                    if databaseOrmResultSubCategoryType.databaseOrmError.count == 0 {
//                        subCategory = databaseOrmResultSubCategoryType.object[0].name
//                    }
//                    let uvcOptionViewModelLocal = UVCOptionViewModel()
//                    uvcOptionViewModelLocal.objectIdName = udci.idName
//                    uvcOptionViewModelLocal.parentId.append(documentGraphItemSearchRequest.optionItemId)
//                    uvcOptionViewModelLocal.objectName = udcDocumentItemMapNode.objectName
//                    uvcOptionViewModelLocal.pathIdName.append(["UDCDocumentItemMapNode.DocumentItems"])
//                    uvcOptionViewModelLocal.pathIdName[0].append(udci.idName)
//                    uvcOptionViewModelLocal.level = 1
//                    uvcOptionViewModelLocal.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: udci.name, description: "", category: udcDocumentItemMapNode.name.capitalized, subCategory: subCategory, language: documentLanguage, isChildrenExist: false, isEditable: false, isCheckBox: false, photoId: nil, photoObjectName: nil)
//                    uvcOptionViewModelLocal.uvcViewModel.rowLength = 3
//                    uvcOptionViewModel.append(uvcOptionViewModelLocal)
//                }
//            }
//        } else if udcDocumentItemMapNode.idName == "UDCDocumentItemMapNode.Village" && !documentGraphItemSearchRequest.isBySubCategory {
//            searchResult = true
//            var databaseOrmResultType : DatabaseOrmResult<UDCVillageType>?
//            if searchPhase == 1 {
//                databaseOrmResultType = UDCVillageType.getOne(text, udbcDatabaseOrm!, documentLanguage)
//            } else if documentGraphItemSearchRequest.isByCategory {
//                databaseOrmResultType = UDCVillageType.get(limitedTo: 0, sortedBy: "name", udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            } else {
//                databaseOrmResultType = try UDCVillageType.search(text: text, udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            }
//            if databaseOrmResultType!.databaseOrmError.count == 0 {
//                for udci in databaseOrmResultType!.object {
//                    var subCategory = ""
//                    let databaseOrmResultSubCategoryType = UDCDistrictType.get(udci.udcDistrictIdName, udbcDatabaseOrm!, documentLanguage)
//                    if databaseOrmResultSubCategoryType.databaseOrmError.count == 0 {
//                        subCategory = databaseOrmResultSubCategoryType.object[0].name
//                    }
//                    let uvcOptionViewModelLocal = UVCOptionViewModel()
//                    uvcOptionViewModelLocal.objectIdName = udci.idName
//                    uvcOptionViewModelLocal.parentId.append(documentGraphItemSearchRequest.optionItemId)
//                    uvcOptionViewModelLocal.objectName = udcDocumentItemMapNode.objectName
//                    uvcOptionViewModelLocal.pathIdName.append(["UDCDocumentItemMapNode.DocumentItems"])
//                    uvcOptionViewModelLocal.pathIdName[0].append(udci.idName)
//                    uvcOptionViewModelLocal.level = 1
//                    uvcOptionViewModelLocal.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: udci.name, description: "", category: udcDocumentItemMapNode.name.capitalized, subCategory: subCategory, language: documentLanguage, isChildrenExist: false, isEditable: false, isCheckBox: false, photoId: nil, photoObjectName: nil)
//                    uvcOptionViewModelLocal.uvcViewModel.rowLength = 3
//                    uvcOptionViewModel.append(uvcOptionViewModelLocal)
//                }
//            }
//        } else if udcDocumentItemMapNode.idName == "UDCDocumentItemMapNode.Town" && !documentGraphItemSearchRequest.isBySubCategory {
//            searchResult = true
//            var databaseOrmResultType : DatabaseOrmResult<UDCTownType>?
//            if searchPhase == 1 {
//                databaseOrmResultType = UDCTownType.getOne(text, udbcDatabaseOrm!, documentLanguage)
//            } else if documentGraphItemSearchRequest.isByCategory {
//                databaseOrmResultType = UDCTownType.get(limitedTo: 0, sortedBy: "name", udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            } else {
//                databaseOrmResultType = try UDCTownType.search(text: text, udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            }
//            if databaseOrmResultType!.databaseOrmError.count == 0 {
//                for udci in databaseOrmResultType!.object {
//                    var subCategory = ""
//                    let databaseOrmResultSubCategoryType = UDCDistrictType.get(udci.udcDistrictIdName, udbcDatabaseOrm!)
//                    if databaseOrmResultSubCategoryType.databaseOrmError.count == 0 {
//                        subCategory = databaseOrmResultSubCategoryType.object[0].name
//                    }
//                    let uvcOptionViewModelLocal = UVCOptionViewModel()
//                    uvcOptionViewModelLocal.objectIdName = udci.idName
//                    uvcOptionViewModelLocal.parentId.append(documentGraphItemSearchRequest.optionItemId)
//                    uvcOptionViewModelLocal.objectName = udcDocumentItemMapNode.objectName
//                    uvcOptionViewModelLocal.pathIdName.append(["UDCDocumentItemMapNode.DocumentItems"])
//                    uvcOptionViewModelLocal.pathIdName[0].append(udci.idName)
//                    uvcOptionViewModelLocal.level = 1
//                    uvcOptionViewModelLocal.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: udci.name, description: "", category: udcDocumentItemMapNode.name.capitalized, subCategory: subCategory, language: documentLanguage, isChildrenExist: false, isEditable: false, isCheckBox: false, photoId: nil, photoObjectName: nil)
//                    uvcOptionViewModelLocal.uvcViewModel.rowLength = 3
//                    uvcOptionViewModel.append(uvcOptionViewModelLocal)
//                }
//            }
//        } else if udcDocumentItemMapNode.idName == "UDCDocumentItemMapNode.PeopleCommunity" && !documentGraphItemSearchRequest.isBySubCategory {
//            searchResult = true
//            var databaseOrmResultType : DatabaseOrmResult<UDCPeopleCommunity>?
//            if searchPhase == 1 {
//                databaseOrmResultType = UDCPeopleCommunity.getOne(text, udbcDatabaseOrm!, documentLanguage)
//            } else if documentGraphItemSearchRequest.isByCategory {
//                databaseOrmResultType = UDCPeopleCommunity.get(limitedTo: 0, sortedBy: "name", udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            } else {
//                databaseOrmResultType = try UDCPeopleCommunity.search(text: text, udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            }
//            if databaseOrmResultType!.databaseOrmError.count == 0 {
//                for udci in databaseOrmResultType!.object {
//                    let uvcOptionViewModelLocal = UVCOptionViewModel()
//                    uvcOptionViewModelLocal.objectIdName = udci.idName
//                    uvcOptionViewModelLocal.parentId.append(documentGraphItemSearchRequest.optionItemId)
//                    uvcOptionViewModelLocal.objectName = udcDocumentItemMapNode.objectName
//                    uvcOptionViewModelLocal.pathIdName.append(["UDCDocumentItemMapNode.DocumentItems"])
//                    uvcOptionViewModelLocal.pathIdName[0].append(udci.idName)
//                    uvcOptionViewModelLocal.level = 1
//                    uvcOptionViewModelLocal.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: udci.name, description: "", category: udcDocumentItemMapNode.name.capitalized, subCategory: "", language: documentLanguage, isChildrenExist: false, isEditable: false, isCheckBox: false, photoId: nil, photoObjectName: nil)
//                    uvcOptionViewModelLocal.uvcViewModel.rowLength = 2
//                    uvcOptionViewModel.append(uvcOptionViewModelLocal)
//                }
//            }
//        } else if udcDocumentItemMapNode.idName == "UDCDocumentItemMapNode.Religion" && !documentGraphItemSearchRequest.isBySubCategory {
//            searchResult = true
//            var databaseOrmResultType : DatabaseOrmResult<UDCReligionType>?
//            if searchPhase == 1 {
//                databaseOrmResultType = UDCReligionType.getOne(text, udbcDatabaseOrm!, documentLanguage)
//            } else if documentGraphItemSearchRequest.isByCategory {
//                databaseOrmResultType = UDCReligionType.get(limitedTo: 0, sortedBy: "name", udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            } else {
//                databaseOrmResultType = try UDCReligionType.search(text: text, udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            }
//            if databaseOrmResultType!.databaseOrmError.count == 0 {
//                for udci in databaseOrmResultType!.object {
//                    let uvcOptionViewModelLocal = UVCOptionViewModel()
//                    uvcOptionViewModelLocal.objectIdName = udci.idName
//                    uvcOptionViewModelLocal.parentId.append(documentGraphItemSearchRequest.optionItemId)
//                    uvcOptionViewModelLocal.objectName = udcDocumentItemMapNode.objectName
//                    uvcOptionViewModelLocal.pathIdName.append(["UDCDocumentItemMapNode.DocumentItems"])
//                    uvcOptionViewModelLocal.pathIdName[0].append(udci.idName)
//                    uvcOptionViewModelLocal.level = 1
//                    uvcOptionViewModelLocal.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: udci.name, description: "", category: udcDocumentItemMapNode.name.capitalized, subCategory: "", language: documentLanguage, isChildrenExist: false, isEditable: false, isCheckBox: false, photoId: nil, photoObjectName: nil)
//                    uvcOptionViewModelLocal.uvcViewModel.rowLength = 2
//                    uvcOptionViewModel.append(uvcOptionViewModelLocal)
//                }
//            }
//        } else if udcDocumentItemMapNode.idName == "UDCDocumentItemMapNode.CuisineStyle" && !documentGraphItemSearchRequest.isBySubCategory {
//            searchResult = true
//            var databaseOrmResultType : DatabaseOrmResult<UDCCuisineStyleType>?
//            if searchPhase == 1 {
//                databaseOrmResultType = UDCCuisineStyleType.getOne(text, udbcDatabaseOrm!, documentLanguage)
//            } else if documentGraphItemSearchRequest.isByCategory {
//                databaseOrmResultType = UDCCuisineStyleType.get(limitedTo: 0, sortedBy: "name", udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            } else {
//                databaseOrmResultType = try UDCCuisineStyleType.search(text: text, udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            }
//            if databaseOrmResultType!.databaseOrmError.count == 0 {
//                for udci in databaseOrmResultType!.object {
//                    let uvcOptionViewModelLocal = UVCOptionViewModel()
//                    uvcOptionViewModelLocal.objectIdName = udci.idName
//                    uvcOptionViewModelLocal.parentId.append(documentGraphItemSearchRequest.optionItemId)
//                    uvcOptionViewModelLocal.objectName = udcDocumentItemMapNode.objectName
//                    uvcOptionViewModelLocal.pathIdName.append(["UDCDocumentItemMapNode.DocumentItems"])
//                    uvcOptionViewModelLocal.pathIdName[0].append(udci.idName)
//                    uvcOptionViewModelLocal.level = 1
//                    uvcOptionViewModelLocal.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: udci.name, description: "", category: udcDocumentItemMapNode.name.capitalized, subCategory: "", language: documentLanguage, isChildrenExist: false, isEditable: false, isCheckBox: false, photoId: nil, photoObjectName: nil)
//                    uvcOptionViewModelLocal.uvcViewModel.rowLength = 2
//                    uvcOptionViewModel.append(uvcOptionViewModelLocal)
//                }
//            }
//        } else if udcDocumentItemMapNode.idName == "UDCDocumentItemMapNode.CuisineHistorical" && !documentGraphItemSearchRequest.isBySubCategory {
//            searchResult = true
//            var databaseOrmResultType : DatabaseOrmResult<UDCCuisineHistoricalType>?
//            if searchPhase == 1 {
//                databaseOrmResultType = UDCCuisineHistoricalType.getOne(text, udbcDatabaseOrm!, documentLanguage)
//            } else if documentGraphItemSearchRequest.isByCategory {
//                databaseOrmResultType = UDCCuisineHistoricalType.get(limitedTo: 0, sortedBy: "name", udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            } else {
//                databaseOrmResultType = try UDCCuisineHistoricalType.search(text: text, udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            }
//            if databaseOrmResultType!.databaseOrmError.count == 0 {
//                for udci in databaseOrmResultType!.object {
//                    let uvcOptionViewModelLocal = UVCOptionViewModel()
//                    uvcOptionViewModelLocal.objectIdName = udci.idName
//                    uvcOptionViewModelLocal.parentId.append(documentGraphItemSearchRequest.optionItemId)
//                    uvcOptionViewModelLocal.objectName = udcDocumentItemMapNode.objectName
//                    uvcOptionViewModelLocal.pathIdName.append(["UDCDocumentItemMapNode.DocumentItems"])
//                    uvcOptionViewModelLocal.pathIdName[0].append(udci.idName)
//                    uvcOptionViewModelLocal.level = 1
//                    uvcOptionViewModelLocal.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: udci.name, description: "", category: udcDocumentItemMapNode.name.capitalized, subCategory: "", language: documentLanguage, isChildrenExist: false, isEditable: false, isCheckBox: false, photoId: nil, photoObjectName: nil)
//                    uvcOptionViewModelLocal.uvcViewModel.rowLength = 2
//                    uvcOptionViewModel.append(uvcOptionViewModelLocal)
//                }
//            }
//        } else if udcDocumentItemMapNode.idName == "UDCDocumentItemMapNode.FoodRecipeCategory" && !documentGraphItemSearchRequest.isBySubCategory {
//            searchResult = true
//            var databaseOrmResultType : DatabaseOrmResult<UDCFoodRecipeCategoryType>?
//            if searchPhase == 1 {
//                databaseOrmResultType = UDCFoodRecipeCategoryType.getOne(text, udbcDatabaseOrm!, documentLanguage)
//            } else if documentGraphItemSearchRequest.isByCategory {
//                databaseOrmResultType = UDCFoodRecipeCategoryType.get(limitedTo: 0, sortedBy: "name", udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            } else {
//                databaseOrmResultType = try UDCFoodRecipeCategoryType.search(text: text, udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            }
//            if databaseOrmResultType!.databaseOrmError.count == 0 {
//                for udci in databaseOrmResultType!.object {
//                    let uvcOptionViewModelLocal = UVCOptionViewModel()
//                    uvcOptionViewModelLocal.objectIdName = udci.idName
//                    uvcOptionViewModelLocal.parentId.append(documentGraphItemSearchRequest.optionItemId)
//                    uvcOptionViewModelLocal.objectName = udcDocumentItemMapNode.objectName
//                    uvcOptionViewModelLocal.pathIdName.append(["UDCDocumentItemMapNode.DocumentItems"])
//                    uvcOptionViewModelLocal.pathIdName[0].append(udci.idName)
//                    uvcOptionViewModelLocal.level = 1
//                    uvcOptionViewModelLocal.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: udci.name, description: "", category: udcDocumentItemMapNode.name.capitalized, subCategory: "", language: documentLanguage, isChildrenExist: false, isEditable: false, isCheckBox: false, photoId: nil, photoObjectName: nil)
//                    uvcOptionViewModelLocal.uvcViewModel.rowLength = 2
//                    uvcOptionViewModel.append(uvcOptionViewModelLocal)
//                }
//            }
//        } else if udcDocumentItemMapNode.idName == "UDCDocumentItemMapNode.FoodRecipeItem" && !documentGraphItemSearchRequest.isBySubCategory {
//            searchResult = true
//            var databaseOrmResultType : DatabaseOrmResult<UDCFoodRecipeItemType>?
//            if searchPhase == 1 {
//                databaseOrmResultType = UDCFoodRecipeItemType.getOne(text, udbcDatabaseOrm!, documentLanguage)
//            } else if documentGraphItemSearchRequest.isByCategory {
//                databaseOrmResultType = UDCFoodRecipeItemType.get(limitedTo: 0, sortedBy: "name", udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            } else {
//                databaseOrmResultType = try UDCFoodRecipeItemType.search(text: text, udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            }
//            if databaseOrmResultType!.databaseOrmError.count == 0 {
//                for udci in databaseOrmResultType!.object {
//                    let uvcOptionViewModelLocal = UVCOptionViewModel()
//                    uvcOptionViewModelLocal.objectIdName = udci.idName
//                    uvcOptionViewModelLocal.parentId.append(documentGraphItemSearchRequest.optionItemId)
//                    uvcOptionViewModelLocal.objectName = udcDocumentItemMapNode.objectName
//                    uvcOptionViewModelLocal.pathIdName.append(["UDCDocumentItemMapNode.DocumentItems"])
//                    uvcOptionViewModelLocal.pathIdName[0].append(udci.idName)
//                    uvcOptionViewModelLocal.level = 1
//                    uvcOptionViewModelLocal.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: udci.name, description: "", category: udcDocumentItemMapNode.name.capitalized, subCategory: "", language: documentLanguage, isChildrenExist: false, isEditable: false, isCheckBox: false, photoId: nil, photoObjectName: nil)
//                    uvcOptionViewModelLocal.uvcViewModel.rowLength = 2
//                    uvcOptionViewModel.append(uvcOptionViewModelLocal)
//                }
//            }
//        } else if udcDocumentItemMapNode.idName == "UDCDocumentItemMapNode.UserWordDictionary" && !documentGraphItemSearchRequest.isBySubCategory {
//            searchResult = true
//            var databaseOrmResultType : DatabaseOrmResult<UDCUserWordDictionary>?
//            if searchPhase == 1 {
//                databaseOrmResultType = UDCUserWordDictionary.getOne(text, udbcDatabaseOrm!, documentLanguage)
//            } else if documentGraphItemSearchRequest.isByCategory {
//                databaseOrmResultType = UDCUserWordDictionary.get(limitedTo: 0, sortedBy: "word", udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            } else {
//                databaseOrmResultType = try UDCUserWordDictionary.search(text: text, udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            }
//            if databaseOrmResultType!.databaseOrmError.count == 0 {
//                for udci in databaseOrmResultType!.object {
//                    let uvcOptionViewModelLocal = UVCOptionViewModel()
//                    uvcOptionViewModelLocal.objectIdName = udci.idName
//                    uvcOptionViewModelLocal.parentId.append(documentGraphItemSearchRequest.optionItemId)
//                    uvcOptionViewModelLocal.objectName = udcDocumentItemMapNode.objectName
//                    uvcOptionViewModelLocal.pathIdName.append(["UDCDocumentItemMapNode.DocumentItems"])
//                    uvcOptionViewModelLocal.pathIdName[0].append(udci.idName)
//                    uvcOptionViewModelLocal.level = 1
//                    uvcOptionViewModelLocal.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: udci.word, description: "", category: udcDocumentItemMapNode.name.capitalized, subCategory: "", language: documentLanguage, isChildrenExist: false, isEditable: false, isCheckBox: false, photoId: nil, photoObjectName: nil)
//                    uvcOptionViewModelLocal.uvcViewModel.rowLength = 2
//                    uvcOptionViewModel.append(uvcOptionViewModelLocal)
//                }
//            }
//        } else if udcDocumentItemMapNode.idName == "UDCDocumentItemMapNode.GassMark" && !documentGraphItemSearchRequest.isBySubCategory {
//            searchResult = true
//            var databaseOrmResultType : DatabaseOrmResult<UDCGassMarkType>?
//            if searchPhase == 1 {
//                databaseOrmResultType = UDCGassMarkType.getOne(text, udbcDatabaseOrm!, documentLanguage)
//            } else if documentGraphItemSearchRequest.isByCategory {
//                databaseOrmResultType = UDCGassMarkType.get(limitedTo: 0, sortedBy: "name", udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            } else {
//                databaseOrmResultType = try UDCGassMarkType.search(text: text, udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            }
//            if databaseOrmResultType!.databaseOrmError.count == 0 {
//                for udci in databaseOrmResultType!.object {
//                    let uvcOptionViewModelLocal = UVCOptionViewModel()
//                    uvcOptionViewModelLocal.objectIdName = udci.idName
//                    uvcOptionViewModelLocal.parentId.append(documentGraphItemSearchRequest.optionItemId)
//                    uvcOptionViewModelLocal.objectName = udcDocumentItemMapNode.objectName
//                    let name = "\(udci.name) (GM: \(udci.gassMark), F: \(udci.fahrenheit), C: \(udci.celsius)"
//                    uvcOptionViewModelLocal.pathIdName.append(["UDCDocumentItemMapNode.DocumentItems"])
//                    uvcOptionViewModelLocal.pathIdName[0].append(udci.idName)
//                    uvcOptionViewModelLocal.level = 1
//                    uvcOptionViewModelLocal.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: name, description: "", category: udcDocumentItemMapNode.name.capitalized, subCategory: "", language: documentLanguage, isChildrenExist: false, isEditable: false, isCheckBox: false, photoId: nil, photoObjectName: nil)
//                    uvcOptionViewModelLocal.uvcViewModel.rowLength = 2
//                    uvcOptionViewModel.append(uvcOptionViewModelLocal)
//                }
//            }
//        } else if udcDocumentItemMapNode.idName == "UDCDocumentItemMapNode.OvenTemperature" && !documentGraphItemSearchRequest.isBySubCategory {
//            searchResult = true
//            var databaseOrmResultType : DatabaseOrmResult<UDCOvenTemperatureType>?
//            if searchPhase == 1 {
//                databaseOrmResultType = UDCOvenTemperatureType.getOne(text, udbcDatabaseOrm!, documentLanguage)
//            } else if documentGraphItemSearchRequest.isByCategory {
//                databaseOrmResultType = UDCOvenTemperatureType.get(limitedTo: 0, sortedBy: "name", udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            } else {
//                databaseOrmResultType = try UDCOvenTemperatureType.search(text: text, udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            }
//            if databaseOrmResultType!.databaseOrmError.count == 0 {
//                for udci in databaseOrmResultType!.object {
//                    let uvcOptionViewModelLocal = UVCOptionViewModel()
//                    uvcOptionViewModelLocal.objectIdName = udci.idName
//                    uvcOptionViewModelLocal.parentId.append(documentGraphItemSearchRequest.optionItemId)
//                    uvcOptionViewModelLocal.objectName = udcDocumentItemMapNode.objectName
//                    let name = "\(udci.name) (F: \(udci.fahrenheitFrom)-\(udci.fahrenheitTo), C: \(udci.celsiusFrom)-\(udci.celsiusTo)"
//                    uvcOptionViewModelLocal.pathIdName.append(["UDCDocumentItemMapNode.DocumentItems"])
//                    uvcOptionViewModelLocal.pathIdName[0].append(udci.idName)
//                    uvcOptionViewModelLocal.level = 1
//                    uvcOptionViewModelLocal.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: name, description: "", category: udcDocumentItemMapNode.name.capitalized, subCategory: "", language: documentLanguage, isChildrenExist: false, isEditable: false, isCheckBox: false, photoId: nil, photoObjectName: nil)
//                    uvcOptionViewModelLocal.uvcViewModel.rowLength = 2
//                    uvcOptionViewModel.append(uvcOptionViewModelLocal)
//                }
//            }
//        } else if udcDocumentItemMapNode.idName == "UDCDocumentItemMapNode.OrderOfMagnitudeTemperature" && !documentGraphItemSearchRequest.isBySubCategory {
//            searchResult = true
//            var databaseOrmResultType : DatabaseOrmResult<UDCOrderOfMagnitudeTemperatureType>?
//            if searchPhase == 1 {
//                databaseOrmResultType = UDCOrderOfMagnitudeTemperatureType.getOne(text, udbcDatabaseOrm!, documentLanguage)
//            } else if documentGraphItemSearchRequest.isByCategory {
//                databaseOrmResultType = UDCOrderOfMagnitudeTemperatureType.get(limitedTo: 0, sortedBy: "name", udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            } else {
//                databaseOrmResultType = try UDCOrderOfMagnitudeTemperatureType.search(text: text, udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            }
//            if databaseOrmResultType!.databaseOrmError.count == 0 {
//                for udci in databaseOrmResultType!.object {
//                    let uvcOptionViewModelLocal = UVCOptionViewModel()
//                    uvcOptionViewModelLocal.objectIdName = udci.idName
//                    uvcOptionViewModelLocal.parentId.append(documentGraphItemSearchRequest.optionItemId)
//                    uvcOptionViewModelLocal.objectName = udcDocumentItemMapNode.objectName
//                    let name = udci.name
//                    uvcOptionViewModelLocal.pathIdName.append(["UDCDocumentItemMapNode.DocumentItems"])
//                    uvcOptionViewModelLocal.pathIdName[0].append(udci.idName)
//                    uvcOptionViewModelLocal.level = 1
//                    uvcOptionViewModelLocal.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: name, description: "", category: udcDocumentItemMapNode.name.capitalized, subCategory: "", language: documentLanguage, isChildrenExist: false, isEditable: false, isCheckBox: false, photoId: nil, photoObjectName: nil)
//                    uvcOptionViewModelLocal.uvcViewModel.rowLength = 2
//                    uvcOptionViewModel.append(uvcOptionViewModelLocal)
//                }
//            }
//        } else if udcDocumentItemMapNode.idName == "UDCDocumentItemMapNode.Utensil" && !documentGraphItemSearchRequest.isBySubCategory {
//            searchResult = true
//            var databaseOrmResultType : DatabaseOrmResult<UDCUtensilType>?
//            if searchPhase == 1 {
//                databaseOrmResultType = UDCUtensilType.getOne(text, udbcDatabaseOrm!, documentLanguage)
//            } else if documentGraphItemSearchRequest.isByCategory {
//                databaseOrmResultType = UDCUtensilType.get(limitedTo: 0, sortedBy: "name", udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            } else {
//                databaseOrmResultType = try UDCUtensilType.search(text: text, udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
//            }
//            if databaseOrmResultType!.databaseOrmError.count == 0 {
//                for udci in databaseOrmResultType!.object {
//                    let uvcOptionViewModelLocal = UVCOptionViewModel()
//                    uvcOptionViewModelLocal.objectIdName = udci.idName
//                    uvcOptionViewModelLocal.parentId.append(documentGraphItemSearchRequest.optionItemId)
//                    uvcOptionViewModelLocal.objectName = udcDocumentItemMapNode.objectName
//                    let name = udci.name
//                    uvcOptionViewModelLocal.pathIdName.append(["UDCDocumentItemMapNode.DocumentItems"])
//                    uvcOptionViewModelLocal.pathIdName[0].append(udci.idName)
//                    uvcOptionViewModelLocal.level = 1
//                    uvcOptionViewModelLocal.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: name, description: "", category: udcDocumentItemMapNode.name.capitalized, subCategory: "", language: documentLanguage, isChildrenExist: false, isEditable: false, isCheckBox: false, photoId: nil, photoObjectName: nil)
//                    uvcOptionViewModelLocal.uvcViewModel.rowLength = 2
//                    uvcOptionViewModel.append(uvcOptionViewModelLocal)
//                }
//                let databaseOrmResultTypePatttern = try UDCWordPatternType.search(rootWordIdName: "UDCUtensil", text: pattern, udbcDatabaseOrm!, documentLanguage)
//                if databaseOrmResultTypePatttern.databaseOrmError.count == 0 {
//                    for udci in databaseOrmResultTypePatttern.object {
//                        let uvcOptionViewModelLocal = getOptionViewModel(parentId: documentGraphItemSearchRequest.optionItemId, parentPath: documentGraphItemSearchRequest.path[0], parentPathIdName: ["UDCDocumentItemMapNode.DocumentItems"], objectName: udcDocumentItemMapNode.objectName, idName: udci.idName, name: udci.name, category: udcDocumentItemMapNode.name.capitalized, subCategory: "", subCategoryIdName: "", level: 1, rowLength: 2, language: documentLanguage, isCheckBox: false)
//                        uvcOptionViewModel.append(uvcOptionViewModelLocal)
//                    }
//                }
//            } else {
//                if searchPhase == 1 {
//                    let databaseOrmResultTypePatttern = try UDCWordPatternType.get(rootWordIdName: "UDCUtensil", name: pattern, udbcDatabaseOrm!, documentLanguage)
//                    if databaseOrmResultTypePatttern.databaseOrmError.count == 0 {
//                        databaseOrmResultType!.databaseOrmError.append(DatabaseOrmError()) // So that cannot process below
//                        for udci in databaseOrmResultTypePatttern.object {
//                            let uvcOptionViewModelLocal = getOptionViewModel(parentId: documentGraphItemSearchRequest.optionItemId, parentPath: documentGraphItemSearchRequest.path[0], parentPathIdName: ["UDCDocumentItemMapNode.DocumentItems"], objectName: udcDocumentItemMapNode.objectName, idName: udci.idName, name: udci.name, category: udcDocumentItemMapNode.name.capitalized, subCategory: "", subCategoryIdName: "", level: 1, rowLength: 2, language: documentLanguage, isCheckBox: false)
//                            uvcOptionViewModel.append(uvcOptionViewModelLocal)
//                        }
//                    }
//                }
//            }
//        } else if udcDocumentItemMapNode.objectName == "UDCPhotoDocument" {
//            searchResult = true
//            let databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentItemMapNode.objectId[0], language: documentLanguage)
//            if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
//                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocument.databaseOrmError[0].name, description: databaseOrmResultUDCDocument.databaseOrmError[0].description))
//                return false
//            }
//            let udcDocument = databaseOrmResultUDCDocument.object[0]
//            let databaseOrmUDCDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: udcDocumentItemMapNode.objectName, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocument.udcDocumentGraphModelId, language: documentLanguage) as DatabaseOrmResult<UDCDocumentGraphModel>
//            if databaseOrmUDCDocumentGraphModel.databaseOrmError.count == 0 {
//                let udcPhotoDocument = databaseOrmUDCDocumentGraphModel.object[0]
//                var category = ""
//                var subCategory = ""
//                try getPhotoDocumentOptions(collectionName: udcDocumentItemMapNode.objectName, text: text, photoDocumentId: udcPhotoDocument.childrenId, uvcOptionViewModel: &uvcOptionViewModel, udcDocumentTypeIdName: documentGraphItemSearchRequest.udcDocumentTypeIdName, objectName: udcDocumentItemMapNode.objectName, optionItemId: documentGraphItemSearchRequest.optionItemId, path: [], pathIdName: ["UDCDocumentItemMapNode.DocumentItems"], category: &category, subCategory: &subCategory, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, documentLanguage: documentLanguage)
//            }
//        }
//
//        return searchResult
//    }
    
//    private func getPhotoDocumentOptions(collectionName: String, text: String, photoDocumentId: [String], uvcOptionViewModel: inout [UVCOptionViewModel], udcDocumentTypeIdName: String, objectName: String, optionItemId: String, path: [String], pathIdName: [String], category: inout String, subCategory: inout String, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest, documentLanguage: String) throws {
//        let databaseOrmUDCDocumentGraphModelSearch = try UDCDocumentGraphModel.search(collectionName: collectionName, text: text, limitedTo: 0, sortedBy: "name", udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage, _id: photoDocumentId)
//        if databaseOrmUDCDocumentGraphModelSearch.databaseOrmError.count  == 0 {
//            let udcPhotoDocumentSearch = databaseOrmUDCDocumentGraphModelSearch.object
//            for udcpd in udcPhotoDocumentSearch {
//                let uvcOptionViewModelLocal = UVCOptionViewModel()
//                let photoId = udcpd.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].itemId
//                let photoObjectName = "\(objectName)Photo"
//                uvcOptionViewModelLocal.objectIdName = udcpd._id
//                uvcOptionViewModelLocal.objectName = objectName
//                uvcOptionViewModelLocal.parentId.append(optionItemId)
//                uvcOptionViewModelLocal.pathIdName.append(pathIdName)
//                uvcOptionViewModelLocal.pathIdName[0].append(udcpd.idName)
//                uvcOptionViewModelLocal.level = 1
//                //                if udcpd.path[0].count > 2 {
//                //                    subCategory = udcpd.path[0][udcpd.path[0].count - 2]
//                //                    category = udcpd.path[0][udcpd.path[0].count - 3]
//                //                } else {
//                //                    category = udcpd.path[0][udcpd.path[0].count - 2]
//                //                }
//                uvcOptionViewModelLocal.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: udcpd.name, description: "", category: category.capitalized, subCategory: subCategory, language: documentLanguage, isChildrenExist: false, isEditable: false, isCheckBox: false, photoId: photoId, photoObjectName: photoObjectName)
//                uvcOptionViewModelLocal.uvcViewModel.rowLength = 2
//                uvcOptionViewModel.append(uvcOptionViewModelLocal)
//            }
//        } else {
//            for id in photoDocumentId {
//                let databaseOrmUDCDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: collectionName, udbcDatabaseOrm: udbcDatabaseOrm!, id: id, language: documentLanguage)
//                if databaseOrmUDCDocumentGraphModel.databaseOrmError.count > 0 {
//                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentGraphModel.databaseOrmError[0].name, description: databaseOrmUDCDocumentGraphModel.databaseOrmError[0].description))
//                    return
//                }
//                let udcPhotoDocument = databaseOrmUDCDocumentGraphModel.object[0]
//                if udcPhotoDocument.childrenId.count > 0 {
//                    try getPhotoDocumentOptions(collectionName: collectionName, text: text, photoDocumentId: udcPhotoDocument.childrenId, uvcOptionViewModel: &uvcOptionViewModel, udcDocumentTypeIdName: udcDocumentTypeIdName, objectName: objectName, optionItemId: optionItemId, path: path, pathIdName: pathIdName, category: &category, subCategory: &subCategory, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, documentLanguage: documentLanguage)
//                }
//            }
//        }
//    }
    
    private func getEditObjectName(idName: String) -> String {
        if idName == "UDCDocumentItem.Document" {
            return "UDCDocument"
        } else if idName.hasPrefix("UDCDocumentItem.DocumentItemConfiguration") {
            return "UDCDocumentItemConfiguration"
        } else if idName.hasPrefix("UDCDocumentItem.") {
            return "UDCDocumentItem"
        } else if idName.hasPrefix("UDCDocumentItem") && idName.hasSuffix("WordDictionary") {
            return "UDC\(idName.split(separator: ".")[1])"
        }
        
        return ""
    }
    
    
    
    
    private func checkRecipeValid(udcDocumentGraphModel: UDCDocumentGraphModel, neuronResponse: inout NeuronRequest) {
        //        for udcDocumentGraphModelIngredient in (udcDocumentGraphModel.udcDocumentGraphModelIngredient) {
        //            if udcDocumentGraphModelIngredient.udcMeasurement.count > 0 {
        //                for udcMeasurement in udcDocumentGraphModelIngredient.udcMeasurement {
        //                    if udcMeasurement.value == 0 || udcMeasurement.unitType.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        //                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "InvalidIngredientMeasurement", description: "One or more ingredient measurement is empty or invalid"))
        //                        break
        //                    }
        //                }
        //            }
        //        }
        //        for udcDocumentGraphModelIngredient in (udcDocumentGraphModel.udcDocumentGraphModelIngredient) {
        //            for udcSentencePatternDataReference in  udcDocumentGraphModelIngredient.udcSentencePatternReference[0].udcSentencePatternDataReference {
        //                if udcSentencePatternDataReference.path[0].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        //                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "IngredientEmpty", description: "One or more ingredient is empty"))
        //                    break
        //                }
        //            }
        //        }
        //        for udcDocumentGraphModelStep in (udcDocumentGraphModel.udcDocumentGraphModelStep) {
        //            for udcSentencePatternDataReference in  udcDocumentGraphModelStep.udcSentencePatternReference[0].udcSentencePatternDataReference {
        //                if udcSentencePatternDataReference.path[0].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        //                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "StepEmpty", description: "One or more step is empty"))
        //                    break
        //                }
        //            }
        //        }
    }
    
    private func callOtherNeuron(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest, neuronName: String, overWriteResponse: Bool) throws {
        let neuronRequestLocal = NeuronRequest()
        neuronRequestLocal.neuronSource._id = neuronRequest.neuronSource._id
        neuronRequestLocal.neuronOperation.synchronus = true
        neuronRequestLocal.neuronOperation._id = neuronRequest.neuronOperation._id
        neuronRequestLocal.neuronSource.name = DocumentItemConfigurationNeuron.getName()
        neuronRequestLocal.neuronSource.type = DocumentItemConfigurationNeuron.getName();
        neuronRequestLocal.neuronOperation.name = neuronRequest.neuronOperation.name
        neuronRequestLocal.neuronOperation.parent = true
        neuronRequestLocal.neuronOperation.neuronData.text = neuronRequest.neuronOperation.neuronData.text
        neuronRequestLocal.neuronTarget.name =  neuronName
        
        neuronUtility!.callNeuron(neuronRequest: neuronRequestLocal)
        
        let neuronResponseLocal = getChildResponse(sourceId: neuronRequestLocal.neuronSource._id)
        
        if neuronResponseLocal.neuronOperation.neuronOperationStatus.neuronOperationError!.count > 0 {
            print("\(DocumentItemConfigurationNeuron.getName()) Errors from child neuron: \(neuronRequest.neuronOperation.name))")
            neuronResponse.neuronOperation.response = true
            for noe in neuronResponseLocal.neuronOperation.neuronOperationStatus.neuronOperationError! {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(noe)
            }
        } else {
            if !neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
                for noe in neuronResponseLocal.neuronOperation.neuronOperationStatus.neuronOperationSuccess! {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationSuccess?.append(noe)
                }
            }
            print("\(DocumentItemConfigurationNeuron.getName()) Success from child neuron: \(neuronRequest.neuronOperation.name))")
            if overWriteResponse {
                neuronResponse.neuronOperation.neuronData.text = neuronResponseLocal.neuronOperation.neuronData.text
            }
        }
    }
    
    //    private func changeRecipe(saveDocumentRequest: SaveDocumentRequest, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws -> GetDocumentResponse {
    //
    //        let getDocumentResponse = GetDocumentResponse()
    //        let udcDocument = saveDocumentRequest.udcDocument
    //
    //        // Save Recipe model
    //        let jsonUtilityRecipeModel = JsonUtility<udcDocumentGraphModel>()
    //        let udcDocumentGraphModel = jsonUtilityRecipeModel.convertJsonToAnyObject(json: udcDocument.udcDocumentGraphModel[0].documentModel)
    //
    //        checkRecipeValid(udcDocumentGraphModel: UDCDocumentModel, neuronResponse: &neuronResponse)
    //        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
    //            return getDocumentResponse
    //        }
    //
    //        let databaseOrmResultudcDocumentGraphModel = udcDocumentGraphModel.update(udbcDatabaseOrm: udbcDatabaseOrm!, object: UDCDocumentModel)
    //        if databaseOrmResultudcDocumentGraphModel.databaseOrmError.count > 0 {
    //            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModel.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModel.databaseOrmError[0].description))
    //            return getDocumentResponse
    //        }
    //
    //        // Save Recipe view model
    //        let jsonUtilityRecipeView = JsonUtility<UVCViewModel>()
    //
    //        // Save recipe document
    //        udcDocument.udcDocumentGraphModel[0].documentModel = ""
    //        udcDocument.udcDocumentView[0].documentModel = ""
    //        let databaseOrmResultUDCDocument = UDCDocument.update(udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocument)
    //        if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
    //            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocument.databaseOrmError[0].name, description: databaseOrmResultUDCDocument.databaseOrmError[0].description))
    //            return getDocumentResponse
    //        }
    //        getDocumentResponse.udcDocument = udcDocument
    //        getDocumentResponse.udcDocumentMapNodeId = saveDocumentRequest.udcDocumentMapNodeId
    //        let udcDocumentGraphModel = UDCDocumentModel()
    //        udcDocumentGraphModel._id = udcDocumentGraphModel._id
    //        udcDocumentGraphModel.udcDocumentType = "UDCDocumentType.Recipe"
    //        udcDocumentGraphModel.documentModel = jsonUtilityRecipeModel.convertAnyObjectToJson(jsonObject: UDCDocumentModel)
    //        let udcDocumentView = UDCDocumentView()
    ////        let newUvcViewModel = try generateView(udcDocumentGraphModel: UDCDocumentModel, json: udcDocumentGraphModel.documentModel, neuronRequest: neuronRequest,  language: udcDocument.language, neuronResponse: &neuronResponse)
    ////        udcDocumentView.documentModel = jsonUtilityRecipeView.convertAnyObjectToJson(jsonObject: newUvcViewModel!)
    //        getDocumentResponse.udcDocument.udcDocumentView[0] = udcDocumentView
    //        getDocumentResponse.udcDocument.udcDocumentGraphModel[0] = udcDocumentGraphModel
    //
    //        return getDocumentResponse
    //    }
    //
    //    private func saveRecipe(saveDocumentRequest: SaveDocumentRequest, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws -> GetDocumentResponse {
    //        let getDocumentResponse = GetDocumentResponse()
    //
    //        let udcDocument = saveDocumentRequest.udcDocument
    //        let jsonUtilityRecipeModel = JsonUtility<udcDocumentGraphModel>()
    //        let udcDocumentGraphModel = jsonUtilityRecipeModel.convertJsonToAnyObject(json: udcDocument.udcDocumentGraphModel[0].documentModel)
    //
    //        checkRecipeValid(udcDocumentGraphModel: UDCDocumentModel, neuronResponse: &neuronResponse)
    //        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
    //            return getDocumentResponse
    //        }
    //
    //        udcDocument._id = try (udbcDatabaseOrm?.generateId())!
    //        udcDocument.modelName = "Recipe Model"
    //        udcDocument.modelVersion = "1.0"
    //        udcDocument.modelDescription = "Contains Recipe Model"
    //        udcDocument.modelTechnicalName = "udcDocumentGraphModel"
    //        udcDocument.udcDocumentHistory[0]._id = try (udbcDatabaseOrm?.generateId())!
    //        udcDocument.udcDocumentGraphModel[0]._id = try (udbcDatabaseOrm?.generateId())!
    //        udcDocument.udcDocumentView[0]._id = try (udbcDatabaseOrm?.generateId())!
    //
    //        // Save Recipe model
    //        udcDocumentGraphModel._id = udcDocument.udcDocumentGraphModel[0]._id
    //        udcDocumentGraphModel.language = udcDocument.language
    //        for udcDocumentGraphModelIngredient in udcDocumentGraphModel.udcDocumentGraphModelIngredient {
    //            udcDocumentGraphModelIngredient._id = try (udbcDatabaseOrm?.generateId())!
    //            for udcSentencePatternDataReference in udcDocumentGraphModelIngredient.udcSentencePatternReference[0].udcSentencePatternDataReference {
    //                udcSentencePatternDataReference._id = try (udbcDatabaseOrm?.generateId())!
    //            }
    //            for udcMeasurement in udcDocumentGraphModelIngredient.udcMeasurement {
    //                udcMeasurement._id = try (udbcDatabaseOrm?.generateId())!
    //            }
    //        }
    //        for udcDocumentGraphModelStep in udcDocumentGraphModel.udcDocumentGraphModelStep {
    //            udcDocumentGraphModelStep._id = try (udbcDatabaseOrm?.generateId())!
    //            for udcSentencePatternDataReference in udcDocumentGraphModelStep.udcSentencePatternReference[0].udcSentencePatternDataReference {
    //                udcSentencePatternDataReference._id = try (udbcDatabaseOrm?.generateId())!
    //            }
    //            for udcMeasurement in udcDocumentGraphModelStep.udcMeasurement {
    //                udcMeasurement._id = try (udbcDatabaseOrm?.generateId())!
    //            }
    //        }
    //        for udcReferenceItem in udcDocumentGraphModel.udcReferenceItem {
    //            udcReferenceItem._id = try (udbcDatabaseOrm?.generateId())!
    //        }
    //        let databaseOrmResultudcDocumentGraphModel = udcDocumentGraphModel.save(udbcDatabaseOrm: udbcDatabaseOrm!, object: UDCDocumentModel)
    //        if databaseOrmResultudcDocumentGraphModel.databaseOrmError.count > 0 {
    //            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModel.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModel.databaseOrmError[0].description))
    //            return getDocumentResponse
    //        }
    //
    //        // Save Recipe view model
    //        let jsonUtilityRecipeView = JsonUtility<UVCViewModel>()
    //
    //        // Save recipe document
    //        udcDocument.udcDocumentGraphModel[0].documentModel = ""
    //        udcDocument.udcDocumentView[0].documentModel = ""
    //        let databaseOrmResultUDCDocument = UDCDocument.save(udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocument)
    //        if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
    //            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocument.databaseOrmError[0].name, description: databaseOrmResultUDCDocument.databaseOrmError[0].description))
    //            return getDocumentResponse
    //        }
    //        getDocumentResponse.udcDocument = udcDocument
    //        getDocumentResponse.udcDocumentMapNodeId = saveDocumentRequest.udcDocumentMapNodeId
    //        let udcDocumentGraphModel = UDCDocumentModel()
    //        udcDocumentGraphModel._id = udcDocumentGraphModel._id
    //        udcDocumentGraphModel.udcDocumentType = "UDCDocumentType.Recipe"
    //        udcDocumentGraphModel.documentModel = jsonUtilityRecipeModel.convertAnyObjectToJson(jsonObject: UDCDocumentModel)
    //        let udcDocumentView = UDCDocumentView()
    ////        let newUvcViewModel = try generateView(udcDocumentGraphModel: UDCDocumentModel, json: udcDocumentGraphModel.documentModel, neuronRequest: neuronRequest,  language: udcDocument.language, neuronResponse: &neuronResponse)
    ////        udcDocumentView.documentModel = jsonUtilityRecipeView.convertAnyObjectToJson(jsonObject: newUvcViewModel!)
    //        getDocumentResponse.udcDocument.udcDocumentView[0] = udcDocumentView
    //        getDocumentResponse.udcDocument.udcDocumentGraphModel[0] = udcDocumentGraphModel
    //
    //
    //        return getDocumentResponse
    //    }
    //
    //    private func newRecipe(documentRequest: GetDocumentRequest, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws -> GetDocumentResponse {
    //        let documentResponse = GetDocumentResponse()
    //        let jsonUtilityRecipeView = JsonUtility<UVCViewModel>()
    //
    //        let uvcViewModel = try generateNewView(neuronRequest: neuronRequest, language: documentRequest.language, neuronResponse: &neuronResponse)
    //        let jsonUVCViewModel = jsonUtilityRecipeView.convertAnyObjectToJson(jsonObject: uvcViewModel!)
    //        let udcDocumentView = UDCDocumentView()
    //        udcDocumentView.documentModel = jsonUVCViewModel
    //        documentResponse.udcDocument.udcDocumentView.append(udcDocumentView)
    //
    //        return documentResponse
    //    }
    //
    //    private func getRecipe(documentRequest: GetDocumentRequest, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws -> GetDocumentResponse {
    //
    //        let documentResponse = GetDocumentResponse()
    //        let jsonUtilityRecipeView = JsonUtility<UVCViewModel>()
    //
    //        // Get document model
    //        var databaseOrmUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: documentRequest.documentId, language: documentRequest.language)
    //        if databaseOrmUDCDocument.databaseOrmError.count > 0 {
    //            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocument.databaseOrmError[0].name, description: databaseOrmUDCDocument.databaseOrmError[0].description))
    //            return documentResponse
    //        }
    //        let udcDocument = databaseOrmUDCDocument.object[0]
    //        documentResponse.udcDocument = udcDocument
    //        let id = udcDocument.udcDocumentGraphModel[0]._id
    //        var udcDocumentGraphModel: UDCDocumentModel?
    //        var jsonRecipe = ""
    //        if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.Get" {
    //            let databaseOrmResultudcDocumentGraphModel = UDCDocumentModel.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: id, language: documentRequest.language)
    //            if databaseOrmResultudcDocumentGraphModel.databaseOrmError.count > 0 {
    //                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: DocumentItemConfigurationNeuronErrorType.ErrorInProcessingView.name, description: DocumentItemConfigurationNeuronErrorType.ErrorInProcessingView.description))
    //                return documentResponse
    //            }
    //            udcDocumentGraphModel = databaseOrmResultudcDocumentGraphModel.object[0]
    //            let jsonUtilityRecipe = JsonUtility<udcDocumentGraphModel>()
    //            jsonRecipe = jsonUtilityRecipe.convertAnyObjectToJson(jsonObject: UDCDocumentModel!)
    //            let udcDocumentGraphModel = UDCDocumentModel()
    //            udcDocumentGraphModel._id = (udcDocumentGraphModel?._id)!
    //            udcDocumentGraphModel.udcDocumentType = "UDCDocumentType.Recipe"
    //            udcDocumentGraphModel.documentModel = jsonRecipe
    //            documentResponse.udcDocument.udcDocumentGraphModel[0] = udcDocumentGraphModel
    //
    //        }
    //
    //        var uvcViewModel: UVCViewModel?
    //
    ////        uvcViewModel = try generateView(udcDocumentGraphModel: UDCDocumentModel!, json: jsonRecipe, neuronRequest: neuronRequest,  language: documentRequest.language, neuronResponse: &neuronResponse)
    ////        if uvcViewModel == nil {
    ////            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: DocumentItemConfigurationNeuronErrorType.ErrorInProcessingView.name, description: DocumentItemConfigurationNeuronErrorType.ErrorInProcessingView.description))
    ////            return documentResponse
    ////        }
    //
    //        let jsonUVCViewModel = jsonUtilityRecipeView.convertAnyObjectToJson(jsonObject: uvcViewModel!)
    //        let udcDocumentView = UDCDocumentView()
    //        udcDocumentView.documentModel = jsonUVCViewModel
    //        documentResponse.udcDocument.udcDocumentView[0] = udcDocumentView
    //
    //
    //       return documentResponse
    //    }
    
    private func generateNewView(neuronRequest: NeuronRequest, language: String, neuronResponse: inout NeuronRequest) throws -> UVCViewModel? {
        
        //        let uvcTable = UVCTable()
        //        var uvcTableRow = UVCTableRow()
        //        var uvcViewItem = UVCViewItem()
        //
        var uvcViewModel = UVCViewModel()
        //
        //        let uvcViewItemCollection = UVCViewItemCollection()
        //
        //        uvcViewModel = UVCViewModel()
        //        uvcViewModel.name = ""
        //        uvcViewModel.description = ""
        //        uvcViewModel.language = language
        //
        //        // View items
        //
        //        uvcViewItem.name = "RecipeTable"
        //        uvcViewItem.type = "UVCViewItemType.Table"
        //        uvcViewModel.uvcViewItem.append(uvcViewItem)
        //        uvcViewItem = UVCViewItem()
        //        uvcViewItem.name = "RecipeTexts"
        //        uvcViewItem.type = "UVCViewItemType.Text"
        //        uvcViewModel.uvcViewItem.append(uvcViewItem)
        //
        //        // Title
        //        let uvcViewGenerator = UVCViewGenerator()
        //        var uvcTableColumn = UVCTableColumn()
        //        var optionButton = uvcViewGenerator.getButton(title: "...", name: "RecipeTitleOptions")
        //        uvcViewItemCollection.uvcButton.append(optionButton)
        //        uvcViewItem = UVCViewItem()
        //        uvcViewItem.name = "RecipeTitleOptions"
        //        uvcViewItem.type = "UVCViewItemType.Button"
        //        uvcTableColumn.uvcViewItem.append(uvcViewItem)
        //
        //        uvcViewItemCollection.uvcText.append(uvcViewGenerator.get(title: "Change Title", name: "Change Title.RecipeTitle", level: 1, isEditable: true))
        //        uvcViewItem = UVCViewItem()
        //        uvcViewItem.name = "Change Title.RecipeTitle"
        //        uvcViewItem.type = "UVCViewItemType.Text"
        //        uvcTableColumn.uvcViewItem.append(uvcViewItem)
        //        uvcTableRow.uvcTableColumn.append(uvcTableColumn)
        //        uvcTable.uvcTableRow.append(uvcTableRow)
        //
        //        // Ingredient
        //        uvcTableRow = UVCTableRow()
        //        uvcTableColumn = UVCTableColumn()
        //        optionButton = uvcViewGenerator.getButton(title: "...", name: "IngredientOptions")
        //        uvcViewItemCollection.uvcButton.append(optionButton)
        //        uvcViewItem = UVCViewItem()
        //        uvcViewItem.name = "IngredientOptions"
        //        uvcViewItem.type = "UVCViewItemType.Button"
        //        uvcTableColumn.uvcViewItem.append(uvcViewItem)
        //
        //        var databaseOrmResultUDCIngredientType = UDCIngredientType.get("UDCIngredientType.Ingredient", udbcDatabaseOrm!, language)
        //        if databaseOrmResultUDCIngredientType.databaseOrmError.count > 0 {
        //            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCIngredientType.databaseOrmError[0].name, description: databaseOrmResultUDCIngredientType.databaseOrmError[0].description))
        //            return nil
        //        }
        //        var recipeItemType = databaseOrmResultUDCIngredientType.object[0]
        //        uvcViewItemCollection.uvcText.append(uvcViewGenerator.get(title: recipeItemType.description, name: "\(recipeItemType.description).IngredientTitle", level: 2, isEditable: false))
        //        uvcViewItem = UVCViewItem()
        //        uvcViewItem.name = "\(recipeItemType.description).IngredientTitle"
        //        uvcViewItem.type = "UVCViewItemType.Text"
        //        uvcTableColumn.uvcViewItem.append(uvcViewItem)
        //
        //        uvcTableRow.uvcTableColumn.append(uvcTableColumn)
        //        uvcTable.uvcTableRow.append(uvcTableRow)
        //
        //        // Pre Cooking Step
        //        uvcTableRow = UVCTableRow()
        //        uvcTableColumn = UVCTableColumn()
        //        uvcViewItemCollection.uvcButton.append(uvcViewGenerator.getButton(title: "...", name: "PreCookingStepOptions"))
        //        uvcViewItem = UVCViewItem()
        //        uvcViewItem.name = "PreCookingStepOptions"
        //        uvcViewItem.type = "UVCViewItemType.Button"
        //        uvcTableColumn.uvcViewItem.append(uvcViewItem)
        //
        //        databaseOrmResultUDCIngredientType = UDCIngredientType.get("UDCIngredientType.PreCookingStep", udbcDatabaseOrm!, language)
        //        if databaseOrmResultUDCIngredientType.databaseOrmError.count > 0 {
        //            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCIngredientType.databaseOrmError[0].name, description: databaseOrmResultUDCIngredientType.databaseOrmError[0].description))
        //            return nil
        //        }
        //        recipeItemType = databaseOrmResultUDCIngredientType.object[0]
        //
        //        uvcViewItemCollection.uvcText.append(uvcViewGenerator.get(title: recipeItemType.description, name: "\(recipeItemType.description).PreCookingStepTitle", level: 2, isEditable: false))
        //        uvcViewItem = UVCViewItem()
        //        uvcViewItem.name = "\(recipeItemType.description).PreCookingStepTitle"
        //        uvcViewItem.type = "UVCViewItemType.Text"
        //        uvcTableColumn.uvcViewItem.append(uvcViewItem)
        //
        //        uvcTableRow.uvcTableColumn.append(uvcTableColumn)
        //        uvcTable.uvcTableRow.append(uvcTableRow)
        //
        //        // Pre Cooking Step
        //        uvcTableRow = UVCTableRow()
        //        uvcTableColumn = UVCTableColumn()
        //        uvcViewItemCollection.uvcButton.append(uvcViewGenerator.getButton(title: "...", name: "CookingStepOptions"))
        //        uvcViewItem = UVCViewItem()
        //        uvcViewItem.name = "CookingStepOptions"
        //        uvcViewItem.type = "UVCViewItemType.Button"
        //        uvcTableColumn.uvcViewItem.append(uvcViewItem)
        //
        //        databaseOrmResultUDCIngredientType = UDCIngredientType.get("UDCIngredientType.CookingStep", udbcDatabaseOrm!, language)
        //        if databaseOrmResultUDCIngredientType.databaseOrmError.count > 0 {
        //            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCIngredientType.databaseOrmError[0].name, description: databaseOrmResultUDCIngredientType.databaseOrmError[0].description))
        //            return nil
        //        }
        //        recipeItemType = databaseOrmResultUDCIngredientType.object[0]
        //
        //        uvcViewItemCollection.uvcText.append(uvcViewGenerator.get(title: recipeItemType.description, name: "\(recipeItemType.description).CookingStepTitle", level: 2, isEditable: false))
        //        uvcViewItem = UVCViewItem()
        //        uvcViewItem.name = "\(recipeItemType.description).CookingStepTitle"
        //        uvcViewItem.type = "UVCViewItemType.Text"
        //        uvcTableColumn.uvcViewItem.append(uvcViewItem)
        //
        //        uvcTableRow.uvcTableColumn.append(uvcTableColumn)
        //        uvcTable.uvcTableRow.append(uvcTableRow)
        //
        //        // Add the table to the collection
        //        uvcViewItemCollection.uvcTable.append(uvcTable)
        //        // Set collection to the view model
        //        uvcViewModel.uvcViewItemCollection = uvcViewItemCollection
        //
        //        return uvcViewModel
        //    }
        //
        //    private func generateView(udcDocumentGraphModel: UDCDocumentModel, json: String, neuronRequest: NeuronRequest, language: String, neuronResponse: inout NeuronRequest) throws -> UVCViewModel? {
        //        var measurementValueCount = 1
        //        var measurementUnitCount = 1
        //        var textCount = 1
        //        var ingredientCount = 1
        //        var cookingMethodCount = 1
        //        var chefCount = 1
        //        var actionCount = 1
        //        var itemStateCount = 1
        //        var serialNumber = 1
        //        var utensilCount = 1
        //        var removeCount = 1
        //        var modelIngredientLength = 0
        //        var modelPreCookingStepLength = 0
        //        var modelCookingStepLength = 0
        //        var durationCount = 1
        //
        //
        //        var uvcTable = UVCTable()
        //        var uvcTableRow = UVCTableRow()
        //        var uvcViewItem = UVCViewItem()
        //
        //        let uvcViewModel = UVCViewModel()
        //
        //        var uvcViewItemCollection = UVCViewItemCollection()
        //
        //        uvcViewModel._id = try (udbcDatabaseOrm!.generateId())
        //        uvcViewModel.name = udcDocumentGraphModel.name
        //        uvcViewModel.description = udcDocumentGraphModel.name
        //        uvcViewModel.language = udcDocumentGraphModel.language
        //
        //        // View items
        //
        //        uvcViewItem.name = "RecipeTable"
        //        uvcViewItem.type = "UVCViewItemType.Table"
        //        uvcViewModel.uvcViewItem.append(uvcViewItem)
        //        uvcViewItem = UVCViewItem()
        //        uvcViewItem.name = "RecipeTexts"
        //        uvcViewItem.type = "UVCViewItemType.Text"
        //        uvcViewModel.uvcViewItem.append(uvcViewItem)
        //
        //        // Title
        //        let uvcViewGenerator = UVCViewGenerator()
        //        var uvcTableColumn = UVCTableColumn()
        //        var optionButton = uvcViewGenerator.getButton(title: "...", name: "RecipeTitleOptions")
        //        uvcViewItemCollection.uvcButton.append(optionButton)
        //        uvcViewItem = UVCViewItem()
        //        uvcViewItem.name = "RecipeTitleOptions"
        //        uvcViewItem.type = "UVCViewItemType.Button"
        //        uvcTableColumn.uvcViewItem.append(uvcViewItem)
        //        uvcViewItemCollection.uvcText.append(uvcViewGenerator.get(title: udcDocumentGraphModel.name, name: "\(udcDocumentGraphModel.name).RecipeTitle", level: 1, isEditable: true))
        //        uvcViewItem = UVCViewItem()
        //        uvcViewItem.name = "\(udcDocumentGraphModel.name).RecipeTitle"
        //        uvcViewItem.type = "UVCViewItemType.Text"
        //        uvcTableColumn.uvcViewItem.append(uvcViewItem)
        //        uvcTableRow.uvcTableColumn.append(uvcTableColumn)
        //        uvcTable.uvcTableRow.append(uvcTableRow)
        //        // Sub Title
        //        uvcTableRow = UVCTableRow()
        //        var databaseOrmResultUDCIngredientType = UDCIngredientType.get("UDCIngredientType.Ingredient", udbcDatabaseOrm!, language)
        //        if databaseOrmResultUDCIngredientType.databaseOrmError.count > 0 {
        //            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCIngredientType.databaseOrmError[0].name, description: databaseOrmResultUDCIngredientType.databaseOrmError[0].description))
        //            return nil
        //        }
        //        var recipeItemType = databaseOrmResultUDCIngredientType.object[0]
        //        uvcTableColumn = UVCTableColumn()
        //        optionButton = uvcViewGenerator.getButton(title: "...", name: "IngredientOptions")
        //        uvcViewItemCollection.uvcButton.append(optionButton)
        //        uvcViewItem = UVCViewItem()
        //        uvcViewItem.name = "IngredientOptions"
        //        uvcViewItem.type = "UVCViewItemType.Button"
        //        uvcTableColumn.uvcViewItem.append(uvcViewItem)
        //        uvcViewItemCollection.uvcText.append(uvcViewGenerator.get(title: recipeItemType.description, name: "\(recipeItemType.description).IngredientTitle", level: 2, isEditable: false))
        //        uvcViewItem = UVCViewItem()
        //        uvcViewItem.name = "\(recipeItemType.description).IngredientTitle"
        //        uvcViewItem.type = "UVCViewItemType.Text"
        //        uvcTableColumn.uvcViewItem.append(uvcViewItem)
        //        uvcTableRow.uvcTableColumn.append(uvcTableColumn)
        //        uvcTable.uvcTableRow.append(uvcTableRow)
        //        // Ingredients
        //        serialNumber = 1
        //
        //        for recipeIngredient in udcDocumentGraphModel.udcDocumentGraphModelIngredient {
        //            var uvcRecipeViewItemMemory = UVCRecipeViewItemMemory()
        //            uvcRecipeViewItemMemory.recipeItemType = "Ingredient"
        //            uvcRecipeViewItemMemory.recipeItemType = "UDCIngredientType.Ingredient"
        //            uvcRecipeViewItemMemory.row = modelIngredientLength
        //            uvcTableRow = UVCTableRow()
        //            // Ingredient Sentence pattern reference
        //            if processSentenceReference(json: json, neuronRequest: neuronRequest, referenceArray: recipeIngredient.udcSentencePatternReference, language: language, uvcViewItem: &uvcViewItem, uvcTableRow: &uvcTableRow, uvcTableColumn: &uvcTableColumn, uvcViewItemCollection: &uvcViewItemCollection, uvcTable: &uvcTable, measurementValueCount: &measurementValueCount, measurementUnitCount: &measurementUnitCount, textCount: &textCount, ingredientCount: &ingredientCount, cookingMethodCount: &cookingMethodCount, chefCount: &chefCount, actionCount: &actionCount, itemStateCount: &itemStateCount, serialNumber: &serialNumber, utensilCount: &utensilCount, removeCount: &removeCount, durationCount: &durationCount, uvcRecipeViewItemMemory: &uvcRecipeViewItemMemory, neuronResponse: &neuronResponse) == false {
        //                return nil
        //            }
        //            modelIngredientLength += 1
        //        }
        //
        //
        //
        //        var preCookingStepFoundCount = 0
        //        var cookingStepFoundCount = 0
        //
        //
        //
        //        serialNumber = 1
        //        var previousRecipeItemType = ""
        //        for recipeStep in udcDocumentGraphModel.udcDocumentGraphModelStep {
        //            var uvcRecipeViewItemMemory = UVCRecipeViewItemMemory()
        //            uvcRecipeViewItemMemory.recipeItemType = recipeStep.udcDocumentGraphModelItemType
        //            if recipeStep.udcDocumentGraphModelItemType == "UDCIngredientType.PreCookingStep" {
        //                preCookingStepFoundCount += 1
        //                uvcRecipeViewItemMemory.row = modelPreCookingStepLength
        //            } else if recipeStep.udcDocumentGraphModelItemType == "UDCIngredientType.CookingStep" {
        //                cookingStepFoundCount += 1
        //                uvcRecipeViewItemMemory.row = modelCookingStepLength + modelPreCookingStepLength
        //            }
        //            databaseOrmResultUDCIngredientType = UDCIngredientType.get(recipeStep.udcDocumentGraphModelItemType, udbcDatabaseOrm!, language)
        //            if databaseOrmResultUDCIngredientType.databaseOrmError.count > 0 {
        //                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCIngredientType.databaseOrmError[0].name, description: databaseOrmResultUDCIngredientType.databaseOrmError[0].description))
        //                return nil
        //            }
        //            recipeItemType = databaseOrmResultUDCIngredientType.object[0]
        //            if previousRecipeItemType != recipeItemType.description {
        //                previousRecipeItemType = recipeItemType.description
        //                uvcTableRow = UVCTableRow()
        //                if recipeStep.udcDocumentGraphModelItemType == "UDCIngredientType.PreCookingStep" {
        //                    uvcTableColumn = UVCTableColumn()
        //                    optionButton = uvcViewGenerator.getButton(title: "...", name: "PreCookingStepOptions")
        //                    uvcViewItemCollection.uvcButton.append(optionButton)
        //                    uvcViewItem = UVCViewItem()
        //                    uvcViewItem.name = "PreCookingStepOptions"
        //                    uvcViewItem.type = "UVCViewItemType.Button"
        //                    uvcTableColumn.uvcViewItem.append(uvcViewItem)
        //                } else if recipeStep.udcDocumentGraphModelItemType == "UDCIngredientType.CookingStep" {
        //                    uvcTableColumn = UVCTableColumn()
        //                    optionButton = uvcViewGenerator.getButton(title: "...", name: "CookingStepOptions")
        //                    uvcViewItemCollection.uvcButton.append(optionButton)
        //                    uvcViewItem = UVCViewItem()
        //                    uvcViewItem.name = "CookingStepOptions"
        //                    uvcViewItem.type = "UVCViewItemType.Button"
        //                    uvcTableColumn.uvcViewItem.append(uvcViewItem)
        //                }
        //                uvcViewItem = UVCViewItem()
        //                if recipeStep.udcDocumentGraphModelItemType == "UDCIngredientType.PreCookingStep" {
        //                    uvcViewItemCollection.uvcText.append(uvcViewGenerator.get(title: recipeItemType.description, name: "\(recipeItemType.description).PreCookingStepTitle", level: 2, isEditable: false))
        //                    uvcViewItem.name = "\(recipeItemType.description).PreCookingStepTitle"
        //                } else if recipeStep.udcDocumentGraphModelItemType == "UDCIngredientType.CookingStep" {
        //                    uvcViewItemCollection.uvcText.append(uvcViewGenerator.get(title: recipeItemType.description, name: "\(recipeItemType.description).CookingStepTitle", level: 2, isEditable: false))
        //                    uvcViewItem.name = "\(recipeItemType.description).CookingStepTitle"
        //                }
        //                uvcViewItem.type = "UVCViewItemType.Text"
        //                uvcTableColumn.uvcViewItem.append(uvcViewItem)
        //                uvcTableRow.uvcTableColumn.append(uvcTableColumn)
        //                uvcTable.uvcTableRow.append(uvcTableRow)
        //                serialNumber = 1
        //            }
        //            if processSentenceReference(json: json, neuronRequest: neuronRequest, referenceArray: recipeStep.udcSentencePatternReference,  language: language, uvcViewItem: &uvcViewItem, uvcTableRow: &uvcTableRow, uvcTableColumn: &uvcTableColumn, uvcViewItemCollection: &uvcViewItemCollection, uvcTable: &uvcTable, measurementValueCount: &measurementValueCount, measurementUnitCount: &measurementUnitCount, textCount: &textCount, ingredientCount: &ingredientCount, cookingMethodCount: &cookingMethodCount, chefCount: &chefCount, actionCount: &actionCount, itemStateCount: &itemStateCount, serialNumber: &serialNumber, utensilCount: &utensilCount, removeCount: &removeCount, durationCount: &durationCount, uvcRecipeViewItemMemory: &uvcRecipeViewItemMemory, neuronResponse: &neuronResponse) == false {
        //                return nil
        //            }
        //            if recipeStep.udcDocumentGraphModelItemType == "UDCIngredientType.PreCookingStep" {
        //                modelPreCookingStepLength += 1
        //            } else if recipeStep.udcDocumentGraphModelItemType == "UDCIngredientType.CookingStep" {
        //                modelCookingStepLength += 1
        //            }
        //
        //        }
        //
        //        if preCookingStepFoundCount == 0 {
        //            uvcTableRow = UVCTableRow()
        //            uvcTableColumn = UVCTableColumn()
        //            optionButton = uvcViewGenerator.getButton(title: "...", name: "PreCookingStepOptions")
        //            optionButton.uvcTextStyle.textColor = UVCColor.get("UVCColor.White").name
        //            optionButton.uvcTextStyle.backgroundColor = UVCColor.get("UVCColor.DarkGreen").name
        //            uvcViewItemCollection.uvcButton.append(optionButton)
        //            uvcViewItem = UVCViewItem()
        //            uvcViewItem.name = "PreCookingStepOptions"
        //            uvcViewItem.type = "UVCViewItemType.Button"
        //            uvcTableColumn.uvcViewItem.append(uvcViewItem)
        //
        //            databaseOrmResultUDCIngredientType = UDCIngredientType.get("UDCIngredientType.PreCookingStep", udbcDatabaseOrm!, language)
        //            if databaseOrmResultUDCIngredientType.databaseOrmError.count > 0 {
        //                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCIngredientType.databaseOrmError[0].name, description: databaseOrmResultUDCIngredientType.databaseOrmError[0].description))
        //                return nil
        //            }
        //            recipeItemType = databaseOrmResultUDCIngredientType.object[0]
        //
        //            uvcViewItemCollection.uvcText.append(uvcViewGenerator.get(title: recipeItemType.description, name: "\(recipeItemType.description).PreCookingStepTitle", level: 2, isEditable: false))
        //            uvcViewItem = UVCViewItem()
        //            uvcViewItem.name = "\(recipeItemType.description).PreCookingStepTitle"
        //            uvcViewItem.type = "UVCViewItemType.Text"
        //            uvcTableColumn.uvcViewItem.append(uvcViewItem)
        //
        //            uvcTableRow.uvcTableColumn.append(uvcTableColumn)
        //            uvcTable.uvcTableRow.append(uvcTableRow)
        //        }
        //
        //        if cookingStepFoundCount == 0 {
        //            // Pre Cooking Step
        //            uvcTableRow = UVCTableRow()
        //            uvcTableColumn = UVCTableColumn()
        //            optionButton = uvcViewGenerator.getButton(title: "...", name: "CookingStepOptions")
        //            optionButton.uvcTextStyle.textColor = UVCColor.get("UVCColor.White").name
        //            optionButton.uvcTextStyle.backgroundColor = UVCColor.get("UVCColor.DarkGreen").name
        //            uvcViewItemCollection.uvcButton.append(optionButton)
        //            uvcViewItem = UVCViewItem()
        //            uvcViewItem.name = "CookingStepOptions"
        //            uvcViewItem.type = "UVCViewItemType.Button"
        //            uvcTableColumn.uvcViewItem.append(uvcViewItem)
        //
        //            databaseOrmResultUDCIngredientType = UDCIngredientType.get("UDCIngredientType.CookingStep", udbcDatabaseOrm!, language)
        //            if databaseOrmResultUDCIngredientType.databaseOrmError.count > 0 {
        //                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCIngredientType.databaseOrmError[0].name, description: databaseOrmResultUDCIngredientType.databaseOrmError[0].description))
        //                return nil
        //            }
        //            recipeItemType = databaseOrmResultUDCIngredientType.object[0]
        //
        //            uvcViewItemCollection.uvcText.append(uvcViewGenerator.get(title: recipeItemType.description, name: "\(recipeItemType.description).CookingStepTitle", level: 2, isEditable: false))
        //            uvcViewItem = UVCViewItem()
        //            uvcViewItem.name = "\(recipeItemType.description).CookingStepTitle"
        //            uvcViewItem.type = "UVCViewItemType.Text"
        //            uvcTableColumn.uvcViewItem.append(uvcViewItem)
        //
        //            uvcTableRow.uvcTableColumn.append(uvcTableColumn)
        //            uvcTable.uvcTableRow.append(uvcTableRow)
        //        }
        //
        //        uvcViewItemCollection.uvcTable.append(uvcTable)
        //
        //        uvcViewModel.uvcViewItemCollection = uvcViewItemCollection
        //
        return uvcViewModel
    }
    
    private func processSentenceReference(json: String, neuronRequest: NeuronRequest, referenceArray: [UDCSentencePatternReference], language: String, uvcViewItem: inout UVCViewItem, uvcTableRow: inout UVCTableRow, uvcTableColumn: inout UVCTableColumn, uvcViewItemCollection: inout UVCViewItemCollection, uvcTable: inout UVCTable,  measurementValueCount: inout Int, measurementUnitCount: inout Int, textCount: inout Int, ingredientCount: inout Int, cookingMethodCount: inout Int, chefCount: inout Int, actionCount: inout Int, itemStateCount: inout Int, serialNumber: inout Int, utensilCount: inout Int, removeCount: inout Int, durationCount: inout Int, uvcRecipeViewItemMemory: inout UVCRecipeViewItemMemory, neuronResponse: inout NeuronRequest) -> Bool {
        //        let uvcViewGenerator = UVCViewGenerator()
        //        for sentencePatternReference in referenceArray {
        //
        //            print("Reference id: \(sentencePatternReference._id)")
        //            uvcTableRow = UVCTableRow()
        //            // Get sentence pattern from database for the id in sentence pattern reference
        //            let databaseOrmResultUDCSentencePattern = UDCSentencePattern.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: sentencePatternReference._id, language: language)
        //            let udcSentencePattern = databaseOrmResultUDCSentencePattern.object[0]
        //            let uvcTableColumn = UVCTableColumn()
        //            let databaseOrmResultUDCSentencePatternSubstitutionType = UDCSentencePatternSubstitutionType.get( "UDCSentencePatternSubstitutionType.Sentence", udbcDatabaseOrm!, language)
        //            if databaseOrmResultUDCSentencePatternSubstitutionType.databaseOrmError.count > 0 {
        //                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCSentencePatternSubstitutionType.databaseOrmError[0].name, description: databaseOrmResultUDCSentencePatternSubstitutionType.databaseOrmError[0].description))
        //                return false
        //            }
        //
        //            // Delete button
        //            var name: String = ""
        //            if uvcRecipeViewItemMemory.recipeItemType == "UDCIngredientType.Ingredient" {
        //                name = "Recipe.IngredientOptions.Remove-\(NSUUID().uuidString)"
        //            } else if uvcRecipeViewItemMemory.recipeItemType == "UDCIngredientType.PreCookingStep" {
        //                name = "Recipe.PreCookingStepOptions.Remove-\(NSUUID().uuidString)"
        //            } else if uvcRecipeViewItemMemory.recipeItemType == "UDCIngredientType.CookingStep" {
        //                name = "Recipe.CookingStepOptions.Remove-\(NSUUID().uuidString)"
        //            }
        //            let uvcButton = uvcViewGenerator.getButton(title: "", name: name)
        //            let uvcPhoto = uvcPhoto()
        //            uvcPhoto.name = "DeleteRow"
        //            uvcButton.uvcPhoto = uvcPhoto
        //            uvcViewItem = UVCViewItem()
        //            uvcViewItem.name = name
        //            uvcViewItem.type = "UVCViewItemType.Button"
        //            uvcViewItemCollection.uvcButton.append(uvcButton)
        //            uvcTableColumn.uvcViewItem.append(uvcViewItem)
        //
        //            // Serial number
        //            let sentencePatternDataName = databaseOrmResultUDCSentencePatternSubstitutionType.object[0].description
        //            name = "\(sentencePatternDataName)-\(NSUUID().uuidString)"
        //            uvcViewItem = UVCViewItem()
        //            uvcViewItem.name = name
        //            let uvcText = uvcViewGenerator.getText(name: name, value: "\(serialNumber))", description: "", isEditable: false)
        //            uvcText.uvcTextSize.uvcTextSizeType = UVCTextSizeType.Regular.name
        //            uvcViewItemCollection.uvcText.append(uvcText)
        //            uvcViewItem.type = "UVCViewItemType.Text"
        //            uvcTableColumn.uvcViewItem.append(uvcViewItem)
        //            serialNumber += 1
        //            textCount += 1
        //            // Loop through sentence pattern data got from sentence pattern
        //
        //            uvcRecipeViewItemMemory.column = 0
        //            for (indexSentencePatternData, sentencePatternData) in ((udcSentencePattern.udcSentencePatternData).enumerated()) {
        //                // If value is not found
        //                if (sentencePatternData.value.count == 0) || sentencePatternData.value[0].isEmpty {
        //                    let sentencePatterDataReference = getSentencePatternData(sentencePatternReference: sentencePatternReference, index: indexSentencePatternData)
        //                    if sentencePatterDataReference != nil {
        //
        //                    let jsonUtilityUVCRecipeViewItemMemory = JsonUtility<UVCRecipeViewItemMemory>()
        //                    let jsonUVCRecipeViewItemMemory = jsonUtilityUVCRecipeViewItemMemory.convertAnyObjectToJson(jsonObject:
        //                        uvcRecipeViewItemMemory)
        //
        //                    // Loop through the paths
        //                    for (pathIndex, path) in (sentencePatterDataReference?.path.enumerated())! {
        //                        if path.isEmpty {
        //                            continue
        //                        }
        //                        // If path is not empty
        //                        print("\(path)")
        //                        if let swifthPath = SwiftPath("$.\(path)") {
        //
        //                            uvcViewItem = UVCViewItem()
        //                            var value: Any?
        //                            do {
        //
        //                                 value = try swifthPath.evaluate(with: json)
        //                            } catch {
        //                                print(path); neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: DocumentItemConfigurationNeuronErrorType.DataPathNotFound.name, description: DocumentItemConfigurationNeuronErrorType.DataPathNotFound.description))
        //                                return false
        //                            }
        //
        //
        //                                let databaseOrmResultJsonType = UDCJsonType.get("UDCJsonType.Number", udbcDatabaseOrm!, language)
        //
        //                            if databaseOrmResultJsonType.object.count == 0 {
        //                                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: DocumentItemConfigurationNeuronErrorType.TypeNotFound.name, description: DocumentItemConfigurationNeuronErrorType.TypeNotFound.description))
        //                                return false
        //                            }
        //                             let jsonTypeNumber = databaseOrmResultJsonType.object[0].description
        //                            var valueStr = ""
        //
        //
        //                            if sentencePatternData.valueType == jsonTypeNumber {
        //                                let doubleValue = value as! Double
        //                                let fraction = doubleValue - (doubleValue > 0 ? floor(doubleValue) : ceil(doubleValue))
        //                                if fraction > 0 {
        //                                    valueStr = String(format: "%.2f", value as! Double)
        //                                } else {
        //                                    valueStr = String(format: "%d", value as! Int)
        //                                }
        //                            } else {
        //                                valueStr = value as! String
        //                            }
        //
        //
        //                            var databaseOrmResultUDCSentencePatternSubstitutionType = UDCSentencePatternSubstitutionType.get( "UDCSentencePatternSubstitutionType.MeasurementValue", udbcDatabaseOrm!, language)
        //                            if databaseOrmResultUDCSentencePatternSubstitutionType.object.count == 0 {
        //
        //                                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: DocumentItemConfigurationNeuronErrorType.TypeNotFound.name, description: DocumentItemConfigurationNeuronErrorType.TypeNotFound.description))
        //
        //                                return false
        //                            }
        //
        //                             var sentencePatternDataName = databaseOrmResultUDCSentencePatternSubstitutionType.object[0].description
        //                            // If Measurement value
        //                            if sentencePatternData.name ==  sentencePatternDataName  {
        //
        //                                let name = "\(sentencePatternDataName)-\(NSUUID().uuidString)"
        //                                uvcViewItem.name = name
        //                                let uvcText = uvcViewGenerator.getText(name: name, value: valueStr, description: "", isEditable: true)
        //                                uvcText.uvcTextSize.uvcTextSizeType = UVCTextSizeType.Regular.name
        //                                uvcText.modelValuePath = path
        //                                uvcText.memoryObject = jsonUVCRecipeViewItemMemory
        //                                uvcViewItemCollection.uvcText.append(uvcText)
        //                                measurementValueCount += 1
        //
        //                            }
        //
        //                            databaseOrmResultUDCSentencePatternSubstitutionType = UDCSentencePatternSubstitutionType.get( "UDCSentencePatternSubstitutionType.MeasurementUnit", udbcDatabaseOrm!, language)
        //                            if databaseOrmResultUDCSentencePatternSubstitutionType.object.count == 0 {
        //
        //                                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: DocumentItemConfigurationNeuronErrorType.TypeNotFound.name, description: DocumentItemConfigurationNeuronErrorType.TypeNotFound.description))
        //
        //                                return false
        //                            }
        //                            sentencePatternDataName = databaseOrmResultUDCSentencePatternSubstitutionType.object[0].description
        //
        //
        //                            // If Measurement unit
        //                            if sentencePatternData.name ==  sentencePatternDataName  {
        //
        //                                let name = "\(sentencePatternDataName)-\(NSUUID().uuidString)"
        //                                uvcViewItem.name = name
        //                                let uvcText = uvcViewGenerator.getText(name: name, value: "\(valueStr)", description: "", isEditable: true)
        //                                uvcText.uvcTextSize.uvcTextSizeType = UVCTextSizeType.Regular.name
        //                                uvcText.modelValuePath = path
        //                                uvcText.memoryObject = jsonUVCRecipeViewItemMemory
        //                                uvcText.uvcEditType = "UDCOptionMapNode.EditType->UDCOptionMapNode.Choice->UDCOptionMapNode.Single"
        //                                uvcText.editObjectName = "UDCMeasurementUnitType"
        //                                uvcViewItemCollection.uvcText.append(uvcText)
        //                                measurementUnitCount += 1
        //
        //                            }
        //
        //
        //
        //                            databaseOrmResultUDCSentencePatternSubstitutionType = UDCSentencePatternSubstitutionType.get( "UDCSentencePatternSubstitutionType.Ingredient", udbcDatabaseOrm!, language)
        //                            if databaseOrmResultUDCSentencePatternSubstitutionType.object.count == 0 {
        //                                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: DocumentItemConfigurationNeuronErrorType.TypeNotFound.name, description: DocumentItemConfigurationNeuronErrorType.TypeNotFound.description))
        //                                return false
        //                            }
        //                            sentencePatternDataName = databaseOrmResultUDCSentencePatternSubstitutionType.object[0].description
        //
        //                            // If ingredient
        //                            if sentencePatternData.name ==  sentencePatternDataName  {
        //                                let name = "\(sentencePatternDataName)-\(NSUUID().uuidString)"
        //                                uvcViewItem.name = name
        //                                let prevName = name
        //                                if pathIndex > 0 {
        //                                    databaseOrmResultUDCSentencePatternSubstitutionType = UDCSentencePatternSubstitutionType.get( "UDCSentencePatternSubstitutionType.Sentence", udbcDatabaseOrm!, language)
        //                                    if databaseOrmResultUDCSentencePatternSubstitutionType.object.count == 0 {
        //                                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: DocumentItemConfigurationNeuronErrorType.TypeNotFound.name, description: DocumentItemConfigurationNeuronErrorType.TypeNotFound.description))
        //                                        return false
        //                                    }
        //                                    sentencePatternDataName = databaseOrmResultUDCSentencePatternSubstitutionType.object[0].description
        //
        //                                    let name = "\(sentencePatternDataName)-\(NSUUID().uuidString)"
        //                                    uvcViewItem.name = name
        //                                    let uvcText = uvcViewGenerator.getText(name: name, value: ",", description: "", isEditable: false)
        //                                    uvcText.uvcTextSize.uvcTextSizeType = UVCTextSizeType.Regular.name
        //                                    uvcViewItemCollection.uvcText.append(uvcText)
        //                                    uvcViewItem.type = "UVCViewItemType.Text"
        //                                    uvcTableColumn.uvcViewItem.append(uvcViewItem)
        //                                    textCount += 1
        //                                    uvcViewItem = UVCViewItem()
        //                                    uvcViewItem.name = prevName
        //                                }
        //                                let uvcText = uvcViewGenerator.getText(name: name, value: "\(valueStr)", description: "", isEditable: true)
        //                                uvcText.uvcTextSize.uvcTextSizeType = UVCTextSizeType.Regular.name
        //                                uvcText.modelValuePath = path
        //                                uvcText.memoryObject = jsonUVCRecipeViewItemMemory
        //                                uvcText.uvcEditType = "UDCOptionMapNode.EditType->UDCOptionMapNode.Choice->UDCOptionMapNode.Single"
        //                                uvcText.editObjectName = "UDCIngredientType"
        //                                uvcViewItemCollection.uvcText.append(uvcText)
        //                                ingredientCount += 1
        //
        //                            }
        //
        //                            databaseOrmResultUDCSentencePatternSubstitutionType = UDCSentencePatternSubstitutionType.get( "UDCSentencePatternSubstitutionType.CookingMethod", udbcDatabaseOrm!, language)
        //                            if databaseOrmResultUDCSentencePatternSubstitutionType.object.count == 0 {
        //                                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: DocumentItemConfigurationNeuronErrorType.TypeNotFound.name, description: DocumentItemConfigurationNeuronErrorType.TypeNotFound.description))
        //
        //                                return false
        //                            }
        //                            sentencePatternDataName = databaseOrmResultUDCSentencePatternSubstitutionType.object[0].description
        //
        //
        //                            // If ingredient
        //                            if sentencePatternData.name ==  sentencePatternDataName  {
        //
        //                                let name = "\(sentencePatternDataName)-\(NSUUID().uuidString)"
        //                                uvcViewItem.name = name
        //                                let uvcText = uvcViewGenerator.getText(name: name, value: "\(valueStr)", description: "", isEditable: true)
        //                                uvcText.uvcTextSize.uvcTextSizeType = UVCTextSizeType.Regular.name
        //                                uvcText.modelValuePath = path
        //                                uvcText.memoryObject = jsonUVCRecipeViewItemMemory
        //                                uvcText.uvcEditType = "UDCOptionMapNode.EditType->UDCOptionMapNode.Choice->UDCOptionMapNode.Single"
        //                                uvcText.editObjectName = "UDCCookingMethodType"
        //                                uvcViewItemCollection.uvcText.append(uvcText)
        //                                cookingMethodCount += 1
        //
        //                            }
        //
        //
        //                            databaseOrmResultUDCSentencePatternSubstitutionType = UDCSentencePatternSubstitutionType.get( "UDCSentencePatternSubstitutionType.Chef", udbcDatabaseOrm!, language)
        //                            if databaseOrmResultUDCSentencePatternSubstitutionType.object.count == 0 {
        //
        //                                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: DocumentItemConfigurationNeuronErrorType.TypeNotFound.name, description: DocumentItemConfigurationNeuronErrorType.TypeNotFound.description))
        //
        //
        //                                return false
        //                            }
        //                            sentencePatternDataName = databaseOrmResultUDCSentencePatternSubstitutionType.object[0].description
        //
        //
        //
        //                            // If ingredient
        //                            if sentencePatternData.name ==  sentencePatternDataName  {
        //
        //                                let name = "\(sentencePatternDataName)-\(NSUUID().uuidString)"
        //                                uvcViewItem.name = name
        //                                let uvcText = uvcViewGenerator.getText(name: name, value: "\(valueStr)", description: "", isEditable: true)
        //                                uvcText.uvcTextSize.uvcTextSizeType = UVCTextSizeType.Regular.name
        //                                uvcText.modelValuePath = path
        //                                uvcText.memoryObject = jsonUVCRecipeViewItemMemory
        //                                uvcText.uvcEditType = "UDCOptionMapNode.EditType->UDCOptionMapNode.Choice->UDCOptionMapNode.Single"
        //                                uvcText.editObjectName = "UDCCookingChefType"
        //                                uvcViewItemCollection.uvcText.append(uvcText)
        //                                chefCount += 1
        //                            }
        //
        //                            databaseOrmResultUDCSentencePatternSubstitutionType = UDCSentencePatternSubstitutionType.get( "UDCSentencePatternSubstitutionType.Duration", udbcDatabaseOrm!, language)
        //                            if databaseOrmResultUDCSentencePatternSubstitutionType.object.count == 0 {
        //
        //                                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: DocumentItemConfigurationNeuronErrorType.TypeNotFound.name, description: DocumentItemConfigurationNeuronErrorType.TypeNotFound.description))
        //
        //
        //                                return false
        //                            }
        //                            sentencePatternDataName = databaseOrmResultUDCSentencePatternSubstitutionType.object[0].description
        //
        //
        //
        //                            // If ingredient
        //                            if sentencePatternData.name ==  sentencePatternDataName  {
        //
        //                                let name = "\(sentencePatternDataName)-\(NSUUID().uuidString)"
        //                                uvcViewItem.name = name
        //                                let uvcText = uvcViewGenerator.getText(name: name, value: "\(valueStr)", description: "", isEditable: true)
        //                                uvcText.uvcTextSize.uvcTextSizeType = UVCTextSizeType.Regular.name
        //                                uvcText.modelValuePath = path
        //                                uvcText.memoryObject = jsonUVCRecipeViewItemMemory
        //                                uvcText.uvcEditType = "UDCOptionMapNode.EditType->UDCOptionMapNode.Choice->UDCOptionMapNode.Single"
        //                                uvcText.editObjectName = "UDCDurationType"
        //                                uvcViewItemCollection.uvcText.append(uvcText)
        //                                durationCount += 1
        //                            }
        //
        //
        //                            databaseOrmResultUDCSentencePatternSubstitutionType = UDCSentencePatternSubstitutionType.get( "UDCSentencePatternSubstitutionType.Action", udbcDatabaseOrm!, language)
        //                            if databaseOrmResultUDCSentencePatternSubstitutionType.object.count == 0 {
        //
        //                                 neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: DocumentItemConfigurationNeuronErrorType.TypeNotFound.name, description: DocumentItemConfigurationNeuronErrorType.TypeNotFound.description))
        //
        //
        //                                return false
        //                            }
        //                            sentencePatternDataName = databaseOrmResultUDCSentencePatternSubstitutionType.object[0].description
        //
        //
        //                            // If ingredient
        //
        //                            if sentencePatternData.name ==  sentencePatternDataName  {
        //
        //                                let name = "\(sentencePatternDataName)-\(NSUUID().uuidString)"
        //                                uvcViewItem.name = name
        //                                let uvcText = uvcViewGenerator.getText(name: name, value: "\(valueStr)", description: "", isEditable: true)
        //                                uvcText.uvcTextSize.uvcTextSizeType = UVCTextSizeType.Regular.name
        //                                uvcText.modelValuePath = path
        //                                uvcText.memoryObject = jsonUVCRecipeViewItemMemory
        //                                uvcText.uvcEditType = "UDCOptionMapNode.EditType->UDCOptionMapNode.Choice->UDCOptionMapNode.Single"
        //                                uvcText.editObjectName = "UDCActionType"
        //                                uvcViewItemCollection.uvcText.append(uvcText)
        //                                actionCount += 1
        //                            }
        //
        //
        //
        //                            databaseOrmResultUDCSentencePatternSubstitutionType = UDCSentencePatternSubstitutionType.get( "UDCSentencePatternSubstitutionType.Utensil", udbcDatabaseOrm!, language)
        //                            if databaseOrmResultUDCSentencePatternSubstitutionType.object.count == 0 {
        //
        //
        //                                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: DocumentItemConfigurationNeuronErrorType.TypeNotFound.name, description: DocumentItemConfigurationNeuronErrorType.TypeNotFound.description))
        //
        //                                return false
        //                            }
        //                            sentencePatternDataName = databaseOrmResultUDCSentencePatternSubstitutionType.object[0].description
        //
        //
        //                            // If ingredient
        //                            if sentencePatternData.name ==  sentencePatternDataName  {
        //
        //                                let name = "\(sentencePatternDataName)-\(NSUUID().uuidString)"
        //                                uvcViewItem.name = name
        //                                let prevName = name
        //                                if pathIndex > 0 {
        //                                    databaseOrmResultUDCSentencePatternSubstitutionType = UDCSentencePatternSubstitutionType.get( "UDCSentencePatternSubstitutionType.Sentence", udbcDatabaseOrm!, language)
        //                                    if databaseOrmResultUDCSentencePatternSubstitutionType.object.count == 0 {
        //                                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: DocumentItemConfigurationNeuronErrorType.TypeNotFound.name, description: DocumentItemConfigurationNeuronErrorType.TypeNotFound.description))
        //                                        return false
        //                                    }
        //                                    sentencePatternDataName = databaseOrmResultUDCSentencePatternSubstitutionType.object[0].description
        //
        //
        //                                    let name = "\(sentencePatternDataName)-\(NSUUID().uuidString)"
        //                                    uvcViewItem.name = name
        //                                    let uvcText = uvcViewGenerator.getText(name: name, value: ",", description: "", isEditable: false)
        //                                    uvcText.uvcTextSize.uvcTextSizeType = UVCTextSizeType.Regular.name
        //                                    uvcViewItemCollection.uvcText.append(uvcText)
        //                                    uvcViewItem.type = "UVCViewItemType.Text"
        //                                    uvcTableColumn.uvcViewItem.append(uvcViewItem)
        //                                    textCount += 1
        //                                    uvcViewItem = UVCViewItem()
        //                                    uvcViewItem.name = prevName
        //                                }
        //                                let uvcText = uvcViewGenerator.getText(name: name, value: "\(valueStr)", description: "", isEditable: true)
        //                                uvcText.uvcTextSize.uvcTextSizeType = UVCTextSizeType.Regular.name
        //                                uvcText.modelValuePath = path
        //                                uvcText.memoryObject = jsonUVCRecipeViewItemMemory
        //                                uvcText.uvcEditType = "UDCOptionMapNode.EditType->UDCOptionMapNode.Choice->UDCOptionMapNode.Single"
        //                                uvcText.editObjectName = "UDCUtensilType"
        //                                uvcViewItemCollection.uvcText.append(uvcText)
        //                                utensilCount += 1
        //
        //                            }
        //
        //
        //                            databaseOrmResultUDCSentencePatternSubstitutionType = UDCSentencePatternSubstitutionType.get( "UDCSentencePatternSubstitutionType.ItemState", udbcDatabaseOrm!, language)
        //                            if databaseOrmResultUDCSentencePatternSubstitutionType.object.count == 0 {
        //
        //                             neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: DocumentItemConfigurationNeuronErrorType.TypeNotFound.name, description: DocumentItemConfigurationNeuronErrorType.TypeNotFound.description))
        //
        //
        //                                return false
        //                            }
        //                            sentencePatternDataName = databaseOrmResultUDCSentencePatternSubstitutionType.object[0].description
        //
        //
        //
        //                            // If ingredient
        //                            if sentencePatternData.name ==  sentencePatternDataName  {
        //
        //                                let name = "\(sentencePatternDataName)-\(NSUUID().uuidString)"
        //                                uvcViewItem.name = name
        //                                let prevName = name
        //                                // multiple values
        //                                if pathIndex > 0 {
        //                                    databaseOrmResultUDCSentencePatternSubstitutionType = UDCSentencePatternSubstitutionType.get( "UDCSentencePatternSubstitutionType.Sentence", udbcDatabaseOrm!, language)
        //                                    if databaseOrmResultUDCSentencePatternSubstitutionType.object.count == 0 {
        //                                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: DocumentItemConfigurationNeuronErrorType.TypeNotFound.name, description: DocumentItemConfigurationNeuronErrorType.TypeNotFound.description))
        //                                        return false
        //                                    }
        //                                    sentencePatternDataName = databaseOrmResultUDCSentencePatternSubstitutionType.object[0].description
        //
        //                                    let name = "\(sentencePatternDataName)-\(NSUUID().uuidString)"
        //                                    uvcViewItem.name = name
        //                                    let uvcText = uvcViewGenerator.getText(name: name, value: ",", description: "", isEditable: false)
        //                                    uvcText.uvcTextSize.uvcTextSizeType = UVCTextSizeType.Regular.name
        //                                    uvcViewItemCollection.uvcText.append(uvcText)
        //                                    uvcViewItem.type = "UVCViewItemType.Text"
        //                                    uvcTableColumn.uvcViewItem.append(uvcViewItem)
        //                                    textCount += 1
        //                                    uvcViewItem = UVCViewItem()
        //                                    uvcViewItem.name = prevName
        //                                }
        //                                let uvcText = uvcViewGenerator.getText(name: prevName, value: "\(valueStr)", description: "", isEditable: true)
        //                                uvcText.uvcTextSize.uvcTextSizeType = UVCTextSizeType.Regular.name
        //                                uvcText.modelValuePath = path
        //                                uvcText.memoryObject = jsonUVCRecipeViewItemMemory
        //                                uvcText.uvcEditType = "UDCOptionMapNode.EditType->UDCOptionMapNode.Choice->UDCOptionMapNode.Single"
        //                                uvcText.editObjectName = "UDCItemStateType"
        //                                uvcViewItemCollection.uvcText.append(uvcText)
        //                                itemStateCount += 1
        //                            }
        //
        //                            uvcViewItem.type = "UVCViewItemType.Text"
        //                            uvcTableColumn.uvcViewItem.append(uvcViewItem)
        //                        } else { // If path is empty report error. Stop processing
        //
        //                            neuronResponse = neuronUtility!.getNeuronResponseError(neuronRequest: neuronRequest, errorName: DocumentItemConfigurationNeuronErrorType.ErrorInProcessingView.name, errorDescription:  DocumentItemConfigurationNeuronErrorType.ErrorInProcessingView.description)
        //
        //                            return false
        //                        }
        //                    }
        //
        //                    }
        //                    uvcRecipeViewItemMemory.column += 1
        //                } else {
        //
        //                    print("Not empty: \(sentencePatternData.value)")
        //                    // If Sentence, Punctuation, etc.,
        //                    uvcRecipeViewItemMemory.column = indexSentencePatternData
        //                    let databaseOrmResultUDCSentencePatternSubstitutionType = UDCSentencePatternSubstitutionType.get( "UDCSentencePatternSubstitutionType.Sentence", udbcDatabaseOrm!, language)
        //                    if databaseOrmResultUDCSentencePatternSubstitutionType.object.count == 0 {
        //                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: DocumentItemConfigurationNeuronErrorType.TypeNotFound.name, description: DocumentItemConfigurationNeuronErrorType.TypeNotFound.description))
        //                        return false
        //                    }
        //                    let sentencePatternDataName = databaseOrmResultUDCSentencePatternSubstitutionType.object[0].description
        //
        //                    let name = "\(sentencePatternDataName)-\(NSUUID().uuidString)"
        //                    uvcViewItem = UVCViewItem()
        //                    uvcViewItem.name = name
        //                    let uvcText = uvcViewGenerator.getText(name: name, value: (sentencePatternData.value[0]), description: "", isEditable: false)
        //                    uvcText.uvcTextSize.uvcTextSizeType = UVCTextSizeType.Regular.name
        //                    uvcViewItemCollection.uvcText.append(uvcText)
        //                    uvcViewItem.type = "UVCViewItemType.Text"
        //                    uvcTableColumn.uvcViewItem.append(uvcViewItem)
        //                    textCount += 1
        //
        //
        //                }
        //
        //            }
        //
        //            uvcTableRow.uvcTableColumn.append(uvcTableColumn)
        //            uvcTable.uvcTableRow.append(uvcTableRow)
        //        }
        
        
        return true
    }
    
    private func getSentencePatternData(sentencePatternReference: UDCSentencePatternReference, index: Int) -> UDCSentencePatternDataReference? {
        for sentencePatternDataReference in sentencePatternReference.udcSentencePatternDataReference {
            if sentencePatternDataReference.orderNumber == index+1 {
                return sentencePatternDataReference
            }
        }
        
        return nil
    }
    
    
    
    static public func getName() -> String {
        return "DocumentItemConfigurationNeuron"
    }
    
    static public func getDescription() -> String {
        return "Recipe Neuron"
    }
    
    static public func getDendrite(sourceId: String) -> (Neuron) {
        var neuron: Neuron?
        
        serialQueue.sync {
            print("Before: \(dendriteMap.debugDescription)")
            neuron = dendriteMap[sourceId]
            if neuron == nil {
                print("\(getName()): Created: \(sourceId)")
                dendriteMap[sourceId] = DocumentItemConfigurationNeuron()
                neuron = dendriteMap[sourceId]
            }
            print("After creation: \(dendriteMap.debugDescription)")
        }
        
        return  neuron!;
    }
    
    
    
    private func setChildResponse(sourceId: String, neuronRequest: NeuronRequest) {
        responseMap[sourceId] = neuronRequest
    }
    
    public func getChildResponse(sourceId: String) -> NeuronRequest {
        var neuronResponse: NeuronRequest?
        print(responseMap)
        if let _ = responseMap[sourceId] {
            neuronResponse = responseMap[sourceId]
            responseMap.removeValue(forKey: sourceId)
        }
        if neuronResponse == nil {
            neuronResponse = NeuronRequest()
        }
        
        return neuronResponse!
    }
    
    public static func getDendriteSize() -> (Int) {
        return dendriteMap.count
    }
    
    public static func removeDendrite(sourceId: String) {
        serialQueue.sync {
            print("neuronUtility: removed neuron: "+sourceId)
            dendriteMap.removeValue(forKey: sourceId)
            print("After removal \(getName()): \(dendriteMap.debugDescription)")
        }
    }
    
    
    public func setDendrite(neuronRequest: NeuronRequest, udbcDatabaseOrm: UDBCDatabaseOrm,  neuronUtility: NeuronUtility) {
        var neuronResponse = NeuronRequest()
        do {
            self.udbcDatabaseOrm = udbcDatabaseOrm
            self.neuronUtility = neuronUtility
            
            if neuronRequest.neuronOperation.parent == true {
                print("\(DocumentItemConfigurationNeuron.getName()) Parent show setting child to true")
                neuronResponse.neuronOperation.child = true
            }
            
            var neuronRequestLocal = neuronRequest
            
            
            self.neuronUtility!.setUDBCDatabaseOrm(udbcDatabaseOrm: udbcDatabaseOrm, neuronName: DocumentItemConfigurationNeuron.getName())
            self.neuronUtility!.setUNCMain( neuronName: DocumentItemConfigurationNeuron.getName())
            documentParser.setNeuronUtility(neuronUtility: self.neuronUtility!,  neuronName: DocumentItemConfigurationNeuron.getName())
            documentParser.setUDBCDatabaseOrm(udbcDatabaseOrm: udbcDatabaseOrm, neuronName: DocumentItemConfigurationNeuron.getName())
            
            let continueProcess = try preProcess(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            if continueProcess == false {
                print("\(DocumentItemConfigurationNeuron.getName()): don't process return")
                return
            }
            
            validateRequest(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            
            if neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError!.count > 0 {
                print("\(DocumentItemConfigurationNeuron.getName()) error in validation return")
                let neuronSource = self.neuronUtility!.getDendrite(sourceId: neuronRequest.neuronSource._id, neuronName: neuronRequest.neuronSource.name)
                neuronSource!.setDendrite(neuronRequest: neuronResponse, udbcDatabaseOrm: self.udbcDatabaseOrm!, neuronUtility: self.neuronUtility!)
                return
            }
            
            
            
            // Controller says no need to
            
            neuronResponse.neuronOperation.acknowledgement = false
            
            if neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError!.count == 0 {
                if neuronRequest.neuronOperation.asynchronus == true {
                    print("\(DocumentItemConfigurationNeuron.getName()) asynchronus store the request and return")
                    neuronResponse.neuronOperation.response = true
                    neuronResponse.neuronOperation.neuronData.text = ""
                    self.neuronUtility!.storeInDatabase(neuronRequest: neuronRequest)
                    return
                } else {
                    if neuronRequest.neuronOperation.synchronus == true {
                        if neuronRequest.neuronOperation.asynchronusProcess == true {
                            print("\(DocumentItemConfigurationNeuron.getName()) asynchronus so update the status as pending")
                            let rows = try NeuronRequest.update(udbcDatabaseOrm: udbcDatabaseOrm, id: (neuronRequest._id), status: NeuronOperationStatusType.InProgress.name)
                        }
                        neuronResponse = self.neuronUtility!.getNeuronAcknowledgement(neuronRequest: neuronRequest)
                        neuronResponse.neuronOperation.acknowledgement = true
                        neuronResponse.neuronOperation.neuronData.text = ""
                        let neuronSource = self.neuronUtility!.getDendrite(sourceId: neuronRequest.neuronSource._id, neuronName: neuronRequest.neuronSource.name)
                        neuronSource!.setDendrite(neuronRequest: neuronResponse, udbcDatabaseOrm: self.udbcDatabaseOrm!, neuronUtility: self.neuronUtility!)
                        neuronResponse.neuronOperation.acknowledgement = false
                        try process(neuronRequest: neuronRequestLocal, neuronResponse: &neuronResponse)
                    }
                }
                
            }
            
            
            
        } catch {
            print("\(DocumentItemConfigurationNeuron.getName()): Error thrown in setdendrite: \(error)")
            neuronResponse = self.neuronUtility!.getNeuronResponseError(neuronRequest: neuronRequest, errorName: NeuronOperationErrorType.ErrorInProcessing.name, errorDescription:  error.localizedDescription)
            
        }
        
        defer {
            postProcess(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        }
    }
    
    private func validateRequest(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) {
        neuronResponse = neuronUtility!.validateRequest(neuronRequest: neuronRequest)
        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
            return
        }
        
        
    }
    
    private func preProcess(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws -> Bool {
        print("\(DocumentItemConfigurationNeuron.getName()): pre process")
        
        print("neuronUtility: pre process: \(neuronRequest.neuronSource._id)")
        let neuronRequestLocal: NeuronRequest = neuronRequest
        
        if neuronRequestLocal.neuronOperation.acknowledgement == true {
            print("\(DocumentItemConfigurationNeuron.getName()) acknowledgement so return")
            return false
        }
        
        if neuronRequestLocal.neuronOperation.response == true {
            setChildResponse(sourceId: neuronRequestLocal.neuronSource._id, neuronRequest: neuronRequest)
            print("\(DocumentItemConfigurationNeuron.getName()) response so return")
            return false
        }
        
        neuronResponse.neuronSource._id = neuronRequest.neuronSource._id
        
        if neuronResponse.neuronOperation._id.isEmpty {
            neuronResponse.neuronOperation._id = try udbcDatabaseOrm!.generateId()
        }
        
        if neuronRequestLocal.neuronOperation.asynchronus == true &&
            neuronRequestLocal.neuronOperation._id.isEmpty {
            neuronRequestLocal.neuronOperation._id = NSUUID().uuidString
        }
        
        if neuronRequest.neuronOperation.name == "NeuronOperation.GetResponse" {
            let databaseOrmResultFromDatabase = neuronUtility!.getFromDatabase(neuronRequest: neuronRequest)
            if databaseOrmResultFromDatabase.databaseOrmError.count > 0 {
                for databaseError in databaseOrmResultFromDatabase.databaseOrmError {
                    neuronResponse = neuronUtility!.getNeuronResponseError(neuronRequest: neuronRequest, errorName: databaseError.name, errorDescription:  databaseError.description)
                }
                return false
            }
            neuronResponse = databaseOrmResultFromDatabase.object[0]
            let neuronSource = neuronUtility!.getDendrite(sourceId: neuronRequest.neuronSource._id, neuronName: neuronRequest.neuronSource.name)
            neuronSource!.setDendrite(neuronRequest: neuronResponse, udbcDatabaseOrm: self.udbcDatabaseOrm!, neuronUtility: self.neuronUtility!)
            print("\(DocumentItemConfigurationNeuron.getName()) got response so return")
            return false
        }
        
        return true
    }
    
    private func postProcess(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) {
        print("\(DocumentItemConfigurationNeuron.getName()): post process")
        
        
        
        do {
            if neuronRequest.neuronOperation.asynchronusProcess == true {
                print("\(DocumentItemConfigurationNeuron.getName()) Asynchronus so storing response in database")
                neuronResponse.neuronOperation.neuronOperationStatus.status = NeuronOperationStatusType.Completed.name
                //                let rows = try NeuronRequest.update(udbcDatabaseOrm: udbcDatabaseOrm!, id: (neuronRequest._id), status: NeuronOperationStatusType.Completed.name)
                //                neuronUtility!.storeInDatabase(neuronRequest: neuronResponse)
                
            }
            print("\(DocumentItemConfigurationNeuron.getName()) Informing: \(String(describing: neuronRequest.neuronSource.name))")
            let neuronSource = neuronUtility!.getDendrite(sourceId: neuronRequest.neuronSource._id, neuronName: neuronRequest.neuronSource.name)
            neuronSource!.setDendrite(neuronRequest: neuronResponse, udbcDatabaseOrm: self.udbcDatabaseOrm!, neuronUtility: self.neuronUtility!)
            
        } catch {
            print(error)
            print("\(DocumentItemConfigurationNeuron.getName()): Error thrown in post process: \(error)")
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: NeuronOperationErrorType.ErrorInProcessing.name, description: error.localizedDescription))
        }
        
        defer {
            DocumentItemConfigurationNeuron.removeDendrite(sourceId: neuronRequest.neuronSource._id)
            print("Recipe Neuron  RESPONSE MAP: \(responseMap)")
            print("Recipe Neuron  Dendrite MAP: \(DocumentItemConfigurationNeuron.dendriteMap)")
        }
        
    }
}
