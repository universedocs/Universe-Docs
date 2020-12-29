//
//  DocumentItemNeuron.swift
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
import UDocsDocumentModel
import UDocsDocumentUtility
import UDocsDatabaseModel
import UDocsDatabaseUtility
import UDocsNeuronModel
import UDocsNeuronUtility
import UDocsViewModel
import UDocsViewUtility
import UDocsValidationUtility
import UDocsDocumentGraphNeuronModel
import UDocsGrammarNeuronModel
import UDocsOptionMapNeuronModel
import UDocsDocumentItemNeuronModel

public class DocumentItemNeuron : Neuron {
    public static func getRootResponse(neuronSourceId: String) -> NeuronRequest {
        return NeuronRequest()
    }
    var neuronUtility: NeuronUtility? = nil
    let uvcViewGenerator = UVCViewGenerator()
    let stringUtility = StringUtility()
    let documentParser = DocumentParser()
    let documentItemConfigurationUtility = DocumentItemConfigurationUtility()
    var udbcDatabaseOrm: UDBCDatabaseOrm?
    static var dendriteMap: [String : Neuron] = [String : Neuron]()
    private var responseMap: [String : NeuronRequest] = [String : NeuronRequest]()
    static let serialQueue = DispatchQueue(label: "SerialQueue")
    
    
    private func process(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        neuronResponse.neuronOperation.response = true
        print("\(DocumentItemNeuron.getName()): process: \(neuronRequest.neuronOperation.name)")
        if neuronRequest.neuronOperation.name == "DocumentItemNeuron.Document.AddCategory" {
//            try addRecipeCategory(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Get.DocumentModels" {
            try getDocumentModels(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.SearchResult.DocumentItem" {
//            try searchPhotoItem(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Generate.DocumentItem.View.Insert" {
            try generateDocumentItemViewForInsert(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Generate.DocumentItem.View.Change" {
            try generateDocumentItemViewForChange(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Get.SentencePattern.DocumentItem" {
            try getSentencePatternForDocumentItem(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Generate.DocumentItem.View.Reference" {
            try getDocumentSentenceListOptionView(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Get.Categories" {
            try getDocumentCategories(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Get.Category.Options" {
            try getDocumentCategoryOptions(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else if neuronRequest.neuronOperation.name.hasPrefix("DocumentGraphNeuron.Document.Type") {
            try documentGraphTypeProcess(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.Validate.Insert" {
            try validateInsertRequest(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.Validate.Delete" {
            try validateDeleteRequest(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.Validate.Delete.Line" {
            try validateDeleteLineRequest(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Generate.Document.View" {
            try generateDocumentView(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.IdName" {
            try getDocumentIdName(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else if neuronRequest.neuronOperation.name == "DocumentItemNeuron.Search.DocumentItem" {
            try searchDocumentItem(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else if neuronRequest.neuronOperation.name == "DocumentItemNeuron.Get.Sentence.Pattern" {
            try getSentencePatternForDocumentItemCommon(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else if neuronRequest.neuronOperation.name == "DocumentItemNeuron.Get.Sentence.Pattern.Data.Group.Value" {
            try getSentencePatternDataGroupValueForDocumentItem(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else if neuronRequest.neuronOperation.name == "DocumentItemNeuron.Get.DocumentItem.Options" {
                   try getDocumentItemOptions(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
               } else if neuronRequest.neuronOperation.name == "DocumentMapNeuron.DocumentMapNode.Remove" {
            //            let removeDocumentMapNodeRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: RemoveDocumentMapNodeRequest())
            //            let databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: removeDocumentMapNodeRequest.udcDocumentMapNode.documentId, language: removeDocumentMapNodeRequest.language)
            //            if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
            //                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocument.databaseOrmError[0].name, description: databaseOrmResultUDCDocument.databaseOrmError[0].description))
            //                return
            //            }
            //            let udcDocument = databaseOrmResultUDCDocument.object[0]
            //            let databaseOrmResultUDCDocumentRemove = UDCDocument.remove(udbcDatabaseOrm: udbcDatabaseOrm!, id: removeDocumentMapNodeRequest.udcDocumentMapNode.documentId) as DatabaseOrmResult<UDCDocument>
            //            if databaseOrmResultUDCDocumentRemove.databaseOrmError.count > 0 {
            //                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentRemove.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentRemove.databaseOrmError[0].description))
            //                return
            //            }
            //            let databaseOrmResultudcDocumentGraphModelRemove = udcDocumentGraphModel.remove(udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocument.udcDocumentGraphModel[0]._id)  as DatabaseOrmResult<udcDocumentGraphModel>
            //            if databaseOrmResultudcDocumentGraphModelRemove.databaseOrmError.count > 0 {
            //                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModelRemove.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModelRemove.databaseOrmError[0].description))
            //                return
            //            }
        } else if neuronRequest.neuronOperation.name == "DocumentMapNeuron.DocumentMapNode.Change" {
            //            let changeDocumentMapNodeRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: ChangeDocumentMapNodeRequest())
            //
            //            // Get and update the name of the document model
            //            let databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: changeDocumentMapNodeRequest.udcDocumentMapNode.documentId, language: changeDocumentMapNodeRequest.language)
            //            if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
            //                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocument.databaseOrmError[0].name, description: databaseOrmResultUDCDocument.databaseOrmError[0].description))
            //                return
            //            }
            //            let udcDocument = databaseOrmResultUDCDocument.object[0]
            //            udcDocument.name = changeDocumentMapNodeRequest.udcDocumentMapNode.name
            //            let databaseOrmResultUDCDocumentUpdate = UDCDocument.update(udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocument)
            //            if databaseOrmResultUDCDocumentUpdate.databaseOrmError.count > 0 {
            //                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentUpdate.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentUpdate.databaseOrmError[0].description))
            //                return
            //            }
            //
            //            // Get and update the name of recipe model
            //            let id = udcDocument.udcDocumentGraphModel[0]._id
            //            let databaseOrmResultUDCRecpipe = udcDocumentGraphModel.update(udbcDatabaseOrm: udbcDatabaseOrm!, id: id, name: changeDocumentMapNodeRequest.udcDocumentMapNode.name) as DatabaseOrmResult<udcDocumentGraphModel>
            //            if databaseOrmResultUDCRecpipe.databaseOrmError.count > 0 {
            //                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCRecpipe.databaseOrmError[0].name, description: databaseOrmResultUDCRecpipe.databaseOrmError[0].description))
            //                return
            //            }
//        } else if neuronRequest.neuronOperation.name == RecipeNeuronOperationType.SentencePattern.name {
            //            let sentencePatternRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: SentencePatternRequest())
            //            let databaseOrmResultUDCSentencePatternCategory = UDCSentencePatternCategory.get(udbcDatabaseOrm: udbcDatabaseOrm!, name: sentencePatternRequest.category, language: sentencePatternRequest.language)
            //            if databaseOrmResultUDCSentencePatternCategory.databaseOrmError.count > 0 {
            //                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCSentencePatternCategory.databaseOrmError[0].name, description: databaseOrmResultUDCSentencePatternCategory.databaseOrmError[0].description))
            //                return
            //            }
            //            let udcSentencePatternCategory = databaseOrmResultUDCSentencePatternCategory.object[0]
            //            let databaseOrmResultUDCSentencePattern = UDCSentencePattern.get(udbcDatabaseOrm: udbcDatabaseOrm!, udcSentencePatternCategoryId:
            //                udcSentencePatternCategory._id, language: sentencePatternRequest.language)
            //            let udcSentencePattern = databaseOrmResultUDCSentencePattern.object
            //            let sentencePatternResponse = SentencePatternResponse()
            //            sentencePatternResponse.udcSentencePattern = udcSentencePattern
            //            let jsonUtilitySentencePattern = JsonUtility<SentencePatternResponse>()
            //            let jsonSentencePattern = jsonUtilitySentencePattern.convertAnyObjectToJson(jsonObject: sentencePatternResponse)
            //            neuronResponse.neuronOperation.neuronData.text = jsonSentencePattern
        } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.Get" {
            
            //            let documentRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: GetDocumentRequest())
            //            var getDocumentResponse = GetDocumentResponse()
            //
            //            if documentRequest.documentType == "UDCDocumentViewType.Recipe" {
            //                getDocumentResponse = try getRecipe(documentRequest: documentRequest, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            //            }
            //
            //            let jsonUtilityDocumentGraphNeuronResponse = JsonUtility<GetDocumentResponse>()
            //            let jsonDocumentGraphNeuronResponse = jsonUtilityDocumentGraphNeuronResponse.convertAnyObjectToJson(jsonObject: getDocumentResponse)
            //
            //            neuronResponse.neuronOperation.neuronData.text = jsonDocumentGraphNeuronResponse
            
        } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.Save" {
            //
            //            let saveDocumentRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: SaveDocumentRequest())
            //            var getDocumentResponse = GetDocumentResponse()
            //
            //            if saveDocumentRequest.udcDocument.udcDocumentGraphModel[0].udcDocumentType == "UDCDocumentViewType.Recipe" {
            //                getDocumentResponse = try saveRecipe(saveDocumentRequest: saveDocumentRequest, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            //            }
            //
            //            let jsonUtilityDocumentGraphNeuronResponse = JsonUtility<GetDocumentResponse>()
            //            let jsonDocumentGraphNeuronResponse = jsonUtilityDocumentGraphNeuronResponse.convertAnyObjectToJson(jsonObject: getDocumentResponse)
            //
            //            neuronResponse.neuronOperation.neuronData.text = jsonDocumentGraphNeuronResponse
            //
            //            try callOtherNeuron(neuronRequest: neuronResponse, neuronResponse: &neuronResponse, neuronName: DocumentGraphNeuron.getName(), overWriteResponse: false)
            
        } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.Change" {
            //
            //            let saveDocumentRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: SaveDocumentRequest())
            //            var getDocumentResponse = GetDocumentResponse()
            //
            //            if saveDocumentRequest.udcDocument.udcDocumentGraphModel[0].udcDocumentType == "UDCDocumentViewType.Recipe" {
            //                getDocumentResponse = try changeRecipe(saveDocumentRequest: saveDocumentRequest, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            //            }
            //
            //            let jsonUtilityDocumentGraphNeuronResponse = JsonUtility<GetDocumentResponse>()
            //            let jsonDocumentGraphNeuronResponse = jsonUtilityDocumentGraphNeuronResponse.convertAnyObjectToJson(jsonObject: getDocumentResponse)
            //
            //            neuronResponse.neuronOperation.neuronData.text = jsonDocumentGraphNeuronResponse
            //
            //            try callOtherNeuron(neuronRequest: neuronResponse, neuronResponse: &neuronResponse, neuronName: DocumentGraphNeuron.getName(), overWriteResponse: false)
        } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.New" {
            
            //            let documentRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: GetDocumentRequest())
            //            var getDocumentResponse = GetDocumentResponse()
            //
            //            if documentRequest.documentType == "UDCDocumentViewType.Recipe" {
            //                getDocumentResponse = try newRecipe(documentRequest: documentRequest, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            //            }
            //
            //            let jsonUtilityDocumentGraphNeuronResponse = JsonUtility<GetDocumentResponse>()
            //            let jsonDocumentGraphNeuronResponse = jsonUtilityDocumentGraphNeuronResponse.convertAnyObjectToJson(jsonObject: getDocumentResponse)
            //
            //            neuronResponse.neuronOperation.neuronData.text = jsonDocumentGraphNeuronResponse
            //
            //            try callOtherNeuron(neuronRequest: neuronResponse, neuronResponse: &neuronResponse, neuronName: DocumentGraphNeuron.getName(), overWriteResponse: false)
        }
        
        
    }
    
    private func getSentencePatternForDocumentItemCommon(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let getSentencePatternForDocumentItemRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: GetGraphSentencePatternForDocumentItemRequest())
        
        var udcSentencePatternDataGroupValue: [UDCSentencePatternDataGroupValue]?
        if (getSentencePatternForDocumentItemRequest.udcSentencePatternDataGroupValue == nil) || getSentencePatternForDocumentItemRequest.udcSentencePatternDataGroupValue!.count == 0 {
            if !getSentencePatternForDocumentItemRequest.isGeneratedItem {
                try getSentencePatternDataGroupValueForDocumentItem(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
                let  getSentencePatternForDocumentItemResponse = neuronUtility!.getNeuronRequest(json: neuronResponse.neuronOperation.neuronData.text, object: GetGraphSentencePatternForDocumentItemResponse())
                udcSentencePatternDataGroupValue = getSentencePatternForDocumentItemResponse.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue

                
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
            }
        } else {
            udcSentencePatternDataGroupValue = getSentencePatternForDocumentItemRequest.udcSentencePatternDataGroupValue

            
        }
        if !getSentencePatternForDocumentItemRequest.uvcViewItemType.isEmpty && (udcSentencePatternDataGroupValue![0].uvcViewItemType != "UVCViewItemType.Photo" && udcSentencePatternDataGroupValue![0].uvcViewItemType != "UVCViewItemType.Button") {
            udcSentencePatternDataGroupValue![0].uvcViewItemType = getSentencePatternForDocumentItemRequest.uvcViewItemType
        }
        

        let getSentencePatternForDocumentItemResponse = GetGraphSentencePatternForDocumentItemResponse()
        getSentencePatternForDocumentItemResponse.udcSentencePattern.udcSentencePatternData.append(UDCSentencePatternData())
        getSentencePatternForDocumentItemResponse.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup.append(UDCSentencePatternDataGroup())
        getSentencePatternForDocumentItemResponse.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.append(contentsOf: udcSentencePatternDataGroupValue!)

        
        let jsonUtilityGetSentencePatternForDocumentItemResponse = JsonUtility<GetGraphSentencePatternForDocumentItemResponse>()
        let jsonGetSentencePatternForDocumentItemResponse = jsonUtilityGetSentencePatternForDocumentItemResponse.convertAnyObjectToJson(jsonObject: getSentencePatternForDocumentItemResponse)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonGetSentencePatternForDocumentItemResponse)
        
    }
    
    private func getSentencePatternDataGroupValueForDocumentItem(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let getGraphSentencePatternForDocumentItemRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: GetGraphSentencePatternForDocumentItemRequest())
        
        let getSentencePatternForDocumentItemResponse = GetGraphSentencePatternForDocumentItemResponse()
        getSentencePatternForDocumentItemResponse.udcSentencePattern.udcSentencePatternData.append(UDCSentencePatternData())
        getSentencePatternForDocumentItemResponse.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup.append(UDCSentencePatternDataGroup())

        let udcSentencePatternDataGroupValue = UDCSentencePatternDataGroupValue()
        udcSentencePatternDataGroupValue.itemType = "UDCJson.String"
        if getGraphSentencePatternForDocumentItemRequest.documentItemIdName == "UDCDocumentItem" || getGraphSentencePatternForDocumentItemRequest.documentItemObjectName == "UDCDocumentItemPhoto" || getGraphSentencePatternForDocumentItemRequest.documentItemObjectName.hasSuffix("WordDictionary") {
            // Document item detials
            let databaseOrmResult = UDCDocumentGraphModel.get(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, id: getGraphSentencePatternForDocumentItemRequest.documentItemIdName, language: getGraphSentencePatternForDocumentItemRequest.documentLanguage)
            if databaseOrmResult.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResult.databaseOrmError[0].name, description: databaseOrmResult.databaseOrmError[0].description))
                getSentencePatternForDocumentItemResponse.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.append(udcSentencePatternDataGroupValue)
                return
            }
            let udcDocumentItem = databaseOrmResult.object[0]
            let mapNodeSuffix = getGraphSentencePatternForDocumentItemRequest.documentItemObjectName.suffix(getGraphSentencePatternForDocumentItemRequest.documentItemObjectName.count - 3)
            if getGraphSentencePatternForDocumentItemRequest.documentItemObjectName == "UDCDocumentItemPhoto" {
                udcSentencePatternDataGroupValue.uvcViewItemType = "UVCViewItemType.Photo"
            } else {
                udcSentencePatternDataGroupValue.uvcViewItemType = "UVCViewItemType.Text"
            }
            udcSentencePatternDataGroupValue.endCategoryIdName = "UDCDocumentItemMapNode.\(mapNodeSuffix)"
            if udcDocumentItem.idName == "UDCDocumentItem.DocumentItemSeparator" {
                udcSentencePatternDataGroupValue.item = udcDocumentItem.name
            } else {
                let nameSplit = documentParser.splitDocumentItem(udcSentencePatternDataGroupValueParam: udcDocumentItem.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue, language: getGraphSentencePatternForDocumentItemRequest.documentLanguage)
                udcSentencePatternDataGroupValue.item = nameSplit[getGraphSentencePatternForDocumentItemRequest.documentItemNameIndex]
            }
            udcSentencePatternDataGroupValue.itemNameIndex = getGraphSentencePatternForDocumentItemRequest.documentItemNameIndex
            udcSentencePatternDataGroupValue.itemId = udcDocumentItem._id
            udcSentencePatternDataGroupValue.itemIdName = udcDocumentItem.idName
            udcSentencePatternDataGroupValue.itemState = ""
            udcSentencePatternDataGroupValue.category = "UDCGrammarCategory.CommonNoun"
            udcSentencePatternDataGroupValue.udcDocumentId = getGraphSentencePatternForDocumentItemRequest.documentIdName
            // Document item parent details
            udcSentencePatternDataGroupValue.endSubCategoryId = udcDocumentItem.parentId[0]
            let databaseOrmResultParent = UDCDocumentGraphModel.get(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentItem.parentId[0], language: getGraphSentencePatternForDocumentItemRequest.documentLanguage)
            if databaseOrmResultParent.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultParent.databaseOrmError[0].name, description: databaseOrmResultParent.databaseOrmError[0].description))
                getSentencePatternForDocumentItemResponse.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.append(udcSentencePatternDataGroupValue)
            }
            let udcDocumentItemParent = databaseOrmResultParent.object[0]
            udcSentencePatternDataGroupValue.endSubCategoryId = udcDocumentItem.parentId[0]
            udcSentencePatternDataGroupValue.endSubCategoryIdName = udcDocumentItemParent.idName
            // If parent is not title of document item
            if udcDocumentItemParent.parentId.count > 0 && udcDocumentItemParent.level > 0 {
                let databaseOrmResultParentsParent = UDCDocumentGraphModel.get(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentItemParent.parentId[0], language: getGraphSentencePatternForDocumentItemRequest.documentLanguage)
                if databaseOrmResultParentsParent.databaseOrmError.count > 0 {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultParentsParent.databaseOrmError[0].name, description: databaseOrmResultParentsParent.databaseOrmError[0].description))
                    getSentencePatternForDocumentItemResponse.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.append(udcSentencePatternDataGroupValue)
                    return
                }
                let udcDocumentItemParentsParent = databaseOrmResultParentsParent.object[0]
                udcSentencePatternDataGroupValue.endCategoryId = udcDocumentItemParentsParent._id
                udcSentencePatternDataGroupValue.endCategoryIdName = udcDocumentItemParentsParent.idName
            } else {
                udcSentencePatternDataGroupValue.endCategoryId = udcDocumentItemParent._id
                udcSentencePatternDataGroupValue.endCategoryIdName = udcDocumentItemParent.idName
                udcSentencePatternDataGroupValue.endSubCategoryId = ""
                udcSentencePatternDataGroupValue.endSubCategoryIdName = ""
            }
            
            if getGraphSentencePatternForDocumentItemRequest.udcDocumentTypeIdName != "UDCDocumentType.DocumentItem" &&  getGraphSentencePatternForDocumentItemRequest.udcDocumentTypeIdName == "UDCDocumentType.DocumentItemConfiguration" {
                let fieldUdcspdvArray = try documentItemConfigurationUtility.getDocumentItemConfiguration(name: "UDCDocumentItem.DocumentType", udcDocumentItem: udcDocumentItem, udcDocumentId: getGraphSentencePatternForDocumentItemRequest.documentIdName, neuronResponse: &neuronResponse, language: getGraphSentencePatternForDocumentItemRequest.documentLanguage, udcProfile: getGraphSentencePatternForDocumentItemRequest.udcProfile)
                if fieldUdcspdvArray != nil {
                    for udcspdgv in fieldUdcspdvArray! {
                        if udcspdgv.endCategoryIdName == "UDCDocumentItem.DocumentType" && udcspdgv.itemIdName == "UDCDocumentItem.Button" {
                            udcSentencePatternDataGroupValue.uvcViewItemType = "UVCViewItemType.Button"
                            break
                        }
                    }
                }
            }
            getSentencePatternForDocumentItemResponse.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.append(udcSentencePatternDataGroupValue)
            
           
        } else if getGraphSentencePatternForDocumentItemRequest.documentItemObjectName == "UDCDocument" {
            let databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: getGraphSentencePatternForDocumentItemRequest.documentItemIdName, language: getGraphSentencePatternForDocumentItemRequest.documentLanguage)
            if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocument.databaseOrmError[0].name, description: databaseOrmResultUDCDocument.databaseOrmError[0].description))
                return
            }
            let udcDocument = databaseOrmResultUDCDocument.object[0]
            udcSentencePatternDataGroupValue.uvcViewItemType = "UVCViewItemType.Text"
            udcSentencePatternDataGroupValue.endCategoryIdName = "UDCDocumentItem.Document"
            udcSentencePatternDataGroupValue.endCategoryId = udcDocument.udcDocumentTypeIdName
            udcSentencePatternDataGroupValue.item = udcDocument.name
            udcSentencePatternDataGroupValue.itemNameIndex = getGraphSentencePatternForDocumentItemRequest.documentItemNameIndex
            udcSentencePatternDataGroupValue.itemId = udcDocument._id
            udcSentencePatternDataGroupValue.udcDocumentId = getGraphSentencePatternForDocumentItemRequest.documentIdName
            udcSentencePatternDataGroupValue.itemIdName = udcDocument.idName
            udcSentencePatternDataGroupValue.itemState = ""
            udcSentencePatternDataGroupValue.category = "UDCGrammarCategory.CommonNoun"
            getSentencePatternForDocumentItemResponse.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.append(udcSentencePatternDataGroupValue)
        }

        let jsonUtilityGetSentencePatternForDocumentItemResponse = JsonUtility<GetGraphSentencePatternForDocumentItemResponse>()
               let jsonGetSentencePatternForDocumentItemResponse = jsonUtilityGetSentencePatternForDocumentItemResponse.convertAnyObjectToJson(jsonObject: getSentencePatternForDocumentItemResponse)
               neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonGetSentencePatternForDocumentItemResponse)
    }
    
    private func getDocumentGraphModelTypeChildrens(collectionName: String, childrenId: [String], typeRequest: GetDocumentItemOptionRequest, indexArray: inout [Int], neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) -> [UDCDocumentGraphModel]? {
        var udcDocumentGraphModelTypeArray = [UDCDocumentGraphModel]()
        let documentLanguage = typeRequest.documentLanguage
        
        for (idIndex, id) in childrenId.enumerated() {
            let datbaseOrmResultUDCDocumentGraphModelType = UDCDocumentGraphModel.get(collectionName: collectionName, udbcDatabaseOrm: udbcDatabaseOrm!, id: id)
            if datbaseOrmResultUDCDocumentGraphModelType.databaseOrmError.count > 0 {
                for databaseError in datbaseOrmResultUDCDocumentGraphModelType.databaseOrmError {
                    neuronResponse = neuronUtility!.getNeuronResponseError(neuronRequest: neuronRequest, errorName: databaseError.name, errorDescription:  databaseError.description)
                }
                return nil
            }
            let udcDocumentGraphModelType = datbaseOrmResultUDCDocumentGraphModelType.object[0]
            let nameSplit = udcDocumentGraphModelType.name.split(separator: "|")
            
            if !typeRequest.searchText.isEmpty {
                for name in nameSplit {
                    if String(name).replacingOccurrences(of: " ", with: "").lowercased().contains(typeRequest.searchText.lowercased()) {
                        udcDocumentGraphModelTypeArray.append(udcDocumentGraphModelType)
                        indexArray.append(idIndex)
                        
                    }
                }
            } else if !typeRequest.fromText.isEmpty {
                for name in nameSplit {
                    if String(name).replacingOccurrences(of: " ", with: "") >= typeRequest.fromText {
                        udcDocumentGraphModelTypeArray.append(udcDocumentGraphModelType)
                        indexArray.append(idIndex)
                        
                    }
                }
            } else {
                udcDocumentGraphModelTypeArray.append(udcDocumentGraphModelType)
                indexArray.append(idIndex)
                
            }
            
        }

        return udcDocumentGraphModelTypeArray
    }
    
     private func getDocumentItemOptions(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        print("\(DocumentItemNeuron.getName()): process")
        let typeRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: GetDocumentItemOptionRequest())
        let typeResponse = GetDocumentItemOptionResponse()
        var uvcOptionViewModel = [UVCOptionViewModel]()
        var uvcViewGenerator = UVCViewGenerator()
        
        let documentLanguage = typeRequest.documentLanguage

        var titleId = ""
        var titleName = ""
        var titleIdName = ""
        
        if typeRequest.type.hasPrefix("UDCDocumentItem") || typeRequest.type.hasSuffix("WordDictionary") {
            let databaseOrmResultUDCDocumentGraphModelTypeCategory = UDCDocumentGraphModel.get(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, id: typeRequest.category)
            if databaseOrmResultUDCDocumentGraphModelTypeCategory.databaseOrmError.count > 0 {
                for databaseError in databaseOrmResultUDCDocumentGraphModelTypeCategory.databaseOrmError {
                    neuronResponse = neuronUtility!.getNeuronResponseError(neuronRequest: neuronRequest, errorName: databaseError.name, errorDescription:  databaseError.description)
                }
            }
            if neuronUtility!.isNeuronOperationError(neuronResponse:  neuronResponse) {
                return
            }
            titleId = databaseOrmResultUDCDocumentGraphModelTypeCategory.object[0]._id
            titleName = databaseOrmResultUDCDocumentGraphModelTypeCategory.object[0].name
            titleIdName = databaseOrmResultUDCDocumentGraphModelTypeCategory.object[0].idName
        } else {
            if !typeRequest.type.hasPrefix("UDCDocument") {
                var databaseOrmUDCDocumentItemMapNode = UDCDocumentItemMapNode.get(objectName: typeRequest.type, udbcDatabaseOrm!, documentLanguage)
                if databaseOrmUDCDocumentItemMapNode.databaseOrmError.count > 0 {
                    for databaseError in databaseOrmUDCDocumentItemMapNode.databaseOrmError {
                        neuronResponse = neuronUtility!.getNeuronResponseError(neuronRequest: neuronRequest, errorName: databaseError.name, errorDescription:  databaseError.description)
                    }
                    return
                }
                var udcDocumentItemMapNode = databaseOrmUDCDocumentItemMapNode.object[0]
                titleId = udcDocumentItemMapNode._id
                titleName = udcDocumentItemMapNode.name
                titleIdName = udcDocumentItemMapNode.idName
            }
        }
        
        let parentOptionView = getOptionView(_id: titleId, name: titleName, category: "", model: "", level: 0, idName: titleIdName, parentView: nil, path: "", pathIdName: "", isCheckBox: false, photoId: nil, photoObjectName: nil)
        parentOptionView.idName = titleIdName
        uvcOptionViewModel.append(parentOptionView)
        let databaseOrmUDCDocumentItemMapNode = UDCDocumentItemMapNode.get("UDCDocumentItemMapNode.DocumentItemOption", udbcDatabaseOrm!, documentLanguage)
        if databaseOrmUDCDocumentItemMapNode.databaseOrmError.count > 0 {
            for databaseError in databaseOrmUDCDocumentItemMapNode.databaseOrmError {
                neuronResponse = neuronUtility!.getNeuronResponseError(neuronRequest: neuronRequest, errorName: databaseError.name, errorDescription:  databaseError.description)
            }
            return
        }
        var udcDocumentItemMapNode = databaseOrmUDCDocumentItemMapNode.object[0]

         if typeRequest.type == "UDCDocument" {
            var databaseOrmResultUDCDocument: DatabaseOrmResult<UDCDocument>?
            databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, udcProfile: typeRequest.udcProfile, udcDocumentTypeIdName: typeRequest.category, language: documentLanguage)
            if databaseOrmResultUDCDocument!.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocument!.databaseOrmError[0].name, description: databaseOrmResultUDCDocument!.databaseOrmError[0].description))
                return
            }
            for type in databaseOrmResultUDCDocument!.object {
                if type.name != "Blank" {
                    let ovm = getOptionView(_id: type._id, name: type.name, category: stringUtility.capitalCaseToArray(capitalCaseText: String(type.udcDocumentTypeIdName.split(separator: ".")[1])).joined(separator: " "), model: "", level: 1, idName: type._id, parentView: parentOptionView, path: udcDocumentItemMapNode.name, pathIdName: udcDocumentItemMapNode.idName, isCheckBox: false, photoId: nil, photoObjectName: nil)
                    ovm.objectName = "UDCDocument"
                    uvcOptionViewModel.append(ovm)
                }
            }
         } else if typeRequest.type.hasPrefix("UDCDocumentItem") || typeRequest.type.hasSuffix("WordDictionary") {
            let databaseOrmResultUDCDocumentGraphModelTypeCategory = UDCDocumentGraphModel.get(collectionName: "UDCDocumentItem",  udbcDatabaseOrm: udbcDatabaseOrm!, id: typeRequest.category)
            if databaseOrmResultUDCDocumentGraphModelTypeCategory.databaseOrmError.count > 0 {
                for databaseError in databaseOrmResultUDCDocumentGraphModelTypeCategory.databaseOrmError {
                    neuronResponse = neuronUtility!.getNeuronResponseError(neuronRequest: neuronRequest, errorName: databaseError.name, errorDescription:  databaseError.description)
                }
            }
            if neuronUtility!.isNeuronOperationError(neuronResponse:  neuronResponse) {
                return
            }
            let udcPhotoDocumentCategory = databaseOrmResultUDCDocumentGraphModelTypeCategory.object[0]
            let jsonUtility = JsonUtility<UDCDocumentGraphModel>()
            var typeArray = [UDCDocumentGraphModelType]()
            var indexArray = [Int]()
            let databaseOrmResultUDCCookingMethodType: DatabaseOrmResult<UDCDocumentGraphModel>?
            let udcPhotoDocumentArrray = getDocumentGraphModelTypeChildrens(collectionName: "UDCDocumentItem", childrenId: udcPhotoDocumentCategory.childrenId, typeRequest: typeRequest, indexArray: &indexArray, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            if neuronUtility!.isNeuronOperationError(neuronResponse:  neuronResponse) {
                return
            }
            for (typeIndex, type) in udcPhotoDocumentArrray!.enumerated() {
                let jsonUtilityType = JsonUtility<UDCDocumentGraphModel>()
                let typeModel = jsonUtilityType.convertAnyObjectToJson(jsonObject: type)
                var photoId: String?
                var photoObjectName: String?
                photoId = type.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].itemId
                if typeRequest.uvcViewItemType == "UVCViewItemType.Photo" {
                    photoObjectName = "UDCDocumentItemPhoto"
                } else {
                    if typeRequest.type.hasSuffix("WordDictionary") {
                        photoObjectName = typeRequest.type
                    } else {
                        photoObjectName = "UDCDocumentItem"
                    }
                }
                if (((photoId != nil) && !photoId!.isEmpty && typeRequest.uvcViewItemType == "UVCViewItemType.Photo") || (typeRequest.uvcViewItemType == "UVCViewItemType.Text" || typeRequest.uvcViewItemType == "UVCViewItemType.Button")) {
                    let nameSplit = documentParser.splitDocumentItem(udcSentencePatternDataGroupValueParam: type.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue, language: documentLanguage)
                    // type.name.split(separator: "|")
                    for (nameIndex, name) in nameSplit.enumerated() {
                        let ovm = getOptionView(_id: type._id, name: name, category: udcPhotoDocumentCategory.name, model: typeModel, level: 1, idName: udcPhotoDocumentCategory.childrenId[indexArray[typeIndex]], parentView: parentOptionView, path: udcDocumentItemMapNode.name, pathIdName: udcDocumentItemMapNode.idName, isCheckBox: false, photoId: type._id, photoObjectName: photoObjectName)
                        ovm.objectCategoryIdName = typeRequest.category
                        ovm.objectNameIndex = nameIndex
                        uvcOptionViewModel.append(ovm)
                    }
                }
            }
        }
        
        defer {
            typeResponse.uvcOptionViewModel.append(contentsOf: uvcOptionViewModel)
            let jsonUtilityTypeResponse = JsonUtility<GetDocumentItemOptionResponse>()
            let json = jsonUtilityTypeResponse.convertAnyObjectToJson(jsonObject: typeResponse)
            neuronResponse.neuronOperation.response = true
            neuronResponse.neuronOperation.neuronData.text = json
        }
     }
     
     private func getOptionView(_id: String, name: String, category: String, model: String, level: Int, idName: String, parentView: UVCOptionViewModel?, path: String, pathIdName: String, isCheckBox: Bool, photoId: String?, photoObjectName: String?) -> UVCOptionViewModel {
         let uvcOptionViewModelLocal = UVCOptionViewModel()
         let uvcViewGenerator = UVCViewGenerator()
         let uvcViewModel = uvcViewGenerator.getOptionViewModel(name: name, description: "", category: category, subCategory: "", language: "en", isChildrenExist: false, isEditable: false, isCheckBox: isCheckBox, photoId: photoId, photoObjectName: photoObjectName)
         uvcOptionViewModelLocal._id = _id
         uvcOptionViewModelLocal.idName = idName
         uvcOptionViewModelLocal.objectIdName = idName
         if photoObjectName != nil {
             uvcOptionViewModelLocal.objectName = photoObjectName!
         } else {
             uvcOptionViewModelLocal.objectName = idName.components(separatedBy: ".")[0]
         }
         uvcOptionViewModelLocal.uvcViewModel = uvcViewModel
         uvcOptionViewModelLocal.uvcViewModel.rowLength = 1
         uvcOptionViewModelLocal.level = level
         uvcOptionViewModelLocal.isMultiSelect = false
         if parentView != nil {
             uvcOptionViewModelLocal.parentId.append(uvcOptionViewModelLocal._id)
         }
         uvcOptionViewModelLocal.pathIdName.append([pathIdName])
         uvcOptionViewModelLocal.pathIdName[0].append(idName)
         return uvcOptionViewModelLocal
     }
    
    private func getDocumentIdName(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let getDocumentGraphIdNameRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: GetDocumentGraphIdNameRequest())
        
        let getDocumentGraphIdNameResponse = GetDocumentGraphIdNameResponse()
        
        var textLocationNotAtStart: Bool = false
        for udcspdgv in getDocumentGraphIdNameRequest.udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue {
            if udcspdgv.itemIdName == "UDCDocumentItem.TranslationSeparator" {
                textLocationNotAtStart = true
                break
            }
        }
        
        if getDocumentGraphIdNameRequest.udcDocumentGraphModel.level > 0 {
            var udcSentencePattern = UDCSentencePattern()
            var udcSentencePatternDataGroupValue = [UDCSentencePatternDataGroupValue]()
            for (udcspdgvIndex, udcspdgv) in getDocumentGraphIdNameRequest.udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.enumerated() {
                if udcspdgv.itemIdName == "UDCDocumentItem.TranslationSeparator" {
                    break
                }
                udcSentencePatternDataGroupValue.append(udcspdgv)
            }
            let udcGrammarUtility = UDCGrammarUtility()
            
            udcGrammarUtility.getSetencePattern(udcSentencePattern: &udcSentencePattern, udcSentencePatternDataGroupValue: udcSentencePatternDataGroupValue)
            udcSentencePattern = try processGrammar(neuronRequest: neuronRequest, neuronResponse: &neuronResponse, udcSentencePattern: udcSentencePattern, documentLanguage: getDocumentGraphIdNameRequest.documentLanguage, textStartIndex: -1)
            if getDocumentGraphIdNameRequest.udcDocumentGraphModel.level == 0 {
                getDocumentGraphIdNameResponse.idName = getDocumentGraphIdNameRequest.udcDocumentGraphModel.idName
            } else {
                getDocumentGraphIdNameResponse.idName = "\(neuronUtility!.getCollectionName(udcDocumentTypeIdName: getDocumentGraphIdNameRequest.udcDocumentTypeIdName)!).\(udcSentencePattern.sentence.capitalized.replacingOccurrences(of: " ", with: ""))"
            }
            // English text or title
            if getDocumentGraphIdNameRequest.documentLanguage == "en" || getDocumentGraphIdNameRequest.udcDocumentGraphModel.level <= 0 {
                getDocumentGraphIdNameResponse.name = udcSentencePattern.sentence
            } else {
                var udcSentencePatternDataGroupValue = [UDCSentencePatternDataGroupValue]()
                var startCapturingText: Bool = false
                for (udcspdgvIndex, udcspdgv) in getDocumentGraphIdNameRequest.udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.enumerated() {
                    if udcspdgv.itemIdName == "UDCDocumentItem.TranslationSeparator" {
                        startCapturingText = true
                        continue
                    }
                    if startCapturingText {
                        udcSentencePatternDataGroupValue.append(udcspdgv)
                    }
                }
                let udcGrammarUtility = UDCGrammarUtility()
                udcSentencePattern = UDCSentencePattern()
                udcGrammarUtility.getSetencePattern(udcSentencePattern: &udcSentencePattern, udcSentencePatternDataGroupValue: udcSentencePatternDataGroupValue)
                udcSentencePattern = try processGrammar(neuronRequest: neuronRequest, neuronResponse: &neuronResponse, udcSentencePattern: udcSentencePattern, documentLanguage: getDocumentGraphIdNameRequest.documentLanguage, textStartIndex: -1)
                getDocumentGraphIdNameResponse.name = udcSentencePattern.sentence
            }
        } else {
            let databaseOrmUDCDocumentItemMapNode = UDCDocumentItemMapNode.get("UDCDocumentItemMapNode.Untitled", udbcDatabaseOrm!, getDocumentGraphIdNameRequest.documentLanguage)
            if databaseOrmUDCDocumentItemMapNode.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentItemMapNode.databaseOrmError[0].name, description: databaseOrmUDCDocumentItemMapNode.databaseOrmError[0].description))
                return
            }
            let untitledItem = databaseOrmUDCDocumentItemMapNode.object[0]
            let name = "\(untitledItem.name)".capitalized
            let untitltedIdNamePrefix = "\(neuronUtility!.getCollectionName(udcDocumentTypeIdName: getDocumentGraphIdNameRequest.udcDocumentTypeIdName)!).\(name)"
            
            getDocumentGraphIdNameResponse.name = getDocumentGraphIdNameRequest.udcDocumentGraphModel.udcSentencePattern.sentence
            if getDocumentGraphIdNameRequest.udcDocumentGraphModel.level == 0 {
                
                if !getDocumentGraphIdNameRequest.udcDocumentGraphModel.idName.contains(untitltedIdNamePrefix) && getDocumentGraphIdNameRequest.udcDocumentGraphModel.language != "en" {
                    getDocumentGraphIdNameResponse.idName = getDocumentGraphIdNameRequest.udcDocumentGraphModel.idName
                    getDocumentGraphIdNameResponse.name = getDocumentGraphIdNameRequest.udcDocumentGraphModel.name
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
            
        }
        if getDocumentGraphIdNameResponse.idName == "\(neuronUtility!.getCollectionName(udcDocumentTypeIdName: getDocumentGraphIdNameRequest.udcDocumentTypeIdName)!)." {
            getDocumentGraphIdNameResponse.idName = "\(neuronUtility!.getCollectionName(udcDocumentTypeIdName: getDocumentGraphIdNameRequest.udcDocumentTypeIdName)!).\(NSUUID().uuidString)"
        }
        
        
        let jsonUtilityGetDocumentGraphIdNameResponse = JsonUtility<GetDocumentGraphIdNameResponse>()
        let jsonValidateGetDocumentGraphIdNameResponse = jsonUtilityGetDocumentGraphIdNameResponse.convertAnyObjectToJson(jsonObject: getDocumentGraphIdNameResponse)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonValidateGetDocumentGraphIdNameResponse)
        
    }
    
    private func generateDocumentView(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let generateDocumentGraphViewRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: GenerateDocumentGraphViewRequest())
        
        var documentLanguage = generateDocumentGraphViewRequest.getDocumentGraphViewRequest.documentLanguage
        
        let generateDocumentGraphViewResponse = GenerateDocumentGraphViewResponse()
        
        let databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.documentId)
        if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocument.databaseOrmError[0].name, description: databaseOrmResultUDCDocument.databaseOrmError[0].description))
            return
        }
        let udcDocument = databaseOrmResultUDCDocument.object[0]
        
        var databaseOrmUDCDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocument.udcDocumentGraphModelId) as DatabaseOrmResult<UDCDocumentGraphModel>
        if databaseOrmUDCDocumentGraphModel.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentGraphModel.databaseOrmError[0].name, description: databaseOrmUDCDocumentGraphModel.databaseOrmError[0].description))
            return
        }
        let udcDocumentGraphModel = databaseOrmUDCDocumentGraphModel.object[0]
        
        if generateDocumentGraphViewRequest.getDocumentGraphViewRequest.isToGetDuplicate {
            var profileId = ""
            for udcp in generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcProfile {
                if udcp.udcProfileItemIdName == "UDCProfileItem.Human" {
                    profileId = udcp.profileId
                }
            }
            // Save the english title
            udcDocumentGraphModel._id = try (udbcDatabaseOrm?.generateId())!
            udcDocumentGraphModel.language = generateDocumentGraphViewRequest.getDocumentGraphViewRequest.duplicateToDocumentLanguage
            udcDocumentGraphModel.udcDocumentTime.createdBy = profileId
            udcDocumentGraphModel.udcDocumentTime.creationTime = Date()
            var databaseOrmUDCDocumentGraphModelSave = UDCDocumentGraphModel.save(collectionName:  neuronUtility!.getCollectionName(udcDocumentTypeIdName: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentGraphModel)
            if databaseOrmUDCDocumentGraphModelSave.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentGraphModelSave.databaseOrmError[0].name, description: databaseOrmUDCDocumentGraphModelSave.databaseOrmError[0].description))
                return
            }
            udcDocument.udcDocumentTime.createdBy = profileId
            udcDocument.udcDocumentTime.creationTime = Date()
            udcDocument.udcDocumentHistory.removeAll()
            udcDocument.udcDocumentHistory.append(UDCDcumentHistory())
            udcDocument.udcDocumentHistory[0]._id = try (udbcDatabaseOrm?.generateId())!
            udcDocument.udcDocumentHistory[0].humanProfileId = profileId
            udcDocument.udcDocumentHistory[0].time = udcDocument.udcDocumentTime.creationTime
            udcDocument.udcDocumentHistory[0].reason = "Initial Version"
            udcDocument.udcDocumentHistory[0].version = udcDocument.modelVersion
            let udcDocumentAccessProfile = UDCDocumentAccessProfile()
            udcDocumentAccessProfile.profileId = profileId
            udcDocumentAccessProfile.udcProfileItemIdName = "UDCProfileItem.Human"
            udcDocumentAccessProfile.udcDocumentAccessType.append("UDCDocumentAccessType.Read")
            udcDocument.udcDocumentAccessProfile.removeAll()
            udcDocument.udcDocumentAccessProfile.append(udcDocumentAccessProfile)
            udcDocument._id = try (udbcDatabaseOrm?.generateId())!
            udcDocument.language = generateDocumentGraphViewRequest.getDocumentGraphViewRequest.duplicateToDocumentLanguage
            udcDocument.udcDocumentGraphModelId = udcDocumentGraphModel._id
            
            // Get the translation separator
            let databaseOrmResultUDCPhotoDocument = UDCDocumentGraphModel.get(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, idName: "UDCDocumentItem.TranslationSeparator", language: "en")
            if databaseOrmResultUDCPhotoDocument.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCPhotoDocument.databaseOrmError[0].name, description: databaseOrmResultUDCPhotoDocument.databaseOrmError[0].description))
                return
            }
            let udcPhotoDocument = databaseOrmResultUDCPhotoDocument.object[0]
            
            let databaseOrmResultUDCPhotoDocumentParent = UDCDocumentGraphModel.get(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, id: udcPhotoDocument.parentId[0])
            if databaseOrmResultUDCPhotoDocumentParent.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCPhotoDocumentParent.databaseOrmError[0].name, description: databaseOrmResultUDCPhotoDocumentParent.databaseOrmError[0].description))
                return
            }
            let udcPhotoDocumentParent = databaseOrmResultUDCPhotoDocumentParent.object[0]
            var newChildrenId = [String]()
            var levelChildrenId = [String: [String]]()
            try duplicateDocumentViewModel(parentId: udcDocumentGraphModel._id, childrenId: udcDocumentGraphModel.childrenId, newChildrenId: &newChildrenId, levelChildrenId: &levelChildrenId, generateDocumentGraphViewRequest: generateDocumentGraphViewRequest, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, profileId: profileId, documentLanguage: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.documentLanguage, translationSeparatorDocumentItem: udcPhotoDocument, translationSeparatorDocumentItemParent: udcPhotoDocumentParent)
            
            let databaseOrmUDCDocumentItemMapNode = UDCDocumentItemMapNode.get("UDCDocumentItemMapNode.Untitled", udbcDatabaseOrm!, generateDocumentGraphViewRequest.getDocumentGraphViewRequest.duplicateToDocumentLanguage)
            if databaseOrmUDCDocumentItemMapNode.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentItemMapNode.databaseOrmError[0].name, description: databaseOrmUDCDocumentItemMapNode.databaseOrmError[0].description))
                return
            }
            let untitledItem = databaseOrmUDCDocumentItemMapNode.object
            
            let name = "\(untitledItem[0].name)-\(NSUUID().uuidString)"
            
            if newChildrenId.count > 0 {
                udcDocumentGraphModel.childrenId.removeAll()
                udcDocumentGraphModel.childrenId.append(contentsOf: newChildrenId)
            }
            
            // Title with new name
            databaseOrmUDCDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentGraphModel.childrenId[0], language: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.duplicateToDocumentLanguage) as DatabaseOrmResult<UDCDocumentGraphModel>
            if databaseOrmUDCDocumentGraphModel.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentGraphModel.databaseOrmError[0].name, description: databaseOrmUDCDocumentGraphModel.databaseOrmError[0].description))
                return
            }
            let udcDocumentGraphModelLanguageTitle = databaseOrmUDCDocumentGraphModel.object[0]
            udcDocumentGraphModelLanguageTitle.name = name
            var count = udcDocumentGraphModelLanguageTitle.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.count
            if count > 1 {
                for index in 1...count-1 {
                    if index > 1 {
                        udcDocumentGraphModelLanguageTitle.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.remove(at: 2)
                    }
                }
            }
            udcDocumentGraphModelLanguageTitle.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].item = name
            udcDocumentGraphModelLanguageTitle.udcSentencePattern.sentence = name
            databaseOrmUDCDocumentGraphModelSave = UDCDocumentGraphModel.update(collectionName:  neuronUtility!.getCollectionName(udcDocumentTypeIdName: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentGraphModelLanguageTitle)
            if databaseOrmUDCDocumentGraphModelSave.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentGraphModelSave.databaseOrmError[0].name, description: databaseOrmUDCDocumentGraphModelSave.databaseOrmError[0].description))
                return
            }
            
            // Update with new childs
            databaseOrmUDCDocumentGraphModelSave = UDCDocumentGraphModel.update(collectionName:  neuronUtility!.getCollectionName(udcDocumentTypeIdName: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentGraphModel)
            if databaseOrmUDCDocumentGraphModelSave.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentGraphModelSave.databaseOrmError[0].name, description: databaseOrmUDCDocumentGraphModelSave.databaseOrmError[0].description))
                return
            }
            
            // Save the document
            udcDocument.name = name
            let databaseOrmUDCDocumentSave = UDCDocument.save(udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocument)
            if databaseOrmUDCDocumentSave.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentSave.databaseOrmError[0].name, description: databaseOrmUDCDocumentSave.databaseOrmError[0].description))
                return
            }
            documentLanguage = generateDocumentGraphViewRequest.getDocumentGraphViewRequest.duplicateToDocumentLanguage
            generateDocumentGraphViewResponse.name = udcDocument.name
        }
        generateDocumentGraphViewResponse.documentId = udcDocument._id
        
        //        let uvcViewModelArray = generateSentenceViewAsArray(udcDocumentGraphModel: udcDocumentGraphModel, uvcViewItemCollection: UVCViewItemCollection(), neuronRequest: neuronRequest, neuronResponse: &neuronResponse, newView: true, isEditable: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.editMode, level: udcDocumentGraphModel.level, viewPathIdName: [], documentLanguage: documentLanguage, documentModelId: udcDocument.udcDocumentGraphModelId, udcProfile: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcProfile,udcDocumentTypeIdName: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcDocumentTypeIdName)
        //        for (udcspgvIndex, udcspgv) in udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.enumerated() {
        //            uvcViewModelArray[udcspgvIndex].udcViewItemId = udcspgv.udcViewItemId
        //            uvcViewModelArray[udcspgvIndex].udcViewItemName = udcspgv.udcViewItemName
        //        }
        //        uvcDocumentGraphModel._id = udcDocumentGraphModel._id
        //        uvcDocumentGraphModel.uvcViewModel.append(contentsOf: uvcViewModelArray)
        //        uvcDocumentGraphModel.level = udcDocumentGraphModel.level
        //        if udcDocumentGraphModel.childrenId.count > 0 {
        //            uvcDocumentGraphModel.childrenId.append(contentsOf: udcDocumentGraphModel.childrenId)
        //        }
        //        uvcDocumentGraphModel.isChildrenAllowed = udcDocumentGraphModel.isChildrenAllowed
        //        let uvcDocumentGraphModel = UVCDocumentGraphModel()
        //        generateDocumentGraphViewResponse.documentTitle = udcDocumentGraphModel.udcSentencePattern.sentence
        //        var nodeIndex: Int = 0
        //        var documentItemViewInsertData = DocumentGraphItemViewData()
        //
        //        documentItemViewInsertData.uvcDocumentGraphModel._id = uvcDocumentGraphModel._id
        //        documentItemViewInsertData.uvcDocumentGraphModel.isChildrenAllowed = uvcDocumentGraphModel.isChildrenAllowed
        //        documentItemViewInsertData.uvcDocumentGraphModel.level = uvcDocumentGraphModel.level
        //        documentItemViewInsertData.uvcDocumentGraphModel.uvcViewModel.append(contentsOf: uvcDocumentGraphModel.uvcViewModel)
        //
        //        documentItemViewInsertData.treeLevel = uvcDocumentGraphModel.level
        //        documentItemViewInsertData.nodeIndex = nodeIndex
        //        documentItemViewInsertData.itemIndex = 0
        //        documentItemViewInsertData.sentenceIndex = 0
        
        //        generateDocumentGraphViewResponse.documentItemViewInsertData.append(documentItemViewInsertData)
        //        generateDocumentGraphViewResponse.currentNodeIndex = 0
        //        generateDocumentGraphViewResponse.currentItemIndex = 1
        //        generateDocumentGraphViewResponse.currentItemIndex = 0 generateDocumentGraphViewResponse.documentItemViewInsertData[0].uvcDocumentGraphModel.uvcViewModel.count
        //        generateDocumentGraphViewResponse.currentLevel = 0
        //        generateDocumentGraphViewResponse.currentSentenceIndex = 0
        
        var uvcDocumentGraphModelArray = [UVCDocumentGraphModel]()
        
        var nodeIndex: Int = 0
        var documentItemViewInsertData = DocumentGraphItemViewData()
        
        try getDocumentViewModel(childrenId: udcDocumentGraphModel.childrenId, uvcDocumentGraphModelArray: &uvcDocumentGraphModelArray, generateDocumentGraphViewRequest: generateDocumentGraphViewRequest, nodeIndex: &nodeIndex, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, documentLanguage: documentLanguage)
        
        if generateDocumentGraphViewRequest.getDocumentGraphViewRequest.editMode {
            let databaseOrmUDCDocumentItemMapNode = UDCDocumentItemMapNode.get("UDCDocumentItemMapNode.SearchDocumentItems", udbcDatabaseOrm!, documentLanguage)
            if databaseOrmUDCDocumentItemMapNode.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentItemMapNode.databaseOrmError[0].name, description: databaseOrmUDCDocumentItemMapNode.databaseOrmError[0].description))
                return
            }
            let searchDocumentItem = databaseOrmUDCDocumentItemMapNode.object
            let uvcm = uvcViewGenerator.getSearchBoxViewModel(name: searchDocumentItem[0].idName, value: "", level: 1, pictureName: "Elipsis", helpText: searchDocumentItem[0].name, parentId: [], childrenId: [], language: documentLanguage)
            uvcm.textLength = 25
            uvcDocumentGraphModelArray[0].uvcViewModel.append(uvcm)
        }
        
        for uvcdgm in uvcDocumentGraphModelArray {
            documentItemViewInsertData = DocumentGraphItemViewData()
            documentItemViewInsertData.uvcDocumentGraphModel._id = uvcdgm._id
            documentItemViewInsertData.uvcDocumentGraphModel.isChildrenAllowed = uvcdgm.isChildrenAllowed
            documentItemViewInsertData.uvcDocumentGraphModel.level = uvcdgm.level
            documentItemViewInsertData.uvcDocumentGraphModel.uvcViewModel.append(contentsOf: uvcdgm.uvcViewModel)
            if uvcdgm.parentId.count > 0 {
                documentItemViewInsertData.uvcDocumentGraphModel.parentId.append(contentsOf: uvcdgm.parentId)
            }
            if uvcdgm.childrenId.count > 0 {
                documentItemViewInsertData.uvcDocumentGraphModel.childrenId.append(contentsOf: uvcdgm.childrenId)
            }
            documentItemViewInsertData.treeLevel = uvcdgm.level
            documentItemViewInsertData.nodeIndex = nodeIndex
            documentItemViewInsertData.itemIndex = 0
            documentItemViewInsertData.sentenceIndex = 0
            
            generateDocumentGraphViewResponse.documentItemViewInsertData.append(documentItemViewInsertData)
            nodeIndex += 1
            
        }
        
        
        generateDocumentGraphViewResponse.documentTitle = udcDocumentGraphModel.udcSentencePattern.sentence
        generateDocumentGraphViewResponse.currentNodeIndex = 0
        generateDocumentGraphViewResponse.currentItemIndex = generateDocumentGraphViewResponse.documentItemViewInsertData[0].uvcDocumentGraphModel.uvcViewModel.count
        generateDocumentGraphViewResponse.currentLevel = 0
        generateDocumentGraphViewResponse.currentSentenceIndex = 0
        
        let jsonUtilityGenerateDocumentGraphViewResponse = JsonUtility<GenerateDocumentGraphViewResponse>()
        let jsonValidateGenerateDocumentGraphViewResponse = jsonUtilityGenerateDocumentGraphViewResponse.convertAnyObjectToJson(jsonObject: generateDocumentGraphViewResponse)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonValidateGenerateDocumentGraphViewResponse)
    }
    
    
    private func duplicateDocumentViewModel(parentId: String, childrenId: [String], newChildrenId: inout [String],  levelChildrenId: inout [String: [String]], generateDocumentGraphViewRequest: GenerateDocumentGraphViewRequest, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest, profileId: String, documentLanguage: String, translationSeparatorDocumentItem: UDCDocumentGraphModel, translationSeparatorDocumentItemParent: UDCDocumentGraphModel) throws {
        for id in childrenId {
            let databaseOrmUDCDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: id, language: documentLanguage) as DatabaseOrmResult<UDCDocumentGraphModel>
            if databaseOrmUDCDocumentGraphModel.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentGraphModel.databaseOrmError[0].name, description: databaseOrmUDCDocumentGraphModel.databaseOrmError[0].description))
                return
            }
            let udcDocumentGraphModel = databaseOrmUDCDocumentGraphModel.object[0]
            udcDocumentGraphModel._id = try (udbcDatabaseOrm?.generateId())!
            if udcDocumentGraphModel.level == 1 {
                newChildrenId.append(udcDocumentGraphModel._id)
                print("Duplicate: Adding: \(parentId)-> level \(udcDocumentGraphModel._id) id: \(id)")
            }
            if levelChildrenId[parentId] == nil {
                levelChildrenId[parentId] = [String]()
            }
            levelChildrenId[parentId]?.append(udcDocumentGraphModel._id)
            udcDocumentGraphModel.language = generateDocumentGraphViewRequest.getDocumentGraphViewRequest.duplicateToDocumentLanguage
            udcDocumentGraphModel.udcDocumentTime.createdBy = profileId
            udcDocumentGraphModel.udcDocumentTime.creationTime = Date()
            udcDocumentGraphModel.parentId.removeAll()
            udcDocumentGraphModel.parentId.append(parentId)
            if udcDocumentGraphModel.level > 1 && udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.count > 0 {
                let udcSentencePatternGroupValue = UDCSentencePatternDataGroupValue()
                udcSentencePatternGroupValue.uvcViewItemType = "UVCViewItemType.Photo"
                udcSentencePatternGroupValue.endCategoryId = translationSeparatorDocumentItemParent._id
                udcSentencePatternGroupValue.endCategoryIdName = translationSeparatorDocumentItemParent.idName
                udcSentencePatternGroupValue.itemIdName = translationSeparatorDocumentItem.idName
                udcSentencePatternGroupValue.itemId = translationSeparatorDocumentItem.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].itemId
                let udcPhoto = UDCPhoto()
                udcPhoto._id = try udbcDatabaseOrm!.generateId()
                udcSentencePatternGroupValue.udcViewItemId = udcPhoto._id
                udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.append(udcSentencePatternGroupValue)
                var uvcMeasurement = UVCMeasurement()
                uvcMeasurement.type = UVCMeasurementType.Width.name
                uvcMeasurement.value = 25
                udcPhoto.uvcMeasurement.append(uvcMeasurement)
                uvcMeasurement = UVCMeasurement()
                uvcMeasurement.type = UVCMeasurementType.Height.name
                uvcMeasurement.value = 25
                udcPhoto.uvcMeasurement.append(uvcMeasurement)
                udcDocumentGraphModel.udcViewItemCollection.udcPhoto.append(udcPhoto)
            }
            if udcDocumentGraphModel.childrenId.count > 0 {
                try duplicateDocumentViewModel(parentId: udcDocumentGraphModel._id, childrenId: udcDocumentGraphModel.childrenId, newChildrenId: &newChildrenId, levelChildrenId: &levelChildrenId, generateDocumentGraphViewRequest: generateDocumentGraphViewRequest, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, profileId: profileId, documentLanguage: documentLanguage, translationSeparatorDocumentItem: translationSeparatorDocumentItem, translationSeparatorDocumentItemParent: translationSeparatorDocumentItemParent)
                udcDocumentGraphModel.childrenId.removeAll()
                for id in  levelChildrenId {
                    print("Duplicate: Adding:\(parentId)->  level \(udcDocumentGraphModel.level) id: \(id)")
                }
                udcDocumentGraphModel.childrenId.append(contentsOf: levelChildrenId[udcDocumentGraphModel._id]!)
            }
            let databaseOrmUDCDocumentGraphModelSave = UDCDocumentGraphModel.save(collectionName:  neuronUtility!.getCollectionName(udcDocumentTypeIdName: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentGraphModel)
            if databaseOrmUDCDocumentGraphModelSave.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentGraphModelSave.databaseOrmError[0].name, description: databaseOrmUDCDocumentGraphModelSave.databaseOrmError[0].description))
                return
            }
        }
    }
    
    private func getDocumentViewModel(childrenId: [String], uvcDocumentGraphModelArray: inout [UVCDocumentGraphModel], generateDocumentGraphViewRequest: GenerateDocumentGraphViewRequest, nodeIndex: inout Int, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest, documentLanguage: String) throws {
        for id in childrenId {
            nodeIndex += 1
            let databaseOrmUDCDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: id, language: documentLanguage) as DatabaseOrmResult<UDCDocumentGraphModel>
            if databaseOrmUDCDocumentGraphModel.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentGraphModel.databaseOrmError[0].name, description: databaseOrmUDCDocumentGraphModel.databaseOrmError[0].description))
                return
            }
            let udcDocumentGraphModel = databaseOrmUDCDocumentGraphModel.object[0]
            
            let databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.documentId)
            if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocument.databaseOrmError[0].name, description: databaseOrmResultUDCDocument.databaseOrmError[0].description))
                return
            }
            let udcDocument = databaseOrmResultUDCDocument.object[0]
            let uvcViewModelArray = generateSentenceViewAsArray(udcDocumentGraphModel: udcDocumentGraphModel, uvcViewItemCollection: UVCViewItemCollection(), neuronRequest: neuronRequest, neuronResponse: &neuronResponse, newView: false, isEditable: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.editMode, level: udcDocumentGraphModel.level, viewPathIdName: [], documentLanguage: documentLanguage, documentModelId: udcDocument.udcDocumentGraphModelId, udcProfile: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcProfile,udcDocumentTypeIdName: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcDocumentTypeIdName)
            for (udcspgvIndex, udcspgv) in udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.enumerated() {
                uvcViewModelArray[udcspgvIndex].udcViewItemId = udcspgv.udcViewItemId
                uvcViewModelArray[udcspgvIndex].udcViewItemName = udcspgv.udcViewItemName
            }
            let uvcDocumentGraphModel = UVCDocumentGraphModel()
            uvcDocumentGraphModel._id = udcDocumentGraphModel._id
            uvcDocumentGraphModel.uvcViewModel.append(contentsOf: uvcViewModelArray)
            uvcDocumentGraphModel.isChildrenAllowed = udcDocumentGraphModel.isChildrenAllowed
            uvcDocumentGraphModel.level = udcDocumentGraphModel.level
            if udcDocumentGraphModel.parentId.count > 0 {
                uvcDocumentGraphModel.parentId.append(contentsOf: udcDocumentGraphModel.parentId)
            }
            if udcDocumentGraphModel.childrenId.count > 0 {
                uvcDocumentGraphModel.childrenId.append(contentsOf: udcDocumentGraphModel.childrenId)
            }
            uvcDocumentGraphModelArray.append(uvcDocumentGraphModel)
            
            if udcDocumentGraphModel.childrenId.count > 0 {
                try getDocumentViewModel(childrenId: udcDocumentGraphModel.childrenId, uvcDocumentGraphModelArray: &uvcDocumentGraphModelArray, generateDocumentGraphViewRequest: generateDocumentGraphViewRequest, nodeIndex: &nodeIndex, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, documentLanguage: documentLanguage)
            }
        }
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
        
        if (validateDocumentGraphItemForDeleteLineRequest.documentGraphDeleteLineRequest.documentLanguage != "en" && textLocationNotAtStart) || !validateDocumentGraphItemForDeleteLineRequest.deleteDocumentModel.udcDocumentGraphModelReferenceId.isEmpty {
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
        
        //        if validateDocumentGraphItemForDeleteRequest.documentGraphDeleteItemRequest.nodeIndex == 0 {
        //           validateDocumentGraphItemForDeleteRequest.deleteDocumentModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.remove(at: validateDocumentGraphItemForDeleteRequest.documentGraphDeleteItemRequest.itemIndex)
        //           let udcGrammarUtility = UDCGrammarUtility()
        //           var udcSentencePattern = UDCSentencePattern()
        //           udcGrammarUtility.getSetencePattern(udcSentencePattern: &udcSentencePattern, udcSentencePatternDataGroupValue: validateDocumentGraphItemForDeleteRequest.deleteDocumentModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue)
        //    udcSentencePattern = try processGrammar(neuronRequest: neuronRequest, neuronResponse: &neuronResponse, udcSentencePattern: udcSentencePattern, documentLanguage: validateDocumentGraphItemForDeleteRequest.documentGraphDeleteItemRequest.documentLanguage, textStartIndex: -1)
        //           let uniqueTitle = "\(udcSentencePattern.sentence)"
        //          let possibleIdName = "UDCDocument.\(uniqueTitle.capitalized.trimmingCharacters(in: .whitespaces))"
        //           let databaseOrmResultUDCDocumentCheck = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, udcProfile: validateDocumentGraphItemForDeleteRequest.documentGraphDeleteItemRequest.udcProfile, idName: possibleIdName, udcDocumentTypeIdName: validateDocumentGraphItemForDeleteRequest.udcDocumentTypeIdName, notEqualsDocumentGroupId: validateDocumentGraphItemForDeleteRequest.udcDocument!.documentGroupId)
        //          if databaseOrmResultUDCDocumentCheck.databaseOrmError.count == 0 {
        //              neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "SameDocumentNameAlreadyExists", description: "Same document name already exists"))
        //              return
        //          }
        //       }
        
        var photoCount = 0
        var translationSeparatorIndex = 0
        for (udcspdgvIndex, udcspdgv) in validateDocumentGraphItemForDeleteRequest.deleteDocumentModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.enumerated() {
            if udcspdgv.uvcViewItemType == "UVCViewItemType.Photo" {
                photoCount += 1
            }
            if photoCount == 2 {
                //                if validateDocumentGraphItemForDeleteRequest.deleteDocumentModel.isChildrenAllowed {
                //                    translationSeparatorIndex = udcspdgvIndex + 1
                //                } else {
                translationSeparatorIndex = udcspdgvIndex
                //                }
                break
            }
        }
        // Parent: Count 4: collapose/expand arrow, photo, information, translation separator
        // Parent: Count 3: photo, information, translation separator
        let textLocationNotAtStart = photoCount == 2
        
        if (validateDocumentGraphItemForDeleteRequest.documentGraphDeleteItemRequest.itemIndex <= translationSeparatorIndex && validateDocumentGraphItemForDeleteRequest.documentGraphDeleteItemRequest.documentLanguage != "en" && textLocationNotAtStart) || !validateDocumentGraphItemForDeleteRequest.deleteDocumentModel.udcDocumentGraphModelReferenceId.isEmpty && validateDocumentGraphItemForDeleteRequest.deleteDocumentModel.level > 1 {
            validateDocumentGraphItemForDeleteResponse.result = false
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "CannotDeleteThisItem", description: "Cannot Delete this item!"))
            return
        }
        
        let jsonUtilityValidateDocumentGraphItemForDeleteResponse = JsonUtility<ValidateDocumentGraphItemForDeleteResponse>()
        let jsonValidateDocumentGraphItemForDeleteResponse = jsonUtilityValidateDocumentGraphItemForDeleteResponse.convertAnyObjectToJson(jsonObject: validateDocumentGraphItemForDeleteResponse)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonValidateDocumentGraphItemForDeleteResponse)
    }
    
    private func validateInsertRequest(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let validateDocumentGraphItemForInsertRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: ValidateDocumentGraphItemForInsertRequest())
        
        let documentLanguage = validateDocumentGraphItemForInsertRequest.documentGraphInsertItemRequest.documentLanguage
        
        //        var udcSentencePatternGroupValue = try getSentencePatternDataGroupValue(optionItemObjectName: validateDocumentGraphItemForInsertRequest.documentGraphInsertItemRequest.optionItemObjectName, optionItemIdName: validateDocumentGraphItemForInsertRequest.documentGraphInsertItemRequest.optionItemId, neuronResponse: &neuronResponse, language: documentLanguage)
        //        if udcSentencePatternGroupValue.count == 0 {
        //           if validateDocumentGraphItemForInsertRequest.documentGraphInsertItemRequest.optionItemId == "UDCSentencePattern.Text" {
        let udcSentencePatternDataGroupValueLocal = UDCSentencePatternDataGroupValue()
        udcSentencePatternDataGroupValueLocal.item = validateDocumentGraphItemForInsertRequest.documentGraphInsertItemRequest.item
        udcSentencePatternDataGroupValueLocal.itemId = ""
        udcSentencePatternDataGroupValueLocal.category = "UDCGrammarCategory.CommonNoun"
        udcSentencePatternDataGroupValueLocal.endCategoryIdName = "UDCDocumentItem.General"
        udcSentencePatternDataGroupValueLocal.uvcViewItemType = "UVCViewItemType.Text"
        var udcSentencePatternGroupValue = [UDCSentencePatternDataGroupValue]()
        udcSentencePatternGroupValue.append(udcSentencePatternDataGroupValueLocal)
        //           }
        //        }
        validateDocumentGraphItemForInsertRequest.insertDocumentModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.insert(udcSentencePatternGroupValue[0], at: validateDocumentGraphItemForInsertRequest.documentGraphInsertItemRequest.itemIndex)
        let udcGrammarUtility = UDCGrammarUtility()
        var udcSentencePattern = UDCSentencePattern()
        udcGrammarUtility.getSetencePattern(udcSentencePattern: &udcSentencePattern, udcSentencePatternDataGroupValue: validateDocumentGraphItemForInsertRequest.insertDocumentModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue)
        udcSentencePattern = try processGrammar(neuronRequest: neuronRequest, neuronResponse: &neuronResponse, udcSentencePattern: udcSentencePattern, documentLanguage: documentLanguage, textStartIndex: -1)
        
        if validateDocumentGraphItemForInsertRequest.documentGraphInsertItemRequest.nodeIndex == 0 {
            
            let uniqueTitle = "\(udcSentencePattern.sentence)"
            let possibleIdName = "UDCDocument.\(uniqueTitle.capitalized.trimmingCharacters(in: .whitespaces))"
            
            let databaseOrmResultUDCDocumentCheck = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, udcProfile: validateDocumentGraphItemForInsertRequest.documentGraphInsertItemRequest.udcProfile, idName: possibleIdName, udcDocumentTypeIdName: validateDocumentGraphItemForInsertRequest.udcDocumentTypeIdName, notEqualsDocumentGroupId: validateDocumentGraphItemForInsertRequest.udcDocument!.documentGroupId)
            if databaseOrmResultUDCDocumentCheck.databaseOrmError.count == 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "SameDocumentNameAlreadyExists", description: "Same document name already exists"))
                return
            }
        }
        
        var photoCount = 0
        var translationSeparatorIndex = 0
        for (udcspdgvIndex, udcspdgv) in validateDocumentGraphItemForInsertRequest.insertDocumentModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.enumerated() {
            if udcspdgv.uvcViewItemType == "UVCViewItemType.Photo" {
                photoCount += 1
            }
            if photoCount == 2 {
                translationSeparatorIndex = udcspdgvIndex
                break
            }
        }
        // Parent: Count 4: collapose/expand arrow, photo, information, translation separator
        // Parent: Count 3: photo, information, translation separator
        let textLocationNotAtStart = (validateDocumentGraphItemForInsertRequest.insertDocumentModel.isChildrenAllowed && photoCount == 3) || (!validateDocumentGraphItemForInsertRequest.insertDocumentModel.isChildrenAllowed && photoCount == 2)
        
        let validateDocumentGraphItemForInsertResponse = ValidateDocumentGraphItemForInsertResponse()
        validateDocumentGraphItemForInsertResponse.result = true
        if validateDocumentGraphItemForInsertRequest.documentGraphInsertItemRequest.itemIndex <= translationSeparatorIndex && validateDocumentGraphItemForInsertRequest.documentGraphInsertItemRequest.documentLanguage != "en" && textLocationNotAtStart {
            validateDocumentGraphItemForInsertResponse.result = false
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "CannotInsertHere", description: "Cannot Insert here!"))
            return
        }
        
        if validateDocumentGraphItemForInsertRequest.insertDocumentModel.parentId.count > 0 {
            let databaseOrmResultudcDocumentGraphModelParent = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: validateDocumentGraphItemForInsertRequest.documentGraphInsertItemRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: validateDocumentGraphItemForInsertRequest.insertDocumentModel.parentId[0], language: documentLanguage)
            if databaseOrmResultudcDocumentGraphModelParent.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModelParent.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModelParent.databaseOrmError[0].description))
                return
            }
            let udcDocumentGraphModelParent = databaseOrmResultudcDocumentGraphModelParent.object[0]
            if !udcSentencePattern.sentence.isEmpty {
                let found = checkAlreadyFound(childrens: udcDocumentGraphModelParent.childrenId, name: udcSentencePattern.sentence, validateDocumentGraphItemForInsertRequest: validateDocumentGraphItemForInsertRequest, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
                
                if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
                    return
                }
                if found {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "AlreadyExist", description: "Already Exist!"))
                    return
                }
            }
        }
        
        let jsonUtilityValidateDocumentGraphItemForInsertResponse = JsonUtility<ValidateDocumentGraphItemForInsertResponse>()
        let jsonValidateDocumentGraphItemForInsertResponse = jsonUtilityValidateDocumentGraphItemForInsertResponse.convertAnyObjectToJson(jsonObject: validateDocumentGraphItemForInsertResponse)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonValidateDocumentGraphItemForInsertResponse)
    }
    
    private func checkAlreadyFound(childrens: [String], name: String, validateDocumentGraphItemForInsertRequest: ValidateDocumentGraphItemForInsertRequest, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) -> Bool {
        
        let documentLanguage = validateDocumentGraphItemForInsertRequest.documentGraphInsertItemRequest.documentLanguage
        
        for child in childrens {
            let databaseOrmResultudcDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: validateDocumentGraphItemForInsertRequest.documentGraphInsertItemRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: child, language: documentLanguage)
            if databaseOrmResultudcDocumentGraphModel.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModel.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModel.databaseOrmError[0].description))
                return false
            }
            let udcDocumentGraphModel = databaseOrmResultudcDocumentGraphModel.object[0]
            if udcDocumentGraphModel.udcSentencePattern.sentence == name {
                return true
            }
        }
        
        return false
    }
    
    private func documentGraphTypeProcess(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let documentGraphTypeProcessRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: DocumentGraphTypeProcessRequest())
        
        let documentGraphTypeProcessResponse = DocumentGraphTypeProcessResponse()
        if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.Type.Process.Post" {
            if documentGraphTypeProcessRequest.nodeIndex == 0 {
                documentGraphTypeProcessResponse.udcSentencePatternUniqueDocumentTitle = documentGraphTypeProcessRequest.udcDocuemntGraphModel.udcSentencePattern
            } else if documentGraphTypeProcessRequest.nodeIndex == 1 {
                documentGraphTypeProcessResponse.udcSentencePatternDocumentTitle = documentGraphTypeProcessRequest.udcDocuemntGraphModel.udcSentencePattern
            }
        } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.Type.Process.View.Generated" || neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.Type.Process.InsertItem.Validated" || neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.Type.Process.DeleteItem.Validated" || neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.Type.Process.DocumentItemView.Insert.Generated" || neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.Type.Process.DocumentItemView.Change.Generated" ||
            neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.Type.Process.SentencePattern.Got" || neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.Type.Process.SentencePattern.Got" || neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.Type.Process.idName.Generated" {
            documentGraphTypeProcessResponse.isProcessed = true
        }
        
        let jsonUtilityDocumentGraphTypeProcessResponse = JsonUtility<DocumentGraphTypeProcessResponse>()
        let jsonDocumentGraphTypeProcessResponse = jsonUtilityDocumentGraphTypeProcessResponse.convertAnyObjectToJson(jsonObject: documentGraphTypeProcessResponse)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonDocumentGraphTypeProcessResponse)
    }
    
    private func getDocumentCategories(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let getDocumentCategoriesRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: GetDocumentCategoriesRequest())
        
        let interfaceLanguage = getDocumentCategoriesRequest.interfaceLanguage
        
        var databaseOrmUVCViewItemType = UVCViewItemType.get(udbcDatabaseOrm!, idName: "UVCViewItemType.Text", interfaceLanguage)
        if databaseOrmUVCViewItemType.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUVCViewItemType.databaseOrmError[0].name, description: databaseOrmUVCViewItemType.databaseOrmError[0].description))
            return
        }
        let uvcViewItemType = databaseOrmUVCViewItemType.object[0]
        
        //        databaseOrmUVCViewItemType = UVCViewItemType.get(udbcDatabaseOrm!, idName: "UVCViewItemType.Photo", neuronRequest.language)
        //        if databaseOrmUVCViewItemType.databaseOrmError.count > 0 {
        //            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUVCViewItemType.databaseOrmError[0].name, description: databaseOrmUVCViewItemType.databaseOrmError[0].description))
        //            return
        //        }
        //        let uvcViewItemTypePhoto = databaseOrmUVCViewItemType.object[0]
        //
        let getDocumentCategoriesResponse = GetDocumentCategoriesResponse()
        var uvcOptionViewModel = UVCOptionViewModel()
        uvcOptionViewModel.level = 2
        uvcOptionViewModel.pathIdName.append(getDocumentCategoriesRequest.categoryOptionViewModel.pathIdName[0])
        uvcOptionViewModel.pathIdName[0].append(uvcViewItemType.idName)
        uvcOptionViewModel.objectIdName = "UDCSentencePattern.Text"
        uvcOptionViewModel.objectName = "UDCSentencePattern"
        uvcOptionViewModel.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: uvcViewItemType.name, description: "", category: "", subCategory: "", language: interfaceLanguage, isChildrenExist: false, isEditable: false, isCheckBox: false, photoId: nil, photoObjectName: nil)
        getDocumentCategoriesResponse.category.append(uvcOptionViewModel)
        //        uvcOptionViewModel = UVCOptionViewModel()
        //        uvcOptionViewModel.level = 2
        //        uvcOptionViewModel.path.append(getDocumentCategoriesRequest.categoryOptionViewModel.path[0])
        //        uvcOptionViewModel.path[0].append(uvcViewItemTypePhoto.name)
        //        uvcOptionViewModel.pathIdName.append(getDocumentCategoriesRequest.categoryOptionViewModel.pathIdName[0])
        //        uvcOptionViewModel.pathIdName[0].append(uvcViewItemTypePhoto.idName)
        //        uvcOptionViewModel.objectIdName = "UDCSentencePattern.Photo"
        //        uvcOptionViewModel.objectName = "UDCSentencePattern"
        //        uvcOptionViewModel.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: uvcViewItemType.name, description: "", category: "", subCategory: "", language: neuronRequest.language, isChildrenExist: false, isEditable: false, isCheckBox: false, photoId: nil, photoObjectName: nil)
        //        getDocumentCategoriesResponse.category.append(uvcOptionViewModel)
        
        let jsonUtilityGetDocumentCategoriesResponse = JsonUtility<GetDocumentCategoriesResponse>()
        let jsonGetDocumentCategoriesResponse = jsonUtilityGetDocumentCategoriesResponse.convertAnyObjectToJson(jsonObject: getDocumentCategoriesResponse)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonGetDocumentCategoriesResponse)
    }
    
    private func getDocumentCategoryOptions(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let getDocumentCategoryOptionsRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: GetDocumentCategoryOptionsRequest())
        
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
        uvcOptionViewModelSentence.objectIdName = "UDCSentencePattern.Text"
        uvcOptionViewModelSentence.objectName = "UDCSentencePattern"
        uvcOptionViewModelSentence.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: uvcViewItemTypeSentence.name, description: "", category: "", subCategory: "", language: interfaceLanguage, isChildrenExist: true, isEditable: false, isCheckBox: false, photoId: nil, photoObjectName: nil)
        
        let getDocumentCategoryOptionsResponse = GetDocumentCategoryOptionsResponse()
        getDocumentCategoryOptionsResponse.categoryOption["UDCOptionMapNode.All"] = [uvcOptionViewModelSentence]
        let jsonUtilityGetDocumentCategoryOptionsResponse = JsonUtility<GetDocumentCategoryOptionsResponse>()
        let jsonGetDocumentCategoryOptionsResponse = jsonUtilityGetDocumentCategoryOptionsResponse.convertAnyObjectToJson(jsonObject: getDocumentCategoryOptionsResponse)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonGetDocumentCategoryOptionsResponse)
        
    }
    
    
    private func getSentencePatternForDocumentItem(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let getSentencePatternForDocumentItemRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: GetGraphSentencePatternForDocumentItemRequest())
        
        var udcSentencePatternDataGroupValue = [UDCSentencePatternDataGroupValue]()
        if getSentencePatternForDocumentItemRequest.itemIndex == 0 && getSentencePatternForDocumentItemRequest.treeLevel > 1 {
            let udcSentencePatternDataGroupValueLocal = UDCSentencePatternDataGroupValue()
            udcSentencePatternDataGroupValueLocal.item = getSentencePatternForDocumentItemRequest.item
            udcSentencePatternDataGroupValueLocal.itemId = ""
            udcSentencePatternDataGroupValueLocal.category = "UDCGrammarCategory.CommonNoun"
            udcSentencePatternDataGroupValueLocal.endCategoryIdName = "UDCDocumentItem.General"
            udcSentencePatternDataGroupValueLocal.uvcViewItemType = "UVCViewItemType.Photo"
            udcSentencePatternDataGroupValue.append(udcSentencePatternDataGroupValueLocal)
        }
        if getSentencePatternForDocumentItemRequest.udcSentencePatternDataGroupValue == nil || ((getSentencePatternForDocumentItemRequest.udcSentencePatternDataGroupValue != nil ) && getSentencePatternForDocumentItemRequest.udcSentencePatternDataGroupValue!.count == 0)  {
            
            let udcSentencePatternDataGroupValueLocal = UDCSentencePatternDataGroupValue()
            udcSentencePatternDataGroupValueLocal.item = getSentencePatternForDocumentItemRequest.item
            udcSentencePatternDataGroupValueLocal.itemId = ""
            udcSentencePatternDataGroupValueLocal.category = "UDCGrammarCategory.CommonNoun"
            udcSentencePatternDataGroupValueLocal.endCategoryIdName = "UDCDocumentItem.General"
            udcSentencePatternDataGroupValueLocal.uvcViewItemType = "UVCViewItemType.Text"
            udcSentencePatternDataGroupValue.append(udcSentencePatternDataGroupValueLocal)
        } else {
            
            
            udcSentencePatternDataGroupValue.append(contentsOf: getSentencePatternForDocumentItemRequest.udcSentencePatternDataGroupValue!)
        }
        
        if !getSentencePatternForDocumentItemRequest.uvcViewItemType.isEmpty && udcSentencePatternDataGroupValue[0].uvcViewItemType != "UVCViewItemType.Photo" {
            udcSentencePatternDataGroupValue[0].uvcViewItemType = getSentencePatternForDocumentItemRequest.uvcViewItemType
        }
        
        
        let getSentencePatternForDocumentItemResponse = GetGraphSentencePatternForDocumentItemResponse()
        getSentencePatternForDocumentItemResponse.udcSentencePattern.udcSentencePatternData.append(UDCSentencePatternData())
        getSentencePatternForDocumentItemResponse.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup.append(UDCSentencePatternDataGroup())
        getSentencePatternForDocumentItemResponse.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.append(contentsOf: udcSentencePatternDataGroupValue)
        
        let jsonUtilityGetSentencePatternForDocumentItemResponse = JsonUtility<GetGraphSentencePatternForDocumentItemResponse>()
        let jsonGetSentencePatternForDocumentItemResponse = jsonUtilityGetSentencePatternForDocumentItemResponse.convertAnyObjectToJson(jsonObject: getSentencePatternForDocumentItemResponse)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonGetSentencePatternForDocumentItemResponse)
    }
    
    private func getSentencePatternDataGroupValue(optionItemObjectName: String, optionItemIdName: String, neuronResponse: inout NeuronRequest, language: String) throws -> [UDCSentencePatternDataGroupValue] {
        var udcSentencePatternDataGroupValueArray = [UDCSentencePatternDataGroupValue]()
        var udcSentencePatternDataGroupValue = UDCSentencePatternDataGroupValue()
        udcSentencePatternDataGroupValue.itemType = "UDCJson.String"
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
            udcSentencePatternDataGroupValueArray.append(udcSentencePatternDataGroupValue)
        } else if optionItemObjectName == "UDCGrammarItem" {
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
            udcSentencePatternDataGroupValueArray.append(udcSentencePatternDataGroupValue)
        }
        
        return udcSentencePatternDataGroupValueArray
    }
    
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
    
    private func getPhotoMeasurements(viewPathIdName: [String], width: inout Double, height: inout Double) {
        if viewPathIdName.count > 0 {
            if viewPathIdName.joined(separator: "->").hasPrefix("UDCOptionMapNode.ViewOptions->UVCViewItemType.Photo->") {
                if viewPathIdName.count > 3 {
                    width = Double(viewPathIdName[viewPathIdName.count - 1].components(separatedBy: "X")[1])!
                    height = Double(viewPathIdName[viewPathIdName.count - 1].components(separatedBy: "X")[2].components(separatedBy: "Pixels")[0])!
                }
            }
        }
    }
    
    private func getPhotoMeasurements(name: String, width: inout Double, height: inout Double) {
        width = Double(name.components(separatedBy: "X")[1])! * -1
        height = Double(name.components(separatedBy: "X")[2].components(separatedBy: "Pixels")[0])!
    }
    
    private func generateSentenceViewAsArray(udcDocumentGraphModel: UDCDocumentGraphModel,  uvcViewItemCollection: UVCViewItemCollection?, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest, newView: Bool, isEditable: Bool, level: Int, viewPathIdName: [String], documentLanguage: String, documentModelId: String, udcProfile: [UDCProfile], udcDocumentTypeIdName: String) -> [UVCViewModel] {
        var uvcViewModelReturn = [UVCViewModel]()
        var photoWidth: Double = -1
        var photoHeight: Double = -1
        
        
        for udcSentencePatternData in udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData {
            for (udcSentencePatternDataGroupIndex, udcSentencePatternDataGroup) in udcSentencePatternData.udcSentencePatternDataGroup.enumerated() {
                
                
                for (udcSentencePatternDataGroupValueIndex, udcSentencePatternDataGroupValue) in udcSentencePatternDataGroup.udcSentencePatternDataGroupValue.enumerated() {
                    let value = udcSentencePatternDataGroupValue.item
                    
                    if udcSentencePatternDataGroupValueIndex == 0 && level > 1 && udcSentencePatternDataGroup.udcSentencePatternDataGroupValue.count > 0 {
                        var databaseOrmResultUDCDocumentGraphModel: DatabaseOrmResult<UDCDocumentGraphModel>?
                        var itemIdName: String?
                        if udcDocumentGraphModel.isChildrenAllowed {
                            databaseOrmResultUDCDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, idName: "UDCDocumentItem.CollapseDownArrow", language: "en")
                            if databaseOrmResultUDCDocumentGraphModel!.databaseOrmError.count > 0 {
                                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentGraphModel!.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentGraphModel!.databaseOrmError[0].description))
                                return uvcViewModelReturn
                            }
                            itemIdName = databaseOrmResultUDCDocumentGraphModel!.object[0].udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].itemId
                            let uvcViewModel = uvcViewGenerator.getPhotoModel(isEditable: false, editObjectCategoryIdName: itemIdName!, editObjectName: "UDCDocumentItem", editObjectIdName: itemIdName!, level: level, isOptionAvailable: false, width: 24, height: 24, itemIndex: udcSentencePatternDataGroupIndex, isCategory: udcDocumentGraphModel.isChildrenAllowed, isBorderEnabled: false, isDeviceOptionsAvailable: false)
                            uvcViewModel.isReadOnly = true
                            uvcViewModelReturn.append(uvcViewModel)
                        }
                    }
                    if udcSentencePatternDataGroupValue.uvcViewItemType == "UVCViewItemType.Photo" {
                        if photoWidth == -1 && udcSentencePatternDataGroupValue.endCategoryIdName == "UDCDocumentItem.General" {
                            // Get the root model
                            let databaseOrmResultUDCDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, id: documentModelId)
                            if databaseOrmResultUDCDocumentGraphModel.databaseOrmError.count > 0 {
                                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentGraphModel.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentGraphModel.databaseOrmError[0].description))
                                return uvcViewModelReturn
                            }
                            let udcDocumentGraphModel = databaseOrmResultUDCDocumentGraphModel.object[0]
                            // Get the document item configuration document based on the id name formed from root model title
                            let databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, udcProfile: udcProfile, udcDocumentTypeIdName: "UDCDocumentType.DocumentItemConfiguration", idName: "UDCDocument.\(udcDocumentGraphModel.idName.split(separator: ".")[1])", language: documentLanguage)
                            if databaseOrmResultUDCDocument.databaseOrmError.count == 0 {
                                let udcDocument = databaseOrmResultUDCDocument.object[0]
                                // Get the document model
                                let databaseOrmResultUDCDocumentGraphModelItemConfiguration = UDCDocumentGraphModel.get(collectionName: "UDCDocumentItemConfiguration", udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocument.udcDocumentGraphModelId)
                                if databaseOrmResultUDCDocumentGraphModelItemConfiguration.databaseOrmError.count > 0 {
                                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentGraphModelItemConfiguration.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentGraphModelItemConfiguration.databaseOrmError[0].description))
                                    return uvcViewModelReturn
                                }
                                let udcDocumentGraphModelItemConfiguration = databaseOrmResultUDCDocumentGraphModelItemConfiguration.object[0]
                                // Get the photo size field by parsing it
                                var fieldsMap = [String: [UDCSentencePatternDataGroupValue]]()
                                documentParser.getField(fieldidName: "UDCDocumentItem.PhotoSize", childrenId: udcDocumentGraphModelItemConfiguration.childrenId, fieldValue: &fieldsMap, udcDocumentTypeIdName: "UDCDocumentType.DocumentItemConfiguration", documentLanguage: documentLanguage)
                                // Parse the photo measurements
                                getPhotoMeasurements(name: fieldsMap["UDCDocumentItem.PhotoSize"]![0].itemIdName, width: &photoWidth, height: &photoHeight)
                            } else {
                                photoWidth = 80
                                photoHeight = 80
                            }
                        }
                        if udcSentencePatternDataGroupValue.endCategoryIdName != "UDCDocumentItem.General" {
                            photoWidth = 24
                            photoHeight = 24
                        }
                        var isOptionAvilable = (udcSentencePatternDataGroupValue.itemIdName == "UDCDocumentItem.DocumentItemSeparator" || udcSentencePatternDataGroupValue.itemIdName == "UDCDocumentItem.SentencePatternNode") && udcSentencePatternDataGroupValue.endCategoryIdName == "UDCDocumentItem.DocumentInterfacePhoto"
                        let uvcViewModel = uvcViewGenerator.getPhotoModel(isEditable: udcSentencePatternDataGroupValue.isEditable, editObjectCategoryIdName: udcSentencePatternDataGroupValue.endSubCategoryId, editObjectName: "UDCDocumentItem", editObjectIdName: udcSentencePatternDataGroupValue.itemId, level: level, isOptionAvailable: isOptionAvilable, width: photoWidth, height: photoHeight, itemIndex: udcSentencePatternDataGroupValueIndex, isCategory: udcDocumentGraphModel.isChildrenAllowed, isBorderEnabled: true, isDeviceOptionsAvailable: true)
                        uvcViewModelReturn.append(uvcViewModel)
                    } else {
                        if udcDocumentGraphModel.isChildrenAllowed {
                            uvcViewModelReturn.append(contentsOf: uvcViewGenerator.getCategoryView(value: value!, language: documentLanguage, parentId: udcDocumentGraphModel.parentId, childrenId: udcDocumentGraphModel.childrenId, nodeId: [udcDocumentGraphModel._id], sentenceIndex: [udcSentencePatternDataGroupIndex], wordIndex: [udcSentencePatternDataGroupValueIndex], objectId: udcSentencePatternDataGroupValue.itemId, objectName: getEditObjectName(idName: udcSentencePatternDataGroupValue.endCategoryIdName), objectCategoryIdName: "", level: udcDocumentGraphModel.level))
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
                            
                            let name = uvcViewGenerator.generateNameWithUniqueId("Name")
                            
                            uvcViewItem.name = name
                            uvcViewItem.type = "UVCViewItemType.Text"
                            
                            if udcSentencePatternDataGroupValue.endCategoryIdName.isEmpty || (udcSentencePatternDataGroupValue.endCategoryIdName == "Grammar Item" && udcSentencePatternDataGroupValue.category != "UDCGrammarCategory.Number") {
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
                                uvcViewModel.uvcViewItemCollection.uvcText.append(uvcText)
                                uvcViewModel.name = uvcViewGenerator.generateNameWithUniqueId("UVCViewItemType.Text")
                                uvcViewModel.textLength = uvcText.value.count
                                uvcViewModel.rowLength = 1
                            } else {
                                let uvcText = uvcViewGenerator.getText(name: name, value: value!, description: "", isEditable: isEditable)
                                uvcText.uvcTextStyle.textColor = UVCColor.get(level: udcDocumentGraphModel.level)!.name
                                uvcText.parentId.append(contentsOf: udcDocumentGraphModel.parentId)
                                uvcText.childrenId.append(contentsOf: udcDocumentGraphModel.childrenId)
                                uvcText._id = udcDocumentGraphModel._id
                                
                                if udcSentencePatternDataGroupValue.category == "UDCGrammarCategory.Number" {
                                    uvcText.uvcViewItemType = "UVCViewItemType.Text"
                                    uvcViewModel.textLength = uvcText.value.count
                                    uvcViewModel.name = uvcViewGenerator.generateNameWithUniqueId("UVCViewItemType.Text")
                                } else {
                                    if isTextFieldRecipeItem(itemIdName: udcSentencePatternDataGroupValue.itemId) {
                                        uvcText.uvcViewItemType = "UVCViewItemType.Text"
                                        uvcText.isEditable = true
                                        uvcText.helpText = "\(udcSentencePatternDataGroupValue.item!.capitalized)"
                                        uvcViewModel.textLength = uvcText.value.count
                                        uvcViewModel.name = uvcViewGenerator.generateNameWithUniqueId("UVCViewItemType.Text")
                                    } else {
                                        if uvcText.value.isEmpty {
                                            uvcText.value = udcSentencePatternDataGroupValue.endCategoryIdName.capitalized
                                        }
                                        uvcText.uvcViewItemType = "UVCViewItemType.Text"
                                        uvcText.helpText = "\(udcSentencePatternDataGroupValue.item!.capitalized)"
                                        uvcViewModel.textLength = uvcText.value.count
                                        uvcText.isEditable = false
                                        uvcText.isOptionAvailable = true
                                        uvcViewModel.name = uvcViewGenerator.generateNameWithUniqueId("UVCViewItemType.Text")
                                    }
                                }
                                uvcText.uvcTextSize.uvcTextSizeType = UVCTextSizeType.Regular.name
                                uvcText.optionObjectIdName = udcSentencePatternDataGroupValue.itemId
                                uvcText.optionObjectCategoryIdName = udcSentencePatternDataGroupValue.endSubCategoryId
                                uvcText.optionObjectName = getEditObjectName(idName: udcSentencePatternDataGroupValue.endCategoryIdName)
                                uvcViewModel.uvcViewItemCollection.uvcText.append(uvcText)
                                uvcViewModel.rowLength = 1
                            }
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
        //        if level > 1 && uvcViewModelReturn.count > 0 {
        //            let databaseOrmResultUDCDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, idName: "UDCDocumentItem.Information", language: "en")
        //            if databaseOrmResultUDCDocumentGraphModel.databaseOrmError.count > 0 {
        //                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentGraphModel.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentGraphModel.databaseOrmError[0].description))
        //                return uvcViewModelReturn
        //            }
        //            let itemIdName = databaseOrmResultUDCDocumentGraphModel.object[0].udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].itemId
        //            let uvcViewModel = uvcViewGenerator.getPhotoModel(isEditable: false, editObjectCategoryIdName: itemIdName, editObjectName: "UDCDocumentItem", editObjectIdName: itemIdName, level: level, isOptionAvailable: false, width: 24, height: 24, itemIndex: udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.count, isCategory: udcDocumentGraphModel.isChildrenAllowed, isBorderEnabled: false, isDeviceOptionsAvailable: false)
        //            uvcViewModelReturn.append(uvcViewModel)
        //            uvcViewModel.isReadOnly = true
        //
        //        }
        
        return uvcViewModelReturn
    }
    
    private func isTextFieldRecipeItem(itemIdName: String) -> Bool {
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
    
    // Form the actual sentence as per Grammar rules, based on the sentence pattern
    private func processGrammar(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest, udcSentencePattern: UDCSentencePattern, documentLanguage: String, textStartIndex: Int) throws -> UDCSentencePattern {
        let neuronRequestLocal = NeuronRequest()
        neuronRequestLocal.neuronSource._id = neuronRequest.neuronSource._id
        neuronRequestLocal.neuronOperation.synchronus = true
        neuronRequestLocal.neuronOperation._id = neuronRequest.neuronOperation._id
        neuronRequestLocal.neuronSource.name = DocumentItemNeuron.getName()
        neuronRequestLocal.neuronSource.type = DocumentItemNeuron.getName();
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
        
        let interfaceLanguage = documentGraphItemReferenceRequest.interfaceLanguage
        var uvcOptionViewModel = [UVCOptionViewModel]()
        
        
        for id in childrenId {
            nodeIndex += 1
            let databaseOrmUDCDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphItemReferenceRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, idName: id, language: interfaceLanguage)
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
                udcSentencePattern = try processGrammar(neuronRequest: neuronRequest, neuronResponse: &neuronResponse, udcSentencePattern: udcSentencePattern, documentLanguage: interfaceLanguage, textStartIndex: -1)
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
        let documentLanguage = generateDocumentItemViewForChangeRequest.documentGraphChangeItemRequest.documentLanguage
        let generateDocumentItemViewForChangeResponse = GenerateDocumentItemViewForChangeResponse()
        let documentItemViewChangeData = DocumentGraphItemViewData()
        documentItemViewChangeData.uvcDocumentGraphModel._id = generateDocumentItemViewForChangeRequest.changeDocumentModel._id
        
        let uvcViewModelArray = generateSentenceViewAsArray(udcDocumentGraphModel: generateDocumentItemViewForChangeRequest.changeDocumentModel, uvcViewItemCollection: nil, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, newView: false, isEditable: true, level: generateDocumentItemViewForChangeRequest.documentGraphChangeItemRequest.level, viewPathIdName: generateDocumentItemViewForChangeRequest.documentGraphChangeItemRequest.objectControllerRequest.viewPathIdName, documentLanguage: documentLanguage, documentModelId: generateDocumentItemViewForChangeRequest.documentModelId, udcProfile: generateDocumentItemViewForChangeRequest.documentGraphChangeItemRequest.udcProfile,udcDocumentTypeIdName: generateDocumentItemViewForChangeRequest.documentGraphChangeItemRequest.udcDocumentTypeIdName)
        documentItemViewChangeData.uvcDocumentGraphModel.uvcViewModel.append(uvcViewModelArray[generateDocumentItemViewForChangeRequest.documentGraphChangeItemRequest.itemIndex])
        documentItemViewChangeData.treeLevel = generateDocumentItemViewForChangeRequest.documentGraphChangeItemRequest.level
        documentItemViewChangeData.nodeIndex = generateDocumentItemViewForChangeRequest.documentGraphChangeItemRequest.nodeIndex
        if generateDocumentItemViewForChangeRequest.documentGraphChangeItemRequest.udcDocumentTypeIdName == "UDCDocumentType.DocumentItem" {
            if generateDocumentItemViewForChangeRequest.changeDocumentModel.isChildrenAllowed && generateDocumentItemViewForChangeRequest.documentGraphChangeItemRequest.level > 1 {
                generateDocumentItemViewForChangeRequest.documentGraphChangeItemRequest.itemIndex += 1
            }
        }
        documentItemViewChangeData.itemIndex = generateDocumentItemViewForChangeRequest.documentGraphChangeItemRequest.itemIndex + 1
        documentItemViewChangeData.subItemIndex = generateDocumentItemViewForChangeRequest.documentGraphChangeItemRequest.subItemIndex
        documentItemViewChangeData.sentenceIndex = generateDocumentItemViewForChangeRequest.documentGraphChangeItemRequest.sentenceIndex
        if generateDocumentItemViewForChangeRequest.documentGraphChangeItemRequest.nodeIndex == 0 {
            //            generateDocumentItemViewForChangeRequest.changeDocumentModel.udcSentencePattern = try processGrammar(neuronRequest: neuronRequest, neuronResponse: &neuronResponse, udcSentencePattern: generateDocumentItemViewForChangeRequest.changeDocumentModel.udcSentencePattern)
            generateDocumentItemViewForChangeResponse.documentTitle = generateDocumentItemViewForChangeRequest.changeDocumentModel.udcSentencePattern.sentence
        }
        generateDocumentItemViewForChangeResponse.documentItemViewChangeData.append(documentItemViewChangeData)
        
        let jsonUtilityGenerateDocumentItemViewForChangeResponse = JsonUtility<GenerateDocumentItemViewForChangeResponse>()
        let jsonGenerateDocumentItemViewForChangeResponse = jsonUtilityGenerateDocumentItemViewForChangeResponse.convertAnyObjectToJson(jsonObject: generateDocumentItemViewForChangeResponse)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonGenerateDocumentItemViewForChangeResponse)
    }
    
    private func generateDocumentItemViewForInsert(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let generateDocumentItemViewForInsertRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: GenerateDocumentItemViewForInsertRequest())
        let documentLanguage = generateDocumentItemViewForInsertRequest.documentGraphInsertItemRequest.documentLanguage
        let generateDocumentItemViewForInsertResponse = GenerateDocumentItemViewForInsertResponse()
        
        
        
        let documentItemViewInsertData = DocumentGraphItemViewData()
        documentItemViewInsertData.uvcDocumentGraphModel._id = generateDocumentItemViewForInsertRequest.insertDocumentModel._id
        documentItemViewInsertData.uvcDocumentGraphModel.isChildrenAllowed = generateDocumentItemViewForInsertRequest.documentGraphInsertItemRequest.isParent
        documentItemViewInsertData.uvcDocumentGraphModel.level = generateDocumentItemViewForInsertRequest.documentGraphInsertItemRequest.level
        if generateDocumentItemViewForInsertRequest.documentGraphInsertItemRequest.nodeIndex == 0 {
            //            generateDocumentItemViewForInsertRequest.insertDocumentModel.udcSentencePattern = try processGrammar(neuronRequest: neuronRequest, neuronResponse: &neuronResponse, udcSentencePattern: generateDocumentItemViewForInsertRequest.insertDocumentModel.udcSentencePattern)
            generateDocumentItemViewForInsertResponse.documentTitle = generateDocumentItemViewForInsertRequest.insertDocumentModel.udcSentencePattern.sentence
        }
        let uvcViewModelArray = generateSentenceViewAsArray(udcDocumentGraphModel: generateDocumentItemViewForInsertRequest.insertDocumentModel, uvcViewItemCollection: generateDocumentItemViewForInsertRequest.uvcViewItemCollection, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, newView: true, isEditable: generateDocumentItemViewForInsertRequest.isEditable, level: generateDocumentItemViewForInsertRequest.documentGraphInsertItemRequest.level, viewPathIdName: generateDocumentItemViewForInsertRequest.documentGraphInsertItemRequest.objectControllerRequest.viewPathIdName, documentLanguage: documentLanguage, documentModelId: generateDocumentItemViewForInsertRequest.documentModelId, udcProfile: generateDocumentItemViewForInsertRequest.documentGraphInsertItemRequest.udcProfile,udcDocumentTypeIdName: generateDocumentItemViewForInsertRequest.documentGraphInsertItemRequest.udcDocumentTypeIdName)
        for (udcspgvIndex, udcspgv) in generateDocumentItemViewForInsertRequest.insertDocumentModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.enumerated() {
            uvcViewModelArray[udcspgvIndex].udcViewItemId = udcspgv.udcViewItemId
            uvcViewModelArray[udcspgvIndex].udcViewItemName = udcspgv.udcViewItemName
            generateDocumentItemViewForInsertResponse.objectControllerResponse.groupUVCViewItemType = udcspgv.groupUVCViewItemType
            generateDocumentItemViewForInsertResponse.objectControllerResponse.udcViewItemId = udcspgv.udcViewItemId
            generateDocumentItemViewForInsertResponse.objectControllerResponse.udcViewItemName = udcspgv.udcViewItemName
            generateDocumentItemViewForInsertResponse.objectControllerResponse.uvcViewItemType = "UVCViewItemType.Text"
        }
        
        if generateDocumentItemViewForInsertRequest.documentGraphInsertItemRequest.itemIndex == 0 {
            documentItemViewInsertData.uvcDocumentGraphModel.uvcViewModel.append(contentsOf: uvcViewModelArray)
        } else {
            if generateDocumentItemViewForInsertRequest.insertDocumentModel.isChildrenAllowed && generateDocumentItemViewForInsertRequest.documentGraphInsertItemRequest.level > 1 {
                documentItemViewInsertData.uvcDocumentGraphModel.uvcViewModel.append(uvcViewModelArray[generateDocumentItemViewForInsertRequest.documentGraphInsertItemRequest.itemIndex + 1])
            } else {
                documentItemViewInsertData.uvcDocumentGraphModel.uvcViewModel.append(uvcViewModelArray[generateDocumentItemViewForInsertRequest.documentGraphInsertItemRequest.itemIndex])
            }
            //            for (uvcvmaIndex, uvcvma) in uvcViewModelArray.enumerated() {
            //                if uvcvmaIndex >= generateDocumentItemViewForInsertRequest.documentGraphInsertItemRequest.itemIndex {
            //                    documentItemViewInsertData.uvcDocumentGraphModel.uvcViewModel.append(uvcvma)
            //                }
            //            }
        }
        
        documentItemViewInsertData.treeLevel = generateDocumentItemViewForInsertRequest.documentGraphInsertItemRequest.level
        documentItemViewInsertData.nodeIndex = generateDocumentItemViewForInsertRequest.documentGraphInsertItemRequest.nodeIndex
        if generateDocumentItemViewForInsertRequest.documentGraphInsertItemRequest.itemIndex > 0 {
            if generateDocumentItemViewForInsertRequest.insertDocumentModel.isChildrenAllowed && generateDocumentItemViewForInsertRequest.documentGraphInsertItemRequest.level > 1 {
                documentItemViewInsertData.itemIndex = generateDocumentItemViewForInsertRequest.documentGraphInsertItemRequest.itemIndex + 2
            } else {
                documentItemViewInsertData.itemIndex = generateDocumentItemViewForInsertRequest.documentGraphInsertItemRequest.itemIndex + 1
            }
        } else {
            documentItemViewInsertData.itemIndex = generateDocumentItemViewForInsertRequest.documentGraphInsertItemRequest.itemIndex + 1
        }
        documentItemViewInsertData.sentenceIndex = generateDocumentItemViewForInsertRequest.documentGraphInsertItemRequest.sentenceIndex
        
        generateDocumentItemViewForInsertResponse.documentItemViewInsertData.append(documentItemViewInsertData)
        if generateDocumentItemViewForInsertRequest.documentGraphInsertItemRequest.itemIndex == 0 && generateDocumentItemViewForInsertRequest.documentGraphInsertItemRequest.level > 1 {
            generateDocumentItemViewForInsertResponse.columnAdjustment = -1
        }
        //        if generateDocumentItemViewForInsertRequest.documentGraphInsertItemRequest.itemIndex > 0 {
        //
        //        }
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
    //                            if neuronRequest.neuronOperation.name == "DocumentItemNeuron.Document.Word.Append" {
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
    
    private func getDocumentModels(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let getDocumentModelsRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: GetDocumentModelsRequest())
        
        let documentLanguage = getDocumentModelsRequest.documentGraphNewRequest.documentLanguage
        
        let getDocumentModelsResponse = GetDocumentModelsResponse()
        
        let databaseOrmUDCDocumentItemMapNode = UDCDocumentItemMapNode.get("UDCDocumentItemMapNode.SearchDocumentItems", udbcDatabaseOrm!, documentLanguage)
        if databaseOrmUDCDocumentItemMapNode.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentItemMapNode.databaseOrmError[0].name, description: databaseOrmUDCDocumentItemMapNode.databaseOrmError[0].description))
            return
        }
        let searchDocumentItem = databaseOrmUDCDocumentItemMapNode.object
        
        var profileId = ""
        for udcp in getDocumentModelsRequest.udcProfile {
            if udcp.udcProfileItemIdName == "UDCProfileItem.Human" {
                profileId = udcp.profileId
            }
        }
        
        // Create model for title
        let udcDocumentGraphModel = UDCDocumentGraphModel()
        udcDocumentGraphModel._id = try (udbcDatabaseOrm?.generateId())!
        getDocumentModelsResponse.documentModelId = udcDocumentGraphModel._id
        udcDocumentGraphModel.isChildrenAllowed = true
        udcDocumentGraphModel.udcDocumentTime.createdBy = profileId
        udcDocumentGraphModel.udcDocumentTime.creationTime = Date()
        udcDocumentGraphModel.name = getDocumentModelsRequest.englishName
        udcDocumentGraphModel.idName = "\(neuronUtility!.getCollectionName(udcDocumentTypeIdName: getDocumentModelsRequest.documentGraphNewRequest.udcDocumentTypeIdName)!).\(getDocumentModelsRequest.englishName.capitalized.trimmingCharacters(in: .whitespaces))"
        udcDocumentGraphModel.level = 0
        udcDocumentGraphModel.language = documentLanguage
        udcDocumentGraphModel.udcProfile = getDocumentModelsRequest.udcProfile
        let udcGrammarUtility = UDCGrammarUtility()
        var udcSentencePatternDataGroupValue = UDCSentencePatternDataGroupValue()
        udcSentencePatternDataGroupValue.item = getDocumentModelsRequest.englishName
        udcSentencePatternDataGroupValue.endCategoryIdName = "UDCDocumentItemMapNode.Title"
        udcSentencePatternDataGroupValue.itemType = "UDCJson.String"
        udcSentencePatternDataGroupValue.uvcViewItemType = "UVCViewItemType.Text"
        var udcSentencePatternLocal = UDCSentencePattern()
        udcGrammarUtility.getSetencePattern(udcSentencePattern: &udcSentencePatternLocal, udcSentencePatternDataGroupValue: [udcSentencePatternDataGroupValue])
        udcSentencePatternLocal = try processGrammar(neuronRequest: neuronRequest, neuronResponse: &neuronResponse, udcSentencePattern: udcSentencePatternLocal, documentLanguage: documentLanguage, textStartIndex: -1)
        udcDocumentGraphModel.udcSentencePattern = udcSentencePatternLocal
        
        let udcDocumentGraphModel1 = UDCDocumentGraphModel()
        udcDocumentGraphModel1._id = try (udbcDatabaseOrm?.generateId())!
        udcDocumentGraphModel1.isChildrenAllowed = true
        udcDocumentGraphModel1.udcDocumentTime.createdBy = profileId
        udcDocumentGraphModel1.udcDocumentTime.creationTime = Date()
        udcDocumentGraphModel1.name = getDocumentModelsRequest.name
        udcDocumentGraphModel1.idName = "\(neuronUtility!.getCollectionName(udcDocumentTypeIdName: getDocumentModelsRequest.documentGraphNewRequest.udcDocumentTypeIdName)!).\(getDocumentModelsRequest.name.capitalized.trimmingCharacters(in: .whitespaces))"
        udcDocumentGraphModel1.level = 1
        udcDocumentGraphModel1.language = documentLanguage
        udcDocumentGraphModel1.udcProfile = getDocumentModelsRequest.udcProfile
        udcSentencePatternDataGroupValue = UDCSentencePatternDataGroupValue()
        udcSentencePatternDataGroupValue.item = getDocumentModelsRequest.name
        udcSentencePatternDataGroupValue.endCategoryIdName = "UDCDocumentItemMapNode.Title"
        udcSentencePatternDataGroupValue.itemType = "UDCJson.String"
        udcSentencePatternDataGroupValue.uvcViewItemType = "UVCViewItemType.Text"
        udcSentencePatternLocal = UDCSentencePattern()
        udcGrammarUtility.getSetencePattern(udcSentencePattern: &udcSentencePatternLocal, udcSentencePatternDataGroupValue: [udcSentencePatternDataGroupValue])
        udcSentencePatternLocal = try processGrammar(neuronRequest: neuronRequest, neuronResponse: &neuronResponse, udcSentencePattern: udcSentencePatternLocal, documentLanguage: documentLanguage, textStartIndex: -1)
        udcDocumentGraphModel1.udcSentencePattern = udcSentencePatternLocal
        udcDocumentGraphModel1.parentId.append(udcDocumentGraphModel._id)
        udcDocumentGraphModel.childrenId.append(udcDocumentGraphModel1._id)
        
        // Create view model for title
        let uvcDocumentGraphModel = UVCDocumentGraphModel()
        uvcDocumentGraphModel.isChildrenAllowed = true
        uvcDocumentGraphModel._id = udcDocumentGraphModel._id
        uvcDocumentGraphModel.level = udcDocumentGraphModel.level
        uvcDocumentGraphModel.language = documentLanguage
        
        let uvcDocumentGraphModel1 = UVCDocumentGraphModel()
        uvcDocumentGraphModel1.isChildrenAllowed = true
        uvcDocumentGraphModel1._id = udcDocumentGraphModel1._id
        uvcDocumentGraphModel1.level = udcDocumentGraphModel1.level
        uvcDocumentGraphModel1.language = documentLanguage
        
        getDocumentModelsResponse.udcDocumentGraphModel.append(udcDocumentGraphModel1)
        
        
        // Generate title with all the children food recipe categories
        for (udcspdgvIndexm, udcspdgv) in udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.enumerated() {
            let uvcViewModel = uvcViewGenerator.getCategoryView(value: udcspdgv.item!, language: documentLanguage, parentId: [], childrenId: [], nodeId: [uvcDocumentGraphModel._id], sentenceIndex: [0], wordIndex: [0], objectId: udcspdgv.itemId, objectName: String(udcspdgv.endCategoryIdName.split(separator: ".")[0]), objectCategoryIdName: "", level: 0)
            uvcDocumentGraphModel.uvcViewModel.append(contentsOf: uvcViewModel)
            // Add search box below first category
            let uvcm = uvcViewGenerator.getSearchBoxViewModel(name: searchDocumentItem[0].idName, value: "", level: 2, pictureName: "Elipsis", helpText: searchDocumentItem[0].name, parentId: [udcDocumentGraphModel._id], childrenId: [], language: documentLanguage)
            if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
                return
            }
            uvcm.textLength = 25
            uvcDocumentGraphModel.uvcViewModel.append(uvcm)
        }
        
        for udcspdgv in udcDocumentGraphModel1.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue {
            let uvcViewModel = uvcViewGenerator.getCategoryView(value: udcspdgv.item!, language: documentLanguage, parentId: [], childrenId: [], nodeId: [uvcDocumentGraphModel1._id], sentenceIndex: [0], wordIndex: [0], objectId: udcspdgv.itemId, objectName: String(udcspdgv.endCategoryIdName.split(separator: ".")[0]), objectCategoryIdName: "", level: 1)
            uvcDocumentGraphModel1.uvcViewModel.append(contentsOf: uvcViewModel)
        }
        
        getDocumentModelsResponse.udcDocumentGraphModel.append(udcDocumentGraphModel)
        getDocumentModelsResponse.uvcDocumentGraphModel.insert(uvcDocumentGraphModel1, at: 0)
        getDocumentModelsResponse.uvcDocumentGraphModel.insert(uvcDocumentGraphModel, at: 0)
        
        getDocumentModelsResponse.objectControllerResponse.groupUVCViewItemType = ""
        getDocumentModelsResponse.objectControllerResponse.uvcViewItemType = "UVCViewItemType.Text"
        // Generate line numbers
        
        for (uvcdmIndex, uvcdm) in getDocumentModelsResponse.uvcDocumentGraphModel.enumerated() {
            uvcViewGenerator.generateLineNumbers(uvcViewModel: &uvcdm.uvcViewModel, uvcdmIndex: uvcdmIndex, parentId: uvcdm.parentId, childrenId: uvcdm.childrenId, editMode: true)
        }
        getDocumentModelsResponse.itemIndex = 2
        getDocumentModelsResponse.nodeIndex = 0
        getDocumentModelsResponse.cursorSentence = 0
        
        let jsonUtilityGetDocumentModelsResponse = JsonUtility<GetDocumentModelsResponse>()
        let jsonDocumentGetDocumentModelsResponse = jsonUtilityGetDocumentModelsResponse.convertAnyObjectToJson(jsonObject: getDocumentModelsResponse)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonDocumentGetDocumentModelsResponse)
        
    }
    
    
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
//        documentAddCategoryResponse.uvcDocumentGraphModel[0].uvcViewModel.append(contentsOf: uvcViewGenerator.getCategoryView(value: udcDocumentGraphModelCategory.name, language: documentLanguage, parentId: [], childrenId: [], nodeId: [udcDocumentGraphModelCategory._id], sentenceIndex: [0], wordIndex: [0], objectId: "", objectName: "", objectCategoryIdName: "", level: 0))
//        let jsonUtilityDocumentAddCategoryResponse = JsonUtility<DocumentAddCategoryResponse>()
//        let jsonDocumentAddCategoryResponse = jsonUtilityDocumentAddCategoryResponse.convertAnyObjectToJson(jsonObject: documentAddCategoryResponse)
//        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonDocumentAddCategoryResponse)
//    }
//
    
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
    
    
    private func searchDocumentItem(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let documentGraphItemSearchRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: DocumentGraphItemSearchRequest())
        let documentGraphItemSearchResponse = DocumentGraphItemSearchResponse()
        
        if documentGraphItemSearchRequest.text.trimmingCharacters(in: .whitespaces).isEmpty {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "SearchTextCannotBeEmpty", description: "Search text cannot be empty"))
            return
        }
        
        //        if documentGraphItemSearchRequest.udcDocumentTypeIdName != "UDCDocumentType.DocumentItem" {
        
        let documentLanguage = documentGraphItemSearchRequest.documentLanguage
        let interfaceLanguage = documentGraphItemSearchRequest.interfaceLanguage
        
        var uvcOptionViewModel = [UVCOptionViewModel]()
        let uvcOptionViewModelLocal = UVCOptionViewModel()
        
        // Check if the option map is found. If not found return
        let databaseOrmResultUDCDocumentItemMap = UDCDocumentItemMap.get(udbcDatabaseOrm: udbcDatabaseOrm!, idName: "UDCDocumentItemMap.DocumentItems", udcProfile: documentGraphItemSearchRequest.udcProfile, language: documentLanguage)
        if databaseOrmResultUDCDocumentItemMap.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentItemMap.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentItemMap.databaseOrmError[0].description))
            return
        }
        let udcDocumentItemMap = databaseOrmResultUDCDocumentItemMap.object[0]
        
        // Title
        uvcOptionViewModelLocal.objectIdName = try (udbcDatabaseOrm?.generateId())!
        uvcOptionViewModelLocal.objectName = ""
        uvcOptionViewModelLocal.level = 0
        uvcOptionViewModelLocal.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: databaseOrmResultUDCDocumentItemMap.object[0].name.capitalized, description: "", category: "", subCategory: "", language: documentLanguage, isChildrenExist: false, isEditable: false, isCheckBox: false, photoId: nil, photoObjectName: nil)
        uvcOptionViewModelLocal.uvcViewModel.rowLength = 1
        documentGraphItemSearchResponse.uvcOptionViewModel.append(uvcOptionViewModelLocal)
        
        // Grammar items
        //        let neuronRequestLocal = neuronRequest
        //        var neuronResponseLocal = NeuronRequest()
        //
        //        let grammarItemSearchRequest = GrammarItemSearchRequest()
        //        grammarItemSearchRequest.selectedOption = uvcOptionViewModelLocal
        //        grammarItemSearchRequest.text = documentGraphItemSearchRequest.text
        //        grammarItemSearchRequest.isBySubCategory = documentGraphItemSearchRequest.isBySubCategory
        //        grammarItemSearchRequest.isSentencePattern = documentGraphItemSearchRequest.isSentencePattern
        //        grammarItemSearchRequest.isByName = documentGraphItemSearchRequest.isByName
        //        grammarItemSearchRequest.isIncludeGrammar = documentGraphItemSearchRequest.isIncludeGrammar
        //        grammarItemSearchRequest.isByCategory = documentGraphItemSearchRequest.isByCategory
        //        let jsonUtilityGrammarItemSearchRequest = JsonUtility<GrammarItemSearchRequest>()
        //        neuronRequestLocal.neuronOperation.neuronData.text = jsonUtilityGrammarItemSearchRequest.convertAnyObjectToJson(jsonObject: grammarItemSearchRequest)
        //        neuronRequestLocal.neuronOperation.name = "GrammarNeuron.Search.GrammarItem"
        //        try callOtherNeuron(neuronRequest: neuronRequestLocal, neuronResponse: &neuronResponseLocal, neuronName: "GrammarNeuron", overWriteResponse: true)
        //        if !neuronResponseLocal.neuronOperation.neuronData.text.isEmpty {
        //            let jsonUtilityGrammarItemSearchResponse = JsonUtility<GrammarItemSearchResponse>()
        //            let grammarItemSearchResponse = jsonUtilityGrammarItemSearchResponse.convertJsonToAnyObject(json: neuronResponseLocal.neuronOperation.neuronData.text)
        //            documentGraphItemSearchResponse.uvcOptionViewModel.append(contentsOf: grammarItemSearchResponse.uvcOptionViewModel)
        //        }
        let databaseOrmResultUDCDocumentItemMapNode = UDCDocumentItemMapNode.get("UDCDocumentItemMapNode.DocumentItems", udbcDatabaseOrm!, documentLanguage)
        
        
        // Recurse through the document items and generate the search result view
        for searchPhase in 1...2 {
            try searchDocumentItem(children: udcDocumentItemMap.udcDocumentItemMapNodeId, uvcOptionViewModel: &uvcOptionViewModel, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, documentGraphItemSearchRequest: documentGraphItemSearchRequest, searchPhase: searchPhase)
            // If found then break
            if uvcOptionViewModel.count > 0 {
                break
            }
        }
        
        if uvcOptionViewModel.count == 0 && documentGraphItemSearchRequest.udcDocumentTypeIdName != "UDCDocumentType.DocumentItem" {
            var wordId: String = ""
            var grammarCategory: String = ""
            var udcDocumentId: String = ""
            try addToWordDictionary(text: documentGraphItemSearchRequest.text, category: databaseOrmResultUDCDocumentItemMapNode.object[0].name.capitalized, documentLanguage: documentLanguage, udcProfile: documentGraphItemSearchRequest.udcProfile, udcDocumentTypeIdName: documentGraphItemSearchRequest.udcDocumentTypeIdName, wordId: &wordId, grammarCategory: &grammarCategory, documentId: &udcDocumentId, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            if !wordId.isEmpty {
                let uvcOptionViewModelLocal = UVCOptionViewModel()
                // User word
                uvcOptionViewModelLocal.objectIdName = wordId
                uvcOptionViewModelLocal.objectDocumentIdName = udcDocumentId
                uvcOptionViewModelLocal.objectName = "\(neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphItemSearchRequest.udcDocumentTypeIdName)!)WordDictionary"
                uvcOptionViewModelLocal.parentId.append(uvcOptionViewModelLocal.objectIdName)
                uvcOptionViewModelLocal.level = 1
                uvcOptionViewModelLocal.pathIdName.append(["UDCDocumentItemMapNode.DocumentItems"])
                uvcOptionViewModelLocal.pathIdName[0].append(documentGraphItemSearchRequest.text)
                uvcOptionViewModelLocal.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: documentGraphItemSearchRequest.text, description: "", category: databaseOrmResultUDCDocumentItemMapNode.object[0].name.capitalized, subCategory: "", language: documentLanguage, isChildrenExist: false, isEditable: false, isCheckBox: false, photoId: nil, photoObjectName: nil)
                uvcOptionViewModelLocal.uvcViewModel.rowLength = 2
                if uvcOptionViewModel != nil {
                    uvcOptionViewModel.append(uvcOptionViewModelLocal)
                }
            }
        }
        
        documentGraphItemSearchResponse.uvcOptionViewModel.append(contentsOf: uvcOptionViewModel)
        //        }
        
        let jsonUtilityDocumentGraphItemSearchResponse = JsonUtility<DocumentGraphItemSearchResponse>()
        let jsonDocumentGraphItemSearchResponse = jsonUtilityDocumentGraphItemSearchResponse.convertAnyObjectToJson(jsonObject: documentGraphItemSearchResponse)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonDocumentGraphItemSearchResponse)
    }
    
    private func addToWordDictionary(text: String, category: String, documentLanguage: String, udcProfile: [UDCProfile], udcDocumentTypeIdName: String, wordId: inout String, grammarCategory: inout String, documentId: inout String, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        
        let databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, udcProfile: udcProfile, udcDocumentTypeIdName: "UDCDocumentType.DocumentItem", idName: "UDCDocument.\(udcDocumentTypeIdName.split(separator: ".")[1])WordDictionary", language: documentLanguage)
        if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocument.databaseOrmError[0].name, description: databaseOrmResultUDCDocument.databaseOrmError[0].description))
            return
        }
        let udcDocument = databaseOrmResultUDCDocument.object[0]
        documentId = udcDocument._id
        // Get the document model based on id
        let databaseOrmResultUDCDocumentItem = UDCDocumentGraphModel.get(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocument.udcDocumentGraphModelId)
        if databaseOrmResultUDCDocumentItem.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentItem.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentItem.databaseOrmError[0].description))
            return
        }
        let udcDocumentItem = databaseOrmResultUDCDocumentItem.object[0]
        
        // Get the children title based on id
        let databaseOrmResultUDCDocumentItemChild = UDCDocumentGraphModel.get(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentItem.childrenId[0], language: documentLanguage)
        if databaseOrmResultUDCDocumentItemChild.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentItemChild.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentItemChild.databaseOrmError[0].description))
            return
        }
        let udcDocumentItemChild = databaseOrmResultUDCDocumentItemChild.object[0]
        
        // Create the word graph model
        let udcDocumentGraphModel = UDCDocumentGraphModel()
        udcDocumentGraphModel._id = try udbcDatabaseOrm!.generateId()
        udcDocumentGraphModel.name = text
        udcDocumentGraphModel.idName = "UDCDocumentItem.\(text.capitalized.replacingOccurrences(of: " ", with: ""))"
        udcDocumentGraphModel.language = documentLanguage
        udcDocumentGraphModel.level = udcDocumentItemChild.level + 1
        udcDocumentGraphModel.udcDocumentTime.createdBy = documentParser.getUDCProfile(udcProfile: udcProfile, idName: "UDCProfileItem.Human")
        udcDocumentGraphModel.udcDocumentTime.creationTime = Date()
        udcDocumentGraphModel.objectName = "\(neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!)WordDictionary"
        udcDocumentGraphModel.udcProfile = udcProfile
        udcDocumentGraphModel.parentId.append(udcDocumentItemChild._id)
        udcDocumentItemChild.childrenId.append(udcDocumentGraphModel._id)
        var udcSentencePatternDataGroupValueArray = [UDCSentencePatternDataGroupValue]()
        var udcSentencePatternDataGroupValueLocal = UDCSentencePatternDataGroupValue()
        udcSentencePatternDataGroupValueLocal.item = text
        udcSentencePatternDataGroupValueLocal.itemId = ""
        udcSentencePatternDataGroupValueLocal.category = "UDCGrammarCategory.CommonNoun"
        udcSentencePatternDataGroupValueLocal.endCategoryIdName = "UDCDocumentItem.General"
        udcSentencePatternDataGroupValueLocal.uvcViewItemType = "UVCViewItemType.Photo"
        udcSentencePatternDataGroupValueArray.append(udcSentencePatternDataGroupValueLocal)
        let naturalLanguageProcessorUtility = NaturalLanguageProcessorUtility()
        var word = [String]()
        var wordTag = [String]()
        var wordLanguage: String = ""
        naturalLanguageProcessorUtility.process(text: "dummy \(text)", word: &word, wordTag: &wordTag, language: &wordLanguage)
        udcSentencePatternDataGroupValueLocal = UDCSentencePatternDataGroupValue()
        udcSentencePatternDataGroupValueLocal.udcDocumentId = udcDocument._id
        udcSentencePatternDataGroupValueLocal.item = text
        udcSentencePatternDataGroupValueLocal.itemId = ""
        if wordTag.count == 2 {
            grammarCategory = wordTag[1]
            udcSentencePatternDataGroupValueLocal.category = "UDCGrammarCategory.\(grammarCategory.capitalized.replacingOccurrences(of: " ", with: ""))"
        } else {
            udcSentencePatternDataGroupValueLocal.category = "UDCGrammarCategory.CommonNoun"
        }
        udcSentencePatternDataGroupValueLocal.endCategoryIdName = "UDCDocumentItemMapNode.\(udcDocumentTypeIdName.split(separator: ".")[1])WordDictionary"
        udcSentencePatternDataGroupValueLocal.uvcViewItemType = "UVCViewItemType.Text"
        udcSentencePatternDataGroupValueArray.append(udcSentencePatternDataGroupValueLocal)
        let udcGrammarUtility = UDCGrammarUtility()
        var udcSentencePattern = UDCSentencePattern()
        udcGrammarUtility.getSetencePattern(udcSentencePattern: &udcSentencePattern, udcSentencePatternDataGroupValue: udcSentencePatternDataGroupValueArray)
        udcDocumentGraphModel.udcSentencePattern = udcSentencePattern
        let databaseOrmResultUDCDocumentGraphModel = UDCDocumentGraphModel.save(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentGraphModel)
        if databaseOrmResultUDCDocumentGraphModel.databaseOrmError.count == 0 {
            wordId = udcDocumentGraphModel._id // Let the caller do whatever with it
        }
        
        // Update the graph model with new child
        let databaseOrmResultUDCDocumentGraphModelChildUpdate = UDCDocumentGraphModel.update(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentItemChild)
        if databaseOrmResultUDCDocumentGraphModelChildUpdate.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentGraphModelChildUpdate.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentGraphModelChildUpdate.databaseOrmError[0].description))
            return
        }
    }
    
    private func searchDocumentItem(children: [String], uvcOptionViewModel: inout [UVCOptionViewModel], neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest, documentGraphItemSearchRequest: DocumentGraphItemSearchRequest, searchPhase: Int) throws {
        
        let documentLanguage = documentGraphItemSearchRequest.documentLanguage
        
        for childrenId in children {
            // Get the document item for the document type
            let databaseOrmResultUDCDocumentItemMapNode = UDCDocumentItemMapNode.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: childrenId, language: documentLanguage, udcDocumentTypeIdName: [documentGraphItemSearchRequest.udcDocumentTypeIdName, "UDCDocumentType.General"])
            if databaseOrmResultUDCDocumentItemMapNode.databaseOrmError.count == 0 {
                let udcDocumentItemMapNode = databaseOrmResultUDCDocumentItemMapNode.object[0]
                // Loop through its childrens and process each document item map node
                for childrenIdSub in udcDocumentItemMapNode.childrenId {
                    let databaseOrmResultUDCDocumentItemMapNodeSub = UDCDocumentItemMapNode.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: childrenIdSub, language: documentLanguage, udcDocumentTypeIdName: [documentGraphItemSearchRequest.udcDocumentTypeIdName, "UDCDocumentType.General"])
                    if databaseOrmResultUDCDocumentItemMapNodeSub.databaseOrmError.count == 0 {
                        let udcDocumentItemMapNodeSub = databaseOrmResultUDCDocumentItemMapNodeSub.object[0]
                        // Process the document item if have document id
                        if udcDocumentItemMapNodeSub.objectId.count > 0 {
                            let documentId = udcDocumentItemMapNodeSub.objectId[0]
                            
                            let objectName = udcDocumentItemMapNodeSub.objectName
                            var collectionName = objectName
                            if objectName.hasSuffix("WordDictionary") {
                                collectionName = "UDCDocumentItem"
                            }
                            if objectName == "UDCDocumentQuery" {
                                let databaseOrmUDCDocument = try UDCDocument.get(collectionName: collectionName, udbcDatabaseOrm: udbcDatabaseOrm!, id: documentId, language: documentLanguage)
                                if databaseOrmUDCDocument.databaseOrmError.count == 0 {
                                    let udcDocumentQuery = databaseOrmUDCDocument.object[0]
                                    let databaseOrmUDCDocumentSearch: DatabaseOrmResult<UDCDocument>?
                                    // If document type based query
                                    if !udcDocumentQuery.udcDocumentTypeIdName.isEmpty {
                                        //                                        if searchPhase == 1 {
                                        //                                            databaseOrmUDCDocumentSearch = try UDCDocument.get(text: documentGraphItemSearchRequest.text, udcDocumentTypeIdName: udcDocumentQuery.udcDocumentTypeIdName, limitedTo: 0, sortedBy: "name", udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
                                        //                                        } else {
                                        databaseOrmUDCDocumentSearch = try UDCDocument.search(collectionName: "UDCDocument", text: documentGraphItemSearchRequest.text, udcDocumentTypeIdName: udcDocumentQuery.udcDocumentTypeIdName, limitedTo: 0, sortedBy: "name", udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
                                        //                                        }
                                        if databaseOrmUDCDocumentSearch!.databaseOrmError.count == 0 {
                                            let udcDocument = databaseOrmUDCDocumentSearch!.object[0]
                                            for udcd in databaseOrmUDCDocumentSearch!.object {
                                                var uvcOptionViewModelLocal = UVCOptionViewModel()
                                                uvcOptionViewModelLocal = UVCOptionViewModel()
                                                uvcOptionViewModelLocal.objectDocumentIdName = udcd._id
                                                uvcOptionViewModelLocal.objectIdName = udcd._id
                                                uvcOptionViewModelLocal.objectName = "UDCDocument"
                                                uvcOptionViewModelLocal.parentId.append(udcDocumentItemMapNodeSub.parentId[0])
                                                uvcOptionViewModelLocal.pathIdName.append(["UDCDocumentItemMapNode.DocumentItems"])
                                                uvcOptionViewModelLocal.pathIdName[0].append(udcDocument.idName)
                                                uvcOptionViewModelLocal.level = 1
                                                uvcOptionViewModelLocal.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: udcd.name, description: "", category: stringUtility.capitalCaseToArray(capitalCaseText: String(udcDocumentQuery.udcDocumentTypeIdName.split(separator: ".")[1])).joined(separator: " "), subCategory: "", language: documentLanguage, isChildrenExist: false, isEditable: false, isCheckBox: false, photoId: nil, photoObjectName: objectName)
                                                uvcOptionViewModelLocal.uvcViewModel.rowLength = 2
                                                uvcOptionViewModel.append(uvcOptionViewModelLocal)
                                            }
                                        }
                                    }
                                }
                            } else if objectName == "UDCDocument" {
                                let databaseOrmUDCDocumentSearch: DatabaseOrmResult<UDCDocument>?
                                //                                if searchPhase == 1 {
                                //                                    databaseOrmUDCDocumentSearch = try UDCDocument.get(text: documentGraphItemSearchRequest.text, limitedTo: 0, sortedBy: "name", udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
                                //                                } else {
                                databaseOrmUDCDocumentSearch = try UDCDocument.search(collectionName: "UDCDocument", text: documentGraphItemSearchRequest.text,  limitedTo: 0, sortedBy: "name", udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
                                //                                }
                                if databaseOrmUDCDocumentSearch!.databaseOrmError.count == 0 {
                                    let udcDocument = databaseOrmUDCDocumentSearch!.object[0]
                                    for udcd in databaseOrmUDCDocumentSearch!.object {
                                        var uvcOptionViewModelLocal = UVCOptionViewModel()
                                        uvcOptionViewModelLocal = UVCOptionViewModel()
                                        uvcOptionViewModelLocal.objectDocumentIdName = udcd._id
                                        uvcOptionViewModelLocal.objectIdName = udcd._id
                                        uvcOptionViewModelLocal.objectName = "UDCDocument"
                                        uvcOptionViewModelLocal.parentId.append(udcDocumentItemMapNodeSub.parentId[0])
                                        uvcOptionViewModelLocal.pathIdName.append(["UDCDocumentItemMapNode.DocumentItems"])
                                        uvcOptionViewModelLocal.pathIdName[0].append(udcDocument.idName)
                                        uvcOptionViewModelLocal.level = 1
                                        uvcOptionViewModelLocal.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: udcd.name, description: "", category: stringUtility.capitalCaseToArray(capitalCaseText: String(udcd.udcDocumentTypeIdName.split(separator: ".")[1])).joined(separator: " "), subCategory: "", language: documentLanguage, isChildrenExist: false, isEditable: false, isCheckBox: false, photoId: nil, photoObjectName: objectName)
                                        uvcOptionViewModelLocal.uvcViewModel.rowLength = 2
                                        uvcOptionViewModel.append(uvcOptionViewModelLocal)
                                    }
                                }
                            } else if objectName == "UDCDocumentItem" {
                                print("\(udcDocumentItemMapNodeSub.name): \(udcDocumentItemMapNodeSub._id)")
                                if udcDocumentItemMapNodeSub.idName == "UDCDocumentItemMapNode.FoodRecipeButton" {
                                    print("")
                                }
                                // If it is not the matching document then ignore this item
                                if !udcDocumentItemMapNodeSub.udcDocumentId.isEmpty && documentGraphItemSearchRequest.documentId != udcDocumentItemMapNodeSub.udcDocumentId {
                                    continue
                                }
                                let databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: documentId, language: documentLanguage)
                                if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
                                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocument.databaseOrmError[0].name, description: databaseOrmResultUDCDocument.databaseOrmError[0].description))
                                    return
                                }
                                let udcDocument = databaseOrmResultUDCDocument.object[0]
                                let databaseOrmUDCDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: collectionName, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocument.udcDocumentGraphModelId, language: documentLanguage) as DatabaseOrmResult<UDCDocumentGraphModel>
                                if databaseOrmUDCDocumentGraphModel.databaseOrmError.count == 0 {
                                    let udcDocumentItem = databaseOrmUDCDocumentGraphModel.object[0]
                                    var category = ""
                                    var subCategory = ""
                                    var path = [[String]]()
                                    path.append([udcDocumentItem.name])
                                    try getDocumentItemOptions(collectionName: collectionName, text: documentGraphItemSearchRequest.text, documentItemId: udcDocumentItem.childrenId, uvcOptionViewModel: &uvcOptionViewModel, udcDocumentTypeIdName: documentGraphItemSearchRequest.udcDocumentTypeIdName, objectName: objectName, optionItemId: documentGraphItemSearchRequest.optionItemId, path: &path, pathIdName: ["UDCDocumentItemMapNode.DocumentItems"], category: &category, subCategory: &subCategory, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, documentLanguage: documentLanguage, documentId: documentId, searchPhase: searchPhase)
                                }
                            }
                        }
                    }
                    
                }
                //                print("\(udcDocumentItemMapNode.name): \(udcDocumentItemMapNode.idName)")
                //                if documentGraphItemSearchRequest.isByCategory {
                //                    if udcDocumentItemMapNode.name.lowercased().contains(documentGraphItemSearchRequest.text) {
                //                        let _ = try search(text: documentGraphItemSearchRequest.text, udcDocumentItemMapNode: udcDocumentItemMapNode, uvcOptionViewModel: &uvcOptionViewModel, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, documentGraphItemSearchRequest: documentGraphItemSearchRequest, searchPhase: searchPhase)
                //                    }
                //                } else {
                //                    let _ = try search(text: documentGraphItemSearchRequest.text, udcDocumentItemMapNode: udcDocumentItemMapNode, uvcOptionViewModel: &uvcOptionViewModel, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, documentGraphItemSearchRequest: documentGraphItemSearchRequest, searchPhase: searchPhase)
                //                }
                //                if udcDocumentItemMapNode.childrenId.count > 0 {
                //                    try searchDocumentItem(children: udcDocumentItemMapNode.childrenId, uvcOptionViewModel: &uvcOptionViewModel, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, documentGraphItemSearchRequest: documentGraphItemSearchRequest, searchPhase: searchPhase)
                //                }
            }
        }
    }
    
    private func getDocumentItemOptions(collectionName: String, text: String, documentItemId: [String], uvcOptionViewModel: inout [UVCOptionViewModel], udcDocumentTypeIdName: String, objectName: String, optionItemId: String, path: inout [[String]], pathIdName: [String], category: inout String, subCategory: inout String, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest, documentLanguage: String, documentId: String, searchPhase: Int) throws {
        // Search starting from the root node, if any text found in children node
        var databaseOrmUDCDocumentGraphModelSearch: DatabaseOrmResult<UDCDocumentGraphModel>?
        //        if searchPhase == 1 {
        //            databaseOrmUDCDocumentGraphModelSearch = try UDCDocumentGraphModel.get(collectionName: collectionName, text: text, limitedTo: 0, sortedBy: "name", udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage, _id: documentItemId)
        //        } else {
        databaseOrmUDCDocumentGraphModelSearch = try UDCDocumentGraphModel.search(collectionName: collectionName, text: text, limitedTo: 0, sortedBy: "name", udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage, _id: documentItemId)
        //        }
        if databaseOrmUDCDocumentGraphModelSearch!.databaseOrmError.count  == 0 {
            let udcPhotoDocumentSearch = databaseOrmUDCDocumentGraphModelSearch!.object
            for udcpd in udcPhotoDocumentSearch {
                var uvcOptionViewModelLocal = UVCOptionViewModel()
                var photoId: String?
                photoId = udcpd.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].itemId.isEmpty ? nil : udcpd._id
                let nameSplit = documentParser.splitDocumentItem(udcSentencePatternDataGroupValueParam: udcpd.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue, language: documentLanguage)
                for (nameIndex, name) in nameSplit.enumerated() {
                    path[0].append(String(name))
                    if photoId != nil {
                        var photoObjectName: String?
                        // Photo version
                        photoObjectName = "\(objectName)Photo"
                        uvcOptionViewModelLocal.objectDocumentIdName = documentId
                        uvcOptionViewModelLocal.objectIdName = udcpd._id
                        uvcOptionViewModelLocal.objectName = photoObjectName!
                        uvcOptionViewModelLocal.parentId.append(optionItemId)
                        uvcOptionViewModelLocal.pathIdName.append(pathIdName)
                        uvcOptionViewModelLocal.pathIdName[0].append(udcpd.idName)
                        uvcOptionViewModelLocal.level = 1
                        uvcOptionViewModelLocal.objectNameIndex = nameIndex
                        if path[0].count > 2 {
                            subCategory = path[0][path[0].count - 2]
                            category = path[0][path[0].count - 3]
                        } else {
                            category = path[0][path[0].count - 2]
                        }
                        uvcOptionViewModelLocal.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: name, description: "", category: category.capitalized, subCategory: subCategory, language: documentLanguage, isChildrenExist: false, isEditable: false, isCheckBox: false, photoId: photoId, photoObjectName: photoObjectName)
                        uvcOptionViewModelLocal.uvcViewModel.rowLength = 2
                        uvcOptionViewModel.append(uvcOptionViewModelLocal)
                    }
                    // Text version
                    uvcOptionViewModelLocal = UVCOptionViewModel()
                    uvcOptionViewModelLocal.objectDocumentIdName = documentId
                    uvcOptionViewModelLocal.objectIdName = udcpd._id
                    uvcOptionViewModelLocal.objectName = objectName
                    uvcOptionViewModelLocal.objectNameIndex = nameIndex
                    uvcOptionViewModelLocal.parentId.append(optionItemId)
                    uvcOptionViewModelLocal.pathIdName.append(pathIdName)
                    uvcOptionViewModelLocal.pathIdName[0].append(udcpd.idName)
                    uvcOptionViewModelLocal.level = 1
                    if path[0].count > 2 {
                        subCategory = path[0][path[0].count - 2]
                        category = path[0][path[0].count - 3]
                    } else {
                        category = path[0][path[0].count - 2]
                    }
                    uvcOptionViewModelLocal.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: name, description: "", category: category.capitalized, subCategory: subCategory, language: documentLanguage, isChildrenExist: false, isEditable: false, isCheckBox: false, photoId: nil, photoObjectName: objectName)
                    uvcOptionViewModelLocal.uvcViewModel.rowLength = 2
                    uvcOptionViewModel.append(uvcOptionViewModelLocal)
                    path[0].remove(at: path[0].count - 1)
                }
            }
        }
        //        if searchPhase == 1 && uvcOptionViewModel.count > 0 {
        //            return
        //        }
        // Also try to search in the childrens children nodes, if any found
        for id in documentItemId {
            let databaseOrmUDCDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: collectionName, udbcDatabaseOrm: udbcDatabaseOrm!, id: id)
            if databaseOrmUDCDocumentGraphModel.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentGraphModel.databaseOrmError[0].name, description: databaseOrmUDCDocumentGraphModel.databaseOrmError[0].description))
                return
            }
            let udcPhotoDocument = databaseOrmUDCDocumentGraphModel.object[0]
            if udcPhotoDocument.childrenId.count > 0 {
                path[0].append(udcPhotoDocument.name)
                try getDocumentItemOptions(collectionName: collectionName, text: text, documentItemId: udcPhotoDocument.childrenId, uvcOptionViewModel: &uvcOptionViewModel, udcDocumentTypeIdName: udcDocumentTypeIdName, objectName: objectName, optionItemId: optionItemId, path: &path, pathIdName: pathIdName, category: &category, subCategory: &subCategory, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, documentLanguage: documentLanguage, documentId: documentId, searchPhase: searchPhase)
                path[0].remove(at: path[0].count - 1)
            }
        }
        
    }
    
    
    
