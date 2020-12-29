//
//  GrammarNeuron.swift
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
import UDocsNeuronModel
import UDocsNeuronUtility
import UDocsDatabaseModel
import UDocsViewModel
import UDocsViewUtility
import UDocsDocumentModel
import UDocsGrammarNeuronModel


public class GrammarNeuron : Neuron {
    
    public static func getRootResponse(neuronSourceId: String) -> NeuronRequest {
        return NeuronRequest()
    }
    
    var neuronUtility: NeuronUtility? = nil
    var udbcDatabaseOrm: UDBCDatabaseOrm?
    static var dendriteMap: [String : Neuron] = [String : Neuron]()
    private var responseMap: [String : NeuronRequest] = [String : NeuronRequest]()
    static let serialQueue = DispatchQueue(label: "SerialQueue")
    
    
    
    static public func getName() -> String {
        return "GrammarNeuron"
    }
    
    static public func getDescription() -> String {
        return "Grammar Neuron"
    }
    
    static public func getDendrite(sourceId: String) -> (Neuron) {
        var neuron: Neuron?
        
        serialQueue.sync {
            print("Before: \(dendriteMap.debugDescription)")
            neuron = dendriteMap[sourceId]
            if neuron == nil {
                print("\(getName()): Created: \(sourceId)")
                dendriteMap[sourceId] = GrammarNeuron()
                neuron = dendriteMap[sourceId]
            }
            print("After creation: \(dendriteMap.debugDescription)")
        }
        
        return  neuron!;
    }
    
    
    
    private func setChildResponse(operationId: String, neuronRequest: NeuronRequest) {
        responseMap[operationId] = neuronRequest
    }
    
