//
//  DocumentGraphNeuron.swift
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
import UDocsNeuronModel
import UDocsNeuronUtility
import UDocsDocumentModel
import UDocsDocumentUtility
import UDocsViewModel
import UDocsViewUtility
import UDocsDocumentGraphNeuronModel
import UDocsGrammarNeuronModel
import UDocsPhotoNeuronModel
import UDocsDocumentMapNeuronModel
import UDocsProfileModel
import UDocsOptionMapNeuronModel
import UDocsDocumentItemNeuronModel

extension Character {
    var isUpperCase: Bool { return String(self) == String(self).uppercased() }
}

extension String  {
    var isNumber: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
}

public class DocumentGraphNeuron : Neuron {
    public static func getRootResponse(neuronSourceId: String) -> NeuronRequest {
        return NeuronRequest()
    }
    var neuronUtility: NeuronUtility?
    let uvcViewGenerator = UVCViewGenerator()
    let stringUtility = StringUtility()
    let documentParser = DocumentParser()
    let documentItemConfigurationUtility = DocumentItemConfigurationUtility()
    var udbcDatabaseOrm: UDBCDatabaseOrm?
    static var dendriteMap: [String : Neuron] = [String : Neuron]()
    private var responseMap: [String : NeuronRequest] = [String : NeuronRequest]()
    static let serialQueue = DispatchQueue(label: "SerialQueue")
    
    static public func getName() -> String {
        return "DocumentGraphNeuron"
    }
    
    static public func getDescription() -> String {
        return "Document Graph Neuron"
    }
    
    static public func getDendrite(sourceId: String) -> (Neuron) {
        var neuron: Neuron?
        
        serialQueue.sync {
            print("Before: \(dendriteMap.debugDescription)")
            neuron = dendriteMap[sourceId]
            if neuron == nil {
                print("\(getName()): Created: \(sourceId)")
                dendriteMap[sourceId] = DocumentGraphNeuron()
                neuron = dendriteMap[sourceId]
            }
            print("After creation: \(dendriteMap.debugDescription)")
        }
        
        return  neuron!;
    }
    
    
    
    private  func setChildResponse(sourceId: String, neuronRequest: NeuronRequest) {
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
    
//    private func getDendrite(type: NeuronUtility.Type, sourceId: String, neuronName: String) -> Neuron {
//        return type.getDendrite(sourceId: sourceId, neuronName: sourceId)
//    }
    
    public func setDendrite(neuronRequest: NeuronRequest, udbcDatabaseOrm: UDBCDatabaseOrm,  neuronUtility: NeuronUtility) {
        var neuronResponse = NeuronRequest()
        do {
            self.udbcDatabaseOrm = udbcDatabaseOrm
            
            self.neuronUtility = neuronUtility
            
            if neuronRequest.neuronOperation.parent == true {
                print("\(DocumentGraphNeuron.getName()) Parent show setting child to true")
                neuronResponse.neuronOperation.child = true
            }
            
            if neuronResponse.neuronOperation._id.isEmpty {
                neuronResponse.neuronOperation._id = try udbcDatabaseOrm.generateId()
            }
            
            var neuronRequestLocal = neuronRequest
            
            
            self.neuronUtility!.setUDBCDatabaseOrm(udbcDatabaseOrm: udbcDatabaseOrm, neuronName: DocumentGraphNeuron.getName())
            self.neuronUtility!.setUNCMain( neuronName: DocumentGraphNeuron.getName())
            documentParser.setNeuronUtility(neuronUtility: self.neuronUtility!,  neuronName: DocumentGraphNeuron.getName())
            documentParser.setUDBCDatabaseOrm(udbcDatabaseOrm: udbcDatabaseOrm, neuronName: DocumentGraphNeuron.getName())
            documentItemConfigurationUtility.setNeuronUtility(neuronUtility: self.neuronUtility!, neuronName: DocumentGraphNeuron.getName())
            documentItemConfigurationUtility.setUDBCDatabaseOrm(udbcDatabaseOrm: udbcDatabaseOrm, neuronName: DocumentGraphNeuron.getName())
            
            let continueProcess = try preProcess(neuronRequest: neuronRequestLocal, neuronResponse: &neuronResponse)
            if continueProcess == false {
                print("\(DocumentGraphNeuron.getName()): don't process return")
                return
            }
            
            validateRequest(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            
            if neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError!.count > 0 {
                print("\(DocumentGraphNeuron.getName()) error in validation return")
                let neuronSource = self.neuronUtility!.getDendrite(sourceId: neuronRequest.neuronSource._id, neuronName: neuronRequest.neuronSource.name)
                neuronSource!.setDendrite(neuronRequest: neuronResponse, udbcDatabaseOrm: self.udbcDatabaseOrm!, neuronUtility: self.neuronUtility!)
                return
            }
            
            // Controller says no need to
            
            neuronResponse.neuronOperation.acknowledgement = false
            
            if neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError!.count == 0 {
                if neuronRequest.neuronOperation.asynchronus == true {
                    print("\(DocumentGraphNeuron.getName()) asynchronus store the request and return")
                    neuronResponse.neuronOperation.response = true
                    neuronResponse.neuronOperation.neuronData.text = ""
                    self.neuronUtility!.storeInDatabase(neuronRequest: neuronRequest)
                    return
                } else {
                    if neuronRequest.neuronOperation.synchronus == true {
                        if neuronRequest.neuronOperation.asynchronusProcess == true {
                            print("\(DocumentGraphNeuron.getName()) asynchronus so update the status as pending")
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
            print("\(DocumentGraphNeuron.getName()): Error thrown in setdendrite: \(error)")
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
        print("\(DocumentGraphNeuron.getName()): pre process")
        neuronResponse.neuronSource._id = neuronRequest.neuronSource._id
        
        print("neuronUtility: pre process: \(neuronRequest.neuronSource._id)")
        let neuronRequestLocal: NeuronRequest = neuronRequest
        
        if neuronRequestLocal.neuronOperation.acknowledgement == true {
            print("\(DocumentGraphNeuron.getName()) acknowledgement so return")
            return false
        }
        
        if neuronRequestLocal.neuronOperation.response == true {
            setChildResponse(sourceId: neuronRequestLocal.neuronSource._id, neuronRequest: neuronRequest)
            print("\(DocumentGraphNeuron.getName()) response so return")
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
            print("\(DocumentGraphNeuron.getName()) got response so return")
            return false
        }
        
        return true
    }
    
    private func process(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        neuronResponse.neuronOperation.response = true
        
        if neuronRequest.neuronOperation.name == "DocumentMapNeuron.DocumentMap.Get.ByPath" {
            try getDocumentMapByPath(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else if neuronRequest.neuronOperation.name == "OptionMapNeuron.OptionMap.Get.SearchOption" ||
            neuronRequest.neuronOperation.name == "OptionMapNeuron.OptionMap.Get.DocumentMapOptions" ||
            neuronRequest.neuronOperation.name == "OptionMapNeuron.OptionMap.Get.InterfaceOptions"  ||  neuronRequest.neuronOperation.name == "OptionMapNeuron.OptionMap.Get.DocumentOptions" {
            try getOptionMap(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.New" {
            try documentNew(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.User.SentencePattern.Add" {
            //            try userSentencePatternAdd(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.Item.Insert" {
            try documentInsertItem(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.Item.Change" {
            try documentChangeItem(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.Item.Delete" {
            try documentDeleteItem(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.Item.Reference" {
            try documentItemReference(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.Insert.NewLine" {
            try documentInsertNewLine(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.Delete.Line" {
            try documentDeleteLine(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Get.ViewController.View" {
            try getObjectControllerView(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Get.View.Configuration.Options" {
            try getViewConfigurationOptions(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.Category.Selected" {
            try categorySelected(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.Category.Options.Selected" {
            try categoryOptionsSelected(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.Add.To.Favourite" {
            try documentAddToFavourite(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.Delete" {
            try documentDelete(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.Get.InterfacePhoto" {
            try documentGetInterfacePhoto(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.Get.View" {
//            let getDocumentGraphViewRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: GetDocumentGraphViewRequest())
//            try putReferenceForDocumentTypes(documentType: ["UDCDocumentType.DocumentMap","UDCDocumentType.FoodRecipe", "UDCDocumentType.DocumentItemConfiguration", "UDCDocumentType.Ingredient", "UDCDocumentType.HumanProfile", "UDCDocumentType.EmailProfile", "UDCDocumentType.Cuisine", "UDCDocumentType.Button"], udcProfile: getDocumentGraphViewRequest.udcProfile, language: "en", neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
////            let udcDocumentItem = try getDocumentModel(udcDocumentGraphModelIdName: "UDCDocumentItem.DocumentItems", language: "en", udcDocumentTypeIdName: "UDCDocumentType.DocumentItem", isLanguageChild: false, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
////
//            if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
//                return
//            }
//            try mapDocumentTitleinDocumentItemEntries(childrenId: udcDocumentItem!.childrenId, udcProfile: getDocumentGraphViewRequest.udcProfile, language: "en", udcDocumentTypeIdName: "UDCDocumentType.DocumentItem", neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
//            let documentGraphDeleteRequest = DocumentGraphDeleteRequest()
//            documentGraphDeleteRequest.udcProfile = getDocumentGraphViewRequest.udcProfile
//            documentGraphDeleteRequest.udcDocumentId = "5ebfa5ed36430370aa0560f4"
//            documentGraphDeleteRequest.documentLanguage = "en"
//            documentGraphDeleteRequest.interfaceLanguage = "en"
//            documentGraphDeleteRequest.udcDocumentTypeIdName = "UDCDocumentType.HumanProfile"
//            let jsonUtilityDocumentGraphDeleteRequest = JsonUtility<DocumentGraphDeleteRequest>()
//            let neuronRequestLocal = NeuronRequest()
//            neuronRequestLocal.neuronSource._id = neuronRequest.neuronSource._id
//            neuronRequestLocal.neuronOperation.synchronus = true
//            neuronRequestLocal.neuronOperation._id = neuronRequest.neuronOperation._id
//            neuronRequestLocal.neuronSource.name = DocumentGraphNeuron.getName()
//            neuronRequestLocal.neuronSource.type = DocumentGraphNeuron.getName();
//            neuronRequestLocal.neuronOperation.name = "DocumentGraphNeuron.Document.Delete"
//            neuronRequestLocal.neuronOperation.parent = true
//            neuronRequestLocal.neuronOperation.neuronData.text = jsonUtilityDocumentGraphDeleteRequest.convertAnyObjectToJson(jsonObject: documentGraphDeleteRequest)
//            var neuronResponseLocal = NeuronRequest()
//            try documentDelete(neuronRequest: neuronRequestLocal, neuronResponse: &neuronResponseLocal)
//
//                        let neuronRequestLocal = NeuronRequest()
//                        neuronRequestLocal.neuronSource._id = neuronRequest.neuronSource._id
//                        neuronRequestLocal.neuronOperation.synchronus = true
//                        neuronRequestLocal.neuronOperation._id = neuronRequest.neuronOperation._id
//                        neuronRequestLocal.neuronSource.name = DocumentGraphNeuron.getName()
//                        neuronRequestLocal.neuronSource.type = DocumentGraphNeuron.getName();
//                        neuronRequestLocal.neuronOperation.name = "DocumentMapNeuron.DocumentMapNode.Add"
//                        neuronRequestLocal.neuronOperation.parent = true
//                        let createDocumentTypeRequest = CreateDocumentTypeRequest()
//                        createDocumentTypeRequest.isKnowledgeAvailable = false
//                        var createDocumentTypeData = CreateDocumentTypeData()
//                        createDocumentTypeData.name = "gregorian calendar"
//                        createDocumentTypeData.language = "en"
//                        createDocumentTypeRequest.createDocumentTypeData.append(createDocumentTypeData)
//                        createDocumentTypeData = CreateDocumentTypeData()
//                        createDocumentTypeData.name = "கிரேக்க நாட்காட்டி"
//                        createDocumentTypeData.language = "ta"
//                        createDocumentTypeRequest.createDocumentTypeData.append(createDocumentTypeData)
//                        createDocumentTypeRequest.udcProfile = getDocumentGraphViewRequest.udcProfile
//                        let jsonUtilityAddDocumentMapNodeRequest = JsonUtility<CreateDocumentTypeRequest>()
//                        neuronRequestLocal.neuronOperation.neuronData.text = jsonUtilityAddDocumentMapNodeRequest.convertAnyObjectToJson(jsonObject: createDocumentTypeRequest)
//                        var neuronResponseLocal = NeuronRequest()
//                        try createDocumentType(neuronRequest: neuronRequestLocal, neuronResponse: &neuronResponseLocal)
//                        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponseLocal) {
//                            print("Error in create document type: \(neuronResponseLocal.neuronOperation.neuronOperationStatus.neuronOperationError![0].description)")
//                        }
            
            //            var englishIdName: String = ""
            //            var englishName: String = ""
            //            var udcDocumentTypeIdName: String = ""
            //            var documentTypeNameEnglish: String = ""
            //            try createWordDictionaryForDocumentType(udcProfile: getDocumentGraphViewRequest.udcProfile, documentTypeName: "time unit", documentTypeNameEnglish: &documentTypeNameEnglish, englishIdName: &englishIdName, englishName: &englishName, language: "en", neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            //            try createWordDictionaryForDocumentType(udcProfile: getDocumentGraphViewRequest.udcProfile, documentTypeName: "நேர அலகு", documentTypeNameEnglish: &documentTypeNameEnglish, englishIdName: &englishIdName, englishName: &englishName, language: "ta", neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            //            try createWordDictionaryForDocumentType(udcProfile: getDocumentGraphViewRequest.udcProfile, documentTypeName: "document item configuration", documentTypeNameEnglish: &documentTypeNameEnglish, englishIdName: &englishIdName, englishName: &englishName, language: "en", neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            //            try createWordDictionaryForDocumentType(udcProfile: getDocumentGraphViewRequest.udcProfile, documentTypeName: "ஆவண உருப்படி கட்டமைப்பு", documentTypeNameEnglish: &documentTypeNameEnglish, englishIdName: &englishIdName, englishName: &englishName, language: "ta", neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            //            try createWordDictionaryForDocumentType(udcProfile: getDocumentGraphViewRequest.udcProfile, documentTypeName: "food recipe", documentTypeNameEnglish: &documentTypeNameEnglish, englishIdName: &englishIdName, englishName: &englishName, language: "en", neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            //            try createWordDictionaryForDocumentType(udcProfile: getDocumentGraphViewRequest.udcProfile, documentTypeName: "உணவு செய்முறை", documentTypeNameEnglish: &documentTypeNameEnglish, englishIdName: &englishIdName, englishName: &englishName, language: "ta", neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            //            try createWordDictionaryForDocumentType(udcProfile: getDocumentGraphViewRequest.udcProfile, documentTypeName: "email profile", documentTypeNameEnglish: &documentTypeNameEnglish, englishIdName: &englishIdName, englishName: &englishName, language: "en", neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            //            try createWordDictionaryForDocumentType(udcProfile: getDocumentGraphViewRequest.udcProfile, documentTypeName: "மின்னஞ்சல் சுயவிவரம்", documentTypeNameEnglish: &documentTypeNameEnglish, englishIdName: &englishIdName, englishName: &englishName, language: "ta", neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            //            try createWordDictionaryForDocumentType(udcProfile: getDocumentGraphViewRequest.udcProfile, documentTypeName: "human profile", documentTypeNameEnglish: &documentTypeNameEnglish, englishIdName: &englishIdName, englishName: &englishName, language: "en", neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            //            try createWordDictionaryForDocumentType(udcProfile: getDocumentGraphViewRequest.udcProfile, documentTypeName: "மனித சுயவிவரம்", documentTypeNameEnglish: &documentTypeNameEnglish, englishIdName: &englishIdName, englishName: &englishName, language: "ta", neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            //            try createWordDictionaryForDocumentType(udcProfile: getDocumentGraphViewRequest.udcProfile, documentTypeName: "ingredient", documentTypeNameEnglish: &documentTypeNameEnglish, englishIdName: &englishIdName, englishName: &englishName, language: "en", neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            //            try createWordDictionaryForDocumentType(udcProfile: getDocumentGraphViewRequest.udcProfile, documentTypeName: "மூலப்பொருள்", documentTypeNameEnglish: &documentTypeNameEnglish, englishIdName: &englishIdName, englishName: &englishName, language: "ta", neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
//                       try createDocumentMapDynamic(udcDocumentTypeIdName: "UDCDocumentType.DocumentItem", udcProfile: getDocumentGraphViewRequest.udcProfile, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            //                      try createDocumentMapDynamic(udcDocumentTypeIdName: "UDCDocumentType.DocumentItemConfiguration", udcProfile: getDocumentGraphViewRequest.udcProfile, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            //                      try createDocumentMapDynamic(udcDocumentTypeIdName: "UDCDocumentType.FoodRecipe", udcProfile: getDocumentGraphViewRequest.udcProfile, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            //                      try createDocumentMapDynamic(udcDocumentTypeIdName: "UDCDocumentType.HumanProfile", udcProfile: getDocumentGraphViewRequest.udcProfile, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            //                      try createDocumentMapDynamic(udcDocumentTypeIdName: "UDCDocumentType.EmailProfile", udcProfile: getDocumentGraphViewRequest.udcProfile, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            //                      try createDocumentMapDynamic(udcDocumentTypeIdName: "UDCDocumentType.Ingredient", udcProfile: getDocumentGraphViewRequest.udcProfile, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            //                      try createDocumentMapDynamic(udcDocumentTypeIdName: "UDCDocumentType.DocumentMap", udcProfile: getDocumentGraphViewRequest.udcProfile, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            //            let udcSentencePattern = UDCSentencePattern()
            //            let udcSentencePatternData = UDCSentencePatternData()
            //            udcSentencePattern.udcSentencePatternData.append(udcSentencePatternData)
            //            let udcSentencePatternDataGroup = UDCSentencePatternDataGroup()
            //            udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup.append(udcSentencePatternDataGroup)
            //            var udcSentencePatternDataGroupValue = UDCSentencePatternDataGroupValue()
            //            udcSentencePatternDataGroupValue.item = "part1"
            //            udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.append(udcSentencePatternDataGroupValue)
            //            udcSentencePatternDataGroupValue = UDCSentencePatternDataGroupValue()
            //            udcSentencePatternDataGroupValue.itemIdName = "UDCDocumentItem.DocumentItemSeparator"
            //            udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.append(udcSentencePatternDataGroupValue)
            //            udcSentencePatternDataGroupValue = UDCSentencePatternDataGroupValue()
            //            udcSentencePatternDataGroupValue.item = ""
            //            udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.append(udcSentencePatternDataGroupValue)
            //            udcSentencePatternDataGroupValue = UDCSentencePatternDataGroupValue()
            //            udcSentencePatternDataGroupValue.itemIdName = "UDCDocumentItem.DocumentItemSeparator"
            //            udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.append(udcSentencePatternDataGroupValue)
            //            udcSentencePatternDataGroupValue = UDCSentencePatternDataGroupValue()
            //            udcSentencePatternDataGroupValue.item = "part3"
            //            udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.append(udcSentencePatternDataGroupValue)
            //            let splited = splitDocumentItem(udcSentencePattern: udcSentencePattern, language: "en")
            //            print("Splitted: \(splited)")
            
            try documentGetView(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            
        }
        
        //
        //        let fileUtility = FileUtility()
        //        fileUtility.writeFile(fileName: "UniverseDocs.json", contents: neuronResponse.neuronOperation.neuronData.text)
        
    }
    
    private func putReferenceForDocumentTypes(documentType: [String], udcProfile: [UDCProfile], language: String, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        for type in documentType {
            let databaseOrmResultUdcDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, udcProfile: udcProfile, udcDocumentTypeIdName: type)
            if databaseOrmResultUdcDocument.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUdcDocument.databaseOrmError[0].name, description: databaseOrmResultUdcDocument.databaseOrmError[0].description))
                return
            }
            let udcDocumentArray = databaseOrmResultUdcDocument.object
            for udcDocument in udcDocumentArray {
                print("Processing reference: \(udcDocument.idName)")
                if udcDocument.idName.hasSuffix(".Blank") {
                    continue
                }
                let udcDocumentGraphModel = try getDocumentModel(udcDocumentGraphModelId: udcDocument.udcDocumentGraphModelId, udcDocumentTypeIdName: udcDocument.udcDocumentTypeIdName, isLanguageChild: true, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
                if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
                    return
                }
                try putReferenceForChild(children: udcDocumentGraphModel!.childrenId, documentId: udcDocument._id, udcDocumentTypeIdName: udcDocument.udcDocumentTypeIdName, udcProfile: udcProfile, language: language, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            }
        }
    }
    
    private func putReferenceForChild(children: [String], documentId: String, udcDocumentTypeIdName: String, udcProfile: [UDCProfile], language: String, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        for child in children {
            let udcDocumentGraphModelChild = try getDocumentModel(udcDocumentGraphModelId: child, udcDocumentTypeIdName: udcDocumentTypeIdName, isLanguageChild: true, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            for udcspdgv in udcDocumentGraphModelChild!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue {
                if !udcspdgv.udcDocumentId.isEmpty && udcspdgv.itemIdName.hasPrefix("UDCDocumentItem.") {
                    try putReference(udcDocumentId: documentId, udcDocumentGraphModelId: udcspdgv.itemId, udcDocumentTypeIdName: "UDCDocumentType.DocumentItem", objectUdcDocumentTypeIdName: udcDocumentTypeIdName, objectId: udcDocumentGraphModelChild!._id, objectName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!, documentLanguage: language, udcProfile: udcProfile, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
                }
            }
            if udcDocumentGraphModelChild!.childrenId.count > 0 {
                try putReferenceForChild(children: udcDocumentGraphModelChild!.childrenId, documentId: documentId, udcDocumentTypeIdName: udcDocumentTypeIdName, udcProfile: udcProfile, language: language, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            }
        }
    }
    
    private func mapDocumentTitleinDocumentItemEntries(childrenId: [String], udcProfile: [UDCProfile], language: String, udcDocumentTypeIdName: String, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        
        var found = false
        for childId in childrenId {
            let udcDocumentItemChild = try getDocumentModel(udcDocumentGraphModelId: childId, udcDocumentTypeIdName: udcDocumentTypeIdName, isLanguageChild: false, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
                return
            }
            if udcDocumentItemChild!.childrenId.count > 0 {
                try mapDocumentTitleinDocumentItemEntries(childrenId: udcDocumentItemChild!.childrenId, udcProfile: udcProfile, language: language, udcDocumentTypeIdName: udcDocumentTypeIdName, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
                continue
            }
            let documentIdName = udcDocumentItemChild?.idName.replacingOccurrences(of: "UDCDocumentItem", with: "UDCDocument")
            let databaseOrmResultUdcDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, udcProfile: udcProfile, udcDocumentTypeIdName: udcDocumentTypeIdName, idName: documentIdName!, language: language)
            if databaseOrmResultUdcDocument.databaseOrmError.count > 0 {
                continue
            }
            let udcDocument = databaseOrmResultUdcDocument.object[0]
            let udcDocumentItemLanguage = try getDocumentModelWithParent(udcDocumentGraphModelId: udcDocument.udcDocumentGraphModelId, udcDocumentTypeIdName: udcDocumentTypeIdName, isLanguageChild: true, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
                return
            }
            if udcDocumentItemLanguage!.count == 2 {
                for (udcspdgvIndex, udcspdgv) in udcDocumentItemChild!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.enumerated() {
                    if udcspdgv.item!.lowercased() == udcDocumentItemLanguage![1].name.lowercased() && udcspdgv.uvcViewItemType == "UVCViewItemType.Text" {
                        found = true
                        udcDocumentItemChild!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].udcDocumentId = udcDocument._id
                        udcDocumentItemChild!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].itemId = udcDocumentItemLanguage![1]._id
                        udcDocumentItemChild!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].itemIdName = udcDocumentItemLanguage![1].idName
                        udcDocumentItemChild!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].endCategoryId = udcDocumentItemLanguage![0]._id
                        udcDocumentItemChild!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].endCategoryIdName = udcDocumentItemLanguage![0].idName
                        udcDocumentItemChild!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].endSubCategoryId = ""
                        udcDocumentItemChild!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].endSubCategoryIdName = udcDocument.udcDocumentTypeIdName
                    }
                }
                if found {
                    let databaseOrmResultDocumentItemUpdate = UDCDocumentGraphModel.update(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentItemChild!)
                    //                if databaseOrmResultDocumentItemUpdate.databaseOrmError.count > 0 {
                    //                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultDocumentItemUpdate.databaseOrmError[0].name, description: databaseOrmResultDocumentItemUpdate.databaseOrmError[0].description))
                    //                    return
                    //                }
                }
                found = false
                if !udcDocumentItemChild!.documentMapObjectId.isEmpty {
                    let udcDocumentItemMap = try getDocumentModel(udcDocumentId: udcDocumentItemChild!.documentMapObjectId, idName: "", udcDocumentTypeIdName: "UDCDocumentType.DocumentMap", udcProfile: udcProfile, documentLanguage: language, isLanguageChild: false, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
                    if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
                        return
                    }
                    try mapDocumentTitleinDocumentMapEntries(documentMapObjectId: [udcDocumentItemMap!._id], udcProfile: udcProfile, language: language, udcDocument: udcDocument, udcDocumentItemLanguage: udcDocumentItemLanguage!, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
                }
            }
            
        }
    }
    
    private func mapDocumentTitleinDocumentMapEntries(documentMapObjectId: [String], udcProfile: [UDCProfile], language: String, udcDocument: UDCDocument, udcDocumentItemLanguage: [UDCDocumentGraphModel]?, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        for child in documentMapObjectId {
            let udcDocumentItemMap = try getDocumentModel(udcDocumentGraphModelId: child, udcDocumentTypeIdName: "UDCDocumentType.DocumentMap", isLanguageChild: false, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
                return
            }
            var found = false
            for (udcspdgvIndex, udcspdgv) in udcDocumentItemMap!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.enumerated() {
                if udcspdgv.item!.lowercased() == udcDocumentItemLanguage![1].name.lowercased() && udcspdgv.uvcViewItemType == "UVCViewItemType.Text" {
                    found = true
                    udcDocumentItemMap!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].udcDocumentId = udcDocument._id
                    udcDocumentItemMap!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].itemId = udcDocumentItemLanguage![1]._id
                    udcDocumentItemMap!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].itemIdName = udcDocumentItemLanguage![1].idName
                    udcDocumentItemMap!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].endCategoryId = udcDocumentItemLanguage![0]._id
                    udcDocumentItemMap!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].endCategoryIdName = udcDocumentItemLanguage![0].idName
                    udcDocumentItemMap!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].endSubCategoryId = ""
                    udcDocumentItemMap!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].endSubCategoryIdName = udcDocument.udcDocumentTypeIdName
                }
            }
            if found {
                let databaseOrmResultDocumentItemMapUpdate = UDCDocumentGraphModel.update(collectionName: "UDCDocumentMap", udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentItemMap)
//                if databaseOrmResultDocumentItemMapUpdate.databaseOrmError.count > 0 {
//                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultDocumentItemMapUpdate.databaseOrmError[0].name, description: databaseOrmResultDocumentItemMapUpdate.databaseOrmError[0].description))
//                    return
//                }
            }
            if udcDocumentItemMap!.childrenId.count > 0 {
                try mapDocumentTitleinDocumentMapEntries(documentMapObjectId: udcDocumentItemMap!.childrenId, udcProfile: udcProfile, language: language, udcDocument: udcDocument, udcDocumentItemLanguage: udcDocumentItemLanguage!, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            }
        }
    }
    // Form the actual sentence as per Grammar rules, based on the sentence pattern
       private func processGrammar(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest, udcSentencePattern: UDCSentencePattern, newSentence: Bool, wordIndex: Int, sentenceIndex: Int, documentLanguage: String, textStartIndex: Int) throws -> UDCSentencePattern {
           let neuronRequestLocal = NeuronRequest()
           neuronRequestLocal.neuronSource._id = neuronRequest.neuronSource._id
           neuronRequestLocal.neuronOperation.synchronus = true
           neuronRequestLocal.neuronOperation._id = neuronRequest.neuronOperation._id
           neuronRequestLocal.neuronSource.name = DocumentGraphNeuron.getName()
           neuronRequestLocal.neuronSource.type = DocumentGraphNeuron.getName();
           neuronRequestLocal.neuronOperation.name = "GrammarNeuron.Sentence.Generate"
           neuronRequestLocal.neuronOperation.parent = true
           let sentenceRequest = SentenceRequest()
           sentenceRequest.udcSentencePattern = udcSentencePattern
           sentenceRequest.newSentence = newSentence
           sentenceRequest.wordIndex = wordIndex
           sentenceRequest.sentenceIndex = sentenceIndex
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
    
    private func getDocumentIdName(getDocumentGraphIdNameRequest: GetDocumentGraphIdNameRequest, getDocumentGraphIdNameResponse: inout GetDocumentGraphIdNameResponse, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        
        
        
        //        if getDocumentGraphIdNameRequest.udcDocumentGraphModel.level <= 1 {
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
            if getDocumentGraphIdNameRequest.udcDocumentGraphModel.isChildrenAllowed {
                getDocumentGraphIdNameResponse.idName = "\(neuronUtility!.getCollectionName(udcDocumentTypeIdName: getDocumentGraphIdNameRequest.udcDocumentTypeIdName)!).\(getDocumentGraphIdNameRequest.udcDocumentGraphModel.udcSentencePattern.sentence.capitalized.replacingOccurrences(of: " ", with: ""))"
            }
        }
        if getDocumentGraphIdNameResponse.idName == "\(neuronUtility!.getCollectionName(udcDocumentTypeIdName: getDocumentGraphIdNameRequest.udcDocumentTypeIdName)!)." &&  getDocumentGraphIdNameRequest.udcDocumentGraphModel.isChildrenAllowed {
            let generatedId = NSUUID().uuidString
            getDocumentGraphIdNameResponse.idName = "\(untitltedIdNamePrefix)-\(generatedId)"
            getDocumentGraphIdNameResponse.name = "\(name).\(generatedId)"
        }
        //
        //        } else {
        //            getDocumentGraphIdNameResponse.name = getDocumentGraphIdNameRequest.udcDocumentGraphModel.name
        //        }
        
        let jsonUtilityGetDocumentGraphIdNameResponse = JsonUtility<GetDocumentGraphIdNameResponse>()
        let jsonValidateGetDocumentGraphIdNameResponse = jsonUtilityGetDocumentGraphIdNameResponse.convertAnyObjectToJson(jsonObject: getDocumentGraphIdNameResponse)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonValidateGetDocumentGraphIdNameResponse)
    }
    
    private func createDocumentMapDynamic(udcDocumentTypeIdName: String, udcProfile: [UDCProfile], neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, udcProfile: udcProfile, udcDocumentTypeIdName: udcDocumentTypeIdName)
        if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocument.databaseOrmError[0].name, description: databaseOrmResultUDCDocument.databaseOrmError[0].description))
            return
        }
        let udcDocument = databaseOrmResultUDCDocument.object
        for udcd in udcDocument {
            try documentGraphModelReference(parentPathIdName: "UDCOptionMap.DocumentMap->\(udcd.udcDocumentTypeIdName)", itemIdName: "UDCOptionMapNode.Recents", udcDocumentId: udcd._id, udcProfile: udcProfile, udcDocumentTypeIdName: udcd.udcDocumentTypeIdName, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, documentLanguage: udcd.language)
            try documentGraphModelReference(parentPathIdName: "UDCOptionMap.DocumentMap->UDCDocumentType.DocumentItem->UDCOptionMapNode.Library", itemIdName: "UDCDocumentMapNode.All", udcDocumentId: udcd._id, udcProfile: udcProfile, udcDocumentTypeIdName: udcd.udcDocumentTypeIdName, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, documentLanguage: udcd.language)
        }
    }
    
    
    private func callNeuron(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest, operationName: String, udcDocumentTypeIdName: String) throws -> Bool {
        var called = false
        let neuronRequestLocal = NeuronRequest()
        neuronRequestLocal.neuronSource._id = neuronRequest.neuronSource._id
        neuronRequestLocal.neuronOperation.synchronus = true
        neuronRequestLocal.neuronOperation._id = neuronRequest.neuronOperation._id
        neuronRequestLocal.neuronSource.name = DocumentGraphNeuron.getName()
        neuronRequestLocal.neuronSource.type = DocumentGraphNeuron.getName();
        neuronRequestLocal.neuronOperation.name = operationName
        neuronRequestLocal.neuronOperation.parent = true
        neuronRequestLocal.neuronOperation.neuronData.text = neuronRequest.neuronOperation.neuronData.text
        let neuronName = neuronUtility!.getNeuronName(udcDocumentTypeIdName: udcDocumentTypeIdName)
        if neuronName == nil {
            return false
        }
        neuronRequestLocal.neuronTarget.name = neuronName!
        called = neuronUtility!.callNeuron(neuronRequest: neuronRequestLocal, udcDocumentTypeIdName: udcDocumentTypeIdName)
        
        let neuronResponseLocal = getChildResponse(sourceId: neuronRequestLocal.neuronSource._id)
        
        if neuronResponseLocal.neuronOperation.neuronOperationStatus.neuronOperationError!.count > 0 {
            print("\(DocumentGraphNeuron.getName()) Errors from child neuron: \(neuronRequestLocal.neuronOperation.name))")
            neuronResponse.neuronOperation.response = true
            for noe in neuronResponseLocal.neuronOperation.neuronOperationStatus.neuronOperationError! {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(noe)
            }
        } else {
            for noe in neuronResponseLocal.neuronOperation.neuronOperationStatus.neuronOperationSuccess! {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationSuccess?.append(noe)
            }
            print("\(DocumentGraphNeuron.getName()) Success from child neuron: \(neuronRequest.neuronOperation.name))")
            neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequestLocal, responseText: neuronResponseLocal.neuronOperation.neuronData.text)
        }
        
        
        //        let jsonUtilityDocumentGraphNeuronResponse = JsonUtility<GetDocumentResponse>()
        //        if !neuronResponseLocal.neuronOperation.neuronData.text.isEmpty {
        //            let documentResponse = jsonUtilityDocumentGraphNeuronResponse.convertJsonToAnyObject(json: neuronResponseLocal.neuronOperation.neuronData.text)
        //            let json = jsonUtilityDocumentGraphNeuronResponse.convertAnyObjectToJson(jsonObject: documentResponse)
        //            neuronResponse.neuronOperation.neuronData.text = json
        //        }
        
        return called
    }
    
    private func generateDocumentItemViewForChange(generateDocumentItemViewForChangeRequest: GenerateDocumentItemViewForChangeRequest, generateDocumentItemViewForChangeResponse: GenerateDocumentItemViewForChangeResponse, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        
        let documentItemViewChangeData = DocumentGraphItemViewData()
        documentItemViewChangeData.uvcDocumentGraphModel._id = generateDocumentItemViewForChangeRequest.changeDocumentModel._id
        let uvcViewModelArray = try generateSentenceViewAsArray(udcDocumentGraphModel: generateDocumentItemViewForChangeRequest.changeDocumentModel, uvcViewItemCollection: nil, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, newView: false, isEditable: true, level: generateDocumentItemViewForChangeRequest.documentGraphChangeItemRequest.level, nodeIndex: generateDocumentItemViewForChangeRequest.documentGraphChangeItemRequest.nodeIndex, itemIndex: generateDocumentItemViewForChangeRequest.documentGraphChangeItemRequest.itemIndex, documentLanguage: generateDocumentItemViewForChangeRequest.documentGraphChangeItemRequest.documentLanguage)
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
    
    private func generateDocumentItemViewForInsert(generateDocumentItemViewForInsertRequest: GenerateDocumentItemViewForInsertRequest, generateDocumentItemViewForInsertResponse: inout GenerateDocumentItemViewForInsertResponse, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        
        let documentItemViewInsertData = DocumentGraphItemViewData()
        documentItemViewInsertData.uvcDocumentGraphModel.level = generateDocumentItemViewForInsertRequest.documentGraphInsertItemRequest.level
        documentItemViewInsertData.uvcDocumentGraphModel._id = generateDocumentItemViewForInsertRequest.insertDocumentModel._id
        documentItemViewInsertData.uvcDocumentGraphModel.isChildrenAllowed = generateDocumentItemViewForInsertRequest.documentGraphInsertItemRequest.isParent
        
        var uvcViewModelArray = [UVCViewModel]()
        
        uvcViewModelArray.append(contentsOf: try generateSentenceViewAsArray(udcDocumentGraphModel: generateDocumentItemViewForInsertRequest.insertDocumentModel, uvcViewItemCollection: generateDocumentItemViewForInsertRequest.uvcViewItemCollection, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, newView: true, isEditable: generateDocumentItemViewForInsertRequest.isEditable, level: generateDocumentItemViewForInsertRequest.documentGraphInsertItemRequest.level, nodeIndex: generateDocumentItemViewForInsertRequest.documentGraphInsertItemRequest.nodeIndex, itemIndex: generateDocumentItemViewForInsertRequest.documentGraphInsertItemRequest.itemIndex, documentLanguage: generateDocumentItemViewForInsertRequest.documentGraphInsertItemRequest.documentLanguage))
        
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
    
    
    
    private func validateDeleteLineRequest(validateDocumentGraphItemForDeleteLineRequest: ValidateDocumentGraphItemForDeleteLineRequest, validateDocumentGraphItemForDeleteLineResponse: inout ValidateDocumentGraphItemForDeleteLineResponse, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        
        validateDocumentGraphItemForDeleteLineResponse.result = true
        
        let jsonUtilityValidateDocumentGraphItemForDeleteLineResponse = JsonUtility<ValidateDocumentGraphItemForDeleteLineResponse>()
        let jsonValidateDocumentGraphItemForDeleteLineResponse = jsonUtilityValidateDocumentGraphItemForDeleteLineResponse.convertAnyObjectToJson(jsonObject: validateDocumentGraphItemForDeleteLineResponse)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonValidateDocumentGraphItemForDeleteLineResponse)
    }
    
    private func validateDeleteRequest(validateDocumentGraphItemForDeleteRequest: ValidateDocumentGraphItemForDeleteRequest, validateDocumentGraphItemForDeleteResponse: inout ValidateDocumentGraphItemForDeleteResponse, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        
        validateDocumentGraphItemForDeleteResponse.result = true
        
        
//        if validateDocumentGraphItemForDeleteRequest.documentGraphDeleteItemRequest.nodeIndex == 0 {
//            var udcSentencePatternDataGroupValue = [UDCSentencePatternDataGroupValue]()
//            for udcspgv in validateDocumentGraphItemForDeleteRequest.deleteDocumentModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue {
//                let udcspgvLocal = UDCSentencePatternDataGroupValue()
//                udcspgvLocal.item = udcspgv.item
//                udcSentencePatternDataGroupValue.append(udcspgvLocal)
//            }
//            udcSentencePatternDataGroupValue.remove(at: validateDocumentGraphItemForDeleteRequest.documentGraphDeleteItemRequest.itemIndex)
//            let udcGrammarUtility = UDCGrammarUtility()
//            var udcSentencePattern = UDCSentencePattern()
//            udcGrammarUtility.getSetencePattern(udcSentencePattern: &udcSentencePattern, udcSentencePatternDataGroupValue: udcSentencePatternDataGroupValue)
//            udcSentencePattern = try processGrammar(neuronRequest: neuronRequest, neuronResponse: &neuronResponse, udcSentencePattern: udcSentencePattern, newSentence: false, wordIndex: 0, sentenceIndex: 0, documentLanguage: validateDocumentGraphItemForDeleteRequest.documentGraphDeleteItemRequest.documentLanguage, textStartIndex: 0)
//            let uniqueTitle = "\(udcSentencePattern.sentence)"
//            let possibleIdName = "UDCDocument.\(uniqueTitle.capitalized.trimmingCharacters(in: .whitespaces))"
//            let databaseOrmResultUDCDocumentCheck = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, udcProfile: validateDocumentGraphItemForDeleteRequest.documentGraphDeleteItemRequest.udcProfile, idName: possibleIdName, udcDocumentTypeIdName: validateDocumentGraphItemForDeleteRequest.udcDocumentTypeIdName, notEqualsDocumentGroupId: validateDocumentGraphItemForDeleteRequest.udcDocument!.documentGroupId)
//            if databaseOrmResultUDCDocumentCheck.databaseOrmError.count == 0 {
//                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "SameDocumentNameAlreadyExists", description: "Same document name already exists"))
//                return
//            }
//        }
        
        let jsonUtilityValidateDocumentGraphItemForDeleteResponse = JsonUtility<ValidateDocumentGraphItemForDeleteResponse>()
        let jsonValidateDocumentGraphItemForDeleteResponse = jsonUtilityValidateDocumentGraphItemForDeleteResponse.convertAnyObjectToJson(jsonObject: validateDocumentGraphItemForDeleteResponse)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonValidateDocumentGraphItemForDeleteResponse)
    }
    
    private func getSentencePatternForDocumentItem(getSentencePatternForDocumentItemRequest: GetGraphSentencePatternForDocumentItemRequest, getSentencePatternForDocumentItemResponse: inout GetGraphSentencePatternForDocumentItemResponse, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let uDCSentencePatternDataGroupValue = [UDCSentencePatternDataGroupValue]()
        
        let neuronRequestLocal = NeuronRequest()
        neuronRequestLocal.neuronSource._id = neuronRequest.neuronSource._id
        neuronRequestLocal.neuronOperation.synchronus = true
        neuronRequestLocal.neuronOperation._id = neuronRequest.neuronOperation._id
        neuronRequestLocal.neuronSource.name = DocumentGraphNeuron.getName()
        neuronRequestLocal.neuronSource.type = DocumentGraphNeuron.getName()
        neuronRequestLocal.neuronOperation.name = "DocumentItemNeuron.Get.Sentence.Pattern"
        neuronRequestLocal.neuronOperation.parent = true
        let jsonUtilityGetGraphSentencePatternForDocumentItemRequest = JsonUtility<GetGraphSentencePatternForDocumentItemRequest>()
        neuronRequestLocal.neuronOperation.neuronData.text = jsonUtilityGetGraphSentencePatternForDocumentItemRequest.convertAnyObjectToJson(jsonObject: getSentencePatternForDocumentItemRequest)
        try callOtherNeuron(neuronRequest: neuronRequestLocal, neuronResponse: &neuronResponse, neuronName: "DocumentItemNeuron", overWriteResponse: true)
        
        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
            return
        }
        
        getSentencePatternForDocumentItemResponse = neuronUtility!.getNeuronRequest(json: neuronResponse.neuronOperation.neuronData.text, object: GetGraphSentencePatternForDocumentItemResponse())

    }
    
    private func getSentencePatternDataGroupValueForDocumentItem(optionItemObjectName: String, optionItemIdName: String, optionDocumentIdName: String, optionItemNameIndex: Int, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest, language: String, udcProfile: [UDCProfile], udcDocumentTypeIdName: String) throws -> [UDCSentencePatternDataGroupValue]? {
        
        let getGraphSentencePatternForDocumentItemRequest = GetGraphSentencePatternForDocumentItemRequest()
        getGraphSentencePatternForDocumentItemRequest.documentItemObjectName = optionItemObjectName
        getGraphSentencePatternForDocumentItemRequest.documentItemIdName = optionItemIdName
        getGraphSentencePatternForDocumentItemRequest.documentIdName = optionDocumentIdName
        getGraphSentencePatternForDocumentItemRequest.documentItemNameIndex = optionItemNameIndex
        getGraphSentencePatternForDocumentItemRequest.documentLanguage = language
        getGraphSentencePatternForDocumentItemRequest.udcProfile = udcProfile
        getGraphSentencePatternForDocumentItemRequest.udcDocumentTypeIdName = udcDocumentTypeIdName
        let neuronRequestLocal = NeuronRequest()
        neuronRequestLocal.neuronSource._id = neuronRequest.neuronSource._id
        neuronRequestLocal.neuronOperation.synchronus = true
        neuronRequestLocal.neuronOperation._id = neuronRequest.neuronOperation._id
        neuronRequestLocal.neuronSource.name = DocumentGraphNeuron.getName()
        neuronRequestLocal.neuronSource.type = DocumentGraphNeuron.getName()
        neuronRequestLocal.neuronOperation.name = "DocumentItemNeuron.Get.Sentence.Pattern.Data.Group.Value"
        neuronRequestLocal.neuronOperation.parent = true
        let jsonUtilityGetGraphSentencePatternForDocumentItemRequest = JsonUtility<GetGraphSentencePatternForDocumentItemRequest>()
        neuronRequestLocal.neuronOperation.neuronData.text = jsonUtilityGetGraphSentencePatternForDocumentItemRequest.convertAnyObjectToJson(jsonObject: getGraphSentencePatternForDocumentItemRequest)
        try callOtherNeuron(neuronRequest: neuronRequestLocal, neuronResponse: &neuronResponse, neuronName: "DocumentItemNeuron", overWriteResponse: true)
        
        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
            return nil
        }
        
        let getGraphSentencePatternForDocumentItemResponse = neuronUtility!.getNeuronRequest(json: neuronResponse.neuronOperation.neuronData.text, object: GetGraphSentencePatternForDocumentItemResponse())
        
        return getGraphSentencePatternForDocumentItemResponse.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue
    }
    
    private func validateInsertRequest(validateDocumentGraphItemForInsertRequest: ValidateDocumentGraphItemForInsertRequest, validateDocumentGraphItemForInsertResponse: inout ValidateDocumentGraphItemForInsertResponse, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let documentLanguage = validateDocumentGraphItemForInsertRequest.documentGraphInsertItemRequest.documentLanguage
        validateDocumentGraphItemForInsertResponse.result = true
        
        
        if validateDocumentGraphItemForInsertRequest.documentGraphInsertItemRequest.nodeIndex == 0 {
            let udcSentencePatternGroupValue = try getSentencePatternDataGroupValueForDocumentItem(optionItemObjectName: validateDocumentGraphItemForInsertRequest.documentGraphInsertItemRequest.optionItemObjectName, optionItemIdName: validateDocumentGraphItemForInsertRequest.documentGraphInsertItemRequest.optionItemId, optionDocumentIdName: validateDocumentGraphItemForInsertRequest.documentGraphInsertItemRequest.optionDocumentIdName, optionItemNameIndex: validateDocumentGraphItemForInsertRequest.documentGraphInsertItemRequest.optionItemNameIndex, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, language: documentLanguage, udcProfile: validateDocumentGraphItemForInsertRequest.documentGraphInsertItemRequest.udcProfile, udcDocumentTypeIdName: validateDocumentGraphItemForInsertRequest.documentGraphInsertItemRequest.udcDocumentTypeIdName)
            
            if udcSentencePatternGroupValue!.count == 0 {
                let udcSentencePatternDataGroupValueLocal = UDCSentencePatternDataGroupValue()
                udcSentencePatternDataGroupValueLocal.item = validateDocumentGraphItemForInsertRequest.documentGraphInsertItemRequest.item
                udcSentencePatternDataGroupValueLocal.itemId = ""
                udcSentencePatternDataGroupValueLocal.category = "UDCGrammarCategory.CommonNoun"
                udcSentencePatternDataGroupValueLocal.endCategoryIdName = "UDCDocumentItem.General"
                udcSentencePatternDataGroupValueLocal.uvcViewItemType = "UVCViewItemType.Text"
                validateDocumentGraphItemForInsertRequest.insertDocumentModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.append(udcSentencePatternDataGroupValueLocal)
            } else { validateDocumentGraphItemForInsertRequest.insertDocumentModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.insert(udcSentencePatternGroupValue![0], at: validateDocumentGraphItemForInsertRequest.documentGraphInsertItemRequest.itemIndex)
            }
            
            let udcGrammarUtility = UDCGrammarUtility()
            var udcSentencePattern = UDCSentencePattern()
            udcGrammarUtility.getSetencePattern(udcSentencePattern: &udcSentencePattern, udcSentencePatternDataGroupValue: validateDocumentGraphItemForInsertRequest.insertDocumentModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue)
            udcSentencePattern = try processGrammar(neuronRequest: neuronRequest, neuronResponse: &neuronResponse, udcSentencePattern: udcSentencePattern, newSentence: false, wordIndex: 0, sentenceIndex: 0, documentLanguage: documentLanguage, textStartIndex: 0)
            
            let uniqueTitle = "\(udcSentencePattern.sentence)"
            let possibleIdName = "UDCDocument.\(uniqueTitle.capitalized.replacingOccurrences(of: " ", with: ""))"
            
            let databaseOrmResultUDCDocumentCheck = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, udcProfile: validateDocumentGraphItemForInsertRequest.documentGraphInsertItemRequest.udcProfile, idName: possibleIdName, udcDocumentTypeIdName: validateDocumentGraphItemForInsertRequest.udcDocumentTypeIdName, notEqualsDocumentGroupId: validateDocumentGraphItemForInsertRequest.udcDocument!.documentGroupId)
            if databaseOrmResultUDCDocumentCheck.databaseOrmError.count == 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "SameDocumentNameAlreadyExists", description: "Same document name already exists"))
                return
            }
        }
        
        let jsonUtilityValidateDocumentGraphItemForInsertResponse = JsonUtility<ValidateDocumentGraphItemForInsertResponse>()
        let jsonValidateDocumentGraphItemForInsertResponse = jsonUtilityValidateDocumentGraphItemForInsertResponse.convertAnyObjectToJson(jsonObject: validateDocumentGraphItemForInsertResponse)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonValidateDocumentGraphItemForInsertResponse)
    }
    
    
    
    private func documentGetInterfacePhoto(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let detDocumentInterfacePhotoRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: GetDocumentInterfacePhotoRequest())
        
        var getDocumentInterfacePhotoResponse = GetDocumentInterfacePhotoResponse()
        try getDocumentIterfacePhoto(getDocumentInterfacePhotoRequest: detDocumentInterfacePhotoRequest, getDocumentInterfacePhotoResponse: &getDocumentInterfacePhotoResponse, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        
        let jsonUtilityGetDocumentInterfacePhotoResponse = JsonUtility<GetDocumentInterfacePhotoResponse>()
        let jsonGetDocumentInterfacePhotoResponse = jsonUtilityGetDocumentInterfacePhotoResponse.convertAnyObjectToJson(jsonObject: getDocumentInterfacePhotoResponse)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonGetDocumentInterfacePhotoResponse)
    }
    
    private func getDocumentIterfacePhoto(getDocumentInterfacePhotoRequest: GetDocumentInterfacePhotoRequest, getDocumentInterfacePhotoResponse: inout GetDocumentInterfacePhotoResponse, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        
        let databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, udcProfile: getDocumentInterfacePhotoRequest.udcProfile, udcDocumentTypeIdName: "UDCDocumentType.DocumentItem", idName: "UDCDocument.DocumentInterfacePhoto", language: getDocumentInterfacePhotoRequest.documentLanguage)
        if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocument.databaseOrmError[0].name, description: databaseOrmResultUDCDocument.databaseOrmError[0].description))
            return
        }
        let udcDocument = databaseOrmResultUDCDocument.object[0]
        
        let databaseOrmResultUDCDocumentItemParent = UDCDocumentGraphModel.get(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocument.udcDocumentGraphModelId)
        if databaseOrmResultUDCDocumentItemParent.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentItemParent.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentItemParent.databaseOrmError[0].description))
            return
        }
        let udcDocumentItemParent = databaseOrmResultUDCDocumentItemParent.object[0]
        
        let databaseOrmResultUDCDocumentItemChild = UDCDocumentGraphModel.get(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentItemParent.childrenId[0])
        if databaseOrmResultUDCDocumentItemChild.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentItemChild.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentItemChild.databaseOrmError[0].description))
            return
        }
        let udcDocumentItemChild = databaseOrmResultUDCDocumentItemChild.object[0]
        
        var udcDocumentItem: UDCDocumentGraphModel?
        var found: Bool = false
        for id in udcDocumentItemChild.childrenId {
            let databaseOrmResultUDCDocumentItem = UDCDocumentGraphModel.get(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, id: id)
            if databaseOrmResultUDCDocumentItem.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentItem.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentItem.databaseOrmError[0].description))
                return
            }
            udcDocumentItem = databaseOrmResultUDCDocumentItem.object[0]
            if udcDocumentItem?.idName == getDocumentInterfacePhotoRequest.idName {
                found = true
                break
            }
        }
        if !found {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "NotFound", description: "not found"))
            return
        }
        
        getDocumentInterfacePhotoResponse.objectDocumentIdName = udcDocument._id
        getDocumentInterfacePhotoResponse.objectNameIndex = 0
        getDocumentInterfacePhotoResponse.objectName = "UDCDocumentItemPhoto"
        getDocumentInterfacePhotoResponse.objectIdName = udcDocumentItem!._id
        getDocumentInterfacePhotoResponse.isOption = true
        
    }
    
    private func documentDelete(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let documentGraphDeleteRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: DocumentGraphDeleteRequest())
        
        // Get the document graph model id
        let databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: documentGraphDeleteRequest.udcDocumentId)
        if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocument.databaseOrmError[0].name, description: databaseOrmResultUDCDocument.databaseOrmError[0].description))
            return
        }
        let udcDocument = databaseOrmResultUDCDocument.object[0]
        
        // Delete all the document graph nodes
        try deleteDocumenGraphModeNodes(id: udcDocument.udcDocumentGraphModelId, documentGraphDeleteRequest: documentGraphDeleteRequest, language: udcDocument.language, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        
        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
            return
        }
        
        // Delete the references to the document
        let _ = UDCDocumentGraphModelDocumentMapDynamic.remove(collectionName: "\(neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphDeleteRequest.udcDocumentTypeIdName)!)DocumentMapDynamic", udbcDatabaseOrm: udbcDatabaseOrm!, udcDocumentId: udcDocument._id, language: udcDocument.language) as DatabaseOrmResult<UDCDocumentGraphModel>
        
        // Delete the document itself
        let databaseOrmResultUDCDocumentRemove = UDCDocument.remove(udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocument._id, language: udcDocument.language) as DatabaseOrmResult<UDCDocument>
        if databaseOrmResultUDCDocumentRemove.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentRemove.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentRemove.databaseOrmError[0].description))
            return
        }
        
        let documentGraphDeleteResponse = DocumentGraphDeleteResponse()
        documentGraphDeleteResponse.udcDocumentId = documentGraphDeleteRequest.udcDocumentId
        let jsonUtilityDocumentGraphDeleteResponse = JsonUtility<DocumentGraphDeleteResponse>()
        let jsonDocumentGraphDeleteResponse = jsonUtilityDocumentGraphDeleteResponse.convertAnyObjectToJson(jsonObject: documentGraphDeleteResponse)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonDocumentGraphDeleteResponse)
    }
    
    private func deleteDocumenGraphModeNodes(id: String, documentGraphDeleteRequest: DocumentGraphDeleteRequest, language: String, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let databaseOrmUDCDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphDeleteRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: id, language: language) as DatabaseOrmResult<UDCDocumentGraphModel>
        if databaseOrmUDCDocumentGraphModel.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentGraphModel.databaseOrmError[0].name, description: databaseOrmUDCDocumentGraphModel.databaseOrmError[0].description))
            return
        }
        let udcDocumentGraphModel = databaseOrmUDCDocumentGraphModel.object[0]
        
        for udcspdgv in udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue {
            if !udcspdgv.udcDocumentId.isEmpty && udcspdgv.itemIdName.hasPrefix("UDCDocumentItem.") {
                try removeReference(udcDocumentGraphModelId: udcspdgv.itemId, udcDocumentTypeIdName: "UDCDocumentType.DocumentItem", objectId: udcDocumentGraphModel._id, documentLanguage: language, udcProfile: documentGraphDeleteRequest.udcProfile, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            }
        }
        
        if udcDocumentGraphModel.childrenId.count > 0 {
            for child in udcDocumentGraphModel.childrenId {
                try deleteDocumenGraphModeNodes(id: child, documentGraphDeleteRequest: documentGraphDeleteRequest, language: language, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            }
        }
        let databaseOrmUDCDocumentGraphModelRemove = UDCDocumentGraphModel.remove(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphDeleteRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: id, language: language) as DatabaseOrmResult<UDCDocumentGraphModel>
        if databaseOrmUDCDocumentGraphModelRemove.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentGraphModelRemove.databaseOrmError[0].name, description: databaseOrmUDCDocumentGraphModelRemove.databaseOrmError[0].description))
            return
        }
    }
    
    private func documentAddToFavourite(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let documentAddToFavouriteRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: DocumentAddToFavouriteRequest())
        
        try documentGraphModelReference(parentPathIdName: "UDCOptionMap.DocumentMap->\(documentAddToFavouriteRequest.udcDocumentTypeIdName)", itemIdName: "UDCOptionMapNode.Favourites", udcDocumentId: documentAddToFavouriteRequest.udcDocumentId, udcProfile: documentAddToFavouriteRequest.udcProfile, udcDocumentTypeIdName: documentAddToFavouriteRequest.udcDocumentTypeIdName, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, documentLanguage: documentAddToFavouriteRequest.documentLanguage)
        
        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
            return
        }
        
        let documentAddToFavouriteResponse = DocumentAddToFavouriteResponse()
        let jsonUtilityDocumentAddToFavouriteResponse = JsonUtility<DocumentAddToFavouriteResponse>()
        let jsonDocumentAddToFavouriteResponse = jsonUtilityDocumentAddToFavouriteResponse.convertAnyObjectToJson(jsonObject: documentAddToFavouriteResponse)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonDocumentAddToFavouriteResponse)
    }
    
    /// Finds the parent document item and adds a child document item. Creates detail document for the child documen titem if not found. Can be used to delete the child document item.
    private func findAndAddDocumentItemWithDetails(mode: String, udcDocumentId: String, udcSentencePatternDataGroupValue: [UDCSentencePatternDataGroupValue], parentIdName: String, findItem: UDCSentencePatternDataGroupValue, isDetailDocument: Bool, isDocumentMapDocument: Bool, fieldToGet: String, isInsertAtFirst: Bool, isInsertAtLast: Bool, isNeedToFindChild: Bool, detailDocumentTypeIdName: String, detailDocumentModel: inout UDCDocumentGraphModel, detailDocumentId: inout String, inChildrens: [String], parentFound: inout Bool, foundParentModel: inout UDCDocumentGraphModel, foundParentId: inout String, foundItem: inout Bool, nodeIndex: Int, itemIndex: Int, level: Int, udcDocumentTypeIdName: String, udcProfile: [UDCProfile], isParent: Bool, generatedIdName: String, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest, documentLanguage: String, addUdcSentencePatternDataGroupValue: [UDCSentencePatternDataGroupValue], addUdcViewItemCollection: UDCViewItemCollection, addUdcSentencePatternDataGroupValueIndex: [Int]) throws -> Bool {
        
        for child in inChildrens {
            // Get each children of the parent that is to be found
            let databaseOrmResultudcDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, id: child, language: documentLanguage)
            if databaseOrmResultudcDocumentGraphModel.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModel.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModel.databaseOrmError[0].description))
                return false
            }
            var udcDocumentGraphModel = databaseOrmResultudcDocumentGraphModel.object[0]
            
            // Parent found, so set a flag and store the parent model for processing
            if udcDocumentGraphModel.idName == parentIdName && !parentFound {
                foundParentModel = udcDocumentGraphModel
                parentFound = true
            }
            var idToLookFor = ""
            if isDetailDocument {
                idToLookFor = udcDocumentGraphModel.objectId
            } else {
                idToLookFor = udcDocumentGraphModel.documentMapObjectId
            }
            if parentFound && isNeedToFindChild && !udcDocumentGraphModel.isChildrenAllowed {
                if !udcDocumentGraphModel.documentMapObjectId.isEmpty {
                    let udcDocumentItemMap = try getDocumentModel(udcDocumentId: udcDocumentGraphModel.documentMapObjectId, idName: "", udcDocumentTypeIdName: "UDCDocumentType.DocumentMap", udcProfile: udcProfile, documentLanguage: documentLanguage, isLanguageChild: true, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
                    var fieldValueMap = [String: [UDCSentencePatternDataGroupValue]]()
                    documentParser.getField(fieldidName: fieldToGet, childrenId: udcDocumentItemMap!.childrenId, fieldValue: &fieldValueMap, udcDocumentTypeIdName: "UDCDocumentType.DocumentMap", documentLanguage: documentLanguage)
                    let fieldValueArray = fieldValueMap[fieldToGet]
                    if (fieldValueArray != nil)  {
                        for udcspdgv in fieldValueArray! {
                            if (udcspdgv.uvcViewItemType == "UVCViewItemType.Text") && udcspdgv.itemId == findItem.itemId && udcspdgv.endSubCategoryId == findItem.endSubCategoryId && udcspdgv.endCategoryIdName == findItem.endCategoryIdName {
                                foundItem = true
                                break
                            }
                            break
                        }
                    }
                }
            }
            // Create detailDocument if not found. After that pass that created id to set in inserted model
            
            // Parent found, then child item found, so insert in the found child
            if (parentFound && ((udcDocumentGraphModel.childrenId.count == 0 && udcDocumentGraphModel.isChildrenAllowed && udcDocumentGraphModel.idName == parentIdName) || (udcDocumentGraphModel.parentId[0] == foundParentModel._id) || !isNeedToFindChild)) {
                if foundItem && isNeedToFindChild {
                    try deleteLineAndInsertAtFirst(currentModel: &udcDocumentGraphModel, udcDocumentTypeIdName: "UDCDocumentType.DocumentItem", documentLanguage: documentLanguage, udcProfile: udcProfile, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
                    
                    if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
                        return false
                    }
                    return true
                }
                var insertedModelId = ""
                var UDCDocumentGraphModelReferenceArray = [UDCDocumentGraphModelReference]()
                try insertItem(isNewChild: true, udcSentencePatternDataGroupValue: udcSentencePatternDataGroupValue, parentModel: &foundParentModel, currentModel: &udcDocumentGraphModel, nodeIndex: nodeIndex, itemIndex: itemIndex, sentenceIndex: 0, udcDocumentTypeIdName: "UDCDocumentType.DocumentItem", documentLanguage: documentLanguage, udcProfile: udcProfile, addUdcSentencePatternDataGroupValue: addUdcSentencePatternDataGroupValue, addUdcViewItemCollection: addUdcViewItemCollection, addUdcSentencePatternDataGroupValueIndex: addUdcSentencePatternDataGroupValueIndex, isParent: isParent, isInsertAtFirst: isInsertAtFirst, isInsertAtLast: isInsertAtLast, insertedModelId: &insertedModelId, udcDocumentGraphModelReference: UDCDocumentGraphModelReferenceArray, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
                
                // Put the reference
                try putReference(udcDocumentId: udcSentencePatternDataGroupValue[1].udcDocumentId, udcDocumentGraphModelId: udcSentencePatternDataGroupValue[1].itemId, udcDocumentTypeIdName: "UDCDocumentType.DocumentItem", objectUdcDocumentTypeIdName: "UDCDocumentType.DocumentItem", objectId: insertedModelId, objectName: "UDCDocumentItem", documentLanguage: documentLanguage, udcProfile: udcProfile, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
                
                if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
                    return false
                }
                
                // Create detail document if not exist
                if idToLookFor.isEmpty {
                    let databaseOrmResultUDCDocumentDetail = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, udcProfile: udcProfile, udcDocumentTypeIdName: detailDocumentTypeIdName, idName: "UDCDocument.Blank", language: documentLanguage)
                    if databaseOrmResultUDCDocumentDetail.databaseOrmError.count > 0 {
                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentDetail.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentDetail.databaseOrmError[0].description))
                        return false
                    }
                    let udcDocumentDetail = databaseOrmResultUDCDocumentDetail.object[0]
                    
                    // Prepare a request to generate document map
                    let generateDocumentGraphViewRequest = GenerateDocumentGraphViewRequest()
                    generateDocumentGraphViewRequest.getDocumentGraphViewRequest.documentId = udcDocumentDetail._id
                    generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcDocumentTypeIdName = "UDCDocumentType.DocumentMap"
                    generateDocumentGraphViewRequest.getDocumentGraphViewRequest.isToGetDuplicate = true
                    if isDetailDocument {
                        generateDocumentGraphViewRequest.getDocumentGraphViewRequest.isDetailedView = true
                    } else {
                        generateDocumentGraphViewRequest.getDocumentGraphViewRequest.isDocumentMapView = true
                    }
                    generateDocumentGraphViewRequest.getDocumentGraphViewRequest.documentId = udcDocumentDetail._id
                    generateDocumentGraphViewRequest.detailParentDocumentId = insertedModelId
                    generateDocumentGraphViewRequest.detailParentDocumentTypeIdName = "UDCDocumentType.DocumentItem"
                    generateDocumentGraphViewRequest.getDocumentGraphViewRequest.nodeId = insertedModelId
                    generateDocumentGraphViewRequest.getDocumentGraphViewRequest.duplicateToDocumentLanguage = documentLanguage
                    generateDocumentGraphViewRequest.getDocumentGraphViewRequest.documentLanguage = documentLanguage
                    generateDocumentGraphViewRequest.isDetailNameUseSource = true
                    
                    var generateDocumentGraphViewResponse = GenerateDocumentGraphViewResponse()
                    var documentLanguageGenerated = ""
                    var nodeIndexGenerated = 0
                    // Generate the document map
                    try generateDocumentGraphModel(generateDocumentGraphViewRequest: generateDocumentGraphViewRequest, udcDocumentGraphModel: &detailDocumentModel, nodeIndex: &nodeIndexGenerated, generateDocumentGraphViewResponse: &generateDocumentGraphViewResponse, isNewDocument: false, documentLanguage: &documentLanguageGenerated, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
                    
                    if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
                        return false
                    }
                    
                    detailDocumentId = generateDocumentGraphViewResponse.documentId
                    let databaseOrmResultInsertModel = UDCDocumentGraphModel.get(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, id: insertedModelId)
                    if databaseOrmResultInsertModel.databaseOrmError.count > 0 {
                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultInsertModel.databaseOrmError[0].name, description: databaseOrmResultInsertModel.databaseOrmError[0].description))
                        return false
                    }
                    let insertItemModel = databaseOrmResultInsertModel.object[0]
                    if isDetailDocument {
                        insertItemModel.objectId = generateDocumentGraphViewResponse.documentId
                        insertItemModel.objectName = neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!
                    } else {
                        insertItemModel.documentMapObjectId = generateDocumentGraphViewResponse.documentId
                        insertItemModel.documentMapObjectName = "UDCDocumentMap"
                    }
                    insertItemModel.udcDocumentTime.changedBy = documentParser.getUDCProfile(udcProfile: udcProfile, idName: "UPCProfileItem.Human")
                    insertItemModel.udcDocumentTime.changedTime = Date()
                    let databaseOrmResultUDCDocumentGraphModelUpdate = UDCDocumentGraphModel.update(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, object: insertItemModel)
                    if databaseOrmResultUDCDocumentGraphModelUpdate.databaseOrmError.count > 0 {
                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentGraphModelUpdate.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentGraphModelUpdate.databaseOrmError[0].description))
                        return false
                    }

                }
                return true
            }
            if udcDocumentGraphModel.childrenId.count > 0 {
                let result = try findAndAddDocumentItemWithDetails(mode: mode, udcDocumentId: udcDocumentId, udcSentencePatternDataGroupValue: udcSentencePatternDataGroupValue, parentIdName: parentIdName, findItem: findItem, isDetailDocument: isDetailDocument, isDocumentMapDocument: isDocumentMapDocument, fieldToGet: fieldToGet, isInsertAtFirst: isInsertAtFirst, isInsertAtLast: isInsertAtLast, isNeedToFindChild: isNeedToFindChild, detailDocumentTypeIdName: detailDocumentTypeIdName, detailDocumentModel: &detailDocumentModel, detailDocumentId: &detailDocumentId, inChildrens: udcDocumentGraphModel.childrenId, parentFound: &parentFound, foundParentModel: &foundParentModel, foundParentId: &foundParentId, foundItem: &foundItem, nodeIndex: nodeIndex, itemIndex: itemIndex, level: level, udcDocumentTypeIdName: udcDocumentTypeIdName, udcProfile: udcProfile, isParent: isParent, generatedIdName: generatedIdName, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, documentLanguage: documentLanguage, addUdcSentencePatternDataGroupValue: addUdcSentencePatternDataGroupValue, addUdcViewItemCollection: addUdcViewItemCollection, addUdcSentencePatternDataGroupValueIndex: addUdcSentencePatternDataGroupValueIndex)
                if result {
                    return result
                }
            }
        }
        
        return false
    }
    
    private func putReference(udcDocumentId: String, udcDocumentGraphModelId: String, udcDocumentTypeIdName: String, objectUdcDocumentTypeIdName: String, objectId: String, objectName: String, documentLanguage: String, udcProfile: [UDCProfile], neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
     
        // Get the reference id
        let udcDocumentodelItem = try getDocumentModel(udcDocumentGraphModelId: udcDocumentGraphModelId, udcDocumentTypeIdName: udcDocumentTypeIdName, isLanguageChild: false, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        
        let udcDocumentGraphModelReference = UDCDocumentGraphModelReference()
        udcDocumentGraphModelReference._id = try udbcDatabaseOrm!.generateId()
        udcDocumentGraphModelReference.udcDocumentTypeIdName = objectUdcDocumentTypeIdName
        udcDocumentGraphModelReference.udcDocumentId = udcDocumentId
        udcDocumentGraphModelReference.language = documentLanguage
        udcDocumentGraphModelReference.objectId = objectId
        udcDocumentGraphModelReference.objectName = objectName
        // Get the reference root node
        if !udcDocumentodelItem!.udcDocumentGraphModelReferenceId.isEmpty {
            let databaseOrmResultRef = UDCDocumentGraphModelReference.get(collectionName: "\(neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!)Reference", udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentodelItem!.udcDocumentGraphModelReferenceId)
            let udcRef = databaseOrmResultRef.object[0]
            
            // Put the reference
            udcDocumentGraphModelReference.parentId.append(udcRef._id)
            udcRef.childrenId.append(udcDocumentGraphModelReference._id)
            let databaseOrmResultRefSave = UDCDocumentGraphModelReference.save(collectionName: "\(neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!)Reference", udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentGraphModelReference)
            if databaseOrmResultRefSave.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultRefSave.databaseOrmError[0].name, description: databaseOrmResultRefSave.databaseOrmError[0].description))
                return
            }
            
            // Add the reference to the root
            udcRef.udcDocumentTime.changedBy = documentParser.getUDCProfile(udcProfile: udcProfile, idName: "UPCProfileItem.Human")
            udcRef.udcDocumentTime.changedTime = Date()
            let databaseOrmResultRefUpdate = UDCDocumentGraphModelReference.update(collectionName: "\(neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!)Reference", udbcDatabaseOrm: udbcDatabaseOrm!, object: udcRef)
            if databaseOrmResultRefUpdate.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultRefUpdate.databaseOrmError[0].name, description: databaseOrmResultRefUpdate.databaseOrmError[0].description))
                return
            }
        } else {
            // Put the reference
            udcDocumentGraphModelReference.udcDocumentTime.createdBy = documentParser.getUDCProfile(udcProfile: udcProfile, idName: "UPCProfileItem.Human")
            udcDocumentGraphModelReference.udcDocumentTime.creationTime = Date()
            let databaseOrmResultRefSave = UDCDocumentGraphModelReference.save(collectionName: "\(neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!)Reference", udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentGraphModelReference)
            if databaseOrmResultRefSave.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultRefSave.databaseOrmError[0].name, description: databaseOrmResultRefSave.databaseOrmError[0].description))
                return
            }
            
            // Update the moodel with root reference id
            udcDocumentodelItem!.udcDocumentGraphModelReferenceId = udcDocumentGraphModelReference._id
            udcDocumentodelItem!.udcDocumentTime.changedBy = documentParser.getUDCProfile(udcProfile: udcProfile, idName: "UPCProfileItem.Human")
            udcDocumentodelItem!.udcDocumentTime.changedTime = Date()
            let databaseOrmResultModelUpdate = UDCDocumentGraphModel.update(collectionName: "\(neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!)", udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentodelItem!)
            if databaseOrmResultModelUpdate.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultModelUpdate.databaseOrmError[0].name, description: databaseOrmResultModelUpdate.databaseOrmError[0].description))
                return
            }
        }
        
    }
    
    private func removeReference(udcDocumentGraphModelId: String, udcDocumentTypeIdName: String, objectId: String, documentLanguage: String, udcProfile: [UDCProfile], neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
     
        // Get the reference id
        let udcDocumentodelItem = try getDocumentModel(udcDocumentGraphModelId: udcDocumentGraphModelId, udcDocumentTypeIdName: udcDocumentTypeIdName, isLanguageChild: false, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        
        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
            return
        }
        
        // Get the root reference
        let databaseOrmResultRef = UDCDocumentGraphModelReference.get(collectionName: "\(neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!)Reference", udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentodelItem!.udcDocumentGraphModelReferenceId)
        if databaseOrmResultRef.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultRef.databaseOrmError[0].name, description: databaseOrmResultRef.databaseOrmError[0].description))
            return
        }
        let udcRef = databaseOrmResultRef.object[0]
        
        // Remove the reference
        var removeIndex = -1
        for (childIndex, child) in udcRef.childrenId.enumerated() {
            let databaseOrmResultRefChild = UDCDocumentGraphModelReference.get(collectionName: "\(neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!)Reference", udbcDatabaseOrm: udbcDatabaseOrm!, id: child)
            if databaseOrmResultRefChild.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultRefChild.databaseOrmError[0].name, description: databaseOrmResultRefChild.databaseOrmError[0].description))
                return
            }
            let udcRefChild = databaseOrmResultRefChild.object[0]
            if udcRefChild.objectId == objectId {
                let databaseOrmResultRefChildRemove = UDCDocumentGraphModelReference.remove(collectionName: "\(neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!)Reference", udbcDatabaseOrm: udbcDatabaseOrm!, id: child) as DatabaseOrmResult<UDCDocumentGraphModelReference>
                if databaseOrmResultRefChildRemove.databaseOrmError.count > 0 {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultRefChildRemove.databaseOrmError[0].name, description: databaseOrmResultRefChildRemove.databaseOrmError[0].description))
                    return
                }
                removeIndex = childIndex
                break
            }
        }
     
        
        // Update the root reference after removing the id in parent
        if removeIndex >= 0 {
            udcRef.childrenId.remove(at: removeIndex)
            udcRef.udcDocumentTime.changedBy = documentParser.getUDCProfile(udcProfile: udcProfile, idName: "UPCProfileItem.Human")
            udcRef.udcDocumentTime.changedTime = Date()
            let databaseOrmResultRefUpdate = UDCDocumentGraphModelReference.update(collectionName: "\(neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!)Reference", udbcDatabaseOrm: udbcDatabaseOrm!, object: udcRef)
            if databaseOrmResultRefUpdate.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultRefUpdate.databaseOrmError[0].name, description: databaseOrmResultRefUpdate.databaseOrmError[0].description))
                return
            }
        }
        
        
        // If no child remove root reference
        if udcRef.objectId == objectId && udcRef.childrenId.count == 0 {
            let databaseOrmResultRefChildRemove = UDCDocumentGraphModelReference.remove(collectionName: "\(neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!)Reference", udbcDatabaseOrm: udbcDatabaseOrm!, id: udcRef._id) as DatabaseOrmResult<UDCDocumentGraphModelReference>
            if databaseOrmResultRefChildRemove.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultRefChildRemove.databaseOrmError[0].name, description: databaseOrmResultRefChildRemove.databaseOrmError[0].description))
                return
            }
            
            udcDocumentodelItem!.udcDocumentGraphModelReferenceId = ""
            udcDocumentodelItem!.udcDocumentTime.changedBy = documentParser.getUDCProfile(udcProfile: udcProfile, idName: "UPCProfileItem.Human")
            udcDocumentodelItem!.udcDocumentTime.changedTime = Date()
            let databaseOrmResultDocumentItemUpdate = UDCDocumentGraphModel.update(collectionName: "\(neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!)", udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentodelItem!)
            if databaseOrmResultDocumentItemUpdate.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultDocumentItemUpdate.databaseOrmError[0].name, description: databaseOrmResultDocumentItemUpdate.databaseOrmError[0].description))
                return
            }
        }
        
    }
    private func generateDocumentView(generateDocumentGraphViewRequest: GenerateDocumentGraphViewRequest, generateDocumentGraphViewResponse: inout GenerateDocumentGraphViewResponse, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        var nodeIndex = 0
        var uvcDocumentGraphModelArray = [UVCDocumentGraphModel]()
        var udcDocumentGraphModel = UDCDocumentGraphModel()
        var documentLanguage = generateDocumentGraphViewRequest.getDocumentGraphViewRequest.documentLanguage
        
        try generateDocumentGraphModel(generateDocumentGraphViewRequest: generateDocumentGraphViewRequest, udcDocumentGraphModel: &udcDocumentGraphModel, nodeIndex: &nodeIndex, generateDocumentGraphViewResponse: &generateDocumentGraphViewResponse, isNewDocument: false, documentLanguage: &documentLanguage, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        
        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
            return
        }
        
        try generateDocumentGraphModelView(udcDocumentGraphModel: udcDocumentGraphModel, uvcDocumentGraphModelArray: &uvcDocumentGraphModelArray, udcDocumentTypeIdName: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcDocumentTypeIdName, documentLanguage: documentLanguage, isEditableMode: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.editMode, documentTitle: &generateDocumentGraphViewResponse.documentTitle,  neuronRequest: neuronRequest, neuronResponse: &neuronResponse)

        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
            return
        }
              
        for uvcdgm in uvcDocumentGraphModelArray {
            let documentItemViewInsertData = DocumentGraphItemViewData()
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
            documentItemViewInsertData.itemIndex = 2
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
    
    
    
    private func generateDocumentGraphModel(generateDocumentGraphViewRequest: GenerateDocumentGraphViewRequest, udcDocumentGraphModel: inout UDCDocumentGraphModel, nodeIndex: inout Int, generateDocumentGraphViewResponse: inout GenerateDocumentGraphViewResponse, isNewDocument: Bool, documentLanguage: inout String, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        
        // Based on the udc document id get the udc document
        let databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.documentId)
        if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "DocumentNotFound", description: "Document not found!"))
            return
        }
        let udcDocument = databaseOrmResultUDCDocument.object[0]
        
//        let udcDocumentItemRecentLangTitle = try getDocumentModel(udcDocumentId: udcDocument._id, idName: "UDCDocument.Recents", udcDocumentTypeIdName: "UDCDocumentType.DocumentItem", udcProfile: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcProfile, documentLanguage: documentLanguage, isLanguageChild: true, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
//
//        var isDocumentRecentFound: Bool = false
//        if !neuronUtility!.isNeuronOperationError(neuronResponse:  neuronResponse) {
//            // Check if document is found already
//            var itemModel = UDCDocumentGraphModel()
//            let recentDocumentId = try getDcoumentIdFromMap(udcDocumentId: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.documentId, udcDocumentTypeIdName: "UDCDocumentType.DocumentItem", udcProfile: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcProfile, documentLanguage: documentLanguage, children: udcDocumentItemRecentLangTitle!.childrenId, itemModel: &itemModel, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
//            if recentDocumentId != nil {
//                isDocumentRecentFound = true
//            }
//
//
//            let generateDocumentGraphViewRequestRecent = GenerateDocumentGraphViewRequest()
//            let databaseOrmResultUDCDocumentConfig = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, udcProfile: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcProfile, udcDocumentTypeIdName: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcDocumentTypeIdName, idName: "UDCDocument.Blank", language: documentLanguage)
//            if databaseOrmResultUDCDocumentConfig.databaseOrmError.count > 0 {
//                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentConfig.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentConfig.databaseOrmError[0].description))
//                return
//            }
//            let udcDocumentConfig = databaseOrmResultUDCDocumentConfig.object[0].self
//            generateDocumentGraphViewRequestRecent.getDocumentGraphViewRequest.documentId = udcDocumentConfig._id
//            generateDocumentGraphViewRequestRecent.getDocumentGraphViewRequest.udcDocumentTypeIdName = "UDCDocumentType.DocumentMap"
//            generateDocumentGraphViewRequestRecent.getDocumentGraphViewRequest.isToGetDuplicate = true
//            generateDocumentGraphViewRequestRecent.detailParentDocumentTypeIdName = "UDCDocumentType.DocumentItem"
//            generateDocumentGraphViewRequestRecent.getDocumentGraphViewRequest.documentId = udcDocumentConfig._id
//            generateDocumentGraphViewRequest.detailParentDocumentId = itemModel._id
//
//            var generateDocumentGraphViewResponseResponse = GenerateDocumentGraphViewResponse()
//
//            try generateDocumentView(generateDocumentGraphViewRequest: generateDocumentGraphViewRequestRecent, generateDocumentGraphViewResponse: &generateDocumentGraphViewResponseResponse, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
//
//            let udcDocumentGraphModelRecent = UDCDocumentGraphModel()
//            udcDocumentGraphModelRecent.idName = udcDocument.idName.replacingOccurrences(of: "UDCDocument", with: "UDCDocumentItem")
//            udcDocumentGraphModelRecent.name = udcDocument.name
//            udcDocumentGraphModelRecent.documentMapObjectId = generateDocumentGraphViewResponseResponse.documentId
//            udcDocumentGraphModelRecent.documentMapObjectName = "UDCDocumentMap"
//            udcDocumentGraphModelRecent.udcSentencePattern.udcSentencePatternData.append(UDCSentencePatternData())
//            udcDocumentGraphModelRecent.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup.append(UDCSentencePatternDataGroup())
//            udcDocumentGraphModelRecent.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.append(UDCSentencePatternDataGroupValue())
//            udcDocumentGraphModelRecent.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].category = "UDCGrammarCategory.CommonNoun"
//            udcDocumentGraphModelRecent.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].endCategoryIdName = "UDCDocumentItem.General"
//            udcDocumentGraphModelRecent.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].uvcViewItemType = "UVCViewItemType.Photo"
//
//            udcDocumentGraphModelRecent.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.append(UDCSentencePatternDataGroupValue())
//            udcDocumentGraphModelRecent.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].category = "UDCGrammarCategory.CommonNoun"
//            udcDocumentGraphModelRecent.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].endCategoryIdName = "UDCDocumentItem.Document"
//            udcDocumentGraphModelRecent.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].uvcViewItemType = "UVCViewItemType.Text"
//            udcDocumentGraphModelRecent.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].udcDocumentId = udcDocument._id
//            udcDocumentGraphModelRecent.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].endCategoryId = generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcDocumentTypeIdName
//            udcDocumentGraphModelRecent.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].itemId = udcDocument._id
//            udcDocumentGraphModelRecent.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].itemIdName = itemModel.idName
//
//        }
        
        var databaseOrmUDCDocumentGraphModel: DatabaseOrmResult<UDCDocumentGraphModel>?
        
        if generateDocumentGraphViewRequest.getDocumentGraphViewRequest.isConfigurationView || generateDocumentGraphViewRequest.getDocumentGraphViewRequest.isDetailedView || generateDocumentGraphViewRequest.getDocumentGraphViewRequest.isDocumentMapView {
            generateDocumentGraphViewRequest.getDocumentGraphViewRequest.duplicateToDocumentLanguage = generateDocumentGraphViewRequest.getDocumentGraphViewRequest.documentLanguage
        }

        var udcDocumentParent: UDCDocument? = nil
        var udcDocumentParentEn: UDCDocument? = nil
        var udcDocumentGraphModelParent: UDCDocumentGraphModel? = nil
        var getSentencePatternForDocumentItemResponse = GetGraphSentencePatternForDocumentItemResponse()
        // If it is related to detail of a parent
        if !generateDocumentGraphViewRequest.detailParentDocumentId.isEmpty {
            // If configuration view of a document item document
            if generateDocumentGraphViewRequest.getDocumentGraphViewRequest.isConfigurationView {
                // Get the document model based on udc document id
                databaseOrmUDCDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocument.udcDocumentGraphModelId) as DatabaseOrmResult<UDCDocumentGraphModel>
                if databaseOrmUDCDocumentGraphModel!.databaseOrmError.count > 0 {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentGraphModel!.databaseOrmError[0].name, description: databaseOrmUDCDocumentGraphModel!.databaseOrmError[0].description))
                    return
                }
                udcDocumentGraphModel = databaseOrmUDCDocumentGraphModel!.object[0]
                
                // Get the parent document details so that language title point to language specific document
                let databaseOrmResultUDCDocumentParent = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: generateDocumentGraphViewRequest.detailParentDocumentId)
                if databaseOrmResultUDCDocumentParent.databaseOrmError.count > 0 {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentParent.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentParent.databaseOrmError[0].description))
                    return
                }
                udcDocumentParent = databaseOrmResultUDCDocumentParent.object[0]
                
                // Get the english parent name so that english title point to english document
                let databaseOrmResultUDCDocumentParentEn = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, udcProfile: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcProfile, udcDocumentTypeIdName: generateDocumentGraphViewRequest.detailParentDocumentTypeIdName, idName: udcDocumentParent!.idName, language: "en")
                if databaseOrmResultUDCDocumentParentEn.databaseOrmError.count > 0 {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentParentEn.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentParentEn.databaseOrmError[0].description))
                    return
                }
                udcDocumentParentEn = databaseOrmResultUDCDocumentParentEn.object[0]
                
                let databaseOrmUDCDocumentGraphModelParent = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: generateDocumentGraphViewRequest.detailParentDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentParent!.udcDocumentGraphModelId) as DatabaseOrmResult<UDCDocumentGraphModel>
                if databaseOrmUDCDocumentGraphModelParent.databaseOrmError.count > 0 {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentGraphModelParent.databaseOrmError[0].name, description: databaseOrmUDCDocumentGraphModelParent.databaseOrmError[0].description))
                    return
                }
                udcDocumentGraphModelParent = databaseOrmUDCDocumentGraphModelParent.object[0]
            } else { // Document Map
                // Ge the document model based on node id
                databaseOrmUDCDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: generateDocumentGraphViewRequest.detailParentDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.nodeId!) as DatabaseOrmResult<UDCDocumentGraphModel>
                if databaseOrmUDCDocumentGraphModel!.databaseOrmError.count > 0 {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentGraphModel!.databaseOrmError[0].name, description: databaseOrmUDCDocumentGraphModel!.databaseOrmError[0].description))
                    return
                }
                udcDocumentGraphModel = databaseOrmUDCDocumentGraphModel!.object[0]
                
                // Get the sentence pattern for the node id
                let getSentencePatternForDocumentItemRequest = GetGraphSentencePatternForDocumentItemRequest()
                if generateDocumentGraphViewRequest.isDetailNameUseSource {
                    getSentencePatternForDocumentItemRequest.documentIdName = udcDocumentGraphModel.getSentencePatternGroupValue(wordIndex: 1).udcDocumentId
                }
                getSentencePatternForDocumentItemRequest.documentIdName = generateDocumentGraphViewRequest.getDocumentGraphViewRequest.documentId
                getSentencePatternForDocumentItemRequest.documentItemObjectName = "UDCDocumentItem"
                getSentencePatternForDocumentItemRequest.documentLanguage = generateDocumentGraphViewRequest.getDocumentGraphViewRequest.documentLanguage
                getSentencePatternForDocumentItemRequest.udcDocumentTypeIdName = generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcDocumentTypeIdName
                getSentencePatternForDocumentItemRequest.udcProfile = generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcProfile

                // If detail name is not used from source
                if generateDocumentGraphViewRequest.isDetailNameUseSource {
                    getSentencePatternForDocumentItemRequest.documentItemIdName = udcDocumentGraphModel.getSentencePatternGroupValue(wordIndex: 1).itemId
                } else {
                    getSentencePatternForDocumentItemRequest.documentItemIdName = generateDocumentGraphViewRequest.getDocumentGraphViewRequest.nodeId!
                }
                try getSentencePatternForDocumentItem(getSentencePatternForDocumentItemRequest: getSentencePatternForDocumentItemRequest, getSentencePatternForDocumentItemResponse: &getSentencePatternForDocumentItemResponse, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            }
        } else {
            databaseOrmUDCDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocument.udcDocumentGraphModelId) as DatabaseOrmResult<UDCDocumentGraphModel>
            if databaseOrmUDCDocumentGraphModel!.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentGraphModel!.databaseOrmError[0].name, description: databaseOrmUDCDocumentGraphModel!.databaseOrmError[0].description))
                return
            }
            udcDocumentGraphModel = databaseOrmUDCDocumentGraphModel!.object[0]
        }
        
        var documentIdForSource: String = ""
        if generateDocumentGraphViewRequest.isDetailNameUseSource {
            documentIdForSource = udcDocumentGraphModel.getSentencePatternGroupValue(wordIndex: 1).udcDocumentId
        }
        var englishIdName: String = ""
        if generateDocumentGraphViewRequest.getDocumentGraphViewRequest.isToGetDuplicate {
            var profileId = ""
            for udcp in generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcProfile {
                if udcp.udcProfileItemIdName == "UDCProfileItem.Human" {
                    profileId = udcp.profileId
                }
            }
            udcDocumentGraphModel._id = try (udbcDatabaseOrm?.generateId())!
            if isNewDocument {
                let databaseOrmUDCDocumentItemMapNode = UDCDocumentItemMapNode.get("UDCDocumentItemMapNode.Untitled", udbcDatabaseOrm!, generateDocumentGraphViewRequest.getDocumentGraphViewRequest.duplicateToDocumentLanguage)
                if databaseOrmUDCDocumentItemMapNode.databaseOrmError.count > 0 {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentItemMapNode.databaseOrmError[0].name, description: databaseOrmUDCDocumentItemMapNode.databaseOrmError[0].description))
                    return
                }
                let untitledItem = databaseOrmUDCDocumentItemMapNode.object
                let name = "\(untitledItem[0].name)-\(NSUUID().uuidString)"
                udcDocumentGraphModel.name = name
                var count = udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.count
                if count > 1 {
                    for index in 1...count-1 {
                        if index > 1 {
                            udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.remove(at: 2)
                        }
                    }
                }
                udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].item = name
                udcDocumentGraphModel.udcSentencePattern.sentence = name
                udcDocument.name = name
                udcDocument.documentGroupId = try (udbcDatabaseOrm?.generateId())!
                udcDocument.idName = "UDCDocument.\(name.capitalized.replacingOccurrences(of: " ", with: ""))"
                udcDocumentGraphModel.idName = "\(neuronUtility!.getCollectionName(udcDocumentTypeIdName: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcDocumentTypeIdName)!).\(name.capitalized.replacingOccurrences(of: " ", with: ""))"
                englishIdName = udcDocument.idName.replacingOccurrences(of: "UDCDocument", with: neuronUtility!.getCollectionName(udcDocumentTypeIdName: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcDocumentTypeIdName)!)
            } else {
                if generateDocumentGraphViewRequest.detailParentDocumentId.isEmpty {
                    udcDocumentGraphModel.idName = udcDocument.idName
                    englishIdName = udcDocument.idName.replacingOccurrences(of: "UDCDocument", with: neuronUtility!.getCollectionName(udcDocumentTypeIdName: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcDocumentTypeIdName)!)
                } else {
                    if generateDocumentGraphViewRequest.getDocumentGraphViewRequest.isConfigurationView {
                        udcDocument.name = udcDocumentGraphModelParent!.name
                        udcDocument.documentGroupId = try (udbcDatabaseOrm?.generateId())!
                        udcDocument.idName = "UDCDocument.\(udcDocument.name.capitalized.replacingOccurrences(of: " ", with: ""))"
                        
                        // Based on the parent document details change the title of the document that is going to be duplicated from blank template
                        udcDocumentGraphModel.idName = udcDocumentParent!.idName.replacingOccurrences(of: "UDCDocument", with: neuronUtility!.getCollectionName(udcDocumentTypeIdName: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcDocumentTypeIdName)!)
                        udcDocumentGraphModel.name = udcDocumentGraphModelParent!.name
                        englishIdName = udcDocumentParent!.idName.replacingOccurrences(of: "UDCDocument", with: neuronUtility!.getCollectionName(udcDocumentTypeIdName: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcDocumentTypeIdName)!)
                        udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.removeAll()
                        udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.append(UDCSentencePatternDataGroupValue())
                        udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].udcDocumentId = generateDocumentGraphViewRequest.detailParentDocumentId
                        udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].category = "UDCGrammarCategory.CommonNoun"
                        udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].endCategoryId = "UDCDocumentType.DocumentItem"
                        udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].endCategoryIdName = "UDCDocumentItem.Document"
                        udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].itemId = udcDocumentParentEn!._id
                        udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].item = udcDocumentGraphModel.name
                        udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].itemIdName = udcDocumentParentEn!.idName
                        udcDocumentGraphModel.udcSentencePattern = try processGrammar(neuronRequest: neuronRequest, neuronResponse: &neuronResponse, udcSentencePattern: udcDocumentGraphModel.udcSentencePattern, newSentence: true, wordIndex: 0, sentenceIndex: 0, documentLanguage: documentLanguage, textStartIndex: 0)
                    } else {
                        udcDocument.name = udcDocumentGraphModel.name
                        udcDocument.documentGroupId = try (udbcDatabaseOrm?.generateId())!
                        udcDocument.idName = udcDocumentGraphModel.idName.replacingOccurrences(of: "UDCDocumentItem", with:  "UDCDocument")
                        
                        // Based on the parent document details change the title of the document that is going to be duplicated from blank template
                        udcDocumentGraphModel.idName = (udcDocumentGraphModel.idName.replacingOccurrences(of: "UDCDocumentItem", with:  neuronUtility!.getCollectionName(udcDocumentTypeIdName: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcDocumentTypeIdName)!))
                        udcDocumentGraphModel.isChildrenAllowed = true
                        udcDocumentGraphModel.level = 0
                        englishIdName = udcDocumentGraphModel.idName.replacingOccurrences(of: "UDCDocumentItem", with: neuronUtility!.getCollectionName(udcDocumentTypeIdName: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcDocumentTypeIdName)!)
                        
                        udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.removeAll()
                        udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.append(UDCSentencePatternDataGroupValue())
                        if generateDocumentGraphViewRequest.isDetailNameUseSource {
                            udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].udcDocumentId = documentIdForSource
                        } else {
                            udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].udcDocumentId = generateDocumentGraphViewRequest.detailParentDocumentId
                        }
                        udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].category = getSentencePatternForDocumentItemResponse.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].category
                        udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].endCategoryId = getSentencePatternForDocumentItemResponse.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].endCategoryId
                        udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].endCategoryIdName = getSentencePatternForDocumentItemResponse.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].endCategoryIdName
                        udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].endSubCategoryId = getSentencePatternForDocumentItemResponse.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].endSubCategoryId
                        udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].endSubCategoryIdName = getSentencePatternForDocumentItemResponse.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].endSubCategoryIdName
                        udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].itemId = getSentencePatternForDocumentItemResponse.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].itemId
                        udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].item = getSentencePatternForDocumentItemResponse.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].item
                        udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].itemIdName = getSentencePatternForDocumentItemResponse.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].itemIdName
                        udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].uvcViewItemType = getSentencePatternForDocumentItemResponse.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].uvcViewItemType
                        udcDocumentGraphModel.udcSentencePattern = try processGrammar(neuronRequest: neuronRequest, neuronResponse: &neuronResponse, udcSentencePattern: udcDocumentGraphModel.udcSentencePattern, newSentence: true, wordIndex: 0, sentenceIndex: 0, documentLanguage: documentLanguage, textStartIndex: 0)
                        udcDocumentGraphModel.name = udcDocumentGraphModel.udcSentencePattern.sentence
                    }
                }
            }
            
            if generateDocumentGraphViewRequest.isDetailNameUseSource {
                try putReference(udcDocumentId: documentIdForSource, udcDocumentGraphModelId: udcDocumentGraphModel.getSentencePatternGroupValue(wordIndex: 0).itemId, udcDocumentTypeIdName: "UDCDocumentType.DocumentItem", objectUdcDocumentTypeIdName: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcDocumentTypeIdName, objectId: udcDocumentGraphModel._id, objectName:  neuronUtility!.getCollectionName(udcDocumentTypeIdName: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcDocumentTypeIdName)!, documentLanguage: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.documentLanguage, udcProfile: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcProfile, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            }
            
            // Save the english title
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
            var newChildrenId = [String]()
            var levelChildrenId = [String: [String]]()
        
            if generateDocumentGraphViewRequest.getDocumentGraphViewRequest.isConfigurationView {
                try duplicateDocumentGraphModel(parentId: udcDocumentGraphModel._id, childrenId: udcDocumentGraphModel.childrenId, newChildrenId: &newChildrenId, levelChildrenId: &levelChildrenId, udcDocumentTypeIdName: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcDocumentTypeIdName, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, profileId: profileId,  udcProfile: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcProfile, documentLanguage: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.documentLanguage, duplicateToDocumentLanguage: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.duplicateToDocumentLanguage, udcDocumentId: udcDocument._id)
            } else {
                let databaseOrmResultUDCDocumentConfigObject = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.documentId)
                if databaseOrmResultUDCDocumentConfigObject.databaseOrmError.count > 0 {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentConfigObject.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentConfigObject.databaseOrmError[0].description))
                    return
                }
                let udcDocumentConfigObject = databaseOrmResultUDCDocumentConfigObject.object[0]
                
                let databaseOrmUDCDocumentGraphModelConfigObject = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentConfigObject.udcDocumentGraphModelId) as DatabaseOrmResult<UDCDocumentGraphModel>
                if databaseOrmUDCDocumentGraphModelConfigObject.databaseOrmError.count > 0 {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentGraphModelConfigObject.databaseOrmError[0].name, description: databaseOrmUDCDocumentGraphModelConfigObject.databaseOrmError[0].description))
                    return
                }
                let udcDocumentGraphModelConfigObject = databaseOrmUDCDocumentGraphModelConfigObject.object[0]
                
                try duplicateDocumentGraphModel(parentId: udcDocumentGraphModel._id, childrenId: udcDocumentGraphModelConfigObject.childrenId, newChildrenId: &newChildrenId, levelChildrenId: &levelChildrenId, udcDocumentTypeIdName: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcDocumentTypeIdName, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, profileId: profileId,  udcProfile: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcProfile, documentLanguage: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.documentLanguage, duplicateToDocumentLanguage: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.duplicateToDocumentLanguage, udcDocumentId: udcDocument._id)
            }
            
            if newChildrenId.count > 0 {
                udcDocumentGraphModel.childrenId.removeAll()
                udcDocumentGraphModel.childrenId.append(contentsOf: newChildrenId)
            }
            // Only if not detailed document
            if generateDocumentGraphViewRequest.detailParentDocumentId.isEmpty {
                let databaseOrmUDCDocumentItemMapNode = UDCDocumentItemMapNode.get("UDCDocumentItemMapNode.Untitled", udbcDatabaseOrm!, generateDocumentGraphViewRequest.getDocumentGraphViewRequest.duplicateToDocumentLanguage)
                if databaseOrmUDCDocumentItemMapNode.databaseOrmError.count > 0 {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentItemMapNode.databaseOrmError[0].name, description: databaseOrmUDCDocumentItemMapNode.databaseOrmError[0].description))
                    return
                }
                let untitledItem = databaseOrmUDCDocumentItemMapNode.object
                
                let name = "\(untitledItem[0].name)-\(NSUUID().uuidString)"
                
               
                // Title with new name
                databaseOrmUDCDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentGraphModel.childrenId[0], language: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.duplicateToDocumentLanguage) as DatabaseOrmResult<UDCDocumentGraphModel>
                if databaseOrmUDCDocumentGraphModel!.databaseOrmError.count > 0 {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentGraphModel!.databaseOrmError[0].name, description: databaseOrmUDCDocumentGraphModel!.databaseOrmError[0].description))
                    return
                }
                let udcDocumentGraphModelLanguageTitle = databaseOrmUDCDocumentGraphModel!.object[0]
                udcDocumentGraphModelLanguageTitle.idName = englishIdName
                udcDocumentGraphModelLanguageTitle.name = name
                //            udcDocumentGraphModelLanguageTitle.idName = name.capitalized.trimmingCharacters(in: .whitespaces)
                // Remove the texts after the first text to make way for new title
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
                
                
                udcDocument.name = name
            } else {
                var udcDocumentGraphModelLanguageTitle: UDCDocumentGraphModel?
                
                let databaseOrmUDCDocumentGraphModelTitle = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentGraphModel.childrenId[0]) as DatabaseOrmResult<UDCDocumentGraphModel>
                if databaseOrmUDCDocumentGraphModelTitle.databaseOrmError.count > 0 {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentGraphModelTitle.databaseOrmError[0].name, description: databaseOrmUDCDocumentGraphModelTitle.databaseOrmError[0].description))
                    return
                }
                udcDocumentGraphModelLanguageTitle = databaseOrmUDCDocumentGraphModelTitle.object[0]
                if generateDocumentGraphViewRequest.getDocumentGraphViewRequest.isConfigurationView {
                    
                    
                    let databaseOrmUDCDocumentGraphModelParentTitle = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: generateDocumentGraphViewRequest.detailParentDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentGraphModelParent!.childrenId[0]) as DatabaseOrmResult<UDCDocumentGraphModel>
                    if databaseOrmUDCDocumentGraphModelParentTitle.databaseOrmError.count > 0 {
                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentGraphModelParentTitle.databaseOrmError[0].name, description: databaseOrmUDCDocumentGraphModelParentTitle.databaseOrmError[0].description))
                        return
                    }
                    let udcDocumentGraphModelParentTitle = databaseOrmUDCDocumentGraphModelParentTitle.object[0]
                    
                    udcDocumentGraphModelLanguageTitle!.idName = udcDocumentParentEn!.idName.replacingOccurrences(of: "UDCDocument", with: neuronUtility!.getCollectionName(udcDocumentTypeIdName: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcDocumentTypeIdName)!)
                    udcDocumentGraphModelLanguageTitle!.name = udcDocumentGraphModelParentTitle.name
                    udcDocumentGraphModelLanguageTitle!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.removeAll()
                    udcDocumentGraphModelLanguageTitle!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.append(UDCSentencePatternDataGroupValue())
                    udcDocumentGraphModelLanguageTitle!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].udcDocumentId = generateDocumentGraphViewRequest.detailParentDocumentId
                    udcDocumentGraphModelLanguageTitle!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].category = "UDCGrammarCategory.CommonNoun"
                    udcDocumentGraphModelLanguageTitle!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].endCategoryId = "UDCDocumentType.DocumentItem"
                    udcDocumentGraphModelLanguageTitle!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].endCategoryIdName = "UDCDocumentItem.Document"
                    udcDocumentGraphModelLanguageTitle!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].itemId = udcDocumentParent!._id
                    udcDocumentGraphModelLanguageTitle!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].item = udcDocumentGraphModelLanguageTitle!.name
                    udcDocumentGraphModelLanguageTitle!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].itemIdName = udcDocumentParent!.idName
                    udcDocumentGraphModelLanguageTitle!.udcSentencePattern = try processGrammar(neuronRequest: neuronRequest, neuronResponse: &neuronResponse, udcSentencePattern: udcDocumentGraphModelLanguageTitle!.udcSentencePattern, newSentence: true, wordIndex: 0, sentenceIndex: 0, documentLanguage: documentLanguage, textStartIndex: 0)
                    
                    // Save the language title
                    udcDocumentGraphModelLanguageTitle!.language = generateDocumentGraphViewRequest.getDocumentGraphViewRequest.documentLanguage
                    udcDocumentGraphModelLanguageTitle!.udcDocumentTime.changedBy = profileId
                    udcDocumentGraphModelLanguageTitle!.udcDocumentTime.changedTime = Date()
                    let databaseOrmUDCDocumentGraphModelSave = UDCDocumentGraphModel.update(collectionName:  neuronUtility!.getCollectionName(udcDocumentTypeIdName: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentGraphModelLanguageTitle!)
                    if databaseOrmUDCDocumentGraphModelSave.databaseOrmError.count > 0 {
                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentGraphModelSave.databaseOrmError[0].name, description: databaseOrmUDCDocumentGraphModelSave.databaseOrmError[0].description))
                        return
                    }
                    
                    udcDocument.name = udcDocumentGraphModelParentTitle.name
                } else {
                    udcDocumentGraphModelLanguageTitle!.idName = udcDocumentGraphModel.idName
                    if documentLanguage != "en" {
                        var englishNameArray = [String]()
                        for udcspdgv in getSentencePatternForDocumentItemResponse.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue {
                            if udcspdgv.itemIdName == "UDCDocumentItem.TranslationSeparator" {
                                break
                            }
                            englishNameArray.append(udcspdgv.item!)
                        }
                        udcDocumentGraphModelLanguageTitle!.name = englishNameArray.joined(separator: " ")
                    } else {
                        udcDocumentGraphModelLanguageTitle!.name = udcDocumentGraphModel.name
                    }
                    udcDocumentGraphModelLanguageTitle!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.removeAll()
                    udcDocumentGraphModelLanguageTitle!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.append(UDCSentencePatternDataGroupValue())
                    if generateDocumentGraphViewRequest.isDetailNameUseSource {
                        udcDocumentGraphModelLanguageTitle!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].udcDocumentId = documentIdForSource
                    } else {
                        udcDocumentGraphModelLanguageTitle!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].udcDocumentId = generateDocumentGraphViewRequest.detailParentDocumentId
                    }
                    udcDocumentGraphModelLanguageTitle!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].category = getSentencePatternForDocumentItemResponse.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].category
                    udcDocumentGraphModelLanguageTitle!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].endCategoryId = getSentencePatternForDocumentItemResponse.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].endCategoryId
                    udcDocumentGraphModelLanguageTitle!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].endCategoryIdName = getSentencePatternForDocumentItemResponse.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].endCategoryIdName
                    udcDocumentGraphModelLanguageTitle!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].endSubCategoryId = getSentencePatternForDocumentItemResponse.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].endSubCategoryId
                    udcDocumentGraphModelLanguageTitle!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].endSubCategoryIdName = getSentencePatternForDocumentItemResponse.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].endSubCategoryIdName
                    udcDocumentGraphModelLanguageTitle!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].itemId = getSentencePatternForDocumentItemResponse.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].itemId
                    udcDocumentGraphModelLanguageTitle!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].item = getSentencePatternForDocumentItemResponse.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].item
                    udcDocumentGraphModelLanguageTitle!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].itemIdName = getSentencePatternForDocumentItemResponse.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].itemIdName
                    udcDocumentGraphModelLanguageTitle!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].uvcViewItemType = getSentencePatternForDocumentItemResponse.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].uvcViewItemType

                    udcDocumentGraphModelLanguageTitle!.udcSentencePattern = try processGrammar(neuronRequest: neuronRequest, neuronResponse: &neuronResponse, udcSentencePattern: udcDocumentGraphModelLanguageTitle!.udcSentencePattern, newSentence: true, wordIndex: 0, sentenceIndex: 0, documentLanguage: documentLanguage, textStartIndex: 0)
                    udcDocumentGraphModelLanguageTitle!.name = udcDocumentGraphModelLanguageTitle!.udcSentencePattern.sentence
                    
                    if generateDocumentGraphViewRequest.isDetailNameUseSource {
                        
                        try putReference(udcDocumentId: documentIdForSource, udcDocumentGraphModelId: udcDocumentGraphModelLanguageTitle!.getSentencePatternGroupValue(wordIndex: 0).itemId, udcDocumentTypeIdName: "UDCDocumentType.DocumentItem", objectUdcDocumentTypeIdName: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcDocumentTypeIdName, objectId: udcDocumentGraphModelLanguageTitle!._id, objectName:  neuronUtility!.getCollectionName(udcDocumentTypeIdName: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcDocumentTypeIdName)!, documentLanguage: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.documentLanguage, udcProfile: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcProfile, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
                    }
                    // Save the language title
                    udcDocumentGraphModelLanguageTitle!.language = generateDocumentGraphViewRequest.getDocumentGraphViewRequest.documentLanguage
                    udcDocumentGraphModelLanguageTitle!.udcDocumentTime.changedBy = profileId
                    udcDocumentGraphModelLanguageTitle!.udcDocumentTime.changedTime = Date()
                    let databaseOrmUDCDocumentGraphModelSave = UDCDocumentGraphModel.update(collectionName:  neuronUtility!.getCollectionName(udcDocumentTypeIdName: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentGraphModelLanguageTitle!)
                    if databaseOrmUDCDocumentGraphModelSave.databaseOrmError.count > 0 {
                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentGraphModelSave.databaseOrmError[0].name, description: databaseOrmUDCDocumentGraphModelSave.databaseOrmError[0].description))
                        return
                    }
                    
                    udcDocument.name = udcDocumentGraphModelLanguageTitle!.name
                }
            }
            
            
            // Update with new childs
            databaseOrmUDCDocumentGraphModelSave = UDCDocumentGraphModel.update(collectionName:  neuronUtility!.getCollectionName(udcDocumentTypeIdName: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentGraphModel)
            if databaseOrmUDCDocumentGraphModelSave.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentGraphModelSave.databaseOrmError[0].name, description: databaseOrmUDCDocumentGraphModelSave.databaseOrmError[0].description))
                return
            }
            
            // Save the document
            let databaseOrmUDCDocumentSave = UDCDocument.save(udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocument)
            if databaseOrmUDCDocumentSave.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentSave.databaseOrmError[0].name, description: databaseOrmUDCDocumentSave.databaseOrmError[0].description))
                return
            }
            if !generateDocumentGraphViewRequest.getDocumentGraphViewRequest.isConfigurationView {
                documentLanguage = generateDocumentGraphViewRequest.getDocumentGraphViewRequest.duplicateToDocumentLanguage
            }
            generateDocumentGraphViewResponse.name = udcDocument.name
        }
        generateDocumentGraphViewResponse.documentId = udcDocument._id
        
        
//        udcDocumentGraphModel!.udcSentencePattern = try processGrammar(neuronRequest: neuronRequest, neuronResponse: &neuronResponse, udcSentencePattern: udcDocumentGraphModel!.udcSentencePattern, newSentence: true, wordIndex: 0, sentenceIndex: 0, documentLanguage: documentLanguage, textStartIndex: 0)
//
//        let uvcViewModelArray = generateSentenceViewAsArray(udcDocumentGraphModel: udcDocumentGraphModel!, uvcViewItemCollection: UVCViewItemCollection(), neuronRequest: neuronRequest, neuronResponse: &neuronResponse, newView: true, isEditable: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.editMode, level: udcDocumentGraphModel!.level, nodeIndex: Int.max, itemIndex: Int.max, documentLanguage: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.documentLanguage)
//        for (udcspgvIndex, udcspgv) in udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.enumerated() {
//            uvcViewModelArray[udcspgvIndex].udcViewItemId = udcspgv.udcViewItemId
//            uvcViewModelArray[udcspgvIndex].udcViewItemName = udcspgv.udcViewItemName
//        }
//        generateDocumentGraphViewResponse.documentTitle = udcDocumentGraphModel!.udcSentencePattern.sentence
//        let uvcDocumentGraphModel = UVCDocumentGraphModel()
//        uvcDocumentGraphModel._id = udcDocumentGraphModel!._id
//        uvcDocumentGraphModel.uvcViewModel.append(contentsOf: uvcViewModelArray)
//        uvcDocumentGraphModel.level = udcDocumentGraphModel!.level
//        if udcDocumentGraphModel!.childrenId.count > 0 {
//            uvcDocumentGraphModel.childrenId.append(contentsOf: udcDocumentGraphModel!.childrenId)
//        }
//
//        if generateDocumentGraphViewRequest.getDocumentGraphViewRequest.editMode {
//            let databaseOrmUDCDocumentItemMapNode = UDCDocumentItemMapNode.get("UDCDocumentItemMapNode.SearchDocumentItems", udbcDatabaseOrm!, documentLanguage)
//            if databaseOrmUDCDocumentItemMapNode.databaseOrmError.count > 0 {
//                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentItemMapNode.databaseOrmError[0].name, description: databaseOrmUDCDocumentItemMapNode.databaseOrmError[0].description))
//                return
//            }
//            let searchDocumentItem = databaseOrmUDCDocumentItemMapNode.object
//            let uvcm = uvcViewGenerator.getSearchBoxViewModel(name: searchDocumentItem[0].idName, value: "", level: uvcDocumentGraphModel.level, pictureName: "Elipsis", helpText: searchDocumentItem[0].name, parentId: [], childrenId: [], udbcDatabsaeOrm: udbcDatabaseOrm!, language: documentLanguage, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, neuronUtility: neuronUtility)
//            uvcm.textLength = 25
//            uvcDocumentGraphModel.uvcViewModel.append(uvcm)
//        }
//
//        uvcDocumentGraphModel.isChildrenAllowed = udcDocumentGraphModel!.isChildrenAllowed
//
//        uvcDocumentGraphModelArray.append(uvcDocumentGraphModel)
//
//        var nodeIndexLocal = 0
//        try getDocumentViewModel(childrenId: udcDocumentGraphModel!.childrenId, uvcDocumentGraphModelArray: &uvcDocumentGraphModelArray, udcDocumentTypeIdName:  generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcDocumentTypeIdName, isEditableMode: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.editMode, nodeIndex: &nodeIndexLocal, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, documentLanguage: documentLanguage)
        
    }
    
    private func generateDocumentGraphModelView(udcDocumentGraphModel: UDCDocumentGraphModel, uvcDocumentGraphModelArray: inout [UVCDocumentGraphModel], udcDocumentTypeIdName: String, documentLanguage: String, isEditableMode: Bool, documentTitle: inout String, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
//        if documentLanguage != "en" {
//            udcDocumentGraphModel.udcSentencePattern = try processGrammar(neuronRequest: neuronRequest, neuronResponse: &neuronResponse, udcSentencePattern: udcDocumentGraphModel.udcSentencePattern, newSentence: true, wordIndex: 0, sentenceIndex: 0, documentLanguage: documentLanguage, textStartIndex: 0)
//
//            let uvcViewModelArray = generateSentenceViewAsArray(udcDocumentGraphModel: udcDocumentGraphModel, uvcViewItemCollection: UVCViewItemCollection(), neuronRequest: neuronRequest, neuronResponse: &neuronResponse, newView: true, isEditable: isEditableMode, level: udcDocumentGraphModel.level, nodeIndex: Int.max, itemIndex: Int.max, documentLanguage: documentLanguage)
//            for (udcspgvIndex, udcspgv) in udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.enumerated() {
//                uvcViewModelArray[udcspgvIndex].udcViewItemId = udcspgv.udcViewItemId
//                uvcViewModelArray[udcspgvIndex].udcViewItemName = udcspgv.udcViewItemName
//            }
//            documentTitle = udcDocumentGraphModel.udcSentencePattern.sentence
//            let uvcDocumentGraphModel = UVCDocumentGraphModel()
//            uvcDocumentGraphModel._id = udcDocumentGraphModel._id
//            uvcDocumentGraphModel.uvcViewModel.append(contentsOf: uvcViewModelArray)
//            uvcDocumentGraphModel.level = udcDocumentGraphModel.level
//            if udcDocumentGraphModel.childrenId.count > 0 {
//                uvcDocumentGraphModel.childrenId.append(contentsOf: udcDocumentGraphModel.childrenId)
//            }
//
//
//
//            uvcDocumentGraphModel.isChildrenAllowed = udcDocumentGraphModel.isChildrenAllowed
//
//            uvcDocumentGraphModelArray.append(uvcDocumentGraphModel)
//        }
        
        var nodeIndexLocal = 0
        try getDocumentViewModel(childrenId: udcDocumentGraphModel.childrenId, uvcDocumentGraphModelArray: &uvcDocumentGraphModelArray, udcDocumentTypeIdName:  udcDocumentTypeIdName, isEditableMode: isEditableMode, nodeIndex: &nodeIndexLocal, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, documentLanguage: documentLanguage)
        if isEditableMode {
            let databaseOrmUDCDocumentItemMapNode = UDCDocumentItemMapNode.get("UDCDocumentItemMapNode.SearchDocumentItems", udbcDatabaseOrm!, documentLanguage)
            if databaseOrmUDCDocumentItemMapNode.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentItemMapNode.databaseOrmError[0].name, description: databaseOrmUDCDocumentItemMapNode.databaseOrmError[0].description))
                return
            }
            let searchDocumentItem = databaseOrmUDCDocumentItemMapNode.object
            let uvcm = uvcViewGenerator.getSearchBoxViewModel(name: searchDocumentItem[0].idName, value: "", level: 1, pictureName: "Elipsis", helpText: searchDocumentItem[0].name, parentId: [], childrenId: [],language: documentLanguage)
            uvcm.textLength = 25
            uvcDocumentGraphModelArray[0].uvcViewModel.append(uvcm)
        }
    }
    
    private func findAndGetName(documentId: String, parentIdName: String, findIdName: String, udcDocumentTypeIdName: String, udcProfile: [UDCProfile], documentLanguage: String, duplicateToDocumentLanguage: String, translatedName: inout String, traslatedDocumentId: inout String, translatedNameId: inout String, translatedNameIdName: inout String, translatedNameCategoryId: inout String, translatedNameCategoryIdName: inout String, translatedNameSubCategoryId: inout String, translatedNameSubCategoryIdName: inout String,  neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: documentId)
        if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocument.databaseOrmError[0].name, description: databaseOrmResultUDCDocument.databaseOrmError[0].description))
            return
        }
        let udcDocument = databaseOrmResultUDCDocument.object[0]
        let databaseOrmResultUDCDocumentLanguage = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, documentGroupId: udcDocument.documentGroupId, notEqualsId: udcDocument._id, language: duplicateToDocumentLanguage)
        if databaseOrmResultUDCDocumentLanguage.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentLanguage.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentLanguage.databaseOrmError[0].description))
            return
        }
        let udcDocumentLanguage = databaseOrmResultUDCDocumentLanguage.object[0]
        traslatedDocumentId = udcDocumentLanguage._id
        let databaseOrmResultUDCDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentLanguage.udcDocumentGraphModelId)
        if databaseOrmResultUDCDocumentGraphModel.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentGraphModel.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentGraphModel.databaseOrmError[0].description))
            return
        }
        findAndGetName(childrenId: databaseOrmResultUDCDocumentGraphModel.object[0].childrenId, parentIdName: parentIdName, findIdName: findIdName, udcDocumentTypeIdName: udcDocumentTypeIdName, udcProfile: udcProfile, documentLanguage: documentLanguage, translatedName: &translatedName,  translatedNameId: &translatedNameId, translatedNameIdName: &translatedNameIdName, translatedNameCategoryId: &translatedNameCategoryId, translatedNameCategoryIdName: &translatedNameCategoryIdName, translatedNameSubCategoryId: &translatedNameSubCategoryId, translatedNameSubCategoryIdName: &translatedNameSubCategoryIdName, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
    }
    
    private func findAndGetName(childrenId: [String],  parentIdName: String, findIdName: String, udcDocumentTypeIdName: String, udcProfile: [UDCProfile], documentLanguage: String,  translatedName: inout String, translatedNameId: inout String, translatedNameIdName: inout String, translatedNameCategoryId: inout String, translatedNameCategoryIdName: inout String, translatedNameSubCategoryId: inout String, translatedNameSubCategoryIdName: inout String, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) {
        
        for child in childrenId {
            let databaseOrmResultUDCDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, id: child)
            let udcDocumentGraphModel = databaseOrmResultUDCDocumentGraphModel.object[0]
            
            if udcDocumentGraphModel.idName == parentIdName {
                
                for child1 in udcDocumentGraphModel.childrenId {
                    let databaseOrmResultUDCDocumentGraphModel1 = UDCDocumentGraphModel.get(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, id: child1)
                    let udcDocumentGraphModel1 = databaseOrmResultUDCDocumentGraphModel1.object[0]
                    if udcDocumentGraphModel1.idName == findIdName {
                        if udcDocumentGraphModel.level == 1 {
                            translatedNameCategoryId = udcDocumentGraphModel._id
                            translatedNameCategoryIdName = udcDocumentGraphModel.idName
                            translatedNameSubCategoryId = ""
                            translatedNameSubCategoryIdName = ""
                        } else {
                            let databaseOrmResultUDCDocumentGraphModelParent = UDCDocumentGraphModel.get(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentGraphModel.parentId[0])
                            translatedNameCategoryId = databaseOrmResultUDCDocumentGraphModelParent.object[0]._id
                            translatedNameCategoryIdName = databaseOrmResultUDCDocumentGraphModelParent.object[0].idName
                            translatedNameSubCategoryId = udcDocumentGraphModel._id
                            translatedNameSubCategoryIdName = udcDocumentGraphModel.idName
                        }
                        translatedName = udcDocumentGraphModel1.name
                        translatedNameId = udcDocumentGraphModel1._id
                        translatedNameIdName = udcDocumentGraphModel1.idName
                    }
                }
            }
            
            if udcDocumentGraphModel.childrenId.count > 0 {
                findAndGetName(childrenId: udcDocumentGraphModel.childrenId, parentIdName: parentIdName, findIdName: findIdName, udcDocumentTypeIdName: udcDocumentTypeIdName, udcProfile: udcProfile, documentLanguage: documentLanguage, translatedName: &translatedName, translatedNameId: &translatedNameId, translatedNameIdName: &translatedNameIdName, translatedNameCategoryId: &translatedNameCategoryId, translatedNameCategoryIdName: &translatedNameCategoryIdName, translatedNameSubCategoryId: &translatedNameSubCategoryId, translatedNameSubCategoryIdName: &translatedNameSubCategoryIdName, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            }
            
        }
        
    }
    
    private func duplicateDocumentGraphModel(parentId: String, childrenId: [String], newChildrenId: inout [String],  levelChildrenId: inout [String: [String]], udcDocumentTypeIdName: String, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest, profileId: String, udcProfile: [UDCProfile], documentLanguage: String, duplicateToDocumentLanguage: String, udcDocumentId: String) throws {
        for id in childrenId {
            let databaseOrmUDCDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: id, language: documentLanguage) as DatabaseOrmResult<UDCDocumentGraphModel>
            if databaseOrmUDCDocumentGraphModel.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentGraphModel.databaseOrmError[0].name, description: databaseOrmUDCDocumentGraphModel.databaseOrmError[0].description))
                return
            }
            let udcDocumentGraphModel = databaseOrmUDCDocumentGraphModel.object[0]
            if udcDocumentGraphModel.level == 0 {
                udcDocumentGraphModel.parentId.removeAll()
            }
            udcDocumentGraphModel.objectName = ""
            udcDocumentGraphModel.objectId = ""
            udcDocumentGraphModel.documentMapObjectId = ""
            udcDocumentGraphModel.documentMapObjectName = ""
            udcDocumentGraphModel.udcDocumentGraphModelReferenceId = ""
            udcDocumentGraphModel._id = try (udbcDatabaseOrm?.generateId())!
            if udcDocumentGraphModel.level == 1 {
                newChildrenId.append(udcDocumentGraphModel._id)
                print("Duplicate: Adding: \(parentId)-> level \(udcDocumentGraphModel._id) id: \(id)")
            }
            if levelChildrenId[parentId] == nil {
                levelChildrenId[parentId] = [String]()
            }
            levelChildrenId[parentId]?.append(udcDocumentGraphModel._id)
            let isTranslated = duplicateToDocumentLanguage != "en" && documentLanguage != duplicateToDocumentLanguage
            for (udcspdgvIndex, udcspdgv) in udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.enumerated() {
                
                if isTranslated {
                    let parentIdName = udcspdgv.endSubCategoryIdName.isEmpty ? udcspdgv.endCategoryIdName : udcspdgv.endSubCategoryIdName
                    if !parentIdName.isEmpty && !udcspdgv.itemIdName.isEmpty && udcDocumentGraphModel.level > 1 {
                        var translatedName: String = ""
                        var traslatedDocumentId: String = ""
                        var translatedNameId: String = ""
                        var translatedNameCategoryId: String = ""
                        var translatedNameCategoryIdName: String = ""
                        var translatedNameSubCategoryId: String = ""
                        var translatedNameSubCategoryIdName: String = ""
                        var translatedNameIdName: String = ""
                        try findAndGetName(documentId: udcspdgv.udcDocumentId, parentIdName: parentIdName, findIdName: udcspdgv.itemIdName, udcDocumentTypeIdName: udcDocumentTypeIdName, udcProfile: udcProfile, documentLanguage:  documentLanguage, duplicateToDocumentLanguage: duplicateToDocumentLanguage, translatedName: &translatedName, traslatedDocumentId: &traslatedDocumentId, translatedNameId: &translatedNameId, translatedNameIdName: &translatedNameIdName, translatedNameCategoryId: &translatedNameCategoryId, translatedNameCategoryIdName: &translatedNameCategoryIdName, translatedNameSubCategoryId: &translatedNameSubCategoryId, translatedNameSubCategoryIdName: &translatedNameSubCategoryIdName, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
                        if !translatedName.isEmpty {
                            udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].item = translatedName
                            udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].itemId = translatedNameId
                            udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].itemIdName = translatedNameIdName
                            udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].endCategoryId = translatedNameCategoryId
                            udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].endCategoryIdName = translatedNameCategoryIdName
                            udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].endSubCategoryId = translatedNameSubCategoryId
                            udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].endSubCategoryIdName = translatedNameSubCategoryIdName
                            udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].udcDocumentId = traslatedDocumentId
                            
                            udcDocumentGraphModel.udcSentencePattern.sentence = translatedName
                            udcDocumentGraphModel.name = translatedName
                            
                        }
                    }
                }
                
                if !udcspdgv.udcDocumentId.isEmpty && udcspdgv.itemIdName.hasPrefix("UDCDocumentItem.") && !udcspdgv.itemIdName.hasSuffix(".Blank") {
                    try putReference(udcDocumentId: udcDocumentId, udcDocumentGraphModelId: udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].itemId, udcDocumentTypeIdName: "UDCDocumentType.DocumentItem", objectUdcDocumentTypeIdName: udcDocumentTypeIdName, objectId: udcDocumentGraphModel._id, objectName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!, documentLanguage: documentLanguage, udcProfile: udcProfile, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
                }
            }
            udcDocumentGraphModel.language = duplicateToDocumentLanguage
            udcDocumentGraphModel.udcDocumentTime.createdBy = profileId
            udcDocumentGraphModel.udcDocumentTime.creationTime = Date()
            udcDocumentGraphModel.parentId.removeAll()
            udcDocumentGraphModel.parentId.append(parentId)
            if udcDocumentGraphModel.childrenId.count > 0 {
                try duplicateDocumentGraphModel(parentId: udcDocumentGraphModel._id, childrenId: udcDocumentGraphModel.childrenId, newChildrenId: &newChildrenId, levelChildrenId: &levelChildrenId, udcDocumentTypeIdName: udcDocumentTypeIdName, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, profileId: profileId, udcProfile: udcProfile, documentLanguage: documentLanguage, duplicateToDocumentLanguage: duplicateToDocumentLanguage, udcDocumentId: udcDocumentId)
                udcDocumentGraphModel.childrenId.removeAll()
                for id in  levelChildrenId {
                    print("Duplicate: Adding:\(parentId)->  level \(udcDocumentGraphModel.level) id: \(id)")
                }
                udcDocumentGraphModel.childrenId.append(contentsOf: levelChildrenId[udcDocumentGraphModel._id]!)
            }
            let databaseOrmUDCDocumentGraphModelSave = UDCDocumentGraphModel.save(collectionName:  neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentGraphModel)
            if databaseOrmUDCDocumentGraphModelSave.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentGraphModelSave.databaseOrmError[0].name, description: databaseOrmUDCDocumentGraphModelSave.databaseOrmError[0].description))
                return
            }
        }
    }
    
    private func getDocumentViewModel(childrenId: [String], uvcDocumentGraphModelArray: inout [UVCDocumentGraphModel], udcDocumentTypeIdName: String, isEditableMode: Bool, nodeIndex: inout Int, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest, documentLanguage: String) throws {
        for id in childrenId {
            nodeIndex += 1
            let databaseOrmUDCDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: id, language: documentLanguage) as DatabaseOrmResult<UDCDocumentGraphModel>
            if databaseOrmUDCDocumentGraphModel.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentGraphModel.databaseOrmError[0].name, description: databaseOrmUDCDocumentGraphModel.databaseOrmError[0].description))
                return
            }
            let udcDocumentGraphModel = databaseOrmUDCDocumentGraphModel.object[0]
            udcDocumentGraphModel.udcSentencePattern = try processGrammar(neuronRequest: neuronRequest, neuronResponse: &neuronResponse, udcSentencePattern: udcDocumentGraphModel.udcSentencePattern, newSentence: true, wordIndex: 0, sentenceIndex: 0, documentLanguage: documentLanguage, textStartIndex: 0)
            
            let uvcViewModelArray = try generateSentenceViewAsArray(udcDocumentGraphModel: udcDocumentGraphModel, uvcViewItemCollection: UVCViewItemCollection(), neuronRequest: neuronRequest, neuronResponse: &neuronResponse, newView: false, isEditable: isEditableMode, level: udcDocumentGraphModel.level, nodeIndex: nodeIndex, itemIndex: Int.max, documentLanguage: documentLanguage)
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
                try getDocumentViewModel(childrenId: udcDocumentGraphModel.childrenId, uvcDocumentGraphModelArray: &uvcDocumentGraphModelArray, udcDocumentTypeIdName: udcDocumentTypeIdName, isEditableMode: isEditableMode, nodeIndex: &nodeIndex, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, documentLanguage: documentLanguage)
            }
        }
    }
    
    private func createDocumentType(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let createDocumentTypeRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: CreateDocumentTypeRequest())
        var englishIdName: String = ""
        var englishName: String = ""
        var udcDocumentTypeIdName: String = ""
        var documentTypeNameEnglish: String = ""
        var idName: String = ""
        
        for createDocumentTypeData in createDocumentTypeRequest.createDocumentTypeData {
            // Save the document type model
            let udcDocumentType = UDCDocumentType()
            udcDocumentType._id = try udbcDatabaseOrm!.generateId()
            // Assumes "en" is the first item in the list
            if createDocumentTypeData.language == "en" {
                idName = "\(UDCDocumentType.getName()).\(createDocumentTypeData.name.capitalized.replacingOccurrences(of: " ", with: ""))"
            }
            // if already exist return
            let databaseOrmResultUDCDocumentTypeGet = UDCDocumentType.get(idName: idName, udbcDatabaseOrm: udbcDatabaseOrm!, language: createDocumentTypeData.language)
            if databaseOrmResultUDCDocumentTypeGet.databaseOrmError.count == 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "AlreadyExist", description: "Already exist"))
                return
            }
            
            let name = createDocumentTypeData.name.lowercased()
            udcDocumentType.idName = idName
            udcDocumentType.name = name
            udcDocumentType.language = createDocumentTypeData.language
            udcDocumentType.udcGrammarCategory = "UDCGrammarCategory.CommonNoun"
            let databaseOrmResultUDCDocumentTypeSave = UDCDocumentType.save(udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentType) as DatabaseOrmResult<UDCDocumentType>
            if databaseOrmResultUDCDocumentTypeSave.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentTypeSave.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentTypeSave.databaseOrmError[0].description))
                return
            }
            
            // Create the application and document type model link
            if createDocumentTypeData.language == "en" {
                let udcApplicationDocumentType = UDCApplicationDocumentType()
                udcApplicationDocumentType._id = try udbcDatabaseOrm!.generateId()
                udcApplicationDocumentType.udcDocumentTypeIdName = idName
                udcApplicationDocumentType.udcProfile = createDocumentTypeRequest.udcProfile
                let databaseOrmResultUDCApplicationDocumentTypeSave = UDCApplicationDocumentType.save(udbcDatabaseOrm: udbcDatabaseOrm!, object: udcApplicationDocumentType) as DatabaseOrmResult<UDCApplicationDocumentType>
                if databaseOrmResultUDCApplicationDocumentTypeSave.databaseOrmError.count > 0 {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCApplicationDocumentTypeSave.databaseOrmError[0].name, description: databaseOrmResultUDCApplicationDocumentTypeSave.databaseOrmError[0].description))
                    return
                }
            }
            
            // Get the document map
            let databaseOrmResultUDCDocumentMapNodeGet = UDCDocumentMapNode.get(udbcDatabaseOrm: udbcDatabaseOrm!, idName: "UDCOptionMapNode.DocumentMap", language: createDocumentTypeData.language)
            if databaseOrmResultUDCDocumentMapNodeGet.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentMapNodeGet.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentMapNodeGet.databaseOrmError[0].description))
                return
            }
            let udcDocumentMapNodeDocumentMap = databaseOrmResultUDCDocumentMapNodeGet.object[0]
            
            // Create the document type's document map node
            let udcDocumentMapNode = UDCDocumentMapNode()
            udcDocumentMapNode._id = try udbcDatabaseOrm!.generateId()
            udcDocumentMapNode.idName = idName
            udcDocumentMapNode.name = name
            udcDocumentMapNode.language = createDocumentTypeData.language
            udcDocumentMapNode.level = 1
            udcDocumentMapNode.path.append(contentsOf: udcDocumentMapNodeDocumentMap.path)
            udcDocumentMapNode.path.append(name)
            udcDocumentMapNode.pathIdName.append(contentsOf: udcDocumentMapNodeDocumentMap.pathIdName)
            udcDocumentMapNode.pathIdName.append(idName)
            udcDocumentMapNode.udcDocumentType = "UDCDocumentType.None"
            udcDocumentMapNode.udcDocumentAccessType.append("UDCDocumentAccessType.Read")
            udcDocumentMapNode.parentId.append(udcDocumentMapNodeDocumentMap._id)
            // Add the new children
            udcDocumentMapNodeDocumentMap.childrenId.append(udcDocumentMapNode._id)
            
            // Get the document type template and add its children to the new document map node
            let databaseOrmResultUDCDocumentMap = UDCDocumentMap.get(udbcDatabaseOrm: udbcDatabaseOrm!, idName: "UDCOptionMap.DocumentTypeTemplate", udcProfile: createDocumentTypeRequest.udcProfile, language: createDocumentTypeData.language)
            if databaseOrmResultUDCDocumentMap.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentMap.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentMap.databaseOrmError[0].description))
                return
            }
            let udcDocumentMapDocumentTypeTemplate = databaseOrmResultUDCDocumentMap.object[0]
            let databaseOrmResultUDCDocumentMapNodeDocumentTypeTemplate = UDCDocumentMapNode.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentMapDocumentTypeTemplate.udcDocumentMapNodeId[0], language: createDocumentTypeData.language)
            if databaseOrmResultUDCDocumentMapNodeDocumentTypeTemplate.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentMapNodeDocumentTypeTemplate.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentMapNodeDocumentTypeTemplate.databaseOrmError[0].description))
                return
            }
            let udcDocumentMapNodeDocumentTypeTemplate = databaseOrmResultUDCDocumentMapNodeDocumentTypeTemplate.object[0]
            
            // Get the childrens
            var udcDocumentMapNodeDocumentType = [UDCDocumentMapNode]()
            try getDocumentMapNodeChildrens(parent: udcDocumentMapNode, givenChildrens: udcDocumentMapNodeDocumentTypeTemplate.childrenId, childrens: &udcDocumentMapNodeDocumentType, createDocumentTypeRequest: createDocumentTypeRequest, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, language: createDocumentTypeData.language)
            var allOptionId: String = ""
            var allOptionName: String = ""
            for udcdmn in udcDocumentMapNodeDocumentType {
                if udcdmn.idName == "UDCOptionMapNode.Recents" || udcdmn.idName == "UDCOptionMapNode.Favourites" {
                    udcdmn.childrenId.append("dummy")
                }
                if udcdmn.level == 2 {
                    udcDocumentMapNode.childrenId.append(udcdmn._id)
                }
                if udcdmn.idName == "UDCDocumentMapNode.All" {
                    allOptionId = udcdmn._id
                    allOptionName = udcdmn.name
                }
            }
            
            
            // Save the parent and childrens
            let databaseOrmResultUDCDocumentMapNodeSaveMapNode = UDCDocumentMapNode.save(udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentMapNode)
            if databaseOrmResultUDCDocumentMapNodeSaveMapNode.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentMapNodeSaveMapNode.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentMapNodeSaveMapNode.databaseOrmError[0].description))
                return
            }
            for udcdmndt in udcDocumentMapNodeDocumentType {
                let databaseOrmResultUDCDocumentMapNodeSaveMapNodeIndividual = UDCDocumentMapNode.save(udbcDatabaseOrm: udbcDatabaseOrm!, object: udcdmndt)
                if databaseOrmResultUDCDocumentMapNodeSaveMapNodeIndividual.databaseOrmError.count > 0 {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentMapNodeSaveMapNodeIndividual.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentMapNodeSaveMapNodeIndividual.databaseOrmError[0].description))
                    return
                }
            }
            
            // Save the all option
            let udcDocumentMapAll = UDCDocumentMap()
            udcDocumentMapAll._id = try udbcDatabaseOrm!.generateId()
            udcDocumentMapAll.idName = "\(idName.replacingOccurrences(of: "UDCDocumentType", with: "UDCDocumentMapNode"))All"
            udcDocumentMapAll.name = "\(name) \(allOptionName)"
            udcDocumentMapAll.language = createDocumentTypeData.language
            udcDocumentMapAll.udcProfile = createDocumentTypeRequest.udcProfile
            udcDocumentMapAll.udcDocumentMapNodeId.append(allOptionId)
            
            let databaseOrmResultUDCDocumentMapAll = UDCDocumentMap.save(udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentMapAll)
            if databaseOrmResultUDCDocumentMapAll.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentMapAll.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentMapAll.databaseOrmError[0].description))
                return
            }
            
            // Get and Update the document map with new children
            let databaseOrmResultUDCDocumentMapNodeSaveMap = UDCDocumentMapNode.update(udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentMapNodeDocumentMap)
            if databaseOrmResultUDCDocumentMapNodeSaveMap.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentMapNodeSaveMap.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentMapNodeSaveMap.databaseOrmError[0].description))
                return
            }
            
            // Get the document items to add
            let databaseOrmResultUDCDocumentItemMapDocumentItems = UDCDocumentItemMap.get(udbcDatabaseOrm: udbcDatabaseOrm!, idName: "UDCDocumentItemMap.DocumentItems", udcProfile: createDocumentTypeRequest.udcProfile, language: createDocumentTypeData.language)
            if databaseOrmResultUDCDocumentItemMapDocumentItems.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentItemMapDocumentItems.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentItemMapDocumentItems.databaseOrmError[0].description))
                return
            }
            let udcDocumentItemMapDocumentItems = databaseOrmResultUDCDocumentItemMapDocumentItems.object[0]
            
            // Get the document item map template
            let databaseOrmResultUDCDocumentItemMapDocumentItemsTemplate = UDCDocumentItemMap.get(udbcDatabaseOrm: udbcDatabaseOrm!, idName: "UDCDocumentItemMap.DocumentItemsTemplate", udcProfile: createDocumentTypeRequest.udcProfile, language: createDocumentTypeData.language)
            if databaseOrmResultUDCDocumentItemMapDocumentItemsTemplate.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentItemMapDocumentItemsTemplate.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentItemMapDocumentItemsTemplate.databaseOrmError[0].description))
                return
            }
            let udcDocumentItemMapDocumentItemsTemplate = databaseOrmResultUDCDocumentItemMapDocumentItemsTemplate.object[0]
            
            let databaseOrmResultUDCDocumentItemMapNodeDocumenItesTemplateData = UDCDocumentItemMapNode.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentItemMapDocumentItemsTemplate.udcDocumentItemMapNodeId[0], language: createDocumentTypeData.language)
            if databaseOrmResultUDCDocumentItemMapNodeDocumenItesTemplateData.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentItemMapNodeDocumenItesTemplateData.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentItemMapNodeDocumenItesTemplateData.databaseOrmError[0].description))
                return
            }
            let udcDocumentItemMapNodeDocumenItesTemplateData = databaseOrmResultUDCDocumentItemMapNodeDocumenItesTemplateData.object[0]
            
            // Get the childrens of the template and prepare for saving
            var udcDocumentItemMapNode = [UDCDocumentItemMapNode]()
            try getDocumentItemMapNodeChildrens(parent: udcDocumentItemMapDocumentItems, givenChildrens: udcDocumentItemMapNodeDocumenItesTemplateData.childrenId, childrens: &udcDocumentItemMapNode,neuronRequest: neuronRequest, neuronResponse: &neuronResponse, language: createDocumentTypeData.language)
            for udcdimn in udcDocumentItemMapNode {
                udcdimn.udcDocumentTypeIdName = idName
                udcDocumentItemMapDocumentItems.udcDocumentItemMapNodeId.append(udcdimn._id)
            }
            
            // Save the childrens and its parents
            for udcdimn in udcDocumentItemMapNode {
                let databaseOrmResultUDCDocumentItemMapNodeSaveMapNodeChild = UDCDocumentItemMapNode.save(udbcDatabaseOrm: udbcDatabaseOrm!, object: udcdimn)
                if databaseOrmResultUDCDocumentItemMapNodeSaveMapNodeChild.databaseOrmError.count > 0 {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentItemMapNodeSaveMapNodeChild.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentItemMapNodeSaveMapNodeChild.databaseOrmError[0].description))
                    return
                }
            }
            
            // Save the new document items for the new document type
            udcDocumentItemMapNodeDocumenItesTemplateData._id = try udbcDatabaseOrm!.generateId()
            udcDocumentItemMapNodeDocumenItesTemplateData.udcDocumentTypeIdName = idName
            let split = udcDocumentItemMapNodeDocumenItesTemplateData.name.components(separatedBy: " ")
            udcDocumentItemMapNodeDocumenItesTemplateData.name = "\(split[0]) \(split[1])"
            udcDocumentItemMapNodeDocumenItesTemplateData.idName = udcDocumentItemMapNodeDocumenItesTemplateData.idName.replacingOccurrences(of: "Template", with: "")
            udcDocumentItemMapNodeDocumenItesTemplateData.pathIdName[0] = udcDocumentItemMapNodeDocumenItesTemplateData.idName
            let databaseOrmResultUDCDocumentItemMapNodeSaveMapData = UDCDocumentItemMapNode.save(udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentItemMapNodeDocumenItesTemplateData)
            if databaseOrmResultUDCDocumentItemMapNodeSaveMapData.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentItemMapNodeSaveMapData.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentItemMapNodeSaveMapData.databaseOrmError[0].description))
                return
            }
            udcDocumentItemMapDocumentItems.udcDocumentItemMapNodeId.append(udcDocumentItemMapNodeDocumenItesTemplateData._id)
            
            let databaseOrmResultUDCDocumentItemMapNodeSaveMap = UDCDocumentItemMap.update(udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentItemMapDocumentItems)
            if databaseOrmResultUDCDocumentItemMapNodeSaveMap.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentItemMapNodeSaveMap.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentItemMapNodeSaveMap.databaseOrmError[0].description))
                return
            }
            
            // Create the word dictionary in document item
            try createWordDictionaryForDocumentType(udcProfile: createDocumentTypeRequest.udcProfile, documentTypeName: createDocumentTypeData.name, documentTypeNameEnglish: &documentTypeNameEnglish, englishIdName: &englishIdName, englishName: &englishName, language: createDocumentTypeData.language, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        }
        
    }
    
    private func createWordDictionaryForDocumentType(udcProfile: [UDCProfile], documentTypeName: String, documentTypeNameEnglish: inout String, englishIdName: inout String, englishName: inout String, language: String, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let databaseOrmResultUDCDocumentEn = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, udcProfile: udcProfile, udcDocumentTypeIdName: "UDCDocumentType.DocumentItem", idName: "UDCDocument.WordDictionaryTemplate", language: language)
        if databaseOrmResultUDCDocumentEn.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentEn.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentEn.databaseOrmError[0].description))
            return
        }
        let udcDocument = databaseOrmResultUDCDocumentEn.object[0]
        
        let split = udcDocument.name.split(separator: " ")
        let suffix = "\(split[0]) \(split[1])".capitalized
        let documentItemName = "\(documentTypeName.capitalized) \(suffix)"
        let documentItemIdName: String = "UDCDocumentItem.\(documentItemName.replacingOccurrences(of: " ", with: ""))"
        if language == "en" {
            documentTypeNameEnglish = documentTypeName
            englishName = documentItemName
            englishIdName = documentItemIdName
        }
        udcDocument._id = try udbcDatabaseOrm!.generateId()
        udcDocument.idName = englishIdName.replacingOccurrences(of: "UDCDocumentItem", with: "UDCDocument")
        let databaseOrmResultUDCDocumentGet = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, udcProfile: udcProfile, udcDocumentTypeIdName: "UDCDocumentType.DocumentItem", idName: udcDocument.idName, language: "en")
        if databaseOrmResultUDCDocumentGet.databaseOrmError.count == 0 {
            udcDocument.documentGroupId = databaseOrmResultUDCDocumentGet.object[0].documentGroupId
        } else {
            udcDocument.documentGroupId = try udbcDatabaseOrm!.generateId()
        }
        udcDocument.name = documentItemName
        
        let databaseOrmResultUDCDocumentGraphModelWordDictionaryEn = UDCDocumentGraphModel.get(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, idName: "UDCDocumentItem.WordDictionaryTemplate", language: "en")
        if databaseOrmResultUDCDocumentGraphModelWordDictionaryEn.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentGraphModelWordDictionaryEn.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentGraphModelWordDictionaryEn.databaseOrmError[0].description))
            return
        }
        let udcDocumentGraphModelWordDictionaryEn = databaseOrmResultUDCDocumentGraphModelWordDictionaryEn.object[0]
        if language != "en" {
            let databaseOrmResultUDCDocumentGraphModelWordDictionaryLanguage = UDCDocumentGraphModel.get(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, idName: "UDCDocumentItem.WordDictionaryTemplate", language: language)
            if databaseOrmResultUDCDocumentGraphModelWordDictionaryLanguage.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentGraphModelWordDictionaryLanguage.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentGraphModelWordDictionaryLanguage.databaseOrmError[0].description))
                return
            }
            let udcDocumentGraphModelWordDictionaryLanguage = databaseOrmResultUDCDocumentGraphModelWordDictionaryLanguage.object[0]
            udcDocumentGraphModelWordDictionaryLanguage._id = try udbcDatabaseOrm!.generateId()
            let parentId = try udbcDatabaseOrm!.generateId()
            udcDocumentGraphModelWordDictionaryLanguage.idName = englishIdName
            udcDocumentGraphModelWordDictionaryLanguage.level = 1
            udcDocumentGraphModelWordDictionaryLanguage.name = documentItemName
            udcDocumentGraphModelWordDictionaryLanguage.language = language
            var udcSentencePatternDataGroupValue = UDCSentencePatternDataGroupValue()
            udcSentencePatternDataGroupValue.item = documentTypeName.capitalized
            udcSentencePatternDataGroupValue.category = "UDCGrammarCategory.CommonNoun"
            udcSentencePatternDataGroupValue.endCategoryIdName = "UDCDocumentItem.General"
            udcSentencePatternDataGroupValue.uvcViewItemType = "UVCViewItemType.Text"
            udcDocumentGraphModelWordDictionaryLanguage.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.insert(udcSentencePatternDataGroupValue, at: 0)
            udcDocumentGraphModelWordDictionaryLanguage.udcSentencePattern = try processGrammar(neuronRequest: neuronRequest, neuronResponse: &neuronResponse, udcSentencePattern: udcDocumentGraphModelWordDictionaryLanguage.udcSentencePattern, newSentence: true, wordIndex: 0, sentenceIndex: 0, documentLanguage: language, textStartIndex: 0)
            udcDocumentGraphModelWordDictionaryLanguage.parentId.removeAll()
            udcDocumentGraphModelWordDictionaryLanguage.childrenId.removeAll()
            udcDocumentGraphModelWordDictionaryLanguage.parentId.append(parentId)
            let childrenId = udcDocumentGraphModelWordDictionaryLanguage._id
            let databaseOrmResultUDCDocumentGraphModelDocumentItemEnSave = UDCDocumentGraphModel.save(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentGraphModelWordDictionaryLanguage)
            if databaseOrmResultUDCDocumentGraphModelDocumentItemEnSave.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentGraphModelDocumentItemEnSave.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentGraphModelDocumentItemEnSave.databaseOrmError[0].description))
                return
            }
            
            udcDocumentGraphModelWordDictionaryEn._id = parentId
            udcDocument.udcDocumentGraphModelId = udcDocumentGraphModelWordDictionaryEn._id
            udcDocumentGraphModelWordDictionaryEn.idName = englishIdName
            udcDocumentGraphModelWordDictionaryEn.name = englishName
            udcDocumentGraphModelWordDictionaryEn.language = language
            udcSentencePatternDataGroupValue = UDCSentencePatternDataGroupValue()
            udcSentencePatternDataGroupValue.item = documentTypeNameEnglish.capitalized
            udcSentencePatternDataGroupValue.category = "UDCGrammarCategory.CommonNoun"
            udcSentencePatternDataGroupValue.endCategoryIdName = "UDCDocumentItem.General"
            udcSentencePatternDataGroupValue.uvcViewItemType = "UVCViewItemType.Text"
            udcDocumentGraphModelWordDictionaryEn.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.insert(udcSentencePatternDataGroupValue, at: 0)
            udcDocumentGraphModelWordDictionaryEn.udcSentencePattern = try processGrammar(neuronRequest: neuronRequest, neuronResponse: &neuronResponse, udcSentencePattern: udcDocumentGraphModelWordDictionaryEn.udcSentencePattern, newSentence: true, wordIndex: 0, sentenceIndex: 0, documentLanguage: language, textStartIndex: 0)
            udcDocumentGraphModelWordDictionaryEn.level = 0
            udcDocumentGraphModelWordDictionaryEn.parentId.removeAll()
            udcDocumentGraphModelWordDictionaryEn.childrenId.removeAll()
            udcDocumentGraphModelWordDictionaryEn.childrenId.append(childrenId)
            let databaseOrmResultUDCDocumentItemMapNodeSaveMapNodeChild = UDCDocumentGraphModel.save(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentGraphModelWordDictionaryEn)
            if databaseOrmResultUDCDocumentItemMapNodeSaveMapNodeChild.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentItemMapNodeSaveMapNodeChild.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentItemMapNodeSaveMapNodeChild.databaseOrmError[0].description))
                return
            }
        } else {
            udcDocumentGraphModelWordDictionaryEn._id = try udbcDatabaseOrm!.generateId()
            let parentId = try udbcDatabaseOrm!.generateId()
            udcDocumentGraphModelWordDictionaryEn.idName = englishIdName
            udcDocumentGraphModelWordDictionaryEn.level = 1
            udcDocumentGraphModelWordDictionaryEn.name = englishName
            udcDocumentGraphModelWordDictionaryEn.language = "en"
            var udcSentencePatternDataGroupValue = UDCSentencePatternDataGroupValue()
            udcSentencePatternDataGroupValue.item = documentTypeNameEnglish.capitalized
            udcSentencePatternDataGroupValue.category = "UDCGrammarCategory.CommonNoun"
            udcSentencePatternDataGroupValue.endCategoryIdName = "UDCDocumentItem.General"
            udcSentencePatternDataGroupValue.uvcViewItemType = "UVCViewItemType.Text"
            udcDocumentGraphModelWordDictionaryEn.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.insert(udcSentencePatternDataGroupValue, at: 0)
            udcDocumentGraphModelWordDictionaryEn.udcSentencePattern = try processGrammar(neuronRequest: neuronRequest, neuronResponse: &neuronResponse, udcSentencePattern: udcDocumentGraphModelWordDictionaryEn.udcSentencePattern, newSentence: true, wordIndex: 0, sentenceIndex: 0, documentLanguage: language, textStartIndex: 0)
            udcDocumentGraphModelWordDictionaryEn.parentId.removeAll()
            udcDocumentGraphModelWordDictionaryEn.childrenId.removeAll()
            udcDocumentGraphModelWordDictionaryEn.parentId.append(parentId)
            var databaseOrmResultUDCDocumentItemMapNodeSaveMapNodeChild = UDCDocumentGraphModel.save(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentGraphModelWordDictionaryEn)
            if databaseOrmResultUDCDocumentItemMapNodeSaveMapNodeChild.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentItemMapNodeSaveMapNodeChild.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentItemMapNodeSaveMapNodeChild.databaseOrmError[0].description))
                return
            }
            udcDocumentGraphModelWordDictionaryEn.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.remove(at: 0)
            let childrenId = udcDocumentGraphModelWordDictionaryEn._id
            udcDocumentGraphModelWordDictionaryEn._id = parentId
            udcDocument.udcDocumentGraphModelId = udcDocumentGraphModelWordDictionaryEn._id
            udcDocumentGraphModelWordDictionaryEn.idName = englishIdName
            udcDocumentGraphModelWordDictionaryEn.name = englishName
            udcDocumentGraphModelWordDictionaryEn.language = "en"
            udcSentencePatternDataGroupValue = UDCSentencePatternDataGroupValue()
            udcSentencePatternDataGroupValue.item = documentTypeNameEnglish.capitalized
            udcSentencePatternDataGroupValue.category = "UDCGrammarCategory.CommonNoun"
            udcSentencePatternDataGroupValue.endCategoryIdName = "UDCDocumentItem.General"
            udcSentencePatternDataGroupValue.uvcViewItemType = "UVCViewItemType.Text"
            udcDocumentGraphModelWordDictionaryEn.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.insert(udcSentencePatternDataGroupValue, at: 0)
            udcDocumentGraphModelWordDictionaryEn.udcSentencePattern = try processGrammar(neuronRequest: neuronRequest, neuronResponse: &neuronResponse, udcSentencePattern: udcDocumentGraphModelWordDictionaryEn.udcSentencePattern, newSentence: true, wordIndex: 0, sentenceIndex: 0, documentLanguage: language, textStartIndex: 0)
            udcDocumentGraphModelWordDictionaryEn.level = 0
            udcDocumentGraphModelWordDictionaryEn.parentId.removeAll()
            udcDocumentGraphModelWordDictionaryEn.childrenId.removeAll()
            udcDocumentGraphModelWordDictionaryEn.childrenId.append(childrenId)
            databaseOrmResultUDCDocumentItemMapNodeSaveMapNodeChild = UDCDocumentGraphModel.save(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentGraphModelWordDictionaryEn)
            if databaseOrmResultUDCDocumentItemMapNodeSaveMapNodeChild.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentItemMapNodeSaveMapNodeChild.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentItemMapNodeSaveMapNodeChild.databaseOrmError[0].description))
                return
            }
        }
        
        let databaseOrmResultUDCDocumentSave = UDCDocument.save(udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocument)
        if databaseOrmResultUDCDocumentSave.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentSave.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentSave.databaseOrmError[0].description))
            return
        }
        
        let databaseUDCDocumentItemMap = UDCDocumentItemMap.get(udbcDatabaseOrm: udbcDatabaseOrm!, idName: "UDCDocumentItemMap.DocumentItems", udcProfile: udcProfile, language: language)
        if databaseUDCDocumentItemMap.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseUDCDocumentItemMap.databaseOrmError[0].name, description: databaseUDCDocumentItemMap.databaseOrmError[0].description))
            return
        }
        let udcDocumentItemMap = databaseUDCDocumentItemMap.object[0]
        
        for id in udcDocumentItemMap.udcDocumentItemMapNodeId {
            // Get the "document items" child node for each document type
            let databaseUDCDocumentItemMapDocItems = UDCDocumentItemMapNode.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: id, language: language)
            if databaseUDCDocumentItemMap.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseUDCDocumentItemMapDocItems.databaseOrmError[0].name, description: databaseUDCDocumentItemMapDocItems.databaseOrmError[0].description))
                return
            }
            
            let udcDocumentItemMapNodeDocItems = databaseUDCDocumentItemMapDocItems.object[0]
            let documentType = "UDCDocumentType.\(englishName.capitalized.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "WordDictionary", with: ""))"
            if udcDocumentItemMapNodeDocItems.udcDocumentTypeIdName == documentType || udcDocumentItemMapNodeDocItems.udcDocumentTypeIdName == "UDCDocumentType.DocumentItem" {
                let udcDocumentItemMapNodeChild = UDCDocumentItemMapNode()
                udcDocumentItemMapNodeChild._id = try udbcDatabaseOrm!.generateId()
                udcDocumentItemMapNodeChild.name = documentItemName
                udcDocumentItemMapNodeChild.idName = "UDCDocumentItemMapNode.\(englishName.capitalized.replacingOccurrences(of: " ", with: ""))"
                udcDocumentItemMapNodeChild.level = 1
                let databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, udcProfile: udcProfile, udcDocumentTypeIdName: "UDCDocumentType.DocumentItem", idName: "UDCDocument.\(englishName.capitalized.replacingOccurrences(of: " ", with: ""))", language: language)
                udcDocumentItemMapNodeChild.objectId = [databaseOrmResultUDCDocument.object[0]._id]
                udcDocumentItemMapNodeChild.objectName = "UDCDocumentItem"
                udcDocumentItemMapNodeChild.udcDocumentTypeIdName = udcDocumentItemMapNodeDocItems.udcDocumentTypeIdName
                udcDocumentItemMapNodeChild.pathIdName.append(udcDocumentItemMapNodeDocItems.idName)
                udcDocumentItemMapNodeChild.pathIdName.append(udcDocumentItemMapNodeChild.idName)
                udcDocumentItemMapNodeChild.language = language
                udcDocumentItemMapNodeChild.parentId.append(udcDocumentItemMapNodeDocItems._id)
                udcDocumentItemMapNodeDocItems.childrenId.append(udcDocumentItemMapNodeChild._id)
                
                // Save the child
                var databaseUDCDocumentItemMapChildSave = UDCDocumentItemMapNode.save(udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentItemMapNodeChild)
                if databaseUDCDocumentItemMapChildSave.databaseOrmError.count > 0 {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseUDCDocumentItemMapChildSave.databaseOrmError[0].name, description: databaseUDCDocumentItemMapChildSave.databaseOrmError[0].description))
                    return
                }
                
                // Save the child
                databaseUDCDocumentItemMapChildSave = UDCDocumentItemMapNode.update(udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentItemMapNodeDocItems)
                if databaseUDCDocumentItemMapChildSave.databaseOrmError.count > 0 {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseUDCDocumentItemMapChildSave.databaseOrmError[0].name, description: databaseUDCDocumentItemMapChildSave.databaseOrmError[0].description))
                    return
                }
            }
        }
        
        
        
        try documentGraphModelReference(parentPathIdName: "UDCOptionMap.DocumentMap->UDCDocumentType.DocumentItem", itemIdName: "UDCOptionMapNode.Recents", udcDocumentId: udcDocument._id, udcProfile: udcProfile, udcDocumentTypeIdName: "UDCDocumentType.DocumentItem", neuronRequest: neuronRequest, neuronResponse: &neuronResponse, documentLanguage: language)
        try documentGraphModelReference(parentPathIdName: "UDCOptionMap.DocumentMap->UDCDocumentType.DocumentItem->UDCOptionMapNode.Library", itemIdName: "UDCDocumentMapNode.All", udcDocumentId: udcDocument._id, udcProfile: udcProfile, udcDocumentTypeIdName: "UDCDocumentType.DocumentItem", neuronRequest: neuronRequest, neuronResponse: &neuronResponse, documentLanguage: language)
    }
    
    private func getDocumentItemMapNodeChildrens(parent: UDCDocumentItemMap, givenChildrens: [String], childrens: inout [UDCDocumentItemMapNode], neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest, language: String) throws {
        for childrenId in givenChildrens {
            let databaseOrmResultUDCDocumentItemMapNode = UDCDocumentItemMapNode.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: childrenId, language: language)
            if databaseOrmResultUDCDocumentItemMapNode.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentItemMapNode.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentItemMapNode.databaseOrmError[0].description))
                return
            }
            let udcDocumentItemMapNode = databaseOrmResultUDCDocumentItemMapNode.object[0]
            
            udcDocumentItemMapNode._id = try udbcDatabaseOrm!.generateId()
            udcDocumentItemMapNode.pathIdName[0] = parent.idName
            udcDocumentItemMapNode.parentId.removeAll()
            udcDocumentItemMapNode.parentId.append(parent._id)
            if udcDocumentItemMapNode.childrenId.count > 0 {
                var childrensLocal = [UDCDocumentItemMapNode]()
                try getDocumentItemMapNodeChildrens(parent: parent, givenChildrens: udcDocumentItemMapNode.childrenId, childrens: &childrensLocal,neuronRequest: neuronRequest, neuronResponse: &neuronResponse, language: language)
                udcDocumentItemMapNode.childrenId.removeAll()
                for child in childrensLocal {
                    udcDocumentItemMapNode.childrenId.append(child._id)
                }
                childrens.append(contentsOf: childrensLocal)
            }
            childrens.append(udcDocumentItemMapNode)
        }
    }
    
    private func getDocumentMapNodeChildrens(parent: UDCDocumentMapNode, givenChildrens: [String], childrens: inout [UDCDocumentMapNode], createDocumentTypeRequest: CreateDocumentTypeRequest, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest, language: String) throws {
        for childrenId in givenChildrens {
            let databaseOrmResultUDCDocumentMapNode = UDCDocumentMapNode.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: childrenId, language: language)
            if databaseOrmResultUDCDocumentMapNode.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentMapNode.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentMapNode.databaseOrmError[0].description))
                return
            }
            let udcDocumentMapNode = databaseOrmResultUDCDocumentMapNode.object[0]
            if udcDocumentMapNode.idName == "UDCOptionMapNode.Knowledge" && !createDocumentTypeRequest.isKnowledgeAvailable {
                continue
            }
            udcDocumentMapNode._id = try udbcDatabaseOrm!.generateId()
            udcDocumentMapNode.path.remove(at: 0)
            udcDocumentMapNode.path.insert(contentsOf: parent.path, at: 0)
            udcDocumentMapNode.pathIdName.remove(at: 0)
            udcDocumentMapNode.pathIdName.insert(contentsOf: parent.pathIdName, at: 0)
            udcDocumentMapNode.parentId.removeAll()
            udcDocumentMapNode.parentId.append(parent._id)
            if udcDocumentMapNode.childrenId.count > 0 {
                var childrensLocal = [UDCDocumentMapNode]()
                try getDocumentMapNodeChildrens(parent: parent, givenChildrens: udcDocumentMapNode.childrenId, childrens: &childrensLocal, createDocumentTypeRequest: createDocumentTypeRequest, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, language: language)
                udcDocumentMapNode.childrenId.removeAll()
                for child in childrensLocal {
                    udcDocumentMapNode.childrenId.append(child._id)
                }
                childrens.append(contentsOf: childrensLocal)
            }
            childrens.append(udcDocumentMapNode)
        }
    }
    
    private func getTreeNodeView(parentNode: UDCDocumentMapNode, getDocumentMapByPathRequest: GetDocumentMapByPathRequest, uvcDocumentMapViewTemplateType: String, isAll: Bool, udcDocumentTypeIdName: String, uniqueId: String, documentId: String, isOptionAvailable: Bool, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws -> UVCTreeNode? {
        
        let interfaceLanguage = getDocumentMapByPathRequest.interfaceLanguage
        
        var udcDocument: UDCDocument?
        if !documentId.isEmpty {
            let databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: documentId)
            if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocument.databaseOrmError[0].name, description: databaseOrmResultUDCDocument.databaseOrmError[0].description))
                return nil
            }
            udcDocument = databaseOrmResultUDCDocument.object[0]
        }
        let uvcTreeNodeChild = UVCTreeNode()
        uvcTreeNodeChild._id = try udbcDatabaseOrm!.generateId()
        var textColor = UVCColor.get("UVCColor.Black")
        var name = ""
        if udcDocument != nil {
            uvcTreeNodeChild.objectId = udcDocument!._id
            uvcTreeNodeChild.language = udcDocument!.language
            name = udcDocument!.name
        } else {
            let databaseOrmResultUDCOptionMapNode = UDCOptionMapNode.get("UDCOptionMapNode.NoData", udbcDatabaseOrm!, interfaceLanguage)
            if databaseOrmResultUDCOptionMapNode.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCOptionMapNode.databaseOrmError[0].name, description: databaseOrmResultUDCOptionMapNode.databaseOrmError[0].description))
                return nil
            }
            let udcOptionMapNode = databaseOrmResultUDCOptionMapNode.object[0]
            name = udcOptionMapNode.name
        }
        uvcTreeNodeChild.objectType = udcDocumentTypeIdName
        uvcTreeNodeChild.level = parentNode.level + 1
        uvcTreeNodeChild.pathIdName.append(contentsOf: parentNode.pathIdName)
        if udcDocument != nil {
            for udcDocumentAccessProfile in udcDocument!.udcDocumentAccessProfile {
                if udcDocumentAccessProfile.udcProfileItemIdName == "UDCProfileItem.Human" {
                    if !udcDocumentAccessProfile.profileId.isEmpty {
                        if getDocumentMapByPathRequest.upcHumanProfileId == udcDocumentAccessProfile.profileId {
                            if udcDocumentAccessProfile.udcDocumentAccessType.contains("UDCDocumentAccessType.Read") &&
                                udcDocumentAccessProfile.udcDocumentAccessType.contains("UDCDocumentAccessType.Write") &&
                                udcDocumentAccessProfile.udcDocumentAccessType.contains("UDCDocumentAccessType.Delete") &&
                                udcDocumentAccessProfile.udcDocumentAccessType.contains("UDCDocumentAccessType.Share") {
                                textColor = UVCColor.get("UVCColor.DarkGreen")
                            } else if udcDocumentAccessProfile.udcDocumentAccessType.contains("UDCDocumentAccessType.Read") &&
                                !udcDocumentAccessProfile.udcDocumentAccessType.contains("UDCDocumentAccessType.Write") &&
                                !udcDocumentAccessProfile.udcDocumentAccessType.contains("UDCDocumentAccessType.Delete") &&
                                !udcDocumentAccessProfile.udcDocumentAccessType.contains("UDCDocumentAccessType.Share") {
                                textColor = UVCColor.get("UVCColor.Purple")
                            } else if udcDocumentAccessProfile.udcDocumentAccessType.contains("UDCDocumentAccessType.Read") &&
                                udcDocumentAccessProfile.udcDocumentAccessType.contains("UDCDocumentAccessType.Write") &&
                                !udcDocumentAccessProfile.udcDocumentAccessType.contains("UDCDocumentAccessType.Delete") &&
                                !udcDocumentAccessProfile.udcDocumentAccessType.contains("UDCDocumentAccessType.Share") {
                                textColor = UVCColor.get("UVCColor.Pink")
                            }
                        }
                    }
                }
            }
        }
        uvcTreeNodeChild.uvcViewModel = uvcViewGenerator.getTreeNodeViewModel(name: name, description: "", path: "", language: interfaceLanguage, isChildrenExist: false,
                                                                              uvcDocumentMapViewTemplateType: uvcDocumentMapViewTemplateType, textColor: textColor, udcDocumentTypeIdName: udcDocumentTypeIdName, isOptionAvailable: isOptionAvailable)
        
        let idName = name.capitalized.trimmingCharacters(in: .whitespaces)
        uvcTreeNodeChild.pathIdName.append(idName)
        uvcTreeNodeChild.parentId.append(parentNode._id)
        parentNode.childrenId.append(uvcTreeNodeChild._id)
        return uvcTreeNodeChild
    }
    
    private func getDocumentMapByPath(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let getDocumentMapByPathRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: GetDocumentMapByPathRequest())
        
        let interfaceLanguage = getDocumentMapByPathRequest.interfaceLanguage
        
        let databaseOrmResultUDCDocumentMapNode = UDCDocumentMapNode.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: getDocumentMapByPathRequest.parentId, language: interfaceLanguage)
        if databaseOrmResultUDCDocumentMapNode.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentMapNode.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentMapNode.databaseOrmError[0].description))
            return
        }
        let udcDocumentMapNode = databaseOrmResultUDCDocumentMapNode.object[0]
        let databaseOrmResultUDCDocumentType = UDCDocumentType.get(udbcDatabaseOrm!, interfaceLanguage)
        if databaseOrmResultUDCDocumentType.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentType.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentType.databaseOrmError[0].description))
            return
        }
        let udcDocumentType = databaseOrmResultUDCDocumentType.object
        
        var uvcTreeNodeArray = [UVCTreeNode]()
        let pathIdName = getDocumentMapByPathRequest.pathIdName.joined(separator: "->")
        var udcDocumentGraphModelDocumentMapDynamicArray = [UDCDocumentGraphModelDocumentMapDynamic]()
        for udcdt in udcDocumentType {
            var databaseOrmResultUDCDocumentGraphModelReferenceGet: DatabaseOrmResult<UDCDocumentGraphModelDocumentMapDynamic>?
            var udcDocumentGraphModelDocumentMapDynamic: [UDCDocumentGraphModelDocumentMapDynamic]?
            // If the path id name has one of the document type path id name prefix
            if pathIdName.hasPrefix("UDCOptionMap.DocumentMap->\(udcdt.idName)") {
                databaseOrmResultUDCDocumentGraphModelReferenceGet = UDCDocumentGraphModelDocumentMapDynamic.get(collectionName: "\(neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcdt.idName)!)DocumentMapDynamic", udbcDatabaseOrm: udbcDatabaseOrm!, pathIdName: getDocumentMapByPathRequest.pathIdName.joined(separator: "->"), udcProfile: getDocumentMapByPathRequest.udcProfile)
                udcDocumentGraphModelDocumentMapDynamic = databaseOrmResultUDCDocumentGraphModelReferenceGet!.object
                udcDocumentGraphModelDocumentMapDynamicArray.append(contentsOf: udcDocumentGraphModelDocumentMapDynamic!)
            } else if pathIdName == "UDCOptionMap.DocumentMap->UDCOptionMapNode.Recents" || pathIdName == "UDCOptionMap.DocumentMap->UDCOptionMapNode.Favourites" {
                databaseOrmResultUDCDocumentGraphModelReferenceGet = UDCDocumentGraphModelDocumentMapDynamic.get(collectionName: "\(neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcdt.idName)!)DocumentMapDynamic", udbcDatabaseOrm: udbcDatabaseOrm!, pathIdName: "UDCOptionMap.DocumentMap->\(udcdt.idName)->\(getDocumentMapByPathRequest.pathIdName[1])", udcProfile: getDocumentMapByPathRequest.udcProfile)
                udcDocumentGraphModelDocumentMapDynamic = databaseOrmResultUDCDocumentGraphModelReferenceGet!.object
                udcDocumentGraphModelDocumentMapDynamicArray.append(contentsOf: udcDocumentGraphModelDocumentMapDynamic!)
            }
            
        }
        
        // Sort based on changed or creation time
        udcDocumentGraphModelDocumentMapDynamicArray = udcDocumentGraphModelDocumentMapDynamicArray.sorted(by: {
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "yyyy-MM-dd\("T")HH:mm:ss.SSSS"
            if $0.udcDocumentTime.changedTime != nil && $1.udcDocumentTime.changedTime != nil {
                let convertedDate0 = dateFormatterGet.string(from: $0.udcDocumentTime.changedTime!)
                let convertedDate1 = dateFormatterGet.string(from: $1.udcDocumentTime.changedTime!)
                return convertedDate0.compare(convertedDate1) == .orderedDescending
            } else {
                let convertedDate0 = dateFormatterGet.string(from: $0.udcDocumentTime.creationTime!)
                let convertedDate1 = dateFormatterGet.string(from: $1.udcDocumentTime.creationTime!)
                return convertedDate0.compare(convertedDate1) == .orderedDescending
            }
        })
        
        // Add the sorted things
        if udcDocumentGraphModelDocumentMapDynamicArray.count > 0 {
            for udcdgmr in udcDocumentGraphModelDocumentMapDynamicArray {
                let uvcTreeNodeLocal = try getTreeNodeView(parentNode: udcDocumentMapNode, getDocumentMapByPathRequest: getDocumentMapByPathRequest, uvcDocumentMapViewTemplateType: getDocumentMapByPathRequest.uvcDocumentMapViewTemplateType, isAll: false, udcDocumentTypeIdName: udcdgmr.udcDocumentTypeIdName, uniqueId: udcdgmr._id, documentId: udcdgmr.udcDocumentId, isOptionAvailable: true, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
                
                if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
                    return
                }
                
                if uvcTreeNodeLocal != nil {
                    uvcTreeNodeArray.append(uvcTreeNodeLocal!)
                }
            }
        }
        
        // If there are no items, then add things to say nothing there
        if uvcTreeNodeArray.count == 0 {
            let uvcTreeNodeLocal = try getTreeNodeView(parentNode: udcDocumentMapNode, getDocumentMapByPathRequest: getDocumentMapByPathRequest, uvcDocumentMapViewTemplateType: getDocumentMapByPathRequest.uvcDocumentMapViewTemplateType, isAll: false, udcDocumentTypeIdName: "", uniqueId: try udbcDatabaseOrm!.generateId(), documentId: "", isOptionAvailable: false, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            
            if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
                return
            }
            if uvcTreeNodeLocal != nil {
                uvcTreeNodeArray.append(uvcTreeNodeLocal!)
            }
        }
        
        let getDocumentMapByPathResponse = GetDocumentMapByPathResponse()
        getDocumentMapByPathResponse.uvcDocumentMapViewModel.uvcTreeNode.append(contentsOf: uvcTreeNodeArray)
        getDocumentMapByPathResponse.pathIdName = getDocumentMapByPathRequest.pathIdName
        
        let jsonUtilityGetDocumentMapByPathResponse = JsonUtility<GetDocumentMapByPathResponse>()
        let jsonGetDocumentMapByPathResponse = jsonUtilityGetDocumentMapByPathResponse.convertAnyObjectToJson(jsonObject: getDocumentMapByPathResponse)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonGetDocumentMapByPathResponse)
    }
    
    
    private func documentGetView(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let getDocumentGraphViewRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: GetDocumentGraphViewRequest())
        
        var documentLanguage = getDocumentGraphViewRequest.documentLanguage
        let interfaceLanguage = getDocumentGraphViewRequest.interfaceLanguage
        var profileId = ""
        for udcp in getDocumentGraphViewRequest.udcProfile {
            if udcp.udcProfileItemIdName == "UDCProfileItem.Human" {
                profileId = udcp.profileId
            }
        }
        
        let getDocumentGraphViewResponse = GetDocumentGraphViewResponse()
        var prevDocumentType = getDocumentGraphViewRequest.udcDocumentTypeIdName
        var prevDocumentId = getDocumentGraphViewRequest.documentId
        var configId = ""
        var isObjectIdEmpty = false
        var udcDocumentGraphModel: UDCDocumentGraphModel?
        var udcDocument: UDCDocument?
        var udcDocumentTypeIdName = ""

        if getDocumentGraphViewRequest.isDetailedView || getDocumentGraphViewRequest.isDocumentMapView {
            let databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: getDocumentGraphViewRequest.documentId)
            if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocument.databaseOrmError[0].name, description: databaseOrmResultUDCDocument.databaseOrmError[0].description))
                return
            }
            udcDocument = databaseOrmResultUDCDocument.object[0]
            
            // Get the root node
            let databaseOrmResultudcDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: getDocumentGraphViewRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocument!.udcDocumentGraphModelId, language: documentLanguage)
            if databaseOrmResultudcDocumentGraphModel.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModel.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModel.databaseOrmError[0].description))
                return
            }
            udcDocumentGraphModel = databaseOrmResultudcDocumentGraphModel.object[0]
            
            if udcDocumentGraphModel!.objectId.isEmpty {
                getDocumentGraphViewRequest.isConfigurationView = true
            } else {
                // Get the model for the node the user is clicking (i) button
                let databaseOrmResultudcDocumentGraphModelDocType = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: getDocumentGraphViewRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: getDocumentGraphViewRequest.nodeId!)
                if databaseOrmResultudcDocumentGraphModelDocType.databaseOrmError.count > 0 {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModelDocType.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModelDocType.databaseOrmError[0].description))
                    return
                }
                let udcDocumentGraphModelDocType = databaseOrmResultudcDocumentGraphModelDocType.object[0]
                
                // If the node doesn't have the object information
                if (udcDocumentGraphModelDocType.objectId.isEmpty && !getDocumentGraphViewRequest.isDocumentMapView) || (udcDocumentGraphModelDocType.documentMapObjectId.isEmpty && getDocumentGraphViewRequest.isDocumentMapView)  {
                    isObjectIdEmpty = true
                    if !getDocumentGraphViewRequest.isDocumentMapView {
                        // Get the configuration document for the document item
                        let databaseOrmResultUDCDocumentConfig = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentGraphModel!.objectId)
                        if databaseOrmResultUDCDocumentConfig.databaseOrmError.count > 0 {
                            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentConfig.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentConfig.databaseOrmError[0].description))
                            return
                        }
                        let udcDocumentConfig = databaseOrmResultUDCDocumentConfig.object[0]
                        
                        let databaseOrmResultudcDocumentGraphModelConfig = UDCDocumentGraphModel.get(collectionName: "UDCDocumentItemConfiguration", udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentConfig.udcDocumentGraphModelId)
                        if databaseOrmResultudcDocumentGraphModelConfig.databaseOrmError.count > 0 {
                            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModelConfig.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModelConfig.databaseOrmError[0].description))
                            return
                        }
                        let udcDocumentGraphModelConfig = databaseOrmResultudcDocumentGraphModelConfig.object[0]
                        
                        // Get the document type for the document item
                        var fieldValueMap = [String: [UDCSentencePatternDataGroupValue]]()
                        documentParser.getField(fieldidName: "UDCDocumentItem.DocumentType", childrenId: udcDocumentGraphModelConfig.childrenId, fieldValue: &fieldValueMap, udcDocumentTypeIdName: "UDCDocumentType.DocumentItemConfiguration", documentLanguage: documentLanguage)
                        let fieldValueArray = fieldValueMap["UDCDocumentItem.DocumentType"]
                        if (fieldValueArray != nil)  {
                            for udcspdgv in fieldValueArray! {
                                if udcspdgv.endCategoryIdName == "UDCDocumentItem.DocumentType" {
                                    udcDocumentTypeIdName = "UDCDocumentType.\(udcspdgv.itemIdName.split(separator: ".")[1])"
                                    break
                                }
                            }
                        }
                    } else {
                        udcDocumentTypeIdName = "UDCDocumentType.DocumentMap"
                    }
                    
                    // If the document type is not given then let the user give the document tyep
                    if udcDocumentTypeIdName.isEmpty {
                        getDocumentGraphViewRequest.isConfigurationView = true
                        configId = udcDocumentGraphModel!.objectId
                        getDocumentGraphViewRequest.documentId = udcDocumentGraphModel!.objectId
                        getDocumentGraphViewRequest.udcDocumentTypeIdName = neuronUtility!.getDocumentType(collectionName: udcDocumentGraphModel!.objectName)!
                        getDocumentGraphViewResponse.isConfigurationView = getDocumentGraphViewRequest.isConfigurationView
                    } else {
                        let databaseOrmResultUDCDocumentConfigNew = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, udcProfile: getDocumentGraphViewRequest.udcProfile, udcDocumentTypeIdName: udcDocumentTypeIdName, idName: "UDCDocument.Blank", language: documentLanguage)
                        if databaseOrmResultUDCDocumentConfigNew.databaseOrmError.count > 0 {
                            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentConfigNew.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentConfigNew.databaseOrmError[0].description))
                            return
                        }
                        let udcDocumentConfigNew = databaseOrmResultUDCDocumentConfigNew.object[0].self
                        getDocumentGraphViewRequest.documentId = udcDocumentConfigNew._id
                        configId = udcDocumentConfigNew._id
                        getDocumentGraphViewRequest.udcDocumentTypeIdName = udcDocumentTypeIdName
                        getDocumentGraphViewResponse.isConfigurationView = getDocumentGraphViewRequest.isConfigurationView
                        getDocumentGraphViewRequest.isToGetDuplicate = true
                    }
                } // Node has object information so set the things to fetch the object
                else {
                    if !getDocumentGraphViewRequest.isDocumentMapView {
                        configId = udcDocumentGraphModelDocType.objectId
                        getDocumentGraphViewRequest.documentId = udcDocumentGraphModelDocType.objectId
                        getDocumentGraphViewRequest.udcDocumentTypeIdName = neuronUtility!.getDocumentType(collectionName: udcDocumentGraphModelDocType.objectName)!
                    } else {
                        configId = udcDocumentGraphModelDocType.documentMapObjectId
                        getDocumentGraphViewRequest.documentId = udcDocumentGraphModelDocType.documentMapObjectName
                        getDocumentGraphViewRequest.udcDocumentTypeIdName = neuronUtility!.getDocumentType(collectionName: udcDocumentGraphModelDocType.documentMapObjectName)!
                    }
                    getDocumentGraphViewResponse.isConfigurationView = getDocumentGraphViewRequest.isConfigurationView
                    getDocumentGraphViewResponse.isDetailedView = getDocumentGraphViewRequest.isDetailedView
                    getDocumentGraphViewResponse.popupUdcDocumentTypeIdName = getDocumentGraphViewRequest.udcDocumentTypeIdName

                }
            }
        }
        
        if getDocumentGraphViewRequest.isConfigurationView {
            udcDocumentTypeIdName = "UDCDocumentType.DocumentItemConfiguration"

            if udcDocumentGraphModel == nil {
                // Get the document
                let databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: getDocumentGraphViewRequest.documentId)
                if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocument.databaseOrmError[0].name, description: databaseOrmResultUDCDocument.databaseOrmError[0].description))
                    return
                }
                udcDocument = databaseOrmResultUDCDocument.object[0]
                
                // Get the root node
                let databaseOrmResultudcDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: getDocumentGraphViewRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocument!.udcDocumentGraphModelId)
                if databaseOrmResultudcDocumentGraphModel.databaseOrmError.count > 0 {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModel.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModel.databaseOrmError[0].description))
                    return
                }
                udcDocumentGraphModel = databaseOrmResultudcDocumentGraphModel.object[0]
            }
            
            let databaseOrmUDCDocumentItemMapNode = UDCDocumentItemMapNode.get("UDCDocumentItemMapNode.Untitled", udbcDatabaseOrm!, documentLanguage)
            if databaseOrmUDCDocumentItemMapNode.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentItemMapNode.databaseOrmError[0].name, description: databaseOrmUDCDocumentItemMapNode.databaseOrmError[0].description))
                return
            }
            let untitledItem = databaseOrmUDCDocumentItemMapNode.object
            if udcDocument!.name.contains(untitledItem[0].name) {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "NameRequired", description: "Name required!"))
                return
            }
                   
            // If object id is empty then create new configuration
            if udcDocumentGraphModel!.objectId.isEmpty {
                isObjectIdEmpty = true
                let databaseOrmResultUDCDocumentConfig = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, udcProfile: getDocumentGraphViewRequest.udcProfile, udcDocumentTypeIdName: udcDocumentTypeIdName, idName: "UDCDocument.Blank", language: documentLanguage)
                if databaseOrmResultUDCDocumentConfig.databaseOrmError.count > 0 {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentConfig.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentConfig.databaseOrmError[0].description))
                    return
                }
                let udcDocumentConfig = databaseOrmResultUDCDocumentConfig.object[0].self
                getDocumentGraphViewRequest.documentId = udcDocumentConfig._id
                configId = udcDocumentConfig._id
                getDocumentGraphViewRequest.udcDocumentTypeIdName = udcDocumentTypeIdName
                getDocumentGraphViewResponse.isConfigurationView = getDocumentGraphViewRequest.isConfigurationView
                getDocumentGraphViewResponse.popupUdcDocumentTypeIdName = udcDocumentTypeIdName
                getDocumentGraphViewRequest.isToGetDuplicate = true
            } else {
                if !getDocumentGraphViewRequest.isDocumentMapView {
                    configId = udcDocumentGraphModel!.objectId
                    getDocumentGraphViewRequest.documentId = udcDocumentGraphModel!.objectId
                } else {
                    configId = udcDocumentGraphModel!.documentMapObjectId
                    getDocumentGraphViewRequest.documentId = udcDocumentGraphModel!.documentMapObjectName
                }
                getDocumentGraphViewResponse.popupUdcDocumentTypeIdName = udcDocumentTypeIdName
                getDocumentGraphViewRequest.udcDocumentTypeIdName = udcDocumentTypeIdName
                getDocumentGraphViewResponse.isConfigurationView = getDocumentGraphViewRequest.isConfigurationView
            }
        }
        
        if getDocumentGraphViewRequest.isToCheckIfFound {
            var databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: getDocumentGraphViewRequest.documentId)
            getDocumentGraphViewResponse.isDocumentNotFound = false
            getDocumentGraphViewResponse.isToCheckIfFound = true
            getDocumentGraphViewResponse.documentLanguage = getDocumentGraphViewRequest.documentLanguage
            if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
                getDocumentGraphViewResponse.isDocumentNotFound = true
                return
            }
            let idName = databaseOrmResultUDCDocument.object[0].idName
            databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, udcProfile: getDocumentGraphViewRequest.udcProfile, udcDocumentTypeIdName: getDocumentGraphViewRequest.udcDocumentTypeIdName, idName: idName, language: documentLanguage)
            if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
                getDocumentGraphViewResponse.isDocumentNotFound = true
                let jsonUtilityGetDocumentGraphViewResponse = JsonUtility<GetDocumentGraphViewResponse>()
                let jsonGetDocumentGraphViewResponse = jsonUtilityGetDocumentGraphViewResponse.convertAnyObjectToJson(jsonObject: getDocumentGraphViewResponse)
                neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonGetDocumentGraphViewResponse)
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationSuccess?.append(neuronUtility!.getNeuronOperationSuccess(name: "NotFoundWantToCreate", description: "Not found. Want to create?"))
                return
            }
            getDocumentGraphViewRequest.documentId = databaseOrmResultUDCDocument.object[0]._id
        }
        
        var generateDocumentGraphViewRequest = GenerateDocumentGraphViewRequest()
        generateDocumentGraphViewRequest.getDocumentGraphViewRequest = getDocumentGraphViewRequest
        var generateDocumentGraphViewResponse = GenerateDocumentGraphViewResponse()
        if try isNeuronProcessingIt(operationName: "DocumentGraphNeuron.Document.Type.Process.View.Generated", udcDocumentTypeIdName: getDocumentGraphViewRequest.udcDocumentTypeIdName, neuronRequest: neuronRequest, neuronResponse: &neuronResponse) && !getDocumentGraphViewRequest.isConfigurationView && !getDocumentGraphViewRequest.isDetailedView {
            generateDocumentGraphViewRequest.getDocumentGraphViewRequest = getDocumentGraphViewRequest
            let neuronRequestLocal = neuronRequest
            let jsonUtilityGenerateDocumentGraphViewRequest = JsonUtility<GenerateDocumentGraphViewRequest>()
            let jsonGenerateDocumentGraphViewRequest = jsonUtilityGenerateDocumentGraphViewRequest.convertAnyObjectToJson(jsonObject: generateDocumentGraphViewRequest)
            neuronRequestLocal.neuronOperation.neuronData.text = jsonGenerateDocumentGraphViewRequest
            try callNeuron(neuronRequest: neuronRequestLocal, neuronResponse: &neuronResponse, operationName: "DocumentGraphNeuron.Generate.Document.View", udcDocumentTypeIdName: getDocumentGraphViewRequest.udcDocumentTypeIdName)
            if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse)  || neuronResponse.neuronOperation.neuronData.text.isEmpty {
                return
            }
            
            generateDocumentGraphViewResponse = neuronUtility!.getNeuronRequest(json: neuronResponse.neuronOperation.neuronData.text, object: GenerateDocumentGraphViewResponse())
        } else {
            if getDocumentGraphViewRequest.isConfigurationView || getDocumentGraphViewRequest.isDetailedView || getDocumentGraphViewRequest.isDocumentMapView {
                generateDocumentGraphViewRequest.detailParentDocumentTypeIdName = prevDocumentType
                generateDocumentGraphViewRequest.getDocumentGraphViewRequest.documentId = configId
                if isObjectIdEmpty {
                    generateDocumentGraphViewRequest.detailParentDocumentId = prevDocumentId
                }
                
            }
            try generateDocumentView(generateDocumentGraphViewRequest: generateDocumentGraphViewRequest, generateDocumentGraphViewResponse: &generateDocumentGraphViewResponse, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            
             if getDocumentGraphViewRequest.isConfigurationView || getDocumentGraphViewRequest.isDetailedView || getDocumentGraphViewRequest.isDocumentMapView  {
                getDocumentGraphViewResponse.documentId = generateDocumentGraphViewResponse.documentId
//                getDocumentGraphViewRequest.documentId = prevDocumentId
//                getDocumentGraphViewRequest.udcDocumentTypeIdName = prevDocumentType
                if !udcDocumentTypeIdName.isEmpty {
                    getDocumentGraphViewResponse.popupUdcDocumentTypeIdName = udcDocumentTypeIdName
                }
            }
        }
        
        if getDocumentGraphViewRequest.isConfigurationView && isObjectIdEmpty {
            udcDocumentGraphModel!.objectId = generateDocumentGraphViewResponse.documentId
            udcDocumentGraphModel!.objectName = neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!
            udcDocumentGraphModel!.udcDocumentTime.changedBy = profileId
            udcDocumentGraphModel!.udcDocumentTime.changedTime = Date()
            let databaseOrmResultUDCDocumentGraphModelUpdate = UDCDocumentGraphModel.update(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: prevDocumentType)!, udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentGraphModel!)
            if databaseOrmResultUDCDocumentGraphModelUpdate.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentGraphModelUpdate.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentGraphModelUpdate.databaseOrmError[0].description))
                return
            }
        } else if (getDocumentGraphViewRequest.isDetailedView || getDocumentGraphViewRequest.isDocumentMapView) && isObjectIdEmpty{
            let databaseOrmResultudcDocumentGraphModelDocType = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: prevDocumentType)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: getDocumentGraphViewRequest.nodeId!)
            if databaseOrmResultudcDocumentGraphModelDocType.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModelDocType.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModelDocType.databaseOrmError[0].description))
                return
            }
            let udcDocumentGraphModelDocType = databaseOrmResultudcDocumentGraphModelDocType.object[0]
            
            if !getDocumentGraphViewRequest.isDocumentMapView {
                udcDocumentGraphModelDocType.objectId = generateDocumentGraphViewResponse.documentId
                udcDocumentGraphModelDocType.objectName = neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!
            } else {
                udcDocumentGraphModelDocType.documentMapObjectId = generateDocumentGraphViewResponse.documentId
                udcDocumentGraphModelDocType.documentMapObjectName = neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!
            }
            udcDocumentGraphModelDocType.udcDocumentTime.changedBy = profileId
            udcDocumentGraphModelDocType.udcDocumentTime.changedTime = Date()
            let databaseOrmResultUDCDocumentGraphModelUpdate = UDCDocumentGraphModel.update(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: prevDocumentType)!, udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentGraphModelDocType)
            if databaseOrmResultUDCDocumentGraphModelUpdate.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentGraphModelUpdate.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentGraphModelUpdate.databaseOrmError[0].description))
                return
            }
        }
        
        if getDocumentGraphViewRequest.isToGetDuplicate {
            
            
            //            let humanLanguages = try getHumanLanguages(upcApplicationProfileId: getDocumentGraphViewRequest.upcApplicationProfileId, upcCompanyProfileId: getDocumentGraphViewRequest.upcCompanyProfileId, documentLanguage: documentLanguage, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            //            for language in humanLanguages {
            //                try documentGraphModelReference(parentPathIdName: "UDCOptionMap.DocumentMap->\(getDocumentGraphViewRequest.udcDocumentTypeIdName)->UDCDocumentMapNode.Library", itemIdName: "UDCDocumentMapNode.All", udcDocumentId: generateDocumentGraphViewResponse.documentId, udcProfile: getDocumentGraphViewRequest.udcProfile, udcDocumentTypeIdName: getDocumentGraphViewRequest.udcDocumentTypeIdName, upcCompanyProfileId: getDocumentGraphViewRequest.upcCompanyProfileId, upcApplicationProfileId: getDocumentGraphViewRequest.upcApplicationProfileId, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, documentLanguage: documentLanguage)
            //
            //                if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
            //                    return
            //                }
            
            //            }
            
            //            let _ = UDCDocumentRecent.remove(udbcDatabaseOrm: udbcDatabaseOrm!, udcDocumentId: generateDocumentGraphViewResponse.documentId) as DatabaseOrmResult<UDCDocumentRecent>
            
            //            try documentGraphModelReference(parentPathIdName: "UDCOptionMap.DocumentMap->\(getDocumentGraphViewRequest.udcDocumentTypeIdName)", itemIdName: "UDCOptionMapNode.Recents", udcDocumentId: generateDocumentGraphViewResponse.documentId, udcProfile: getDocumentGraphViewRequest.udcProfile, udcDocumentTypeIdName: getDocumentGraphViewRequest.udcDocumentTypeIdName, upcCompanyProfileId: getDocumentGraphViewRequest.upcCompanyProfileId, upcApplicationProfileId: getDocumentGraphViewRequest.upcApplicationProfileId, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, documentLanguage: documentLanguage)
            
            if getDocumentGraphViewRequest.udcDocumentTypeIdName == "UDCDocumentType.PhotoDocument" {
                
                let databaseOrmResultUDCDocumentItemMapNode = UDCDocumentItemMapNode.get("UDCDocumentItemMapNode.DocumentItems", udbcDatabaseOrm!, documentLanguage)
                if databaseOrmResultUDCDocumentItemMapNode.databaseOrmError.count > 0 {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentItemMapNode.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentItemMapNode.databaseOrmError[0].description))
                    return
                }
                let udcDocumentItemMapNode = databaseOrmResultUDCDocumentItemMapNode.object[0]
                
                let databaseOrmResultUDCDocumentType = UDCDocumentType.get(limitedTo: 0, sortedBy: "_id", udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
                if databaseOrmResultUDCDocumentType.databaseOrmError.count > 0 {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentType.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentType.databaseOrmError[0].description))
                    return
                }
                let udcDocumentType = databaseOrmResultUDCDocumentType.object
                
                for udcdt in udcDocumentType {
                    if udcdt.idName == "UDCDocumentType.PhotoDocument" {
                        let udcDocumentItemMapNodeSave = UDCDocumentItemMapNode()
                        udcDocumentItemMapNodeSave._id = try udbcDatabaseOrm!.generateId()
                        udcDocumentItemMapNodeSave.parentId.append(contentsOf: udcDocumentItemMapNode.parentId)
                        udcDocumentItemMapNode.childrenId.append(udcDocumentItemMapNodeSave._id)
                        udcDocumentItemMapNodeSave.name = generateDocumentGraphViewResponse.name
                        udcDocumentItemMapNodeSave.idName = "UDCDocumentItemMapNode.\(generateDocumentGraphViewResponse.name.capitalized.replacingOccurrences(of: " ", with: ""))"
                        udcDocumentItemMapNodeSave.language = documentLanguage
                        udcDocumentItemMapNodeSave.level = 1
                        udcDocumentItemMapNodeSave.objectId = [generateDocumentGraphViewResponse.documentId]
                        udcDocumentItemMapNodeSave.objectName = "UDC\(getDocumentGraphViewRequest.udcDocumentTypeIdName.components(separatedBy: ".")[1])"
                        udcDocumentItemMapNodeSave.pathIdName.append(contentsOf: udcDocumentItemMapNode.pathIdName)
                        udcDocumentItemMapNodeSave.pathIdName.append(udcDocumentItemMapNodeSave.idName)
                        udcDocumentItemMapNodeSave.udcDocumentTypeIdName = udcdt.idName
                        let _ = UDCDocumentItemMapNode.remove(udbcDatabaseOrm: udbcDatabaseOrm!, idName: "udcDocumentItemMapNodeSave.udcDocumentTypeIdName") as DatabaseOrmResult<UDCDocumentItemMapNode>
                        let databaseOrmResultUDCDocumentItemMapNodeSave = UDCDocumentItemMapNode.save(udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentItemMapNodeSave)
                        if databaseOrmResultUDCDocumentItemMapNodeSave.databaseOrmError.count > 0 {
                            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentItemMapNodeSave.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentItemMapNodeSave.databaseOrmError[0].description))
                            return
                        }
                    }
                }
                
                let databaseOrmResultUDCDocumentItemMapNodeSave = UDCDocumentItemMapNode.update(udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentItemMapNode)
                if databaseOrmResultUDCDocumentItemMapNodeSave.databaseOrmError.count > 0 {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentItemMapNodeSave.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentItemMapNodeSave.databaseOrmError[0].description))
                    return
                }
                
            }
            
            documentLanguage = generateDocumentGraphViewRequest.getDocumentGraphViewRequest.duplicateToDocumentLanguage
            getDocumentGraphViewResponse.documentLanguage = generateDocumentGraphViewRequest.getDocumentGraphViewRequest.duplicateToDocumentLanguage
        }
        
        getDocumentGraphViewResponse.documentId = generateDocumentGraphViewResponse.documentId
        getDocumentGraphViewResponse.documentTitle = generateDocumentGraphViewResponse.documentTitle
        if generateDocumentGraphViewResponse.documentItemViewInsertData.count > 0 {
            getDocumentGraphViewResponse.documentItemViewInsertData.append(contentsOf: generateDocumentGraphViewResponse.documentItemViewInsertData)
        }
        if generateDocumentGraphViewResponse.documentItemViewChangeData.count > 0 {
            getDocumentGraphViewResponse.documentItemViewChangeData.append(contentsOf: generateDocumentGraphViewResponse.documentItemViewChangeData)
        }
        if generateDocumentGraphViewResponse.documentItemViewDeleteData.count > 0 {
            getDocumentGraphViewResponse.documentItemViewDeleteData.append(contentsOf: generateDocumentGraphViewResponse.documentItemViewDeleteData)
        }
        getDocumentGraphViewResponse.objectControllerResponse = generateDocumentGraphViewResponse.objectControllerResponse
        getDocumentGraphViewResponse.currentNodeIndex = generateDocumentGraphViewResponse.currentNodeIndex
        getDocumentGraphViewResponse.currentItemIndex = generateDocumentGraphViewResponse.currentItemIndex
        getDocumentGraphViewResponse.currentLevel = generateDocumentGraphViewResponse.currentLevel
        getDocumentGraphViewResponse.currentSentenceIndex = generateDocumentGraphViewResponse.currentSentenceIndex
        if generateDocumentGraphViewRequest.getDocumentGraphViewRequest.isConfigurationView || generateDocumentGraphViewRequest.getDocumentGraphViewRequest.isDetailedView || generateDocumentGraphViewRequest.getDocumentGraphViewRequest.isDocumentMapView {
            getDocumentGraphViewResponse.isShowPopup = true
        }
        getDocumentGraphViewResponse.isConfigurationView = generateDocumentGraphViewRequest.getDocumentGraphViewRequest.isConfigurationView
        getDocumentGraphViewResponse.isDetailedView = generateDocumentGraphViewRequest.getDocumentGraphViewRequest.isDetailedView
        //        if generateDocumentGraphViewRequest.getDocumentGraphViewRequest.editMode {
        for (insertDataindex, insertData) in getDocumentGraphViewResponse.documentItemViewInsertData.enumerated() {
            let lineNumberViewModel = uvcViewGenerator.getLineNumberViewModel(lineNumber: insertDataindex + 1, parentId: insertData.uvcDocumentGraphModel.parentId, childrenId: insertData.uvcDocumentGraphModel.childrenId, editMode: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.editMode)
            insertData.uvcDocumentGraphModel.uvcViewModel.insert(lineNumberViewModel, at: 0)
        }
        //        }
        
        try populateDocumentOptions(udcDocumentTypeIdName: getDocumentGraphViewRequest.udcDocumentTypeIdName, udcProfile: getDocumentGraphViewRequest.udcProfile, documentOptions: &getDocumentGraphViewResponse.documentOptions, documentItemOptions: &getDocumentGraphViewResponse.documentItemOptions, categoryOptions: &getDocumentGraphViewResponse.categoryOptions, objectControllerOptions: &getDocumentGraphViewResponse.objectControllerOptions, photoOptions: &getDocumentGraphViewResponse.photoOptions, toolbarView: &getDocumentGraphViewResponse.toolbarView, objectControllerView: &getDocumentGraphViewResponse.objectControllerView, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, documentLanguage: documentLanguage, interfaceLanguage: interfaceLanguage)
        
        
        if udcDocument == nil {
            let databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: getDocumentGraphViewRequest.documentId)
            if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocument.databaseOrmError[0].name, description: databaseOrmResultUDCDocument.databaseOrmError[0].description))
                return
            }
            udcDocument = databaseOrmResultUDCDocument.object[0]
        }
        
//        try putRecentCallsEntry(udcDocument: udcDocument!, udcDocumentTypeIdName: getDocumentGraphViewRequest.udcDocumentTypeIdName, documentLanguage: getDocumentGraphViewRequest.documentLanguage, udcProfile: getDocumentGraphViewRequest.udcProfile, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
    
//        // Insert the item in begining
//        let _ = try findAndAddDocumentItemWithDetails(mode: "insert", udcSentencePatternDataGroupValue: udcSentencePatternDataGroupValueRecentArray, parentIdName: udcDocumentItemRecent!.idName, findItem: findItem, isDetailDocument: false, isDocumentMapDocument: true, fieldToGet: "UDCDocumentItem.Document", isInsertAtFirst: true, isInsertAtLast: false, isNeedToFindChild: false, detailDocumentTypeIdName: "UDCDocumentType.DocumentMap", detailDocumentModel: &udcDocumentGraphModelRecentDetail, inChildrens: udcDocumentItemRecent!.childrenId, parentFound: &parentFound, foundParentModel: &foundParentModel, foundParentId: &foundParentId, nodeIndex: 0, itemIndex: 0, level: 0, udcDocumentTypeIdName: getDocumentGraphViewRequest.udcDocumentTypeIdName, udcProfile: getDocumentGraphViewRequest.udcProfile, isParent: false, generatedIdName: "", neuronRequest: neuronRequest, neuronResponse: &neuronResponse, documentLanguage: documentLanguage, addUdcSentencePatternDataGroupValue: [], addUdcViewItemCollection: UDCViewItemCollection(), addUdcSentencePatternDataGroupValueIndex: [])
//
//        let _ = UDCDocumentRecent.remove(udbcDatabaseOrm: udbcDatabaseOrm!, udcDocumentId: getDocumentGraphViewRequest.documentId) as DatabaseOrmResult<UDCDocumentRecent>

//        try documentGraphModelReference(parentPathIdName: "UDCOptionMap.DocumentMap->\(getDocumentGraphViewRequest.udcDocumentTypeIdName)", itemIdName: "UDCOptionMapNode.Recents", udcDocumentId: generateDocumentGraphViewResponse.documentId, udcProfile: getDocumentGraphViewRequest.udcProfile, udcDocumentTypeIdName: getDocumentGraphViewRequest.udcDocumentTypeIdName, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, documentLanguage: documentLanguage)
//        try documentGraphModelReference(parentPathIdName: "UDCOptionMap.DocumentMap->\(getDocumentGraphViewRequest.udcDocumentTypeIdName)->UDCOptionMapNode.Library", itemIdName: "UDCDocumentMapNode.All", udcDocumentId: generateDocumentGraphViewResponse.documentId, udcProfile: getDocumentGraphViewRequest.udcProfile, udcDocumentTypeIdName: getDocumentGraphViewRequest.udcDocumentTypeIdName, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, documentLanguage: documentLanguage)
        if !getDocumentGraphViewRequest.isToGetDuplicate {
            getDocumentGraphViewResponse.documentLanguage = getDocumentGraphViewRequest.documentLanguage
        }
        
        let jsonUtilityGetDocumentGraphViewResponse = JsonUtility<GetDocumentGraphViewResponse>()
        let jsonGetDocumentGraphViewResponse = jsonUtilityGetDocumentGraphViewResponse.convertAnyObjectToJson(jsonObject: getDocumentGraphViewResponse)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonGetDocumentGraphViewResponse)
    }
    
    private func putDocumentMapEntry(mapUdcDocumentIdName: String, parentIdName: String, action: [String], udcDocument: UDCDocument, udcDocumentTypeIdName: String, documentLanguage: String, udcProfile: [UDCProfile], neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        var udcSentencePatternDataGroupValueRecentArray = [UDCSentencePatternDataGroupValue]()
        let udcSentencePatternDataGroupValueRecent = UDCSentencePatternDataGroupValue()
        udcSentencePatternDataGroupValueRecent.category = "UDCGrammarCategory.CommonNoun"
        udcSentencePatternDataGroupValueRecent.endCategoryIdName = "UDCDocumentItem.General"
        udcSentencePatternDataGroupValueRecent.uvcViewItemType = "UVCViewItemType.Photo"
        udcSentencePatternDataGroupValueRecentArray.append(udcSentencePatternDataGroupValueRecent)
        
        let udcDocmumentModel = try getDocumentModelWithParent(udcDocumentGraphModelId: udcDocument.udcDocumentGraphModelId, udcDocumentTypeIdName: udcDocumentTypeIdName, isLanguageChild: true, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        var fieldValue = [UDCSentencePatternDataGroupValue]()
        let findItem = UDCSentencePatternDataGroupValue()
        
        let udcSentencePatternDataGroupValueMap = UDCSentencePatternDataGroupValue()
        udcSentencePatternDataGroupValueMap.category = "UDCGrammarCategory.CommonNoun"
        udcSentencePatternDataGroupValueMap.endCategoryId = udcDocmumentModel![0]._id
        udcSentencePatternDataGroupValueMap.endCategoryIdName = udcDocmumentModel![0].idName
        findItem.endCategoryIdName = udcSentencePatternDataGroupValueMap.endCategoryIdName
        findItem.endCategoryId = udcSentencePatternDataGroupValueMap.endCategoryId
        findItem.endSubCategoryId = udcSentencePatternDataGroupValueMap.endSubCategoryId
        findItem.endSubCategoryIdName = udcSentencePatternDataGroupValueMap.endSubCategoryIdName
        udcSentencePatternDataGroupValueMap.uvcViewItemType = "UVCViewItemType.Text"
        udcSentencePatternDataGroupValueMap.udcDocumentId = udcDocument._id
        udcSentencePatternDataGroupValueMap.item = udcDocmumentModel![1].name
        udcSentencePatternDataGroupValueMap.itemId = udcDocmumentModel![1]._id
        udcSentencePatternDataGroupValueMap.itemIdName = udcDocmumentModel![1].idName
        udcSentencePatternDataGroupValueRecentArray.append(udcSentencePatternDataGroupValueMap)
        var udcDocumentGraphModelRecentDetail = UDCDocumentGraphModel()
        
        let udcDocumentItemRecent = try getDocumentModel(udcDocumentId: "", idName: mapUdcDocumentIdName, udcDocumentTypeIdName: "UDCDocumentType.DocumentItem", udcProfile: udcProfile, documentLanguage: documentLanguage, isLanguageChild: false, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        
        var parentFound = false
        var foundItem = false
        var foundParentId = ""
        var foundParentModel = UDCDocumentGraphModel()
        var udcDocumentGraphModelRecentDetailDocumentId: String = ""
        let isNeedToFindChild = action.contains("findChild")
        let isInsertAtFirst = action.contains("insertAtFirst")
        let isInsertAtLast = action.contains("insertAtLast")
        // Delete the item if found
        let _ = try findAndAddDocumentItemWithDetails(mode: "deleteLineAndInsertAtFirst", udcDocumentId: udcDocument._id, udcSentencePatternDataGroupValue: udcSentencePatternDataGroupValueRecentArray, parentIdName: parentIdName, findItem: findItem, isDetailDocument: false, isDocumentMapDocument: true, fieldToGet: "UDCDocumentItem.ReferenceDocument", isInsertAtFirst: isInsertAtFirst, isInsertAtLast: isInsertAtLast, isNeedToFindChild: isNeedToFindChild, detailDocumentTypeIdName: "UDCDocumentType.DocumentMap", detailDocumentModel: &udcDocumentGraphModelRecentDetail, detailDocumentId: &udcDocumentGraphModelRecentDetailDocumentId, inChildrens: udcDocumentItemRecent!.childrenId, parentFound: &parentFound, foundParentModel: &foundParentModel, foundParentId: &foundParentId, foundItem: &foundItem, nodeIndex: 0, itemIndex: 0, level: 0, udcDocumentTypeIdName: udcDocumentTypeIdName, udcProfile: udcProfile, isParent: false, generatedIdName: "", neuronRequest: neuronRequest, neuronResponse: &neuronResponse, documentLanguage: documentLanguage, addUdcSentencePatternDataGroupValue: [], addUdcViewItemCollection: UDCViewItemCollection(), addUdcSentencePatternDataGroupValueIndex: [])
        
        if !foundItem {
            let databaseOrmResultMapChild = UDCDocumentGraphModel.get(collectionName: "UDCDocumentMap", udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentGraphModelRecentDetail.childrenId[0])
            if databaseOrmResultMapChild.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultMapChild.databaseOrmError[0].name, description: databaseOrmResultMapChild.databaseOrmError[0].description))
                return
            }
            let udcDocumentMapChild = databaseOrmResultMapChild.object[0]
            
            let databaseOrmResultMapRef = UDCDocumentGraphModel.get(collectionName: "UDCDocumentMap", udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentGraphModelRecentDetail.childrenId[0])
            if databaseOrmResultMapRef.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultMapRef.databaseOrmError[0].name, description: databaseOrmResultMapRef.databaseOrmError[0].description))
                return
            }
            
            
            // Reference to the document item of application document
            
            fieldValue.append(udcSentencePatternDataGroupValueMap)
            var udcDocumentGraphModelResult = UDCDocumentGraphModel()
            var fieldFound: Bool = false
            var mdoelId = ""
            documentParser.setFieldValue(fieldidName: "UDCDocumentItem.Document", childrenId: udcDocumentMapChild.childrenId, fieldValue: fieldValue, udcDocumentTypeIdName: "UDCDocumentType.DocumentMap", documentLanguage: documentLanguage, udcDocumentGraphModelResult: &udcDocumentGraphModelResult, fieldFound: &fieldFound, modelId: &mdoelId, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            
            if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
                return
            }
            
            if !fieldFound {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "FieldNotFound", description: "Field not found"))
                return
            }
            
            
            // Put reference to the document map from document item of application document
            try putReference(udcDocumentId: udcDocumentGraphModelRecentDetailDocumentId, udcDocumentGraphModelId: fieldValue[0].itemId, udcDocumentTypeIdName: "UDCDocumentType.DocumentItem", objectUdcDocumentTypeIdName: "UDCDocumentType.DocumentMap", objectId: mdoelId, objectName: "UDCDocumentMap", documentLanguage: documentLanguage, udcProfile: udcProfile, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            
            if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
                return
            }
            
            // Update with reference document
            udcDocumentGraphModelResult.udcSentencePattern = try processGrammar(neuronRequest: neuronRequest, neuronResponse: &neuronResponse, udcSentencePattern: udcDocumentGraphModelResult.udcSentencePattern, newSentence: false, wordIndex: 0, sentenceIndex: 0, documentLanguage: documentLanguage, textStartIndex: 0)
            udcDocumentGraphModelResult.name = udcDocumentGraphModelResult.udcSentencePattern.sentence
            udcDocumentGraphModelResult.udcDocumentTime.changedBy = documentParser.getUDCProfile(udcProfile: udcProfile, idName: "UPCProfileItem.Human")
            udcDocumentGraphModelResult.udcDocumentTime.changedTime = Date()
            let databaseOrmResultUpdate = UDCDocumentGraphModel.update(collectionName: "UDCDocumentMap", udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentGraphModelResult)
            if databaseOrmResultUpdate.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUpdate.databaseOrmError[0].name, description: databaseOrmResultUpdate.databaseOrmError[0].description))
                return
            }
         }
    }
    
    private func addEntryToDocumentItem(udcDocumentId: String, name: String, udcDocumentTypeIdName: String, udcProfile: [UDCProfile], documentLanguage: String, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        // Get the recent document item
        
    }
    
    private func getDocumentModel(udcDocumentId: String, idName: String, udcDocumentTypeIdName: String, udcProfile: [UDCProfile], documentLanguage: String, isLanguageChild: Bool, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws -> UDCDocumentGraphModel? {
        // Get the recent documents document
        var databaseOrmResultUDCDocument: DatabaseOrmResult<UDCDocument>?
        if idName.isEmpty {
            databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentId)
        } else {
            databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, udcProfile: udcProfile, idName: idName, udcDocumentTypeIdName: udcDocumentTypeIdName, language: documentLanguage)
        }
        if databaseOrmResultUDCDocument!.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocument!.databaseOrmError[0].name, description: databaseOrmResultUDCDocument!.databaseOrmError[0].description))
            return nil
        }
        let udcDocument = databaseOrmResultUDCDocument!.object[0]

        let udcDocumentItem = try getDocumentModel(udcDocumentGraphModelId: udcDocument.udcDocumentGraphModelId, udcDocumentTypeIdName: udcDocumentTypeIdName,  isLanguageChild: isLanguageChild, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        
        return udcDocumentItem
    }
    
    private func getDocumentModel(udcDocumentGraphModelIdName: String, language: String, udcDocumentTypeIdName: String, isLanguageChild: Bool, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws -> UDCDocumentGraphModel? {
        
        // Get the document item based on document
        let databaseOrmUDCDocumentItem = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, idName: udcDocumentGraphModelIdName, language: language)
        if databaseOrmUDCDocumentItem.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentItem.databaseOrmError[0].name, description: databaseOrmUDCDocumentItem.databaseOrmError[0].description))
            return nil
        }
        let udcDocumentItem = databaseOrmUDCDocumentItem.object[0]
        
        let returnDocumentItem = try getDocumentModel(udcDocumentGraphModelId: udcDocumentItem._id, udcDocumentTypeIdName: udcDocumentTypeIdName, isLanguageChild: isLanguageChild, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        
        return returnDocumentItem
    }
    
    private func getDocumentModel(udcDocumentGraphModelId: String, udcDocumentTypeIdName: String, isLanguageChild: Bool, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws -> UDCDocumentGraphModel? {
        
        // Get the document item based on document
        let databaseOrmUDCDocumentItem = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentGraphModelId)
        if databaseOrmUDCDocumentItem.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentItem.databaseOrmError[0].name, description: databaseOrmUDCDocumentItem.databaseOrmError[0].description))
            return nil
        }
        let udcDocumentItem = databaseOrmUDCDocumentItem.object[0]
        
        if isLanguageChild {
            // Get the document item child for language title
            let databaseOrmUDCDocumentItemChild = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentItem.childrenId[0])
            if databaseOrmUDCDocumentItemChild.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentItemChild.databaseOrmError[0].name, description: databaseOrmUDCDocumentItemChild.databaseOrmError[0].description))
                return nil
            }
            let udcDocumentItemChild = databaseOrmUDCDocumentItemChild.object[0]
            return udcDocumentItemChild
        }
        
        return udcDocumentItem
    }
    
    private func getDocumentModelWithParent(udcDocumentGraphModelId: String, udcDocumentTypeIdName: String, isLanguageChild: Bool, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws -> [UDCDocumentGraphModel]? {
        var udcDocumentItemArray = [UDCDocumentGraphModel]()

        // Get the document item based on document
        let databaseOrmUDCDocumentItem = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentGraphModelId)
        if databaseOrmUDCDocumentItem.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentItem.databaseOrmError[0].name, description: databaseOrmUDCDocumentItem.databaseOrmError[0].description))
            return nil
        }
        let udcDocumentItem = databaseOrmUDCDocumentItem.object[0]
        
        if isLanguageChild && udcDocumentItem.childrenId.count > 0 {
            udcDocumentItemArray.append(udcDocumentItem)
            
            // Get the document item child for language title
            let databaseOrmUDCDocumentItemChild = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentItem.childrenId[0])
            if databaseOrmUDCDocumentItemChild.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentItemChild.databaseOrmError[0].name, description: databaseOrmUDCDocumentItemChild.databaseOrmError[0].description))
                return nil
            }
            let udcDocumentItemChild = databaseOrmUDCDocumentItemChild.object[0]
            udcDocumentItemArray.append(udcDocumentItemChild)
            return udcDocumentItemArray
        }
        
        if udcDocumentItem.parentId.count > 0 {
            let databaseOrmUDCDocumentItemParent = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentGraphModelId)
            if databaseOrmUDCDocumentItemParent.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentItemParent.databaseOrmError[0].name, description: databaseOrmUDCDocumentItemParent.databaseOrmError[0].description))
                return nil
            }
            let udcDocumentItemParent = databaseOrmUDCDocumentItemParent.object[0]
            udcDocumentItemArray.append(udcDocumentItemParent)
        }
        
        udcDocumentItemArray.append(udcDocumentItem)

        return udcDocumentItemArray
    }
    
    private func getDcoumentIdFromMap(udcDocumentId: String, udcDocumentTypeIdName: String, udcProfile: [UDCProfile], documentLanguage: String, children: [String], itemModel: inout UDCDocumentGraphModel, isDetailDocument: Bool, isDocumentMapDocument: Bool, fieldToGet: String, inDocumentTypeIdName: String, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws -> String? {
        for child in children {
            let databaseOrmUDCDocumentItem = UDCDocumentGraphModel.get(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, id: child)
            if databaseOrmUDCDocumentItem.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentItem.databaseOrmError[0].name, description: databaseOrmUDCDocumentItem.databaseOrmError[0].description))
                return nil
            }
            itemModel = databaseOrmUDCDocumentItem.object[0]

            var idToLookFor: String = ""
            if isDetailDocument {
                idToLookFor = itemModel.objectId
            } else {
                idToLookFor = itemModel.documentMapObjectId
            }
            if idToLookFor.isEmpty {
                if isDetailDocument {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "DocumentDetailNotFound", description: "Document detail not found"))
                } else {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "DocumentMapNotFound", description: "Document map not found"))
                }
                return nil
            }
            
            // Get the document
            let udcDocumenttemMap = try getDocumentModel(udcDocumentId: idToLookFor, idName: "", udcDocumentTypeIdName: udcDocumentTypeIdName, udcProfile: udcProfile, documentLanguage: documentLanguage, isLanguageChild: true, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            
            if neuronUtility!.isNeuronOperationError(neuronResponse:  neuronResponse) {
                return nil
            }
            
            var fieldValueMap = [String: [UDCSentencePatternDataGroupValue]]()
            documentParser.getField(fieldidName: fieldToGet, childrenId: udcDocumenttemMap!.childrenId, fieldValue: &fieldValueMap, udcDocumentTypeIdName: inDocumentTypeIdName, documentLanguage: documentLanguage)
            let fieldValueArray = fieldValueMap[fieldToGet]
            if (fieldValueArray != nil)  {
                for udcspdgv in fieldValueArray! {
                    if udcspdgv.endCategoryIdName == fieldToGet {
                        return udcspdgv.itemId
                    }
                }
            }
        }
        
        return nil
    }
    
    private func isNeuronProcessingIt(operationName: String, udcDocumentTypeIdName: String, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws ->Bool {
        var called = false
        var documentTypeProcessRequest = DocumentGraphTypeProcessRequest()
        let neuronRequestLocal1 = neuronRequest
        var jsonUtilityDocumentTypeProcessRequest = JsonUtility<DocumentGraphTypeProcessRequest>()
        var jsonDocumentGetSentencePatternForDocumentItemRequest = jsonUtilityDocumentTypeProcessRequest.convertAnyObjectToJson(jsonObject: documentTypeProcessRequest)
        neuronRequestLocal1.neuronOperation.neuronData.text = jsonDocumentGetSentencePatternForDocumentItemRequest
        called = try callNeuron(neuronRequest: neuronRequestLocal1, neuronResponse: &neuronResponse, operationName: operationName, udcDocumentTypeIdName: udcDocumentTypeIdName)
        
        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
            return false
        }
        
        var documentTypeProcessResponse = DocumentGraphTypeProcessResponse()
        if !called {
            documentTypeProcessResponse.isProcessed = false
        } else {
            documentTypeProcessResponse = neuronUtility!.getNeuronRequest(json: neuronResponse.neuronOperation.neuronData.text, object: DocumentGraphTypeProcessResponse())
        }
        return documentTypeProcessResponse.isProcessed
    }
    
    private func getDocumentModels(getDocumentModelsRequest: GetDocumentModelsRequest, getDocumentModelsResponse: inout GetDocumentModelsResponse, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let documentLanguage = getDocumentModelsRequest.documentGraphNewRequest.documentLanguage
        let interfaceLanguage = getDocumentModelsRequest.documentGraphNewRequest.interfaceLanguage
        
        let databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, udcProfile: getDocumentModelsRequest.udcProfile, idName: "UDCDocument.Blank", udcDocumentTypeIdName: getDocumentModelsRequest.documentGraphNewRequest.udcDocumentTypeIdName, language: documentLanguage)
        if databaseOrmResultUDCDocument.databaseOrmError.count == 0 {
            let udcDocument = databaseOrmResultUDCDocument.object[0]
            
            let generateDocumentGraphViewRequest = GenerateDocumentGraphViewRequest()
            generateDocumentGraphViewRequest.getDocumentGraphViewRequest.documentId = udcDocument._id
            generateDocumentGraphViewRequest.getDocumentGraphViewRequest.documentLanguage = documentLanguage
            generateDocumentGraphViewRequest.getDocumentGraphViewRequest.editMode = true
            generateDocumentGraphViewRequest.getDocumentGraphViewRequest.interfaceLanguage = interfaceLanguage
            generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcDocumentTypeIdName = getDocumentModelsRequest.documentGraphNewRequest.udcDocumentTypeIdName
            generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcProfile = getDocumentModelsRequest.udcProfile
            generateDocumentGraphViewRequest.getDocumentGraphViewRequest.isToGetDuplicate = true
            generateDocumentGraphViewRequest.getDocumentGraphViewRequest.duplicateToDocumentLanguage = documentLanguage
            var nodeIndex = 0
            var uvcDocumentGraphModelArray = [UVCDocumentGraphModel]()
            var generateDocumentGraphViewResponse = GenerateDocumentGraphViewResponse()
            var udcDocumentGraphModel = UDCDocumentGraphModel()
            var documentLanguageFromGenerateGraphModel = generateDocumentGraphViewRequest.getDocumentGraphViewRequest.documentLanguage
            try generateDocumentGraphModel(generateDocumentGraphViewRequest: generateDocumentGraphViewRequest, udcDocumentGraphModel: &udcDocumentGraphModel, nodeIndex: &nodeIndex, generateDocumentGraphViewResponse: &generateDocumentGraphViewResponse, isNewDocument: true, documentLanguage: &documentLanguageFromGenerateGraphModel, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            
            try generateDocumentGraphModelView(udcDocumentGraphModel: udcDocumentGraphModel, uvcDocumentGraphModelArray: &uvcDocumentGraphModelArray, udcDocumentTypeIdName: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.udcDocumentTypeIdName, documentLanguage: documentLanguageFromGenerateGraphModel, isEditableMode: generateDocumentGraphViewRequest.getDocumentGraphViewRequest.editMode, documentTitle: &generateDocumentGraphViewResponse.documentTitle,  neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            
            getDocumentModelsResponse.uvcDocumentGraphModel.append(contentsOf: uvcDocumentGraphModelArray)
            for (uvcdmIndex, uvcdm) in getDocumentModelsResponse.uvcDocumentGraphModel.enumerated() {
                uvcViewGenerator.generateLineNumbers(uvcViewModel: &uvcdm.uvcViewModel, uvcdmIndex: uvcdmIndex, parentId: uvcdm.parentId, childrenId: uvcdm.childrenId, editMode: true)
            }
            getDocumentModelsResponse.itemIndex = 2
            getDocumentModelsResponse.nodeIndex = 0
            getDocumentModelsResponse.cursorSentence = 0
            getDocumentModelsResponse.isDocumentAlreadyCreated = true
            getDocumentModelsResponse.documentId = generateDocumentGraphViewResponse.documentId
            
            let jsonUtilityGetDocumentModelsResponse = JsonUtility<GetDocumentModelsResponse>()
            let jsonDocumentGetDocumentModelsResponse = jsonUtilityGetDocumentModelsResponse.convertAnyObjectToJson(jsonObject: getDocumentModelsResponse)
            neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonDocumentGetDocumentModelsResponse)
            return
        }
        
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
        udcSentencePatternLocal = try processGrammar(neuronRequest: neuronRequest, neuronResponse: &neuronResponse, udcSentencePattern: udcSentencePatternLocal, newSentence: true, wordIndex: 0, sentenceIndex: 0, documentLanguage: documentLanguage, textStartIndex: 0)
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
        udcSentencePatternLocal = try processGrammar(neuronRequest: neuronRequest, neuronResponse: &neuronResponse, udcSentencePattern: udcSentencePatternLocal, newSentence: true, wordIndex: 0, sentenceIndex: 0, documentLanguage: documentLanguage, textStartIndex: 0)
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
    
    private func categorySelected(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let documentCategorySelectedRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: DocumentCategorySelectedRequest())
        
        let documentLanguage = documentCategorySelectedRequest.documentLanguage
        
        if documentCategorySelectedRequest.itemIndex != 1 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "ShouldBeLineStart", description: "Should be line start"))
            return
        }
        
        let documentGraphInsertItemRequest = DocumentGraphInsertItemRequest()
        
        var documentGraphInsertItemResponse = DocumentGraphInsertItemResponse()
        
        let databaseOrmUDCGrammarItemType = UDCGrammarItemType.get("UDCGrammarItem.Category", udbcDatabaseOrm!, documentLanguage)
        if databaseOrmUDCGrammarItemType.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCGrammarItemType.databaseOrmError[0].name, description: databaseOrmUDCGrammarItemType.databaseOrmError[0].description))
            return
        }
        let categoryItem = databaseOrmUDCGrammarItemType.object[0]
        documentGraphInsertItemRequest.item = "\(categoryItem.name)-\(NSUUID().uuidString)"
        documentGraphInsertItemRequest.parentId = documentCategorySelectedRequest.parentId
        documentGraphInsertItemRequest.nodeId = documentCategorySelectedRequest.nodeId
        documentGraphInsertItemRequest.nodeIndex = documentCategorySelectedRequest.nodeIndex
        documentGraphInsertItemRequest.itemIndex = documentCategorySelectedRequest.itemIndex
        documentGraphInsertItemRequest.sentenceIndex = documentCategorySelectedRequest.sentenceIndex
        documentGraphInsertItemRequest.level = documentCategorySelectedRequest.level
        documentGraphInsertItemRequest.documentId = documentCategorySelectedRequest.documentId
        documentGraphInsertItemRequest.udcDocumentTypeIdName = documentCategorySelectedRequest.udcDocumentTypeIdName
        documentGraphInsertItemRequest.objectControllerRequest = documentCategorySelectedRequest.objectControllerRequest
        documentGraphInsertItemRequest.udcProfile = documentCategorySelectedRequest.udcProfile
        documentGraphInsertItemRequest.isParent = true
        documentGraphInsertItemRequest.optionItemId = documentCategorySelectedRequest.optionItemId
        documentGraphInsertItemRequest.optionItemObjectName = documentCategorySelectedRequest.optionItemObjectName
        documentGraphInsertItemRequest.documentLanguage = documentCategorySelectedRequest.documentLanguage
        try documentInsertItem(documentGraphInsertItemRequest: documentGraphInsertItemRequest, documentGraphInsertItemResponse: &documentGraphInsertItemResponse, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, isGeneratedItem: true)
        
        let documentCategorySelectedResponse = DocumentCategorySelectedResponse()
        if documentGraphInsertItemResponse.documentItemViewInsertData.count > 0 {
            documentCategorySelectedResponse.documentItemViewInsertData.append(contentsOf: documentGraphInsertItemResponse.documentItemViewInsertData)
        }
        if documentGraphInsertItemResponse.documentItemViewChangeData.count > 0 {
            documentCategorySelectedResponse.documentItemViewChangeData.append(contentsOf: documentGraphInsertItemResponse.documentItemViewChangeData)
        }
        if documentGraphInsertItemResponse.documentItemViewDeleteData.count > 0 {
            documentCategorySelectedResponse.documentItemViewDeleteData.append(contentsOf: documentGraphInsertItemResponse.documentItemViewDeleteData)
        }
        documentCategorySelectedResponse.objectControllerResponse = documentGraphInsertItemResponse.objectControllerResponse
        
        let jsonUtilityDocumentCategorySelectedResponse = JsonUtility<DocumentCategorySelectedResponse>()
        let jsonDocumentDocumentCategorySelectedResponse = jsonUtilityDocumentCategorySelectedResponse.convertAnyObjectToJson(jsonObject: documentCategorySelectedResponse)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonDocumentDocumentCategorySelectedResponse)
    }
    
    private func categoryOptionsSelected(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let documentCategoryOptionSelectedRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: DocumentCategoryOptionSelectedRequest())
        
        let documentLanguage = documentCategoryOptionSelectedRequest.documentLanguage
        
        var documentGraphInsertItemResponse = DocumentGraphInsertItemResponse()
        
        if documentCategoryOptionSelectedRequest.categoryOptionPathIdName.joined(separator: "->") == "UDCOptionMapNode.DocumentItemOptions->UDCOptionMapNode.CategoryOptions->UVCViewItemType.Sentence->" {
            let documentGraphInsertItemRequest = DocumentGraphInsertItemRequest()
            
            
            let databaseOrmUDCGrammarItemType = UDCGrammarItemType.get("UDCGrammarItem.Category", udbcDatabaseOrm!, documentLanguage)
            if databaseOrmUDCGrammarItemType.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCGrammarItemType.databaseOrmError[0].name, description: databaseOrmUDCGrammarItemType.databaseOrmError[0].description))
                return
            }
            let categoryItem = databaseOrmUDCGrammarItemType.object[0]
            documentGraphInsertItemRequest.item = "\(categoryItem.name)-\(NSUUID().uuidString)"
            documentGraphInsertItemRequest.parentId = documentCategoryOptionSelectedRequest.parentId
            documentGraphInsertItemRequest.nodeId = documentCategoryOptionSelectedRequest.nodeId
            documentGraphInsertItemRequest.nodeIndex = documentCategoryOptionSelectedRequest.nodeIndex
            documentGraphInsertItemRequest.itemIndex = documentCategoryOptionSelectedRequest.itemIndex
            documentGraphInsertItemRequest.sentenceIndex = documentCategoryOptionSelectedRequest.sentenceIndex
            documentGraphInsertItemRequest.level = documentCategoryOptionSelectedRequest.level
            documentGraphInsertItemRequest.documentId = documentCategoryOptionSelectedRequest.documentId
            documentGraphInsertItemRequest.udcDocumentTypeIdName = documentCategoryOptionSelectedRequest.udcDocumentTypeIdName
            documentGraphInsertItemRequest.objectControllerRequest = documentCategoryOptionSelectedRequest.objectControllerRequest
            documentGraphInsertItemRequest.udcProfile = documentCategoryOptionSelectedRequest.udcProfile
            documentGraphInsertItemRequest.isParent = false
            documentGraphInsertItemRequest.optionItemId = documentCategoryOptionSelectedRequest.optionItemId
            documentGraphInsertItemRequest.optionItemObjectName = documentCategoryOptionSelectedRequest.optionItemObjectName
            try documentInsertItem(documentGraphInsertItemRequest: documentGraphInsertItemRequest, documentGraphInsertItemResponse: &documentGraphInsertItemResponse, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, isGeneratedItem: true)
        } else {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "InvalidCategoryOption", description: "Invalid Category Option"))
            return
        }
        
        let documentCategoryOptionSelectedResponse = DocumentCategoryOptionSelectedResponse()
        if documentGraphInsertItemResponse.documentItemViewInsertData.count > 0 {
            documentCategoryOptionSelectedResponse.documentItemViewInsertData.append(contentsOf: documentGraphInsertItemResponse.documentItemViewInsertData)
        }
        if documentGraphInsertItemResponse.documentItemViewChangeData.count > 0 {
            documentCategoryOptionSelectedResponse.documentItemViewChangeData.append(contentsOf: documentGraphInsertItemResponse.documentItemViewChangeData)
        }
        if documentGraphInsertItemResponse.documentItemViewDeleteData.count > 0 {
            documentCategoryOptionSelectedResponse.documentItemViewDeleteData.append(contentsOf: documentGraphInsertItemResponse.documentItemViewDeleteData)
        }
        documentCategoryOptionSelectedResponse.objectControllerResponse = documentGraphInsertItemResponse.objectControllerResponse
        let jsonUtilityDocumentCategoryOptionSelectedResponse = JsonUtility<DocumentCategoryOptionSelectedResponse>()
        let jsonDocumentCategoryOptionSelectedResponse = jsonUtilityDocumentCategoryOptionSelectedResponse.convertAnyObjectToJson(jsonObject: documentCategoryOptionSelectedResponse)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonDocumentCategoryOptionSelectedResponse)
    }
    
    private func getViewConfigurationOptions(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let documentGetViewConfigurationOptionsRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: DocumentGetViewConfigurationOptionsRequest())
        
        let documentLanguage = documentGetViewConfigurationOptionsRequest.documentLanguage
        let interfaceLanguage = documentGetViewConfigurationOptionsRequest.interfaceLanguage
        
        let databaseOrmResultUVCViewItemType = UVCViewItemType.get(udbcDatabaseOrm!, idName: documentGetViewConfigurationOptionsRequest.uvcViewItemType, interfaceLanguage)
        if databaseOrmResultUVCViewItemType.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUVCViewItemType.databaseOrmError[0].name, description: databaseOrmResultUVCViewItemType.databaseOrmError[0].description))
            return
        }
        
        let getOptionMapRequest = GetOptionMapRequest()
        getOptionMapRequest.name = "UDCOptionMap.\(documentGetViewConfigurationOptionsRequest.uvcViewItemType.split(separator: ".")[1])Configuration"
        getOptionMapRequest.udcProfile = documentGetViewConfigurationOptionsRequest.udcProfile
        let jsonUtilityGetOptionMapRequest = JsonUtility<GetOptionMapRequest>()
        let jsonDocumentGetOptionMapRequest = jsonUtilityGetOptionMapRequest.convertAnyObjectToJson(jsonObject: getOptionMapRequest)
        let neuronRequestLocal = NeuronRequest()
        neuronRequestLocal.neuronSource._id = neuronRequest.neuronSource._id
        neuronRequestLocal.neuronOperation.synchronus = true
        neuronRequestLocal.neuronOperation._id = neuronRequest.neuronOperation._id
        neuronRequestLocal.neuronSource.name = DocumentGraphNeuron.getName()
        neuronRequestLocal.neuronSource.type = DocumentGraphNeuron.getName()
        neuronRequestLocal.neuronOperation.name = "OptionMapNeuron.OptionMap.Get"
        neuronRequestLocal.neuronOperation.parent = true
        neuronRequestLocal.neuronOperation.neuronData.text = jsonDocumentGetOptionMapRequest
        neuronRequestLocal.neuronTarget.name = "OptionMapNeuron"
        
        try callOtherNeuron(neuronRequest: neuronRequestLocal, neuronResponse: &neuronResponse, neuronName: "OptionMapNeuron", overWriteResponse: true)
        
        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse)  || neuronResponse.neuronOperation.neuronData.text.isEmpty {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.removeAll()
            return
        }
        
        let getOptionMapResponse = neuronUtility!.getNeuronRequest(json: neuronResponse.neuronOperation.neuronData.text, object: GetOptionMapResponse())
        
        let documentGetViewConfigurationOptionsResponse = DocumentGetViewConfigurationOptionsResponse()
        documentGetViewConfigurationOptionsResponse.uvcOptionViewModel.append(contentsOf: getOptionMapResponse.uvcOptionMapViewModel.uvcOptionViewModel)
        let jsonUtilityDocumentGetViewConfigurationOptionsResponse = JsonUtility<DocumentGetViewConfigurationOptionsResponse>()
        let jsonDocumentGetViewConfigurationOptionsResponse = jsonUtilityDocumentGetViewConfigurationOptionsResponse.convertAnyObjectToJson(jsonObject: documentGetViewConfigurationOptionsResponse)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonDocumentGetViewConfigurationOptionsResponse)
    }
    
    private func getObjectControllerView(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let getObjectControllerViewRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: GetObjectControllerViewRequest())
        
        let getOptionMapRequest = GetOptionMapRequest()
        getOptionMapRequest.name = "UDCOptionMap.InterfaceOptions"
        getOptionMapRequest.udcProfile = getObjectControllerViewRequest.udcProfile
        getOptionMapRequest.documentLanguage = getObjectControllerViewRequest.documentLanguage
        getOptionMapRequest.interfaceLanguage = getObjectControllerViewRequest.interfaceLanguage
        let jsonUtilityGetOptionMapRequest = JsonUtility<GetOptionMapRequest>()
        let jsonDocumentGetOptionMapRequest = jsonUtilityGetOptionMapRequest.convertAnyObjectToJson(jsonObject: getOptionMapRequest)
        let neuronRequestLocal = NeuronRequest()
        neuronRequestLocal.neuronSource._id = neuronRequest.neuronSource._id
        neuronRequestLocal.neuronOperation.synchronus = true
        neuronRequestLocal.neuronOperation._id = neuronRequest.neuronOperation._id
        neuronRequestLocal.neuronSource.name = DocumentGraphNeuron.getName()
        neuronRequestLocal.neuronSource.type = DocumentGraphNeuron.getName()
        neuronRequestLocal.neuronOperation.name = "OptionMapNeuron.OptionMap.Get"
        neuronRequestLocal.neuronOperation.parent = true
        neuronRequestLocal.neuronOperation.neuronData.text = jsonDocumentGetOptionMapRequest
        neuronRequestLocal.neuronTarget.name = "OptionMapNeuron"
        
        try callOtherNeuron(neuronRequest: neuronRequestLocal, neuronResponse: &neuronResponse, neuronName: "OptionMapNeuron", overWriteResponse: true)
        
        let getOptionMapResponse = neuronUtility!.getNeuronRequest(json: neuronResponse.neuronOperation.neuronData.text, object: GetOptionMapResponse())
        
        let objectControllerView = UVCToolbarView()
        objectControllerView.controllerText.append("")
        objectControllerView.photoName.append("")
        objectControllerView.uvcViewItemType.append("UVCViewItemType.Text")
        objectControllerView.controllerText.append("")
        objectControllerView.photoName.append("Elipsis")
        objectControllerView.uvcViewItemType.append("UVCViewItemType.Button")
        objectControllerView.controllerText.append("")
        objectControllerView.photoName.append("ObjectController")
        objectControllerView.uvcViewItemType.append("UVCViewItemType.Button")
        objectControllerView.controllerText.append("")
        objectControllerView.photoName.append("UpDirectionArrow")
        objectControllerView.uvcViewItemType.append("UVCViewItemType.Button")
        objectControllerView.controllerText.append("")
        objectControllerView.photoName.append("DownDirectionArrow")
        objectControllerView.uvcViewItemType.append("UVCViewItemType.Button")
        objectControllerView.controllerText.append("")
        objectControllerView.photoName.append("LeftDirectionArrow")
        objectControllerView.uvcViewItemType.append("UVCViewItemType.Button")
        objectControllerView.controllerText.append("")
        objectControllerView.photoName.append("RightDirectionArrow")
        objectControllerView.uvcViewItemType.append("UVCViewItemType.Button")
        for ucovm in getOptionMapResponse.uvcOptionMapViewModel.uvcOptionViewModel {
            let value = ucovm.getText(name: "Name")!.value
            if ucovm.idName == "UDCOptionMapNode.Delete" || ucovm.idName == "UDCOptionMapNode.Edit" || ucovm.idName == "UDCOptionMapNode.Select" {
                objectControllerView.photoName.append("")
                objectControllerView.controllerText.append(value)
                objectControllerView.uvcViewItemType.append("UVCViewItemType.Button")
            }
        }
        
        
        let jsonUtilityobjectControllerView = JsonUtility<UVCToolbarView>()
        let jsonobjectControllerView = jsonUtilityobjectControllerView.convertAnyObjectToJson(jsonObject: objectControllerView)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonobjectControllerView)
    }
    
    private func documentDeleteLine(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let documentGraphDeleteLineRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: DocumentGraphDeleteLineRequest())
        
        let documentLanguage = documentGraphDeleteLineRequest.documentLanguage
        // Get the model and check whether line can be deleted
        let databaseOrmUDCDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphDeleteLineRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: documentGraphDeleteLineRequest.nodeId, language: documentLanguage) as DatabaseOrmResult<UDCDocumentGraphModel>
        if databaseOrmUDCDocumentGraphModel.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentGraphModel.databaseOrmError[0].name, description: databaseOrmUDCDocumentGraphModel.databaseOrmError[0].description))
            return
        }
        let udcDocumentGraphModel = databaseOrmUDCDocumentGraphModel.object[0]
        
        // Generate change data for line numbers
        let databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: documentGraphDeleteLineRequest.documentId, language: documentLanguage)
        if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocument.databaseOrmError[0].name, description: databaseOrmResultUDCDocument.databaseOrmError[0].description))
            return
        }
        let udcDocument = databaseOrmResultUDCDocument.object[0]
        
        let validateDocumentGraphItemForDeleteLineRequest = ValidateDocumentGraphItemForDeleteLineRequest()
        validateDocumentGraphItemForDeleteLineRequest.documentGraphDeleteLineRequest = documentGraphDeleteLineRequest
        validateDocumentGraphItemForDeleteLineRequest.udcValidationStepTypeIdName = "UDCValidationStep.Request"
        validateDocumentGraphItemForDeleteLineRequest.deleteDocumentModel = udcDocumentGraphModel
        validateDocumentGraphItemForDeleteLineRequest.udcDocument = udcDocument
        let neuronRequestLocal = NeuronRequest()
        neuronRequestLocal.neuronSource._id = neuronRequest.neuronSource._id
        neuronRequestLocal.neuronOperation.synchronus = true
        neuronRequestLocal.neuronOperation._id = neuronRequest.neuronOperation._id
        neuronRequestLocal.neuronSource.name = DocumentGraphNeuron.getName()
        neuronRequestLocal.neuronSource.type = DocumentGraphNeuron.getName()
        neuronRequestLocal.neuronOperation.name = "DocumentGraphNeuron.Document.Validate.Delete.Line"
        neuronRequestLocal.neuronOperation.parent = true
        let jsonUtilityValidatValidateDocumentGraphItemForDeleteLineRequest = JsonUtility<ValidateDocumentGraphItemForDeleteLineRequest>()
        neuronRequestLocal.neuronOperation.neuronData.text = jsonUtilityValidatValidateDocumentGraphItemForDeleteLineRequest.convertAnyObjectToJson(jsonObject: validateDocumentGraphItemForDeleteLineRequest)
        try callNeuron(neuronRequest: neuronRequestLocal, neuronResponse: &neuronResponse, operationName: "DocumentGraphNeuron.Document.Validate.Delete.Line", udcDocumentTypeIdName: documentGraphDeleteLineRequest.udcDocumentTypeIdName)
        
        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
            return
        }
        
        if documentGraphDeleteLineRequest.udcDocumentTypeIdName == "UDCDocumentType.DocumentItem" && udcDocumentGraphModel.level > 1 {
            let databaseOrmUDCDocumentGraphModelParent = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphDeleteLineRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentGraphModel.parentId[0], language: documentLanguage) as DatabaseOrmResult<UDCDocumentGraphModel>
            if databaseOrmUDCDocumentGraphModelParent.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentGraphModelParent.databaseOrmError[0].name, description: databaseOrmUDCDocumentGraphModelParent.databaseOrmError[0].description))
                return
            }
            let udcDocumentGraphModelParent = databaseOrmUDCDocumentGraphModelParent.object[0]
            let udcSentencePatternDataGroupValueLocalFind = UDCSentencePatternDataGroupValue()
            if udcDocumentGraphModelParent.level == 1 {
                udcSentencePatternDataGroupValueLocalFind.endCategoryIdName = udcDocumentGraphModelParent.idName
            } else {
                let databaseOrmResultCategory = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphDeleteLineRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentGraphModelParent.parentId[0])
                udcSentencePatternDataGroupValueLocalFind.endCategoryIdName = databaseOrmResultCategory.object[0].idName
            }
            udcSentencePatternDataGroupValueLocalFind.itemId = udcDocumentGraphModel._id
            udcSentencePatternDataGroupValueLocalFind.endSubCategoryId = udcDocumentGraphModel.parentId[0]
            
            
            var found = false
            findDocumentItemInAllDocs(find: udcSentencePatternDataGroupValueLocalFind, documentLanguage: documentLanguage, found: &found, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            if found {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "CannotDeleteSinceItIsReferedSomewhere", description: "Cannot delete since it is refered somewhere!"))
                return
            }
        }
        for udcspdg in udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup {
            for udcspdgv in udcspdg.udcSentencePatternDataGroupValue {
                if udcspdgv.udcDocumentItemGraphReferenceTarget.count > 0 {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "CannotDeleteSourceRefered", description: "Cannot Delete line, since it caontains a source which is refered somewhere else!"))
                    return
                }
                //                if udcspdgv.endCategoryIdName.hasSuffix(".FoodRecipeCategory") || udcspdgv.endCategoryIdName == "UDCGrammarItem.Title" {
                //                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "CannotDeleteCategory", description: "Cannot Delete this line, since it is required!"))
                //                    return
                //                }
            }
        }
        
        if documentGraphDeleteLineRequest.udcDocumentTypeIdName == "UDCDocumentType.DocumentItem" && udcDocumentGraphModel.level > 1 && documentGraphDeleteLineRequest.documentLanguage == "en" {
            let udcSentencePatternDataGroupValueLocal = UDCSentencePatternDataGroupValue()
            udcSentencePatternDataGroupValueLocal.endCategoryIdName = "UDCDocumentItemMapNode.DocumentItem"
            udcSentencePatternDataGroupValueLocal.itemId = udcDocumentGraphModel._id
            udcSentencePatternDataGroupValueLocal.endSubCategoryId = udcDocumentGraphModel.parentId[0]
            var found = false
            checkDocumentItemUsedInAnyDocs(find: udcSentencePatternDataGroupValueLocal, documentLanguage: documentLanguage, found: &found, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            if found {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "CannotDeleteItIsUsedInADocument", description: "Cannot delete it is used in a document"))
                return
            }
        }
        
        var udcDocumentGraphModelNearBy: UDCDocumentGraphModel?
        
        if documentGraphDeleteLineRequest.nearbyNodeId != nil {
            let databaseOrmResultudcDocumentGraphModelNearBy = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphDeleteLineRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: documentGraphDeleteLineRequest.nearbyNodeId!, language: documentLanguage) as DatabaseOrmResult<UDCDocumentGraphModel>
            if databaseOrmResultudcDocumentGraphModelNearBy.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModelNearBy.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModelNearBy.databaseOrmError[0].description))
                return
            }
            udcDocumentGraphModelNearBy = databaseOrmResultudcDocumentGraphModelNearBy.object[0]
        }
        
        // If line is delted then delete any reference in the source items
        for (udcspdgIndex, udcspdg) in udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup.enumerated() {
            for (udcspdgvIndex, udcspdgv) in udcspdg.udcSentencePatternDataGroupValue.enumerated() {
                if udcspdgv.udcDocumentItemGraphReferenceSource.count > 0 {
                    for udcdigrs in udcspdgv.udcDocumentItemGraphReferenceSource {
                        let databaseOrmResultudcDocumentGraphModelSource = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphDeleteLineRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcdigrs.nodeId, language: documentLanguage) as DatabaseOrmResult<UDCDocumentGraphModel>
                        if databaseOrmResultudcDocumentGraphModelSource.databaseOrmError.count > 0 {
                            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModelSource.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModelSource.databaseOrmError[0].description))
                            return
                        }
                        let udcDocumentGraphModelSource = databaseOrmResultudcDocumentGraphModelSource.object[0]
                        var removeIndex = [Int]()
                        for (udcdigrtIndex, udcdigrt) in udcDocumentGraphModelSource.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[udcdigrs.referenceSentenceIndex].udcSentencePatternDataGroupValue[udcdigrs.referenceItemIndex].udcDocumentItemGraphReferenceTarget.enumerated() {
                            if udcdigrs.referenceItemIndex == udcspdgvIndex && udcdigrs.referenceSentenceIndex == udcspdgIndex && udcDocumentGraphModel._id == udcdigrt.nodeId {
                                removeIndex.append(udcdigrtIndex)
                            }
                        }
                        for rmIndex in removeIndex {
                            udcDocumentGraphModelSource.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[udcdigrs.referenceSentenceIndex].udcSentencePatternDataGroupValue[udcdigrs.referenceItemIndex].udcDocumentItemGraphReferenceTarget.remove(at: rmIndex)
                        }
                        let databaseOrmResultudcDocumentGraphModelSave = UDCDocumentGraphModel.update(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphDeleteLineRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentGraphModelSource) as DatabaseOrmResult<UDCDocumentGraphModel>
                        if databaseOrmResultudcDocumentGraphModelSave.databaseOrmError.count > 0 {
                            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModelSave.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModelSave.databaseOrmError[0].description))
                            return
                        }
                    }
                }
            }
        }
        
        var documentGraphDeleteLineResponse = DocumentGraphDeleteLineResponse()
        
        // Remove if any child of the line
        if udcDocumentGraphModel.childrenId.count > 0 {
            deleteRecursive(childrenId: udcDocumentGraphModel.childrenId, nodeIndex: &documentGraphDeleteLineRequest.nodeIndex, documentGraphDeleteLineRequest: documentGraphDeleteLineRequest, documentGraphDeleteLineResponse: &documentGraphDeleteLineResponse, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        }
        
        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
            return
        }
        
        // Remove the node related to the line
        let databaseOrmUDCDocumentGraphModelRemove = UDCDocumentGraphModel.remove(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphDeleteLineRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: documentGraphDeleteLineRequest.nodeId, language: documentLanguage) as DatabaseOrmResult<UDCDocumentGraphModel>
        if databaseOrmUDCDocumentGraphModelRemove.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentGraphModelRemove.databaseOrmError[0].name, description: databaseOrmUDCDocumentGraphModelRemove.databaseOrmError[0].description))
            return
        }
        
        // Remove the node from parent
        let databaseOrmResultudcDocumentGraphModelUpdate = UDCDocumentGraphModel.updatePull(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphDeleteLineRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: documentGraphDeleteLineRequest.parentId!, childrenId: documentGraphDeleteLineRequest.nodeId) as DatabaseOrmResult<UDCDocumentGraphModel>
        if databaseOrmResultudcDocumentGraphModelUpdate.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModelUpdate.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModelUpdate.databaseOrmError[0].description))
            return
        }
        
        
        let databaseOrmUDCDocumentGraphModelRoot = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphDeleteLineRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocument.udcDocumentGraphModelId, language: documentLanguage) as DatabaseOrmResult<UDCDocumentGraphModel>
        if databaseOrmUDCDocumentGraphModelRoot.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentGraphModelRoot.databaseOrmError[0].name, description: databaseOrmUDCDocumentGraphModelRoot.databaseOrmError[0].description))
            return
        }
        
        if documentGraphDeleteLineRequest.udcDocumentTypeIdName == "UDCDocumentType.DocumentItem" && udcDocumentGraphModel.level > 1 && documentGraphDeleteLineRequest.documentLanguage == "en" {
            
            // Get all the documents that are not in english language
            let databaseOrmResultUDCDocumentOther = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, idName: udcDocument.idName, udcProfile: documentGraphDeleteLineRequest.udcProfile, udcDocumentTypeIdName: documentGraphDeleteLineRequest.udcDocumentTypeIdName, notEqualsLanguage: "en")
            if databaseOrmResultUDCDocumentOther.databaseOrmError.count == 0 {
                let udcDocumentOther = databaseOrmResultUDCDocumentOther.object
                
                // Handle insert in those other language documents
                for udcd in udcDocumentOther {
                    // Get the document model root node
                    let databaseOrmResultudcDocumentGraphModelOther = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphDeleteLineRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcd.udcDocumentGraphModelId, language: udcd.language)
                    if databaseOrmResultudcDocumentGraphModelOther.databaseOrmError.count > 0 {
                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModelOther.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModelOther.databaseOrmError[0].description))
                        return
                    }
                    let udcDocumentGraphModelOther = databaseOrmResultudcDocumentGraphModelOther.object[0]
                    var parentFound: Bool = false
                    var foundParentModel = UDCDocumentGraphModel()
                    var foundParentId: String = ""
                    
                    // Get the english language parent node of the node to process
                    let databaseOrmResultudcDocumentGraphModelLangSpeficEnglishTitleNode = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphDeleteLineRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentGraphModel.parentId[0], language: udcDocumentGraphModel.language)
                    if databaseOrmResultudcDocumentGraphModelLangSpeficEnglishTitleNode.databaseOrmError.count > 0 {
                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModelLangSpeficEnglishTitleNode.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModelLangSpeficEnglishTitleNode.databaseOrmError[0].description))
                        return
                    }
                    let udcDocumentGraphModelLangSpeficParentNode = databaseOrmResultudcDocumentGraphModelLangSpeficEnglishTitleNode.object[0]
                    
                    // Use the parent id name and pervious node id name to search.
                    // If parent matches then change the respective children if found
                    let _ = try findAndProcessDocumentItem(mode: "deleteLine", udcSentencePatternDataGroupValue: udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue, parentIdName: udcDocumentGraphModelLangSpeficParentNode.idName, findIdName: udcDocumentGraphModel.idName, inChildrens: udcDocumentGraphModelOther.childrenId, parentFound: &parentFound, foundParentModel: &foundParentModel, foundParentId: &foundParentId, nodeIndex: documentGraphDeleteLineRequest.nodeIndex, itemIndex: 0, level: documentGraphDeleteLineRequest.level, udcDocumentTypeIdName: documentGraphDeleteLineRequest.udcDocumentTypeIdName, udcProfile: documentGraphDeleteLineRequest.udcProfile, isParent: udcDocumentGraphModel.isChildrenAllowed, generatedIdName: udcDocumentGraphModel.idName,  neuronRequest: neuronRequest, neuronResponse: &neuronResponse, documentLanguage: udcd.language, addUdcSentencePatternDataGroupValue: [], addUdcViewItemCollection: UDCViewItemCollection(), addUdcSentencePatternDataGroupValueIndex: [])
                    if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
                        return
                    }
                }
            }
        }
        
        let udcDocumentGraphModelRoot = databaseOrmUDCDocumentGraphModelRoot.object[0]
        var uvcViewModelLineNumberArray = [UVCViewModel]()
        var isChildrenAllowed = [Bool]()
        var nodeIndex = 0
        getLineNumberViewFromNode(childrenId: udcDocumentGraphModelRoot.childrenId, uvcViewModel: &uvcViewModelLineNumberArray, fromIndex: documentGraphDeleteLineRequest.nodeIndex - 1, nodeIndex: &nodeIndex, udcDocumentTypeIdName: documentGraphDeleteLineRequest.udcDocumentTypeIdName, isChildrenAllowed: &isChildrenAllowed, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, documentLanguage: documentLanguage, editMode: true, operation: "deleteLine")
        if uvcViewModelLineNumberArray.count > 0 {
            uvcViewModelLineNumberArray.remove(at: uvcViewModelLineNumberArray.count - 1)
            for (uvcvmlnaIndex, uvcvmlna) in uvcViewModelLineNumberArray.enumerated() {
                let documentItemViewChangeData = DocumentGraphItemViewData()
                documentItemViewChangeData.itemIndex = 0
                documentItemViewChangeData.uvcDocumentGraphModel.isChildrenAllowed = isChildrenAllowed[uvcvmlnaIndex]
                documentItemViewChangeData.nodeIndex = documentGraphDeleteLineRequest.nodeIndex + uvcvmlnaIndex
                documentItemViewChangeData.sentenceIndex = 0
                documentItemViewChangeData.documentInterfaceItemIdName = "UDCDocumentItemMapNode.Line"
                documentItemViewChangeData.uvcDocumentGraphModel.uvcViewModel.append(uvcvmlna)
                documentGraphDeleteLineResponse.documentItemViewChangeData.append(documentItemViewChangeData)
                print("line \(uvcvmlna.uvcViewItemCollection.uvcText[0].value): \(documentItemViewChangeData.nodeIndex)")
            }
        }
        
        let documentItemViewDeleteData = DocumentGraphItemViewData()
        documentItemViewDeleteData.nodeIndex = documentGraphDeleteLineRequest.nodeIndex
        if udcDocumentGraphModelNearBy != nil {
            documentItemViewDeleteData.sentenceIndex = udcDocumentGraphModelNearBy!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup.count == 0 ? 0 :  udcDocumentGraphModelNearBy!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup.count - 1
        } else {
            documentItemViewDeleteData.sentenceIndex = 0
        }
        documentItemViewDeleteData.documentInterfaceItemIdName = "UDCDocumentItemMapNode.Line"
        documentGraphDeleteLineResponse.documentItemViewDeleteData.append(documentItemViewDeleteData)
        
        
        let jsonUtilityDocumentGraphDeleteLineResponse = JsonUtility<DocumentGraphDeleteLineResponse>()
        let jsonDocumentGraphDeleteLineResponse = jsonUtilityDocumentGraphDeleteLineResponse.convertAnyObjectToJson(jsonObject: documentGraphDeleteLineResponse)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonDocumentGraphDeleteLineResponse)
    }
    
    private func deleteRecursive(childrenId: [String], nodeIndex: inout Int, documentGraphDeleteLineRequest: DocumentGraphDeleteLineRequest, documentGraphDeleteLineResponse: inout DocumentGraphDeleteLineResponse, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) {
        let documentLanguage = documentGraphDeleteLineRequest.documentLanguage
        for id in childrenId {
            
            let databaseOrmUDCDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphDeleteLineRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: id, language: documentLanguage) as DatabaseOrmResult<UDCDocumentGraphModel>
            if databaseOrmUDCDocumentGraphModel.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentGraphModel.databaseOrmError[0].name, description: databaseOrmUDCDocumentGraphModel.databaseOrmError[0].description))
                return
            }
            let udcDocumentGraphModel = databaseOrmUDCDocumentGraphModel.object[0]
            if udcDocumentGraphModel.childrenId.count > 0 {
                deleteRecursive(childrenId: udcDocumentGraphModel.childrenId, nodeIndex: &nodeIndex, documentGraphDeleteLineRequest: documentGraphDeleteLineRequest, documentGraphDeleteLineResponse: &documentGraphDeleteLineResponse, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            }
            
            let documentItemViewDeleteData = DocumentGraphItemViewData()
            documentItemViewDeleteData.nodeIndex = nodeIndex
            documentItemViewDeleteData.sentenceIndex = 0
            documentItemViewDeleteData.documentInterfaceItemIdName = "UDCDocumentItemMapNode.Line"
            documentGraphDeleteLineResponse.documentItemViewDeleteData.append(documentItemViewDeleteData)
            
            let databaseOrmUDCDocumentGraphModelRemove = UDCDocumentGraphModel.remove(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphDeleteLineRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: id, language: documentLanguage) as DatabaseOrmResult<UDCDocumentGraphModel>
            if databaseOrmUDCDocumentGraphModelRemove.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentGraphModelRemove.databaseOrmError[0].name, description: databaseOrmUDCDocumentGraphModelRemove.databaseOrmError[0].description))
                return
            }
        }
    }
    
    private func documentInsertNewLine(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let documentGraphInsertNewLineRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: DocumentGraphInsertNewLineRequest())
        
        let documentLanguage = documentGraphInsertNewLineRequest.documentLanguage
        
        documentGraphInsertNewLineRequest.itemIndex += 1
        
        let documentGraphInsertNewLineResponse = DocumentGraphInsertNewLineResponse()
        
        let databaseOrmUDCDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphInsertNewLineRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: documentGraphInsertNewLineRequest.nodeId, language: documentLanguage) as DatabaseOrmResult<UDCDocumentGraphModel>
        if databaseOrmUDCDocumentGraphModel.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentGraphModel.databaseOrmError[0].name, description: databaseOrmUDCDocumentGraphModel.databaseOrmError[0].description))
            return
        }
        let udcDocumentGraphModel = databaseOrmUDCDocumentGraphModel.object[0]
        
        // Get a copy of items after item index
        var udcSentencePatternDataGroupValueArray = [UDCSentencePatternDataGroupValue]()
        var removeIndexArray = [Int]()
        for (udcspdgvIndex, udcspdgv) in udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphInsertNewLineRequest.sentenceIndex].udcSentencePatternDataGroupValue.enumerated() {
            if udcspdgvIndex >= documentGraphInsertNewLineRequest.itemIndex {
                udcSentencePatternDataGroupValueArray.append(udcspdgv)
                removeIndexArray.append(udcspdgvIndex)
            }
        }
        
        // Remove the items after item index
        for index in removeIndexArray {
            udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphInsertNewLineRequest.sentenceIndex].udcSentencePatternDataGroupValue.remove(at: index)
        }
        
        // Get the parent model
        var parentId = ""
        //        if (udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphInsertNewLineRequest.sentenceIndex].udcSentencePatternDataGroupValue.count > 0) && udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphInsertNewLineRequest.sentenceIndex].udcSentencePatternDataGroupValue[0].endCategory.hasSuffix(".FoodRecipeCategory") {
        if udcDocumentGraphModel.isChildrenAllowed {
            parentId = documentGraphInsertNewLineRequest.nodeId
        } else {
            parentId = documentGraphInsertNewLineRequest.parentId
        }
        let databaseOrmUDCDocumentGraphModelParent = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphInsertNewLineRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: parentId, language: documentLanguage) as DatabaseOrmResult<UDCDocumentGraphModel>
        if databaseOrmUDCDocumentGraphModelParent.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentGraphModelParent.databaseOrmError[0].name, description: databaseOrmUDCDocumentGraphModelParent.databaseOrmError[0].description))
            return
        }
        let udcDocumentGraphModelParent = databaseOrmUDCDocumentGraphModelParent.object[0]
        
        // Generate the new line model
        let udcDocumentGraphModelNew = UDCDocumentGraphModel()
        if udcDocumentGraphModel.isChildrenAllowed {
            udcDocumentGraphModelNew.parentId.append(documentGraphInsertNewLineRequest.nodeId)
        } else {
            udcDocumentGraphModelNew.parentId.append(documentGraphInsertNewLineRequest.parentId)
        }
        udcDocumentGraphModelNew._id = (try udbcDatabaseOrm?.generateId())!
        udcDocumentGraphModelNew.level = documentGraphInsertNewLineRequest.level
        udcDocumentGraphModelNew.language = documentLanguage
        let databaseOrmUDCDocumentItemMapNode = UDCDocumentItemMapNode.get("UDCDocumentItemMapNode.SearchDocumentItems", udbcDatabaseOrm!, documentLanguage)
        if databaseOrmUDCDocumentItemMapNode.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentItemMapNode.databaseOrmError[0].name, description: databaseOrmUDCDocumentItemMapNode.databaseOrmError[0].description))
            return
        }
        let searchDocumentItem = databaseOrmUDCDocumentItemMapNode.object
        udcDocumentGraphModelNew.udcProfile.append(contentsOf: documentGraphInsertNewLineRequest.udcProfile)
        udcDocumentGraphModelNew.udcSentencePattern.udcSentencePatternData.append(UDCSentencePatternData())
        udcDocumentGraphModelNew.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup.append(UDCSentencePatternDataGroup())
        if udcSentencePatternDataGroupValueArray.count > 0 {
            udcDocumentGraphModelNew.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.append(contentsOf: udcSentencePatternDataGroupValueArray)
        }
        
        var profileId = ""
        for udcp in documentGraphInsertNewLineRequest.udcProfile {
            if udcp.udcProfileItemIdName == "UDCProfileItem.Human" {
                profileId = udcp.profileId
            }
        }
        
        if udcSentencePatternDataGroupValueArray.count > 0 {
            // Save the current line model
            udcDocumentGraphModel.udcDocumentTime.changedBy = profileId
            udcDocumentGraphModel.udcDocumentTime.changedTime = Date()
            let databaseOrmResultudcDocumentGraphModelSaveLine = UDCDocumentGraphModel.save(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphInsertNewLineRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentGraphModel) as DatabaseOrmResult<UDCDocumentGraphModel>
            if databaseOrmResultudcDocumentGraphModelSaveLine.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModelSaveLine.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModelSaveLine.databaseOrmError[0].description))
                return
            }
        }
        
        // Save the new model
        udcDocumentGraphModelNew.udcDocumentTime.createdBy = profileId
        udcDocumentGraphModelNew.udcDocumentTime.creationTime = Date()
        let databaseOrmResultudcDocumentGraphModelSave = UDCDocumentGraphModel.save(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphInsertNewLineRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentGraphModelNew) as DatabaseOrmResult<UDCDocumentGraphModel>
        if databaseOrmResultudcDocumentGraphModelSave.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModelSave.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModelSave.databaseOrmError[0].description))
            return
        }
        
        // Get the parent model and insert the new child at the particular index
        var childrenPositionToInsert = 0
        for (childrenIndex, children) in udcDocumentGraphModelParent.childrenId.enumerated() {
            if children == udcDocumentGraphModel._id {
                childrenPositionToInsert = childrenIndex + 1
                break
            }
        }
        let databaseOrmResultudcDocumentGraphModelUpdatePush = UDCDocumentGraphModel.updatePush(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphInsertNewLineRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentGraphModelParent._id, childrenId: udcDocumentGraphModelNew._id, position: childrenPositionToInsert) as DatabaseOrmResult<UDCDocumentGraphModel>
        if databaseOrmResultudcDocumentGraphModelUpdatePush.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModelUpdatePush.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModelUpdatePush.databaseOrmError[0].description))
            return
        }
        
        // Generate delete if anything moves from current line to new line
        if udcSentencePatternDataGroupValueArray.count > 0 {
            let documentItemViewDeleteData = DocumentGraphItemViewData()
            documentItemViewDeleteData.itemIndex = documentGraphInsertNewLineRequest.itemIndex
            documentItemViewDeleteData.nodeIndex = documentGraphInsertNewLineRequest.nodeIndex
            documentItemViewDeleteData.sentenceIndex = documentGraphInsertNewLineRequest.sentenceIndex
            documentItemViewDeleteData.itemLength = udcSentencePatternDataGroupValueArray.count
            documentGraphInsertNewLineResponse.documentItemViewDeleteData.append(documentItemViewDeleteData)
        }
        
        // Generate new line view model
        let documentItemViewInsertData = DocumentGraphItemViewData()
        
        documentItemViewInsertData.nodeIndex = documentGraphInsertNewLineRequest.nodeIndex + 1
        documentItemViewInsertData.uvcDocumentGraphModel._id = udcDocumentGraphModelNew._id
        documentItemViewInsertData.uvcDocumentGraphModel.parentId.append(parentId)
        documentItemViewInsertData.sentenceIndex = 0
        documentItemViewInsertData.uvcDocumentGraphModel.level = documentGraphInsertNewLineRequest.level
        documentItemViewInsertData.itemIndex = 0
        documentItemViewInsertData.documentInterfaceItemIdName = "UDCDocumentItemMapNode.Line"
        documentItemViewInsertData.nodeIndex = documentGraphInsertNewLineRequest.nodeIndex + 1
        documentItemViewInsertData.uvcDocumentGraphModel.uvcViewModel.append(uvcViewGenerator.getLineNumberViewModel(lineNumber: documentGraphInsertNewLineRequest.nodeIndex + 2, parentId: udcDocumentGraphModel.parentId, childrenId: udcDocumentGraphModel.childrenId, editMode: true))
        documentGraphInsertNewLineResponse.documentItemViewInsertData.append(documentItemViewInsertData)
        
        // Generate change data for line numbers
        let databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: documentGraphInsertNewLineRequest.documentId, language: documentLanguage)
        if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocument.databaseOrmError[0].name, description: databaseOrmResultUDCDocument.databaseOrmError[0].description))
            return
        }
        let udcDocument = databaseOrmResultUDCDocument.object[0]
        
        let databaseOrmUDCDocumentGraphModelRoot = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphInsertNewLineRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocument.udcDocumentGraphModelId, language: documentLanguage) as DatabaseOrmResult<UDCDocumentGraphModel>
        if databaseOrmUDCDocumentGraphModelRoot.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentGraphModelRoot.databaseOrmError[0].name, description: databaseOrmUDCDocumentGraphModelRoot.databaseOrmError[0].description))
            return
        }
        let udcDocumentGraphModelRoot = databaseOrmUDCDocumentGraphModelRoot.object[0]
        var uvcViewModelLineNumberArray = [UVCViewModel]()
        var isChildrenAllowed = [Bool]()
        var nodeIndex = 0
        getLineNumberViewFromNode(childrenId: udcDocumentGraphModelRoot.childrenId, uvcViewModel: &uvcViewModelLineNumberArray, fromIndex: documentGraphInsertNewLineRequest.nodeIndex + 1, nodeIndex: &nodeIndex, udcDocumentTypeIdName: documentGraphInsertNewLineRequest.udcDocumentTypeIdName, isChildrenAllowed: &isChildrenAllowed, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, documentLanguage: documentLanguage, editMode: true, operation: "newLine")
        for (uvcvmlnaIndex, uvcvmlna) in uvcViewModelLineNumberArray.enumerated() {
            let documentItemViewChangeData = DocumentGraphItemViewData()
            documentItemViewChangeData.itemIndex = 0
            documentItemViewChangeData.uvcDocumentGraphModel.isChildrenAllowed = isChildrenAllowed[uvcvmlnaIndex]
            documentItemViewChangeData.nodeIndex = documentGraphInsertNewLineRequest.nodeIndex + 1 + uvcvmlnaIndex
            documentItemViewChangeData.sentenceIndex = 0
            documentItemViewChangeData.documentInterfaceItemIdName = "UDCDocumentItemMapNode.Line"
            documentItemViewChangeData.uvcDocumentGraphModel.uvcViewModel.append(uvcvmlna)
            documentGraphInsertNewLineResponse.documentItemViewChangeData.append(documentItemViewChangeData)
            
            print("line \(uvcvmlna.uvcViewItemCollection.uvcText[0].value): \(documentItemViewChangeData.nodeIndex)")
        }
        
        documentGraphInsertNewLineResponse.currentItemIndex = 1
        documentGraphInsertNewLineResponse.currentNodeIndex = documentGraphInsertNewLineRequest.nodeIndex + 1
        
        // Package the response
        let jsonUtilityDocumentGraphInsertNewLineResponse = JsonUtility<DocumentGraphInsertNewLineResponse>()
        let jsonDocumentGraphInsertNewLineResponse = jsonUtilityDocumentGraphInsertNewLineResponse.convertAnyObjectToJson(jsonObject: documentGraphInsertNewLineResponse)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonDocumentGraphInsertNewLineResponse)
    }
    
    private func documentItemReference(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let documentGraphItemReferenceRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: DocumentGraphItemReferenceRequest())
        if documentGraphItemReferenceRequest.itemIndex > 0 {
            documentGraphItemReferenceRequest.itemIndex -= 1
        }
        
        let documentLanguage = documentGraphItemReferenceRequest.documentLanguage
        
        var profileId = ""
        var companyProfileId = ""
        var applicationProfileId = ""
        for udcp in documentGraphItemReferenceRequest.udcProfile {
            if udcp.udcProfileItemIdName == "UDCProfileItem.Human" {
                profileId = udcp.profileId
            } else if udcp.udcProfileItemIdName == "UDCProfileItem.Company" {
                companyProfileId = udcp.profileId
            } else if udcp.udcProfileItemIdName == "UDCProfileItem.Application" {
                applicationProfileId = udcp.profileId
            }
        }
        
        let documentGraphItemReferenceResponse = DocumentGraphItemReferenceResponse()
        documentGraphItemReferenceResponse.pathIdName.append(contentsOf: documentGraphItemReferenceRequest.pathIdName)
        if documentGraphItemReferenceRequest.pathIdName.joined(separator: "->") == "UDCOptionMapNode.DocumentItemOptions->UDCOptionMapNode.Reference->UDCDocumentReferenceType.SameDocument" {
            
            var databaseOrmResultUDCDocumentItemMapNode = UDCDocumentItemMapNode.get("UDCDocumentItemMapNode.DocumentGrammarItems", udbcDatabaseOrm!, documentLanguage)
            if databaseOrmResultUDCDocumentItemMapNode.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentItemMapNode.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentItemMapNode.databaseOrmError[0].description))
                return
            }
            for udcdimn in databaseOrmResultUDCDocumentItemMapNode.object {
                for children in udcdimn.childrenId {
                    let databaseOrmResultUDCDocumentItemMapNodeLocal = UDCDocumentItemMapNode.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: children, language: documentLanguage)
                    if databaseOrmResultUDCDocumentItemMapNodeLocal.databaseOrmError.count > 0 {
                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentItemMapNodeLocal.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentItemMapNodeLocal.databaseOrmError[0].description))
                        return
                    }
                    let udcDocuemntItemMapNode = databaseOrmResultUDCDocumentItemMapNodeLocal.object[0]
                    let uvcOptionViewModelLocal = UVCOptionViewModel()
                    uvcOptionViewModelLocal._id = try (udbcDatabaseOrm?.generateId())!
                    uvcOptionViewModelLocal.objectIdName = udcDocuemntItemMapNode.idName
                    uvcOptionViewModelLocal.objectName = String(udcDocuemntItemMapNode.idName.split(separator: ".")[0])
                    uvcOptionViewModelLocal.parentId.append(documentGraphItemReferenceRequest.parentId)
                    uvcOptionViewModelLocal.pathIdName.append(documentGraphItemReferenceRequest.pathIdName)
                    uvcOptionViewModelLocal.pathIdName[0].append(udcDocuemntItemMapNode.idName)
                    uvcOptionViewModelLocal.isDismissedOnSelection = false
                    uvcOptionViewModelLocal.level = 2
                    uvcOptionViewModelLocal.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: udcDocuemntItemMapNode.name, description: "", category: "", subCategory: "", language: "en", isChildrenExist: false, isEditable: false, isCheckBox: false, photoId: nil, photoObjectName: nil)
                    uvcOptionViewModelLocal.uvcViewModel.rowLength = 1
                    documentGraphItemReferenceResponse.uvcOptionViewModel.append(uvcOptionViewModelLocal)
                }
            }
            databaseOrmResultUDCDocumentItemMapNode = UDCDocumentItemMapNode.get("UDCDocumentItemMapNode.DocumentInterfaceItems", udbcDatabaseOrm!, documentLanguage)
            if databaseOrmResultUDCDocumentItemMapNode.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentItemMapNode.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentItemMapNode.databaseOrmError[0].description))
                return
            }
            for udcdimn in databaseOrmResultUDCDocumentItemMapNode.object {
                for children in udcdimn.childrenId {
                    let databaseOrmResultUDCDocumentItemMapNodeLocal = UDCDocumentItemMapNode.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: children, language: documentLanguage)
                    if databaseOrmResultUDCDocumentItemMapNodeLocal.databaseOrmError.count > 0 {
                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentItemMapNodeLocal.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentItemMapNodeLocal.databaseOrmError[0].description))
                        return
                    }
                    let udcDocuemntItemMapNode = databaseOrmResultUDCDocumentItemMapNodeLocal.object[0]
                    let uvcOptionViewModelLocal = UVCOptionViewModel()
                    uvcOptionViewModelLocal._id = try (udbcDatabaseOrm?.generateId())!
                    uvcOptionViewModelLocal.objectIdName = udcDocuemntItemMapNode.idName
                    uvcOptionViewModelLocal.objectName = String(udcDocuemntItemMapNode.idName.split(separator: ".")[0])
                    uvcOptionViewModelLocal.parentId.append(documentGraphItemReferenceRequest.parentId)
                    uvcOptionViewModelLocal.pathIdName.append(documentGraphItemReferenceRequest.pathIdName)
                    uvcOptionViewModelLocal.pathIdName[0].append(udcDocuemntItemMapNode.idName)
                    uvcOptionViewModelLocal.isDismissedOnSelection = false
                    uvcOptionViewModelLocal.level = 0
                    uvcOptionViewModelLocal.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: udcDocuemntItemMapNode.name, description: "", category: "", subCategory: "", language: "en", isChildrenExist: false, isEditable: false, isCheckBox: false, photoId: nil, photoObjectName: nil)
                    uvcOptionViewModelLocal.uvcViewModel.rowLength = 1
                    documentGraphItemReferenceResponse.uvcOptionViewModel.append(uvcOptionViewModelLocal)
                }
            }
        } else if documentGraphItemReferenceRequest.pathIdName.joined(separator: "->") == "UDCOptionMapNode.DocumentItemOptions->UDCOptionMapNode.Reference->UDCDocumentReferenceType.SameDocument->UDCDocumentItemMapNode.Sentence" || documentGraphItemReferenceRequest.pathIdName.joined(separator: "->") == "UDCOptionMapNode.DocumentItemOptions->UDCOptionMapNode.Reference->UDCDocumentReferenceType.SameDocument->UDCDocumentItemMapNode.Word" {
            
            
            // Get technical document model id
            let databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: documentGraphItemReferenceRequest.documentId, language: documentLanguage)
            if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocument.databaseOrmError[0].name, description: databaseOrmResultUDCDocument.databaseOrmError[0].description))
                return
            }
            let udcDocument = databaseOrmResultUDCDocument.object[0]
            
            // Get technical document
            let databaseOrmUDCDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphItemReferenceRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocument.udcDocumentGraphModelId, language: documentLanguage) as DatabaseOrmResult<UDCDocumentGraphModel>
            if databaseOrmUDCDocumentGraphModel.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentGraphModel.databaseOrmError[0].name, description: databaseOrmUDCDocumentGraphModel.databaseOrmError[0].description))
                return
            }
            let udcDocumentGraphModel = databaseOrmUDCDocumentGraphModel.object[0]
            
            try getDocumentItemListOptionView(udcDocumentGraphModel: udcDocumentGraphModel, documentGraphItemReferenceRequest: documentGraphItemReferenceRequest, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            
            if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
                return
            }
            
            let getDocumentItemListOptionViewResponse = neuronUtility!.getNeuronRequest(json: neuronResponse.neuronOperation.neuronData.text, object: GetDocumentItemListOptionViewResponse())
            
            documentGraphItemReferenceResponse.uvcOptionViewModel.append(contentsOf: getDocumentItemListOptionViewResponse.uvcOptionViewModel)
        } else if documentGraphItemReferenceRequest.pathIdName.joined(separator: "->").hasPrefix( "UDCOptionMapNode.DocumentItemOptions->UDCOptionMapNode.Reference->UDCDocumentReferenceType.SameDocument->UDCDocumentItemMapNode.Sentence->") || documentGraphItemReferenceRequest.pathIdName.joined(separator: "->").hasPrefix( "UDCOptionMapNode.DocumentItemOptions->UDCOptionMapNode.Reference->UDCDocumentReferenceType.SameDocument->UDCDocumentItemMapNode.Word->") {
            let sentenceProcessing = documentGraphItemReferenceRequest.pathIdName.joined(separator: "->").hasPrefix( "UDCOptionMapNode.DocumentItemOptions->UDCOptionMapNode.Reference->UDCDocumentReferenceType.SameDocument->UDCDocumentItemMapNode.Sentence->")
            
            
            let databaseOrmResultudcDocumentGraphModelCheck = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphItemReferenceRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: documentGraphItemReferenceRequest.nodeId, language: documentLanguage)
            if databaseOrmResultudcDocumentGraphModelCheck.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModelCheck.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModelCheck.databaseOrmError[0].description))
                return
            }
            let udcDocumentGraphModelCheck = databaseOrmResultudcDocumentGraphModelCheck.object[0]
            for udcspdg in udcDocumentGraphModelCheck.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup {
                for udcspdgv in udcspdg.udcSentencePatternDataGroupValue {
                    if udcspdgv.endCategoryIdName.hasSuffix(".FoodRecipeCategory") || udcspdgv.endCategoryIdName == "UDCGrammarItem.Title" {
                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "CannotInsertHere", description: "Cannot insert here, since it is not allowed!"))
                        return
                    }
                }
            }
            if documentGraphItemReferenceRequest.objectControllerRequest.editMode == false {
                for udcChoice in udcDocumentGraphModelCheck.udcViewItemCollection.udcChoice {
                    for udcChoiceItem in udcChoice.udcChoiceItem {
                        if documentGraphItemReferenceRequest.itemIndex >= udcChoiceItem.udcSentenceReference.startItemIndex &&
                            documentGraphItemReferenceRequest.itemIndex <= udcChoiceItem.udcSentenceReference.endItemIndex &&
                            documentGraphItemReferenceRequest.sentenceIndex >= udcChoiceItem.udcSentenceReference.startSentenceIndex &&
                            documentGraphItemReferenceRequest.sentenceIndex <= udcChoiceItem.udcSentenceReference.endSentenceIndex {
                            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "CannotInsertWithinChoice", description: "Cannot insert within choice!"))
                            return
                        }
                    }
                }
            }
            
            // Get technical document model id
            let databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: documentGraphItemReferenceRequest.documentId, language: documentLanguage)
            if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocument.databaseOrmError[0].name, description: databaseOrmResultUDCDocument.databaseOrmError[0].description))
                return
            }
            let udcDocument = databaseOrmResultUDCDocument.object[0]
            
            // Get technical document of the reference
            var databaseOrmUDCDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphItemReferenceRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: documentGraphItemReferenceRequest.referenceNodeId, language: documentLanguage) as DatabaseOrmResult<UDCDocumentGraphModel>
            if databaseOrmUDCDocumentGraphModel.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentGraphModel.databaseOrmError[0].name, description: databaseOrmUDCDocumentGraphModel.databaseOrmError[0].description))
                return
            }
            var udcDocumentGraphModelReference = databaseOrmUDCDocumentGraphModel.object[0]
            if documentGraphItemReferenceRequest.objectControllerRequest.editMode == false {
                for udcspdgv in  udcDocumentGraphModelReference.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphItemReferenceRequest.referenceSentenceIndex].udcSentencePatternDataGroupValue {
                    if udcspdgv.groupUVCViewItemType == "UVCViewItemType.Choice" {
                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "CannotReferAChoice", description: "Cannot refer a choice"))
                        return
                    }
                }
            }
            
            let databaseOrmUDCDocumentGraphModel1 = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphItemReferenceRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: documentGraphItemReferenceRequest.parentId, language: documentLanguage) as DatabaseOrmResult<UDCDocumentGraphModel>
            if databaseOrmUDCDocumentGraphModel1.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentGraphModel1.databaseOrmError[0].name, description: databaseOrmUDCDocumentGraphModel1.databaseOrmError[0].description))
                return
            }
            let udcDocumentGraphModelParent = databaseOrmUDCDocumentGraphModel1.object[0]
            
            let isNewChild = udcDocumentGraphModelParent.childrenId.count == 0 || documentGraphItemReferenceRequest.nodeId.isEmpty
            var udcDocumentGraphModel: UDCDocumentGraphModel?
            
            
            // Parent doesn't have child, so add new child
            if isNewChild {
                
                udcDocumentGraphModel = UDCDocumentGraphModel()
                udcDocumentGraphModel!._id = try (udbcDatabaseOrm?.generateId())!
                udcDocumentGraphModelParent.childrenId.append(udcDocumentGraphModel!._id)
                // Save parent
                let databaseOrmResultudcDocumentGraphModelUpdate = UDCDocumentGraphModel.updatePush(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphItemReferenceRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentGraphModelParent._id, childrenId: udcDocumentGraphModel!._id) as DatabaseOrmResult<UDCDocumentGraphModel>
                if databaseOrmResultudcDocumentGraphModelUpdate.databaseOrmError.count > 0 {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModelUpdate.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModelUpdate.databaseOrmError[0].description))
                    return
                }
                udcDocumentGraphModel!.parentId.append(udcDocumentGraphModelParent._id)
                udcDocumentGraphModel!.name = udcDocumentGraphModelReference.udcSentencePattern.name
                udcDocumentGraphModel!.level = documentGraphItemReferenceRequest.level
                udcDocumentGraphModel!.language = documentLanguage
                
                udcDocumentGraphModel!.udcProfile = documentGraphItemReferenceRequest.udcProfile
                
                let udcGrammarUtility = UDCGrammarUtility()
                var udcSetencePatterLocal = UDCSentencePattern()
                if sentenceProcessing {
                    udcGrammarUtility.getSetencePattern(udcSentencePattern: &udcSetencePatterLocal, udcSentencePatternDataGroupValue: udcDocumentGraphModelReference.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphItemReferenceRequest.referenceSentenceIndex].udcSentencePatternDataGroupValue)
                } else {
                    let udcSentencePatternDataGroupValue = udcDocumentGraphModelReference.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphItemReferenceRequest.referenceSentenceIndex].udcSentencePatternDataGroupValue[documentGraphItemReferenceRequest.referenceItemIndex]
                    udcGrammarUtility.getSetencePattern(udcSentencePattern: &udcSetencePatterLocal, udcSentencePatternDataGroupValue: [udcSentencePatternDataGroupValue])
                }
                udcDocumentGraphModel!.udcSentencePattern = udcSetencePatterLocal
                
            }
            else { // Parent has child, so just update the child
                
                databaseOrmUDCDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphItemReferenceRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: documentGraphItemReferenceRequest.nodeId, language: documentLanguage) as DatabaseOrmResult<UDCDocumentGraphModel>
                if databaseOrmUDCDocumentGraphModel.databaseOrmError.count > 0 {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentGraphModel.databaseOrmError[0].name, description: databaseOrmUDCDocumentGraphModel.databaseOrmError[0].description))
                    return
                }
                udcDocumentGraphModel = databaseOrmUDCDocumentGraphModel.object[0]
                
                let udcSentencePatternDataGroupValueRefrence =  udcDocumentGraphModelReference.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphItemReferenceRequest.referenceSentenceIndex].udcSentencePatternDataGroupValue
                for udcspdgvr in udcSentencePatternDataGroupValueRefrence {
                    udcspdgvr.udcDocumentItemGraphReferenceSource.removeAll()
                }
                // If first word of next sentence, set the index to the last group value index. View index is different
                let index = udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup.count - 1
                var itemIndex = documentGraphItemReferenceRequest.itemIndex
                
                // If have two or more sentence
                if udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup.count > 1 {
                    // If have two or more values
                    if udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphItemReferenceRequest.sentenceIndex].udcSentencePatternDataGroupValue.count > 1 {
                        itemIndex =  udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphItemReferenceRequest.sentenceIndex].udcSentencePatternDataGroupValue.count - 1
                    } else { // If have one blank valu, since new sentence first item
                        itemIndex = 0
                    }
                }
                if documentGraphItemReferenceRequest.itemIndex > (udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphItemReferenceRequest.sentenceIndex].udcSentencePatternDataGroupValue.count) - 1 {
                    if sentenceProcessing { udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphItemReferenceRequest.sentenceIndex].udcSentencePatternDataGroupValue.append(contentsOf: udcSentencePatternDataGroupValueRefrence)
                    } else {
                        udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphItemReferenceRequest.sentenceIndex].udcSentencePatternDataGroupValue.append(udcSentencePatternDataGroupValueRefrence[documentGraphItemReferenceRequest.referenceItemIndex])
                    }
                    
                } else {
                    if sentenceProcessing {
                        udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphItemReferenceRequest.sentenceIndex].udcSentencePatternDataGroupValue.insert(contentsOf: udcSentencePatternDataGroupValueRefrence, at: itemIndex)
                    } else {
                        udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphItemReferenceRequest.sentenceIndex].udcSentencePatternDataGroupValue.insert(udcSentencePatternDataGroupValueRefrence[documentGraphItemReferenceRequest.referenceItemIndex], at: itemIndex)
                    }
                }
            }
            
            // Change references in source if any
            for (udcspdgvIndex, udcspdgv) in udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphItemReferenceRequest.sentenceIndex].udcSentencePatternDataGroupValue.enumerated() {
                // Check for positional changes
                if udcspdgv.udcDocumentItemGraphReferenceSource.count > 0 {
                    if documentGraphItemReferenceRequest.itemIndex < udcspdgvIndex {
                        for udcdigrs in udcspdgv.udcDocumentItemGraphReferenceSource {
                            let databaseOrmResultudcDocumentGraphModel1 = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphItemReferenceRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcdigrs.nodeId, language: documentLanguage)
                            if databaseOrmResultudcDocumentGraphModel1.databaseOrmError.count > 0 {
                                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModel1.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModel1.databaseOrmError[0].description))
                                return
                            }
                            let udcDocumentGraphModelSource = databaseOrmResultudcDocumentGraphModel1.object[0]
                            
                            // Update the reference of the source to plus 1, since position changed
                            for udcdigrt in udcDocumentGraphModelSource.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[udcdigrs.referenceSentenceIndex].udcSentencePatternDataGroupValue[udcdigrs.referenceItemIndex].udcDocumentItemGraphReferenceTarget {
                                if udcdigrt.nodeId == udcDocumentGraphModel!._id && udcdigrt.referenceItemIndex == udcspdgvIndex - 1 {
                                    udcdigrt.referenceItemIndex += 1
                                }
                            }
                            
                            // Update back
                            udcDocumentGraphModelSource.udcDocumentTime.changedBy = profileId
                            udcDocumentGraphModelSource.udcDocumentTime.changedTime = Date()
                            let databaseOrmResultudcDocumentGraphModelUpdate = UDCDocumentGraphModel.update(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphItemReferenceRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentGraphModelSource)
                            if databaseOrmResultudcDocumentGraphModelUpdate.databaseOrmError.count > 0 {
                                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModelUpdate.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModelUpdate.databaseOrmError[0].description))
                                return
                            }
                        }
                    }
                }
            }
            
            // Add target reference to source
            // Get technical document of the reference
            databaseOrmUDCDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphItemReferenceRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: documentGraphItemReferenceRequest.referenceNodeId, language: documentLanguage) as DatabaseOrmResult<UDCDocumentGraphModel>
            if databaseOrmUDCDocumentGraphModel.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentGraphModel.databaseOrmError[0].name, description: databaseOrmUDCDocumentGraphModel.databaseOrmError[0].description))
                return
            }
            udcDocumentGraphModelReference = databaseOrmUDCDocumentGraphModel.object[0]
            if sentenceProcessing {
                for (udcspdgvIndex, udcspdgv) in udcDocumentGraphModelReference.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphItemReferenceRequest.referenceSentenceIndex].udcSentencePatternDataGroupValue.enumerated() {
                    let udcDocumentItemGraphReference = UDCDocumentItemGraphReference()
                    udcDocumentItemGraphReference._id = (try udbcDatabaseOrm?.generateId())!
                    udcDocumentItemGraphReference.documentId = udcDocument._id
                    udcDocumentItemGraphReference.nodeId = udcDocumentGraphModel!._id
                    udcDocumentItemGraphReference.referenceItemIndex = documentGraphItemReferenceRequest.itemIndex + udcspdgvIndex
                    udcDocumentItemGraphReference.referenceSentenceIndex = documentGraphItemReferenceRequest.sentenceIndex
                    udcDocumentItemGraphReference.udcDocumentReferenceTypeIdName = documentGraphItemReferenceRequest.pathIdName[documentGraphItemReferenceRequest.pathIdName.count - 3]
                    print("Adding reference target to : \(udcDocumentGraphModelReference._id)")
                    udcspdgv.udcDocumentItemGraphReferenceSource.removeAll()
                    udcspdgv.udcDocumentItemGraphReferenceTarget.append(udcDocumentItemGraphReference)
                }
            } else {
                let udcDocumentItemGraphReference = UDCDocumentItemGraphReference()
                udcDocumentItemGraphReference._id = (try udbcDatabaseOrm?.generateId())!
                udcDocumentItemGraphReference.documentId = udcDocument._id
                udcDocumentItemGraphReference.nodeId = udcDocumentGraphModel!._id
                udcDocumentItemGraphReference.referenceItemIndex = documentGraphItemReferenceRequest.itemIndex
                udcDocumentItemGraphReference.referenceSentenceIndex = documentGraphItemReferenceRequest.sentenceIndex
                udcDocumentItemGraphReference.udcDocumentReferenceTypeIdName = documentGraphItemReferenceRequest.pathIdName[documentGraphItemReferenceRequest.pathIdName.count - 3]
                print("Adding reference target to : \(udcDocumentGraphModelReference._id)")
                udcDocumentGraphModelReference.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphItemReferenceRequest.referenceSentenceIndex].udcSentencePatternDataGroupValue[documentGraphItemReferenceRequest.referenceItemIndex].udcDocumentItemGraphReferenceSource.removeAll()
                udcDocumentGraphModelReference.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphItemReferenceRequest.referenceSentenceIndex].udcSentencePatternDataGroupValue[documentGraphItemReferenceRequest.referenceItemIndex].udcDocumentItemGraphReferenceTarget.append(udcDocumentItemGraphReference)
            }
            udcDocumentGraphModelReference.udcDocumentTime.changedBy = profileId
            udcDocumentGraphModelReference.udcDocumentTime.changedTime = Date()
            let databaseOrmResultudcDocumentGraphModelSave1 = UDCDocumentGraphModel.update(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphItemReferenceRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentGraphModelReference) as DatabaseOrmResult<UDCDocumentGraphModel>
            if databaseOrmResultudcDocumentGraphModelSave1.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModelSave1.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModelSave1.databaseOrmError[0].description))
                return
            }
            // If on same row, then add the target so that while resaving below it is theres
            if documentGraphItemReferenceRequest.nodeIndex == documentGraphItemReferenceRequest.referenceNodeIndex {
                var count = udcDocumentGraphModelReference.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphItemReferenceRequest.referenceSentenceIndex].udcSentencePatternDataGroupValue[documentGraphItemReferenceRequest.referenceItemIndex].udcDocumentItemGraphReferenceTarget.count - 1
                if count == -1 {
                    count = 0
                }
                udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphItemReferenceRequest.sentenceIndex].udcSentencePatternDataGroupValue[documentGraphItemReferenceRequest.referenceItemIndex].udcDocumentItemGraphReferenceTarget.append(udcDocumentGraphModelReference.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphItemReferenceRequest.referenceSentenceIndex].udcSentencePatternDataGroupValue[documentGraphItemReferenceRequest.referenceItemIndex].udcDocumentItemGraphReferenceTarget[count])
            }
            for udcspdgv in udcDocumentGraphModelReference.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphItemReferenceRequest.referenceSentenceIndex].udcSentencePatternDataGroupValue {
                udcspdgv.udcDocumentItemGraphReferenceTarget.removeAll()
                udcspdgv.udcDocumentItemGraphReferenceSource.removeAll()
            }
            
            // Add source reference to target
            
            print("Adding reference source to : \(udcDocumentGraphModel!._id)")
            var itemIndex = documentGraphItemReferenceRequest.itemIndex
            var referenceIndex = documentGraphItemReferenceRequest.referenceItemIndex
            if sentenceProcessing {
                for (udcspdgvIndex, udcspdgv) in udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphItemReferenceRequest.sentenceIndex].udcSentencePatternDataGroupValue.enumerated() {
                    if udcspdgvIndex >= documentGraphItemReferenceRequest.itemIndex {
                        let udcDocumentItemGraphReference = UDCDocumentItemGraphReference()
                        udcDocumentItemGraphReference._id = (try udbcDatabaseOrm?.generateId())!
                        udcDocumentItemGraphReference.documentId = udcDocument._id
                        udcDocumentItemGraphReference.nodeId = documentGraphItemReferenceRequest.referenceNodeId
                        udcDocumentItemGraphReference.referenceItemIndex = referenceIndex
                        udcDocumentItemGraphReference.referenceSentenceIndex = documentGraphItemReferenceRequest.referenceSentenceIndex
                        udcDocumentItemGraphReference.udcDocumentReferenceTypeIdName = documentGraphItemReferenceRequest.pathIdName[documentGraphItemReferenceRequest.pathIdName.count - 3]
                        udcspdgv.udcDocumentItemGraphReferenceTarget.removeAll()
                        udcspdgv.udcDocumentItemGraphReferenceSource.append(udcDocumentItemGraphReference)
                        itemIndex += 1
                        referenceIndex += 1
                    }
                }
            } else {
                let udcDocumentItemGraphReference = UDCDocumentItemGraphReference()
                udcDocumentItemGraphReference._id = (try udbcDatabaseOrm?.generateId())!
                udcDocumentItemGraphReference.documentId = udcDocument._id
                udcDocumentItemGraphReference.nodeId = documentGraphItemReferenceRequest.referenceNodeId
                udcDocumentItemGraphReference.referenceItemIndex = referenceIndex
                udcDocumentItemGraphReference.referenceSentenceIndex = documentGraphItemReferenceRequest.referenceSentenceIndex
                udcDocumentItemGraphReference.udcDocumentReferenceTypeIdName = documentGraphItemReferenceRequest.pathIdName[documentGraphItemReferenceRequest.pathIdName.count - 3]
                udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphItemReferenceRequest.sentenceIndex].udcSentencePatternDataGroupValue[documentGraphItemReferenceRequest.itemIndex].udcDocumentItemGraphReferenceTarget.removeAll()
                udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphItemReferenceRequest.sentenceIndex].udcSentencePatternDataGroupValue[documentGraphItemReferenceRequest.itemIndex].udcDocumentItemGraphReferenceSource.append(udcDocumentItemGraphReference)
            }
            
            
            // Process grammar (any modifications based on grammar)
            // 1) Capitalization of words
            // 2) Singular to plural
            // Etc.,
            udcDocumentGraphModel!.udcSentencePattern = try processGrammar(neuronRequest: neuronRequest, neuronResponse: &neuronResponse, udcSentencePattern: udcDocumentGraphModel!.udcSentencePattern, newSentence: false, wordIndex: documentGraphItemReferenceRequest.itemIndex, sentenceIndex: documentGraphItemReferenceRequest.sentenceIndex, documentLanguage: documentLanguage, textStartIndex: 0)
            udcDocumentGraphModel!.name = (udcDocumentGraphModel!.udcSentencePattern.sentence)
            
            // Save or Update technical model
            var profileId = ""
            for udcp in documentGraphItemReferenceRequest.udcProfile {
                if udcp.udcProfileItemIdName == "UDCProfileItem.Human" {
                    profileId = udcp.profileId
                }
            }
            udcDocumentGraphModel!.udcDocumentTime.changedBy = profileId
            udcDocumentGraphModel!.udcDocumentTime.changedTime = Date()
            var databaseOrmResultudcDocumentGraphModelSave: DatabaseOrmResult<UDCDocumentGraphModel>?
            if isNewChild {
                udcDocumentGraphModel?.udcDocumentTime.createdBy = profileId
                udcDocumentGraphModel?.udcDocumentTime.creationTime = Date()
                databaseOrmResultudcDocumentGraphModelSave = UDCDocumentGraphModel.save(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphItemReferenceRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentGraphModel!) as DatabaseOrmResult<UDCDocumentGraphModel>
            } else {
                udcDocumentGraphModel?.udcDocumentTime.changedBy = profileId
                udcDocumentGraphModel?.udcDocumentTime.changedTime = Date()
                databaseOrmResultudcDocumentGraphModelSave = UDCDocumentGraphModel.update(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphItemReferenceRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentGraphModel!) as DatabaseOrmResult<UDCDocumentGraphModel>
            }
            if databaseOrmResultudcDocumentGraphModelSave!.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModelSave!.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModelSave!.databaseOrmError[0].description))
                return
            }
            
            // Update document model
            
            // Get and Update document model
            udcDocument.udcDocumentTime.changedBy = profileId
            udcDocument.udcDocumentTime.changedTime = Date()
            let databaseOrmResultUDCDocumentUpdate = UDCDocument.update(udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocument)
            if databaseOrmResultUDCDocumentUpdate.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentUpdate.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentUpdate.databaseOrmError[0].description))
                return
            }
            
            //*****************************************************************
            // Item Model ready, generate item view as per document type by sending to specific neuron
            //*****************************************************************
            let documentGraphInsertItemRequest = DocumentGraphInsertItemRequest()
            documentGraphInsertItemRequest.itemIndex = documentGraphItemReferenceRequest.itemIndex
            documentGraphInsertItemRequest.nodeIndex = documentGraphItemReferenceRequest.nodeIndex
            documentGraphInsertItemRequest.sentenceIndex = documentGraphItemReferenceRequest.sentenceIndex
            documentGraphInsertItemRequest.udcDocumentTypeIdName = documentGraphItemReferenceRequest.udcDocumentTypeIdName
            documentGraphInsertItemRequest.udcProfile.append(contentsOf: documentGraphItemReferenceRequest.udcProfile)
            documentGraphInsertItemRequest.documentId = documentGraphItemReferenceRequest.documentId
            documentGraphInsertItemRequest.level = documentGraphItemReferenceRequest.level
            documentGraphInsertItemRequest.parentId = documentGraphItemReferenceRequest.parentId
            documentGraphInsertItemRequest.nodeId = documentGraphItemReferenceRequest.nodeId
            udcDocumentGraphModelReference._id = udcDocumentGraphModel!._id
            var generateDocumentItemViewForInsertResponse = GenerateDocumentItemViewForInsertResponse()
            if sentenceProcessing {
                try generateDocumentItemViewForInsert(parentDocumentModel: udcDocumentGraphModelParent, insertDocumentModel: udcDocumentGraphModelReference, documentModelId: udcDocument.udcDocumentGraphModelId, udcSentencePatternDataGroupValue: udcDocumentGraphModelReference.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphItemReferenceRequest.referenceSentenceIndex].udcSentencePatternDataGroupValue, documentGraphInsertItemRequest: documentGraphInsertItemRequest, isNewChild: false, isNewSentence: false, isEditable: false, isSentence: true, uvcViewItemCollection: UVCViewItemCollection(), generateDocumentItemViewForInsertResponse: &generateDocumentItemViewForInsertResponse, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            } else {
                let udcDocumentGraphModelForItem = UDCDocumentGraphModel()
                udcDocumentGraphModelForItem._id = udcDocumentGraphModelReference._id
                var udcSentencePatternForItem = UDCSentencePattern()
                let udcGrammarUtility = UDCGrammarUtility()
                udcGrammarUtility.getSetencePattern(udcSentencePattern: &udcSentencePatternForItem, udcSentencePatternDataGroupValue: [udcDocumentGraphModelReference.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphItemReferenceRequest.referenceSentenceIndex].udcSentencePatternDataGroupValue[documentGraphItemReferenceRequest.referenceItemIndex]])
                udcDocumentGraphModelForItem.udcSentencePattern = udcSentencePatternForItem
                try generateDocumentItemViewForInsert(parentDocumentModel: udcDocumentGraphModelParent, insertDocumentModel: udcDocumentGraphModelForItem, documentModelId: udcDocument.udcDocumentGraphModelId, udcSentencePatternDataGroupValue: udcDocumentGraphModelForItem.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue, documentGraphInsertItemRequest: documentGraphInsertItemRequest, isNewChild: false, isNewSentence: false, isEditable: false, isSentence: true, uvcViewItemCollection: nil, generateDocumentItemViewForInsertResponse: &generateDocumentItemViewForInsertResponse, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            }
            if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
                return
            }
            
            
            // Package response
            if generateDocumentItemViewForInsertResponse.documentItemViewInsertData.count > 0 {
                documentGraphItemReferenceResponse.documentItemViewInsertData.append(contentsOf: generateDocumentItemViewForInsertResponse.documentItemViewInsertData)
            }
            if generateDocumentItemViewForInsertResponse.documentItemViewChangeData.count > 0 {
                documentGraphItemReferenceResponse.documentItemViewChangeData.append(contentsOf: documentGraphItemReferenceResponse.documentItemViewChangeData)
            }
            if generateDocumentItemViewForInsertResponse.documentItemViewDeleteData.count > 0 {
                documentGraphItemReferenceResponse.documentItemViewDeleteData.append(contentsOf: generateDocumentItemViewForInsertResponse.documentItemViewDeleteData)
            }
        }
        
        let jsonUtilityDocumentGraphItemReferenceResponse = JsonUtility<DocumentGraphItemReferenceResponse>()
        let jsonDocumentGraphItemReferenceResponse = jsonUtilityDocumentGraphItemReferenceResponse.convertAnyObjectToJson(jsonObject: documentGraphItemReferenceResponse)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonDocumentGraphItemReferenceResponse)
    }
    
    private func getDocumentTypeName(type: String, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest, documentLanguage: String) throws -> UDCDocumentType? {
        // Check if the option map is found. If not found return
        let databaseOrmResultUDCDocumentType = UDCDocumentType.getOne(type, udbcDatabaseOrm!, documentLanguage)
        if databaseOrmResultUDCDocumentType.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentType.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentType.databaseOrmError[0].description))
            return nil
        }
        let udcDocumentItemType = databaseOrmResultUDCDocumentType.object[0]
        
        return udcDocumentItemType
    }
    
    
    
    
    private func search(text: String, udcDocumentItemMapNode: UDCDocumentItemMapNode, uvcOptionViewModel: inout [UVCOptionViewModel], neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest, documentGraphItemSearchRequest: DocumentGraphItemSearchRequest, searchPhase: Int) throws -> Bool {
        let documentLanguage = documentGraphItemSearchRequest.documentLanguage
        var searchResult = false
        
        
        if udcDocumentItemMapNode.udcDocumentTypeIdName == "UDCDocumentType.General" {
            if udcDocumentItemMapNode.idName == "UDCDocumentItemMapNode.SentencePattern" && !documentGraphItemSearchRequest.isBySubCategory {
                searchResult = true
                var databaseOrmResultType : DatabaseOrmResult<UDCSentencePattern>?
                if searchPhase == 1 {
                    databaseOrmResultType = UDCSentencePattern.get(text, udbcDatabaseOrm!, documentLanguage)
                } else if documentGraphItemSearchRequest.isByCategory {
                    databaseOrmResultType = UDCSentencePattern.get(limitedTo: 0, sortedBy: "name", udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
                } else {
                    databaseOrmResultType = try UDCSentencePattern.search(text: text, udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
                }
                if databaseOrmResultType!.databaseOrmError.count == 0 {
                    for udci in databaseOrmResultType!.object {
                        let uvcOptionViewModelLocal = UVCOptionViewModel()
                        uvcOptionViewModelLocal.objectIdName = udci.idName
                        uvcOptionViewModelLocal.parentId.append(documentGraphItemSearchRequest.optionItemId)
                        uvcOptionViewModelLocal.objectName = udcDocumentItemMapNode.objectName
                        let name = udci.name
                        uvcOptionViewModelLocal.pathIdName.append(["UDCDocumentItemMapNode.DocumentItems"])
                        uvcOptionViewModelLocal.pathIdName[0].append(udci.idName)
                        uvcOptionViewModelLocal.level = 1
                        uvcOptionViewModelLocal.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: name, description: "", category: udcDocumentItemMapNode.name.capitalized, subCategory: "", language: documentLanguage, isChildrenExist: false, isEditable: false, isCheckBox: false, photoId: nil, photoObjectName: nil)
                        uvcOptionViewModelLocal.uvcViewModel.rowLength = 2
                        uvcOptionViewModel.append(uvcOptionViewModelLocal)
                    }
                }
            } else if udcDocumentItemMapNode.idName == "UDCDocumentItemMapNode.MathematicalItem" && !documentGraphItemSearchRequest.isBySubCategory {
                searchResult = true
                var databaseOrmResultType : DatabaseOrmResult<UDCMathematicalItemType>?
                if searchPhase == 1 {
                    databaseOrmResultType = UDCMathematicalItemType.get(text, udbcDatabaseOrm!, documentLanguage)
                } else if documentGraphItemSearchRequest.isByCategory {
                    databaseOrmResultType = UDCMathematicalItemType.get(limitedTo: 0, sortedBy: "name", category: "", udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
                } else {
                    databaseOrmResultType = try UDCMathematicalItemType.search(text: text, udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
                }
                if databaseOrmResultType!.databaseOrmError.count == 0 {
                    for udci in databaseOrmResultType!.object {
                        let databaseOrmResultCategory = UDCMathematicalCategoryType.get(udci.udcMathematicalCategoryIdName, udbcDatabaseOrm!, documentLanguage)
                        if databaseOrmResultCategory.databaseOrmError.count > 0 {
                            for databaseError in databaseOrmResultCategory.databaseOrmError {
                                neuronResponse = neuronUtility!.getNeuronResponseError(neuronRequest: neuronRequest, errorName: databaseError.name, errorDescription:  databaseError.description)
                            }
                            return searchResult
                        }
                        let subCategory = databaseOrmResultCategory.object[0].name
                        let uvcOptionViewModelLocal = UVCOptionViewModel()
                        uvcOptionViewModelLocal.objectCategoryIdName = databaseOrmResultCategory.object[0].idName
                        uvcOptionViewModelLocal.objectIdName = udci.idName
                        uvcOptionViewModelLocal.parentId.append(documentGraphItemSearchRequest.optionItemId)
                        uvcOptionViewModelLocal.objectName = udcDocumentItemMapNode.objectName
                        let name = udci.name
                        uvcOptionViewModelLocal.pathIdName.append(["UDCDocumentItemMapNode.DocumentItems"])
                        uvcOptionViewModelLocal.pathIdName[0].append(udci.idName)
                        uvcOptionViewModelLocal.level = 1
                        uvcOptionViewModelLocal.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: name, description: "", category: udcDocumentItemMapNode.name.capitalized, subCategory: subCategory, language: documentLanguage, isChildrenExist: false, isEditable: false, isCheckBox: false, photoId: nil, photoObjectName: nil)
                        uvcOptionViewModelLocal.uvcViewModel.rowLength = 2
                        uvcOptionViewModel.append(uvcOptionViewModelLocal)
                    }
                }
            } else if udcDocumentItemMapNode.idName == "UDCDocumentItemMapNode.HumanProfile" && !documentGraphItemSearchRequest.isBySubCategory {
                searchResult = true
                var databaseOrmResultType : DatabaseOrmResult<UPCHumanProfile>?
                if searchPhase == 1 {
                    databaseOrmResultType = UPCHumanProfile.get(text, udbcDatabaseOrm!, documentLanguage)
                } else if documentGraphItemSearchRequest.isByCategory {
                    databaseOrmResultType = UPCHumanProfile.get(limitedTo: 0, sortedBy: "name", udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
                } else {
                    databaseOrmResultType = try UPCHumanProfile.search(text: text, udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
                }
                if databaseOrmResultType!.databaseOrmError.count == 0 {
                    for udci in databaseOrmResultType!.object {
                        
                        let subCategory = ""
                        let uvcOptionViewModelLocal = UVCOptionViewModel()
                        uvcOptionViewModelLocal.objectCategoryIdName = ""
                        uvcOptionViewModelLocal.objectIdName = udci.idName
                        uvcOptionViewModelLocal.parentId.append(documentGraphItemSearchRequest.optionItemId)
                        uvcOptionViewModelLocal.objectName = udcDocumentItemMapNode.objectName
                        let name = udci.name
                        uvcOptionViewModelLocal.pathIdName.append(["UDCDocumentItemMapNode.DocumentItems"])
                        uvcOptionViewModelLocal.pathIdName[0].append(udci.idName)
                        uvcOptionViewModelLocal.level = 1
                        uvcOptionViewModelLocal.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: name, description: "", category: udcDocumentItemMapNode.name.capitalized, subCategory: subCategory, language: documentLanguage, isChildrenExist: false, isEditable: false, isCheckBox: false, photoId: nil, photoObjectName: nil)
                        uvcOptionViewModelLocal.uvcViewModel.rowLength = 2
                        uvcOptionViewModel.append(uvcOptionViewModelLocal)
                    }
                }
            }
        } else {
            // Send to the specific neuron to collect the search results view
            let documentItemSearchResultRequest = DocumentItemSearchResultRequest()
            documentItemSearchResultRequest.udcDocumentItemMapNode = udcDocumentItemMapNode
            documentItemSearchResultRequest.documentGraphItemSearchRequest = documentGraphItemSearchRequest
            documentItemSearchResultRequest.searchPhase = searchPhase
            
            let neuronRequestLocal = neuronRequest
            let jsonUtilityDocumentItemSearchResultRequest = JsonUtility<DocumentItemSearchResultRequest>()
            let jsonDocumentDocumentItemSearchResultRequest = jsonUtilityDocumentItemSearchResultRequest.convertAnyObjectToJson(jsonObject: documentItemSearchResultRequest)
            neuronRequestLocal.neuronOperation.neuronData.text = jsonDocumentDocumentItemSearchResultRequest
            try callNeuron(neuronRequest: neuronRequestLocal, neuronResponse: &neuronResponse, operationName: "DocumentGraphNeuron.SearchResult.DocumentItem", udcDocumentTypeIdName: documentGraphItemSearchRequest.udcDocumentTypeIdName)
            
            if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
                return false
            }
            
            let documentItemSearchResultResponse = neuronUtility!.getNeuronRequest(json: neuronResponse.neuronOperation.neuronData.text, object: DocumentItemSearchResultResponse())
            uvcOptionViewModel.append(contentsOf: documentItemSearchResultResponse.uvcOptionViewModel)
            searchResult = documentItemSearchResultResponse.status
        }
        
        return searchResult
    }
    
    private func userWordAdd(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let userWordAddRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: UserWordAddRequest())
        let _ = try userWordAdd(userWordAddRequest: userWordAddRequest, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
    }
    
    private func userWordAdd(userWordAddRequest: UserWordAddRequest, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws -> String {
        let documentLanguage = userWordAddRequest.documentLanguage
        // Get profile id's
        var profileId = ""
        for udcp in userWordAddRequest.udcUserWordDictionary.udcProfile {
            if udcp.udcProfileItemIdName == "UDCProfileItem.Human" {
                profileId = udcp.profileId
            }
        }
        
        // Save analytic and get id
        let udcDocumentTime = try getUDCDocumentTimeCreated(profileId: profileId, language: documentLanguage)
        let udcAnalytic = try getAnalyticAndSaveDocumentTime(udcDocumentTime: udcDocumentTime, objectName: "UDCDocumentTime", profileId: profileId,  neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        
        // Save user word dictionary
        userWordAddRequest.udcUserWordDictionary.udcAnalytic.append(udcAnalytic)
        userWordAddRequest.udcUserWordDictionary._id = try udbcDatabaseOrm!.generateId()
        userWordAddRequest.udcUserWordDictionary.idName = "UDCUserWordDictionary.\(userWordAddRequest.udcUserWordDictionary.word.capitalized.replacingOccurrences(of: " ", with: ""))"
        let databaseOrmResultUDCUserWordDictionary = UDCUserWordDictionary.save(udbcDatabaseOrm: udbcDatabaseOrm!, object: userWordAddRequest.udcUserWordDictionary)
        if databaseOrmResultUDCUserWordDictionary.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCUserWordDictionary.databaseOrmError[0].name, description: databaseOrmResultUDCUserWordDictionary.databaseOrmError[0].description))
            return ""
        }
        
        let userWordAddResponse = UserWordAddResponse()
        let jsonUtilityUserWordAddResponse = JsonUtility<UserWordAddResponse>()
        let jsonUserWordAddResponse = jsonUtilityUserWordAddResponse.convertAnyObjectToJson(jsonObject: userWordAddResponse)
        
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonUserWordAddResponse)
        
        return userWordAddRequest.udcUserWordDictionary.idName
    }
    
    //    private func userSentencePatternAdd(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
    //        let userSentencePatternAddRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: UserSentencePatternAddRequest())
    //
    //        // Get the node that is having the sentence pattern
    //        let databaseOrmResultudcDocumentGraphModelChild = UDCDocumentModel.get(collectionName: "UDCRecipe", udbcDatabaseOrm: udbcDatabaseOrm!, id: userSentencePatternAddRequest.nodeId, language: neuronRequest.language)
    //        if databaseOrmResultudcDocumentGraphModelChild.databaseOrmError.count > 0 {
    //            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModelChild.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModelChild.databaseOrmError[0].description))
    //            return
    //        }
    //        let udcDocumentGraphModelChild = databaseOrmResultudcDocumentGraphModelChild.object[0]
    //
    //        let userSentencePatternAddResponse = UserSentencePatternAddResponse()
    //
    //        // If there are more than one sentence in a row, then return the sentence list
    //        if udcDocumentGraphModelChild.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup.count > 1 {
    //            // Form the title option
    //            let databaseOrmUDCDocumentItemMapNode = UDCDocumentItemMapNode.get("UDCDocumentItemMapNode.SentenceList", udbcDatabaseOrm!, neuronRequest.language)
    //            if databaseOrmUDCDocumentItemMapNode.databaseOrmError.count > 0 {
    //                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentItemMapNode.databaseOrmError[0].name, description: databaseOrmUDCDocumentItemMapNode.databaseOrmError[0].description))
    //                return
    //            }
    //            let udcDocumentItemMapNode = databaseOrmUDCDocumentItemMapNode.object[0]
    //            let uvcOptionViewModelLocal = UVCOptionViewModel()
    //            uvcOptionViewModelLocal._id = try (udbcDatabaseOrm?.generateId())!
    //            uvcOptionViewModelLocal.objectIdName = udcDocumentItemMapNode.idName
    //            uvcOptionViewModelLocal.objectName = String(udcDocumentItemMapNode.idName.split(separator: ".")[0])
    //            uvcOptionViewModelLocal.parentId.append(uvcOptionViewModelLocal.objectIdName)
    //            uvcOptionViewModelLocal.path.append(udcDocumentItemMapNode.name)
    //            uvcOptionViewModelLocal.pathIdName.append(udcDocumentItemMapNode.idName)
    //            uvcOptionViewModelLocal.level = 0
    //            let uvcViewGenerator = UVCViewGenerator()
    //            uvcOptionViewModelLocal.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: udcDocumentItemMapNode.name, description: "", category: "", subCategory: "", language: "en", isChildrenExist: false, isEditable: false)
    //            uvcOptionViewModelLocal.uvcViewModel.rowLength = 1
    //            var uvcOptionViewModelArray = [UVCOptionViewModel]()
    //
    //            // Form the list of sentnece pattern options
    //            for udcspdg in udcDocumentGraphModelChild.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup {
    //                for udcspdgv in udcspdg.udcSentencePatternDataGroupValue {
    //                    let uvcOptionViewModelChild = UVCOptionViewModel()
    //                    uvcOptionViewModelChild._id = try (udbcDatabaseOrm?.generateId())!
    //                    // User word
    //                    uvcOptionViewModelChild.objectIdName = udcspdgv.itemIdName
    //                    uvcOptionViewModelChild.objectName = String(udcspdgv.itemIdName.split(separator: ".")[0])
    //                    uvcOptionViewModelChild.parentId.append(uvcOptionViewModelLocal.objectIdName)
    //                    uvcOptionViewModelChild.path.append(contentsOf: uvcOptionViewModelLocal.path)
    //                    uvcOptionViewModelLocal.pathIdName.append(contentsOf: uvcOptionViewModelLocal.pathIdName)
    //                    uvcOptionViewModelChild.level = 1
    //                    uvcOptionViewModelChild.uvcViewModel = generateSentenceViewAsObject(udcDocumentGraphModel: udcDocumentGraphModelChild, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
    //                    var text = ""
    //                    for uvcText in uvcOptionViewModelChild.uvcViewModel.uvcViewItemCollection.uvcText {
    //                        text = text + uvcText.value + " "
    //                    }
    //                    let name = text.trimmingCharacters(in: .whitespaces)
    //                    uvcOptionViewModelChild.path.append(name)
    //                    uvcOptionViewModelLocal.pathIdName.append(name.replacingOccurrences(of: " ", with: "").capitalized)
    //                    uvcOptionViewModelChild.uvcViewModel.rowLength = 1
    //                    uvcOptionViewModelLocal.parentId.append(uvcOptionViewModelLocal._id)
    //                    uvcOptionViewModelLocal.childrenId.append(uvcOptionViewModelChild._id)
    //                    uvcOptionViewModelArray.append(uvcOptionViewModelChild)
    //                }
    //            }
    //            userSentencePatternAddResponse.uvcOptionViewModel.append(uvcOptionViewModelLocal)
    //            userSentencePatternAddResponse.uvcOptionViewModel.append(contentsOf: uvcOptionViewModelArray)
    //        }
    //
    //        // Get the id name of the parent category to which the sentence pattern belongs
    //        let udcSetnencPatternDataGroupValue = getSentencePatternDataGroupValue(optionItemObjectName: userSentencePatternAddRequest.parentObjectName, optionItemIdName: userSentencePatternAddRequest.parentObjectId, neuronResponse: &neuronResponse, language: neuronRequest.language)
    //
    //        // Copy the words in the range from the specified sentence
    //        let udcUserSentencePattern = UDCUserSentencePattern()
    //        udcUserSentencePattern.udcSentencePatternCategoryIdName = udcSetnencPatternDataGroupValue.itemIdName
    //        let udcSentencePattern = UDCSentencePattern()
    //        udcSentencePattern.udcSentencePatternData.append(UDCSentencePatternData())
    //        udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup.append(UDCSentencePatternDataGroup())
    //        for (udcsdgvIndex, udcsdgv) in udcDocumentGraphModelChild.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[userSentencePatternAddRequest.sentenceIndex].udcSentencePatternDataGroupValue.enumerated() {
    //            if udcsdgvIndex >= userSentencePatternAddRequest.fromItemIndex && udcsdgvIndex <= userSentencePatternAddRequest.toItemIndex {
    //                udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.append(udcsdgv)
    //            }
    //        }
    //        udcUserSentencePattern.udcSentencePattern = udcSentencePattern
    //        udcUserSentencePattern.udcProfile = userSentencePatternAddRequest.udcProfile
    //
    //        // Get profile id's
    //        var profileId = ""
    //        for udcp in udcUserSentencePattern.udcProfile {
    //            if udcp.udcProfileItemIdName == "UDCProfileItem.Human" {
    //                profileId = udcp.profileId
    //            }
    //        }
    //
    //        // Save analytic and get id
    //        let udcDocumentTime = try getUDCDocumentTimeCreated(profileId: profileId, language: neuronRequest.language)
    //        let udcAnalytic = try getAnalyticAndSaveDocumentTime(udcDocumentTime: udcDocumentTime, objectName: "UDCDocumentTime", profileId: profileId,  neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
    //        udcUserSentencePattern.udcAnalytic.append(udcAnalytic)
    //        udcUserSentencePattern._id = try (udbcDatabaseOrm?.generateId())!
    //        let databaseOrmResultUDCUserSentencePattern = UDCUserSentencePattern.save(udbcDatabaseOrm: udbcDatabaseOrm!, object: udcUserSentencePattern)
    //        if databaseOrmResultUDCUserSentencePattern.databaseOrmError.count > 0 {
    //            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCUserSentencePattern.databaseOrmError[0].name, description: databaseOrmResultUDCUserSentencePattern.databaseOrmError[0].description))
    //            return
    //        }
    //
    //
    //        let jsonUtilityUserSentencePatternAddResponse = JsonUtility<UserSentencePatternAddResponse>()
    //        let jsonUserSentencePatternAddResponse = jsonUtilityUserSentencePatternAddResponse.convertAnyObjectToJson(jsonObject: userSentencePatternAddResponse)
    //
    //        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonUserSentencePatternAddResponse)
    //    }
    
    
    private func generateSentenceViewAsObject(udcDocumentGraphModel: UDCDocumentGraphModel,  neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) -> UVCViewModel {
        return UVCViewModel()
    }
    
    private func generateSentenceViewAsArray(udcDocumentGraphModel: UDCDocumentGraphModel,  uvcViewItemCollection: UVCViewItemCollection?, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest, newView: Bool, isEditable: Bool, level: Int, nodeIndex: Int, itemIndex: Int, documentLanguage: String) throws -> [UVCViewModel] {
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
                        let databaseOrmUDCDocumentItem = UDCDocumentGraphModel.get(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, id: udcSentencePatternDataGroupValue.itemId)
                        if databaseOrmUDCDocumentItem.databaseOrmError.count > 0 {
                            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentItem.databaseOrmError[0].name, description: databaseOrmUDCDocumentItem.databaseOrmError[0].description))
                            return uvcViewModelReturn
                        }
                        let udcDocumentItem = databaseOrmUDCDocumentItem.object[0]
                        
                        let udcPhoto = try getPhotoModel(id: udcDocumentItem.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].itemId, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
                               
                        udcPhotoId = udcDocumentItem._id
                        for uvcMeasurement in udcPhoto!.uvcMeasurement {
                            if uvcMeasurement.type == "UVCMeasurementType.Width" {
                                photoWidth = Double(uvcMeasurement.value)
                            } else if uvcMeasurement.type == "UVCMeasurementType.Height" {
                                photoHeight = Double(uvcMeasurement.value)
                            }
                        }
                        //                           } else {
                        //                               udcPhotoId = udcSentencePatternDataGroupValue.itemId
                        //                               isOptionAvailable = false
                        //                           }
                        uvcViewModelReturn.append(uvcViewGenerator.getPhotoModel(isEditable: udcSentencePatternDataGroupValue.isEditable, editObjectCategoryIdName: objectCategoryId, editObjectName: getEditObjectName(idName: udcSentencePatternDataGroupValue.endCategoryIdName), editObjectIdName: udcPhotoId, level: level, isOptionAvailable: isOptionAvailable, width: photoWidth, height: photoHeight, itemIndex: udcSentencePatternDataGroupValueIndex, isCategory: udcDocumentGraphModel.isChildrenAllowed, isBorderEnabled: true, isDeviceOptionsAvailable: !isOptionAvailable))
                    } else if udcSentencePatternDataGroupValue.uvcViewItemType == "UVCViewItemType.Button" {
                        uvcViewModelReturn.append(uvcViewGenerator.getButtonModel(title: value!, name: udcSentencePatternDataGroupValue.itemIdName, level: level, pictureName: nil, parentId: udcDocumentGraphModel.parentId, childrenId: udcDocumentGraphModel.childrenId, objectIdName: udcSentencePatternDataGroupValue.itemIdName, objectName: getEditObjectName(idName: udcSentencePatternDataGroupValue.endCategoryIdName), objectCategoryIdName: objectCategoryId))
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
                            
                            
                            uvcText.uvcViewItemType = "UVCViewItemType.Text"
                            uvcText.helpText = "\(udcSentencePatternDataGroupValue.item!.capitalized)"
                            uvcViewModel.textLength = uvcText.value.count
                            uvcViewModel.name = uvcViewGenerator.generateNameWithUniqueId("UVCViewItemType.Text")
                            if uvcText.value.isEmpty {
                                uvcText.value = value!
                            }
                            if !udcSentencePatternDataGroupValue.isEditable {
                                uvcText.isOptionAvailable = true
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
    
    private func getSentencePattern(existingModel: UDCDocumentGraphModel, objectControllerRequest: ObjectControllerRequest, optionItemObjectName: String, optionItemIdName: String, optionItemNameIndex: Int, optionDocumentIdName: String, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest, language: String, udcDocumentTypeIdName: String, uvcViewItemType: String, itemIndex: Int, item: String, isGeneratedItem: Bool, documentLanguage: String, treeLevel: Int, udcProfile: [UDCProfile], getSentencePatternForDocumentItemResponse: inout GetGraphSentencePatternForDocumentItemResponse) throws {
        
        let getSentencePatternForDocumentItemRequest = GetGraphSentencePatternForDocumentItemRequest()
        getSentencePatternForDocumentItemRequest.documentItemIdName = optionItemIdName
        getSentencePatternForDocumentItemRequest.documentItemObjectName = optionItemObjectName
        getSentencePatternForDocumentItemRequest.documentItemNameIndex = optionItemNameIndex
        getSentencePatternForDocumentItemRequest.uvcViewItemType = uvcViewItemType
        getSentencePatternForDocumentItemRequest.itemIndex = itemIndex
        getSentencePatternForDocumentItemRequest.existingModel = existingModel
        getSentencePatternForDocumentItemRequest.objectControllerRequest = objectControllerRequest
        getSentencePatternForDocumentItemRequest.item = item
        getSentencePatternForDocumentItemRequest.isGeneratedItem = isGeneratedItem
        getSentencePatternForDocumentItemRequest.documentLanguage = documentLanguage
        getSentencePatternForDocumentItemRequest.treeLevel = treeLevel
        getSentencePatternForDocumentItemRequest.udcDocumentTypeIdName = udcDocumentTypeIdName
        getSentencePatternForDocumentItemRequest.documentIdName = optionDocumentIdName
        getSentencePatternForDocumentItemRequest.udcProfile = udcProfile
        getSentencePatternForDocumentItemRequest.udcSentencePatternDataGroupValue = try getSentencePatternDataGroupValueForDocumentItem(optionItemObjectName: optionItemObjectName, optionItemIdName: optionItemIdName, optionDocumentIdName: optionDocumentIdName, optionItemNameIndex: optionItemNameIndex, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, language: documentLanguage, udcProfile: udcProfile, udcDocumentTypeIdName: udcDocumentTypeIdName)

        if try isNeuronProcessingIt(operationName: "DocumentGraphNeuron.Document.Type.Process.SentencePattern.Got", udcDocumentTypeIdName: udcDocumentTypeIdName, neuronRequest: neuronRequest, neuronResponse: &neuronResponse) {
            let neuronRequestLocal = neuronRequest
            let jsonUtilityGetSentencePatternForDocumentItemRequest = JsonUtility<GetGraphSentencePatternForDocumentItemRequest>()
            let jsonDocumentGetSentencePatternForDocumentItemRequest = jsonUtilityGetSentencePatternForDocumentItemRequest.convertAnyObjectToJson(jsonObject: getSentencePatternForDocumentItemRequest)
            neuronRequestLocal.neuronOperation.neuronData.text = jsonDocumentGetSentencePatternForDocumentItemRequest
            
            try callNeuron(neuronRequest: neuronRequestLocal, neuronResponse: &neuronResponse, operationName: "DocumentGraphNeuron.Get.SentencePattern.DocumentItem", udcDocumentTypeIdName: udcDocumentTypeIdName)
        } else {
            try getSentencePatternForDocumentItem(getSentencePatternForDocumentItemRequest: getSentencePatternForDocumentItemRequest, getSentencePatternForDocumentItemResponse: &getSentencePatternForDocumentItemResponse, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        }
    }
    
    private func callOtherNeuron(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest, neuronName: String, overWriteResponse: Bool) throws {
        let neuronRequestLocal = NeuronRequest()
        neuronRequestLocal.neuronSource._id = neuronRequest.neuronSource._id
        neuronRequestLocal.neuronOperation.synchronus = true
        neuronRequestLocal.neuronOperation._id = neuronRequest.neuronOperation._id
        neuronRequestLocal.neuronSource.name = DocumentGraphNeuron.getName()
        neuronRequestLocal.neuronSource.type = DocumentGraphNeuron.getName();
        neuronRequestLocal.neuronOperation.name = neuronRequest.neuronOperation.name
        neuronRequestLocal.neuronOperation.parent = true
        neuronRequestLocal.neuronOperation.neuronData.text = neuronRequest.neuronOperation.neuronData.text
        neuronRequestLocal.neuronTarget.name =  neuronName
        neuronUtility!.callNeuron(neuronRequest: neuronRequestLocal)
        
        let neuronResponseLocal = getChildResponse(sourceId: neuronRequestLocal.neuronSource._id)
        
        if neuronResponseLocal.neuronOperation.neuronOperationStatus.neuronOperationError!.count > 0 {
            print("\(DocumentGraphNeuron.getName()) Errors from child neuron: \(neuronRequest.neuronOperation.name))")
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
            print("\(DocumentGraphNeuron.getName()) Success from child neuron: \(neuronRequest.neuronOperation.name))")
            if overWriteResponse {
                neuronResponse.neuronOperation.neuronData.text = neuronResponseLocal.neuronOperation.neuronData.text
            }
        }
    }
    
    private func getOptionMap(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let getOptionMapRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: GetOptionMapRequest())
        
        let documentLanguage = getOptionMapRequest.documentLanguage
        let interfaceLanguage = getOptionMapRequest.interfaceLanguage
        
        try callOtherNeuron(neuronRequest: neuronRequest, neuronResponse: &neuronResponse, neuronName: "OptionMapNeuron", overWriteResponse: true)
        
        let getOptionMapResponse = neuronUtility!.getNeuronRequest(json: neuronResponse.neuronOperation.neuronData.text, object: GetOptionMapResponse())
        
        if getOptionMapResponse.name == "UDCOptionMap.DocumentOptions" || getOptionMapResponse.name == "UDCOptionMap.DocumentMapOptions" {
            for uvcovm in getOptionMapResponse.uvcOptionMapViewModel.uvcOptionViewModel {
                print(uvcovm.idName)
                
                if (uvcovm.idName == "UDCOptionMapNode.DocumentLanguage" || uvcovm.idName == "UDCOptionMapNode.InterfaceLanguage") {
                    uvcovm.childrenId.removeAll()
                    
                    let databaseOrmResultUDCApplicationHumanLanguage = UDCApplicationHumanLanguage.get(udcProfile: getOptionMapRequest.udcProfile, udbcDatabaseOrm!)
                    if databaseOrmResultUDCApplicationHumanLanguage.databaseOrmError.count > 0 {
                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCApplicationHumanLanguage.databaseOrmError[0].name, description: databaseOrmResultUDCApplicationHumanLanguage.databaseOrmError[0].description))
                        return
                    }
                    let udcApplicationHumanLanguage = databaseOrmResultUDCApplicationHumanLanguage.object
                    for udcphl in udcApplicationHumanLanguage {
                        let databaseOrmUDCHumanLanguageType = UDCHumanLanguageType.get(idName: udcphl.udcHumanLanguageIdName, udbcDatabaseOrm!, interfaceLanguage)
                        if databaseOrmUDCHumanLanguageType.databaseOrmError.count > 0 {
                            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCHumanLanguageType.databaseOrmError[0].name, description: databaseOrmUDCHumanLanguageType.databaseOrmError[0].description))
                            return
                        }
                        let udchl = databaseOrmUDCHumanLanguageType.object[0]
                        let uvcOptionViewModel = UVCOptionViewModel()
                        uvcOptionViewModel._id = try (udbcDatabaseOrm?.generateId())!
                        uvcOptionViewModel.idName = udchl.code6391!
                        var name = udchl.name
                        if interfaceLanguage == "en" {
                            name = name.capitalized
                        }
                        uvcOptionViewModel.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: name, description: "", category: "", subCategory: "", language: interfaceLanguage, isChildrenExist: false, isEditable: false, isCheckBox: true, photoId: nil, photoObjectName: nil)
                        uvcOptionViewModel.language = interfaceLanguage
                        uvcOptionViewModel.level = 2
                        uvcOptionViewModel.pathIdName.append(contentsOf: uvcovm.pathIdName)
                        uvcOptionViewModel.pathIdName[0].append(udchl.idName)
                        uvcOptionViewModel.isSingleSelect = true
                        if documentLanguage == udchl.code6391 {
                            uvcOptionViewModel.isSelected = true
                        }
                        uvcOptionViewModel.parentId.append(uvcovm._id)
                        uvcovm.childrenId.append(uvcOptionViewModel._id)
                        let jsonUtility = JsonUtility<UDCHumanLanguageType>()
                        uvcOptionViewModel.model = jsonUtility.convertAnyObjectToJson(jsonObject: udchl)
                        getOptionMapResponse.uvcOptionMapViewModel.uvcOptionViewModel.append(uvcOptionViewModel)
                    }
                } else if uvcovm.idName == "UDCOptionMapNode.DocumentType" {
                    uvcovm.childrenId.removeAll()
                    let databaseOrmUDCApplicationDocumentType = UDCApplicationDocumentType.get(limitedTo: 0, sortedBy: "_id", udbcDatabaseOrm: udbcDatabaseOrm!, udcProfile: getOptionMapRequest.udcProfile)
                    if databaseOrmUDCApplicationDocumentType.databaseOrmError.count > 0 {
                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCApplicationDocumentType.databaseOrmError[0].name, description: databaseOrmUDCApplicationDocumentType.databaseOrmError[0].description))
                        return
                    }
                    for udcApplicationDocumentType in databaseOrmUDCApplicationDocumentType.object {
                        let databaseOrmUDCHumanLanguageType = UDCDocumentType.get(limitedTo: 0,  sortedBy: "name", udbcDatabaseOrm: udbcDatabaseOrm!,  language: interfaceLanguage, idName: udcApplicationDocumentType.udcDocumentTypeIdName)
                        let udcdt = databaseOrmUDCHumanLanguageType.object[0]
                        let uvcOptionViewModel = UVCOptionViewModel()
                        uvcOptionViewModel._id = try (udbcDatabaseOrm?.generateId())!
                        var name = udcdt.name
                        if interfaceLanguage == "en" {
                            name = name.capitalized
                        }
                        uvcOptionViewModel.idName = udcdt.idName
                        uvcOptionViewModel.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: name, description: "", category: "", subCategory: "", language: interfaceLanguage, isChildrenExist: false, isEditable: false, isCheckBox: true, photoId: nil, photoObjectName: nil)
                        uvcOptionViewModel.language = interfaceLanguage
                        uvcOptionViewModel.level = 2
                        uvcOptionViewModel.pathIdName.append(contentsOf: uvcovm.pathIdName)
                        uvcOptionViewModel.pathIdName[0].append(udcdt.idName)
                        uvcOptionViewModel.isSingleSelect = true
                        if getOptionMapRequest.documentType == udcdt.idName {
                            uvcOptionViewModel.isSelected = true
                        }
                        uvcOptionViewModel.parentId.append(uvcovm._id)
                        uvcovm.childrenId.append(uvcOptionViewModel._id)
                        let jsonUtility = JsonUtility<UDCDocumentType>()
                        uvcOptionViewModel.model = jsonUtility.convertAnyObjectToJson(jsonObject: udcdt)
                        
                        getOptionMapResponse.uvcOptionMapViewModel.uvcOptionViewModel.append(uvcOptionViewModel)
                    }
                }
            }
        } else if getOptionMapResponse.name == "UDCOptionMap.DocumentItemOptions" {
            for uvcovm in getOptionMapResponse.uvcOptionMapViewModel.uvcOptionViewModel {
                print(uvcovm.idName)
                if uvcovm.idName == "UDCOptionMapNode.ConfigureSearch" {
                    uvcovm.childrenId.removeAll()
                    let uvcOptionViewModel = UVCOptionViewModel()
                    uvcOptionViewModel._id = try (udbcDatabaseOrm?.generateId())!
                    uvcOptionViewModel.uvcViewModel = getConfigureSearchView(getOptionMapRequest: getOptionMapRequest, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
                    if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
                        return
                    }
                    uvcOptionViewModel.language = interfaceLanguage
                    uvcOptionViewModel.level = 2
                    var name = uvcovm.getText(name: "Name")!.value
                    if interfaceLanguage == "en" {
                        name = name.capitalized
                    }
                    uvcOptionViewModel.pathIdName.append(contentsOf: uvcovm.pathIdName)
                    uvcOptionViewModel.pathIdName[0].append("UDCOptionMapNode.ConfigureSearchView")
                    uvcOptionViewModel.isDocument = true
                    uvcOptionViewModel.parentId.append(uvcovm._id)
                    uvcovm.childrenId.append(uvcOptionViewModel._id)
                    getOptionMapResponse.uvcOptionMapViewModel.uvcOptionViewModel.append(uvcOptionViewModel)
                } else if uvcovm.idName == "UDCOptionMapNode.Reference" {
                    // Remove the dummy child, added for child indication purpose
                    uvcovm.childrenId.removeAll()
                    
                    let databaseOrmResultUDCDocumentReferenceType =  UDCDocumentReferenceType.get(udbcDatabaseOrm!, interfaceLanguage)
                    if databaseOrmResultUDCDocumentReferenceType.databaseOrmError.count > 0 {
                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentReferenceType.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentReferenceType.databaseOrmError[0].description))
                        continue
                    }
                    for udcrt in databaseOrmResultUDCDocumentReferenceType.object {
                        let uvcOptionViewModel = UVCOptionViewModel()
                        uvcOptionViewModel._id = try (udbcDatabaseOrm?.generateId())!
                        var name = udcrt.name
                        if interfaceLanguage == "en" {
                            name = name.capitalized
                        }
                        uvcOptionViewModel.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: name, description: "", category: "", subCategory: "", language: interfaceLanguage, isChildrenExist: true, isEditable: false, isCheckBox: false, photoId: nil, photoObjectName: nil)
                        uvcOptionViewModel.language = interfaceLanguage
                        uvcOptionViewModel.level = 2
                        uvcOptionViewModel.pathIdName.append(contentsOf: uvcovm.pathIdName)
                        uvcOptionViewModel.pathIdName[0].append(udcrt.idName)
                        uvcOptionViewModel.parentId.append(uvcovm._id)
                        uvcOptionViewModel.isDismissedOnSelection = false
                        uvcovm.childrenId.append(uvcOptionViewModel._id)
                        
                        getOptionMapResponse.uvcOptionMapViewModel.uvcOptionViewModel.append(uvcOptionViewModel)
                        
                    }
                } else if uvcovm.idName == "UDCOptionMapNode.Category" {
                    // Get categories from respective neuron based on document type
                    let getDocumentCategoriesRequest = GetDocumentCategoriesRequest()
                    getDocumentCategoriesRequest.categoryOptionViewModel = uvcovm
                    getDocumentCategoriesRequest.documentLanguage = documentLanguage
                    getDocumentCategoriesRequest.interfaceLanguage = interfaceLanguage
                    let neuronRequestLocal = neuronRequest
                    let jsonUtilityGetDocumentCategoriesRequest = JsonUtility<GetDocumentCategoriesRequest>()
                    let jsonGetDocumentCategoriesRequest = jsonUtilityGetDocumentCategoriesRequest.convertAnyObjectToJson(jsonObject: getDocumentCategoriesRequest)
                    neuronRequestLocal.neuronOperation.neuronData.text = jsonGetDocumentCategoriesRequest
                    
                    let called = try callNeuron(neuronRequest: neuronRequestLocal, neuronResponse: &neuronResponse, operationName: "DocumentGraphNeuron.Get.Categories", udcDocumentTypeIdName: getOptionMapRequest.documentType)
                    
                    if called {
                        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) || neuronResponse.neuronOperation.neuronData.text.isEmpty {
                            return
                        }
                        
                        
                        let getDocumentCategoriesResponse = neuronUtility!.getNeuronRequest(json: neuronResponse.neuronOperation.neuronData.text, object: GetDocumentCategoriesResponse())
                        
                        uvcovm.childrenId.removeAll()
                        for category in getDocumentCategoriesResponse.category {
                            uvcovm.childrenId.append(category._id)
                        }
                        getOptionMapResponse.uvcOptionMapViewModel.uvcOptionViewModel.append(contentsOf: getDocumentCategoriesResponse.category)
                    }
                } else if uvcovm.idName == "UDCOptionMapNode.CategoryOptions" {
                    // Get category options for each category from respective neuorn based on document type
                    let getDocumentCategoryOptionsRequest = GetDocumentCategoryOptionsRequest()
                    getDocumentCategoryOptionsRequest.categoryOptionsOptionViewModel = uvcovm
                    getDocumentCategoryOptionsRequest.documentLanguage = documentLanguage
                    getDocumentCategoryOptionsRequest.interfaceLanguage = interfaceLanguage
                    uvcovm.isDismissedOnSelection = false
                    let neuronRequestLocal = neuronRequest
                    let jsonUtilityGetDocumentCategoryOptionsRequest = JsonUtility<GetDocumentCategoryOptionsRequest>()
                    let jsonGetDocumentCategoryOptionsRequest = jsonUtilityGetDocumentCategoryOptionsRequest.convertAnyObjectToJson(jsonObject: getDocumentCategoryOptionsRequest)
                    neuronRequestLocal.neuronOperation.neuronData.text = jsonGetDocumentCategoryOptionsRequest
                    
                    let called = try callNeuron(neuronRequest: neuronRequestLocal, neuronResponse: &neuronResponse, operationName: "DocumentGraphNeuron.Get.Category.Options", udcDocumentTypeIdName: getOptionMapRequest.documentType)
                    
                    if called {
                        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) || neuronResponse.neuronOperation.neuronData.text.isEmpty {
                            return
                        }
                        
                        let getDocumentCategoryOptionsResponse = neuronUtility!.getNeuronRequest(json: neuronResponse.neuronOperation.neuronData.text, object: GetDocumentCategoryOptionsResponse())
                        
                        getOptionMapResponse.uvcOptionMapViewModelDictionary[uvcovm.idName] = getDocumentCategoryOptionsResponse.categoryOption
                    }
                }
            }
            
        } else if getOptionMapResponse.name == "UDCOptionMap.ViewOptions" {
            let uvcovm = getOptionMapResponse.uvcOptionMapViewModel.uvcOptionViewModel[0]
            uvcovm.childrenId.removeAll()
            let databaseOrmResultUVCViewItemType = UVCViewItemType.get(udbcDatabaseOrm!, interfaceLanguage)
            if databaseOrmResultUVCViewItemType.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUVCViewItemType.databaseOrmError[0].name, description: databaseOrmResultUVCViewItemType.databaseOrmError[0].description))
                return
            }
            for (udcviIndex, udcvi) in databaseOrmResultUVCViewItemType.object.enumerated() {
                let uvcOptionViewModel = UVCOptionViewModel()
                uvcOptionViewModel._id = try (udbcDatabaseOrm?.generateId())!
                uvcOptionViewModel.idName = udcvi.idName
                var isChildrenExist = false
                if udcvi.idName == "UVCViewItemType.Photo" {
                    isChildrenExist = true
                }
                var name = udcvi.name
                if interfaceLanguage == "en" {
                    name = name.capitalized
                }
                uvcOptionViewModel.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: name, description: "", category: "", subCategory: "", language: interfaceLanguage, isChildrenExist: isChildrenExist, isEditable: false, isCheckBox: true, photoId: nil, photoObjectName: nil)
                uvcOptionViewModel.language = interfaceLanguage
                uvcOptionViewModel.level = 1
                uvcOptionViewModel.pathIdName.append(contentsOf: uvcovm.pathIdName)
                uvcOptionViewModel.pathIdName[0].append(udcvi.idName)
                uvcOptionViewModel.isDismissedOnSelection = true
                uvcOptionViewModel.parentId.append(uvcovm._id)
                uvcovm.childrenId.append(uvcOptionViewModel._id)
                if udcvi.idName == "UVCViewItemType.Photo" {
                    let getOptionMapRequestLocal = GetOptionMapRequest()
                    getOptionMapRequestLocal.name = "UDCOptionMap.PhotoSizeOptions"
                    getOptionMapRequestLocal.udcProfile = getOptionMapRequest.udcProfile
                    getOptionMapRequestLocal.documentLanguage = getOptionMapRequest.documentLanguage
                    getOptionMapRequestLocal.interfaceLanguage = getOptionMapRequest.interfaceLanguage
                    let neuronRequestLocal = NeuronRequest()
                    neuronRequestLocal.neuronSource._id = neuronRequest.neuronSource._id
                    neuronRequestLocal.neuronOperation.synchronus = true
                    neuronRequestLocal.neuronOperation._id = neuronRequest.neuronOperation._id
                    neuronRequestLocal.neuronSource.name = DocumentGraphNeuron.getName()
                    neuronRequestLocal.neuronSource.type = DocumentGraphNeuron.getName()
                    neuronRequestLocal.neuronOperation.name = "OptionMapNeuron.OptionMap.Get"
                    neuronRequestLocal.neuronOperation.parent = true
                    let jsonUtilityGetOptionMapRequest = JsonUtility<GetOptionMapRequest>()
                    let jsonDocumentGetOptionMapRequest = jsonUtilityGetOptionMapRequest.convertAnyObjectToJson(jsonObject: getOptionMapRequestLocal)
                    neuronRequestLocal.neuronOperation.neuronData.text = jsonDocumentGetOptionMapRequest
                    neuronRequestLocal.neuronTarget.name = "OptionMapNeuron"
                    
                    try getOptionMap(neuronRequest: neuronRequestLocal, neuronResponse: &neuronResponse)
                    
                    if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
                        return
                    }
                    
                    let getOptionMapResponseLocal = neuronUtility!.getNeuronRequest(json: neuronResponse.neuronOperation.neuronData.text, object: GetOptionMapResponse())
                    for (uvcOptionViewModelLocalIndex, uvcOptionViewModelLocal) in getOptionMapResponseLocal.uvcOptionMapViewModel.uvcOptionViewModel.enumerated() {
                        if uvcOptionViewModelLocal.pathIdName[0].count == 1 {
                            continue
                        }
                        if uvcOptionViewModelLocal.pathIdName[0].count == 2/* && uvcOptionViewModelLocal.pathIdName[0][0] == "UVCViewItemType.Photo"*/ {
                            uvcOptionViewModelLocal.parentId.append(uvcOptionViewModel._id)
                            uvcOptionViewModel.childrenId.append(uvcOptionViewModelLocal._id)
                        }
                        uvcOptionViewModelLocal.pathIdName[0].insert(contentsOf: uvcovm.pathIdName[0], at: 0)
                        getOptionMapResponse.uvcOptionMapViewModel.uvcOptionViewModel.append(uvcOptionViewModelLocal)
                    }
                    
                }
                getOptionMapResponse.uvcOptionMapViewModel.uvcOptionViewModel.append(uvcOptionViewModel)
            }
        }
        
        let jsonUtilityGetOptionMapResponse = JsonUtility<GetOptionMapResponse>()
        let jsonGetOptionMapResponse = jsonUtilityGetOptionMapResponse.convertAnyObjectToJson(jsonObject: getOptionMapResponse)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonGetOptionMapResponse)
    }
    
    
    private func getConfigureSearchView(getOptionMapRequest: GetOptionMapRequest, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) -> UVCViewModel {
        
        let interfaceLanguage = getOptionMapRequest.interfaceLanguage
        let uvcm = UVCViewModel()
        uvcm.name = ""
        uvcm.description = ""
        uvcm.language = interfaceLanguage
        
        // View items
        
        let databaseOrmUDCOptionMap = UDCOptionMap.get(udbcDatabaseOrm: udbcDatabaseOrm!, name: "UDCOptionMap.ConfigureSearchView", udcProfile: getOptionMapRequest.udcProfile, language: interfaceLanguage)
        if databaseOrmUDCOptionMap.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCOptionMap.databaseOrmError[0].name, description: databaseOrmUDCOptionMap.databaseOrmError[0].description))
            return uvcm
        }
        let udcOptionMap = databaseOrmUDCOptionMap.object
        var datbaseOrmUDCOptionMapNode = UDCOptionMapNode.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: udcOptionMap[0].udcOptionMapNodeId[0], language: interfaceLanguage)
        if datbaseOrmUDCOptionMapNode.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: datbaseOrmUDCOptionMapNode.databaseOrmError[0].name, description: datbaseOrmUDCOptionMapNode.databaseOrmError[0].description))
            return uvcm
        }
        let udcOptionMapNode = datbaseOrmUDCOptionMapNode.object
        
        
        
        var uvcViewItem = UVCViewItem()
        let uvcTable = UVCTable()
        
        uvcViewItem.name = "\(udcOptionMapNode[0].idName).Table"
        uvcViewItem.type = "UVCViewItemType.Table"
        uvcm.uvcViewItem.append(uvcViewItem)
        uvcViewItem = UVCViewItem()
        uvcViewItem.name = "\(udcOptionMapNode[0].idName).Text"
        uvcViewItem.type = "UVCViewItemType.Text"
        uvcm.uvcViewItem.append(uvcViewItem)
        uvcViewItem = UVCViewItem()
        uvcViewItem.name = "\(udcOptionMapNode[0].idName).OnOff"
        uvcViewItem.type = "UVCViewItemType.OnOff"
        uvcm.uvcViewItem.append(uvcViewItem)
        
        uvcTable.name = "\(udcOptionMapNode[0].idName).Table"
        
        for id in udcOptionMapNode[0].childrenId {
            datbaseOrmUDCOptionMapNode = UDCOptionMapNode.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: id, language: interfaceLanguage)
            if datbaseOrmUDCOptionMapNode.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: datbaseOrmUDCOptionMapNode.databaseOrmError[0].name, description: datbaseOrmUDCOptionMapNode.databaseOrmError[0].description))
                return uvcm
            }
            let udcomn = datbaseOrmUDCOptionMapNode.object[0]
            
            let uvcTableRow = UVCTableRow()
            let uvcTableColumn = UVCTableColumn()
            uvcViewItem = UVCViewItem()
            uvcViewItem.uvcAlignment.uvcPositionType = UVCPositionType.Left.name
            uvcViewItem.name = "\(udcomn.idName).Text"
            uvcViewItem.type = "UVCViewItemType.Text"
            uvcTableColumn.uvcViewItem.append(uvcViewItem)
            uvcViewItem = UVCViewItem()
            uvcViewItem.name = "\(udcomn.idName).OnOff"
            uvcViewItem.uvcAlignment.uvcPositionType = UVCPositionType.Left.name
            uvcViewItem.type = "UVCViewItemType.OnOff"
            uvcTableColumn.uvcViewItem.append(uvcViewItem)
            uvcTableRow.uvcTableColumn.append(uvcTableColumn)
            uvcTable.uvcTableRow.append(uvcTableRow)
            
            let uvcText = uvcViewGenerator.getText(name: "\(udcomn.idName).Text", value: udcomn.name.capitalized, description: "", isEditable: false)
            uvcText.uvcTextSize.uvcTextSizeType = UVCTextSizeType.Regular.name
            var uvcMeasurement = UVCMeasurement()
            uvcMeasurement.type = UVCMeasurementType.XAxis.name
            uvcMeasurement.value = 0
            uvcText.uvcMeasurement.append(uvcMeasurement)
            uvcMeasurement = UVCMeasurement()
            uvcMeasurement.type = UVCMeasurementType.YAxis.name
            uvcMeasurement.value = 0
            uvcText.uvcMeasurement.append(uvcMeasurement)
            uvcMeasurement = UVCMeasurement()
            uvcMeasurement.type = UVCMeasurementType.Width.name
            uvcMeasurement.value = 100
            uvcText.uvcMeasurement.append(uvcMeasurement)
            uvcMeasurement = UVCMeasurement()
            uvcMeasurement.type = UVCMeasurementType.Height.name
            uvcMeasurement.value = 31
            uvcText.uvcMeasurement.append(uvcMeasurement)
            uvcm.uvcViewItemCollection.uvcText.append(uvcText)
            
            let uvcOnOff = uvcViewGenerator.getOnOff(name: "\(udcomn.idName).OnOff", isSelected: false, isEditable: true)
            uvcm.uvcViewItemCollection.uvcOnOff.append(uvcOnOff)
            
        }
        
        uvcm.uvcViewItemCollection.uvcTable.append(uvcTable)
        uvcm.rowLength = 5
        
        return uvcm
    }
    
    private func removePhoto(id: String, udcDocumentTypeIdName: String, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let removeItemPhotoRequest = RemoveItemPhotoRequest()
        removeItemPhotoRequest.photoId = id
        removeItemPhotoRequest.udcDocumentTypeIdName = udcDocumentTypeIdName
        let neuronRequestLocal = NeuronRequest()
        neuronRequestLocal.neuronSource._id = neuronRequest.neuronSource._id
        neuronRequestLocal.neuronOperation.synchronus = true
        neuronRequestLocal.neuronOperation._id = neuronRequest.neuronOperation._id
        neuronRequestLocal.neuronSource.name = DocumentGraphNeuron.getName()
        neuronRequestLocal.neuronSource.type = DocumentGraphNeuron.getName()
        neuronRequestLocal.neuronOperation.name = "PhotoNeuron.Remove.Item.Photo"
        neuronRequestLocal.neuronOperation.parent = true
        let jsonUtilityRemoveItemPhotoRequest = JsonUtility<RemoveItemPhotoRequest>()
        neuronRequestLocal.neuronOperation.neuronData.text = jsonUtilityRemoveItemPhotoRequest.convertAnyObjectToJson(jsonObject: removeItemPhotoRequest)
        try callOtherNeuron(neuronRequest: neuronRequestLocal, neuronResponse: &neuronResponse, neuronName: "PhotoNeuron", overWriteResponse: true)
        
        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
            return
        }
    }
    
    private func getPhotoModel(id: String, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws -> UDCPhoto? {
        let getPhotoModelRequest = GetPhotoModelRequest()
        getPhotoModelRequest.photoId = id
        let neuronRequestLocal = NeuronRequest()
        neuronRequestLocal.neuronSource._id = neuronRequest.neuronSource._id
        neuronRequestLocal.neuronOperation.synchronus = true
        neuronRequestLocal.neuronOperation._id = neuronRequest.neuronOperation._id
        neuronRequestLocal.neuronSource.name = DocumentGraphNeuron.getName()
        neuronRequestLocal.neuronSource.type = DocumentGraphNeuron.getName()
        neuronRequestLocal.neuronOperation.name = "PhotoNeuron.Get.Model"
        neuronRequestLocal.neuronOperation.parent = true
        let jsonUtilityGetPhotoModelRequest = JsonUtility<GetPhotoModelRequest>()
        neuronRequestLocal.neuronOperation.neuronData.text = jsonUtilityGetPhotoModelRequest.convertAnyObjectToJson(jsonObject: getPhotoModelRequest)
        try callOtherNeuron(neuronRequest: neuronRequestLocal, neuronResponse: &neuronResponse, neuronName: "PhotoNeuron", overWriteResponse: true)
        
        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
            return nil
        }

        let getPhotoModelResponse = neuronUtility!.getNeuronRequest(json: neuronResponse.neuronOperation.neuronData.text, object: GetPhotoModelResponse())
        
        return getPhotoModelResponse.udcPhoto
    }
    
    
    private func documentDeleteItem(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let documentGraphDeleteItemRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: DocumentGraphDeleteItemRequest())
        
        let documentLanguage = documentGraphDeleteItemRequest.documentLanguage
        let interfaceLanguage = documentGraphDeleteItemRequest.interfaceLanguage
        
        // If zeroth index or a category then don't delete return
        if documentGraphDeleteItemRequest.itemIndex == 0 {
            let documentGraphDeleteItemResponse = DocumentGraphDeleteItemResponse()
            let jsonUtilityDocumentGraphChangeItemResponse = JsonUtility<DocumentGraphDeleteItemResponse>()
            let jsonDocumentGraphChangeItemResponse = jsonUtilityDocumentGraphChangeItemResponse.convertAnyObjectToJson(jsonObject: documentGraphDeleteItemResponse)
            neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonDocumentGraphChangeItemResponse)
            return
        }
        
        if documentGraphDeleteItemRequest.itemIndex > 0 {
            documentGraphDeleteItemRequest.itemIndex -= 1
        }
        
        let databaseOrmUDCDocumentGraphModelCheck = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphDeleteItemRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: documentGraphDeleteItemRequest.nodeId, language: documentLanguage) as DatabaseOrmResult<UDCDocumentGraphModel>
        if databaseOrmUDCDocumentGraphModelCheck.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentGraphModelCheck.databaseOrmError[0].name, description: databaseOrmUDCDocumentGraphModelCheck.databaseOrmError[0].description))
            return
        }
        let udcDocumentGraphModelCheck = databaseOrmUDCDocumentGraphModelCheck.object[0]
        let prevIdName = udcDocumentGraphModelCheck.idName
        var prevUdcSentencePatternDataGroupValue = udcDocumentGraphModelCheck.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue
        
        if udcDocumentGraphModelCheck.level == 0 && documentLanguage != "en" {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "CannotDelete", description: "Cannot delete!"))
            return
        }
        
        if documentGraphDeleteItemRequest.udcDocumentTypeIdName == "UDCDocumentType.DocumentItem" {
            if udcDocumentGraphModelCheck.isChildrenAllowed && documentGraphDeleteItemRequest.treeLevel > 1 {
                documentGraphDeleteItemRequest.itemIndex -= 1
            }
        }
        
        var databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: documentGraphDeleteItemRequest.documentId, language: documentLanguage)
        if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocument.databaseOrmError[0].name, description: databaseOrmResultUDCDocument.databaseOrmError[0].description))
            return
        }
        let udcDocument = databaseOrmResultUDCDocument.object[0]
        
        
        if documentGraphDeleteItemRequest.udcDocumentTypeIdName == "UDCDocumentType.DocumentItem" && udcDocumentGraphModelCheck.level > 1 {
            let databaseOrmUDCDocumentGraphModelParent = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphDeleteItemRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentGraphModelCheck.parentId[0], language: documentLanguage) as DatabaseOrmResult<UDCDocumentGraphModel>
            if databaseOrmUDCDocumentGraphModelParent.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentGraphModelParent.databaseOrmError[0].name, description: databaseOrmUDCDocumentGraphModelParent.databaseOrmError[0].description))
                return
            }
            let udcDocumentGraphModelParent = databaseOrmUDCDocumentGraphModelParent.object[0]
            let udcSentencePatternDataGroupValueLocalFind = UDCSentencePatternDataGroupValue()
            if udcDocumentGraphModelParent.level == 1 {
                udcSentencePatternDataGroupValueLocalFind.endCategoryIdName = udcDocumentGraphModelParent.idName
            } else {
                let databaseOrmResultCategory = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphDeleteItemRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentGraphModelParent.parentId[0])
                udcSentencePatternDataGroupValueLocalFind.endCategoryIdName = databaseOrmResultCategory.object[0].idName
            }
            udcSentencePatternDataGroupValueLocalFind.itemId = udcDocumentGraphModelCheck._id
            udcSentencePatternDataGroupValueLocalFind.endSubCategoryId = udcDocumentGraphModelCheck.parentId[0]
            
            
            var found = false
            findDocumentItemInAllDocs(find: udcSentencePatternDataGroupValueLocalFind, documentLanguage: documentLanguage, found: &found, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            if found {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "CannotDeleteSinceItIsReferedSomewhere", description: "Cannot delete since it is refered somewhere!"))
                return
            }
        }
        
        let validateDocumentGraphItemForDeleteRequest = ValidateDocumentGraphItemForDeleteRequest()
        validateDocumentGraphItemForDeleteRequest.documentGraphDeleteItemRequest = documentGraphDeleteItemRequest
        validateDocumentGraphItemForDeleteRequest.udcValidationStepTypeIdName = "UDCValidationStep.Request"
        validateDocumentGraphItemForDeleteRequest.deleteDocumentModel = udcDocumentGraphModelCheck
        validateDocumentGraphItemForDeleteRequest.udcDocument = udcDocument
        validateDocumentGraphItemForDeleteRequest.udcDocumentTypeIdName = documentGraphDeleteItemRequest.udcDocumentTypeIdName
        var validateDocumentGraphItemForDeleteResponse = ValidateDocumentGraphItemForDeleteResponse()
        try validateDeleteRequest(validateDocumentGraphItemForDeleteRequest: validateDocumentGraphItemForDeleteRequest, validateDocumentGraphItemForDeleteResponse: &validateDocumentGraphItemForDeleteResponse, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        
        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
            return
        }
        
        if try isNeuronProcessingIt(operationName: "DocumentGraphNeuron.Document.Type.Process.DeleteItem.Validated", udcDocumentTypeIdName: documentGraphDeleteItemRequest.udcDocumentTypeIdName, neuronRequest: neuronRequest, neuronResponse: &neuronResponse) {
            let neuronRequestLocal = NeuronRequest()
            neuronRequestLocal.neuronSource._id = neuronRequest.neuronSource._id
            neuronRequestLocal.neuronOperation.synchronus = true
            neuronRequestLocal.neuronOperation._id = neuronRequest.neuronOperation._id
            neuronRequestLocal.neuronSource.name = DocumentGraphNeuron.getName()
            neuronRequestLocal.neuronSource.type = DocumentGraphNeuron.getName()
            neuronRequestLocal.neuronOperation.name = "DocumentGraphNeuron.Document.Validate.Delete"
            neuronRequestLocal.neuronOperation.parent = true
            let jsonUtilityValidateDocumentGraphItemForDeleteRequest = JsonUtility<ValidateDocumentGraphItemForDeleteRequest>()
            neuronRequestLocal.neuronOperation.neuronData.text = jsonUtilityValidateDocumentGraphItemForDeleteRequest.convertAnyObjectToJson(jsonObject: validateDocumentGraphItemForDeleteRequest)
            try callNeuron(neuronRequest: neuronRequestLocal, neuronResponse: &neuronResponse, operationName: "DocumentGraphNeuron.Document.Validate.Delete", udcDocumentTypeIdName: documentGraphDeleteItemRequest.udcDocumentTypeIdName)
        }
        
        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
            return
        }
        
        
        var profileId = ""
        for udcp in documentGraphDeleteItemRequest.udcProfile {
            if udcp.udcProfileItemIdName == "UDCProfileItem.Human" {
                profileId = udcp.profileId
            }
        }
        
        // Get the recipe model
        
        let databaseOrmResultudcDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphDeleteItemRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: documentGraphDeleteItemRequest.nodeId, language: documentLanguage) as DatabaseOrmResult<UDCDocumentGraphModel>
        if databaseOrmResultudcDocumentGraphModel.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModel.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModel.databaseOrmError[0].description))
            return
        }
        let udcDocumentGraphModel = databaseOrmResultudcDocumentGraphModel.object[0]
        
        let documentGraphDeleteItemResponse = DocumentGraphDeleteItemResponse()
        documentGraphDeleteItemResponse.objectControllerResponse.groupUVCViewItemType = documentGraphDeleteItemRequest.objectControllerRequest.groupUVCViewItemType
        documentGraphDeleteItemResponse.objectControllerResponse.uvcViewItemType = documentGraphDeleteItemRequest.objectControllerRequest.uvcViewItemType
        documentGraphDeleteItemResponse.objectControllerResponse.udcViewItemName = documentGraphDeleteItemRequest.objectControllerRequest.udcViewItemName!
        documentGraphDeleteItemResponse.objectControllerResponse.udcViewItemId = documentGraphDeleteItemRequest.objectControllerRequest.udcViewItemId!
        documentGraphDeleteItemResponse.objectControllerResponse.editMode = documentGraphDeleteItemRequest.objectControllerRequest.editMode
        documentGraphDeleteItemResponse.objectControllerResponse.viewConfigPathIdName.append(contentsOf: documentGraphDeleteItemRequest.objectControllerRequest.viewConfigPathIdName)
        
        // Remove choice items if any
        var removeItem: Bool = false
        var removeItemIndex: Int = 0
        var removeSentenceReference = [UDCSentenceReference]()
        var viewItemName = ""
        for (udcspgvIndex, udcspgv) in udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphDeleteItemRequest.sentenceIndex].udcSentencePatternDataGroupValue.enumerated() {
            if udcspgvIndex == documentGraphDeleteItemRequest.itemIndex && ((udcspgv.uvcViewItemType == "UVCViewItemType.Text" && udcspgv.groupUVCViewItemType == "UVCViewItemType.Choice") || (udcspgv.groupUVCViewItemType == "UVCViewItemType.Sentence")) {
                
                if udcspgv.groupUVCViewItemType == "UVCViewItemType.Choice" {
                    for (udcChoiceIndex, udcChoice) in udcDocumentGraphModel.udcViewItemCollection.udcChoice.enumerated() {
                        if udcChoice.name == udcspgv.udcViewItemName {
                            viewItemName = udcChoice.name
                            for (udcChoiceItemIndex, udcChoiceItem) in udcChoice.udcChoiceItem.enumerated() {
                                if documentGraphDeleteItemRequest.itemIndex >= udcChoiceItem.udcSentenceReference.startItemIndex &&
                                    documentGraphDeleteItemRequest.itemIndex <= udcChoiceItem.udcSentenceReference.endItemIndex &&
                                    documentGraphDeleteItemRequest.sentenceIndex >= udcChoiceItem.udcSentenceReference.startSentenceIndex &&
                                    documentGraphDeleteItemRequest.sentenceIndex <= udcChoiceItem.udcSentenceReference.endSentenceIndex {
                                    let count = udcChoiceItem.udcSentenceReference.endItemIndex - udcChoiceItem.udcSentenceReference.startItemIndex + 1
                                    if count > 1 {
                                        udcChoiceItem.udcSentenceReference.endItemIndex -= 1
                                    } else {
                                        removeItem = true
                                        removeItemIndex = udcChoiceItemIndex
                                    }
                                    // If inserted in middle update the indexes of those following it
                                    if udcChoiceItemIndex < udcChoice.udcChoiceItem.count - 1 {
                                        for index in udcChoiceItemIndex + 1...udcChoice.udcChoiceItem.count - 1 {
                                            udcChoice.udcChoiceItem[index].udcSentenceReference.startItemIndex -= 1
                                            udcChoice.udcChoiceItem[index].udcSentenceReference.endItemIndex -= 1
                                        }
                                    }
                                    break
                                }
                            }
                            if removeItem {
                                udcChoice.udcChoiceItem.remove(at: removeItemIndex)
                            }
                            if udcChoice.udcChoiceItem.count == 0 {
                                removeItem = true
                                removeItemIndex = udcChoiceIndex
                            }
                        }
                        if removeItem {
                            removeItem = false
                            udcDocumentGraphModel.udcViewItemCollection.udcChoice.remove(at: removeItemIndex)
                            documentGraphDeleteItemResponse.objectControllerResponse.udcViewItemName = ""
                            documentGraphDeleteItemResponse.objectControllerResponse.uvcViewItemType = "UVCViewItemType.Text"
                            documentGraphDeleteItemResponse.objectControllerResponse.udcViewItemId = ""
                        }
                    }
                } else if udcspgv.groupUVCViewItemType == "UVCViewItemType.Sentence" {
                    var removeIndexArray = [Int]()
                    var removeSentenceReference = [UDCSentenceReference]()
                    for (udcSentenceReferenceIndex, udcSentenceReference) in udcDocumentGraphModel.udcViewItemCollection.udcSentenceReference.enumerated() {
                        if udcSentenceReference.name == udcspgv.udcViewItemName {
                            if documentGraphDeleteItemRequest.itemIndex == udcSentenceReference.startItemIndex {
                                removeIndexArray.append(udcSentenceReferenceIndex)
                                removeSentenceReference.append(udcSentenceReference)
                                break
                            } else {
                                if documentGraphDeleteItemRequest.itemIndex >= udcSentenceReference.startItemIndex &&
                                    documentGraphDeleteItemRequest.itemIndex <= udcSentenceReference.endItemIndex &&
                                    documentGraphDeleteItemRequest.sentenceIndex >= udcSentenceReference.startSentenceIndex &&
                                    documentGraphDeleteItemRequest.sentenceIndex <= udcSentenceReference.endSentenceIndex {
                                    let count = udcSentenceReference.endItemIndex - udcSentenceReference.startItemIndex + 1
                                    if count > 1 {
                                        udcSentenceReference.endItemIndex -= 1
                                    } else {
                                        removeItem = true
                                        removeItemIndex = udcSentenceReferenceIndex
                                    }
                                    // If inserted in middle update the indexes of those following it
                                    if udcSentenceReferenceIndex < udcDocumentGraphModel.udcViewItemCollection.udcSentenceReference.count - 1 {
                                        for index in udcSentenceReferenceIndex + 1...udcDocumentGraphModel.udcViewItemCollection.udcSentenceReference.count - 1 {
                                            udcDocumentGraphModel.udcViewItemCollection.udcSentenceReference[index].startItemIndex -= 1
                                            udcDocumentGraphModel.udcViewItemCollection.udcSentenceReference[index].endItemIndex -= 1
                                        }
                                    }
                                    break
                                }
                            }
                        }
                    }
                    if removeIndexArray.count > 0 {
                        for udcsr in removeSentenceReference {
                            for sentenceIndex in udcsr.startSentenceIndex...udcsr.endSentenceIndex {
                                
                                for itemIndex in udcsr.startItemIndex...udcsr.endItemIndex {
                                    if udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[sentenceIndex].udcSentencePatternDataGroupValue[udcsr.startItemIndex].uvcViewItemType == "UVCViewItemType.Photo" && !udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[sentenceIndex].udcSentencePatternDataGroupValue[udcsr.startItemIndex].itemId.isEmpty {
                                        
                                        try removePhoto(id: udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[sentenceIndex].udcSentencePatternDataGroupValue[udcsr.startItemIndex].itemId, udcDocumentTypeIdName: documentGraphDeleteItemRequest.udcDocumentTypeIdName, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
                                        
                                    }
                                    
                                    udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[sentenceIndex].udcSentencePatternDataGroupValue.remove(at: udcsr.startItemIndex)
                                    let documentItemViewDeleteData = DocumentGraphItemViewData()
                                    documentItemViewDeleteData.treeLevel = documentGraphDeleteItemRequest.treeLevel
                                    documentItemViewDeleteData.nodeIndex = documentGraphDeleteItemRequest.nodeIndex
                                    // Ignore search box
                                    if itemIndex >= udcsr.startItemIndex + 1 {
                                        documentItemViewDeleteData.itemIndex = udcsr.startItemIndex + 1
                                    } else {
                                        documentItemViewDeleteData.itemIndex = udcsr.startItemIndex
                                    }
                                    documentItemViewDeleteData.sentenceIndex = sentenceIndex
                                    documentItemViewDeleteData.uvcDocumentGraphModel._id = udcDocumentGraphModel._id
                                    documentGraphDeleteItemResponse.documentItemViewDeleteData.append(documentItemViewDeleteData)
                                }
                            }
                        }
                        for index in removeIndexArray {
                            udcDocumentGraphModel.udcViewItemCollection.udcSentenceReference.remove(at: index)
                        }
                    }
                    if removeItem {
                        udcDocumentGraphModel.udcViewItemCollection.udcSentenceReference.remove(at: removeItemIndex)
                    }
                }
            } else if udcspgvIndex == documentGraphDeleteItemRequest.itemIndex && ((udcspgv.uvcViewItemType == "UVCViewItemType.Choice" && udcspgv.groupUVCViewItemType == "UVCViewItemType.Choice") || (udcspgv.uvcViewItemType == "UVCViewItemType.Sentence" && udcspgv.groupUVCViewItemType == "UVCViewItemType.Sentence")) {
                var removeIndexArray = [Int]()
                var removeItemIndexArray = [Int]()
                if udcspgv.groupUVCViewItemType == "UVCViewItemType.Choice" {
                    for (udcChoiceIndex, udcChoice) in udcDocumentGraphModel.udcViewItemCollection.udcChoice.enumerated() {
                        if udcChoice.name == udcspgv.udcViewItemName {
                            
                            for (udcChoiceItemIndex, udcChoiceItem) in udcChoice.udcChoiceItem.enumerated() {
                                if documentGraphDeleteItemRequest.itemIndex >= udcChoiceItem.udcSentenceReference.startItemIndex &&
                                    documentGraphDeleteItemRequest.itemIndex <= udcChoiceItem.udcSentenceReference.endItemIndex &&
                                    documentGraphDeleteItemRequest.sentenceIndex >= udcChoiceItem.udcSentenceReference.startSentenceIndex &&
                                    documentGraphDeleteItemRequest.sentenceIndex <= udcChoiceItem.udcSentenceReference.endSentenceIndex {
                                    removeItemIndexArray.append(udcChoiceItemIndex)
                                    removeSentenceReference.append(udcChoiceItem.udcSentenceReference)
                                    let decrement = udcChoiceItem.udcSentenceReference.endItemIndex - udcChoiceItem.udcSentenceReference.startItemIndex + 1
                                    // If inserted in middle update the indexes of those following it
                                    if udcChoiceItemIndex < udcChoice.udcChoiceItem.count - 1 {
                                        for index in udcChoiceItemIndex + 1...udcChoice.udcChoiceItem.count - 1 {
                                            udcChoice.udcChoiceItem[index].udcSentenceReference.startItemIndex -= decrement
                                            udcChoice.udcChoiceItem[index].udcSentenceReference.endItemIndex -= decrement
                                        }
                                    }
                                    break
                                }
                            }
                            for index in removeItemIndexArray {
                                udcChoice.udcChoiceItem.remove(at: index)
                            }
                            if udcChoice.udcChoiceItem.count == 0 {
                                removeItem = true
                            }
                        }
                        if removeItem {
                            removeItem = false
                            removeIndexArray.append(udcChoiceIndex)
                        }
                    }
                    
                    
                    for udcsr in removeSentenceReference {
                        for sentenceIndex in udcsr.startSentenceIndex...udcsr.endSentenceIndex {
                            
                            for itemIndex in udcsr.startItemIndex...udcsr.endItemIndex {
                                
                                if udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[sentenceIndex].udcSentencePatternDataGroupValue[itemIndex].uvcViewItemType == "UVCViewItemType.Photo" && !udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[sentenceIndex].udcSentencePatternDataGroupValue[itemIndex].itemId.isEmpty {
                                    
                                    try removePhoto(id: udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[sentenceIndex].udcSentencePatternDataGroupValue[itemIndex].itemId, udcDocumentTypeIdName: documentGraphDeleteItemRequest.udcDocumentTypeIdName, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
                                    
                                }
                                udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[sentenceIndex].udcSentencePatternDataGroupValue.remove(at: udcsr.startItemIndex)
                                let documentItemViewDeleteData = DocumentGraphItemViewData()
                                documentItemViewDeleteData.treeLevel = documentGraphDeleteItemRequest.treeLevel
                                documentItemViewDeleteData.nodeIndex = documentGraphDeleteItemRequest.nodeIndex
                                // Ignore search box
                                if itemIndex >= udcsr.startItemIndex + 1 {
                                    documentItemViewDeleteData.itemIndex = udcsr.startItemIndex + 1
                                } else {
                                    documentItemViewDeleteData.itemIndex = udcsr.startItemIndex
                                }
                                documentItemViewDeleteData.sentenceIndex = sentenceIndex
                                documentItemViewDeleteData.uvcDocumentGraphModel._id = udcDocumentGraphModel._id
                                documentGraphDeleteItemResponse.documentItemViewDeleteData.append(documentItemViewDeleteData)
                            }
                        }
                    }
                    
                    for index in removeIndexArray {
                        udcDocumentGraphModel.udcViewItemCollection.udcChoice.remove(at: index)
                    }
                    if udcDocumentGraphModel.udcViewItemCollection.udcChoice.count == 0 {
                        documentGraphDeleteItemResponse.objectControllerResponse.udcViewItemName = ""
                        documentGraphDeleteItemResponse.objectControllerResponse.udcViewItemId = ""
                    }
                    
                    break
                } else if udcspgv.groupUVCViewItemType == "UVCViewItemType.Sentence" {
                    for (udcSentenceReferenceIndex, udcSentenceReference) in udcDocumentGraphModel.udcViewItemCollection.udcSentenceReference.enumerated() {
                        if udcSentenceReference.name == udcspgv.udcViewItemName {
                            if documentGraphDeleteItemRequest.itemIndex >= udcSentenceReference.startItemIndex &&
                                documentGraphDeleteItemRequest.itemIndex <= udcSentenceReference.endItemIndex &&
                                documentGraphDeleteItemRequest.sentenceIndex >= udcSentenceReference.startSentenceIndex &&
                                documentGraphDeleteItemRequest.sentenceIndex <= udcSentenceReference.endSentenceIndex {
                                removeItemIndexArray.append(udcSentenceReferenceIndex)
                                removeSentenceReference.append(udcSentenceReference)
                                let decrement = udcSentenceReference.endItemIndex - udcSentenceReference.startItemIndex + 1
                                // If inserted in middle update the indexes of those following it
                                if udcSentenceReferenceIndex < udcDocumentGraphModel.udcViewItemCollection.udcSentenceReference.count - 1 {
                                    for index in udcSentenceReferenceIndex + 1...udcDocumentGraphModel.udcViewItemCollection.udcSentenceReference.count - 1 {
                                        udcDocumentGraphModel.udcViewItemCollection.udcSentenceReference[index].startItemIndex -= decrement
                                        udcDocumentGraphModel.udcViewItemCollection.udcSentenceReference[index].endItemIndex -= decrement
                                    }
                                }
                                break
                            }
                        }
                    }
                    
                    for udcsr in removeSentenceReference {
                        for sentenceIndex in udcsr.startSentenceIndex...udcsr.endSentenceIndex {
                            
                            for itemIndex in udcsr.startItemIndex...udcsr.endItemIndex {
                                
                                if udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[sentenceIndex].udcSentencePatternDataGroupValue[itemIndex].uvcViewItemType == "UVCViewItemType.Photo" && !udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[sentenceIndex].udcSentencePatternDataGroupValue[itemIndex].itemId.isEmpty {
                                    
                                    try removePhoto(id: udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[sentenceIndex].udcSentencePatternDataGroupValue[itemIndex].itemId, udcDocumentTypeIdName: documentGraphDeleteItemRequest.udcDocumentTypeIdName, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
                                    
                                }
                                udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[sentenceIndex].udcSentencePatternDataGroupValue.remove(at: udcsr.startItemIndex)
                                let documentItemViewDeleteData = DocumentGraphItemViewData()
                                documentItemViewDeleteData.treeLevel = documentGraphDeleteItemRequest.treeLevel
                                documentItemViewDeleteData.nodeIndex = documentGraphDeleteItemRequest.nodeIndex
                                // Ignore search box
                                if itemIndex >= udcsr.startItemIndex + 1 {
                                    documentItemViewDeleteData.itemIndex = udcsr.startItemIndex + 1
                                } else {
                                    documentItemViewDeleteData.itemIndex = udcsr.startItemIndex
                                }
                                documentItemViewDeleteData.sentenceIndex = sentenceIndex
                                documentItemViewDeleteData.uvcDocumentGraphModel._id = udcDocumentGraphModel._id
                                documentGraphDeleteItemResponse.documentItemViewDeleteData.append(documentItemViewDeleteData)
                            }
                        }
                    }
                    
                    for index in removeIndexArray {
                        udcDocumentGraphModel.udcViewItemCollection.udcSentenceReference.remove(at: index)
                    }
                    if udcDocumentGraphModel.udcViewItemCollection.udcSentenceReference.count == 0 {
                        documentGraphDeleteItemResponse.objectControllerResponse.udcViewItemName = ""
                        documentGraphDeleteItemResponse.objectControllerResponse.udcViewItemId = ""
                    }
                }
            }
            
        }
        
        var textStartIndex = 0
        
        if documentGraphDeleteItemRequest.udcDocumentTypeIdName == "UDCDocumentType.DocumentItem" {
            for udcspdgv in udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue {
                if udcspdgv.itemIdName == "UDCDocumentItem.TranslationSeparator" {
                    break
                }
                textStartIndex += 1
            }
        }
        
        if documentGraphDeleteItemResponse.documentItemViewDeleteData.count == 0 {
            if udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphDeleteItemRequest.sentenceIndex].udcSentencePatternDataGroupValue[documentGraphDeleteItemRequest.itemIndex].udcDocumentItemGraphReferenceTarget.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "CannotDeleteReferedSomeWhere", description: "Cannot Delete! Refered some where!"))
                return
            } else if udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphDeleteItemRequest.sentenceIndex].udcSentencePatternDataGroupValue[documentGraphDeleteItemRequest.itemIndex].udcDocumentItemGraphReferenceSource.count > 0 {
                for udcdigrs in udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphDeleteItemRequest.sentenceIndex].udcSentencePatternDataGroupValue[documentGraphDeleteItemRequest.itemIndex].udcDocumentItemGraphReferenceSource {
                    let databaseOrmResultudcDocumentGraphModelSource = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphDeleteItemRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcdigrs.nodeId, language: documentLanguage) as DatabaseOrmResult<UDCDocumentGraphModel>
                    if databaseOrmResultudcDocumentGraphModelSource.databaseOrmError.count > 0 {
                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModelSource.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModelSource.databaseOrmError[0].description))
                        return
                    }
                    let udcDocumentGraphModelSource = databaseOrmResultudcDocumentGraphModelSource.object[0]
                    var removeIndex = [Int]()
                    for (udcdigrtIndex, udcdigrt) in udcDocumentGraphModelSource.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[udcdigrs.referenceSentenceIndex].udcSentencePatternDataGroupValue[udcdigrs.referenceItemIndex].udcDocumentItemGraphReferenceTarget.enumerated() {
                        if documentGraphDeleteItemRequest.itemIndex == udcdigrt.referenceItemIndex && udcdigrs.referenceSentenceIndex == documentGraphDeleteItemRequest.sentenceIndex && udcDocumentGraphModel._id == udcdigrt.nodeId {
                            removeIndex.append(udcdigrtIndex)
                        }
                    }
                    for rmIndex in removeIndex {
                        udcDocumentGraphModelSource.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[udcdigrs.referenceSentenceIndex].udcSentencePatternDataGroupValue[udcdigrs.referenceItemIndex].udcDocumentItemGraphReferenceTarget.remove(at: rmIndex)
                    }
                    let databaseOrmResultudcDocumentGraphModelSave = UDCDocumentGraphModel.update(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphDeleteItemRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentGraphModelSource) as DatabaseOrmResult<UDCDocumentGraphModel>
                    if databaseOrmResultudcDocumentGraphModelSave.databaseOrmError.count > 0 {
                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModelSave.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModelSave.databaseOrmError[0].description))
                        return
                    }
                }
            }
            
            // If any reference position is changing then do it in source
            for (udcspdgvIndex, udcspdgv) in udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphDeleteItemRequest.sentenceIndex].udcSentencePatternDataGroupValue.enumerated() {
                // Check for positional changes
                if udcspdgv.udcDocumentItemGraphReferenceSource.count > 0 {
                    if documentGraphDeleteItemRequest.itemIndex < udcspdgvIndex {
                        for udcdigrs in udcspdgv.udcDocumentItemGraphReferenceSource {
                            let databaseOrmResultudcDocumentGraphModel1 = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphDeleteItemRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcdigrs.nodeId, language: documentLanguage)
                            if databaseOrmResultudcDocumentGraphModel1.databaseOrmError.count > 0 {
                                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModel1.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModel1.databaseOrmError[0].description))
                                return
                            }
                            let udcDocumentGraphModelSource = databaseOrmResultudcDocumentGraphModel1.object[0]
                            
                            // Update the reference of the source to plus 1, since position changed
                            for (udcdigrtIndex, udcdigrt) in udcDocumentGraphModelSource.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[udcdigrs.referenceSentenceIndex].udcSentencePatternDataGroupValue[udcdigrs.referenceItemIndex].udcDocumentItemGraphReferenceTarget.enumerated() {
                                if udcdigrt.nodeId == udcDocumentGraphModel._id && udcdigrt.referenceItemIndex == udcspdgvIndex && udcdigrt.referenceSentenceIndex == documentGraphDeleteItemRequest.sentenceIndex {
                                    // Reference index change model is same as inserted model, so put changes there also
                                    if udcDocumentGraphModelSource._id == documentGraphDeleteItemRequest.nodeId { udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[udcdigrs.referenceSentenceIndex].udcSentencePatternDataGroupValue[udcdigrs.referenceItemIndex].udcDocumentItemGraphReferenceTarget[udcdigrtIndex].referenceItemIndex -= 1
                                    }
                                    udcdigrt.referenceItemIndex -= 1
                                }
                            }
                            
                            // Update back
                            udcDocumentGraphModelSource.udcDocumentTime.changedBy = profileId
                            udcDocumentGraphModelSource.udcDocumentTime.changedTime = Date()
                            let databaseOrmResultudcDocumentGraphModelUpdate = UDCDocumentGraphModel.update(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphDeleteItemRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentGraphModelSource)
                            if databaseOrmResultudcDocumentGraphModelUpdate.databaseOrmError.count > 0 {
                                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModelUpdate.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModelUpdate.databaseOrmError[0].description))
                                return
                            }
                        }
                    }
                }
            }
            
            if udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphDeleteItemRequest.sentenceIndex].udcSentencePatternDataGroupValue[documentGraphDeleteItemRequest.itemIndex].uvcViewItemType == "UVCViewItemType.Photo" && !udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphDeleteItemRequest.sentenceIndex].udcSentencePatternDataGroupValue[documentGraphDeleteItemRequest.itemIndex].itemId.isEmpty {
                
                if documentGraphDeleteItemRequest.udcDocumentTypeIdName != "UDCDocumentType.DocumentItem" {
                    try removePhoto(id: udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphDeleteItemRequest.sentenceIndex].udcSentencePatternDataGroupValue[documentGraphDeleteItemRequest.itemIndex].itemId, udcDocumentTypeIdName: documentGraphDeleteItemRequest.udcDocumentTypeIdName, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
                }
                
            }
            
            // Reduce the used count if it is an document item
            if udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphDeleteItemRequest.sentenceIndex].udcSentencePatternDataGroupValue[documentGraphDeleteItemRequest.itemIndex].itemIdName.hasPrefix("UDCDocumentItem.") {
                let itemId =  udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphDeleteItemRequest.sentenceIndex].udcSentencePatternDataGroupValue[documentGraphDeleteItemRequest.itemIndex].itemId
                try removeReference(udcDocumentGraphModelId: itemId, udcDocumentTypeIdName: "UDCDocumentType.DocumentItem", objectId: udcDocumentGraphModel._id, documentLanguage: documentLanguage, udcProfile: documentGraphDeleteItemRequest.udcProfile, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
//                let databaseOrmResultUsedCountGet = UDCDocumentGraphModel.get(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, id: itemId)
//                let udcDocumentItemUsedCount = databaseOrmResultUsedCountGet.object[0]
//                var removeIndex = [Int]()
//                for (referenceIndex, reference) in udcDocumentItemUsedCount.udcDocumentGraphModelReference.enumerated() {
//                    if reference.objectId == udcDocumentGraphModel._id {
//                        removeIndex.append(referenceIndex)
//                        break // Breaks so that only one reference is removed as per one delete
//                    }
//                }
//                for rIndex in removeIndex {
//                    udcDocumentItemUsedCount.udcDocumentGraphModelReference.remove(at: rIndex)
//                }
//                udcDocumentItemUsedCount.udcDocumentTime.changedBy = documentParser.getUDCProfile(udcProfile: documentGraphDeleteItemRequest.udcProfile, idName: "UDCProfileItem.Human")
//                udcDocumentItemUsedCount.udcDocumentTime.changedTime = Date()
//                let databaseOrmResultUsedCountUpdate = UDCDocumentGraphModel.update(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentItemUsedCount)
//                if databaseOrmResultUsedCountUpdate.databaseOrmError.count > 0 {
//                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUsedCountUpdate.databaseOrmError[0].name, description: databaseOrmResultUsedCountUpdate.databaseOrmError[0].description))
//                    return
//                }
            }

            // Remove the item
            // If more than two values in current sentence
            if udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphDeleteItemRequest.sentenceIndex].udcSentencePatternDataGroupValue.count > 0 { udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphDeleteItemRequest.sentenceIndex].udcSentencePatternDataGroupValue.remove(at: documentGraphDeleteItemRequest.itemIndex)
            } else { // If zero values in current sentence
                var groupIndex = udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup.count - 1
                
                udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup.remove(at: groupIndex)
                groupIndex = udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup.count - 1
                
                let deleteIndex = udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[groupIndex].udcSentencePatternDataGroupValue.count - 1
                udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[groupIndex].udcSentencePatternDataGroupValue.remove(at: deleteIndex)
                documentGraphDeleteItemRequest.itemIndex = deleteIndex - 1
                documentGraphDeleteItemRequest.sentenceIndex = groupIndex
            }
            
            
            // If current sentence has no words
            if udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup.count > 1 && udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphDeleteItemRequest.sentenceIndex].udcSentencePatternDataGroupValue.count == 0 {
                udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup.remove(at: documentGraphDeleteItemRequest.sentenceIndex)
                // Remove "."
                udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphDeleteItemRequest.sentenceIndex - 1].udcSentencePatternDataGroupValue.remove(at: udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphDeleteItemRequest.sentenceIndex - 1].udcSentencePatternDataGroupValue.count - 1)
                // Decrement sentence index
                documentGraphDeleteItemRequest.sentenceIndex = documentGraphDeleteItemRequest.sentenceIndex - 1
                udcDocumentGraphModel.name = ""
                
            } else {
                udcDocumentGraphModel.udcSentencePattern = try processGrammar(neuronRequest: neuronRequest, neuronResponse: &neuronResponse, udcSentencePattern: udcDocumentGraphModel.udcSentencePattern, newSentence: false, wordIndex: documentGraphDeleteItemRequest.itemIndex, sentenceIndex: documentGraphDeleteItemRequest.sentenceIndex, documentLanguage: documentLanguage, textStartIndex: textStartIndex)
                udcDocumentGraphModel.name = udcDocumentGraphModel.udcSentencePattern.sentence
                
            }
        } else {
            udcDocumentGraphModel.udcSentencePattern = try processGrammar(neuronRequest: neuronRequest, neuronResponse: &neuronResponse, udcSentencePattern: udcDocumentGraphModel.udcSentencePattern, newSentence: false, wordIndex: documentGraphDeleteItemRequest.itemIndex, sentenceIndex: documentGraphDeleteItemRequest.sentenceIndex, documentLanguage: documentLanguage, textStartIndex: textStartIndex)
            udcDocumentGraphModel.name = udcDocumentGraphModel.udcSentencePattern.sentence
        }
        // Get the new grammar
//        if documentGraphDeleteItemRequest.udcDocumentTypeIdName == "UDCDocumentType.DocumentItem" && udcDocumentGraphModel.level > 1 {
            
//        }
        
        
        let getDocumentGraphIdNameRequest = GetDocumentGraphIdNameRequest()
        getDocumentGraphIdNameRequest.udcDocumentGraphModel = udcDocumentGraphModel
        getDocumentGraphIdNameRequest.udcDocumentTypeIdName = documentGraphDeleteItemRequest.udcDocumentTypeIdName
        getDocumentGraphIdNameRequest.documentLanguage = documentGraphDeleteItemRequest.documentLanguage
        var getDocumentGraphIdNameResponse = GetDocumentGraphIdNameResponse()
        if try isNeuronProcessingIt(operationName: "DocumentGraphNeuron.Document.Type.Process.idName.Generated", udcDocumentTypeIdName: documentGraphDeleteItemRequest.udcDocumentTypeIdName, neuronRequest: neuronRequest, neuronResponse: &neuronResponse) {
            var neuronRequestLocal1 = neuronRequest
            let jsonUtilityGetDocumentGraphIdNameRequest = JsonUtility<GetDocumentGraphIdNameRequest>()
            let jsonDocumentGetDocumentGraphIdNameRequest = jsonUtilityGetDocumentGraphIdNameRequest.convertAnyObjectToJson(jsonObject: getDocumentGraphIdNameRequest)
            neuronRequestLocal1.neuronOperation.neuronData.text = jsonDocumentGetDocumentGraphIdNameRequest
            var called = try callNeuron(neuronRequest: neuronRequestLocal1, neuronResponse: &neuronResponse, operationName: "DocumentGraphNeuron.Document.IdName", udcDocumentTypeIdName: documentGraphDeleteItemRequest.udcDocumentTypeIdName)
            getDocumentGraphIdNameResponse = neuronUtility!.getNeuronRequest(json: neuronResponse.neuronOperation.neuronData.text, object: GetDocumentGraphIdNameResponse())
        } else {
            try getDocumentIdName(getDocumentGraphIdNameRequest: getDocumentGraphIdNameRequest, getDocumentGraphIdNameResponse: &getDocumentGraphIdNameResponse, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        }
        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
            return
        }
        
        
        udcDocumentGraphModel.idName = getDocumentGraphIdNameResponse.idName
        udcDocumentGraphModel.name = getDocumentGraphIdNameResponse.name
        
        
        var prevNameSplit = documentParser.splitDocumentItem(udcSentencePatternDataGroupValueParam: prevUdcSentencePatternDataGroupValue, language: documentLanguage)
        if prevNameSplit.count == 0 {
            prevNameSplit.append("")
        }
        let nameSplit = documentParser.splitDocumentItem(udcSentencePatternDataGroupValueParam: udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue, language: documentLanguage)
        var nameIndexLocal = 0
        var nameLocal = udcDocumentGraphModel.name
        
        if prevNameSplit.count == nameSplit.count {
            for (nameIndex, name) in prevNameSplit.enumerated() {
                if name != nameSplit[nameIndex] {
                    nameIndexLocal = nameIndex
                    nameLocal = nameSplit[nameIndex]
                    break
                }
            }
        }
        if !udcDocumentGraphModel.name.isEmpty && !udcDocumentGraphModel.udcDocumentGraphModelReferenceId.isEmpty {

            let udcSentencePatternDataGroupValueLocalFind = UDCSentencePatternDataGroupValue()
            let udcDocumentGraphModelParent = try getDocumentModel(udcDocumentGraphModelId: udcDocumentGraphModel.parentId[0], udcDocumentTypeIdName: documentGraphDeleteItemRequest.udcDocumentTypeIdName, isLanguageChild: false, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            if udcDocumentGraphModelParent!.parentId.count > 0 {
                let databaseOrmResultParentParent = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphDeleteItemRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: (udcDocumentGraphModelParent?.parentId[0])!)
                let udcDocumentGraphModelParentParent = databaseOrmResultParentParent.object[0]
                udcSentencePatternDataGroupValueLocalFind.endCategoryIdName = udcDocumentGraphModelParentParent.idName
                udcSentencePatternDataGroupValueLocalFind.endCategoryId = udcDocumentGraphModelParentParent._id
                udcSentencePatternDataGroupValueLocalFind.endSubCategoryId = udcDocumentGraphModelParent!._id
                udcSentencePatternDataGroupValueLocalFind.endSubCategoryIdName = udcDocumentGraphModelParent!.idName
            } else {
                udcSentencePatternDataGroupValueLocalFind.endCategoryIdName = udcDocumentGraphModelParent!.idName
                udcSentencePatternDataGroupValueLocalFind.endCategoryId = udcDocumentGraphModelParent!._id
            }
            udcSentencePatternDataGroupValueLocalFind.itemId = udcDocumentGraphModel._id
            udcSentencePatternDataGroupValueLocalFind.itemIdName = prevIdName
            
            let udcSentencePatternDataGroupValueLocalReplace = UDCSentencePatternDataGroupValue()
            udcSentencePatternDataGroupValueLocalReplace.item = nameLocal
            udcSentencePatternDataGroupValueLocalReplace.itemIdName = udcDocumentGraphModel.idName
            // If it is title, then same as the one changed
            if udcDocumentGraphModel.level == 1 {
                udcSentencePatternDataGroupValueLocalReplace.endCategoryIdName = udcDocumentGraphModel.idName
            }
            udcSentencePatternDataGroupValueLocalReplace.itemNameIndex = nameIndexLocal
            udcSentencePatternDataGroupValueLocalFind.itemNameIndex = nameIndexLocal
            var found = false
            try replaceDocumentItemInAllReferedDoc(referenceId: udcDocumentGraphModel.udcDocumentGraphModelReferenceId, referenceObjectName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphDeleteItemRequest.udcDocumentTypeIdName)!, find: udcSentencePatternDataGroupValueLocalFind, replace: udcSentencePatternDataGroupValueLocalReplace, found: &found, udcSentencePatternGroupValue: udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue, replaceFull: false, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
                        
        }
       
        
        // If child still there, then put the removal changes in database
        
        var documentTypeProcessRequest = DocumentGraphTypeProcessRequest()
        documentTypeProcessRequest.udcDocuemntGraphModel = udcDocumentGraphModel
        documentTypeProcessRequest.udcDocumentTypeIdName = documentGraphDeleteItemRequest.udcDocumentTypeIdName
        documentTypeProcessRequest.udcDocumentModelId = udcDocument.udcDocumentGraphModelId
        documentTypeProcessRequest.nodeIndex = documentGraphDeleteItemRequest.nodeIndex
        var neuronRequestLocal1 = neuronRequest
        var jsonUtilityDocumentTypeProcessRequest = JsonUtility<DocumentGraphTypeProcessRequest>()
        var jsonDocumentGetSentencePatternForDocumentItemRequest = jsonUtilityDocumentTypeProcessRequest.convertAnyObjectToJson(jsonObject: documentTypeProcessRequest)
        neuronRequestLocal1.neuronOperation.neuronData.text = jsonDocumentGetSentencePatternForDocumentItemRequest
        var called = try callNeuron(neuronRequest: neuronRequestLocal1, neuronResponse: &neuronResponse, operationName: "DocumentGraphNeuron.Document.Type.Process.Post", udcDocumentTypeIdName: documentGraphDeleteItemRequest.udcDocumentTypeIdName)
        
        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
            return
        }
        
        var documentTypeProcessResponse = DocumentGraphTypeProcessResponse()
        
        if called {
            documentTypeProcessResponse = neuronUtility!.getNeuronRequest(json: neuronResponse.neuronOperation.neuronData.text, object: DocumentGraphTypeProcessResponse())
        } else {
            if documentGraphDeleteItemRequest.nodeIndex == 0 {
                documentTypeProcessResponse.udcSentencePatternUniqueDocumentTitle = udcDocumentGraphModel.udcSentencePattern
            }/* else if documentGraphDeleteItemRequest.nodeIndex == 1 {
                documentTypeProcessResponse.udcSentencePatternDocumentTitle = udcDocumentGraphModel.udcSentencePattern
            }*/
        }
        
//        if documentTypeProcessResponse.udcSentencePatternUniqueDocumentTitle.udcSentencePatternData.count > 0 {
//            let idName: String = "UDCDocument.\(getDocumentGraphIdNameResponse.idName.split(separator: ".")[1])"
//            if udcDocument.idName != idName {
//                var udcDocumentUpdated: Bool = false
//                try updateIdName(name: "title", fromIdName: udcDocument.idName, fromDocumentIdName: udcDocument.idName, toIdName: getDocumentGraphIdNameResponse.idName, toDocumentIdName: idName, toTitle: "", toSentencePattern: documentTypeProcessResponse.udcSentencePatternUniqueDocumentTitle, udcProfile: documentGraphDeleteItemRequest.udcProfile, udcDocument: udcDocument, udcDocumentTypeIdName: documentGraphDeleteItemRequest.udcDocumentTypeIdName, documentLanguage: documentLanguage, udcDocumentUpdated: &udcDocumentUpdated, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
//            }
//        } else if documentTypeProcessResponse.udcSentencePatternDocumentTitle.udcSentencePatternData.count > 0 {
//            let documentTitle = documentTypeProcessResponse.udcSentencePatternDocumentTitle.sentence
//            let databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: documentGraphDeleteItemRequest.documentId, language: documentLanguage)
//            if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
//                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocument.databaseOrmError[0].name, description: databaseOrmResultUDCDocument.databaseOrmError[0].description))
//                return
//            }
//            let udcDocument = databaseOrmResultUDCDocument.object[0]
//            let previousTitle = udcDocument.name
//            if documentGraphDeleteItemRequest.udcDocumentTypeIdName == "UDCDocumentType.InterfaceBar" {
//                let idName: String = "UDCInterfaceBar.\(documentTitle.capitalized.replacingOccurrences(of: " ", with: ""))"
//                let previousIdName = "UDCInterfaceBar.\(previousTitle.capitalized.replacingOccurrences(of: " ", with: ""))"
//                UDCApplicationInterfaceBar.remove(udbcDatabaseOrm: udbcDatabaseOrm!, udcInterfaceBarId: udcDocumentGraphModel._id, udcInterfaceBarIdName: previousIdName, upcCompanyProfileId: documentGraphDeleteItemRequest.upcCompanyProfileId, upcApplicationProfileId: documentGraphDeleteItemRequest.upcApplicationProfileId, language: documentLanguage) as DatabaseOrmResult<UDCApplicationInterfaceBar>
//                let databaseOrmResultUDCApplicationInterfaceBarGet = UDCApplicationInterfaceBar.get(udcInterfaceBarId: udcDocumentGraphModel._id, udcInterfaceBarIdName: idName, upcCompanyProfileId: documentGraphDeleteItemRequest.upcCompanyProfileId, upcApplicationProfileId: documentGraphDeleteItemRequest.upcApplicationProfileId, udbcDatabaseOrm!, documentLanguage)
//                if databaseOrmResultUDCApplicationInterfaceBarGet.databaseOrmError.count > 0 {
//                    let udcApplicationInterfaceBar = UDCApplicationInterfaceBar()
//                    udcApplicationInterfaceBar._id = try (udbcDatabaseOrm?.generateId())!
//                    udcApplicationInterfaceBar.upcCompanyProfileId = documentGraphDeleteItemRequest.upcCompanyProfileId
//                    udcApplicationInterfaceBar.upcApplicationProfileId = documentGraphDeleteItemRequest.upcApplicationProfileId
//                    udcApplicationInterfaceBar.udcInterfaceBarId = udcDocumentGraphModel._id
//                    udcApplicationInterfaceBar.udcInterfaceBarIdName = idName
//                    udcApplicationInterfaceBar.language = documentLanguage
//                    let databaseOrmResultUDCApplicationInterfaceBar = UDCApplicationInterfaceBar.save(udbcDatabaseOrm: udbcDatabaseOrm!, object: udcApplicationInterfaceBar)
//                    if databaseOrmResultUDCApplicationInterfaceBar.databaseOrmError.count > 0 {
//                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCApplicationInterfaceBar.databaseOrmError[0].name, description: databaseOrmResultUDCApplicationInterfaceBar.databaseOrmError[0].description))
//                        return
//                    }
//                } else {
//                    let databaseOrmResultUDCApplicationInterfaceBar = UDCApplicationInterfaceBar.update(udbcDatabaseOrm: udbcDatabaseOrm!, udcInterfaceBarId: udcDocumentGraphModel._id, udcInterfaceBarIdName: udcDocumentGraphModel.idName, upcCompanyProfileId: documentGraphDeleteItemRequest.upcCompanyProfileId, upcApplicationProfileId: documentGraphDeleteItemRequest.upcApplicationProfileId, newUDCInterfaceBarIdName: idName,  language: documentLanguage) as DatabaseOrmResult<UDCApplicationInterfaceBar>
//                    if databaseOrmResultUDCApplicationInterfaceBar.databaseOrmError.count > 0 {
//                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCApplicationInterfaceBar.databaseOrmError[0].name, description: databaseOrmResultUDCApplicationInterfaceBar.databaseOrmError[0].description))
//                        return
//                    }
//                }
//            }
//            // Change the title of the other language docume nts
//            var udcDocumentUpdated: Bool = false
//            let prevIdNameDocument = prevIdName.replacingOccurrences(of: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphDeleteItemRequest.udcDocumentTypeIdName)!, with: "UDCDocument")
//            udcDocumentGraphModel.name = documentTitle
//            try updateIdName(name: "subTitle", fromIdName: prevIdNameDocument, fromDocumentIdName: udcDocument.idName, toIdName: udcDocumentGraphModel.idName, toDocumentIdName: "", toTitle: "", toSentencePattern: nil, udcProfile: documentGraphDeleteItemRequest.udcProfile, udcDocument: udcDocument, udcDocumentTypeIdName: documentGraphDeleteItemRequest.udcDocumentTypeIdName, documentLanguage: documentLanguage, udcDocumentUpdated: &udcDocumentUpdated, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
//
//            //        // if no more item, then remove item from parent
//            //        if udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphDeleteItemRequest.sentenceIndex].udcSentencePatternDataGroupValue.count == 0 && udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup.count == 1 {
//            //
//            //            // Remove from parent
//            //            let databaseOrmResultudcDocumentGraphModelUpdate = UDCDocumentGraphModel.updatePull(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphDeleteItemRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentGraphModel.parentId[0], childrenId: documentGraphDeleteItemRequest.nodeId) as DatabaseOrmResult<UDCDocumentGraphModel>
//            //            if databaseOrmResultudcDocumentGraphModelUpdate.databaseOrmError.count > 0 {
//            //                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModelUpdate.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModelUpdate.databaseOrmError[0].description))
//            //                return
//            //            }
//            //        }
//        }
        // Package the response
        
        let databaseOrmResultudcDocumentGraphModelSave = UDCDocumentGraphModel.update(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphDeleteItemRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentGraphModel) as DatabaseOrmResult<UDCDocumentGraphModel>
        if databaseOrmResultudcDocumentGraphModelSave.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModelSave.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModelSave.databaseOrmError[0].description))
            return
        }
        
        
        if documentGraphDeleteItemRequest.udcDocumentTypeIdName == "UDCDocumentType.DocumentItem" && udcDocumentGraphModel.level > 1 && documentGraphDeleteItemRequest.documentLanguage == "en" {
            // Get all the documents that are not in english language
            let databaseOrmResultUDCDocumentOther = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, idName: udcDocument.idName, udcProfile: documentGraphDeleteItemRequest.udcProfile, udcDocumentTypeIdName: documentGraphDeleteItemRequest.udcDocumentTypeIdName, notEqualsLanguage: "en")
            if databaseOrmResultUDCDocumentOther.databaseOrmError.count == 0 {
                let udcDocumentOther = databaseOrmResultUDCDocumentOther.object
                
                // Handle insert in those other language documents
                for udcd in udcDocumentOther {
                    // Get the document model root node
                    let databaseOrmResultudcDocumentGraphModelOther = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphDeleteItemRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcd.udcDocumentGraphModelId, language: udcd.language)
                    if databaseOrmResultudcDocumentGraphModelOther.databaseOrmError.count > 0 {
                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModelOther.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModelOther.databaseOrmError[0].description))
                        return
                    }
                    let udcDocumentGraphModelOther = databaseOrmResultudcDocumentGraphModelOther.object[0]
                    var parentFound: Bool = false
                    var foundParentModel = UDCDocumentGraphModel()
                    var foundParentId: String = ""
                    
                    // Get the english language parent node of the node to process
                    let databaseOrmResultudcDocumentGraphModelLangSpeficEnglishTitleNode = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphDeleteItemRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentGraphModel.parentId[0], language: udcDocumentGraphModel.language)
                    if databaseOrmResultudcDocumentGraphModelLangSpeficEnglishTitleNode.databaseOrmError.count > 0 {
                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModelLangSpeficEnglishTitleNode.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModelLangSpeficEnglishTitleNode.databaseOrmError[0].description))
                        return
                    }
                    let udcDocumentGraphModelLangSpeficParentNode = databaseOrmResultudcDocumentGraphModelLangSpeficEnglishTitleNode.object[0]
                    
                    // Use the parent id name and pervious node id name to search.
                    // If parent matches then change the respective children if found
                    let _ = try findAndProcessDocumentItem(mode: "delete", udcSentencePatternDataGroupValue: udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphDeleteItemRequest.sentenceIndex].udcSentencePatternDataGroupValue, parentIdName: udcDocumentGraphModelLangSpeficParentNode.idName, findIdName: prevIdName, inChildrens: udcDocumentGraphModelOther.childrenId, parentFound: &parentFound, foundParentModel: &foundParentModel, foundParentId: &foundParentId, nodeIndex: documentGraphDeleteItemRequest.nodeIndex, itemIndex: documentGraphDeleteItemRequest.itemIndex, level: documentGraphDeleteItemRequest.treeLevel, udcDocumentTypeIdName: documentGraphDeleteItemRequest.udcDocumentTypeIdName, udcProfile: documentGraphDeleteItemRequest.udcProfile, isParent: udcDocumentGraphModel.isChildrenAllowed, generatedIdName: udcDocumentGraphModel.idName,  neuronRequest: neuronRequest, neuronResponse: &neuronResponse, documentLanguage: udcd.language, addUdcSentencePatternDataGroupValue: [], addUdcViewItemCollection: UDCViewItemCollection(), addUdcSentencePatternDataGroupValueIndex: [])
                    if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
                        return
                    }
                }
            }
        }
        
        
        documentTypeProcessRequest = DocumentGraphTypeProcessRequest()
        documentTypeProcessRequest.udcDocumentModelId = udcDocument.udcDocumentGraphModelId
        documentTypeProcessRequest.documentLanguage = documentLanguage
        documentTypeProcessRequest.udcDocumentTypeIdName = documentGraphDeleteItemRequest.udcDocumentTypeIdName
        documentTypeProcessRequest.udcDocuemntGraphModel = udcDocumentGraphModel
        documentTypeProcessRequest.udcProfile = documentGraphDeleteItemRequest.udcProfile
        documentTypeProcessRequest.nodeIndex = documentGraphDeleteItemRequest.nodeIndex
        neuronRequestLocal1 = neuronRequest
        jsonUtilityDocumentTypeProcessRequest = JsonUtility<DocumentGraphTypeProcessRequest>()
        jsonDocumentGetSentencePatternForDocumentItemRequest = jsonUtilityDocumentTypeProcessRequest.convertAnyObjectToJson(jsonObject: documentTypeProcessRequest)
        neuronRequestLocal1.neuronOperation.neuronData.text = jsonDocumentGetSentencePatternForDocumentItemRequest
        called = try callNeuron(neuronRequest: neuronRequestLocal1, neuronResponse: &neuronResponse, operationName: "DocumentGraphNeuron.Document.Type.Process.Post.AfterSave", udcDocumentTypeIdName: documentGraphDeleteItemRequest.udcDocumentTypeIdName)
        
        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
            return
        }
        
        if called {
            documentTypeProcessResponse = neuronUtility!.getNeuronRequest(json: neuronResponse.neuronOperation.neuronData.text, object: DocumentGraphTypeProcessResponse())
        }
        
        
        // If not already included in group delete, then add for delete
        if documentGraphDeleteItemResponse.documentItemViewDeleteData.count == 0 {
            let documentItemViewDeleteData = DocumentGraphItemViewData()
            documentItemViewDeleteData.treeLevel = documentGraphDeleteItemRequest.treeLevel
            documentItemViewDeleteData.nodeIndex = documentGraphDeleteItemRequest.nodeIndex
            if documentGraphDeleteItemRequest.udcDocumentTypeIdName == "UDCDocumentType.DocumentItem" {
                // Need to move this code to specific neuron
                if udcDocumentGraphModelCheck.isChildrenAllowed && documentGraphDeleteItemRequest.treeLevel > 1 {
                    documentItemViewDeleteData.itemIndex = documentGraphDeleteItemRequest.itemIndex + 1
                } else {
                    documentItemViewDeleteData.itemIndex = documentGraphDeleteItemRequest.itemIndex
                }
            } else {
                documentItemViewDeleteData.itemIndex = documentGraphDeleteItemRequest.itemIndex
            }
            documentItemViewDeleteData.sentenceIndex = documentGraphDeleteItemRequest.sentenceIndex
            documentItemViewDeleteData.uvcDocumentGraphModel._id = udcDocumentGraphModel._id
            documentGraphDeleteItemResponse.documentItemViewDeleteData.append(documentItemViewDeleteData)
        }
        
        let jsonUtilityDocumentGraphChangeItemResponse = JsonUtility<DocumentGraphDeleteItemResponse>()
        let jsonDocumentGraphChangeItemResponse = jsonUtilityDocumentGraphChangeItemResponse.convertAnyObjectToJson(jsonObject: documentGraphDeleteItemResponse)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonDocumentGraphChangeItemResponse)
    }
    
    private func updateIdName(name: String, fromIdName: String, fromDocumentIdName: String, toIdName: String, toDocumentIdName: String, toTitle: String, toSentencePattern: UDCSentencePattern?, udcProfile: [UDCProfile], udcDocument: UDCDocument, udcDocumentTypeIdName: String, documentLanguage: String, udcDocumentUpdated: inout Bool, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let profileId = documentParser.getUDCProfile(udcProfile: udcProfile, idName: "UDCHumanProfileItem.Human")
        
        if name == "title" {
            let databaseOrmResultUDCDocumentLocal = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, udcProfile: udcProfile, udcDocumentTypeIdName: udcDocumentTypeIdName, idName: fromDocumentIdName)
            
            if databaseOrmResultUDCDocumentLocal.databaseOrmError.count == 0 {
                let udcDocumentToChange = databaseOrmResultUDCDocumentLocal.object
                
                for toChange in udcDocumentToChange {
                    
                    let databaseOrmResultudcDocumentGraphModelTitle = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: toChange.udcDocumentGraphModelId, language: toChange.language)
                    if databaseOrmResultudcDocumentGraphModelTitle.databaseOrmError.count > 0 {
                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModelTitle.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModelTitle.databaseOrmError[0].description))
                        return
                    }
                    let udcDocumentGraphModelTitle = databaseOrmResultudcDocumentGraphModelTitle.object[0]
                    udcDocumentGraphModelTitle.idName = toIdName
                    udcDocumentGraphModelTitle.name = toTitle
                    udcDocumentGraphModelTitle.udcSentencePattern = toSentencePattern!
                    udcDocumentGraphModelTitle.udcDocumentTime.changedBy = profileId
                    udcDocumentGraphModelTitle.udcDocumentTime.changedTime = Date()
                    let databaseOrmResultudcDocumentGraphModelChanged = UDCDocumentGraphModel.update(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentGraphModelTitle)
                    if databaseOrmResultudcDocumentGraphModelChanged.databaseOrmError.count > 0 {
                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModelChanged.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModelChanged.databaseOrmError[0].description))
                        return
                    }
                    
                    // Update id name for current language document
                    udcDocument.udcDocumentTime.changedBy = profileId
                    udcDocument.udcDocumentTime.changedTime = Date()
                    let datbaseOrmResultUDCDocumentChange = UDCDocument.update(udbcDatabaseOrm: udbcDatabaseOrm!, id: toChange._id, idName: toDocumentIdName) as DatabaseOrmResult<UDCDocument>
                    udcDocumentUpdated = true
                    if datbaseOrmResultUDCDocumentChange.databaseOrmError.count > 0 {
                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: datbaseOrmResultUDCDocumentChange.databaseOrmError[0].name, description: datbaseOrmResultUDCDocumentChange.databaseOrmError[0].description))
                        return
                    }
                    
                    // Only for english language update id name and name of document
                    if toChange.language == "en" {
                        // Needs to reassign since already update with this id name. Must not be overridden!
                        toChange.idName = toDocumentIdName
                        let datbaseOrmResultUDCDocumentChange1 = UDCDocument.update(udbcDatabaseOrm: udbcDatabaseOrm!, object: toChange)
                    }
                }
            }
            return
        } else {
            
            let databaseOrmResultUDCDocumentLocal = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, udcProfile: udcProfile, udcDocumentTypeIdName: udcDocumentTypeIdName, idName: fromDocumentIdName)
            
            if databaseOrmResultUDCDocumentLocal.databaseOrmError.count == 0 {
                let udcDocumentToChange = databaseOrmResultUDCDocumentLocal.object
                for toChange in udcDocumentToChange {
                    let databaseOrmResultudcDocumentGraphModelTitle = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: toChange.udcDocumentGraphModelId)
                    if databaseOrmResultudcDocumentGraphModelTitle.databaseOrmError.count > 0 {
                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModelTitle.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModelTitle.databaseOrmError[0].description))
                        return
                    }
                    let udcDocumentGraphModelTitle = databaseOrmResultudcDocumentGraphModelTitle.object[0]
                    
                    let databaseOrmResultudcDocumentGraphModelTitle1 = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentGraphModelTitle.childrenId[0])
                    if databaseOrmResultudcDocumentGraphModelTitle1.databaseOrmError.count > 0 {
                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModelTitle1.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModelTitle.databaseOrmError[0].description))
                        return
                    }
                    let udcDocumentGraphModelTitle1 = databaseOrmResultudcDocumentGraphModelTitle1.object[0]
                    
                    if udcDocumentGraphModelTitle1.idName != toIdName {
                        udcDocumentGraphModelTitle1.idName = toIdName
                        let databaseOrmResultudcDocumentGraphModelSave = UDCDocumentGraphModel.update(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentGraphModelTitle1._id, idName: toIdName) as DatabaseOrmResult<UDCDocumentGraphModel>
                        if databaseOrmResultudcDocumentGraphModelSave.databaseOrmError.count > 0 {
                            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModelSave.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModelSave.databaseOrmError[0].description))
                            return
                        }
                    }
                    
                    if toChange.language == documentLanguage {
                        udcDocumentGraphModelTitle1.name = toTitle
                        udcDocumentGraphModelTitle1.udcDocumentTime.changedBy = profileId
                        udcDocumentGraphModelTitle1.udcDocumentTime.changedTime = Date()
                        let databaseOrmResultudcDocumentGraphModelChanged = UDCDocumentGraphModel.update(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentGraphModelTitle1)
                        if databaseOrmResultudcDocumentGraphModelChanged.databaseOrmError.count > 0 {
                            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModelChanged.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModelChanged.databaseOrmError[0].description))
                            return
                        }
                        
                        toChange.udcDocumentTime.changedBy = profileId
                        toChange.udcDocumentTime.changedTime = Date()
                        toChange.name = toTitle
                        let datbaseOrmResultUDCDocumentChange1 = UDCDocument.update(udbcDatabaseOrm: udbcDatabaseOrm!, object: toChange)
                        if datbaseOrmResultUDCDocumentChange1.databaseOrmError.count > 0 {
                            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: datbaseOrmResultUDCDocumentChange1.databaseOrmError[0].name, description: datbaseOrmResultUDCDocumentChange1.databaseOrmError[0].description))
                            return
                        }
                    }
                }
                
            }
        }
    }
    
    private func getNodeIdNodeIndexMap(childrenId: [String], nodeIdNodeIndexMap: inout [String: Int], nodeIndex: inout Int, documentGraphChangeItemRequest: DocumentGraphChangeItemRequest, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) {
        
        for id in childrenId {
            nodeIndex += 1
            nodeIdNodeIndexMap[id] = nodeIndex
            let databaseOrmResultudcDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphChangeItemRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: id)
            if databaseOrmResultudcDocumentGraphModel.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModel.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModel.databaseOrmError[0].description))
                return
            }
            let udcDocumentGraphModel = databaseOrmResultudcDocumentGraphModel.object[0]
            if udcDocumentGraphModel.childrenId.count > 0 {
                getNodeIdNodeIndexMap(childrenId: udcDocumentGraphModel.childrenId, nodeIdNodeIndexMap: &nodeIdNodeIndexMap, nodeIndex: &nodeIndex, documentGraphChangeItemRequest: documentGraphChangeItemRequest, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            }
        }
        
        return
    }
    
    private func getLineNumberViewFromNode(childrenId: [String], uvcViewModel: inout [UVCViewModel], fromIndex: Int, nodeIndex: inout Int, udcDocumentTypeIdName: String, isChildrenAllowed: inout [Bool], neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest, documentLanguage: String, editMode: Bool, operation: String) {
        
        for id in childrenId {
            let databaseOrmResultudcDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: id, language: documentLanguage)
            if databaseOrmResultudcDocumentGraphModel.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModel.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModel.databaseOrmError[0].description))
                return
            }
            let udcDocumentGraphModel = databaseOrmResultudcDocumentGraphModel.object[0]
            if nodeIndex >= fromIndex {
                isChildrenAllowed.append(udcDocumentGraphModel.isChildrenAllowed)
                if operation == "newLine" {
                    uvcViewModel.append(uvcViewGenerator.getLineNumberViewModel(lineNumber: nodeIndex + 1, parentId: udcDocumentGraphModel.parentId, childrenId: udcDocumentGraphModel.childrenId, editMode: editMode))
                } else {
                    uvcViewModel.append(uvcViewGenerator.getLineNumberViewModel(lineNumber: nodeIndex + 2, parentId: udcDocumentGraphModel.parentId, childrenId: udcDocumentGraphModel.childrenId, editMode: editMode))
                }
            }
            nodeIndex += 1
            if udcDocumentGraphModel.childrenId.count > 0 {
                getLineNumberViewFromNode(childrenId: udcDocumentGraphModel.childrenId, uvcViewModel: &uvcViewModel, fromIndex: fromIndex, nodeIndex: &nodeIndex, udcDocumentTypeIdName: udcDocumentTypeIdName, isChildrenAllowed: &isChildrenAllowed, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, documentLanguage: documentLanguage, editMode: editMode, operation: operation)
            }
            
        }
        
        return
    }
    
    private func documentChangeItem(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let documentGraphChangeItemRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: DocumentGraphChangeItemRequest())
        
        let documentLanguage = documentGraphChangeItemRequest.documentLanguage
        
        if documentGraphChangeItemRequest.itemIndex > 0 {
            documentGraphChangeItemRequest.itemIndex -= 1
        }
        
        var profileId = ""
        for udcp in documentGraphChangeItemRequest.udcProfile {
            if udcp.udcProfileItemIdName == "UDCProfileItem.Human" {
                profileId = udcp.profileId
            }
        }
        
        let databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: documentGraphChangeItemRequest.documentId, language: documentLanguage)
        if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocument.databaseOrmError[0].name, description: databaseOrmResultUDCDocument.databaseOrmError[0].description))
            return
        }
        let udcDocument = databaseOrmResultUDCDocument.object[0]
        
        let modelId = documentGraphChangeItemRequest.parentId.isEmpty ? udcDocument.udcDocumentGraphModelId : documentGraphChangeItemRequest.parentId
        var databaseOrmResultudcDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphChangeItemRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: modelId, language: documentLanguage)
        if databaseOrmResultudcDocumentGraphModel.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModel.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModel.databaseOrmError[0].description))
            return
        }
        let udcDocumentGraphModelParent = databaseOrmResultudcDocumentGraphModel.object[0]
        
        // Get the recipe model
        databaseOrmResultudcDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphChangeItemRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: documentGraphChangeItemRequest.nodeId, language: documentLanguage)
        if databaseOrmResultudcDocumentGraphModel.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModel.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModel.databaseOrmError[0].description))
            return
        }
        let udcDocumentGraphModel = databaseOrmResultudcDocumentGraphModel.object[0]
        
        if documentGraphChangeItemRequest.udcDocumentTypeIdName == "UDCDocumentType.DocumentItem" {
            if udcDocumentGraphModel.isChildrenAllowed && documentGraphChangeItemRequest.level > 1 {
                documentGraphChangeItemRequest.itemIndex -= 1
            }
        }
        
        // Reduce the used count if it is an document item
        if udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphChangeItemRequest.sentenceIndex].udcSentencePatternDataGroupValue[documentGraphChangeItemRequest.itemIndex].itemIdName.hasPrefix("UDCDocumentItem.") {
            let itemId =  udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphChangeItemRequest.sentenceIndex].udcSentencePatternDataGroupValue[documentGraphChangeItemRequest.itemIndex].itemId
            
            // If not changed to same item
            if documentGraphChangeItemRequest.optionItemId != itemId {

                try removeReference(udcDocumentGraphModelId: itemId, udcDocumentTypeIdName: documentGraphChangeItemRequest.udcDocumentTypeIdName, objectId: udcDocumentGraphModel._id, documentLanguage: documentLanguage, udcProfile: documentGraphChangeItemRequest.udcProfile, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)

                try putReference(udcDocumentId: documentGraphChangeItemRequest.documentId, udcDocumentGraphModelId: documentGraphChangeItemRequest.optionItemId, udcDocumentTypeIdName: "UDCDocumentType.DocumentItem", objectUdcDocumentTypeIdName: documentGraphChangeItemRequest.udcDocumentTypeIdName, objectId: udcDocumentGraphModel._id, objectName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphChangeItemRequest.udcDocumentTypeIdName)!, documentLanguage: documentLanguage, udcProfile: documentGraphChangeItemRequest.udcProfile, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)

            }
        }
        
        let documentGraphChangeItemResponse = DocumentGraphChangeItemResponse()
        documentGraphChangeItemResponse.objectControllerResponse.groupUVCViewItemType = documentGraphChangeItemRequest.objectControllerRequest.groupUVCViewItemType
        documentGraphChangeItemResponse.objectControllerResponse.uvcViewItemType = documentGraphChangeItemRequest.objectControllerRequest.uvcViewItemType
        documentGraphChangeItemResponse.objectControllerResponse.udcViewItemName = documentGraphChangeItemRequest.objectControllerRequest.udcViewItemName!
        documentGraphChangeItemResponse.objectControllerResponse.udcViewItemId = documentGraphChangeItemRequest.objectControllerRequest.udcViewItemId!
        documentGraphChangeItemResponse.objectControllerResponse.editMode = documentGraphChangeItemRequest.objectControllerRequest.editMode
        documentGraphChangeItemResponse.objectControllerResponse.viewConfigPathIdName.append(contentsOf: documentGraphChangeItemRequest.objectControllerRequest.viewConfigPathIdName)
        
        // Update model
        // Form Sentence Pattern
        var udcSentencePatternGroupValue: UDCSentencePatternDataGroupValue?
        if !documentGraphChangeItemRequest.optionItemId.isEmpty {
            var getSentencePatternForDocumentItemResponse = GetGraphSentencePatternForDocumentItemResponse()
            try getSentencePattern(existingModel: udcDocumentGraphModel, objectControllerRequest: documentGraphChangeItemRequest.objectControllerRequest, optionItemObjectName: documentGraphChangeItemRequest.optionItemObjectName, optionItemIdName: documentGraphChangeItemRequest.optionItemId, optionItemNameIndex: documentGraphChangeItemRequest.optionItemNameIndex, optionDocumentIdName: documentGraphChangeItemRequest.optionDocumentIdName, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, language: documentLanguage, udcDocumentTypeIdName: documentGraphChangeItemRequest.udcDocumentTypeIdName, uvcViewItemType: documentGraphChangeItemRequest.objectControllerRequest.uvcViewItemType, itemIndex: documentGraphChangeItemRequest.itemIndex, item: documentGraphChangeItemRequest.item, isGeneratedItem: false, documentLanguage: documentGraphChangeItemRequest.documentLanguage, treeLevel: documentGraphChangeItemRequest.level, udcProfile: documentGraphChangeItemRequest.udcProfile, getSentencePatternForDocumentItemResponse: &getSentencePatternForDocumentItemResponse)
            
            if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
                return
            }
            
            getSentencePatternForDocumentItemResponse = neuronUtility!.getNeuronRequest(json: neuronResponse.neuronOperation.neuronData.text, object: GetGraphSentencePatternForDocumentItemResponse())

            udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphChangeItemRequest.sentenceIndex].udcSentencePatternDataGroupValue[documentGraphChangeItemRequest.itemIndex].item = getSentencePatternForDocumentItemResponse.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].item
            udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphChangeItemRequest.sentenceIndex].udcSentencePatternDataGroupValue[documentGraphChangeItemRequest.itemIndex].itemId = getSentencePatternForDocumentItemResponse.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].itemId
            udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphChangeItemRequest.sentenceIndex].udcSentencePatternDataGroupValue[documentGraphChangeItemRequest.itemIndex].itemIdName = getSentencePatternForDocumentItemResponse.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].itemIdName
            udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphChangeItemRequest.sentenceIndex].udcSentencePatternDataGroupValue[documentGraphChangeItemRequest.itemIndex].itemState = getSentencePatternForDocumentItemResponse.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].itemState
            udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphChangeItemRequest.sentenceIndex].udcSentencePatternDataGroupValue[documentGraphChangeItemRequest.itemIndex].endCategoryIdName = getSentencePatternForDocumentItemResponse.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].endCategoryIdName
            udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphChangeItemRequest.sentenceIndex].udcSentencePatternDataGroupValue[documentGraphChangeItemRequest.itemIndex].category = getSentencePatternForDocumentItemResponse.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].category
            udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphChangeItemRequest.sentenceIndex].udcSentencePatternDataGroupValue[documentGraphChangeItemRequest.itemIndex].itemNameIndex = getSentencePatternForDocumentItemResponse.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].itemNameIndex
            
            udcSentencePatternGroupValue = udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphChangeItemRequest.sentenceIndex].udcSentencePatternDataGroupValue[documentGraphChangeItemRequest.itemIndex]
        } else {
            if documentGraphChangeItemRequest.objectControllerRequest.uvcViewItemType == "UVCViewItemType.Photo" || documentGraphChangeItemRequest.objectControllerRequest.uvcViewItemType == "UVCViewItemType.PhotoDocument" {
                udcSentencePatternGroupValue =  udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphChangeItemRequest.sentenceIndex].udcSentencePatternDataGroupValue[documentGraphChangeItemRequest.itemIndex]
                udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphChangeItemRequest.sentenceIndex].udcSentencePatternDataGroupValue[documentGraphChangeItemRequest.itemIndex].itemId = documentGraphChangeItemRequest.itemId
                
            } else {
                udcSentencePatternGroupValue =  udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphChangeItemRequest.sentenceIndex].udcSentencePatternDataGroupValue[documentGraphChangeItemRequest.itemIndex]
                udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphChangeItemRequest.sentenceIndex].udcSentencePatternDataGroupValue[documentGraphChangeItemRequest.itemIndex].item = documentGraphChangeItemRequest.item
                udcSentencePatternGroupValue!.item = documentGraphChangeItemRequest.item
            }
            
        }

        // Process the grammar
        udcDocumentGraphModel.udcSentencePattern = try processGrammar(neuronRequest: neuronRequest, neuronResponse: &neuronResponse, udcSentencePattern: udcDocumentGraphModel.udcSentencePattern, newSentence: false, wordIndex: documentGraphChangeItemRequest.itemIndex, sentenceIndex: documentGraphChangeItemRequest.sentenceIndex, documentLanguage: documentLanguage, textStartIndex: 0)
        let getDocumentGraphIdNameRequest = GetDocumentGraphIdNameRequest()
        getDocumentGraphIdNameRequest.udcDocumentGraphModel = udcDocumentGraphModel
        getDocumentGraphIdNameRequest.udcDocumentTypeIdName = documentGraphChangeItemRequest.udcDocumentTypeIdName
        getDocumentGraphIdNameRequest.documentLanguage = documentGraphChangeItemRequest.documentLanguage
        var getDocumentGraphIdNameResponse = GetDocumentGraphIdNameResponse()
        if try isNeuronProcessingIt(operationName: "DocumentGraphNeuron.Document.Type.Process.idName.Generated", udcDocumentTypeIdName: documentGraphChangeItemRequest.udcDocumentTypeIdName, neuronRequest: neuronRequest, neuronResponse: &neuronResponse) {
            var neuronRequestLocal1 = neuronRequest
            let jsonUtilityGetDocumentGraphIdNameRequest = JsonUtility<GetDocumentGraphIdNameRequest>()
            let jsonDocumentGetDocumentGraphIdNameRequest = jsonUtilityGetDocumentGraphIdNameRequest.convertAnyObjectToJson(jsonObject: getDocumentGraphIdNameRequest)
            neuronRequestLocal1.neuronOperation.neuronData.text = jsonDocumentGetDocumentGraphIdNameRequest
            var called = try callNeuron(neuronRequest: neuronRequestLocal1, neuronResponse: &neuronResponse, operationName: "DocumentGraphNeuron.Document.IdName", udcDocumentTypeIdName: documentGraphChangeItemRequest.udcDocumentTypeIdName)
            getDocumentGraphIdNameResponse = neuronUtility!.getNeuronRequest(json: neuronResponse.neuronOperation.neuronData.text, object: GetDocumentGraphIdNameResponse())
        } else {
            try getDocumentIdName(getDocumentGraphIdNameRequest: getDocumentGraphIdNameRequest, getDocumentGraphIdNameResponse: &getDocumentGraphIdNameResponse, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        }
        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
            return
        }
        
        udcDocumentGraphModel.name = getDocumentGraphIdNameResponse.name
        udcDocumentGraphModel.idName = getDocumentGraphIdNameResponse.idName
        
        let documentTypeProcessRequest = DocumentGraphTypeProcessRequest()
        documentTypeProcessRequest.udcDocuemntGraphModel = udcDocumentGraphModel
        documentTypeProcessRequest.nodeIndex = documentGraphChangeItemRequest.nodeIndex
        var neuronRequestLocal1 = neuronRequest
        let jsonUtilityDocumentTypeProcessRequest = JsonUtility<DocumentGraphTypeProcessRequest>()
        let jsonDocumentGetSentencePatternForDocumentItemRequest = jsonUtilityDocumentTypeProcessRequest.convertAnyObjectToJson(jsonObject: documentTypeProcessRequest)
        neuronRequestLocal1.neuronOperation.neuronData.text = jsonDocumentGetSentencePatternForDocumentItemRequest
        var called = try callNeuron(neuronRequest: neuronRequestLocal1, neuronResponse: &neuronResponse, operationName: "DocumentGraphNeuron.Document.Type.Process.Post", udcDocumentTypeIdName: documentGraphChangeItemRequest.udcDocumentTypeIdName)
        
        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
            return
        }
        
        var documentTypeProcessResponse = DocumentGraphTypeProcessResponse()
        if called {
            documentTypeProcessResponse = neuronUtility!.getNeuronRequest(json: neuronResponse.neuronOperation.neuronData.text, object: DocumentGraphTypeProcessResponse())
        } else {
            if documentGraphChangeItemRequest.nodeIndex == 0 {
                documentTypeProcessResponse.udcSentencePatternUniqueDocumentTitle = udcDocumentGraphModel.udcSentencePattern
            } /*else if documentGraphChangeItemRequest.nodeIndex == 1 {
                documentTypeProcessResponse.udcSentencePatternDocumentTitle = udcDocumentGraphModel.udcSentencePattern
            }*/
        }
        
        if documentTypeProcessResponse.udcSentencePatternUniqueDocumentTitle.udcSentencePatternData.count > 0 {
            let uniqueDocumentTitle = documentTypeProcessResponse.udcSentencePatternUniqueDocumentTitle.sentence
            let idName: String = "UDCDocument.\(uniqueDocumentTitle.capitalized.replacingOccurrences(of: " ", with: ""))"
            if udcDocument.idName != idName {
                let databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, idName: udcDocument.idName)
                if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocument.databaseOrmError[0].name, description: databaseOrmResultUDCDocument.databaseOrmError[0].description))
                    return
                }
                let udcDocumentToChange = databaseOrmResultUDCDocument.object
                for toChange in udcDocumentToChange {
                    toChange.name = idName
                    let databaseOrmResultudcDocumentGraphModelToChange = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName:  documentGraphChangeItemRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: toChange.udcDocumentGraphModelId)
                    if databaseOrmResultudcDocumentGraphModelToChange.databaseOrmError.count > 0 {
                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModelToChange.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModelToChange.databaseOrmError[0].description))
                        return
                    }
                    let udcDocumentGraphModelToChange = databaseOrmResultudcDocumentGraphModelToChange.object[0]
                    let modelIdName: String = "\(neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphChangeItemRequest.udcDocumentTypeIdName)!).\(uniqueDocumentTitle.capitalized.replacingOccurrences(of: " ", with: ""))"
                    udcDocumentGraphModelToChange.udcDocumentTime.changedBy = profileId
                    udcDocumentGraphModelToChange.idName = modelIdName
                    udcDocumentGraphModelToChange.name = uniqueDocumentTitle
                    udcDocumentGraphModelToChange.udcSentencePattern.sentence = uniqueDocumentTitle
                    udcDocumentGraphModelToChange.udcDocumentTime.changedBy = profileId
                    udcDocumentGraphModelToChange.udcDocumentTime.changedTime = Date()
                    let databaseOrmResultudcDocumentGraphModelChanged = UDCDocumentGraphModel.update(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName:   documentGraphChangeItemRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentGraphModelToChange)
                    if databaseOrmResultudcDocumentGraphModelChanged.databaseOrmError.count > 0 {
                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModelChanged.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModelChanged.databaseOrmError[0].description))
                        return
                    }
                    toChange.udcDocumentTime.changedBy = profileId
                    toChange.udcDocumentTime.changedTime = Date()
                    let datbaseOrmResultUDCDocumentChange = UDCDocument.update(udbcDatabaseOrm: udbcDatabaseOrm!, id: toChange._id, idName: idName) as DatabaseOrmResult<UDCDocument>
                    if datbaseOrmResultUDCDocumentChange.databaseOrmError.count > 0 {
                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: datbaseOrmResultUDCDocumentChange.databaseOrmError[0].name, description: datbaseOrmResultUDCDocumentChange.databaseOrmError[0].description))
                        return
                    }
                    
                    
                }
                
            }
        } else if documentTypeProcessResponse.udcSentencePatternDocumentTitle.udcSentencePatternData.count > 0 {
            let documentTitle = documentTypeProcessResponse.udcSentencePatternDocumentTitle.sentence
            documentGraphChangeItemResponse.documentTitle = documentTitle
            if udcDocument.name != documentTitle {
                udcDocument.name = documentTitle
                udcDocument.idName = "UDCDocument.\(documentTitle.capitalized.replacingOccurrences(of: " ", with: ""))"
                let databaseOrmResultUDCDocument = UDCDocument.update(udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocument._id, name: documentTitle) as DatabaseOrmResult<UDCDocument>
                if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocument.databaseOrmError[0].name, description: databaseOrmResultUDCDocument.databaseOrmError[0].description))
                    return
                }
                
                // Change the title of the document
                let databaseOrmResultUDCDocumentItemMapNode = UDCDocumentItemMapNode.get(objectId: documentGraphChangeItemRequest.documentId, udbcDatabaseOrm!, documentLanguage)
                if databaseOrmResultUDCDocumentItemMapNode.databaseOrmError.count == 0 {
                    let idName: String = "UDCDocumentItemMapNode.\(documentTitle.capitalized.replacingOccurrences(of: " ", with: ""))"
                    let udcDocumentItemMapNode = databaseOrmResultUDCDocumentItemMapNode.object[0]
                    udcDocumentItemMapNode.name = documentTitle
                    udcDocumentItemMapNode.idName = idName
                    udcDocumentItemMapNode.pathIdName[udcDocumentItemMapNode.pathIdName.count - 1] = idName
                    let _ = UDCDocumentItemMapNode.update(udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentItemMapNode) as DatabaseOrmResult<UDCDocumentItemMapNode>
                }
                
                let changeDocumentMapNodeRequest = ChangeDocumentMapNodeRequest()
                changeDocumentMapNodeRequest.udcDocumentMapNode.documentId = documentGraphChangeItemRequest.documentId
                changeDocumentMapNodeRequest.udcDocumentMapNode.name = documentTitle
                changeDocumentMapNodeRequest.upcApplicationProfileId = documentGraphChangeItemRequest.upcApplicationProfileId
                changeDocumentMapNodeRequest.upcCompanyProfileId = documentGraphChangeItemRequest.upcCompanyProfileId
                let neuronRequestLocal = NeuronRequest()
                neuronRequestLocal.neuronSource._id = neuronRequest.neuronSource._id
                neuronRequestLocal.neuronOperation.synchronus = true
                neuronRequestLocal.neuronOperation._id = neuronRequest.neuronOperation._id
                neuronRequestLocal.neuronSource.name = DocumentGraphNeuron.getName()
                neuronRequestLocal.neuronSource.type = DocumentGraphNeuron.getName()
                neuronRequestLocal.neuronOperation.name = "DocumentMapNeuron.DocumentMapNode.Change"
                neuronRequestLocal.neuronOperation.parent = true
                let jsonUtilityChangeDocumentMapNodeRequest = JsonUtility<ChangeDocumentMapNodeRequest>()
                neuronRequestLocal.neuronOperation.neuronData.text = jsonUtilityChangeDocumentMapNodeRequest.convertAnyObjectToJson(jsonObject: changeDocumentMapNodeRequest)
                try callOtherNeuron(neuronRequest: neuronRequestLocal, neuronResponse: &neuronResponse, neuronName: "DocumentMapNeuron", overWriteResponse: true)
                
                if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
                    return
                }
                documentGraphChangeItemResponse.refreshDocumentMap = true
            }
        }
        
        if documentGraphChangeItemRequest.objectControllerRequest.uvcViewItemType == "UVCViewItemType.Photo" {
            var found: Bool = false
            for udcPhoto in udcDocumentGraphModel.udcViewItemCollection.udcPhoto {
                if udcSentencePatternGroupValue?.udcViewItemId == udcPhoto._id {
                    found = true
                    break
                }
            }
            if !found {
                let udcPhoto = UDCPhoto()
                udcPhoto._id = (try udbcDatabaseOrm?.generateId())!
                
                var width: Double = 0
                var height: Double = 0
                getPhotoMeasurements(viewPathIdName: documentGraphChangeItemRequest.objectControllerRequest.viewPathIdName, width: &width, height: &height)
                var uvcMeasurement = UVCMeasurement()
                uvcMeasurement.type = UVCMeasurementType.Width.name
                uvcMeasurement.value = width
                udcPhoto.uvcMeasurement.append(uvcMeasurement)
                uvcMeasurement = UVCMeasurement()
                uvcMeasurement.type = UVCMeasurementType.Height.name
                uvcMeasurement.value = height
                udcPhoto.uvcMeasurement.append(uvcMeasurement)
                udcDocumentGraphModel.udcViewItemCollection.udcPhoto.append(udcPhoto)
                udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphChangeItemRequest.sentenceIndex].udcSentencePatternDataGroupValue[documentGraphChangeItemRequest.itemIndex].udcViewItemId = udcPhoto._id
            }
        }
        
        // Save it back
        udcDocumentGraphModel.udcDocumentTime.changedBy = profileId
        udcDocumentGraphModel.udcDocumentTime.changedTime = Date()
        let databaseOrmResultudcDocumentGraphModel2 = UDCDocumentGraphModel.update(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphChangeItemRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentGraphModel)
        if databaseOrmResultudcDocumentGraphModel2.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModel2.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModel2.databaseOrmError[0].description))
            return
        }
        
        // Send the view of the changed item alone
        let udcDocumentGraphModelResponse = UDCDocumentGraphModel()
        udcDocumentGraphModelResponse._id = udcDocumentGraphModel._id
        if udcDocumentGraphModel.parentId.count > 0 {
            udcDocumentGraphModelResponse.parentId.append(udcDocumentGraphModel.parentId[0])
        }
        udcDocumentGraphModelResponse.name = udcSentencePatternGroupValue!.item!
        udcDocumentGraphModelResponse.level = udcDocumentGraphModel.level
        udcDocumentGraphModelResponse.language = documentLanguage
        udcDocumentGraphModelResponse.udcAnalytic = udcDocumentGraphModel.udcAnalytic
        udcDocumentGraphModelResponse.udcProfile = udcDocumentGraphModel.udcProfile
        
        udcDocumentGraphModelResponse.udcSentencePattern = UDCSentencePattern()
        udcDocumentGraphModelResponse.udcSentencePattern.udcSentencePatternData.append(UDCSentencePatternData())
        udcDocumentGraphModelResponse.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup.append(UDCSentencePatternDataGroup())
        udcDocumentGraphModelResponse.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.append(udcSentencePatternGroupValue!)
        
        
        
        
        // Generate the sentence view with new model
        var nodeIndexLocal = 0
        var nodeIdNodeIndexMap = [String: Int]()
        databaseOrmResultudcDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphChangeItemRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocument.udcDocumentGraphModelId, language: documentLanguage)
        let udcDocumentGraphModelRoot = databaseOrmResultudcDocumentGraphModel.object[0]
        if databaseOrmResultudcDocumentGraphModel.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModel.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModel.databaseOrmError[0].description))
            return
        }
        getNodeIdNodeIndexMap(childrenId: udcDocumentGraphModelRoot.childrenId, nodeIdNodeIndexMap: &nodeIdNodeIndexMap, nodeIndex: &nodeIndexLocal, documentGraphChangeItemRequest: documentGraphChangeItemRequest, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        
        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
            return
        }
        
        // If any target item needs to be updated, then do so and gnerate the view for it
        for (udcspdgvIndex, udcspdgv) in udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphChangeItemRequest.sentenceIndex].udcSentencePatternDataGroupValue.enumerated() {
            if udcspdgv.udcDocumentItemGraphReferenceTarget.count > 0 {
                for udcdigr in udcspdgv.udcDocumentItemGraphReferenceTarget {
                    if udcspdgvIndex == documentGraphChangeItemRequest.itemIndex {
                        let databaseOrmResultudcDocumentGraphModel1 = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphChangeItemRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcdigr.nodeId, language: documentLanguage)
                        if databaseOrmResultudcDocumentGraphModel1.databaseOrmError.count > 0 {
                            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModel1.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModel1.databaseOrmError[0].description))
                            return
                        }
                        let udcDocumentGraphModelTarget = databaseOrmResultudcDocumentGraphModel1.object[0]
                        
                        let databaseOrmResultudcDocumentGraphModel2 = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphChangeItemRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentGraphModelTarget.parentId[0], language: documentLanguage)
                        if databaseOrmResultudcDocumentGraphModel2.databaseOrmError.count > 0 {
                            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModel2.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModel2.databaseOrmError[0].description))
                            return
                        }
                        let udcDocumentGraphModelTargetParent = databaseOrmResultudcDocumentGraphModel2.object[0]
                        udcDocumentGraphModelTarget.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[udcdigr.referenceSentenceIndex].udcSentencePatternDataGroupValue[udcdigr.referenceItemIndex].item = documentGraphChangeItemRequest.item
                        
                        udcDocumentGraphModelTarget.udcSentencePattern = try processGrammar(neuronRequest: neuronRequest, neuronResponse: &neuronResponse, udcSentencePattern: udcDocumentGraphModelTarget.udcSentencePattern, newSentence: false, wordIndex: documentGraphChangeItemRequest.itemIndex, sentenceIndex: documentGraphChangeItemRequest.sentenceIndex, documentLanguage: documentLanguage, textStartIndex: 0)
                        udcDocumentGraphModelTarget.name = udcDocumentGraphModelTarget.udcSentencePattern.sentence
                        
                        udcDocumentGraphModelTarget.udcDocumentTime.changedBy = profileId
                        udcDocumentGraphModelTarget.udcDocumentTime.changedTime = Date()
                        let databaseOrmResultudcDocumentGraphModelUpdate = UDCDocumentGraphModel.update(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphChangeItemRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentGraphModelTarget)
                        if databaseOrmResultudcDocumentGraphModelUpdate.databaseOrmError.count > 0 {
                            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModelUpdate.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModelUpdate.databaseOrmError[0].description))
                            return
                        }
                        
                        let documentGraphChangeItemRequestLocal = DocumentGraphChangeItemRequest()
                        documentGraphChangeItemRequestLocal.itemIndex = udcdigr.referenceItemIndex
                        documentGraphChangeItemRequestLocal.nodeIndex = nodeIdNodeIndexMap[udcdigr.nodeId]!
                        documentGraphChangeItemRequestLocal.sentenceIndex = udcdigr.referenceSentenceIndex
                        documentGraphChangeItemRequestLocal.documentId = documentGraphChangeItemRequest.documentId
                        documentGraphChangeItemRequestLocal.item = documentGraphChangeItemRequest.item
                        documentGraphChangeItemRequestLocal.itemId = documentGraphChangeItemRequest.itemId
                        documentGraphChangeItemRequestLocal.nodeId = udcdigr.nodeId
                        documentGraphChangeItemRequestLocal.parentId = udcDocumentGraphModelTargetParent._id
                        documentGraphChangeItemRequestLocal.udcDocumentTypeIdName = documentGraphChangeItemRequest.udcDocumentTypeIdName
                        var generateDocumentItemViewForChangeResponse = GenerateDocumentItemViewForChangeResponse()
                        try generateDocumentItemViewForChange(parentDocumentModel: udcDocumentGraphModelTargetParent, changeDocumentModel: udcDocumentGraphModelTarget, documentModelId: udcDocument.udcDocumentGraphModelId, udcSentencePatternDataGroupValue: udcDocumentGraphModelTarget.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[udcdigr.referenceSentenceIndex].udcSentencePatternDataGroupValue[udcdigr.referenceItemIndex], documentGraphChangeItemRequest: documentGraphChangeItemRequestLocal, generateDocumentItemViewForChangeResponse: &generateDocumentItemViewForChangeResponse, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
                        
                        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
                            return
                        }
                        
                        
                        if generateDocumentItemViewForChangeResponse.documentItemViewInsertData.count > 0 {
                            documentGraphChangeItemResponse.documentItemViewInsertData.append(contentsOf: generateDocumentItemViewForChangeResponse.documentItemViewInsertData)
                        }
                        if generateDocumentItemViewForChangeResponse.documentItemViewChangeData.count > 0 {
                            documentGraphChangeItemResponse.documentItemViewChangeData.append(contentsOf: generateDocumentItemViewForChangeResponse.documentItemViewChangeData)
                        }
                        if generateDocumentItemViewForChangeResponse.documentItemViewDeleteData.count > 0 {
                            documentGraphChangeItemResponse.documentItemViewDeleteData.append(contentsOf: generateDocumentItemViewForChangeResponse.documentItemViewDeleteData)
                        }
                    }
                }
            }
        }
        
        if documentGraphChangeItemRequest.udcDocumentTypeIdName == "UDCDocumentType.DocumentItem" && udcDocumentGraphModel.level > 1 && documentGraphChangeItemRequest.documentLanguage == "en" {
            // Get all the documents that are not in english language
            let databaseOrmResultUDCDocumentOther = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, idName: udcDocument.idName, udcProfile: documentGraphChangeItemRequest.udcProfile, udcDocumentTypeIdName: documentGraphChangeItemRequest.udcDocumentTypeIdName, notEqualsLanguage: "en")
            if databaseOrmResultUDCDocumentOther.databaseOrmError.count == 0 {
                let udcDocumentOther = databaseOrmResultUDCDocumentOther.object
                
                // Handle insert in those other language documents
                for udcd in udcDocumentOther {
                    // Get the document model root node
                    let databaseOrmResultudcDocumentGraphModelOther = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphChangeItemRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcd.udcDocumentGraphModelId, language: udcd.language)
                    if databaseOrmResultudcDocumentGraphModelOther.databaseOrmError.count > 0 {
                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModelOther.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModelOther.databaseOrmError[0].description))
                        return
                    }
                    let udcDocumentGraphModelOther = databaseOrmResultudcDocumentGraphModelOther.object[0]
                    var parentFound: Bool = false
                    var foundParentModel = UDCDocumentGraphModel()
                    var foundParentId: String = ""
                    
                    // Get the english language parent node of the node to process
                    let databaseOrmResultudcDocumentGraphModelLangSpeficEnglishTitleNode = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphChangeItemRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentGraphModel.parentId[0], language: udcDocumentGraphModel.language)
                    if databaseOrmResultudcDocumentGraphModelLangSpeficEnglishTitleNode.databaseOrmError.count > 0 {
                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModelLangSpeficEnglishTitleNode.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModelLangSpeficEnglishTitleNode.databaseOrmError[0].description))
                        return
                    }
                    let udcDocumentGraphModelLangSpeficParentNode = databaseOrmResultudcDocumentGraphModelLangSpeficEnglishTitleNode.object[0]
                    let udcViewItemCollection = UDCViewItemCollection()
                    for udcPhoto in udcDocumentGraphModel.udcViewItemCollection.udcPhoto {
                        if udcPhoto._id == udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[documentGraphChangeItemRequest.itemIndex].udcViewItemId {
                            let udcPhotoLocal = udcPhoto
                            udcPhotoLocal._id = try udbcDatabaseOrm!.generateId()
                            udcViewItemCollection.udcPhoto.append(udcPhotoLocal)
                        }
                    }
                    
                    
                    // Use the parent id name and pervious node id name to search.
                    // If parent matches then change the respective children if found
                    let _ = try findAndProcessDocumentItem(mode: "change", udcSentencePatternDataGroupValue: udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphChangeItemRequest.sentenceIndex].udcSentencePatternDataGroupValue, parentIdName: udcDocumentGraphModelLangSpeficParentNode.idName, findIdName: udcDocumentGraphModel.idName, inChildrens: udcDocumentGraphModelOther.childrenId, parentFound: &parentFound, foundParentModel: &foundParentModel, foundParentId: &foundParentId, nodeIndex: documentGraphChangeItemRequest.nodeIndex, itemIndex: documentGraphChangeItemRequest.itemIndex, level: documentGraphChangeItemRequest.level, udcDocumentTypeIdName: documentGraphChangeItemRequest.udcDocumentTypeIdName, udcProfile: documentGraphChangeItemRequest.udcProfile, isParent: udcDocumentGraphModel.isChildrenAllowed,  generatedIdName: "", neuronRequest: neuronRequest, neuronResponse: &neuronResponse, documentLanguage: udcd.language, addUdcSentencePatternDataGroupValue: [], addUdcViewItemCollection: udcViewItemCollection, addUdcSentencePatternDataGroupValueIndex: [])
                    if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
                        return
                    }
                    
                }
            }
        }
        
        var generateDocumentItemViewForChangeResponse = GenerateDocumentItemViewForChangeResponse()
        try generateDocumentItemViewForChange(parentDocumentModel: udcDocumentGraphModelParent, changeDocumentModel: udcDocumentGraphModel, documentModelId: udcDocument.udcDocumentGraphModelId, udcSentencePatternDataGroupValue: udcSentencePatternGroupValue!, documentGraphChangeItemRequest: documentGraphChangeItemRequest, generateDocumentItemViewForChangeResponse: &generateDocumentItemViewForChangeResponse, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        
        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
            return
        }
        
        
        
        
        documentGraphChangeItemResponse.objectControllerResponse = generateDocumentItemViewForChangeResponse.objectControllerResponse
        
        if generateDocumentItemViewForChangeResponse.documentItemViewInsertData.count > 0 {
            documentGraphChangeItemResponse.documentItemViewInsertData.append(contentsOf: generateDocumentItemViewForChangeResponse.documentItemViewInsertData)
        }
        if generateDocumentItemViewForChangeResponse.documentItemViewChangeData.count > 0 {
            documentGraphChangeItemResponse.documentItemViewChangeData.append(contentsOf: generateDocumentItemViewForChangeResponse.documentItemViewChangeData)
        }
        if generateDocumentItemViewForChangeResponse.documentItemViewDeleteData.count > 0 {
            documentGraphChangeItemResponse.documentItemViewDeleteData.append(contentsOf: generateDocumentItemViewForChangeResponse.documentItemViewDeleteData)
        }
        
        let jsonUtilityDocumentGraphChangeItemResponse = JsonUtility<DocumentGraphChangeItemResponse>()
        let jsonDocumentGraphChangeItemResponse = jsonUtilityDocumentGraphChangeItemResponse.convertAnyObjectToJson(jsonObject: documentGraphChangeItemResponse)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonDocumentGraphChangeItemResponse)
    }
    
    
    private func getJsonTypeForViewItem(idName: String) -> String? {
        if idName == "UDCOptionMapNode.Choice" {
            return "UDCJsonType.Choice"
        }
        
        return nil
    }
    
    private func isUDCViewCollectionAnyChange(udcViewCollection: UDCViewItemCollection) -> Bool {
        var changed = udcViewCollection.udcPhoto.count > 0 || udcViewCollection.udcChoice.count > 0 || udcViewCollection.udcSentenceReference.count > 0
        
        return changed
    }
    
    private func findDocumentItemInAllDocs(find: UDCSentencePatternDataGroupValue, documentLanguage: String, found: inout Bool, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) {
        // Loop through the document that are matching the document item language
        let databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
        if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocument.databaseOrmError[0].name, description: databaseOrmResultUDCDocument.databaseOrmError[0].description))
            return
        }
        let udcDocument = databaseOrmResultUDCDocument.object
        
        for udcd in udcDocument {
            
            if udcd.udcDocumentTypeIdName.isEmpty {
                continue
            }
            // Lock the document
            
            // Get the document model nodes traverse through the childrens, for matching items.
            let databaseOrmResultUDCDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcd.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcd.udcDocumentGraphModelId, language: documentLanguage)
            if databaseOrmResultUDCDocument.databaseOrmError.count == 0 && databaseOrmResultUDCDocumentGraphModel.object.count > 0 {
                let udcDocumentGraphModel = databaseOrmResultUDCDocumentGraphModel.object[0]
                print("Document: \(udcd._id): \(udcDocumentGraphModel._id): \(udcDocumentGraphModel.name): \(udcd.udcDocumentTypeIdName)")
                if udcDocumentGraphModel._id == "5e30121f7f303f1c6c4e12bb" {
                    findDocumentItemInDoc(children: udcDocumentGraphModel.childrenId, udcDocument: udcd, find: find, documentLanguage: documentLanguage, found: &found, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
                }
            }
            // Release the lock of document
            
        } // End of the loop document that are matching the document item language
    }
    
    private func findDocumentItemInDoc(children: [String], udcDocument: UDCDocument, find: UDCSentencePatternDataGroupValue, documentLanguage: String, found: inout Bool, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) {
        // Loop through the childrens
        for child in children {
            
            // Get the document model node for the children
            let databaseOrmResultUDCDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocument.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: child, language: documentLanguage)
            if databaseOrmResultUDCDocumentGraphModel.databaseOrmError.count == 0 {
                let udcDocumentGraphModel = databaseOrmResultUDCDocumentGraphModel.object[0]
                
                // Find the item, but should be the find item itself
                if find.itemId != udcDocumentGraphModel._id && find.endSubCategoryId != udcDocumentGraphModel.parentId[0]  {
                    var foundLocal: Bool = false
                    for (udcspdgvIndex, udcspdgv) in udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.enumerated() {
                        // if found replace the text
                        if udcspdgv.itemId == find.itemId && udcspdgv.endSubCategoryId == find.endSubCategoryId && udcspdgv.endCategoryIdName == find.endCategoryIdName {
                            found = true
                            return
                        }
                    }
                    
                    
                }
                // Do recursive if there are childrens
                if udcDocumentGraphModel.childrenId.count > 0 {
                    findDocumentItemInDoc(children: udcDocumentGraphModel.childrenId, udcDocument: udcDocument, find: find, documentLanguage: documentLanguage, found: &found, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
                }
            }
        } // End of the looop through childrenss
    }
    
    private func replaceDocumentItemInAllDocs(find: UDCSentencePatternDataGroupValue, replace: UDCSentencePatternDataGroupValue, documentLanguage: String, found: inout Bool, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        // Loop through the document that are matching the document item language
        let databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
        if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocument.databaseOrmError[0].name, description: databaseOrmResultUDCDocument.databaseOrmError[0].description))
            return
        }
        let udcDocument = databaseOrmResultUDCDocument.object
        
        for udcd in udcDocument {
            
            if udcd.udcDocumentTypeIdName.isEmpty {
                continue
            }
            // Lock the document
            
            // Get the document model nodes traverse through the childrens, for matching items.
            let databaseOrmResultUDCDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcd.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcd.udcDocumentGraphModelId, language: documentLanguage)
            if databaseOrmResultUDCDocument.databaseOrmError.count == 0 && databaseOrmResultUDCDocumentGraphModel.object.count > 0 {
                let udcDocumentGraphModel = databaseOrmResultUDCDocumentGraphModel.object[0]
                try replaceDocumentItemInDoc(children: [udcDocumentGraphModel._id], udcDocument: udcd, find: find, replace: replace, documentLanguage: documentLanguage, found: &found, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            }
            // Release the lock of document
            
        } // End of the loop document that are matching the document item language
    }
    
    private func replaceDocumentItemInDoc(children: [String], udcDocument: UDCDocument, find: UDCSentencePatternDataGroupValue, replace: UDCSentencePatternDataGroupValue, documentLanguage: String, found: inout Bool, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        // Loop through the childrens
        for child in children {
            
            // Get the document model node for the children
            let databaseOrmResultUDCDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocument.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: child, language: documentLanguage)
            if databaseOrmResultUDCDocumentGraphModel.databaseOrmError.count == 0 {
                let udcDocumentGraphModel = databaseOrmResultUDCDocumentGraphModel.object[0]
                let parentId = udcDocumentGraphModel.parentId.count == 0 ? "" : udcDocumentGraphModel.parentId[0]
                // Find the item, but should be the find item itself
                if find.itemId != udcDocumentGraphModel._id && find.endSubCategoryId != parentId {
                    var foundLocal: Bool = false
                    for (udcspdgvIndex, udcspdgv) in udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.enumerated() {
                        // if found replace the text
                        if udcspdgv.itemId == find.itemId && udcspdgv.endSubCategoryId == find.endSubCategoryId && udcspdgv.endCategoryIdName == find.endCategoryIdName && udcspdgv.itemNameIndex == find.itemNameIndex {
                            foundLocal = true
                            udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].item = replace.item
                            udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].itemIdName = replace.itemIdName
                            
                            udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].itemNameIndex = replace.itemNameIndex
                        } else if udcspdgv.itemId == find.itemId && udcspdgv.endCategoryId == find.endSubCategoryId && udcspdgv.endCategoryIdName == find.endCategoryIdName && udcspdgv.itemNameIndex == find.itemNameIndex {
                            foundLocal = true
                            udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].item = replace.item
                            
                            udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].itemIdName = replace.itemIdName
                            udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].itemNameIndex = replace.itemNameIndex
                        }
                        udcDocumentGraphModel.udcSentencePattern = try processGrammar(neuronRequest: neuronRequest, neuronResponse: &neuronResponse, udcSentencePattern: udcDocumentGraphModel.udcSentencePattern, newSentence: true, wordIndex: 0, sentenceIndex: 0, documentLanguage: documentLanguage, textStartIndex: 0)
                        udcDocumentGraphModel.name = udcDocumentGraphModel.udcSentencePattern.sentence
                        udcDocumentGraphModel.idName = "\(neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocument.udcDocumentTypeIdName)!).\(udcDocumentGraphModel.name.capitalized.replacingOccurrences(of: " ", with: ""))"
                    }
                    
                    // If found then update the model
                    if foundLocal {
                        let databaseOrmResultUDCDocumentGraphModelUpdate = UDCDocumentGraphModel.update(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocument.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentGraphModel)
                        if databaseOrmResultUDCDocumentGraphModelUpdate.databaseOrmError.count > 0 {
                            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentGraphModelUpdate.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentGraphModelUpdate.databaseOrmError[0].description))
                            return
                        }
                    }
                }
                // Do recursive if there are childrens
                if udcDocumentGraphModel.childrenId.count > 0 {
                    try replaceDocumentItemInDoc(children: udcDocumentGraphModel.childrenId, udcDocument: udcDocument, find: find, replace: replace, documentLanguage: documentLanguage, found: &found, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
                }
            }
        } // End of the looop through childrenss
    }
    
    private func replaceDocumentItemInAllReferedDoc(referenceId: String, referenceObjectName: String, find: UDCSentencePatternDataGroupValue, replace: UDCSentencePatternDataGroupValue, found: inout Bool, udcSentencePatternGroupValue: [UDCSentencePatternDataGroupValue], replaceFull: Bool, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let databaseOrmRef = UDCDocumentGraphModelReference.get(collectionName: "\(referenceObjectName)Reference", udbcDatabaseOrm: udbcDatabaseOrm!, id: referenceId)
        let udcRef = databaseOrmRef.object[0]
        var isSameObjectName = udcRef.objectName == referenceObjectName
        try replaceDocumentItemInReferedDoc(find: find, replace: replace, reference: udcRef, found: &found, isSameObjectName: isSameObjectName, udcSentencePatternGroupValue: udcSentencePatternGroupValue, replaceFull: replaceFull, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        for child in udcRef.childrenId {
            let databaseOrmRefChild = UDCDocumentGraphModelReference.get(collectionName: "\(referenceObjectName)Reference", udbcDatabaseOrm: udbcDatabaseOrm!, id: child)
            let udcRefChild = databaseOrmRefChild.object[0]
            isSameObjectName = udcRefChild.objectName == referenceObjectName
            try replaceDocumentItemInReferedDoc(find: find, replace: replace, reference: udcRefChild, found: &found, isSameObjectName: isSameObjectName, udcSentencePatternGroupValue: udcSentencePatternGroupValue, replaceFull: replaceFull, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        }
    }
    
    private func replaceDocumentItemInReferedDoc(find: UDCSentencePatternDataGroupValue, replace: UDCSentencePatternDataGroupValue, reference: UDCDocumentGraphModelReference, found: inout Bool, isSameObjectName: Bool, udcSentencePatternGroupValue: [UDCSentencePatternDataGroupValue], replaceFull: Bool, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        if reference.objectName == "UDCDocument" {
            let databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: reference.objectId)
            if databaseOrmResultUDCDocument.databaseOrmError.count == 0 {
                let udcDocument = databaseOrmResultUDCDocument.object[0]
                let findNamePart = find.itemIdName.split(separator: ".")[1]
                if udcDocument.idName.split(separator: ".")[1] == findNamePart {
                    if !reference.isIdNameChange || reference.language == "en" {
                        udcDocument.name = replace.item!
                    }
                    udcDocument.idName = "UDCDocument.\(replace.itemIdName.split(separator: ".")[1])"
                    let databaseOrmResultUDCDocumentSave = UDCDocument.update(udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocument)
                    if databaseOrmResultUDCDocumentSave.databaseOrmError.count > 0 {
                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentSave.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentSave.databaseOrmError[0].description))
                        return
                    }
                }
            }
        } else {
            let databaseOrmResultUDCDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: reference.objectName, udbcDatabaseOrm: udbcDatabaseOrm!, id: reference.objectId, language: reference.language)
            if databaseOrmResultUDCDocumentGraphModel.databaseOrmError.count == 0 {
                let udcDocumentGraphModel = databaseOrmResultUDCDocumentGraphModel.object[0]
                let prevIdName = udcDocumentGraphModel.idName
                let prevNameSplit = documentParser.splitDocumentItem(udcSentencePatternDataGroupValueParam: udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue, language: udcDocumentGraphModel.language)
                let parentId = udcDocumentGraphModel.parentId.count == 0 ? "" : udcDocumentGraphModel.parentId[0]
                // Find the item, but should be the find item itself
//                if find.itemId != udcDocumentGraphModel._id && find.endSubCategoryId != parentId {
                    var foundLocal: Bool = false
                    if find.itemIdName == udcDocumentGraphModel.idName && reference.isIdNameChange {
                        foundLocal = true
                        udcDocumentGraphModel.idName = replace.itemIdName
                    }
                    if isSameObjectName && udcDocumentGraphModel.level <= 1 && !foundLocal {
                        foundLocal = true
                        udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.removeAll()
                        udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.append(contentsOf: udcSentencePatternGroupValue)
                    } else {
                        
                        for (udcspdgvIndex, udcspdgv) in udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.enumerated() {
                            // if item id, sub category id and category id matches (or) category id name matches for id name change alone
                            if (udcspdgv.itemId == find.itemId && udcspdgv.endSubCategoryId == find.endSubCategoryId && udcspdgv.endCategoryId == find.endCategoryId && udcspdgv.itemNameIndex == find.itemNameIndex) || (udcspdgv.endCategoryIdName == find.endCategoryIdName && reference.isIdNameChange) {
                                foundLocal = true
                                if replaceFull {
                                    udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].udcDocumentId = replace.udcDocumentId
                                    udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].item = replace.item
                                    udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].itemId = replace.itemId
                                    udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].itemIdName = replace.itemIdName
                                    udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].endSubCategoryId = replace.endSubCategoryId
                                    udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].endSubCategoryIdName = replace.endSubCategoryIdName
                                    udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].endCategoryId = replace.endCategoryId
                                    udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].endCategoryIdName = replace.endCategoryIdName
                                    udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].itemNameIndex = replace.itemNameIndex
                                } else if reference.isIdNameChange && udcspdgv.endCategoryIdName == find.endCategoryIdName && udcspdgv.itemId != find.itemId {
                                    udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].endCategoryIdName = replace.endCategoryIdName
                                } else {
                                    if isSameObjectName && udcDocumentGraphModel.level == 1 {
                                        udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.removeAll()
                                        udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.append(contentsOf: udcSentencePatternGroupValue)
                                    } else {
                                        udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].item = replace.item
                                        udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].itemIdName = replace.itemIdName
                                        if !replace.endCategoryIdName.isEmpty {
                                            udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].endCategoryIdName = replace.endCategoryIdName
                                        }
                                        udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].itemNameIndex = replace.itemNameIndex
                                    }
                                }
                            } /*else if (udcspdgv.itemId == find.itemId && (udcspdgv.endSubCategoryId == find.endSubCategoryId || udcspdgv.endSubCategoryId == find.endCategoryId) && udcspdgv.endCategoryIdName == find.endCategoryIdName && udcspdgv.itemNameIndex == find.itemNameIndex) || (udcspdgv.endCategoryIdName == find.endCategoryIdName && reference.isIdNameChange) {
                             foundLocal = true
                             if reference.isIdNameChange && udcspdgv.endCategoryIdName == find.endCategoryIdName && udcspdgv.itemId != find.itemId {
                             udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].endCategoryIdName = replace.endCategoryIdName
                             } else {
                             udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].item = replace.item
                             udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].itemIdName = replace.itemIdName
                             udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].endCategoryIdName = replace.endCategoryIdName
                             udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].itemNameIndex = replace.itemNameIndex
                             }
                             }*/
                            
                            
                            
                        }
                    }
                    // If found then update the model
                    if foundLocal {
                        udcDocumentGraphModel.udcSentencePattern = try processGrammar(neuronRequest: neuronRequest, neuronResponse: &neuronResponse, udcSentencePattern: udcDocumentGraphModel.udcSentencePattern, newSentence: true, wordIndex: 0, sentenceIndex: 0, documentLanguage: reference.language, textStartIndex: 0)
                        udcDocumentGraphModel.name = udcDocumentGraphModel.udcSentencePattern.sentence
                        // If children allowed other document type item or document item object
                        if (!reference.isIdNameChange && udcDocumentGraphModel.isChildrenAllowed) || reference.objectName == "UDCDocumentItem" && reference.language == "en" {
                            udcDocumentGraphModel.idName = "\(neuronUtility!.getCollectionName(udcDocumentTypeIdName: reference.udcDocumentTypeIdName)!).\(udcDocumentGraphModel.name.capitalized.replacingOccurrences(of: " ", with: ""))"
                        }
                        let databaseOrmResultUDCDocumentGraphModelUpdate = UDCDocumentGraphModel.update(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: reference.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentGraphModel)
                        if databaseOrmResultUDCDocumentGraphModelUpdate.databaseOrmError.count > 0 {
                            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentGraphModelUpdate.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentGraphModelUpdate.databaseOrmError[0].description))
                            return
                        }
                    }
                    // If reference again found, then replace in recursive
                    if !udcDocumentGraphModel.udcDocumentGraphModelReferenceId.isEmpty {
                        let nameSplit = documentParser.splitDocumentItem(udcSentencePatternDataGroupValueParam: udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue, language: udcDocumentGraphModel.language)
                        var nameIndexLocal = 0
                        var nameLocal = udcDocumentGraphModel.name
                        
                        if prevNameSplit.count == nameSplit.count {
                            for (nameIndex, name) in prevNameSplit.enumerated() {
                                if name != nameSplit[nameIndex] {
                                    nameIndexLocal = nameIndex
                                    nameLocal = nameSplit[nameIndex]
                                    break
                                }
                            }
                        }
                        let databaseOrmresultUdcDocumentGraphModelParent = UDCDocumentGraphModel.get(collectionName: reference.objectName, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentGraphModel.parentId[0], language: udcDocumentGraphModel.language)
                        let udcDocumentGraphModelParent = databaseOrmresultUdcDocumentGraphModelParent.object[0]
                        let udcSentencePatternDataGroupValueLocalFind = UDCSentencePatternDataGroupValue()
//                        if udcDocumentGraphModel.level <= 1 {
//
//                        } else {
                            if udcDocumentGraphModelParent.parentId.count > 0 {
                                let databaseOrmresultUdcDocumentGraphModelParentParent = UDCDocumentGraphModel.get(collectionName: reference.objectName, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentGraphModelParent.parentId[0])
                                let udcDocumentGraphModelParentParent = databaseOrmresultUdcDocumentGraphModelParentParent.object[0]
                                udcSentencePatternDataGroupValueLocalFind.endCategoryId = udcDocumentGraphModelParentParent._id
                                udcSentencePatternDataGroupValueLocalFind.endCategoryIdName = udcDocumentGraphModelParentParent.idName
                                udcSentencePatternDataGroupValueLocalFind.endSubCategoryId = udcDocumentGraphModelParent._id
                                udcSentencePatternDataGroupValueLocalFind.endSubCategoryIdName = udcDocumentGraphModelParent.idName
                            } else {
                                udcSentencePatternDataGroupValueLocalFind.endCategoryId = udcDocumentGraphModelParent._id
                                udcSentencePatternDataGroupValueLocalFind.endCategoryIdName = udcDocumentGraphModelParent.idName
                            }
//                        }
                        udcSentencePatternDataGroupValueLocalFind.itemId = udcDocumentGraphModel._id
                        udcSentencePatternDataGroupValueLocalFind.itemIdName = prevIdName
                        
                        let udcSentencePatternDataGroupValueLocalReplace = UDCSentencePatternDataGroupValue()
                        udcSentencePatternDataGroupValueLocalReplace.item = nameLocal
                        udcSentencePatternDataGroupValueLocalReplace.itemIdName = udcDocumentGraphModel.idName
                        // If it is title, then same as the one changed
                        if udcDocumentGraphModel.level == 1 {
                            udcSentencePatternDataGroupValueLocalReplace.endCategoryIdName = udcDocumentGraphModel.idName
                        }
                        udcSentencePatternDataGroupValueLocalReplace.itemNameIndex = nameIndexLocal
                        udcSentencePatternDataGroupValueLocalFind.itemNameIndex = nameIndexLocal
                        var found = false
                        try replaceDocumentItemInAllReferedDoc(referenceId: udcDocumentGraphModel.udcDocumentGraphModelReferenceId, referenceObjectName: reference.objectName, find: udcSentencePatternDataGroupValueLocalFind, replace: udcSentencePatternDataGroupValueLocalReplace, found: &found, udcSentencePatternGroupValue: udcSentencePatternGroupValue, replaceFull: false, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
                    }
//                }
            }
        }
        
    }
    
    private func checkDocumentItemUsedInAnyDocs(find: UDCSentencePatternDataGroupValue, documentLanguage: String, found: inout Bool, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) {
        // Loop through the document that are matching the document item language
        let databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
        if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocument.databaseOrmError[0].name, description: databaseOrmResultUDCDocument.databaseOrmError[0].description))
            return
        }
        let udcDocument = databaseOrmResultUDCDocument.object
        
        for udcd in udcDocument {
            
            if udcd.udcDocumentTypeIdName.isEmpty {
                continue
            }
            // Lock the document
            
            // Get the document model nodes traverse through the childrens, for matching items.
            let databaseOrmResultUDCDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcd.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcd.udcDocumentGraphModelId, language: documentLanguage)
            if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocument.databaseOrmError[0].name, description: databaseOrmResultUDCDocument.databaseOrmError[0].description))
                return
            }
            if databaseOrmResultUDCDocumentGraphModel.object.count > 0 {
                let udcDocumentGraphModel = databaseOrmResultUDCDocumentGraphModel.object[0]
                checkDocumentItemUsedInDoc(children: udcDocumentGraphModel.childrenId, udcDocument: udcd, find: find, documentLanguage: documentLanguage, found: &found, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
                if found {
                    return
                }
            }
            // Release the lock of document
            
        } // End of the loop document that are matching the document item language
    }
    
    
    private func checkDocumentItemUsedInDoc(children: [String], udcDocument: UDCDocument, find: UDCSentencePatternDataGroupValue, documentLanguage: String, found: inout Bool, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) {
        // Loop through the childrens
        for child in children {
            
            // Get the document model node for the children
            let databaseOrmResultUDCDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocument.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: child, language: documentLanguage)
            if databaseOrmResultUDCDocumentGraphModel.databaseOrmError.count == 0 {
                let udcDocumentGraphModel = databaseOrmResultUDCDocumentGraphModel.object[0]
                
                // Find the item, but should be the find item itself
                if find.itemId != udcDocumentGraphModel._id && find.endSubCategoryId != udcDocumentGraphModel.parentId[0]  {
                    for udcspdgv in udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue {
                        // if found set flag and return
                        if udcspdgv.itemId == find.itemId && udcspdgv.endSubCategoryId == find.endSubCategoryId && udcspdgv.endCategoryIdName == find.endCategoryIdName {
                            found = true
                            return
                        }
                    }
                } else if find.itemId != udcDocumentGraphModel._id && find.endCategoryId != udcDocumentGraphModel.parentId[0]  {
                    for udcspdgv in udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue {
                        // if found set flag and return
                        if udcspdgv.itemId == find.itemId && udcspdgv.endSubCategoryId == find.endSubCategoryId && udcspdgv.endCategoryIdName == find.endCategoryIdName {
                            found = true
                            return
                        }
                    }
                }
                // Do recursive if there are childrens
                if udcDocumentGraphModel.childrenId.count > 0 {
                    checkDocumentItemUsedInDoc(children: udcDocumentGraphModel.childrenId, udcDocument: udcDocument, find: find, documentLanguage: documentLanguage, found: &found, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
                    if found {
                        return
                    }
                }
            }
        } // End of the looop through childrenss
    }
    
    private func replaceWordDictionaryWithCategorizedInAllDocs(replace: UDCSentencePatternDataGroupValue, with: UDCSentencePatternDataGroupValue, documentLanguage: String, found: inout Bool, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) {
        // Loop through the document that are matching the document item language
        let databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!)
        if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocument.databaseOrmError[0].name, description: databaseOrmResultUDCDocument.databaseOrmError[0].description))
            return
        }
        let udcDocument = databaseOrmResultUDCDocument.object
        
        for udcd in udcDocument {
            
            if udcd.udcDocumentTypeIdName.isEmpty {
                continue
            }
            // Lock the document
            
            // Get the document model nodes traverse through the childrens, for matching items.
            // If found replace it by updating it.
            
            let databaseOrmResultUDCDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcd.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcd.udcDocumentGraphModelId)
            if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocument.databaseOrmError[0].name, description: databaseOrmResultUDCDocument.databaseOrmError[0].description))
                return
            }
            if databaseOrmResultUDCDocumentGraphModel.object.count > 0 {
                let udcDocumentGraphModel = databaseOrmResultUDCDocumentGraphModel.object[0]
                replaceWordDictionaryWithCategorizedInDoc(children: udcDocumentGraphModel.childrenId, udcDocument: udcd, replace: replace, with: with, documentLanguage: documentLanguage, found: &found, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            }
            // Release the lock of document
            
        } // End of the loop document that are matching the document item language
    }
    
    private func replaceWordDictionaryWithCategorizedInDoc(children: [String], udcDocument: UDCDocument, replace: UDCSentencePatternDataGroupValue, with: UDCSentencePatternDataGroupValue, documentLanguage: String, found: inout Bool, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) {
        var foundLocal: Bool = false
        // Loop through the childrens
        for child in children {
            
            // Get the document model node for the children
            let databaseOrmResultUDCDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocument.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: child)
            if databaseOrmResultUDCDocumentGraphModel.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentGraphModel.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentGraphModel.databaseOrmError[0].description))
                return
            }
            let udcDocumentGraphModel = databaseOrmResultUDCDocumentGraphModel.object[0]
            
            // First check if we are not replacing the source.
            // Then check if any of the text has the replace id name and end sub category, if found replace and save it
            if (replace.itemId != udcDocumentGraphModel._id && replace.endSubCategoryId != udcDocumentGraphModel.parentId[0]) && (with.itemId != udcDocumentGraphModel._id && with.endSubCategoryId != udcDocumentGraphModel.parentId[0])  {
                foundLocal = false
                for (udcspdgvIndex, udcspdgv) in udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.enumerated() {
                    // If found replace all accourances if any in single line
                    if udcspdgv.itemId == replace.itemId && udcspdgv.endSubCategoryId == replace.endSubCategoryId && udcspdgv.endCategoryIdName == replace.endCategoryIdName /*&& udcspdgv.itemNameIndex == replace.itemNameIndex*/ {
                        found = true
                        foundLocal = true
                        udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].item = with.item
                        udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].itemId = with.itemId
                        udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].itemIdName = with.itemIdName
                        udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].endSubCategoryId = with.endSubCategoryId
                        udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].endSubCategoryIdName = with.endSubCategoryIdName
                        
                        udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].endCategoryId = with.endCategoryId
                        udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].endCategoryIdName = with.endCategoryIdName
                        
                        udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].itemNameIndex = with.itemNameIndex
                    } else if udcspdgv.itemId == replace.itemId && udcspdgv.endCategoryId == replace.endSubCategoryId && udcspdgv.endCategoryIdName == replace.endCategoryIdName /*&& udcspdgv.itemNameIndex == replace.itemNameIndex*/  {
                        found = true
                        foundLocal = true
                        udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].item = with.item
                        udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].itemId = with.itemId
                        udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].itemIdName = with.itemIdName
                        udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].endSubCategoryId = with.endSubCategoryId
                        udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].endSubCategoryIdName = with.endSubCategoryIdName
                        
                        udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].endCategoryId = with.endCategoryId
                        udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].endCategoryIdName = with.endCategoryIdName
                        
                        udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[udcspdgvIndex].itemNameIndex = with.itemNameIndex
                        
                    }
                }
                // If atleast one is replaced, then update the model to reflect the change
                if foundLocal {
                    let databaseOrmResultUDCDocumentGraphModelUpdate = UDCDocumentGraphModel.update(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocument.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentGraphModel)
                    if databaseOrmResultUDCDocumentGraphModelUpdate.databaseOrmError.count > 0 {
                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentGraphModelUpdate.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentGraphModelUpdate.databaseOrmError[0].description))
                        return
                    }
                }
            }
            
            // Do recursive if there are childrens
            if udcDocumentGraphModel.childrenId.count > 0 {
                replaceWordDictionaryWithCategorizedInDoc(children: udcDocumentGraphModel.childrenId, udcDocument: udcDocument, replace: replace, with: with, documentLanguage: documentLanguage, found: &found, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            }
            
            
        } // End of the looop through childrenss
    }
    
    private func updateDocumentItemWithObjectDetails(objectId: String, objectName: String, documentItemId: String, udcDocumentTypeIdName: String, udcProfile: [UDCProfile], neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let databaseOrmUDCDocumentItemUpdate = UDCDocumentGraphModel.get(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, id: documentItemId)
        if databaseOrmUDCDocumentItemUpdate.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentItemUpdate.databaseOrmError[0].name, description: databaseOrmUDCDocumentItemUpdate.databaseOrmError[0].description))
            return
        }
        let udcDocumentItemUpdate = databaseOrmUDCDocumentItemUpdate.object[0]
        udcDocumentItemUpdate.objectId = objectId
        udcDocumentItemUpdate.objectName = objectName
        udcDocumentItemUpdate.udcDocumentTime.createdBy = documentParser.getUDCProfile(udcProfile: udcProfile, idName: "UDCProfileItem.Human")
        udcDocumentItemUpdate.udcDocumentTime.creationTime = Date()
        let databaseOrmResultudcDocumentGraphModelSave = UDCDocumentGraphModel.update(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentItemUpdate) as DatabaseOrmResult<UDCDocumentGraphModel>
        if databaseOrmResultudcDocumentGraphModelSave.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModelSave.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModelSave.databaseOrmError[0].description))
            return
        }
    }
    
    private func documentInsertItem(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let documentGraphInsertItemRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: DocumentGraphInsertItemRequest())
        
        var documentGraphInsertItemResponse = DocumentGraphInsertItemResponse()
        try documentInsertItem(documentGraphInsertItemRequest: documentGraphInsertItemRequest, documentGraphInsertItemResponse: &documentGraphInsertItemResponse, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, isGeneratedItem: false)
        
        let jsonUtilityDocumentGraphInsertItemResponse = JsonUtility<DocumentGraphInsertItemResponse>()
        let jsonDocumentDocumentGraphInsertItemResponse = jsonUtilityDocumentGraphInsertItemResponse.convertAnyObjectToJson(jsonObject: documentGraphInsertItemResponse)
        let neuronResponseLocal = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonDocumentDocumentGraphInsertItemResponse)
        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
            for error in neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError! {
                neuronResponseLocal.neuronOperation.neuronOperationStatus.neuronOperationError?.append(error)
            }
        }
        neuronResponse = neuronResponseLocal
    }
    
    private func documentInsertItem(documentGraphInsertItemRequest: DocumentGraphInsertItemRequest, documentGraphInsertItemResponse: inout DocumentGraphInsertItemResponse, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest, isGeneratedItem: Bool) throws {
        
        let documentLanguage = documentGraphInsertItemRequest.documentLanguage
        let interfaceLanguage = documentGraphInsertItemRequest.interfaceLanguage
        
        if documentGraphInsertItemRequest.level > 8 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "NoMoreThan5Levels", description: "No more than 8 levels"))
            return
        }
        // Line number
        documentGraphInsertItemRequest.itemIndex -= 1
        
        
        
        let databaseOrmResultudcDocumentGraphModelCheck = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphInsertItemRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: documentGraphInsertItemRequest.nodeId, language: documentLanguage)
        if databaseOrmResultudcDocumentGraphModelCheck.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModelCheck.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModelCheck.databaseOrmError[0].description))
            return
        }
        let udcDocumentGraphModelCheck = databaseOrmResultudcDocumentGraphModelCheck.object[0]
        var prevUdcSentencePatternDataGroupValue = [UDCSentencePatternDataGroupValue]()
        for udcspdgv in udcDocumentGraphModelCheck.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue {
            let udcSentencePatternDataGroupValue = UDCSentencePatternDataGroupValue()
            udcSentencePatternDataGroupValue.item = udcspdgv.item
            udcSentencePatternDataGroupValue.itemIdName = udcspdgv.itemIdName
            prevUdcSentencePatternDataGroupValue.append(udcSentencePatternDataGroupValue)
        }
        
        if documentGraphInsertItemRequest.udcDocumentTypeIdName == "UDCDocumentType.DocumentItem" {
            if udcDocumentGraphModelCheck.isChildrenAllowed && documentGraphInsertItemRequest.level > 1 {
                documentGraphInsertItemRequest.itemIndex -= 1
            }
        }
        
        let databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: documentGraphInsertItemRequest.documentId, language: documentLanguage)
        if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocument.databaseOrmError[0].name, description: databaseOrmResultUDCDocument.databaseOrmError[0].description))
            return
        }
        let udcDocument = databaseOrmResultUDCDocument.object[0]
        
        
        let udcSentencePatternDataGroupValueCheck = try getSentencePatternDataGroupValueForDocumentItem(optionItemObjectName: documentGraphInsertItemRequest.optionItemObjectName, optionItemIdName: documentGraphInsertItemRequest.optionItemId, optionDocumentIdName: documentGraphInsertItemRequest.optionDocumentIdName, optionItemNameIndex: documentGraphInsertItemRequest.optionItemNameIndex, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, language: documentLanguage, udcProfile: documentGraphInsertItemRequest.udcProfile, udcDocumentTypeIdName: documentGraphInsertItemRequest.udcDocumentTypeIdName)
        
        var validateDocumentGraphItemForInsertResponse = ValidateDocumentGraphItemForInsertResponse()
        let validateDocumentGraphItemForInsertRequest = ValidateDocumentGraphItemForInsertRequest()
        validateDocumentGraphItemForInsertRequest.documentGraphInsertItemRequest = documentGraphInsertItemRequest
        validateDocumentGraphItemForInsertRequest.udcValidationStepTypeIdName = "UDCValidationStep.Request"
        validateDocumentGraphItemForInsertRequest.insertDocumentModel = udcDocumentGraphModelCheck
        validateDocumentGraphItemForInsertRequest.documentLanguage = documentLanguage
        validateDocumentGraphItemForInsertRequest.udcDocument = udcDocument
        validateDocumentGraphItemForInsertRequest.udcDocumentTypeIdName = documentGraphInsertItemRequest.udcDocumentTypeIdName
        validateDocumentGraphItemForInsertRequest.udcSentencePatternDataGroupValue = udcSentencePatternDataGroupValueCheck
        
        try validateInsertRequest(validateDocumentGraphItemForInsertRequest: validateDocumentGraphItemForInsertRequest, validateDocumentGraphItemForInsertResponse: &validateDocumentGraphItemForInsertResponse, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        
        
        // Do general validation
        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
            return
        }
        
        
        // Do if specific validation
        if try isNeuronProcessingIt(operationName: "DocumentGraphNeuron.Document.Type.Process.InsertItem.Validated", udcDocumentTypeIdName: documentGraphInsertItemRequest.udcDocumentTypeIdName, neuronRequest: neuronRequest, neuronResponse: &neuronResponse) {
            let neuronRequestLocal = NeuronRequest()
            neuronRequestLocal.neuronSource._id = neuronRequest.neuronSource._id
            neuronRequestLocal.neuronOperation.synchronus = true
            neuronRequestLocal.neuronOperation._id = neuronRequest.neuronOperation._id
            neuronRequestLocal.neuronSource.name = DocumentGraphNeuron.getName()
            neuronRequestLocal.neuronSource.type = DocumentGraphNeuron.getName()
            neuronRequestLocal.neuronOperation.name = "DocumentMapNeuron.DocumentMapNode.Change"
            neuronRequestLocal.neuronOperation.parent = true
            let jsonUtilityValidateDocumentGraphItemForInsertRequest = JsonUtility<ValidateDocumentGraphItemForInsertRequest>()
            neuronRequestLocal.neuronOperation.neuronData.text = jsonUtilityValidateDocumentGraphItemForInsertRequest.convertAnyObjectToJson(jsonObject: validateDocumentGraphItemForInsertRequest)
            try callNeuron(neuronRequest: neuronRequestLocal, neuronResponse: &neuronResponse, operationName: "DocumentGraphNeuron.Document.Validate.Insert", udcDocumentTypeIdName: documentGraphInsertItemRequest.udcDocumentTypeIdName)
        }
        
        
        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
            return
        }
        
        
        
        if documentGraphInsertItemRequest.objectControllerRequest.editMode == false {
            for udcChoice in udcDocumentGraphModelCheck.udcViewItemCollection.udcChoice {
                for udcChoiceItem in udcChoice.udcChoiceItem {
                    if documentGraphInsertItemRequest.itemIndex >= udcChoiceItem.udcSentenceReference.startItemIndex &&
                        documentGraphInsertItemRequest.itemIndex <= udcChoiceItem.udcSentenceReference.endItemIndex &&
                        documentGraphInsertItemRequest.sentenceIndex >= udcChoiceItem.udcSentenceReference.startSentenceIndex &&
                        documentGraphInsertItemRequest.sentenceIndex <= udcChoiceItem.udcSentenceReference.endSentenceIndex {
                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "CannotInsertWithinChoice", description: "Cannot insert within choice!"))
                        return
                    }
                }
            }
        }
        
        var uvcViewModel = UVCViewModel()
        
        let uvcViewItemCollection = UVCViewItemCollection()
        var udcChoice = UDCChoice()
        var isViewItemFoundInCollection = false
        //        if !validateDocumentGraphItemForInsertResponse.result {
        //            return
        //        }
        var udcViewItemCollection: UDCViewItemCollection?
        let objectControllerResponse = ObjectControllerResponse()
        //*****************************************************************
        // Get sentence pattern based on the user selected document item, by sending to the
        // specific neuron. Sentence pattern contains all details about the item to be inserted!
        // The neuron contains the handling of specific document items and document neuron doesn't handle.
        //*****************************************************************
        var udcSentencePatternDataGroupValue = [UDCSentencePatternDataGroupValue]()
        var isNumber = documentGraphInsertItemRequest.item.isNumber
        var puncutationItem = documentGraphInsertItemRequest.optionItemId.isEmpty && documentGraphInsertItemRequest.udcDocumentTypeIdName != "UDCDocumentType.DocumentItem"
        if isNumber {
            let udcSentencePatternDataGroupValueLocal = UDCSentencePatternDataGroupValue()
            udcSentencePatternDataGroupValueLocal.category = "UDCGrammarCategory.Number"
            udcSentencePatternDataGroupValueLocal.item = documentGraphInsertItemRequest.item
            udcSentencePatternDataGroupValueLocal.itemType = "UDCJson.Number"
            udcSentencePatternDataGroupValue.append(udcSentencePatternDataGroupValueLocal)
        } else if puncutationItem && stringUtility.isPunctuation(text: documentGraphInsertItemRequest.item) {
            let udcSentencePatternDataGroupValueLocal = UDCSentencePatternDataGroupValue()
            udcSentencePatternDataGroupValueLocal.category = "UDCGrammarCategory.Punctuation"
            udcSentencePatternDataGroupValueLocal.item = documentGraphInsertItemRequest.item
            udcSentencePatternDataGroupValueLocal.itemType = "UDCJson.String"
            udcSentencePatternDataGroupValue.append(udcSentencePatternDataGroupValueLocal)
        }  else if puncutationItem {
            let udcSentencePatternDataGroupValueLocal = UDCSentencePatternDataGroupValue()
            udcSentencePatternDataGroupValueLocal.category = "UDCGrammarCategory.CommonNoun"
            udcSentencePatternDataGroupValueLocal.item = documentGraphInsertItemRequest.item
            udcSentencePatternDataGroupValueLocal.itemType = "UDCJson.String"
            udcSentencePatternDataGroupValue.append(udcSentencePatternDataGroupValueLocal)
        } else {
            if puncutationItem {
                
                //                let databaseOrmResultUDCDocumentItemMapNode = UDCDocumentItemMapNode.get("UDCDocumentItemMapNode.DocumentItems", udbcDatabaseOrm!, documentLanguage)
                //                var wordId: String = ""
                //                var grammarCategory: String = ""
                //                try addToWordDictionary(text: documentGraphInsertItemRequest.item, category: databaseOrmResultUDCDocumentItemMapNode.object[0].name.capitalized, documentLanguage: documentLanguage, udcProfile: documentGraphInsertItemRequest.udcProfile, udcDocumentTypeIdName: documentGraphInsertItemRequest.udcDocumentTypeIdName, wordId: &wordId, grammarCategory: &grammarCategory, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
                //                documentGraphInsertItemRequest.optionItemObjectName = "UDCDocumentItem.\(neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphInsertItemRequest.udcDocumentTypeIdName)!)WordDictionary"
                //                documentGraphInsertItemRequest.optionItemId = wordId
            }
            if documentGraphInsertItemRequest.objectControllerRequest.uvcViewItemType == "UVCViewItemType.Photo" && !documentGraphInsertItemRequest.isOption {
                let udcSentencePatternDataGroupValueLocal = UDCSentencePatternDataGroupValue()
                udcSentencePatternDataGroupValueLocal.category = "UDCGrammarCategory.CommonNoun"
                udcSentencePatternDataGroupValueLocal.endCategoryIdName = "UDCDocumentItemMapNode.Photo"
                udcSentencePatternDataGroupValueLocal.item = ""
                udcSentencePatternDataGroupValueLocal.itemType = "UDCJson.Photo"
                udcSentencePatternDataGroupValueLocal.uvcViewItemType = documentGraphInsertItemRequest.objectControllerRequest.uvcViewItemType
                udcSentencePatternDataGroupValue.append(udcSentencePatternDataGroupValueLocal)
            } else {
                var getSentencePatternForDocumentItemResponse = GetGraphSentencePatternForDocumentItemResponse()
                try getSentencePattern(existingModel: udcDocumentGraphModelCheck, objectControllerRequest: documentGraphInsertItemRequest.objectControllerRequest, optionItemObjectName: documentGraphInsertItemRequest.optionItemObjectName, optionItemIdName: documentGraphInsertItemRequest.optionItemId, optionItemNameIndex: documentGraphInsertItemRequest.optionItemNameIndex, optionDocumentIdName: documentGraphInsertItemRequest.optionDocumentIdName, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, language: documentLanguage, udcDocumentTypeIdName: documentGraphInsertItemRequest.udcDocumentTypeIdName, uvcViewItemType: documentGraphInsertItemRequest.objectControllerRequest.uvcViewItemType, itemIndex: documentGraphInsertItemRequest.itemIndex, item: documentGraphInsertItemRequest.item, isGeneratedItem: isGeneratedItem, documentLanguage: documentGraphInsertItemRequest.documentLanguage, treeLevel: documentGraphInsertItemRequest.level, udcProfile: documentGraphInsertItemRequest.udcProfile, getSentencePatternForDocumentItemResponse: &getSentencePatternForDocumentItemResponse)
                
                if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
                    return
                }
                
                
                
                if !documentGraphInsertItemRequest.optionItemId.isEmpty || documentGraphInsertItemRequest.udcDocumentTypeIdName == "UDCDocumentType.DocumentItem" {
                    getSentencePatternForDocumentItemResponse = neuronUtility!.getNeuronRequest(json: neuronResponse.neuronOperation.neuronData.text, object: GetGraphSentencePatternForDocumentItemResponse())
                    
                    if getSentencePatternForDocumentItemResponse.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.count == 1 {
                        getSentencePatternForDocumentItemResponse.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].isEditable = documentGraphInsertItemRequest.isDocumentItemEditable
                    }
                    udcViewItemCollection = getSentencePatternForDocumentItemResponse.udcViewItemCollection
                    
                    udcSentencePatternDataGroupValue.append(contentsOf:  getSentencePatternForDocumentItemResponse.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue)
                    
                }
                
                
            }
            //            }
        }
        
        
        let udcGrammarUtility = UDCGrammarUtility()
        var udcSentencePatternGroupValueArray = [UDCSentencePatternDataGroupValue]()
        udcSentencePatternGroupValueArray.append(contentsOf: udcSentencePatternDataGroupValue)
        var udcSentencePattern = UDCSentencePattern()
        udcGrammarUtility.getSetencePattern(udcSentencePattern: &udcSentencePattern, udcSentencePatternDataGroupValue: udcSentencePatternGroupValueArray)
        
        var isNewChild = false
        var udcDocumentGraphModelParent: UDCDocumentGraphModel?
        if documentGraphInsertItemRequest.parentId != nil {
            let databaseOrmResultudcDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphInsertItemRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: documentGraphInsertItemRequest.parentId!, language: documentLanguage)
            if databaseOrmResultudcDocumentGraphModel.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModel.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModel.databaseOrmError[0].description))
                return
            }
            udcDocumentGraphModelParent = databaseOrmResultudcDocumentGraphModel.object[0]
            isNewChild = udcDocumentGraphModelParent!.childrenId.count == 0 || documentGraphInsertItemRequest.nodeId.isEmpty
        }
        
        
        
        //*****************************************************************
        // Validate insert by calling neuron specific to document type
        // Retruns error if validation failure
        //*****************************************************************
        
        // Validation success proceed further!
        
        var newSentenceProcessing: Bool = false
        var udcDocumentGraphModel: UDCDocumentGraphModel?
        var udcDocumentGraphModelResponse: UDCDocumentGraphModel?
        var udcDocumentGraphModelModelList = [UDCDocumentGraphModel]()
        documentGraphInsertItemResponse.objectControllerResponse.groupUVCViewItemType = documentGraphInsertItemRequest.objectControllerRequest.groupUVCViewItemType
        documentGraphInsertItemResponse.objectControllerResponse.uvcViewItemType = documentGraphInsertItemRequest.objectControllerRequest.uvcViewItemType
        documentGraphInsertItemResponse.objectControllerResponse.udcViewItemName = documentGraphInsertItemRequest.objectControllerRequest.udcViewItemName!
        documentGraphInsertItemResponse.objectControllerResponse.udcViewItemId = documentGraphInsertItemRequest.objectControllerRequest.udcViewItemId!
        documentGraphInsertItemResponse.objectControllerResponse.editMode = documentGraphInsertItemRequest.objectControllerRequest.editMode
        documentGraphInsertItemResponse.objectControllerResponse.viewConfigPathIdName.append(contentsOf: documentGraphInsertItemRequest.objectControllerRequest.viewConfigPathIdName)
        
        //        udcSentencePatternDataGroupValue.item = documentGraphInsertItemRequest.itemWithSuffix
        
        // Parent doesn't have child, so add new child
        if isNewChild {
            udcDocumentGraphModel = UDCDocumentGraphModel()
            if documentGraphInsertItemRequest.isParent {
                udcDocumentGraphModel?.isChildrenAllowed = true
            }
            udcDocumentGraphModel!._id = try (udbcDatabaseOrm?.generateId())!
            udcDocumentGraphModelParent!.childrenId.append(udcDocumentGraphModel!._id)
            // Save parent
            let databaseOrmResultudcDocumentGraphModelUpdate = UDCDocumentGraphModel.updatePush(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphInsertItemRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentGraphModelParent!._id, childrenId: udcDocumentGraphModel!._id) as DatabaseOrmResult<UDCDocumentGraphModel>
            if databaseOrmResultudcDocumentGraphModelUpdate.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModelUpdate.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModelUpdate.databaseOrmError[0].description))
                return
            }
            udcDocumentGraphModel!.parentId.append(udcDocumentGraphModelParent!._id)
            udcDocumentGraphModel!.name = udcSentencePatternDataGroupValue[udcSentencePatternDataGroupValue.count - 1].item!
            udcDocumentGraphModel!.level = documentGraphInsertItemRequest.level
            udcDocumentGraphModel!.language = documentLanguage
            
            udcDocumentGraphModel!.udcProfile = documentGraphInsertItemRequest.udcProfile
            udcDocumentGraphModel!.udcSentencePattern = udcSentencePattern
            if udcViewItemCollection != nil {
                if udcViewItemCollection!.udcSentenceReference.count > 0 {
                    udcDocumentGraphModel?.udcViewItemCollection.udcSentenceReference.append(contentsOf: udcViewItemCollection!.udcSentenceReference)
                }
            }
            udcDocumentGraphModelResponse = udcDocumentGraphModel
            
        }
        else { // Parent has child, so just update the child
            
            let databaseOrmResultudcDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphInsertItemRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: documentGraphInsertItemRequest.nodeId, language: documentLanguage)
            if databaseOrmResultudcDocumentGraphModel.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModel.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModel.databaseOrmError[0].description))
                return
            }
            udcDocumentGraphModel = databaseOrmResultudcDocumentGraphModel.object[0]
            if documentGraphInsertItemRequest.isParent {
                udcDocumentGraphModel?.isChildrenAllowed = true
            }
            if udcViewItemCollection != nil {
                if isUDCViewCollectionAnyChange(udcViewCollection: udcViewItemCollection!) {
                    udcDocumentGraphModel?.udcViewItemCollection = udcViewItemCollection!
                }
                //                if udcViewItemCollection!.udcSentenceReference.count > 0 {
                //                    var index = 0
                //                    var found: Bool = false
                //                    for (udcsrIndex, udcsr) in udcViewItemCollection!.udcSentenceReference.enumerated() {
                //                        if udcsr.name == documentGraphInsertItemRequest.objectControllerRequest.udcViewItemName && udcsr._id == documentGraphInsertItemRequest.objectControllerRequest.udcViewItemId {
                //                            index = udcsrIndex
                //                            found = true
                //                            break
                //                        }
                //                    }
                //                    if found {
                //                        udcDocumentGraphModel?.udcViewItemCollection.udcSentenceReference[index] = udcViewItemCollection!.udcSentenceReference[index]
                //                    } else {
                //                        udcDocumentGraphModel?.udcViewItemCollection.udcSentenceReference.append(contentsOf: udcViewItemCollection!.udcSentenceReference)
                //                    }
                //                    documentGraphInsertItemResponse.objectControllerResponse.udcViewItemId = (udcDocumentGraphModel?.udcViewItemCollection.udcSentenceReference[index]._id)!
                //                    documentGraphInsertItemResponse.objectControllerResponse.udcViewItemName = (udcDocumentGraphModel?.udcViewItemCollection.udcSentenceReference[index].name)!
                //                }
            }
            
            if documentGraphInsertItemRequest.itemIndex > (udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphInsertItemRequest.sentenceIndex].udcSentencePatternDataGroupValue.count) - 1 {
                udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphInsertItemRequest.sentenceIndex].udcSentencePatternDataGroupValue.append(contentsOf: udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphInsertItemRequest.sentenceIndex].udcSentencePatternDataGroupValue)
                
            } else {
                udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphInsertItemRequest.sentenceIndex].udcSentencePatternDataGroupValue.insert(contentsOf: udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphInsertItemRequest.sentenceIndex].udcSentencePatternDataGroupValue, at: documentGraphInsertItemRequest.itemIndex)
            }
            
            
        }
        
        // Reduce the used count if it is an document item
        if udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphInsertItemRequest.sentenceIndex].udcSentencePatternDataGroupValue[documentGraphInsertItemRequest.itemIndex].itemIdName.hasPrefix("UDCDocumentItem.") {
        let itemId =  udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphInsertItemRequest.sentenceIndex].udcSentencePatternDataGroupValue[documentGraphInsertItemRequest.itemIndex].itemId
        try putReference(udcDocumentId: documentGraphInsertItemRequest.documentId, udcDocumentGraphModelId: itemId, udcDocumentTypeIdName: "UDCDocumentType.DocumentItem", objectUdcDocumentTypeIdName: documentGraphInsertItemRequest.udcDocumentTypeIdName, objectId: udcDocumentGraphModel!._id, objectName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphInsertItemRequest.udcDocumentTypeIdName)!, documentLanguage: documentLanguage, udcProfile: documentGraphInsertItemRequest.udcProfile, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
//        let databaseOrmResultUsedCountGet = UDCDocumentGraphModel.get(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, id: itemId)
//        let udcDocumentItemUsedCount = databaseOrmResultUsedCountGet.object[0]
//        let udcDocumentGraphModelReference = UDCDocumentGraphModelReference()
//        udcDocumentGraphModelReference.udcDocumentTypeIdName = documentGraphInsertItemRequest.udcDocumentTypeIdName
//        udcDocumentGraphModelReference.language = documentLanguage
//        udcDocumentGraphModelReference.udcDocumentId = documentGraphInsertItemRequest.documentId
//        udcDocumentGraphModelReference.objectId = udcDocumentGraphModel!._id
//        udcDocumentGraphModelReference.objectName = neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphInsertItemRequest.udcDocumentTypeIdName)!
//        udcDocumentItemUsedCount.udcDocumentGraphModelReference.append(udcDocumentGraphModelReference)
//        udcDocumentItemUsedCount.udcDocumentTime.changedBy = documentParser.getUDCProfile(udcProfile: documentGraphInsertItemRequest.udcProfile, idName: "UDCProfileItem.Human")
//        udcDocumentItemUsedCount.udcDocumentTime.changedTime = Date()
//        let databaseOrmResultUsedCountUpdate = UDCDocumentGraphModel.update(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentItemUsedCount)
//        if databaseOrmResultUsedCountUpdate.databaseOrmError.count > 0 {
//            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUsedCountUpdate.databaseOrmError[0].name, description: databaseOrmResultUsedCountUpdate.databaseOrmError[0].description))
//            return
//        }
        }
        
        if documentGraphInsertItemRequest.objectControllerRequest.editMode == true {
            udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphInsertItemRequest.sentenceIndex].udcSentencePatternDataGroupValue[documentGraphInsertItemRequest.itemIndex].uvcViewItemType = documentGraphInsertItemRequest.objectControllerRequest.uvcViewItemType
            udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphInsertItemRequest.sentenceIndex].udcSentencePatternDataGroupValue[documentGraphInsertItemRequest.itemIndex].groupUVCViewItemType = documentGraphInsertItemRequest.objectControllerRequest.groupUVCViewItemType
            
            // First choice item
            if documentGraphInsertItemRequest.objectControllerRequest.udcViewItemName!.isEmpty {
                
                if documentGraphInsertItemRequest.objectControllerRequest.groupUVCViewItemType == "UVCViewItemType.Choice" {
                    udcChoice.name = uvcViewGenerator.generateNameWithUniqueId(String(documentGraphInsertItemRequest.objectControllerRequest.groupUVCViewItemType.split(separator: ".")[1]))
                    documentGraphInsertItemResponse.objectControllerResponse.udcViewItemName = udcChoice.name
                    udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphInsertItemRequest.sentenceIndex].udcSentencePatternDataGroupValue[documentGraphInsertItemRequest.itemIndex].udcViewItemName = udcChoice.name
                    
                    let udcChoiceItem = UDCChoiceItem()
                    udcChoiceItem._id = (try udbcDatabaseOrm?.generateId())!
                    udcChoiceItem.udcSentenceReference.objectName = UDCDocumentGraphModel.getName()
                    udcChoiceItem.udcSentenceReference.startItemIndex = documentGraphInsertItemRequest.itemIndex
                    udcChoiceItem.udcSentenceReference.startSentenceIndex = documentGraphInsertItemRequest.sentenceIndex
                    udcChoiceItem.udcSentenceReference.endItemIndex = documentGraphInsertItemRequest.itemIndex
                    udcChoiceItem.udcSentenceReference.endSentenceIndex = documentGraphInsertItemRequest.sentenceIndex
                    udcChoiceItem.udcSentenceReference.objectId = udcDocumentGraphModel!._id
                    udcChoice.udcChoiceItem.append(udcChoiceItem)
                    udcDocumentGraphModel?.udcViewItemCollection.udcChoice.append(udcChoice)
                    udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphInsertItemRequest.sentenceIndex].udcSentencePatternDataGroupValue[documentGraphInsertItemRequest.itemIndex].udcViewItemId = udcChoiceItem._id
                    documentGraphInsertItemResponse.objectControllerResponse.udcViewItemId = udcChoiceItem._id
                } else {
                    let udcSentenceReference = UDCSentenceReference()
                    udcSentenceReference._id = (try udbcDatabaseOrm?.generateId())!
                    udcSentenceReference.name = uvcViewGenerator.generateNameWithUniqueId(String(documentGraphInsertItemRequest.objectControllerRequest.groupUVCViewItemType.split(separator: ".")[1]))
                    udcSentenceReference.objectName = UDCDocumentGraphModel.getName()
                    udcSentenceReference.startItemIndex = documentGraphInsertItemRequest.itemIndex
                    udcSentenceReference.startSentenceIndex = documentGraphInsertItemRequest.sentenceIndex
                    udcSentenceReference.endItemIndex = documentGraphInsertItemRequest.itemIndex
                    udcSentenceReference.endSentenceIndex = documentGraphInsertItemRequest.sentenceIndex
                    udcSentenceReference.objectId = udcDocumentGraphModel!._id
                    udcDocumentGraphModel?.udcViewItemCollection.udcSentenceReference.append(udcSentenceReference)
                    udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphInsertItemRequest.sentenceIndex].udcSentencePatternDataGroupValue[documentGraphInsertItemRequest.itemIndex].udcViewItemId = udcSentenceReference._id
                }
                // Only the first item is of specific view type and rest or Text so change
                documentGraphInsertItemResponse.objectControllerResponse.uvcViewItemType = "UVCViewItemType.Text"
            } else {
                udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphInsertItemRequest.sentenceIndex].udcSentencePatternDataGroupValue[documentGraphInsertItemRequest.itemIndex].uvcViewItemType = documentGraphInsertItemRequest.objectControllerRequest.uvcViewItemType
                
                if udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphInsertItemRequest.sentenceIndex].udcSentencePatternDataGroupValue[documentGraphInsertItemRequest.itemIndex].udcViewItemName.isEmpty { udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphInsertItemRequest.sentenceIndex].udcSentencePatternDataGroupValue[documentGraphInsertItemRequest.itemIndex].udcViewItemName = documentGraphInsertItemRequest.objectControllerRequest.udcViewItemName!
                } else {
                    documentGraphInsertItemRequest.objectControllerRequest.udcViewItemName = udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphInsertItemRequest.sentenceIndex].udcSentencePatternDataGroupValue[documentGraphInsertItemRequest.itemIndex].udcViewItemName
                    documentGraphInsertItemRequest.objectControllerRequest.udcViewItemId = udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphInsertItemRequest.sentenceIndex].udcSentencePatternDataGroupValue[documentGraphInsertItemRequest.itemIndex].udcViewItemId
                }
                
                if udcDocumentGraphModel?.udcViewItemCollection.udcChoice.count == 0 && documentGraphInsertItemRequest.objectControllerRequest.groupUVCViewItemType == "UVCViewItemType.Choice" {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "ChoiceShouldBeOnSameRowOrNotChoice", description: "Choice should be on same row or not a choice"))
                    return
                } else if udcDocumentGraphModel?.udcViewItemCollection.udcChoice.count == 0 && documentGraphInsertItemRequest.objectControllerRequest.groupUVCViewItemType == "UVCViewItemType.Sentence" {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "SentenceShouldBeOnSameRowOrNotChoice", description: "Sentence should be on same row or not a choice"))
                    return
                }// If same choice item
                if documentGraphInsertItemRequest.objectControllerRequest.uvcViewItemType == "UVCViewItemType.Text" {
                    if documentGraphInsertItemRequest.objectControllerRequest.groupUVCViewItemType == "UVCViewItemType.Choice" {
                        for udcChoiceLocal in (udcDocumentGraphModel?.udcViewItemCollection.udcChoice)! {
                            // Find the choice with the name
                            if udcChoiceLocal.name == documentGraphInsertItemRequest.objectControllerRequest.udcViewItemName {
                                for (udcChoiceItemLocalIndex, udcChoiceItemLocal) in udcChoiceLocal.udcChoiceItem.enumerated() {
                                    // Find the choice item with the inserted item index range and update the end indexes
                                    if udcChoiceItemLocal._id == documentGraphInsertItemRequest.objectControllerRequest.udcViewItemId {
                                        
                                        // Check if inside of previous item. If yes throw error
                                        if documentGraphInsertItemRequest.itemIndex < udcChoiceItemLocal.udcSentenceReference.startItemIndex && documentGraphInsertItemRequest.sentenceIndex == udcChoiceItemLocal.udcSentenceReference.startSentenceIndex {
                                            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "OutsideBoundaryOfCurrentItem", description: "Outside Boundary of Current Item"))
                                            return
                                        } else {
                                            for udcChoiceItemLocal1 in udcChoiceLocal.udcChoiceItem {
                                                // Check if inside of following items. If yes throw error
                                                if documentGraphInsertItemRequest.itemIndex > udcChoiceItemLocal1.udcSentenceReference.startItemIndex &&  udcChoiceItemLocal1._id != documentGraphInsertItemRequest.objectControllerRequest.udcViewItemId && udcChoiceItemLocal1.udcSentenceReference.startSentenceIndex > documentGraphInsertItemRequest.sentenceIndex {
                                                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "OutsideBoundaryOfCurrentItem", description: "Outside Boundary of Current Item"))
                                                    return
                                                }
                                            }
                                        }
                                        if udcChoiceItemLocal.udcSentenceReference.startSentenceIndex == documentGraphInsertItemRequest.sentenceIndex {
                                            
                                            if documentGraphInsertItemRequest.itemIndex <= udcChoiceItemLocal.udcSentenceReference.endItemIndex /*&& udcChoiceItemLocal.udcSentenceReference.endItemIndex != Int.max*/ {
                                                udcChoiceItemLocal.udcSentenceReference.endItemIndex += 1
                                            } else {
                                                udcChoiceItemLocal.udcSentenceReference.endItemIndex = documentGraphInsertItemRequest.itemIndex
                                            }
                                            if documentGraphInsertItemRequest.sentenceIndex < udcChoiceItemLocal.udcSentenceReference.endSentenceIndex /*&&
                                                 udcChoiceItemLocal.udcSentenceReference.endSentenceIndex != Int.max*/  {
                                                    udcChoiceItemLocal.udcSentenceReference.endSentenceIndex += 1
                                            } else {
                                                udcChoiceItemLocal.udcSentenceReference.endSentenceIndex = documentGraphInsertItemRequest.sentenceIndex
                                            }
                                            
                                            // If inserted in middle update the indexes of those following it
                                            if udcChoiceItemLocalIndex < udcChoiceLocal.udcChoiceItem.count - 1 {
                                                for index in udcChoiceItemLocalIndex + 1...udcChoiceLocal.udcChoiceItem.count - 1 {
                                                    udcChoiceLocal.udcChoiceItem[index].udcSentenceReference.startItemIndex += 1
                                                    udcChoiceLocal.udcChoiceItem[index].udcSentenceReference.endItemIndex += 1
                                                }
                                            }
                                        }
                                    }
                                }
                                break
                            }
                        }
                    } else if documentGraphInsertItemRequest.objectControllerRequest.groupUVCViewItemType == "UVCViewItemType.Sentence" {
                        for (udcSentenceReferenceIndex, udcSentenceReference) in (udcDocumentGraphModel?.udcViewItemCollection.udcSentenceReference)!.enumerated() {
                            if udcSentenceReference._id == documentGraphInsertItemRequest.objectControllerRequest.udcViewItemId {
                                
                                // Check if inside of previous item. If yes throw error
                                if documentGraphInsertItemRequest.itemIndex < udcSentenceReference.startItemIndex && documentGraphInsertItemRequest.sentenceIndex == udcSentenceReference.startSentenceIndex {
                                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "OutsideBoundaryOfCurrentItem", description: "Outside Boundary of Current Item"))
                                    return
                                } else {
                                    for udcSentenceReference in (udcDocumentGraphModel?.udcViewItemCollection.udcSentenceReference)! {
                                        // Check if inside of following items. If yes throw error
                                        if documentGraphInsertItemRequest.itemIndex > udcSentenceReference.startItemIndex &&  udcSentenceReference._id != documentGraphInsertItemRequest.objectControllerRequest.udcViewItemId && udcSentenceReference.startSentenceIndex > documentGraphInsertItemRequest.sentenceIndex {
                                            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "OutsideBoundaryOfCurrentItem", description: "Outside Boundary of Current Item"))
                                            return
                                        }
                                    }
                                }
                                if udcSentenceReference.startSentenceIndex == documentGraphInsertItemRequest.sentenceIndex {
                                    
                                    if documentGraphInsertItemRequest.itemIndex <= udcSentenceReference.endItemIndex /*&& udcChoiceItemLocal.udcSentenceReference.endItemIndex != Int.max*/ {
                                        udcSentenceReference.endItemIndex += 1
                                    } else {
                                        udcSentenceReference.endItemIndex = documentGraphInsertItemRequest.itemIndex
                                    }
                                    if documentGraphInsertItemRequest.sentenceIndex < udcSentenceReference.endSentenceIndex /*&&
                                         udcChoiceItemLocal.udcSentenceReference.endSentenceIndex != Int.max*/  {
                                            udcSentenceReference.endSentenceIndex += 1
                                    } else {
                                        udcSentenceReference.endSentenceIndex = documentGraphInsertItemRequest.sentenceIndex
                                    }
                                    
                                    // If inserted in middle update the indexes of those following it
                                    if udcSentenceReferenceIndex < (udcDocumentGraphModel?.udcViewItemCollection.udcSentenceReference)!.count - 1 {
                                        for index in udcSentenceReferenceIndex + 1...(udcDocumentGraphModel?.udcViewItemCollection.udcSentenceReference)!.count - 1 {
                                            udcDocumentGraphModel?.udcViewItemCollection.udcSentenceReference[index].startItemIndex += 1
                                            udcDocumentGraphModel?.udcViewItemCollection.udcSentenceReference[index].endItemIndex += 1
                                        }
                                    }
                                }
                                break
                            }
                        }
                    }
                    
                } // If new choice item
                else if documentGraphInsertItemRequest.objectControllerRequest.uvcViewItemType == documentGraphInsertItemRequest.objectControllerRequest.groupUVCViewItemType {
                    if documentGraphInsertItemRequest.objectControllerRequest.groupUVCViewItemType == "UVCViewItemType.Choice" {
                        for udcChoiceLocal in (udcDocumentGraphModel?.udcViewItemCollection.udcChoice)! {
                            // Find the choice with the name
                            if udcChoiceLocal.name == documentGraphInsertItemRequest.objectControllerRequest.udcViewItemName {
                                var foundItem: Bool = false
                                var itemIndex: Int = 0
                                for (udcChoiceItemLocalIndex, udcChoiceItemLocal) in udcChoiceLocal.udcChoiceItem.enumerated() {
                                    // Find the choice item with the inserted item index range and update the end indexes
                                    if (documentGraphInsertItemRequest.itemIndex >= udcChoiceItemLocal.udcSentenceReference.startItemIndex &&
                                        documentGraphInsertItemRequest.itemIndex <= udcChoiceItemLocal.udcSentenceReference.endItemIndex) &&
                                        (documentGraphInsertItemRequest.sentenceIndex >= udcChoiceItemLocal.udcSentenceReference.startSentenceIndex &&
                                            documentGraphInsertItemRequest.sentenceIndex <= udcChoiceItemLocal.udcSentenceReference.endSentenceIndex) {
                                        foundItem = true
                                        itemIndex = udcChoiceItemLocalIndex
                                        
                                        break
                                    }
                                }
                                let udcChoiceItem = UDCChoiceItem()
                                udcChoiceItem._id = (try udbcDatabaseOrm?.generateId())!
                                udcChoiceItem.udcSentenceReference.objectName = UDCDocumentGraphModel.getName()
                                udcChoiceItem.udcSentenceReference.startItemIndex = documentGraphInsertItemRequest.itemIndex
                                udcChoiceItem.udcSentenceReference.startSentenceIndex = documentGraphInsertItemRequest.sentenceIndex
                                udcChoiceItem.udcSentenceReference.endItemIndex = documentGraphInsertItemRequest.itemIndex
                                udcChoiceItem.udcSentenceReference.endSentenceIndex = documentGraphInsertItemRequest.sentenceIndex
                                udcChoiceItem.udcSentenceReference.objectId = udcDocumentGraphModel!._id
                                if !foundItem {
                                    udcChoiceLocal.udcChoiceItem.append(udcChoiceItem)
                                } else {
                                    udcChoiceLocal.udcChoiceItem.insert(udcChoiceItem, at: itemIndex)
                                    
                                    // If inserted in middle update the indexes of those following it
                                    if itemIndex < udcChoiceLocal.udcChoiceItem.count - 1 {
                                        for index in itemIndex + 1...udcChoiceLocal.udcChoiceItem.count - 1 {
                                            udcChoiceLocal.udcChoiceItem[index].udcSentenceReference.startItemIndex += 1
                                            udcChoiceLocal.udcChoiceItem[index].udcSentenceReference.endItemIndex += 1
                                        }
                                    }
                                }
                                
                                udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphInsertItemRequest.sentenceIndex].udcSentencePatternDataGroupValue[documentGraphInsertItemRequest.itemIndex].udcViewItemId = udcChoiceItem._id
                                documentGraphInsertItemResponse.objectControllerResponse.udcViewItemId = udcChoiceItem._id
                                
                                
                                break
                            }
                        }
                    } else if documentGraphInsertItemRequest.objectControllerRequest.groupUVCViewItemType == "UVCViewItemType.Sentence" {
                        for (udcSentenceReferenceIndex, udcSentenceReference) in (udcDocumentGraphModel?.udcViewItemCollection.udcSentenceReference)!.enumerated() {
                            if udcSentenceReference.name == documentGraphInsertItemRequest.objectControllerRequest.udcViewItemName {
                                var foundItem: Bool = false
                                var itemIndex: Int = 0
                                for (udcSentenceReferenceIndex, udcSentenceReference) in (udcDocumentGraphModel?.udcViewItemCollection.udcSentenceReference)!.enumerated() {
                                    // Find the choice item with the inserted item index range and update the end indexes
                                    if (documentGraphInsertItemRequest.itemIndex >= udcSentenceReference.startItemIndex &&
                                        documentGraphInsertItemRequest.itemIndex <= udcSentenceReference.endItemIndex) &&
                                        (documentGraphInsertItemRequest.sentenceIndex >= udcSentenceReference.startSentenceIndex &&
                                            documentGraphInsertItemRequest.sentenceIndex <= udcSentenceReference.endSentenceIndex) {
                                        foundItem = true
                                        itemIndex = udcSentenceReferenceIndex
                                        
                                        break
                                    }
                                }
                                let udcSentenceReferenceLocal = UDCSentenceReference()
                                udcSentenceReferenceLocal._id = (try udbcDatabaseOrm?.generateId())!
                                udcSentenceReferenceLocal.name = documentGraphInsertItemRequest.objectControllerRequest.udcViewItemName!
                                udcSentenceReferenceLocal.objectName = UDCDocumentGraphModel.getName()
                                udcSentenceReferenceLocal.startItemIndex = documentGraphInsertItemRequest.itemIndex
                                udcSentenceReferenceLocal.startSentenceIndex = documentGraphInsertItemRequest.sentenceIndex
                                udcSentenceReferenceLocal.endItemIndex = documentGraphInsertItemRequest.itemIndex
                                udcSentenceReferenceLocal.endSentenceIndex = documentGraphInsertItemRequest.sentenceIndex
                                udcSentenceReferenceLocal.objectId = udcDocumentGraphModel!._id
                                if !foundItem {
                                    udcDocumentGraphModel?.udcViewItemCollection.udcSentenceReference.append(udcSentenceReference)
                                } else {
                                    udcDocumentGraphModel?.udcViewItemCollection.udcSentenceReference.insert(udcSentenceReference, at: itemIndex)
                                    if udcSentenceReferenceIndex < (udcDocumentGraphModel?.udcViewItemCollection.udcSentenceReference)!.count - 1 {
                                        for index in udcSentenceReferenceIndex + 1...(udcDocumentGraphModel?.udcViewItemCollection.udcSentenceReference)!.count - 1 {
                                            udcDocumentGraphModel?.udcViewItemCollection.udcSentenceReference[index].startItemIndex += 1
                                            udcDocumentGraphModel?.udcViewItemCollection.udcSentenceReference[index].endItemIndex += 1
                                        }
                                    }
                                    
                                }
                                udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphInsertItemRequest.sentenceIndex].udcSentencePatternDataGroupValue[documentGraphInsertItemRequest.itemIndex].udcViewItemId = udcSentenceReferenceLocal._id
                                documentGraphInsertItemResponse.objectControllerResponse.udcViewItemId = udcSentenceReferenceLocal._id
                            }
                        }
                    }
                    // New choice item so, the next item onwards it will be Text
                    documentGraphInsertItemResponse.objectControllerResponse.uvcViewItemType = "UVCViewItemType.Text"
                }
            }
        }
        
        var profileId = ""
        for udcp in documentGraphInsertItemRequest.udcProfile {
            if udcp.udcProfileItemIdName == "UDCProfileItem.Human" {
                profileId = udcp.profileId
            }
        }
        
        
        for (udcspdgvIndex, udcspdgv) in udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphInsertItemRequest.sentenceIndex].udcSentencePatternDataGroupValue.enumerated() {
            // Check for positional changes
            if udcspdgv.udcDocumentItemGraphReferenceSource.count > 0 {
                if documentGraphInsertItemRequest.itemIndex < udcspdgvIndex {
                    for udcdigrs in udcspdgv.udcDocumentItemGraphReferenceSource {
                        let databaseOrmResultudcDocumentGraphModel1 = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphInsertItemRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcdigrs.nodeId, language: documentLanguage)
                        if databaseOrmResultudcDocumentGraphModel1.databaseOrmError.count > 0 {
                            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModel1.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModel1.databaseOrmError[0].description))
                            return
                        }
                        let udcDocumentGraphModelSource = databaseOrmResultudcDocumentGraphModel1.object[0]
                        
                        // Update the reference of the source to plus 1, since position changed
                        for (udcdigrtIndex, udcdigrt) in udcDocumentGraphModelSource.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[udcdigrs.referenceSentenceIndex].udcSentencePatternDataGroupValue[udcdigrs.referenceItemIndex].udcDocumentItemGraphReferenceTarget.enumerated() {
                            if udcdigrt.nodeId == udcDocumentGraphModel!._id && udcdigrt.referenceItemIndex == udcspdgvIndex - 1 && udcdigrt.referenceSentenceIndex == documentGraphInsertItemRequest.sentenceIndex {
                                // Reference index change model is same as inserted model, so put changes there also
                                if udcDocumentGraphModelSource._id == documentGraphInsertItemRequest.nodeId { udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[udcdigrs.referenceSentenceIndex].udcSentencePatternDataGroupValue[udcdigrs.referenceItemIndex].udcDocumentItemGraphReferenceTarget[udcdigrtIndex].referenceItemIndex += 1
                                }
                                udcdigrt.referenceItemIndex += 1
                            }
                        }
                        
                        // Update back
                        udcDocumentGraphModelSource.udcDocumentTime.changedBy = profileId
                        udcDocumentGraphModelSource.udcDocumentTime.changedTime = Date()
                        let databaseOrmResultudcDocumentGraphModelUpdate = UDCDocumentGraphModel.update(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphInsertItemRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentGraphModelSource)
                        if databaseOrmResultudcDocumentGraphModelUpdate.databaseOrmError.count > 0 {
                            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModelUpdate.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModelUpdate.databaseOrmError[0].description))
                            return
                        }
                    }
                }
            }
        }
        
        var textStartIndex: Int = 0
        // Set it so that first character is not capitalized
        if documentGraphInsertItemRequest.udcDocumentTypeIdName == "UDCDocumentType.DocumentItem" && documentGraphInsertItemRequest.documentLanguage == "en" {
            textStartIndex = -1
        } else if documentGraphInsertItemRequest.udcDocumentTypeIdName == "UDCDocumentType.DocumentItem" &&
            documentGraphInsertItemRequest.documentLanguage != "en" {
            if documentGraphInsertItemRequest.level > 1 {
                for udcspdgv in udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue {
                    if udcspdgv.itemIdName == "UDCDocumentItem.TranslationSeparator" {
                        break
                    }
                    textStartIndex += 1
                }
            } else {
                textStartIndex = -1
            }
        }
        
        // Process grammar (any modifications based on grammar)
        // 1) Capitalization of words
        // 2) Singular to plural
        // Etc.,
        udcDocumentGraphModel?.udcSentencePattern = try processGrammar(neuronRequest: neuronRequest, neuronResponse: &neuronResponse, udcSentencePattern: udcDocumentGraphModel!.udcSentencePattern, newSentence: true, wordIndex: documentGraphInsertItemRequest.itemIndex, sentenceIndex: documentGraphInsertItemRequest.sentenceIndex, documentLanguage: documentLanguage, textStartIndex: textStartIndex)
        udcDocumentGraphModel?.name = (udcDocumentGraphModel?.udcSentencePattern.sentence)!
        
        let getDocumentGraphIdNameRequest = GetDocumentGraphIdNameRequest()
        getDocumentGraphIdNameRequest.udcDocumentGraphModel = udcDocumentGraphModel!
        getDocumentGraphIdNameRequest.udcDocumentTypeIdName = documentGraphInsertItemRequest.udcDocumentTypeIdName
        getDocumentGraphIdNameRequest.documentLanguage = documentGraphInsertItemRequest.documentLanguage
        var getDocumentGraphIdNameResponse = GetDocumentGraphIdNameResponse()
        if try isNeuronProcessingIt(operationName: "DocumentGraphNeuron.Document.Type.Process.idName.Generated", udcDocumentTypeIdName: documentGraphInsertItemRequest.udcDocumentTypeIdName, neuronRequest: neuronRequest, neuronResponse: &neuronResponse) {
            var neuronRequestLocal1 = neuronRequest
            let jsonUtilityGetDocumentGraphIdNameRequest = JsonUtility<GetDocumentGraphIdNameRequest>()
            let jsonDocumentGetDocumentGraphIdNameRequest = jsonUtilityGetDocumentGraphIdNameRequest.convertAnyObjectToJson(jsonObject: getDocumentGraphIdNameRequest)
            neuronRequestLocal1.neuronOperation.neuronData.text = jsonDocumentGetDocumentGraphIdNameRequest
            let _ = try callNeuron(neuronRequest: neuronRequestLocal1, neuronResponse: &neuronResponse, operationName: "DocumentGraphNeuron.Document.IdName", udcDocumentTypeIdName: documentGraphInsertItemRequest.udcDocumentTypeIdName)
            getDocumentGraphIdNameResponse = neuronUtility!.getNeuronRequest(json: neuronResponse.neuronOperation.neuronData.text, object: GetDocumentGraphIdNameResponse())
            
        } else {
            try getDocumentIdName(getDocumentGraphIdNameRequest: getDocumentGraphIdNameRequest, getDocumentGraphIdNameResponse: &getDocumentGraphIdNameResponse, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        }
        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
            return
        }
        
        var prevIdName = udcDocumentGraphModel?.idName
        udcDocumentGraphModel?.name = getDocumentGraphIdNameResponse.name
        udcDocumentGraphModel?.idName = getDocumentGraphIdNameResponse.idName
        if prevIdName!.isEmpty {
            prevIdName = udcDocumentGraphModel?.idName
        }
        
        var documentTypeProcessRequest = DocumentGraphTypeProcessRequest()
        documentTypeProcessRequest.udcDocumentModelId = udcDocument.udcDocumentGraphModelId
        documentTypeProcessRequest.documentLanguage = documentLanguage
        documentTypeProcessRequest.udcDocumentTypeIdName = documentGraphInsertItemRequest.udcDocumentTypeIdName
        documentTypeProcessRequest.udcDocuemntGraphModel = udcDocumentGraphModel!
        documentTypeProcessRequest.udcProfile = documentGraphInsertItemRequest.udcProfile
        documentTypeProcessRequest.nodeIndex = documentGraphInsertItemRequest.nodeIndex
        var neuronRequestLocal1 = neuronRequest
        var jsonUtilityDocumentTypeProcessRequest = JsonUtility<DocumentGraphTypeProcessRequest>()
        var jsonDocumentGetSentencePatternForDocumentItemRequest = jsonUtilityDocumentTypeProcessRequest.convertAnyObjectToJson(jsonObject: documentTypeProcessRequest)
        neuronRequestLocal1.neuronOperation.neuronData.text = jsonDocumentGetSentencePatternForDocumentItemRequest
        var called = try callNeuron(neuronRequest: neuronRequestLocal1, neuronResponse: &neuronResponse, operationName: "DocumentGraphNeuron.Document.Type.Process.Post", udcDocumentTypeIdName: documentGraphInsertItemRequest.udcDocumentTypeIdName)
        
        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
            return
        }
        
        var documentTypeProcessResponse = DocumentGraphTypeProcessResponse()
        
        if called {
            documentTypeProcessResponse = neuronUtility!.getNeuronRequest(json: neuronResponse.neuronOperation.neuronData.text, object: DocumentGraphTypeProcessResponse())
        } else {
            if documentGraphInsertItemRequest.nodeIndex == 0 {
                documentTypeProcessResponse.udcSentencePatternUniqueDocumentTitle = udcDocumentGraphModel!.udcSentencePattern
            }/* else if documentGraphInsertItemRequest.nodeIndex == 1 {
                documentTypeProcessResponse.udcSentencePatternDocumentTitle = udcDocumentGraphModel!.udcSentencePattern
            }*/
        }
        
        
        var udcDocumentUpdated = false
//        if documentTypeProcessResponse.udcSentencePatternUniqueDocumentTitle.udcSentencePatternData.count > 0 {
//            let uniqueDocumentTitle = documentTypeProcessResponse.udcSentencePatternUniqueDocumentTitle.sentence
//            let datbaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, idName: udcDocument.idName)
//            if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
//                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocument.databaseOrmError[0].name, description: databaseOrmResultUDCDocument.databaseOrmError[0].description))
//                return
//            }
//            let idName: String = "UDCDocument.\(uniqueDocumentTitle.capitalized.replacingOccurrences(of: " ", with: ""))"
//            if udcDocument.idName != idName {
//                try updateIdName(name: "title", fromIdName: udcDocument.idName, fromDocumentIdName: udcDocument.idName, toIdName: getDocumentGraphIdNameResponse.idName, toDocumentIdName: idName, toTitle: uniqueDocumentTitle, toSentencePattern: documentTypeProcessResponse.udcSentencePatternUniqueDocumentTitle, udcProfile: documentGraphInsertItemRequest.udcProfile, udcDocument: udcDocument, udcDocumentTypeIdName: documentGraphInsertItemRequest.udcDocumentTypeIdName, documentLanguage: documentLanguage, udcDocumentUpdated: &udcDocumentUpdated, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
//
//            }
//        } else if documentTypeProcessResponse.udcSentencePatternDocumentTitle.udcSentencePatternData.count > 0 {
//            let documentTitle = documentTypeProcessResponse.udcSentencePatternDocumentTitle.sentence
//            if udcDocument.name != documentTitle {
//                documentGraphInsertItemResponse.documentTitle = documentTitle
//                let previousTitle = udcDocument.name
//                udcDocument.name = documentTitle
//                if documentGraphInsertItemRequest.udcDocumentTypeIdName == "UDCDocumentType.InterfaceBar" {
//                    let idName: String = "UDCInterfaceBar.\(documentTitle.capitalized.replacingOccurrences(of: " ", with: ""))"
//                    let previousIdName = "UDCInterfaceBar.\(previousTitle.capitalized.replacingOccurrences(of: " ", with: ""))"
//                    UDCApplicationInterfaceBar.remove(udbcDatabaseOrm: udbcDatabaseOrm!, udcInterfaceBarId: udcDocumentGraphModel!._id, udcInterfaceBarIdName: previousIdName, upcCompanyProfileId: documentGraphInsertItemRequest.upcCompanyProfileId, upcApplicationProfileId: documentGraphInsertItemRequest.upcApplicationProfileId, language: documentLanguage) as DatabaseOrmResult<UDCApplicationInterfaceBar>
//                    let databaseOrmResultUDCApplicationInterfaceBarGet = UDCApplicationInterfaceBar.get(udcInterfaceBarId: udcDocumentGraphModel!._id, udcInterfaceBarIdName: idName, upcCompanyProfileId: documentGraphInsertItemRequest.upcCompanyProfileId, upcApplicationProfileId: documentGraphInsertItemRequest.upcApplicationProfileId, udbcDatabaseOrm!, documentLanguage)
//                    if databaseOrmResultUDCApplicationInterfaceBarGet.databaseOrmError.count > 0 {
//                        let udcApplicationInterfaceBar = UDCApplicationInterfaceBar()
//                        udcApplicationInterfaceBar._id = try (udbcDatabaseOrm?.generateId())!
//                        udcApplicationInterfaceBar.upcCompanyProfileId = documentGraphInsertItemRequest.upcCompanyProfileId
//                        udcApplicationInterfaceBar.upcApplicationProfileId = documentGraphInsertItemRequest.upcApplicationProfileId
//                        udcApplicationInterfaceBar.udcInterfaceBarId = udcDocumentGraphModel!._id
//                        udcApplicationInterfaceBar.udcInterfaceBarIdName = idName
//                        udcApplicationInterfaceBar.language = documentLanguage
//                        let databaseOrmResultUDCApplicationInterfaceBar = UDCApplicationInterfaceBar.save(udbcDatabaseOrm: udbcDatabaseOrm!, object: udcApplicationInterfaceBar)
//                        if databaseOrmResultUDCApplicationInterfaceBar.databaseOrmError.count > 0 {
//                            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCApplicationInterfaceBar.databaseOrmError[0].name, description: databaseOrmResultUDCApplicationInterfaceBar.databaseOrmError[0].description))
//                            return
//                        }
//                    } else {
//                        let databaseOrmResultUDCApplicationInterfaceBar = UDCApplicationInterfaceBar.update(udbcDatabaseOrm: udbcDatabaseOrm!, udcInterfaceBarId: udcDocumentGraphModel!._id, udcInterfaceBarIdName: udcDocumentGraphModel!.idName, upcCompanyProfileId: documentGraphInsertItemRequest.upcCompanyProfileId, upcApplicationProfileId: documentGraphInsertItemRequest.upcApplicationProfileId, newUDCInterfaceBarIdName: idName,  language: documentLanguage) as DatabaseOrmResult<UDCApplicationInterfaceBar>
//                        if databaseOrmResultUDCApplicationInterfaceBar.databaseOrmError.count > 0 {
//                            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCApplicationInterfaceBar.databaseOrmError[0].name, description: databaseOrmResultUDCApplicationInterfaceBar.databaseOrmError[0].description))
//                            return
//                        }
//                    }
//                }
//
//                if documentGraphInsertItemRequest.udcDocumentTypeIdName == "UDCDocumentType.PhotoDocument" {
//                    // Change the title of the document item map node
//                    let databaseOrmResultUDCDocumentItemMapNode = UDCDocumentItemMapNode.get(objectId: documentGraphInsertItemRequest.documentId, udbcDatabaseOrm!, documentLanguage)
//                    if databaseOrmResultUDCDocumentItemMapNode.databaseOrmError.count == 0 {
//                        let idName: String = "UDCDocumentItemMapNode.\(documentTitle.capitalized.replacingOccurrences(of: " ", with: ""))"
//                        let udcDocumentItemMapNode = databaseOrmResultUDCDocumentItemMapNode.object[0]
//                        udcDocumentItemMapNode.name = documentTitle
//                        udcDocumentItemMapNode.idName = idName
//                        udcDocumentItemMapNode.pathIdName[udcDocumentItemMapNode.pathIdName.count - 1] = idName
//                        let _ = UDCDocumentItemMapNode.update(udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentItemMapNode) as DatabaseOrmResult<UDCDocumentItemMapNode>
//                    }
//                }
//                var udcDocumentUpdated: Bool = false
//                try updateIdName(name: "subTitle", fromIdName: udcDocument.idName, fromDocumentIdName: udcDocument.idName, toIdName: udcDocumentGraphModel!.idName, toDocumentIdName: "", toTitle: "", toSentencePattern: nil, udcProfile: documentGraphInsertItemRequest.udcProfile, udcDocument: udcDocument, udcDocumentTypeIdName: documentGraphInsertItemRequest.udcDocumentTypeIdName, documentLanguage: documentLanguage, udcDocumentUpdated: &udcDocumentUpdated, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
//
//            }
//        }
        
        if documentGraphInsertItemRequest.objectControllerRequest.uvcViewItemType == "UVCViewItemType.Photo" {
            var found: Bool = false
            for udcPhoto in udcDocumentGraphModel!.udcViewItemCollection.udcPhoto {
                if  udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphInsertItemRequest.sentenceIndex].udcSentencePatternDataGroupValue[documentGraphInsertItemRequest.itemIndex].udcViewItemId == udcPhoto._id {
                    found = true
                    break
                }
            }
            if !found {
                let udcPhoto = UDCPhoto()
                udcPhoto._id = (try udbcDatabaseOrm?.generateId())!
                
                var width: Double = 0
                var height: Double = 0
                getPhotoMeasurements(viewPathIdName: documentGraphInsertItemRequest.objectControllerRequest.viewPathIdName, width: &width, height: &height)
                var uvcMeasurement = UVCMeasurement()
                uvcMeasurement.type = UVCMeasurementType.Width.name
                uvcMeasurement.value = width
                udcPhoto.uvcMeasurement.append(uvcMeasurement)
                uvcMeasurement = UVCMeasurement()
                uvcMeasurement.type = UVCMeasurementType.Height.name
                uvcMeasurement.value = height
                udcPhoto.uvcMeasurement.append(uvcMeasurement)
                udcDocumentGraphModel!.udcViewItemCollection.udcPhoto.append(udcPhoto)
                udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphInsertItemRequest.sentenceIndex].udcSentencePatternDataGroupValue[documentGraphInsertItemRequest.itemIndex].udcViewItemId = udcPhoto._id
            }
        }
        
        if documentGraphInsertItemRequest.udcDocumentTypeIdName == "UDCDocumentType.Button" && documentGraphInsertItemRequest.nodeIndex == 0 {
            try updateDocumentItemWithObjectDetails(objectId: udcDocumentGraphModel!._id, objectName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphInsertItemRequest.udcDocumentTypeIdName)!, documentItemId: udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphInsertItemRequest.sentenceIndex].udcSentencePatternDataGroupValue[documentGraphInsertItemRequest.itemIndex].itemId, udcDocumentTypeIdName: documentGraphInsertItemRequest.udcDocumentTypeIdName, udcProfile: documentGraphInsertItemRequest.udcProfile, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        }
        
        
        // Save or Update technical model
        var databaseOrmResultudcDocumentGraphModelSave: DatabaseOrmResult<UDCDocumentGraphModel>?
        if isNewChild {
            udcDocumentGraphModel?.udcDocumentTime.createdBy = profileId
            udcDocumentGraphModel?.udcDocumentTime.creationTime = Date()
            databaseOrmResultudcDocumentGraphModelSave = UDCDocumentGraphModel.save(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphInsertItemRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentGraphModel!) as DatabaseOrmResult<UDCDocumentGraphModel>
        } else {
            udcDocumentGraphModel?.udcDocumentTime.changedBy = profileId
            udcDocumentGraphModel?.udcDocumentTime.changedTime = Date()
            databaseOrmResultudcDocumentGraphModelSave = UDCDocumentGraphModel.update(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphInsertItemRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentGraphModel!) as DatabaseOrmResult<UDCDocumentGraphModel>
        }
        if databaseOrmResultudcDocumentGraphModelSave!.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModelSave!.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModelSave!.databaseOrmError[0].description))
            return
        }
        
        // Update document model
        
        // Get and Update document model
        
        if !udcDocumentUpdated {
            udcDocument.udcDocumentTime.changedBy = profileId
            udcDocument.udcDocumentTime.changedTime = Date()
            let databaseOrmResultUDCDocumentUpdate = UDCDocument.update(udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocument)
            if databaseOrmResultUDCDocumentUpdate.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentUpdate.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentUpdate.databaseOrmError[0].description))
                return
            }
        }
        var prevNameSplit = documentParser.splitDocumentItem(udcSentencePatternDataGroupValueParam: prevUdcSentencePatternDataGroupValue, language: documentLanguage)
        if prevNameSplit.count == 0 {
            prevNameSplit.append("")
        }
        let nameSplit = documentParser.splitDocumentItem(udcSentencePatternDataGroupValueParam: udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue, language: documentLanguage)
        var nameIndexLocal = 0
        var nameLocal = udcDocumentGraphModel!.name
        
        if prevNameSplit.count == nameSplit.count {
            for (nameIndex, name) in prevNameSplit.enumerated() {
                if name != nameSplit[nameIndex] {
                    nameIndexLocal = nameIndex
                    nameLocal = nameSplit[nameIndex]
                    break
                }
            }
        }
        if !udcDocumentGraphModel!.name.isEmpty && !udcDocumentGraphModel!.udcDocumentGraphModelReferenceId.isEmpty {
            let udcSentencePatternDataGroupValueLocalFind = UDCSentencePatternDataGroupValue()
//            if udcDocumentGraphModelParent!.level <= 1 {
//
//            } else {
                if udcDocumentGraphModelParent == nil {
                    let databaseOrmResultudcDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphInsertItemRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: documentGraphInsertItemRequest.parentId!, language: documentLanguage)
                    if databaseOrmResultudcDocumentGraphModel.databaseOrmError.count > 0 {
                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModel.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModel.databaseOrmError[0].description))
                        return
                    }
                    udcDocumentGraphModelParent = databaseOrmResultudcDocumentGraphModel.object[0]
                }
                if udcDocumentGraphModelParent!.parentId.count > 0 {
                    let databaseOrmResultParentParent = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphInsertItemRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: (udcDocumentGraphModelParent?.parentId[0])!)
                    let udcDocumentGraphModelParentParent = databaseOrmResultParentParent.object[0]
                    udcSentencePatternDataGroupValueLocalFind.endCategoryIdName = udcDocumentGraphModelParentParent.idName
                    udcSentencePatternDataGroupValueLocalFind.endCategoryId = udcDocumentGraphModelParentParent._id
                    udcSentencePatternDataGroupValueLocalFind.endSubCategoryId = udcDocumentGraphModelParent!._id
                    udcSentencePatternDataGroupValueLocalFind.endSubCategoryIdName = udcDocumentGraphModelParent!.idName
                } else {
                    udcSentencePatternDataGroupValueLocalFind.endCategoryIdName = udcDocumentGraphModelParent!.idName
                    udcSentencePatternDataGroupValueLocalFind.endCategoryId = udcDocumentGraphModelParent!._id
                }
//            }
            udcSentencePatternDataGroupValueLocalFind.itemId = udcDocumentGraphModel!._id
            udcSentencePatternDataGroupValueLocalFind.itemIdName = prevIdName!
            
            let udcSentencePatternDataGroupValueLocalReplace = UDCSentencePatternDataGroupValue()
            udcSentencePatternDataGroupValueLocalReplace.item = nameLocal
            udcSentencePatternDataGroupValueLocalReplace.itemIdName = udcDocumentGraphModel!.idName
            // If it is title, then same as the one changed
            if udcDocumentGraphModel!.level == 1 {
                udcSentencePatternDataGroupValueLocalReplace.endCategoryIdName = udcDocumentGraphModel!.idName
            }
            udcSentencePatternDataGroupValueLocalReplace.itemNameIndex = nameIndexLocal
            udcSentencePatternDataGroupValueLocalFind.itemNameIndex = nameIndexLocal
            var found = false
            try replaceDocumentItemInAllReferedDoc(referenceId: udcDocumentGraphModel!.udcDocumentGraphModelReferenceId, referenceObjectName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphInsertItemRequest.udcDocumentTypeIdName)!, find: udcSentencePatternDataGroupValueLocalFind, replace: udcSentencePatternDataGroupValueLocalReplace, found: &found, udcSentencePatternGroupValue: udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue, replaceFull: false, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
                        
        }
        
        
        if documentGraphInsertItemRequest.udcDocumentTypeIdName == "UDCDocumentType.DocumentItem" && udcDocumentGraphModel!.level > 1 {
            
            
            if !documentGraphInsertItemRequest.optionDocumentIdName.isEmpty {
                let databaseOrmResultUdcDocumentDict = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: documentGraphInsertItemRequest.optionDocumentIdName)
                
                
                let udcDocumentDict = databaseOrmResultUdcDocumentDict.object[0]
                // If word dictionary item is added, then change to document item and remove the word dictionary
                if udcDocumentDict.idName.hasSuffix("WordDictionary") {
                    let udcSentencePatternDataGroupValueLocalReplace = UDCSentencePatternDataGroupValue()
                    udcSentencePatternDataGroupValueLocalReplace.endCategoryIdName = "UDCDocumentItem.\(udcDocumentDict.idName.components(separatedBy: ".")[1])"
                    udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[1].endCategoryIdName = "UDCDocumentItem.General"
                    udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].endCategoryIdName = "UDCDocumentItem.General"
                    udcSentencePatternDataGroupValueLocalReplace.item = udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[1].item
                    udcSentencePatternDataGroupValueLocalReplace.itemId = udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[1].itemId
                    udcSentencePatternDataGroupValueLocalReplace.itemNameIndex = nameIndexLocal
                    udcSentencePatternDataGroupValueLocalReplace.endCategoryId = udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[1].endCategoryId
                    udcSentencePatternDataGroupValueLocalReplace.endSubCategoryId = udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[1].endSubCategoryId
                    udcSentencePatternDataGroupValueLocalReplace.endSubCategoryIdName = udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[1].endSubCategoryIdName
                    let itemId = udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[1].itemId
                    var parentId = udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[1].endSubCategoryId
                    if parentId.isEmpty {
                        parentId = udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[1].endCategoryId
                        
                    }
                    
                    // Empty the things since it is moved to other place
                    udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[1].itemIdName = ""
                    udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[1].endSubCategoryId = ""
                    udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[1].itemId = ""
                    
                    udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].itemId = ""
                    
                    udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].itemIdName = ""
                    
                    udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].endSubCategoryId = ""
                    udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].endCategoryIdName = "UDCDocumentItem.General"
                    
                    // Save the updates
                    udcDocumentGraphModel?.udcDocumentTime.changedBy = profileId
                    udcDocumentGraphModel?.udcDocumentTime.changedTime = Date()
                    let databaseOrmResultUDCDocumentItemUpdate = UDCDocumentGraphModel.update(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphInsertItemRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentGraphModel!) as DatabaseOrmResult<UDCDocumentGraphModel>
                    if databaseOrmResultUDCDocumentItemUpdate.databaseOrmError.count > 0 {
                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentItemUpdate.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentItemUpdate.databaseOrmError[0].description))
                        return
                    }
                    
                    let udcSentencePatternDataGroupValueLocalWith = UDCSentencePatternDataGroupValue()
                    udcSentencePatternDataGroupValueLocalWith.item = nameLocal
                    udcSentencePatternDataGroupValueLocalWith.itemId = udcDocumentGraphModel!._id
                    udcSentencePatternDataGroupValueLocalWith.itemIdName = udcDocumentGraphModel!.idName
                    udcSentencePatternDataGroupValueLocalWith.itemNameIndex = nameIndexLocal
                    udcSentencePatternDataGroupValueLocalWith.endSubCategoryId = udcDocumentGraphModel!.parentId[0]
                    let databaseOrmResultUDCDocumentItemParent = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphInsertItemRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentGraphModel!.parentId[0], language: documentLanguage)
                    if databaseOrmResultUDCDocumentItemParent.databaseOrmError.count > 0 {
                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentItemParent.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentItemParent.databaseOrmError[0].description))
                        return
                    }
                    let udcDocumentItemParent = databaseOrmResultUDCDocumentItemParent.object[0]
                    udcSentencePatternDataGroupValueLocalWith.endSubCategoryIdName = udcDocumentItemParent.idName
                    if udcDocumentItemParent.parentId.count > 0 {
                        let databaseOrmResultUDCDocumentItemParentsParent = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphInsertItemRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentItemParent.parentId[0], language: documentLanguage)
                        if databaseOrmResultUDCDocumentItemParentsParent.databaseOrmError.count > 0 {
                            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentItemParentsParent.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentItemParentsParent.databaseOrmError[0].description))
                            return
                        }
                        let udcDocumentItemParentsParent = databaseOrmResultUDCDocumentItemParentsParent.object[0]
                        udcSentencePatternDataGroupValueLocalWith.endCategoryId = udcDocumentItemParentsParent._id
                        udcSentencePatternDataGroupValueLocalWith.endCategoryIdName = udcDocumentItemParentsParent.idName
                    }
                    udcSentencePatternDataGroupValueLocalWith.udcDocumentId = documentGraphInsertItemRequest.documentId
                    // replace with new ones if found
                    var found = false
                    let udcDocumentItemGraphModel = try getDocumentModel(udcDocumentGraphModelId: itemId, udcDocumentTypeIdName: "UDCDocumentType.DocumentItem", isLanguageChild: false, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
                    try replaceDocumentItemInAllReferedDoc(referenceId: udcDocumentItemGraphModel!.udcDocumentGraphModelReferenceId, referenceObjectName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphInsertItemRequest.udcDocumentTypeIdName)!, find: udcSentencePatternDataGroupValueLocalReplace, replace: udcSentencePatternDataGroupValueLocalWith, found: &found, udcSentencePatternGroupValue: udcDocumentGraphModel!.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue, replaceFull: true, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
//                    replaceWordDictionaryWithCategorizedInAllDocs(replace: udcSentencePatternDataGroupValueLocalReplace, with: udcSentencePatternDataGroupValueLocalWith, documentLanguage: documentGraphInsertItemRequest.documentLanguage, found: &found, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
                    
                    //                if found {`
                    
                    // remove the word dictionary child
                    let datbaseOrmResultUDCDocumentGraphModelRemove = UDCDocumentGraphModel.remove(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphInsertItemRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: itemId) as DatabaseOrmResult<UDCDocumentGraphModel>
                    if datbaseOrmResultUDCDocumentGraphModelRemove.databaseOrmError.count > 0 {
                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: datbaseOrmResultUDCDocumentGraphModelRemove.databaseOrmError[0].name, description: datbaseOrmResultUDCDocumentGraphModelRemove.databaseOrmError[0].description))
                        return
                    }
                    
                    let datbaseOrmResultUDCDocumentGraphModelRemoveFromParent = UDCDocumentGraphModel.updatePull(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphInsertItemRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: parentId, childrenId: itemId) as DatabaseOrmResult<UDCDocumentGraphModel>
                    if datbaseOrmResultUDCDocumentGraphModelRemoveFromParent.databaseOrmError.count > 0 {
                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: datbaseOrmResultUDCDocumentGraphModelRemoveFromParent.databaseOrmError[0].name, description: datbaseOrmResultUDCDocumentGraphModelRemoveFromParent.databaseOrmError[0].description))
                        return
                    }
                    //                }
                    
                    
                }
            }
            
            
            if documentGraphInsertItemRequest.documentLanguage == "en" {
                // Get all the documents that are not in english language
                let databaseOrmResultUDCDocumentOther = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, idName: udcDocument.idName, udcProfile: documentGraphInsertItemRequest.udcProfile, udcDocumentTypeIdName: documentGraphInsertItemRequest.udcDocumentTypeIdName, notEqualsLanguage: "en")
                if databaseOrmResultUDCDocumentOther.databaseOrmError.count == 0 {
                    let udcDocumentOther = databaseOrmResultUDCDocumentOther.object
                    
                    // Handle insert in those other language documents
                    for udcd in udcDocumentOther {
                        // Get the document model root node
                        let databaseOrmResultudcDocumentGraphModelOther = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphInsertItemRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcd.udcDocumentGraphModelId, language: udcd.language)
                        if databaseOrmResultudcDocumentGraphModelOther.databaseOrmError.count > 0 {
                            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModelOther.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModelOther.databaseOrmError[0].description))
                            return
                        }
                        let udcDocumentGraphModelOther = databaseOrmResultudcDocumentGraphModelOther.object[0]
                        var parentFound: Bool = false
                        var foundParentModel = UDCDocumentGraphModel()
                        var foundParentId: String = ""
                        
                        // Get the english language parent node of the node to process
                        let databaseOrmResultudcDocumentGraphModelLangSpeficEnglishTitleNode = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphInsertItemRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentGraphModel!.parentId[0], language: udcDocumentGraphModel!.language)
                        if databaseOrmResultudcDocumentGraphModelLangSpeficEnglishTitleNode.databaseOrmError.count > 0 {
                            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModelLangSpeficEnglishTitleNode.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModelLangSpeficEnglishTitleNode.databaseOrmError[0].description))
                            return
                        }
                        let udcDocumentGraphModelLangSpeficParentNode = databaseOrmResultudcDocumentGraphModelLangSpeficEnglishTitleNode.object[0]
                        
                        // Get the arrow photo
                        let databaseOrmResultUDCDocumentItem = UDCDocumentGraphModel.get(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, idName: "UDCDocumentItem.TranslationSeparator", language: "en")
                        if databaseOrmResultUDCDocumentItem.databaseOrmError.count > 0 {
                            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentItem.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentItem.databaseOrmError[0].description))
                            return
                        }
                        let udcDocumentItem = databaseOrmResultUDCDocumentItem.object[0]
                        
                        let databaseOrmResultUDCDocumentItemParent = UDCDocumentGraphModel.get(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentItem.parentId[0], language: "en")
                        if databaseOrmResultUDCDocumentItemParent.databaseOrmError.count > 0 {
                            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentItemParent.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentItemParent.databaseOrmError[0].description))
                            return
                        }
                        let udcDocumentItemParent = databaseOrmResultUDCDocumentItemParent.object[0]
                        let udcSentencePatternGroupValueLocal = UDCSentencePatternDataGroupValue()
                        udcSentencePatternGroupValueLocal.uvcViewItemType = "UVCViewItemType.Photo"
                        udcSentencePatternGroupValueLocal.itemId = udcDocumentItem.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].itemId
                        udcSentencePatternGroupValueLocal.itemIdName = udcDocumentItem.idName
                        udcSentencePatternGroupValueLocal.endCategoryIdName = udcDocumentItemParent.idName
                        udcSentencePatternGroupValueLocal.endCategoryId = udcDocumentItem.parentId[0]
                        let udcPhoto = UDCPhoto()
                        udcPhoto._id = try udbcDatabaseOrm!.generateId()
                        udcSentencePatternGroupValueLocal.udcViewItemId = udcPhoto._id
                        var uvcMeasurement = UVCMeasurement()
                        uvcMeasurement.type = UVCMeasurementType.Width.name
                        uvcMeasurement.value = 72
                        udcPhoto.uvcMeasurement.append(uvcMeasurement)
                        uvcMeasurement = UVCMeasurement()
                        uvcMeasurement.type = UVCMeasurementType.Height.name
                        uvcMeasurement.value = 72
                        udcPhoto.uvcMeasurement.append(uvcMeasurement)
                        let udcViewItemCollectionLocal = UDCViewItemCollection()
                        udcViewItemCollectionLocal.udcPhoto.append(udcPhoto)
                        
                        // Use the parent id name and pervious node id name to search.
                        // If parent matches then add to the respective parent as a
                        // new node or insert into existing node. if parent not found returns false
                        let result = try findAndProcessDocumentItem(mode: "insert", udcSentencePatternDataGroupValue: udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphInsertItemRequest.sentenceIndex].udcSentencePatternDataGroupValue, parentIdName: udcDocumentGraphModelLangSpeficParentNode.idName, findIdName: prevIdName!, inChildrens: udcDocumentGraphModelOther.childrenId, parentFound: &parentFound, foundParentModel: &foundParentModel, foundParentId: &foundParentId, nodeIndex: documentGraphInsertItemRequest.nodeIndex, itemIndex: documentGraphInsertItemRequest.itemIndex, level: documentGraphInsertItemRequest.level, udcDocumentTypeIdName: documentGraphInsertItemRequest.udcDocumentTypeIdName, udcProfile: documentGraphInsertItemRequest.udcProfile, isParent: documentGraphInsertItemRequest.isParent, generatedIdName: "", neuronRequest: neuronRequest, neuronResponse: &neuronResponse, documentLanguage: udcd.language, addUdcSentencePatternDataGroupValue: [udcSentencePatternGroupValueLocal], addUdcViewItemCollection: udcViewItemCollectionLocal, addUdcSentencePatternDataGroupValueIndex: [Int.max])
                        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
                            return
                        }
                        
                        // If parent not found, then add below the document title parent
                        if !result {
                            // Document language specific title node will be the parent for the new node, if parent is not found
                            var parentId: String = ""
                            var udcDocumentGraphModelOtherParent = UDCDocumentGraphModel()
                            if parentFound {
                                parentId = foundParentModel._id
                                udcDocumentGraphModelOtherParent = foundParentModel
                            } else {
                                parentId = udcDocumentGraphModelOther.childrenId[0]
                                let databaseOrmResultudcDocumentGraphModelOtherParent = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphInsertItemRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: parentId, language: udcd.language)
                                if databaseOrmResultudcDocumentGraphModelOtherParent.databaseOrmError.count > 0 {
                                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModelOtherParent.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModelOtherParent.databaseOrmError[0].description))
                                    return
                                }
                                udcDocumentGraphModelOtherParent = databaseOrmResultudcDocumentGraphModelOtherParent.object[0]
                            }
                            var insertedModelId = ""
                            try insertItem(isNewChild: true, udcSentencePatternDataGroupValue:  udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[documentGraphInsertItemRequest.sentenceIndex].udcSentencePatternDataGroupValue, parentModel: &udcDocumentGraphModelOtherParent, currentModel: &udcDocumentGraphModel!, nodeIndex: documentGraphInsertItemRequest.nodeIndex, itemIndex: documentGraphInsertItemRequest.itemIndex, sentenceIndex: 0, udcDocumentTypeIdName: documentGraphInsertItemRequest.udcDocumentTypeIdName, documentLanguage: udcd.language, udcProfile: documentGraphInsertItemRequest.udcProfile, addUdcSentencePatternDataGroupValue: [udcSentencePatternGroupValueLocal], addUdcViewItemCollection: udcViewItemCollectionLocal, addUdcSentencePatternDataGroupValueIndex: [Int.max], isParent: documentGraphInsertItemRequest.isParent, isInsertAtFirst: false, isInsertAtLast: true, insertedModelId: &insertedModelId, udcDocumentGraphModelReference: nil, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
                            
                        }
                        
                    }
                }
            }
        }
        
        documentTypeProcessRequest = DocumentGraphTypeProcessRequest()
        documentTypeProcessRequest.udcDocumentModelId = udcDocument.udcDocumentGraphModelId
        documentTypeProcessRequest.documentLanguage = documentLanguage
        documentTypeProcessRequest.udcDocumentTypeIdName = documentGraphInsertItemRequest.udcDocumentTypeIdName
        documentTypeProcessRequest.udcDocuemntGraphModel = udcDocumentGraphModel!
        documentTypeProcessRequest.udcProfile = documentGraphInsertItemRequest.udcProfile
        documentTypeProcessRequest.nodeIndex = documentGraphInsertItemRequest.nodeIndex
        neuronRequestLocal1 = neuronRequest
        jsonUtilityDocumentTypeProcessRequest = JsonUtility<DocumentGraphTypeProcessRequest>()
        jsonDocumentGetSentencePatternForDocumentItemRequest = jsonUtilityDocumentTypeProcessRequest.convertAnyObjectToJson(jsonObject: documentTypeProcessRequest)
        neuronRequestLocal1.neuronOperation.neuronData.text = jsonDocumentGetSentencePatternForDocumentItemRequest
        called = try callNeuron(neuronRequest: neuronRequestLocal1, neuronResponse: &neuronResponse, operationName: "DocumentGraphNeuron.Document.Type.Process.Post.AfterSave", udcDocumentTypeIdName: documentGraphInsertItemRequest.udcDocumentTypeIdName)
        
        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
            return
        }
        
        if called {
            documentTypeProcessResponse = neuronUtility!.getNeuronRequest(json: neuronResponse.neuronOperation.neuronData.text, object: DocumentGraphTypeProcessResponse())
        }
        
        
        documentGraphInsertItemResponse.objectControllerResponse.viewConfigurationOptions.append(UVCOptionViewModel())
        //*****************************************************************
        // Item Model ready, generate item view as per document type by sending to specific neuron
        //*****************************************************************
        
        var generateDocumentItemViewForInsertResponse = GenerateDocumentItemViewForInsertResponse()
        if udcDocumentGraphModelParent == nil {
            try generateDocumentItemViewForInsert(parentDocumentModel: nil, insertDocumentModel: udcDocumentGraphModel!, documentModelId: udcDocument.udcDocumentGraphModelId, udcSentencePatternDataGroupValue: udcSentencePatternDataGroupValue, documentGraphInsertItemRequest: documentGraphInsertItemRequest, isNewChild: isNewChild, isNewSentence: newSentenceProcessing, isEditable: true, isSentence: false, uvcViewItemCollection: uvcViewItemCollection,  generateDocumentItemViewForInsertResponse: &generateDocumentItemViewForInsertResponse, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else {
            try generateDocumentItemViewForInsert(parentDocumentModel: udcDocumentGraphModelParent!, insertDocumentModel: udcDocumentGraphModel!, documentModelId: udcDocument.udcDocumentGraphModelId, udcSentencePatternDataGroupValue: udcSentencePatternDataGroupValue, documentGraphInsertItemRequest: documentGraphInsertItemRequest, isNewChild: isNewChild, isNewSentence: newSentenceProcessing, isEditable: true, isSentence: false, uvcViewItemCollection: uvcViewItemCollection,  generateDocumentItemViewForInsertResponse: &generateDocumentItemViewForInsertResponse,neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        }
        
        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
            return
        }
        
        documentGraphInsertItemResponse.columnAdjustment = generateDocumentItemViewForInsertResponse.columnAdjustment
        documentGraphInsertItemResponse.lineAdjustment = generateDocumentItemViewForInsertResponse.lineAdjustment
        documentGraphInsertItemResponse.objectControllerResponse.uvcViewItemType = generateDocumentItemViewForInsertResponse.objectControllerResponse.uvcViewItemType
        
        
        for divid in generateDocumentItemViewForInsertResponse.documentItemViewInsertData {
            for uvcvm in divid.uvcDocumentGraphModel.uvcViewModel {
                if !uvcvm.udcViewItemName.isEmpty {
                    documentGraphInsertItemResponse.objectControllerResponse.udcViewItemName = generateDocumentItemViewForInsertResponse.objectControllerResponse.udcViewItemName
                    documentGraphInsertItemResponse.objectControllerResponse.udcViewItemId = generateDocumentItemViewForInsertResponse.objectControllerResponse.udcViewItemId
                    
                } else {
                    uvcvm.udcViewItemName = documentGraphInsertItemResponse.objectControllerResponse.udcViewItemName
                    uvcvm.udcViewItemId = documentGraphInsertItemResponse.objectControllerResponse.udcViewItemId
                }
            }
            
        }
        
        // Package response
        
        if generateDocumentItemViewForInsertResponse.documentItemViewInsertData.count > 0 {
            documentGraphInsertItemResponse.documentItemViewInsertData.append(contentsOf: generateDocumentItemViewForInsertResponse.documentItemViewInsertData)
        }
        if generateDocumentItemViewForInsertResponse.documentItemViewChangeData.count > 0 {
            documentGraphInsertItemResponse.documentItemViewChangeData.append(contentsOf: generateDocumentItemViewForInsertResponse.documentItemViewChangeData)
        }
        if generateDocumentItemViewForInsertResponse.documentItemViewDeleteData.count > 0 {
            documentGraphInsertItemResponse.documentItemViewDeleteData.append(contentsOf: generateDocumentItemViewForInsertResponse.documentItemViewDeleteData)
        }
        
    }
    
    private func getSentenceData(documentItemIdName: String, udcSentenceDataPatternGroupValue: inout UDCSentencePatternDataGroupValue, udcViewItemCollection: inout UDCViewItemCollection, width: Double, height: Double, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let databaseOrmResultUDCPhotoDocument = UDCDocumentGraphModel.get(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, idName: documentItemIdName, language: "en")
        if databaseOrmResultUDCPhotoDocument.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCPhotoDocument.databaseOrmError[0].name, description: databaseOrmResultUDCPhotoDocument.databaseOrmError[0].description))
            return
        }
        let udcPhotoDocument = databaseOrmResultUDCPhotoDocument.object[0]
        let photoId = udcPhotoDocument.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].itemId
        udcSentenceDataPatternGroupValue.uvcViewItemType = "UVCViewItemType.Photo"
        udcSentenceDataPatternGroupValue.itemId = photoId
        udcSentenceDataPatternGroupValue.endCategoryIdName = photoId
        let udcPhoto = UDCPhoto()
        udcPhoto._id = try udbcDatabaseOrm!.generateId()
        udcSentenceDataPatternGroupValue.udcViewItemId = udcPhoto._id
        
        var uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.Width.name
        uvcMeasurement.value = width
        udcPhoto.uvcMeasurement.append(uvcMeasurement)
        uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.Height.name
        uvcMeasurement.value = height
        udcPhoto.uvcMeasurement.append(uvcMeasurement)
        let udcViewItemCollection = UDCViewItemCollection()
        udcViewItemCollection.udcPhoto.append(udcPhoto)
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
    
    private func insertItem(isNewChild: Bool, udcSentencePatternDataGroupValue: [UDCSentencePatternDataGroupValue], parentModel: inout UDCDocumentGraphModel, currentModel: inout UDCDocumentGraphModel, nodeIndex: Int, itemIndex: Int, sentenceIndex: Int, udcDocumentTypeIdName: String, documentLanguage: String, udcProfile: [UDCProfile], addUdcSentencePatternDataGroupValue: [UDCSentencePatternDataGroupValue], addUdcViewItemCollection: UDCViewItemCollection, addUdcSentencePatternDataGroupValueIndex: [Int], isParent: Bool, isInsertAtFirst: Bool, isInsertAtLast: Bool, insertedModelId: inout String, udcDocumentGraphModelReference: [UDCDocumentGraphModelReference]?, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        var profileId = ""
        for udcp in udcProfile {
            if udcp.udcProfileItemIdName == "UDCProfileItem.Human" {
                profileId = udcp.profileId
            }
        }
        var udcDocumentGraphModelInProcess: UDCDocumentGraphModel?
        if isNewChild {
            udcDocumentGraphModelInProcess = UDCDocumentGraphModel()
            if isParent {
                udcDocumentGraphModelInProcess?.isChildrenAllowed = true
            }
            udcDocumentGraphModelInProcess!._id = try (udbcDatabaseOrm?.generateId())!
            insertedModelId = udcDocumentGraphModelInProcess!._id
            if isInsertAtFirst {
                parentModel.childrenId.insert(udcDocumentGraphModelInProcess!._id, at: 0)
            } else {
                parentModel.childrenId.append(udcDocumentGraphModelInProcess!._id)
            }
            
            // Save parent
            let databaseOrmResultudcDocumentGraphModelUpdate = UDCDocumentGraphModel.updatePush(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: parentModel._id, childrenId: udcDocumentGraphModelInProcess!._id) as DatabaseOrmResult<UDCDocumentGraphModel>
            if databaseOrmResultudcDocumentGraphModelUpdate.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModelUpdate.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModelUpdate.databaseOrmError[0].description))
                return
            }
            // Create new child
            udcDocumentGraphModelInProcess!.parentId.append(parentModel._id)
            
            udcDocumentGraphModelInProcess!.level = parentModel.level + 1
            
            udcDocumentGraphModelInProcess!.language = documentLanguage
            
            udcDocumentGraphModelInProcess!.udcProfile = udcProfile
            let udcGrammarUtility = UDCGrammarUtility()
            var udcSentencePattern = UDCSentencePattern()
            var udcSentencePatterDataGroupValueArray = [UDCSentencePatternDataGroupValue]()
            udcSentencePatterDataGroupValueArray.append(contentsOf: udcSentencePatternDataGroupValue)
            if addUdcSentencePatternDataGroupValue.count > 0 {
                for (udcspdvIdnex, udcspdv) in addUdcSentencePatternDataGroupValue.enumerated() {
                    if addUdcSentencePatternDataGroupValueIndex[udcspdvIdnex] != Int.max {
                        udcSentencePatterDataGroupValueArray.insert(udcspdv, at: addUdcSentencePatternDataGroupValueIndex[udcspdvIdnex])
                    }
                }
                for (udcspdvIdnex, udcspdv) in addUdcSentencePatternDataGroupValue.enumerated() {
                    if addUdcSentencePatternDataGroupValueIndex[udcspdvIdnex] == Int.max {
                        udcSentencePatterDataGroupValueArray.append(udcspdv)
                    }
                }
            }
            udcGrammarUtility.getSetencePattern(udcSentencePattern: &udcSentencePattern, udcSentencePatternDataGroupValue: udcSentencePatterDataGroupValueArray)
            udcDocumentGraphModelInProcess?.udcSentencePattern = udcSentencePattern
        } else {
            var udcSentencePatterDataGroupValueArray = [UDCSentencePatternDataGroupValue]()
            udcSentencePatterDataGroupValueArray.append(contentsOf: udcSentencePatternDataGroupValue)
            if itemIndex > (currentModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.count) - 1 {
                currentModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[sentenceIndex].udcSentencePatternDataGroupValue.append(contentsOf:  udcSentencePatterDataGroupValueArray)
                
            } else {
                currentModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[sentenceIndex].udcSentencePatternDataGroupValue.insert(contentsOf: udcSentencePatterDataGroupValueArray, at: itemIndex)
            }
            udcDocumentGraphModelInProcess = currentModel
            
        }
        
        if addUdcViewItemCollection.udcPhoto.count > 0 {
            udcDocumentGraphModelInProcess!.udcViewItemCollection.udcPhoto.append(contentsOf: addUdcViewItemCollection.udcPhoto)
        }
        
        udcDocumentGraphModelInProcess!.udcSentencePattern = try processGrammar(neuronRequest: neuronRequest, neuronResponse: &neuronResponse, udcSentencePattern: udcDocumentGraphModelInProcess!.udcSentencePattern, newSentence: true, wordIndex: itemIndex, sentenceIndex: 0, documentLanguage: documentLanguage, textStartIndex: -1)
        udcDocumentGraphModelInProcess!.name = udcDocumentGraphModelInProcess!.udcSentencePattern.sentence
        udcDocumentGraphModelInProcess!.idName = udcDocumentGraphModelInProcess!.name.capitalized.replacingOccurrences(of: " ", with: "")
        
        let getDocumentGraphIdNameRequest = GetDocumentGraphIdNameRequest()
        getDocumentGraphIdNameRequest.udcDocumentGraphModel = udcDocumentGraphModelInProcess!
        getDocumentGraphIdNameRequest.udcDocumentTypeIdName = udcDocumentTypeIdName
        getDocumentGraphIdNameRequest.documentLanguage = documentLanguage
        var getDocumentGraphIdNameResponse = GetDocumentGraphIdNameResponse()
        if try isNeuronProcessingIt(operationName: "DocumentGraphNeuron.Document.Type.Process.idName.Generated", udcDocumentTypeIdName: udcDocumentTypeIdName, neuronRequest: neuronRequest, neuronResponse: &neuronResponse) {
            let neuronRequestLocal1 = neuronRequest
            let jsonUtilityGetDocumentGraphIdNameRequest = JsonUtility<GetDocumentGraphIdNameRequest>()
            let jsonDocumentGetDocumentGraphIdNameRequest = jsonUtilityGetDocumentGraphIdNameRequest.convertAnyObjectToJson(jsonObject: getDocumentGraphIdNameRequest)
            neuronRequestLocal1.neuronOperation.neuronData.text = jsonDocumentGetDocumentGraphIdNameRequest
            try callNeuron(neuronRequest: neuronRequestLocal1, neuronResponse: &neuronResponse, operationName: "DocumentGraphNeuron.Document.IdName", udcDocumentTypeIdName: udcDocumentTypeIdName)
            getDocumentGraphIdNameResponse = neuronUtility!.getNeuronRequest(json: neuronResponse.neuronOperation.neuronData.text, object: GetDocumentGraphIdNameResponse())
        } else {
            try getDocumentIdName(getDocumentGraphIdNameRequest: getDocumentGraphIdNameRequest, getDocumentGraphIdNameResponse: &getDocumentGraphIdNameResponse, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        }
        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
            return
        }
        
        udcDocumentGraphModelInProcess!.name = getDocumentGraphIdNameResponse.name
        udcDocumentGraphModelInProcess!.idName = getDocumentGraphIdNameResponse.idName
        
        if isNewChild {
            
            udcDocumentGraphModelInProcess!.udcDocumentTime.createdBy = profileId
            udcDocumentGraphModelInProcess!.udcDocumentTime.creationTime = Date()
            let databaseOrmResultUDCDocumentGraphModelSave = UDCDocumentGraphModel.save(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentGraphModelInProcess!)
            if databaseOrmResultUDCDocumentGraphModelSave.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentGraphModelSave.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentGraphModelSave.databaseOrmError[0].description))
                return
            }
            if udcDocumentGraphModelReference != nil {
                for ref in udcDocumentGraphModelReference! {
                    try putReference(udcDocumentId: ref.udcDocumentId, udcDocumentGraphModelId: udcDocumentGraphModelInProcess!._id, udcDocumentTypeIdName: udcDocumentTypeIdName, objectUdcDocumentTypeIdName: ref.udcDocumentTypeIdName, objectId: ref.objectId, objectName: ref.objectName, documentLanguage: documentLanguage, udcProfile: udcProfile, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
                }
            }
        } else {
            
            udcDocumentGraphModelInProcess!.udcDocumentTime.changedBy = profileId
            udcDocumentGraphModelInProcess!.udcDocumentTime.changedTime = Date()
            let databaseOrmResultUDCDocumentGraphModelSave = UDCDocumentGraphModel.update(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentGraphModelInProcess!)
            if databaseOrmResultUDCDocumentGraphModelSave.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentGraphModelSave.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentGraphModelSave.databaseOrmError[0].description))
                return
            }
        }
    }
    
    private func changeItem(udcSentencePatternDataGroupValue: [UDCSentencePatternDataGroupValue], parentModel: inout UDCDocumentGraphModel, currentModel: inout UDCDocumentGraphModel, nodeIndex: Int, itemIndex: Int, sentenceIndex: Int, udcDocumentTypeIdName: String, documentLanguage: String, udcProfile: [UDCProfile], addUdcSentencePatternDataGroupValue: [UDCSentencePatternDataGroupValue], addUdcViewItemCollection: UDCViewItemCollection, addUdcSentencePatternDataGroupValueIndex: [Int], isParent: Bool, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        var profileId = ""
        for udcp in udcProfile {
            if udcp.udcProfileItemIdName == "UDCProfileItem.Human" {
                profileId = udcp.profileId
            }
        }
        var udcDocumentGraphModelInProcess: UDCDocumentGraphModel?
        currentModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[sentenceIndex].udcSentencePatternDataGroupValue[itemIndex].item = udcSentencePatternDataGroupValue[itemIndex].item
        currentModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[sentenceIndex].udcSentencePatternDataGroupValue[itemIndex].itemId = udcSentencePatternDataGroupValue[itemIndex].itemId
        currentModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[sentenceIndex].udcSentencePatternDataGroupValue[itemIndex].itemState = udcSentencePatternDataGroupValue[itemIndex].itemState
        currentModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[sentenceIndex].udcSentencePatternDataGroupValue[itemIndex].category = udcSentencePatternDataGroupValue[itemIndex].category
        currentModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[sentenceIndex].udcSentencePatternDataGroupValue[itemIndex].endCategoryIdName = udcSentencePatternDataGroupValue[itemIndex].endCategoryIdName
        currentModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[sentenceIndex].udcSentencePatternDataGroupValue[itemIndex].udcViewItemId = udcSentencePatternDataGroupValue[itemIndex].udcViewItemId
        udcDocumentGraphModelInProcess = currentModel
        
        if addUdcViewItemCollection.udcPhoto.count > 0 {
            var found: Bool = false
            for (udcvicIndex, udcvic) in udcDocumentGraphModelInProcess!.udcViewItemCollection.udcPhoto.enumerated() {
                if udcvic._id == currentModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[sentenceIndex].udcSentencePatternDataGroupValue[itemIndex].udcViewItemId {
                    udcDocumentGraphModelInProcess!.udcViewItemCollection.udcPhoto[udcvicIndex] = addUdcViewItemCollection.udcPhoto[0]
                    found = true
                    break
                }
            }
            if !found {
                udcDocumentGraphModelInProcess!.udcViewItemCollection.udcPhoto.append(contentsOf: addUdcViewItemCollection.udcPhoto)
            }
        }
        
        udcDocumentGraphModelInProcess!.udcSentencePattern = try processGrammar(neuronRequest: neuronRequest, neuronResponse: &neuronResponse, udcSentencePattern: udcDocumentGraphModelInProcess!.udcSentencePattern, newSentence: true, wordIndex: itemIndex, sentenceIndex: 0, documentLanguage: documentLanguage, textStartIndex: -1)
        udcDocumentGraphModelInProcess!.name = udcDocumentGraphModelInProcess!.udcSentencePattern.sentence
        udcDocumentGraphModelInProcess!.idName = udcDocumentGraphModelInProcess!.name.capitalized.replacingOccurrences(of: " ", with: "")
        
        let getDocumentGraphIdNameRequest = GetDocumentGraphIdNameRequest()
        getDocumentGraphIdNameRequest.udcDocumentGraphModel = udcDocumentGraphModelInProcess!
        getDocumentGraphIdNameRequest.udcDocumentTypeIdName = udcDocumentTypeIdName
        getDocumentGraphIdNameRequest.documentLanguage = documentLanguage
        var getDocumentGraphIdNameResponse = GetDocumentGraphIdNameResponse()
        if try isNeuronProcessingIt(operationName: "DocumentGraphNeuron.Document.Type.Process.idName.Generated", udcDocumentTypeIdName: udcDocumentTypeIdName, neuronRequest: neuronRequest, neuronResponse: &neuronResponse) {
            let neuronRequestLocal1 = neuronRequest
            let jsonUtilityGetDocumentGraphIdNameRequest = JsonUtility<GetDocumentGraphIdNameRequest>()
            let jsonDocumentGetDocumentGraphIdNameRequest = jsonUtilityGetDocumentGraphIdNameRequest.convertAnyObjectToJson(jsonObject: getDocumentGraphIdNameRequest)
            neuronRequestLocal1.neuronOperation.neuronData.text = jsonDocumentGetDocumentGraphIdNameRequest
            try callNeuron(neuronRequest: neuronRequestLocal1, neuronResponse: &neuronResponse, operationName: "DocumentGraphNeuron.Document.IdName", udcDocumentTypeIdName: udcDocumentTypeIdName)
            getDocumentGraphIdNameResponse = neuronUtility!.getNeuronRequest(json: neuronResponse.neuronOperation.neuronData.text, object: GetDocumentGraphIdNameResponse())
        } else {
            try getDocumentIdName(getDocumentGraphIdNameRequest: getDocumentGraphIdNameRequest, getDocumentGraphIdNameResponse: &getDocumentGraphIdNameResponse, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        }
        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
            return
        }
        
        
        
        udcDocumentGraphModelInProcess!.idName = getDocumentGraphIdNameResponse.idName
        udcDocumentGraphModelInProcess!.udcDocumentTime.changedBy = profileId
        udcDocumentGraphModelInProcess!.udcDocumentTime.changedTime = Date()
        let databaseOrmResultUDCDocumentGraphModelSave = UDCDocumentGraphModel.update(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentGraphModelInProcess!)
        if databaseOrmResultUDCDocumentGraphModelSave.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentGraphModelSave.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentGraphModelSave.databaseOrmError[0].description))
            return
        }
    }
    
    private func deleteItem(parentModel: inout UDCDocumentGraphModel, currentModel: inout UDCDocumentGraphModel, nodeIndex: Int, itemIndex: Int, sentenceIndex: Int, udcDocumentTypeIdName: String, documentLanguage: String, udcProfile: [UDCProfile], isParent: Bool, generatedIdName: String, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        var profileId = ""
        for udcp in udcProfile {
            if udcp.udcProfileItemIdName == "UDCProfileItem.Human" {
                profileId = udcp.profileId
            }
        }
        
        if !currentModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[itemIndex].udcViewItemId.isEmpty {
            var removeIndex = 0
            var found: Bool = false
            for (udcPhotoIndex, udcPhoto) in currentModel.udcViewItemCollection.udcPhoto.enumerated() {
                if udcPhoto._id == currentModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[itemIndex].udcViewItemId {
                    removeIndex = udcPhotoIndex
                    found = true
                    break
                }
            }
            if found {
                currentModel.udcViewItemCollection.udcPhoto.remove(at: removeIndex)
            }
        }
        currentModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.remove(at: itemIndex)
        var udcDocumentGraphModelInProcess: UDCDocumentGraphModel?
        udcDocumentGraphModelInProcess = currentModel
        
        udcDocumentGraphModelInProcess!.udcSentencePattern = try processGrammar(neuronRequest: neuronRequest, neuronResponse: &neuronResponse, udcSentencePattern: udcDocumentGraphModelInProcess!.udcSentencePattern, newSentence: true, wordIndex: itemIndex, sentenceIndex: 0, documentLanguage: documentLanguage, textStartIndex: -1)
        udcDocumentGraphModelInProcess!.name = udcDocumentGraphModelInProcess!.udcSentencePattern.sentence
        // Delete already generated an id so use that
        udcDocumentGraphModelInProcess!.idName = generatedIdName
        
        udcDocumentGraphModelInProcess!.udcDocumentTime.changedBy = profileId
        udcDocumentGraphModelInProcess!.udcDocumentTime.changedTime = Date()
        let databaseOrmResultUDCDocumentGraphModelSave = UDCDocumentGraphModel.update(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentGraphModelInProcess!)
        if databaseOrmResultUDCDocumentGraphModelSave.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentGraphModelSave.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentGraphModelSave.databaseOrmError[0].description))
            return
        }
    }
    
    private func deleteLine(currentModel: inout UDCDocumentGraphModel, udcDocumentTypeIdName: String, documentLanguage: String, udcProfile: [UDCProfile], neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let databaseOrmUDCDocumentGraphModelRemove = UDCDocumentGraphModel.remove(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: currentModel._id, language: documentLanguage) as DatabaseOrmResult<UDCDocumentGraphModel>
        if databaseOrmUDCDocumentGraphModelRemove.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentGraphModelRemove.databaseOrmError[0].name, description: databaseOrmUDCDocumentGraphModelRemove.databaseOrmError[0].description))
            return
        }
        
        // Remove the node from parent
        let databaseOrmResultudcDocumentGraphModelUpdate = UDCDocumentGraphModel.updatePull(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: currentModel.parentId[0], childrenId: currentModel._id) as DatabaseOrmResult<UDCDocumentGraphModel>
        if databaseOrmResultudcDocumentGraphModelUpdate.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModelUpdate.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModelUpdate.databaseOrmError[0].description))
            return
        }
    }
    
    private func deleteLineAndInsertAtFirst(currentModel: inout UDCDocumentGraphModel, udcDocumentTypeIdName: String, documentLanguage: String, udcProfile: [UDCProfile], neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
      
        // Remove the node from parent
        let databaseOrmResultudcDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: currentModel.parentId[0]) as DatabaseOrmResult<UDCDocumentGraphModel>
        if databaseOrmResultudcDocumentGraphModel.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModel.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModel.databaseOrmError[0].description))
            return
        }
        let udcDocumentModel = databaseOrmResultudcDocumentGraphModel.object[0]
        var removeIndex = 0
        for (idIndex, id) in udcDocumentModel.childrenId.enumerated() {
            if id == currentModel._id {
                if idIndex == 0 {
                    return // Already in first
                }
                removeIndex = idIndex
            }
        }
        udcDocumentModel.childrenId.remove(at: removeIndex)
        udcDocumentModel.childrenId.insert(currentModel._id, at: 0)
        let databaseOrmResultudcDocumentGraphModelUpdate = UDCDocumentGraphModel.update(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentModel)
        if databaseOrmResultudcDocumentGraphModelUpdate.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModelUpdate.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModelUpdate.databaseOrmError[0].description))
            return
        }
        
    }
    
    private func findAndProcessDocumentItem(mode: String, udcSentencePatternDataGroupValue: [UDCSentencePatternDataGroupValue], parentIdName: String, findIdName: String, inChildrens: [String], parentFound: inout Bool, foundParentModel: inout UDCDocumentGraphModel, foundParentId: inout String, nodeIndex: Int, itemIndex: Int, level: Int, udcDocumentTypeIdName: String, udcProfile: [UDCProfile], isParent: Bool, generatedIdName: String, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest, documentLanguage: String, addUdcSentencePatternDataGroupValue: [UDCSentencePatternDataGroupValue], addUdcViewItemCollection: UDCViewItemCollection, addUdcSentencePatternDataGroupValueIndex: [Int]) throws -> Bool {
        
        for (index, child) in inChildrens.enumerated() {
            // Get each children of the parent that is to be found
            let databaseOrmResultudcDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: child, language: documentLanguage)
            if databaseOrmResultudcDocumentGraphModel.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModel.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModel.databaseOrmError[0].description))
                return false
            }
            var udcDocumentGraphModel = databaseOrmResultudcDocumentGraphModel.object[0]
            
            // Parent found, so set a flag and store the parent model for processing
            if udcDocumentGraphModel.idName == parentIdName && !parentFound {
                foundParentModel = udcDocumentGraphModel
                parentFound = true
            }
            
            // Parent found, then child item found, so insert in the found child
            if (parentFound && (udcDocumentGraphModel.idName == findIdName)) {
                if mode == "insert" {
                    var insertedModelId = ""
                    let isNewChild = udcDocumentGraphModel.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.count == 0
                    try insertItem(isNewChild: isNewChild, udcSentencePatternDataGroupValue: udcSentencePatternDataGroupValue, parentModel: &foundParentModel, currentModel: &udcDocumentGraphModel, nodeIndex: nodeIndex, itemIndex: itemIndex, sentenceIndex: 0, udcDocumentTypeIdName: udcDocumentTypeIdName, documentLanguage: documentLanguage, udcProfile: udcProfile, addUdcSentencePatternDataGroupValue: addUdcSentencePatternDataGroupValue, addUdcViewItemCollection: addUdcViewItemCollection, addUdcSentencePatternDataGroupValueIndex: addUdcSentencePatternDataGroupValueIndex, isParent: isParent, isInsertAtFirst: false, isInsertAtLast: true, insertedModelId: &insertedModelId, udcDocumentGraphModelReference: nil, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
                    return true
                } else if mode == "change" {
                    try changeItem(udcSentencePatternDataGroupValue: udcSentencePatternDataGroupValue, parentModel: &foundParentModel, currentModel: &udcDocumentGraphModel, nodeIndex: nodeIndex, itemIndex: itemIndex, sentenceIndex: 0, udcDocumentTypeIdName: udcDocumentTypeIdName, documentLanguage: documentLanguage, udcProfile: udcProfile, addUdcSentencePatternDataGroupValue: addUdcSentencePatternDataGroupValue, addUdcViewItemCollection: addUdcViewItemCollection, addUdcSentencePatternDataGroupValueIndex: addUdcSentencePatternDataGroupValueIndex, isParent: isParent, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
                } else if mode == "delete" {
                    try deleteItem(parentModel: &foundParentModel, currentModel: &udcDocumentGraphModel, nodeIndex: nodeIndex, itemIndex: itemIndex, sentenceIndex: 0, udcDocumentTypeIdName: udcDocumentTypeIdName, documentLanguage: documentLanguage, udcProfile: udcProfile, isParent: isParent, generatedIdName: generatedIdName, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
                } else if mode == "deleteLine" {
                    try deleteLine(currentModel: &udcDocumentGraphModel, udcDocumentTypeIdName: udcDocumentTypeIdName, documentLanguage: documentLanguage, udcProfile: udcProfile, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
                }
                return true
            }
            if udcDocumentGraphModel.childrenId.count > 0 {
                let result = try findAndProcessDocumentItem(mode: mode, udcSentencePatternDataGroupValue: udcSentencePatternDataGroupValue, parentIdName: parentIdName, findIdName: findIdName, inChildrens: udcDocumentGraphModel.childrenId, parentFound: &parentFound, foundParentModel: &foundParentModel, foundParentId: &foundParentId, nodeIndex: nodeIndex, itemIndex: itemIndex, level: level, udcDocumentTypeIdName: udcDocumentTypeIdName, udcProfile: udcProfile, isParent: isParent, generatedIdName: generatedIdName, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, documentLanguage: documentLanguage, addUdcSentencePatternDataGroupValue: addUdcSentencePatternDataGroupValue, addUdcViewItemCollection: addUdcViewItemCollection, addUdcSentencePatternDataGroupValueIndex: addUdcSentencePatternDataGroupValueIndex)
                if result {
                    return result
                }
            }
        }
        
        return false
    }
    
    private func getDocumentItemListOptionView(udcDocumentGraphModel: UDCDocumentGraphModel, documentGraphItemReferenceRequest: DocumentGraphItemReferenceRequest, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let neuronRequestLocal = neuronRequest
        let getDocumentItemListOptionViewRequest = GetDocumentItemListOptionViewRequest()
        getDocumentItemListOptionViewRequest.udcDocumentGraphModel = udcDocumentGraphModel
        getDocumentItemListOptionViewRequest.documentGraphItemReferenceRequest = documentGraphItemReferenceRequest
        getDocumentItemListOptionViewRequest.udcDocumentItemMapNodeIdName = documentGraphItemReferenceRequest.pathIdName[documentGraphItemReferenceRequest.pathIdName.count - 1]
        let jsonUtilityGetDocumentItemListOptionViewRequest = JsonUtility<GetDocumentItemListOptionViewRequest>()
        let jsonGetDocumentItemListOptionViewRequest = jsonUtilityGetDocumentItemListOptionViewRequest.convertAnyObjectToJson(jsonObject: getDocumentItemListOptionViewRequest)
        neuronRequestLocal.neuronOperation.neuronData.text = jsonGetDocumentItemListOptionViewRequest
        try callNeuron(neuronRequest: neuronRequestLocal, neuronResponse: &neuronResponse, operationName: "DocumentGraphNeuron.Generate.DocumentItem.View.Reference", udcDocumentTypeIdName: documentGraphItemReferenceRequest.udcDocumentTypeIdName)
    }
    
    private func generateDocumentItemViewForInsert(parentDocumentModel: UDCDocumentGraphModel?, insertDocumentModel: UDCDocumentGraphModel, documentModelId: String, udcSentencePatternDataGroupValue: [UDCSentencePatternDataGroupValue], documentGraphInsertItemRequest: DocumentGraphInsertItemRequest, isNewChild: Bool, isNewSentence: Bool, isEditable: Bool, isSentence: Bool, uvcViewItemCollection: UVCViewItemCollection?, generateDocumentItemViewForInsertResponse: inout GenerateDocumentItemViewForInsertResponse, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let neuronRequestLocal = neuronRequest
        let generateDocumentItemViewForInsertRequest = GenerateDocumentItemViewForInsertRequest()
        if parentDocumentModel != nil {
            generateDocumentItemViewForInsertRequest.parentDocumentModel = parentDocumentModel!
        }
        generateDocumentItemViewForInsertRequest.insertDocumentModel = insertDocumentModel
        generateDocumentItemViewForInsertRequest.isNewChild = isNewChild
        generateDocumentItemViewForInsertRequest.documentModelId = documentModelId
        generateDocumentItemViewForInsertRequest.isNewSentence = isNewSentence
        generateDocumentItemViewForInsertRequest.isEditable = isEditable
        generateDocumentItemViewForInsertRequest.isSentence = isSentence
        generateDocumentItemViewForInsertRequest.udcSentencePatternDataGroupValue.append(contentsOf:  udcSentencePatternDataGroupValue)
        generateDocumentItemViewForInsertRequest.documentGraphInsertItemRequest = documentGraphInsertItemRequest
        if uvcViewItemCollection != nil {
            generateDocumentItemViewForInsertRequest.uvcViewItemCollection = uvcViewItemCollection!
        }
        
        if try isNeuronProcessingIt(operationName: "DocumentGraphNeuron.Document.Type.Process.DocumentItemView.Insert.Generated", udcDocumentTypeIdName: documentGraphInsertItemRequest.udcDocumentTypeIdName, neuronRequest: neuronRequest, neuronResponse: &neuronResponse) {
            let jsonUtilityGenerateDocumentItemViewForInsertRequest = JsonUtility<GenerateDocumentItemViewForInsertRequest>()
            let jsonDocumentGenerateDocumentItemViewForInsertRequest = jsonUtilityGenerateDocumentItemViewForInsertRequest.convertAnyObjectToJson(jsonObject: generateDocumentItemViewForInsertRequest)
            neuronRequestLocal.neuronOperation.neuronData.text = jsonDocumentGenerateDocumentItemViewForInsertRequest
            try callNeuron(neuronRequest: neuronRequestLocal, neuronResponse: &neuronResponse, operationName: "DocumentGraphNeuron.Generate.DocumentItem.View.Insert", udcDocumentTypeIdName: documentGraphInsertItemRequest.udcDocumentTypeIdName)
            
            generateDocumentItemViewForInsertResponse = neuronUtility!.getNeuronRequest(json: neuronResponse.neuronOperation.neuronData.text, object: GenerateDocumentItemViewForInsertResponse())
        } else {
            try generateDocumentItemViewForInsert(generateDocumentItemViewForInsertRequest: generateDocumentItemViewForInsertRequest, generateDocumentItemViewForInsertResponse: &generateDocumentItemViewForInsertResponse, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        }
    }
    
    private func generateDocumentItemViewForChange(parentDocumentModel: UDCDocumentGraphModel, changeDocumentModel: UDCDocumentGraphModel, documentModelId: String, udcSentencePatternDataGroupValue: UDCSentencePatternDataGroupValue, documentGraphChangeItemRequest: DocumentGraphChangeItemRequest, generateDocumentItemViewForChangeResponse: inout GenerateDocumentItemViewForChangeResponse, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let neuronRequestLocal = neuronRequest
        let generateDocumentItemViewForChangeRequest = GenerateDocumentItemViewForChangeRequest()
        generateDocumentItemViewForChangeRequest.parentDocumentModel = parentDocumentModel
        generateDocumentItemViewForChangeRequest.changeDocumentModel = changeDocumentModel
        generateDocumentItemViewForChangeRequest.documentModelId = documentModelId
        generateDocumentItemViewForChangeRequest.udcSentencePatternDataGroupValue = udcSentencePatternDataGroupValue
        generateDocumentItemViewForChangeRequest.documentGraphChangeItemRequest = documentGraphChangeItemRequest
        
        if try isNeuronProcessingIt(operationName: "DocumentGraphNeuron.Document.Type.Process.DocumentItemView.Change.Generated", udcDocumentTypeIdName: documentGraphChangeItemRequest.udcDocumentTypeIdName, neuronRequest: neuronRequest, neuronResponse: &neuronResponse) {
            let jsonUtilityGenerateDocumentItemViewForChangeRequest = JsonUtility<GenerateDocumentItemViewForChangeRequest>()
            let jsonDocumentGenerateDocumentItemViewForChangeRequest = jsonUtilityGenerateDocumentItemViewForChangeRequest.convertAnyObjectToJson(jsonObject: generateDocumentItemViewForChangeRequest)
            neuronRequestLocal.neuronOperation.neuronData.text = jsonDocumentGenerateDocumentItemViewForChangeRequest
            try callNeuron(neuronRequest: neuronRequestLocal, neuronResponse: &neuronResponse, operationName: "DocumentGraphNeuron.Generate.DocumentItem.View.Change", udcDocumentTypeIdName: documentGraphChangeItemRequest.udcDocumentTypeIdName)
            
            generateDocumentItemViewForChangeResponse = neuronUtility!.getNeuronRequest(json: neuronResponse.neuronOperation.neuronData.text, object: GenerateDocumentItemViewForChangeResponse())
        } else {
            try generateDocumentItemViewForChange(generateDocumentItemViewForChangeRequest: generateDocumentItemViewForChangeRequest, generateDocumentItemViewForChangeResponse: generateDocumentItemViewForChangeResponse, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        }
    }
    
   
    
    private func getHumanLanguages(udcProfile: [UDCProfile], documentLanguage: String, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws -> [String] {
        var language = [String]()
        let databaseOrmResultUDCApplicationHumanLanguage = UDCApplicationHumanLanguage.get(udcProfile: udcProfile, udbcDatabaseOrm!)
        if databaseOrmResultUDCApplicationHumanLanguage.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCApplicationHumanLanguage.databaseOrmError[0].name, description: databaseOrmResultUDCApplicationHumanLanguage.databaseOrmError[0].description))
            return language
        }
        let udcApplicationHumanLanguage = databaseOrmResultUDCApplicationHumanLanguage.object
        for udcphl in udcApplicationHumanLanguage {
            let databaseOrmUDCHumanLanguageType = UDCHumanLanguageType.get(idName: udcphl.udcHumanLanguageIdName, udbcDatabaseOrm!, documentLanguage)
            if databaseOrmUDCHumanLanguageType.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCHumanLanguageType.databaseOrmError[0].name, description: databaseOrmUDCHumanLanguageType.databaseOrmError[0].description))
                return language
            }
            let udcHumanLanguageType = databaseOrmUDCHumanLanguageType.object[0]
            language.append(udcHumanLanguageType.code6391!)
        }
        return language
    }
    
    private func documentNew(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let documentGraphNewRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: DocumentGraphNewRequest())
        
        var documentLanguage = documentGraphNewRequest.documentLanguage
        let interfaceLanguage = documentGraphNewRequest.interfaceLanguage
        
        // Override language since document item as to be created in English first to maintain unique id.
        documentLanguage = "en"
        documentGraphNewRequest.documentLanguage = "en"
        
        var profileId = ""
        for udcp in documentGraphNewRequest.udcProfile {
            if udcp.udcProfileItemIdName == "UDCProfileItem.Human" {
                profileId = udcp.profileId
            }
        }
        let documentGraphNewResponse = DocumentGraphNewResponse()
        
        let databaseOrmUDCDocumentItemMapNode = UDCDocumentItemMapNode.get("UDCDocumentItemMapNode.Untitled", udbcDatabaseOrm!, documentLanguage)
        if databaseOrmUDCDocumentItemMapNode.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentItemMapNode.databaseOrmError[0].name, description: databaseOrmUDCDocumentItemMapNode.databaseOrmError[0].description))
            return
        }
        let untitledItem = databaseOrmUDCDocumentItemMapNode.object
        
        let name = "\(untitledItem[0].name)-\(NSUUID().uuidString)"
        let englishName = "untitled-\(NSUUID().uuidString)"
        
        
        // Get technical Document model and technical document view model from respective neuron based on document type
        let getDocumentModelsRequest = GetDocumentModelsRequest()
        getDocumentModelsRequest.name = name
        getDocumentModelsRequest.englishName = englishName
        getDocumentModelsRequest.documentGraphNewRequest = documentGraphNewRequest
        getDocumentModelsRequest.udcProfile = documentGraphNewRequest.udcProfile
        var getDocumentModelsResponse = GetDocumentModelsResponse()
        try getDocumentModels(getDocumentModelsRequest: getDocumentModelsRequest, getDocumentModelsResponse: &getDocumentModelsResponse, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        
        documentGraphNewResponse.objectControllerResponse = getDocumentModelsResponse.objectControllerResponse
        
        // Save the technical document model
        for udcrl in getDocumentModelsResponse.udcDocumentGraphModel {
            let databaseOrmResultudcDocumentGraphModel = UDCDocumentGraphModel.save(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: documentGraphNewRequest.udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, object: udcrl)
            if databaseOrmResultudcDocumentGraphModel.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultudcDocumentGraphModel.databaseOrmError[0].name, description: databaseOrmResultudcDocumentGraphModel.databaseOrmError[0].description))
                return
            }
        }
        
        var udcDocument = UDCDocument()
        if !getDocumentModelsResponse.isDocumentAlreadyCreated {
            udcDocument._id = try (udbcDatabaseOrm?.generateId())!
            udcDocument.idName = "UDCDocument.\(englishName.capitalized.trimmingCharacters(in: .whitespaces))"
            udcDocument.documentGroupId = try (udbcDatabaseOrm?.generateId())!
            udcDocument.name = name
            udcDocument.language = documentLanguage
            udcDocument.modelName = "Document Model"
            udcDocument.modelVersion = "1.0"
            udcDocument.modelDescription = "Contains Document Model"
            udcDocument.modelTechnicalName = "udcDocumentGraphModel"
            udcDocument.udcProfile = documentGraphNewRequest.udcProfile
            udcDocument.udcDocumentHistory.append(UDCDcumentHistory())
            udcDocument.udcDocumentHistory[0]._id = try (udbcDatabaseOrm?.generateId())!
            udcDocument.udcDocumentHistory[0].humanProfileId = profileId
            udcDocument.udcDocumentTime.createdBy = profileId
            udcDocument.udcDocumentTime.creationTime = Date()
            udcDocument.udcDocumentHistory[0].time = udcDocument.udcDocumentTime.creationTime
            udcDocument.udcDocumentHistory[0].reason = "Initial Version"
            udcDocument.udcDocumentHistory[0].version = udcDocument.modelVersion
            udcDocument.udcDocumentGraphModelId = getDocumentModelsResponse.documentModelId
            udcDocument.udcDocumentTypeIdName = documentGraphNewRequest.udcDocumentTypeIdName
            let udcDocumentAccessProfile = UDCDocumentAccessProfile()
            udcDocumentAccessProfile.profileId = profileId
            udcDocumentAccessProfile.udcProfileItemIdName = "UDCProfileItem.Human"
            udcDocumentAccessProfile.udcDocumentAccessType.append("UDCDocumentAccessType.Read")
            udcDocument.udcDocumentAccessProfile.append(udcDocumentAccessProfile)
            
            // Save the document model containing basic information and the refrence to the technical model
            let databaseOrmResultUDCDocument = UDCDocument.save(udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocument)
            if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocument.databaseOrmError[0].name, description: databaseOrmResultUDCDocument.databaseOrmError[0].description))
                return
            }
        } else {
            let databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: getDocumentModelsResponse.documentId, language: documentLanguage)
            if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocument.databaseOrmError[0].name, description: databaseOrmResultUDCDocument.databaseOrmError[0].description))
                return
            }
            udcDocument = databaseOrmResultUDCDocument.object[0]
        }
        
        //        let humanLanguages = try getHumanLanguages(upcApplicationProfileId: documentGraphNewRequest.upcApplicationProfileId, upcCompanyProfileId: documentGraphNewRequest.upcCompanyProfileId, documentLanguage: documentLanguage, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        //        for language in humanLanguages {
        try documentGraphModelReference(parentPathIdName: "UDCOptionMap.DocumentMap->\(documentGraphNewRequest.udcDocumentTypeIdName)->UDCOptionMapNode.Library", itemIdName: "UDCDocumentMapNode.All", udcDocumentId: udcDocument._id, udcProfile: documentGraphNewRequest.udcProfile, udcDocumentTypeIdName: documentGraphNewRequest.udcDocumentTypeIdName, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, documentLanguage: documentLanguage)
        
        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
            return
        }
        //        }
        
        try populateDocumentOptions(udcDocumentTypeIdName: documentGraphNewRequest.udcDocumentTypeIdName, udcProfile: documentGraphNewRequest.udcProfile, documentOptions: &documentGraphNewResponse.documentOptions, documentItemOptions: &documentGraphNewResponse.documentItemOptions, categoryOptions: &documentGraphNewResponse.categoryOptions, objectControllerOptions: &documentGraphNewResponse.objectControllerOptions, photoOptions: &documentGraphNewResponse.photoOptions, toolbarView: &documentGraphNewResponse.toolbarView, objectControllerView: &documentGraphNewResponse.objectControllerView, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, documentLanguage: documentLanguage, interfaceLanguage: interfaceLanguage)
        
        let _ = UDCDocumentRecent.remove(udbcDatabaseOrm: udbcDatabaseOrm!, udcDocumentId: udcDocument._id) as DatabaseOrmResult<UDCDocumentRecent>
        
        try documentGraphModelReference(parentPathIdName: "UDCOptionMap.DocumentMap->\(documentGraphNewRequest.udcDocumentTypeIdName)", itemIdName: "UDCOptionMapNode.Recents", udcDocumentId: udcDocument._id, udcProfile: documentGraphNewRequest.udcProfile, udcDocumentTypeIdName: documentGraphNewRequest.udcDocumentTypeIdName, neuronRequest: neuronRequest, neuronResponse: &neuronResponse, documentLanguage: documentLanguage)
        
        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
            return
        }
        
        if documentGraphNewRequest.udcDocumentTypeIdName == "UDCDocumentType.PhotoDocument" {
            
            let databaseOrmResultUDCDocumentItemMapNode = UDCDocumentItemMapNode.get("UDCDocumentItemMapNode.DocumentItems", udbcDatabaseOrm!, documentLanguage)
            if databaseOrmResultUDCDocumentItemMapNode.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentItemMapNode.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentItemMapNode.databaseOrmError[0].description))
                return
            }
            let udcDocumentItemMapNode = databaseOrmResultUDCDocumentItemMapNode.object[0]
            
            let databaseOrmResultUDCDocumentType = UDCDocumentType.get(limitedTo: 0, sortedBy: "_id", udbcDatabaseOrm: udbcDatabaseOrm!, language: documentLanguage)
            if databaseOrmResultUDCDocumentType.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentType.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentType.databaseOrmError[0].description))
                return
            }
            let udcDocumentType = databaseOrmResultUDCDocumentType.object
            
            for udcdt in udcDocumentType {
                if udcdt.idName != "UDCDocumentType.PhotoDocument" {
                    let udcDocumentItemMapNodeSave = UDCDocumentItemMapNode()
                    udcDocumentItemMapNodeSave._id = try udbcDatabaseOrm!.generateId()
                    udcDocumentItemMapNodeSave.parentId.append(contentsOf: udcDocumentItemMapNode.parentId)
                    udcDocumentItemMapNode.childrenId.append(udcDocumentItemMapNodeSave._id)
                    udcDocumentItemMapNodeSave.name = udcDocument.name
                    udcDocumentItemMapNodeSave.idName = "UDCDocumentItemMapNode.\(udcDocument.name.capitalized.trimmingCharacters(in: .whitespaces))"
                    udcDocumentItemMapNodeSave.language = documentLanguage
                    udcDocumentItemMapNodeSave.level = 1
                    udcDocumentItemMapNodeSave.objectId = [udcDocument._id]
                    udcDocumentItemMapNodeSave.objectName = "UDC\(documentGraphNewRequest.udcDocumentTypeIdName.components(separatedBy: ".")[1])"
                    udcDocumentItemMapNodeSave.pathIdName.append(contentsOf: udcDocumentItemMapNode.pathIdName)
                    udcDocumentItemMapNodeSave.pathIdName.append(udcDocumentItemMapNodeSave.idName)
                    udcDocumentItemMapNodeSave.udcDocumentTypeIdName = udcdt.idName
                    let _ = UDCDocumentItemMapNode.remove(udbcDatabaseOrm: udbcDatabaseOrm!, idName: "udcDocumentItemMapNodeSave.udcDocumentTypeIdName") as DatabaseOrmResult<UDCDocumentItemMapNode>
                    let databaseOrmResultUDCDocumentItemMapNodeSave = UDCDocumentItemMapNode.save(udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentItemMapNodeSave)
                    if databaseOrmResultUDCDocumentItemMapNodeSave.databaseOrmError.count > 0 {
                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentItemMapNodeSave.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentItemMapNodeSave.databaseOrmError[0].description))
                        return
                    }
                }
            }
            
            let databaseOrmResultUDCDocumentItemMapNodeSave = UDCDocumentItemMapNode.update(udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentItemMapNode)
            if databaseOrmResultUDCDocumentItemMapNodeSave.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentItemMapNodeSave.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentItemMapNodeSave.databaseOrmError[0].description))
                return
            }
            
        }
        
        
        // Put document map entry
        if documentGraphNewRequest.udcDocumentTypeIdName == "UDCDocumentType.DocumentItem" {
            try putDocumentMapEntry(mapUdcDocumentIdName: "UDCDocument.UniverseDocs", parentIdName: "UDCDocumentItem.DocumentItems", action: ["insertAtLast"], udcDocument: udcDocument, udcDocumentTypeIdName: documentGraphNewRequest.udcDocumentTypeIdName, documentLanguage: documentGraphNewRequest.documentLanguage, udcProfile: documentGraphNewRequest.udcProfile, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        }

        // Process document members
        
        
        // Package the response
        documentGraphNewResponse.documentId = udcDocument._id
        documentGraphNewResponse.documentTitle = udcDocument.name
        documentGraphNewResponse.currentLevel = 0
        documentGraphNewResponse.currentNodeIndex = getDocumentModelsResponse.nodeIndex
        documentGraphNewResponse.currentItemIndex = getDocumentModelsResponse.itemIndex
        documentGraphNewResponse.currentSentenceIndex = getDocumentModelsResponse.cursorSentence
        documentGraphNewResponse.uvcDocumentGraphModel = getDocumentModelsResponse.uvcDocumentGraphModel
        //        if documentGraphNewRequest.udcDocumentTypeIdName == "UDCDocumentType.DocumentItem" {
        documentGraphNewResponse.documentLanguage = "en"
        //        }
        
        let jsonUtilityDocumentGraphNewResponse = JsonUtility<DocumentGraphNewResponse>()
        let jsonDocumentDocumentGraphNewResponse = jsonUtilityDocumentGraphNewResponse.convertAnyObjectToJson(jsonObject: documentGraphNewResponse)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonDocumentDocumentGraphNewResponse)
    }
    
    private func documentGraphModelReference(parentPathIdName: String, itemIdName: String, udcDocumentId: String, udcProfile: [UDCProfile], udcDocumentTypeIdName: String, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest, documentLanguage: String) throws {
        let profileId = documentParser.getUDCProfile(udcProfile: udcProfile, idName: "UDCProfileItem.Human")
        var found = false
        let databaseOrmResultUDCDocumentGraphModelReferenceGet = UDCDocumentGraphModelDocumentMapDynamic.get(collectionName: "\(neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!)DocumentMapDynamic", udbcDatabaseOrm: udbcDatabaseOrm!, pathIdName: "\(parentPathIdName)->\(itemIdName)", udcProfile: udcProfile, udcDocumentId: udcDocumentId, udcDocumentTypeIdName: udcDocumentTypeIdName, language: documentLanguage)
        if databaseOrmResultUDCDocumentGraphModelReferenceGet.databaseOrmError.count == 0 {
            found = true
        }
        
        if !found {
            let udcDocumentGraphModelReference = UDCDocumentGraphModelDocumentMapDynamic()
            udcDocumentGraphModelReference._id = try udbcDatabaseOrm!.generateId()
            udcDocumentGraphModelReference.language = documentLanguage
            udcDocumentGraphModelReference.pathIdName = "\(parentPathIdName)->\(itemIdName)"
            udcDocumentGraphModelReference.udcDocumentAccessTypeIdName.append("UDCDocumentAccessType.Read")
            udcDocumentGraphModelReference.udcDocumentId = udcDocumentId
            udcDocumentGraphModelReference.udcDocumentTime.createdBy = profileId
            udcDocumentGraphModelReference.udcDocumentTime.creationTime = Date()
            udcDocumentGraphModelReference.udcDocumentTypeIdName = udcDocumentTypeIdName
            udcDocumentGraphModelReference.udcProfile = udcProfile
            let databaseOrmResultUDCDocumentGraphModelReference = UDCDocumentGraphModelDocumentMapDynamic.save(collectionName: "\(neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!)DocumentMapDynamic", udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentGraphModelReference)
            if databaseOrmResultUDCDocumentGraphModelReference.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentGraphModelReference.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentGraphModelReference.databaseOrmError[0].description))
                return
            }
        } else {
            let udcDocumentGraphModelReferenceForUpdate = databaseOrmResultUDCDocumentGraphModelReferenceGet.object[0]
            udcDocumentGraphModelReferenceForUpdate.udcDocumentTime.changedBy = profileId
            udcDocumentGraphModelReferenceForUpdate.udcDocumentTime.changedTime = Date()
            let databaseOrmResultUDCDocumentGraphModelReference = UDCDocumentGraphModelDocumentMapDynamic.update(collectionName: "\(neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!)DocumentMapDynamic", udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentGraphModelReferenceForUpdate)
            if databaseOrmResultUDCDocumentGraphModelReference.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentGraphModelReference.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentGraphModelReference.databaseOrmError[0].description))
                return
            }
        }
    }
    
    private func populateDocumentOptions(udcDocumentTypeIdName: String, udcProfile: [UDCProfile], documentOptions: inout [UVCOptionViewModel], documentItemOptions: inout [UVCOptionViewModel], categoryOptions: inout [String: [UVCOptionViewModel]], objectControllerOptions: inout [UVCOptionViewModel], photoOptions: inout [UVCOptionViewModel], toolbarView: inout UVCToolbarView, objectControllerView: inout UVCToolbarView, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest, documentLanguage: String, interfaceLanguage: String) throws {
        
        var getOptionMapRequest = GetOptionMapRequest()
        getOptionMapRequest.documentType = udcDocumentTypeIdName
        getOptionMapRequest.enableSingleSelectIdName.append("UDCOptionMapNode.ViewTypeConfiguration")
        getOptionMapRequest.enableSingleSelectIdName.append("UDCOptionMapNode.Single")
        getOptionMapRequest.enableSingleSelectIdName.append("UDCOptionMapNode.Multiple")
        getOptionMapRequest.name = "UDCOptionMap.DocumentItemOptions"
        getOptionMapRequest.udcProfile = udcProfile
        getOptionMapRequest.documentLanguage = documentLanguage
        getOptionMapRequest.interfaceLanguage = interfaceLanguage
        var neuronRequestLocal = NeuronRequest()
        neuronRequestLocal.neuronSource._id = neuronRequest.neuronSource._id
        neuronRequestLocal.neuronOperation.synchronus = true
        neuronRequestLocal.neuronOperation._id = neuronRequest.neuronOperation._id
        neuronRequestLocal.neuronSource.name = DocumentGraphNeuron.getName()
        neuronRequestLocal.neuronSource.type = DocumentGraphNeuron.getName();
        neuronRequestLocal.neuronOperation.name = "OptionMapNeuron.OptionMap.Get"
        neuronRequestLocal.neuronOperation.parent = true
        let jsonUtilityGetOptionMapRequest = JsonUtility<GetOptionMapRequest>()
        neuronRequestLocal.neuronOperation.neuronData.text = jsonUtilityGetOptionMapRequest.convertAnyObjectToJson(jsonObject: getOptionMapRequest)
        neuronRequestLocal.neuronTarget.name =  "OptionMapNeuron"
        
        try getOptionMap(neuronRequest: neuronRequestLocal, neuronResponse: &neuronResponse)
        
        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
            return
        }
        
        var getOptionMapResponse = neuronUtility!.getNeuronRequest(json: neuronResponse.neuronOperation.neuronData.text, object: GetOptionMapResponse())
        
        documentItemOptions.append(contentsOf: getOptionMapResponse.uvcOptionMapViewModel.uvcOptionViewModel)
        if getOptionMapResponse.uvcOptionMapViewModelDictionary["UDCOptionMapNode.CategoryOptions"] != nil {
            categoryOptions = getOptionMapResponse.uvcOptionMapViewModelDictionary["UDCOptionMapNode.CategoryOptions"]!
        }
        
        getOptionMapRequest = GetOptionMapRequest()
        getOptionMapRequest.name = "UDCOptionMap.DocumentOptions"
        getOptionMapRequest.udcProfile = udcProfile
        getOptionMapRequest.documentLanguage = documentLanguage
        getOptionMapRequest.interfaceLanguage = interfaceLanguage
        neuronRequestLocal = NeuronRequest()
        neuronRequestLocal.neuronSource._id = neuronRequest.neuronSource._id
        neuronRequestLocal.neuronOperation.synchronus = true
        neuronRequestLocal.neuronOperation._id = neuronRequest.neuronOperation._id
        neuronRequestLocal.neuronSource.name = DocumentGraphNeuron.getName()
        neuronRequestLocal.neuronSource.type = DocumentGraphNeuron.getName()
        neuronRequestLocal.neuronOperation.name = "OptionMapNeuron.OptionMap.Get"
        neuronRequestLocal.neuronOperation.parent = true
        var jsonDocumentGetOptionMapRequest = jsonUtilityGetOptionMapRequest.convertAnyObjectToJson(jsonObject: getOptionMapRequest)
        neuronRequestLocal.neuronOperation.neuronData.text = jsonDocumentGetOptionMapRequest
        neuronRequestLocal.neuronTarget.name = "OptionMapNeuron"
        
        try getOptionMap(neuronRequest: neuronRequestLocal, neuronResponse: &neuronResponse)
        
        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
            return
        }
        
        getOptionMapResponse = neuronUtility!.getNeuronRequest(json: neuronResponse.neuronOperation.neuronData.text, object: GetOptionMapResponse())
        documentOptions.append(contentsOf: getOptionMapResponse.uvcOptionMapViewModel.uvcOptionViewModel)
        
        getOptionMapRequest = GetOptionMapRequest()
        getOptionMapRequest.name = "UDCOptionMap.InterfaceOptions"
        getOptionMapRequest.udcProfile = udcProfile
        getOptionMapRequest.documentLanguage = documentLanguage
        getOptionMapRequest.interfaceLanguage = interfaceLanguage
        neuronRequestLocal = NeuronRequest()
        neuronRequestLocal.neuronSource._id = neuronRequest.neuronSource._id
        neuronRequestLocal.neuronOperation.synchronus = true
        neuronRequestLocal.neuronOperation._id = neuronRequest.neuronOperation._id
        neuronRequestLocal.neuronSource.name = DocumentGraphNeuron.getName()
        neuronRequestLocal.neuronSource.type = DocumentGraphNeuron.getName()
        neuronRequestLocal.neuronOperation.name = "OptionMapNeuron.OptionMap.Get"
        neuronRequestLocal.neuronOperation.parent = true
        jsonDocumentGetOptionMapRequest = jsonUtilityGetOptionMapRequest.convertAnyObjectToJson(jsonObject: getOptionMapRequest)
        neuronRequestLocal.neuronOperation.neuronData.text = jsonDocumentGetOptionMapRequest
        neuronRequestLocal.neuronTarget.name = "OptionMapNeuron"
        
        try getOptionMap(neuronRequest: neuronRequestLocal, neuronResponse: &neuronResponse)
        
        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
            return
        }
        
        getOptionMapResponse = neuronUtility!.getNeuronRequest(json: neuronResponse.neuronOperation.neuronData.text, object: GetOptionMapResponse())
        
        
        toolbarView.controllerText.append("")
        toolbarView.photoName.append("ExpandArrow")
        toolbarView.uvcViewItemType.append("UVCViewItemType.Photo")
        
        for ucovm in getOptionMapResponse.uvcOptionMapViewModel.uvcOptionViewModel {
            let value = ucovm.getText(name: "Name")!.value
            if ucovm.idName == "UDCOptionMapNode.Tool" || ucovm.idName == "UDCOptionMapNode.View" || ucovm.idName == "UDCOptionMapNode.Format" {
                toolbarView.photoName.append("")
                toolbarView.controllerText.append(value.capitalized)
                toolbarView.uvcViewItemType.append("UVCViewItemType.Button")
            }
        }
        
        
        objectControllerView.controllerText.append("")
        objectControllerView.photoName.append("LeftDirectionArrow")
        objectControllerView.uvcViewItemType.append("UVCViewItemType.Button")
        
        objectControllerView.controllerText.append("")
        objectControllerView.photoName.append("RightDirectionArrow")
        objectControllerView.uvcViewItemType.append("UVCViewItemType.Button")
        
        
        objectControllerView.controllerText.append("")
        objectControllerView.photoName.append("UpDirectionArrow")
        objectControllerView.uvcViewItemType.append("UVCViewItemType.Button")
        
        objectControllerView.controllerText.append("")
        objectControllerView.photoName.append("DownDirectionArrow")
        objectControllerView.uvcViewItemType.append("UVCViewItemType.Button")
        
        objectControllerView.controllerText.append("")
        objectControllerView.photoName.append("Search")
        objectControllerView.uvcViewItemType.append("UVCViewItemType.Button")
        
        objectControllerView.controllerText.append("")
        objectControllerView.photoName.append("Information")
        objectControllerView.uvcViewItemType.append("UVCViewItemType.Button")
        
        objectControllerView.controllerText.append("")
        objectControllerView.photoName.append("Configuration")
        objectControllerView.uvcViewItemType.append("UVCViewItemType.Button")
        
        objectControllerView.controllerText.append("")
        objectControllerView.photoName.append("DocumentMap")
        objectControllerView.uvcViewItemType.append("UVCViewItemType.Button")
        
        objectControllerView.controllerText.append("")
        objectControllerView.photoName.append("Elipsis")
        objectControllerView.uvcViewItemType.append("UVCViewItemType.Button")
        
        for ucovm in getOptionMapResponse.uvcOptionMapViewModel.uvcOptionViewModel {
            let value = ucovm.getText(name: "Name")!.value
            if ucovm.idName == "UDCOptionMapNode.View" || ucovm.idName == "UDCOptionMapNode.Format" {
                objectControllerView.photoName.append("")
                objectControllerView.controllerText.append(value.capitalized)
                objectControllerView.uvcViewItemType.append("UVCViewItemType.Button")
            }
        }
        
        for ucovm in getOptionMapResponse.uvcOptionMapViewModel.uvcOptionViewModel {
            let value = ucovm.getText(name: "Name")!.value
            if ucovm.idName == "UDCOptionMapNode.Delete" {
                objectControllerView.photoName.append("")
                objectControllerView.controllerText.append(value)
                objectControllerView.uvcViewItemType.append("UVCViewItemType.Button")
            }
        }
        
        getOptionMapRequest = GetOptionMapRequest()
        getOptionMapRequest.name = "UDCOptionMap.ViewOptions"
        getOptionMapRequest.udcProfile = udcProfile
        getOptionMapRequest.documentLanguage = documentLanguage
        getOptionMapRequest.interfaceLanguage = interfaceLanguage
        neuronRequestLocal = NeuronRequest()
        neuronRequestLocal.neuronSource._id = neuronRequest.neuronSource._id
        neuronRequestLocal.neuronOperation.synchronus = true
        neuronRequestLocal.neuronOperation._id = neuronRequest.neuronOperation._id
        neuronRequestLocal.neuronSource.name = DocumentGraphNeuron.getName()
        neuronRequestLocal.neuronSource.type = DocumentGraphNeuron.getName()
        neuronRequestLocal.neuronOperation.name = "OptionMapNeuron.OptionMap.Get"
        neuronRequestLocal.neuronOperation.parent = true
        jsonDocumentGetOptionMapRequest = jsonUtilityGetOptionMapRequest.convertAnyObjectToJson(jsonObject: getOptionMapRequest)
        neuronRequestLocal.neuronOperation.neuronData.text = jsonDocumentGetOptionMapRequest
        neuronRequestLocal.neuronTarget.name = "OptionMapNeuron"
        
        try getOptionMap(neuronRequest: neuronRequestLocal, neuronResponse: &neuronResponse)
        
        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
            return
        }
        
        getOptionMapResponse = neuronUtility!.getNeuronRequest(json: neuronResponse.neuronOperation.neuronData.text, object: GetOptionMapResponse())
        
        objectControllerOptions.append(contentsOf: getOptionMapResponse.uvcOptionMapViewModel.uvcOptionViewModel)
        
        getOptionMapRequest = GetOptionMapRequest()
        getOptionMapRequest.name = "UDCOptionMap.PhotoOptions"
        getOptionMapRequest.udcProfile = udcProfile
        getOptionMapRequest.documentLanguage = documentLanguage
        getOptionMapRequest.interfaceLanguage = interfaceLanguage
        neuronRequestLocal = NeuronRequest()
        neuronRequestLocal.neuronSource._id = neuronRequest.neuronSource._id
        neuronRequestLocal.neuronOperation.synchronus = true
        neuronRequestLocal.neuronOperation._id = neuronRequest.neuronOperation._id
        neuronRequestLocal.neuronSource.name = DocumentGraphNeuron.getName()
        neuronRequestLocal.neuronSource.type = DocumentGraphNeuron.getName()
        neuronRequestLocal.neuronOperation.name = "OptionMapNeuron.OptionMap.Get"
        neuronRequestLocal.neuronOperation.parent = true
        jsonDocumentGetOptionMapRequest = jsonUtilityGetOptionMapRequest.convertAnyObjectToJson(jsonObject: getOptionMapRequest)
        neuronRequestLocal.neuronOperation.neuronData.text = jsonDocumentGetOptionMapRequest
        neuronRequestLocal.neuronTarget.name = "OptionMapNeuron"
        
        try getOptionMap(neuronRequest: neuronRequestLocal, neuronResponse: &neuronResponse)
        
        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
            return
        }
        
        getOptionMapResponse = neuronUtility!.getNeuronRequest(json: neuronResponse.neuronOperation.neuronData.text, object: GetOptionMapResponse())
        
        photoOptions.append(contentsOf: getOptionMapResponse.uvcOptionMapViewModel.uvcOptionViewModel)
    }
    
    private func getAnalyticAndSaveDocumentTime(udcDocumentTime: UDCDocumentTime, objectName: String, profileId: String, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws -> UDCAnalytic {
        let udcAnalytic = UDCAnalytic()
        
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
    
    
    
    private func postProcess(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) {
        print("\(DocumentGraphNeuron.getName()): post process")
        
        
        
        if neuronRequest.neuronOperation.asynchronusProcess == true {
            print("\(DocumentGraphNeuron.getName()) Asynchronus so storing response in database")
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
        print("\(DocumentGraphNeuron.getName()) Informing: \(String(describing: neuronRequest.neuronSource.name))")
        let neuronSource = neuronUtility!.getDendrite(sourceId: neuronRequest.neuronSource._id, neuronName: neuronRequest.neuronSource.name)
        neuronSource!.setDendrite(neuronRequest: neuronResponse, udbcDatabaseOrm: self.udbcDatabaseOrm!, neuronUtility: self.neuronUtility!)
        
        
        
        defer {
            DocumentGraphNeuron.removeDendrite(sourceId: neuronRequest.neuronSource._id)
            print("Document Neuron  RESPONSE MAP: \(responseMap)")
            print("Document Neuron  Dendrite MAP: \(DocumentGraphNeuron.dendriteMap)")
        }
        
    }
}