//    private func searchPhotoItem(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
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
//    }
//    
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
    
    private func search(text: String, udcDocumentItemMapNode: UDCDocumentItemMapNode, uvcOptionViewModel: inout [UVCOptionViewModel], neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest, documentGraphItemSearchRequest: DocumentGraphItemSearchRequest, searchPhase: Int) throws -> Bool {
        let documentLanguage = documentGraphItemSearchRequest.documentLanguage
        var searchResult = false
        
        if udcDocumentItemMapNode.idName == "UDCDocumentItemMapNode.UserWordDictionary" && !documentGraphItemSearchRequest.isBySubCategory {
            searchResult = true
            var databaseOrmResultType : DatabaseOrmResult<UDCUserWordDictionary>?
            if searchPhase == 1 {
                databaseOrmResultType = UDCUserWordDictionary.getOne(text, udbcDatabaseOrm!, documentLanguage)
            } else if documentGraphItemSearchRequest.isByCategory {
                databaseOrmResultType = UDCUserWordDictionary.get(limitedTo: 0, sortedBy: "word", udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
            } else {
                databaseOrmResultType = try UDCUserWordDictionary.search(text: text, udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
            }
            if databaseOrmResultType!.databaseOrmError.count == 0 {
                for udci in databaseOrmResultType!.object {
                    let uvcOptionViewModelLocal = UVCOptionViewModel()
                    uvcOptionViewModelLocal.objectIdName = udci.idName
                    uvcOptionViewModelLocal.parentId.append(documentGraphItemSearchRequest.optionItemId)
                    uvcOptionViewModelLocal.objectName = udcDocumentItemMapNode.objectName
                    uvcOptionViewModelLocal.pathIdName.append(["UDCDocumentItemMapNode.DocumentItems"])
                    uvcOptionViewModelLocal.pathIdName[0].append(udci.idName)
                    uvcOptionViewModelLocal.level = 1
                    uvcOptionViewModelLocal.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: udci.word, description: "", category: udcDocumentItemMapNode.name.capitalized, subCategory: "", language: documentLanguage, isChildrenExist: false, isEditable: false, isCheckBox: false, photoId: nil, photoObjectName: nil)
                    uvcOptionViewModelLocal.uvcViewModel.rowLength = 2
                    uvcOptionViewModel.append(uvcOptionViewModelLocal)
                }
            }
        } else if udcDocumentItemMapNode.objectName == "UDCPhotoDocument" {
            searchResult = true
            let databaseOrmUDCDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphItemSearchRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, idName: udcDocumentItemMapNode.objectId[0], language: documentLanguage) as DatabaseOrmResult<UDCDocumentGraphModel>
            if databaseOrmUDCDocumentGraphModel.databaseOrmError.count == 0 {
                let udcPhotoDocument = databaseOrmUDCDocumentGraphModel.object[0]
                var category = ""
                var subCategory = ""
                getPhotoDocumentOptions(text: text, photoDocumentId: udcPhotoDocument.childrenId, uvcOptionViewModel: &uvcOptionViewModel, udcDocumentTypeIdName: documentGraphItemSearchRequest.udcDocumentTypeIdName, optionItemId: documentGraphItemSearchRequest.optionItemId, pathIdName: ["UDCDocumentItemMapNode.DocumentItems"], category: &category, subCategory: &subCategory, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, documentLanguage: documentLanguage)
                
            }
        }
        
        return searchResult
    }
    
    private func getEditObjectName(idName: String) -> String {
        if idName == "UDCDocumentItemMapNode.UserWordDictionary" {
            return "UDCUserWordDictionary"
        } else if idName == "UDCDocumentItemMapNode.Photo" {
            return "UDCPhoto"
        }
        
        
        
        return ""
    }
    
    private func getPhotoDocumentOptions(text: String, photoDocumentId: [String], uvcOptionViewModel: inout [UVCOptionViewModel], udcDocumentTypeIdName: String, optionItemId: String, pathIdName: [String], category: inout String, subCategory: inout String, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest, documentLanguage: String) {
        for id in photoDocumentId {
            let databaseOrmUDCDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, idName: id, language: documentLanguage) as DatabaseOrmResult<UDCDocumentGraphModel>
            if databaseOrmUDCDocumentGraphModel.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentGraphModel.databaseOrmError[0].name, description: databaseOrmUDCDocumentGraphModel.databaseOrmError[0].description))
                return
            }
            let udcPhotoDocument = databaseOrmUDCDocumentGraphModel.object[0]
            if udcPhotoDocument.name.contains(text) {
                let uvcOptionViewModelLocal = UVCOptionViewModel()
                let photoId = udcPhotoDocument.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].itemId
                let photoObjectName = udcDocumentTypeIdName.components(separatedBy: ".")[0]
                uvcOptionViewModelLocal.objectIdName = photoId
                uvcOptionViewModelLocal.objectName = photoObjectName
                uvcOptionViewModelLocal.parentId.append(optionItemId)
                uvcOptionViewModelLocal.pathIdName.append(pathIdName)
                uvcOptionViewModelLocal.pathIdName[0].append(udcPhotoDocument.idName)
                uvcOptionViewModelLocal.level = 1
                uvcOptionViewModelLocal.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: udcPhotoDocument.name, description: "", category: category.capitalized, subCategory: subCategory, language: documentLanguage, isChildrenExist: false, isEditable: false, isCheckBox: false, photoId: photoId, photoObjectName: photoObjectName)
                uvcOptionViewModelLocal.uvcViewModel.rowLength = 2
                uvcOptionViewModel.append(uvcOptionViewModelLocal)
            }
            if !category.isEmpty {
                subCategory = category
            }
            category = udcPhotoDocument.name
            if udcPhotoDocument.childrenId.count > 0 {
                getPhotoDocumentOptions(text: text, photoDocumentId: udcPhotoDocument.childrenId, uvcOptionViewModel: &uvcOptionViewModel, udcDocumentTypeIdName: udcDocumentTypeIdName, optionItemId: optionItemId, pathIdName: pathIdName, category: &category, subCategory: &subCategory, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, documentLanguage: documentLanguage)
            }
        }
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
        neuronRequestLocal.neuronSource.name = DocumentItemNeuron.getName()
        neuronRequestLocal.neuronSource.type = DocumentItemNeuron.getName();
        neuronRequestLocal.neuronOperation.name = neuronRequest.neuronOperation.name
        neuronRequestLocal.neuronOperation.parent = true
        neuronRequestLocal.neuronOperation.neuronData.text = neuronRequest.neuronOperation.neuronData.text
        neuronRequestLocal.neuronTarget.name =  neuronName
        
        neuronUtility!.callNeuron(neuronRequest: neuronRequestLocal)
        
        let neuronResponseLocal = getChildResponse(sourceId: neuronRequestLocal.neuronSource._id)
        
        if neuronResponseLocal.neuronOperation.neuronOperationStatus.neuronOperationError!.count > 0 {
            print("\(DocumentItemNeuron.getName()) Errors from child neuron: \(neuronRequest.neuronOperation.name))")
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
            print("\(DocumentItemNeuron.getName()) Success from child neuron: \(neuronRequest.neuronOperation.name))")
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
    //                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: RecipeNeuronErrorType.ErrorInProcessingView.name, description: RecipeNeuronErrorType.ErrorInProcessingView.description))
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
    ////            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: RecipeNeuronErrorType.ErrorInProcessingView.name, description: RecipeNeuronErrorType.ErrorInProcessingView.description))
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
        //                                print(path); neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: RecipeNeuronErrorType.DataPathNotFound.name, description: RecipeNeuronErrorType.DataPathNotFound.description))
        //                                return false
        //                            }
        //
        //
        //                                let databaseOrmResultJsonType = UDCJsonType.get("UDCJsonType.Number", udbcDatabaseOrm!, language)
        //
        //                            if databaseOrmResultJsonType.object.count == 0 {
        //                                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: RecipeNeuronErrorType.TypeNotFound.name, description: RecipeNeuronErrorType.TypeNotFound.description))
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
        //                                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: RecipeNeuronErrorType.TypeNotFound.name, description: RecipeNeuronErrorType.TypeNotFound.description))
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
        //                                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: RecipeNeuronErrorType.TypeNotFound.name, description: RecipeNeuronErrorType.TypeNotFound.description))
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
        //                                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: RecipeNeuronErrorType.TypeNotFound.name, description: RecipeNeuronErrorType.TypeNotFound.description))
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
        //                                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: RecipeNeuronErrorType.TypeNotFound.name, description: RecipeNeuronErrorType.TypeNotFound.description))
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
        //                                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: RecipeNeuronErrorType.TypeNotFound.name, description: RecipeNeuronErrorType.TypeNotFound.description))
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
        //                                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: RecipeNeuronErrorType.TypeNotFound.name, description: RecipeNeuronErrorType.TypeNotFound.description))
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
        //                                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: RecipeNeuronErrorType.TypeNotFound.name, description: RecipeNeuronErrorType.TypeNotFound.description))
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
        //                                 neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: RecipeNeuronErrorType.TypeNotFound.name, description: RecipeNeuronErrorType.TypeNotFound.description))
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
        //                                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: RecipeNeuronErrorType.TypeNotFound.name, description: RecipeNeuronErrorType.TypeNotFound.description))
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
        //                                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: RecipeNeuronErrorType.TypeNotFound.name, description: RecipeNeuronErrorType.TypeNotFound.description))
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
        //                             neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: RecipeNeuronErrorType.TypeNotFound.name, description: RecipeNeuronErrorType.TypeNotFound.description))
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
        //                                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: RecipeNeuronErrorType.TypeNotFound.name, description: RecipeNeuronErrorType.TypeNotFound.description))
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
        //                            neuronResponse = neuronUtility!.getNeuronResponseError(neuronRequest: neuronRequest, errorName: RecipeNeuronErrorType.ErrorInProcessingView.name, errorDescription:  RecipeNeuronErrorType.ErrorInProcessingView.description)
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
        //                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: RecipeNeuronErrorType.TypeNotFound.name, description: RecipeNeuronErrorType.TypeNotFound.description))
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
        return "DocumentItemNeuron"
    }
    
    static public func getDescription() -> String {
        return "Document Item Neuron"
    }
    
    static public func getDendrite(sourceId: String) -> (Neuron) {
        var neuron: Neuron?
        
        serialQueue.sync {
            print("Before: \(dendriteMap.debugDescription)")
            neuron = dendriteMap[sourceId]
            if neuron == nil {
                print("\(getName()): Created: \(sourceId)")
                dendriteMap[sourceId] = DocumentItemNeuron()
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
    
    private static func removeDendrite(sourceId: String) {
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
                print("\(DocumentItemNeuron.getName()) Parent show setting child to true")
                neuronResponse.neuronOperation.child = true
            }
            
            var neuronRequestLocal = neuronRequest
            
            
            self.neuronUtility!.setUDBCDatabaseOrm(udbcDatabaseOrm: udbcDatabaseOrm, neuronName: DocumentItemNeuron.getName())
            
            documentParser.setNeuronUtility(neuronUtility: self.neuronUtility!,  neuronName: DocumentItemNeuron.getName())
            documentParser.setUDBCDatabaseOrm(udbcDatabaseOrm: udbcDatabaseOrm, neuronName: DocumentItemNeuron.getName())
            
            let continueProcess = try preProcess(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            if continueProcess == false {
                print("\(DocumentItemNeuron.getName()): don't process return")
                return
            }
            
            validateRequest(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            
            if neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError!.count > 0 {
                print("\(DocumentItemNeuron.getName()) error in validation return")
                let neuronSource = self.neuronUtility!.getDendrite(sourceId: neuronRequest.neuronSource._id, neuronName: neuronRequest.neuronSource.name)
                neuronSource!.setDendrite(neuronRequest: neuronResponse, udbcDatabaseOrm: self.udbcDatabaseOrm!, neuronUtility: self.neuronUtility!)
                return
            }
            
            
            
            // Controller says no need to
            
            neuronResponse.neuronOperation.acknowledgement = false
            
            if neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError!.count == 0 {
                if neuronRequest.neuronOperation.asynchronus == true {
                    print("\(DocumentItemNeuron.getName()) asynchronus store the request and return")
                    neuronResponse.neuronOperation.response = true
                    neuronResponse.neuronOperation.neuronData.text = ""
                    self.neuronUtility!.storeInDatabase(neuronRequest: neuronRequest)
                    return
                } else {
                    if neuronRequest.neuronOperation.synchronus == true {
                        if neuronRequest.neuronOperation.asynchronusProcess == true {
                            print("\(DocumentItemNeuron.getName()) asynchronus so update the status as pending")
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
            print("\(DocumentItemNeuron.getName()): Error thrown in setdendrite: \(error)")
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
        print("\(DocumentItemNeuron.getName()): pre process")
        
        print("neuronUtility: pre process: \(neuronRequest.neuronSource._id)")
        let neuronRequestLocal: NeuronRequest = neuronRequest
        
        if neuronRequestLocal.neuronOperation.acknowledgement == true {
            print("\(DocumentItemNeuron.getName()) acknowledgement so return")
            return false
        }
        
        if neuronRequestLocal.neuronOperation.response == true {
            setChildResponse(sourceId: neuronRequestLocal.neuronSource._id, neuronRequest: neuronRequest)
            print("\(DocumentItemNeuron.getName()) response so return")
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
            print("\(DocumentItemNeuron.getName()) got response so return")
            return false
        }
        
        return true
    }
    
    private func postProcess(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) {
        print("\(DocumentItemNeuron.getName()): post process")
        
        
        
        do {
            if neuronRequest.neuronOperation.asynchronusProcess == true {
                print("\(DocumentItemNeuron.getName()) Asynchronus so storing response in database")
                neuronResponse.neuronOperation.neuronOperationStatus.status = NeuronOperationStatusType.Completed.name
                //                let rows = try NeuronRequest.update(udbcDatabaseOrm: udbcDatabaseOrm!, id: (neuronRequest._id), status: NeuronOperationStatusType.Completed.name)
                //                neuronUtility!.storeInDatabase(neuronRequest: neuronResponse)
                
            }
            print("\(DocumentItemNeuron.getName()) Informing: \(String(describing: neuronRequest.neuronSource.name))")
            let neuronSource = neuronUtility!.getDendrite(sourceId: neuronRequest.neuronSource._id, neuronName: neuronRequest.neuronSource.name)
            neuronSource!.setDendrite(neuronRequest: neuronResponse, udbcDatabaseOrm: self.udbcDatabaseOrm!, neuronUtility: self.neuronUtility!)
            
        } catch {
            print(error)
            print("\(DocumentItemNeuron.getName()): Error thrown in post process: \(error)")
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: NeuronOperationErrorType.ErrorInProcessing.name, description: error.localizedDescription))
        }
        
        defer {
            DocumentItemNeuron.removeDendrite(sourceId: neuronRequest.neuronSource._id)
            print("Recipe Neuron  RESPONSE MAP: \(responseMap)")
            print("Recipe Neuron  Dendrite MAP: \(DocumentItemNeuron.dendriteMap)")
        }
        
    }
}