    public func getChildResponse(operationId: String) -> NeuronRequest {
        var neuronResponse: NeuronRequest?
        print(responseMap)
        if let _ = responseMap[operationId] {
            neuronResponse = responseMap[operationId]
            responseMap.removeValue(forKey: operationId)
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
        var neuronResponse =  NeuronRequest()
        do {
            self.udbcDatabaseOrm = udbcDatabaseOrm
            
            self.neuronUtility = neuronUtility
            
            if neuronRequest.neuronOperation.parent == true {
                print("\(GrammarNeuron.getName()) Parent show setting child to true")
                neuronResponse.neuronOperation.child = true
            }
            
            var neuronRequestLocal = neuronRequest
            
            if neuronResponse.neuronOperation._id.isEmpty {
                neuronResponse.neuronOperation._id = try udbcDatabaseOrm.generateId()
            }
            
            self.neuronUtility!.setUDBCDatabaseOrm(udbcDatabaseOrm: udbcDatabaseOrm, neuronName: GrammarNeuron.getName())
            
            
            let continueProcess = try preProcess(neuronRequest: neuronRequestLocal, neuronResponse: &neuronResponse)
            if continueProcess == false {
                print("\(GrammarNeuron.getName()): don't process return")
                return
            }
            
            validateRequest(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            
            if neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError!.count > 0 {
                print("\(GrammarNeuron.getName()) error in validation return")
                let neuronSource = self.neuronUtility!.getDendrite(sourceId: neuronRequest.neuronSource._id, neuronName: neuronRequest.neuronSource.name)
                neuronSource!.setDendrite(neuronRequest: neuronResponse, udbcDatabaseOrm: self.udbcDatabaseOrm!, neuronUtility: self.neuronUtility!)
                return
            }
            
            
            
            // Controller says no need to
            
            neuronResponse.neuronOperation.acknowledgement = false
            
            if neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError!.count == 0 {
                if neuronRequest.neuronOperation.asynchronus == true {
                    print("\(GrammarNeuron.getName()) asynchronus store the request and return")
                    neuronResponse.neuronOperation.response = true
                    neuronResponse.neuronOperation.neuronData.text = ""
                    self.neuronUtility!.storeInDatabase(neuronRequest: neuronRequest)
                    return
                } else {
                    if neuronRequest.neuronOperation.synchronus == true {
                        if neuronRequest.neuronOperation.asynchronusProcess == true {
                            print("\(GrammarNeuron.getName()) asynchronus so update the status as pending")
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
            print("\(GrammarNeuron.getName()): Error thrown in setdendrite: \(error)")
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
        print("\(GrammarNeuron.getName()): pre process")
        neuronResponse.neuronSource._id = neuronRequest.neuronSource._id
        
        print("neuronUtility: pre process: \(neuronRequest.neuronSource._id)")
        let neuronRequestLocal: NeuronRequest = neuronRequest
        
        if neuronRequestLocal.neuronOperation.acknowledgement == true {
            print("\(GrammarNeuron.getName()) acknowledgement so return")
            return false
        }
        
        if neuronRequestLocal.neuronOperation.response == true {
            setChildResponse(operationId: neuronRequestLocal.neuronOperation.name, neuronRequest: neuronRequest)
            print("\(GrammarNeuron.getName()) response so return")
            return false
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
            print("\(GrammarNeuron.getName()) got response so return")
            return false
        }
        
        return true
    }
    
    private func process(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        neuronResponse.neuronOperation.response = true
        if neuronRequest.neuronOperation.name == "GrammarNeuron.Sentence.Generate" {
            generateSentence(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else if neuronRequest.neuronOperation.name == "GrammarNeuron.Search.GrammarItem" {
            try searchGrammarItem(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        }
    }
    
    private func searchGrammarItem(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let grammarItemSearchRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: GrammarItemSearchRequest())
        
        let documentLanguage = grammarItemSearchRequest.documentLanguage
        
        var uvcOptionViewModel = [UVCOptionViewModel]()
        
        let databaseOrmResultUDCDocumentItemMap = UDCDocumentItemMap.get(udbcDatabaseOrm: udbcDatabaseOrm!, name: "UDCDocumentItemMap.GrammarItems", language: documentLanguage)
        if databaseOrmResultUDCDocumentItemMap.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentItemMap.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentItemMap.databaseOrmError[0].description))
            return
        }
        let udcDocumentItemMap = databaseOrmResultUDCDocumentItemMap.object[0]
        
        for chidren in udcDocumentItemMap.udcDocumentItemMapNodeId {
            let databaseOrmResultUDCDocumentItemMapNode = UDCDocumentItemMapNode.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: chidren, language: documentLanguage)
            if databaseOrmResultUDCDocumentItemMapNode.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentItemMapNode.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentItemMapNode.databaseOrmError[0].description))
                return
            }
            let udcDocumentItemMapNode = databaseOrmResultUDCDocumentItemMapNode.object[0]
            if grammarItemSearchRequest.isByCategory {
                if udcDocumentItemMapNode.name.lowercased().contains(grammarItemSearchRequest.text) {
                    let _ = try search(text: grammarItemSearchRequest.text, inObject: udcDocumentItemMapNode.objectName, category: udcDocumentItemMapNode.name, uvcOptionViewModel: &uvcOptionViewModel, selectedOption: grammarItemSearchRequest.selectedOption, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, grammarItemSearchRequest: grammarItemSearchRequest)
                }
            } else {
                let _ = try search(text: grammarItemSearchRequest.text, inObject: udcDocumentItemMapNode.objectName, category: udcDocumentItemMapNode.name, uvcOptionViewModel: &uvcOptionViewModel, selectedOption: grammarItemSearchRequest.selectedOption, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, grammarItemSearchRequest: grammarItemSearchRequest)
                break // Grammar Item all childs have same object
            }
            
        }
        
        let grammarItemSearchResponse = GrammarItemSearchResponse()
        grammarItemSearchResponse.uvcOptionViewModel = uvcOptionViewModel
        
        let jsonUtilityGrammarItemSearchResponse = JsonUtility<GrammarItemSearchResponse>()
        let jsonGrammarItemSearchResponse = jsonUtilityGrammarItemSearchResponse.convertAnyObjectToJson(jsonObject: grammarItemSearchResponse)
        
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonGrammarItemSearchResponse)
    }
    
    private func search(text: String, inObject: String, category: String, uvcOptionViewModel: inout [UVCOptionViewModel], selectedOption: UVCOptionViewModel, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest, grammarItemSearchRequest: GrammarItemSearchRequest) throws -> Bool {
        let documentLanguage = grammarItemSearchRequest.documentLanguage
        var searchResult = false
        let uvcViewGenerator = UVCViewGenerator()
        
        var databaseOrmResultType: DatabaseOrmResult<UDCGrammarItemType>?
        if grammarItemSearchRequest.isByCategory || grammarItemSearchRequest.isBySubCategory {
            databaseOrmResultType = UDCGrammarItemType.get(limitedTo: 0, sortedBy: "name", category: "", udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
        } else {
            databaseOrmResultType = try UDCGrammarItemType.search(text: text, udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
        }
        
        if databaseOrmResultType!.databaseOrmError.count == 0 {
            searchResult = true
            for udgi in databaseOrmResultType!.object {
                var categoryNameArray = [String]()
                for udcgcidn in udgi.udcGrammarCategoryIdName {
                    let databaseOrmResultUDCGrammarCategoryType = UDCGrammarCategoryType.get(udcgcidn, udbcDatabaseOrm!, documentLanguage)
                    if databaseOrmResultUDCGrammarCategoryType.databaseOrmError.count > 0 {
                        for databaseError in databaseOrmResultUDCGrammarCategoryType.databaseOrmError {
                            neuronResponse = neuronUtility!.getNeuronResponseError(neuronRequest: neuronRequest, errorName: databaseError.name, errorDescription:  databaseError.description)
                        }
                        return searchResult
                    }
                    categoryNameArray.append(databaseOrmResultUDCGrammarCategoryType.object[0].name)
                }
                if grammarItemSearchRequest.isByCategory && grammarItemSearchRequest.isIncludeGrammar {
                    if !category.contains(categoryNameArray.joined(separator: ", ")) {
                        continue
                    }
                }
                let subCategory = categoryNameArray.joined(separator: ", ")
                if grammarItemSearchRequest.isBySubCategory && !subCategory.lowercased().contains(grammarItemSearchRequest.text) {
                    continue
                }
                let uvcOptionViewModelLocal = UVCOptionViewModel()
                uvcOptionViewModelLocal.idName = udgi.idName
                uvcOptionViewModelLocal.objectIdName = udgi.idName
                uvcOptionViewModelLocal.parentId.append(selectedOption._id)
                uvcOptionViewModelLocal.objectName = inObject
                uvcOptionViewModelLocal.pathIdName.append(["UDCDocumentItemMapNode.DocumentItems"])
                uvcOptionViewModelLocal.pathIdName.append([udgi.idName])
                uvcOptionViewModelLocal.level = 1
                uvcOptionViewModelLocal.objectCategoryIdName = categoryNameArray[0]
                uvcOptionViewModelLocal.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: udgi.name, description: "", category: category.capitalized, subCategory: subCategory, language: documentLanguage, isChildrenExist: false, isEditable: false, isCheckBox: false, photoId: nil, photoObjectName: nil)
                uvcOptionViewModelLocal.uvcViewModel.rowLength = 3
                uvcOptionViewModel.append(uvcOptionViewModelLocal)
            }
        }
        
        return searchResult
    }
    
    private func generateSentence(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) {
        let sentenceRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: SentenceRequest())
        let jsonUtility = JsonUtility<SentenceRequest>()
        print("sentence request: \(jsonUtility.convertAnyObjectToJson(jsonObject: sentenceRequest))")
        let sentenceResponse = generateSentenceByCombining(sentenceRequest: sentenceRequest, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        let jsonUtilityResponse = JsonUtility<SentenceResponse>()
        let text = jsonUtilityResponse.convertAnyObjectToJson(jsonObject: sentenceResponse)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: text)
    }
    
    private func generateSentenceByCombining(sentenceRequest: SentenceRequest, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) -> SentenceResponse {
        let sentenceResponse = SentenceResponse()
        sentenceResponse.udcSentencePattern.language = sentenceRequest.documentLanguage
//        copyInput(udcSentencePatternIn: sentenceRequest.udcSentencePattern, udcSentencePatternOut: &sentenceResponse.udcSentencePattern)
        let jsonUtility = JsonUtility<SentenceResponse>()
        print("sentence response: \(jsonUtility.convertAnyObjectToJson(jsonObject: sentenceResponse))")
        var wordList = [String]()
        
        // Loop through data request
        for (indexSentencePatternData, udcSentencePatternData) in sentenceRequest.udcSentencePattern.udcSentencePatternData.enumerated() {
            sentenceResponse.udcSentencePattern.udcSentencePatternData.append(UDCSentencePatternData())
            // Loop through data group
            for (indexSentencePatternDataGroup, udcSentencePatternDataGroup) in udcSentencePatternData.udcSentencePatternDataGroup.enumerated() {
                sentenceResponse.udcSentencePattern.udcSentencePatternData[indexSentencePatternData].udcSentencePatternDataGroup.append(UDCSentencePatternDataGroup())
                // Loop through values and group the words
                for  (indexSentencePatternDataGroupValue, udcSentencePatternDataGroupValue) in udcSentencePatternDataGroup.udcSentencePatternDataGroupValue.enumerated() {
                    
                    var word = ""
                    if (udcSentencePatternDataGroupValue.udcSentencePattern?.udcSentencePatternData != nil) && (udcSentencePatternDataGroupValue.udcSentencePattern?.udcSentencePatternData.count)! > 0 {
                        // Send the send request child recursively
                        let sentenceRequestLocal = SentenceRequest()
                        sentenceRequestLocal.udcSentencePattern = udcSentencePatternDataGroupValue.udcSentencePattern!
                      
                        
                        let sentenceResponseLocal = generateSentenceByCombining(sentenceRequest: sentenceRequestLocal, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
                        word = sentenceResponseLocal.udcSentencePattern.sentence
                        
                        sentenceResponse.udcSentencePattern.udcSentencePatternData[indexSentencePatternData].udcSentencePatternDataGroup[indexSentencePatternDataGroup].udcSentencePatternDataGroupValue.append(udcSentencePatternDataGroupValue)
                        
                        let lastIndex = sentenceResponse.udcSentencePattern.udcSentencePatternData[indexSentencePatternData].udcSentencePatternDataGroup[indexSentencePatternDataGroup].udcSentencePatternDataGroupValue.count - 1
                        sentenceResponse.udcSentencePattern.udcSentencePatternData[indexSentencePatternData].udcSentencePatternDataGroup[indexSentencePatternDataGroup].udcSentencePatternDataGroupValue[lastIndex].udcSentencePattern = udcSentencePatternDataGroupValue.udcSentencePattern!
                        // Add child patterns to the data group value response
                    } else {
                        if udcSentencePatternDataGroupValue.itemId == "UDCMathematicalItem.RealNumber" && sentenceRequest.newSentence {
                            if sentenceRequest.wordIndex > 0 && indexSentencePatternDataGroupValue == sentenceRequest.wordIndex {
                                word = "0.0"
                            } else if sentenceRequest.wordIndex == 0 {
                                word = "0.0"
                            } else {
                                word = udcSentencePatternDataGroupValue.item!
                            }
                        } else if udcSentencePatternDataGroupValue.itemId == "UDCMathematicalItem.Integer" &&
                            sentenceRequest.newSentence {
                            if sentenceRequest.wordIndex > 0 && indexSentencePatternDataGroupValue == sentenceRequest.wordIndex {
                                word = "0"
                            } else if sentenceRequest.wordIndex == 0 {
                                word = "0"
                            } else {
                                word = udcSentencePatternDataGroupValue.item!
                            }
                        } else if udcSentencePatternDataGroupValue.category == "UDCGrammarCategory.ProperNoun" {
                            word = udcSentencePatternDataGroupValue.item!.capitalized
                        } else {
                            word = udcSentencePatternDataGroupValue.item!
                        }
                       if indexSentencePatternDataGroupValue == sentenceRequest.textStartIndex {
                           word = word.capitalized
                       }

                           sentenceResponse.udcSentencePattern.udcSentencePatternData[indexSentencePatternData].udcSentencePatternDataGroup[indexSentencePatternDataGroup].udcSentencePatternDataGroupValue.append(udcSentencePatternDataGroupValue)
                        
                        let lastIndex = sentenceResponse.udcSentencePattern.udcSentencePatternData[indexSentencePatternData].udcSentencePatternDataGroup[indexSentencePatternDataGroup].udcSentencePatternDataGroupValue.count - 1
                        
                        if word != udcSentencePatternDataGroupValue.item! {
                            sentenceResponse.udcSentencePattern.udcSentencePatternData[indexSentencePatternData].udcSentencePatternDataGroup[indexSentencePatternDataGroup].udcSentencePatternDataGroupValue[lastIndex].item = word
                        }
                        
                    }
                    if udcSentencePatternDataGroupValue.uvcViewItemType != "UVCViewItemType.Photo" && (indexSentencePatternDataGroupValue >= sentenceRequest.textStartIndex || sentenceRequest.textStartIndex == -1) {
                        wordList.append(word)
                    }
                }
            }
        }
        let sentence = wordList.joined(separator: " ")
        
        sentenceResponse.udcSentencePattern.sentence = sentence
        let jsonUtilityr = JsonUtility<SentenceResponse>()
        print("Final: sentence Response: \(jsonUtilityr.convertAnyObjectToJson(jsonObject: sentenceResponse))")
        return sentenceResponse
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
    
    
    private func postProcess(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) {
        print("\(GrammarNeuron.getName()): post process")
        
        
        
        if neuronRequest.neuronOperation.asynchronusProcess == true {
            print("\(GrammarNeuron.getName()) Asynchronus so storing response in database")
            neuronResponse.neuronOperation.neuronOperationStatus.status = NeuronOperationStatusType.Completed.name
            let databaseOrmResultUpdate = NeuronRequest.update(udbcDatabaseOrm: udbcDatabaseOrm!, id: (neuronRequest._id), status: NeuronOperationStatusType.Completed.name)
            if databaseOrmResultUpdate.databaseOrmError.count > 0 {
                for databaseError in databaseOrmResultUpdate.databaseOrmError {
                    neuronResponse = neuronUtility!.getNeuronResponseError(neuronRequest: neuronRequest, errorName: databaseError.name, errorDescription:  databaseError.description)
                }
            }
            let databaseOrmResultStoreInDatabase = neuronUtility!.storeInDatabase(neuronRequest: neuronResponse)
            if databaseOrmResultUpdate.databaseOrmError.count > 0 {
                for databaseError in databaseOrmResultUpdate.databaseOrmError {
                    neuronResponse = neuronUtility!.getNeuronResponseError(neuronRequest: neuronRequest, errorName: databaseError.name, errorDescription:  databaseError.description)
                }
            }
            
        }
        print("\(GrammarNeuron.getName()) Informing: \(String(describing: neuronRequest.neuronSource.name))")
        let neuronSource = neuronUtility!.getDendrite(sourceId: neuronRequest.neuronSource._id, neuronName: neuronRequest.neuronSource.name)
        neuronSource!.setDendrite(neuronRequest: neuronResponse, udbcDatabaseOrm: self.udbcDatabaseOrm!, neuronUtility: self.neuronUtility!)
        
        
        
        defer {
            GrammarNeuron.removeDendrite(sourceId: neuronRequest.neuronSource._id)
        }
        
    }
}
