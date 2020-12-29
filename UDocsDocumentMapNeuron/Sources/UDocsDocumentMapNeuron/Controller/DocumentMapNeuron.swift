//
//  DocumentMapNeuron.swift
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
import UDocsNeuronModel
import UDocsNeuronUtility
import UDocsUtility
import UDocsDatabaseModel
import UDocsDatabaseUtility
import UDocsDocumentModel
import UDocsDocumentUtility
import UDocsViewModel
import UDocsViewUtility
import UDocsDocumentMapNeuronModel

public class DocumentMapNeuron : Neuron {
    
    public static func getRootResponse(neuronSourceId: String) -> NeuronRequest {
        return NeuronRequest()
    }
    
    var neuronUtility: NeuronUtility? = nil
    let documentParser = DocumentParser()
    let uvcViewGenerator = UVCViewGenerator()
    let documentItemConfigurationUtility = DocumentItemConfigurationUtility()
    var udbcDatabaseOrm: UDBCDatabaseOrm?
    static var dendriteMap: [String : Neuron] = [String : Neuron]()
    private var responseMap: [String : NeuronRequest] = [String : NeuronRequest]()
    static let serialQueue = DispatchQueue(label: "SerialQueue")
    var neuronResponse =  NeuronRequest()
    
    
    static public func getName() -> String {
        return "DocumentMapNeuron"
    }
    
    static public func getDescription() -> String {
        return "Document Map Neuron"
    }
    
    static public func getDendrite(sourceId: String) -> (Neuron) {
        var neuron: Neuron?
        
        serialQueue.sync {
            print("Before: \(dendriteMap.debugDescription)")
            neuron = dendriteMap[sourceId]
            if neuron == nil {
                print("\(getName()): Created: \(sourceId)")
                dendriteMap[sourceId] = DocumentMapNeuron()
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
        
        do {
            self.udbcDatabaseOrm = udbcDatabaseOrm
            
            self.neuronUtility = neuronUtility
            
            if neuronRequest.neuronOperation.parent == true {
                print("\(DocumentMapNeuron.getName()) Parent show setting child to true")
                neuronResponse.neuronOperation.child = true
            }
            
            var neuronRequestLocal = neuronRequest
            
            if neuronResponse.neuronOperation._id.isEmpty {
                neuronResponse.neuronOperation._id = try udbcDatabaseOrm.generateId()
            }
            
            self.neuronUtility!.setUDBCDatabaseOrm(udbcDatabaseOrm: udbcDatabaseOrm, neuronName: DocumentMapNeuron.getName())
            documentItemConfigurationUtility.setNeuronUtility(neuronUtility: self.neuronUtility!,  neuronName: DocumentMapNeuron.getName())
            documentItemConfigurationUtility.setUDBCDatabaseOrm(udbcDatabaseOrm: udbcDatabaseOrm, neuronName: DocumentMapNeuron.getName())
            documentParser.setNeuronUtility(neuronUtility: self.neuronUtility!,  neuronName: DocumentMapNeuron.getName())
            documentParser.setUDBCDatabaseOrm(udbcDatabaseOrm: udbcDatabaseOrm, neuronName: DocumentMapNeuron.getName())
            
            let continueProcess = try preProcess(neuronRequest: neuronRequestLocal)
            if continueProcess == false {
                print("\(DocumentMapNeuron.getName()): don't process return")
                return
            }
            
            validateRequest(neuronRequest: neuronRequest)
            
            if neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError!.count > 0 {
                print("\(DocumentMapNeuron.getName()) error in validation return")
                let neuronSource = self.neuronUtility!.getDendrite(sourceId: neuronRequest.neuronSource._id, neuronName: neuronRequest.neuronSource.name)
                neuronSource!.setDendrite(neuronRequest: neuronResponse, udbcDatabaseOrm: self.udbcDatabaseOrm!, neuronUtility: self.neuronUtility!)
                return
            }
            
            
            
            // Controller says no need to
            
            neuronResponse.neuronOperation.acknowledgement = false
            
            if neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError!.count == 0 {
                if neuronRequest.neuronOperation.asynchronus == true {
                    print("\(DocumentMapNeuron.getName()) asynchronus store the request and return")
                    neuronResponse.neuronOperation.response = true
                    neuronResponse.neuronOperation.neuronData.text = ""
                    self.neuronUtility!.storeInDatabase(neuronRequest: neuronRequest)
                    return
                } else {
                    if neuronRequest.neuronOperation.synchronus == true {
                        if neuronRequest.neuronOperation.asynchronusProcess == true {
                            print("\(DocumentMapNeuron.getName()) asynchronus so update the status as pending")
                            let rows = try NeuronRequest.update(udbcDatabaseOrm: udbcDatabaseOrm, id: (neuronRequest._id), status: NeuronOperationStatusType.InProgress.name)
                        }
                        neuronResponse = self.neuronUtility!.getNeuronAcknowledgement(neuronRequest: neuronRequest)
                        neuronResponse.neuronOperation.acknowledgement = true
                        neuronResponse.neuronOperation.neuronData.text = ""
                        let neuronSource = self.neuronUtility!.getDendrite(sourceId: neuronRequest.neuronSource._id, neuronName: neuronRequest.neuronSource.name)
                        neuronSource!.setDendrite(neuronRequest: neuronResponse, udbcDatabaseOrm: self.udbcDatabaseOrm!, neuronUtility: self.neuronUtility!)
                        neuronResponse.neuronOperation.acknowledgement = false
                        try process(neuronRequest: neuronRequestLocal)
                    }
                }
                
            }
            
            
            
        } catch {
            print("\(DocumentMapNeuron.getName()): Error thrown in setdendrite: \(error)")
            neuronResponse = self.neuronUtility!.getNeuronResponseError(neuronRequest: neuronRequest, errorName: NeuronOperationErrorType.ErrorInProcessing.name, errorDescription:  error.localizedDescription)
            
        }
        
        defer {
            postProcess(neuronRequest: neuronRequest)
        }
    }
    
    private func validateRequest(neuronRequest: NeuronRequest) {
        neuronResponse = neuronUtility!.validateRequest(neuronRequest: neuronRequest)
        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
            return
        }
    }
    
    
    
    private func preProcess(neuronRequest: NeuronRequest) throws -> Bool {
        print("\(DocumentMapNeuron.getName()): pre process")
        neuronResponse.neuronSource._id = neuronRequest.neuronSource._id
        
        print("neuronUtility: pre process: \(neuronRequest.neuronSource._id)")
        let neuronRequestLocal: NeuronRequest = neuronRequest
        
        if neuronRequestLocal.neuronOperation.acknowledgement == true {
            print("\(DocumentMapNeuron.getName()) acknowledgement so return")
            return false
        }
        
        if neuronRequestLocal.neuronOperation.response == true {
            setChildResponse(sourceId: neuronRequestLocal.neuronSource._id, neuronRequest: neuronRequest)
            print("\(DocumentMapNeuron.getName()) response so return")
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
            print("\(DocumentMapNeuron.getName()) got response so return")
            return false
        }
        
        return true
    }
    
    private func process(neuronRequest: NeuronRequest) throws {
        neuronResponse.neuronOperation.response = true
        if neuronRequest.neuronOperation.name == "DocumentMapNeuron.DocumentMap.Get" {
            getDocumentMap(neuronRequest: neuronRequest)
        } else if neuronRequest.neuronOperation.name == "DocumentMapNeuron.Search.Document" {
            try searchDocument(neuronRequest: neuronRequest)
        }  /*else if neuronRequest.neuronOperation.name == "DocumentMapNeuron.DocumentMapNode.Add" {
            try addDocumentMapNode(neuronRequest: neuronRequest)
        } else if neuronRequest.neuronOperation.name == "DocumentMapNeuron.DocumentMapNode.Change" {
            try changeDocumentMapNode(neuronRequest: neuronRequest)
        } else if neuronRequest.neuronOperation.name == "DocumentMapNeuron.DocumentMapNode.Remove" {
            try removeDocumentMapNode(neuronRequest: neuronRequest)
        } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.Save" || neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.Change" {
            try updateDocumentId(neuronRequest: neuronRequest)
        } else if neuronRequest.neuronOperation.name == SecurityNeuronOperationType.CreateUserConnection.name {
            try createDocumentMap(neuronRequest: neuronRequest)
        }*/
    }
        
    private func searchDocument(neuronRequest: NeuronRequest) throws {
        let documentMapSearchDocumentRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: DocumentMapSearchDocumentRequest())
        
        let interfaceLanguage = documentMapSearchDocumentRequest.interfaceLanguage
        
        let databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, udcProfile: documentMapSearchDocumentRequest.udcProfile, idName: "UDCDocument.DocumentMap", udcDocumentTypeIdName: "UDCDocumentType.DocumentItem", language: interfaceLanguage)
        if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocument.databaseOrmError[0].name, description: databaseOrmResultUDCDocument.databaseOrmError[0].description))
            return
            
        }
        let udcDocument = databaseOrmResultUDCDocument.object[0]
        
        let databaseOrmDocumentItem = UDCDocumentGraphModel.get(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocument.udcDocumentGraphModelId)
        if databaseOrmDocumentItem.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmDocumentItem.databaseOrmError[0].name, description: databaseOrmDocumentItem.databaseOrmError[0].description))
            return
            
        }
        
        let documentMapSearchDocumentResponse = DocumentMapSearchDocumentResponse()
        let udcDocumentItem = databaseOrmDocumentItem.object[0]
        var path = [String]()
        var pathIdName = [String]()
        var category = ""
        var subCategory = ""
        var treeLevel = documentMapSearchDocumentRequest.treeLevel
        if documentMapSearchDocumentRequest.text == nil {
            treeLevel -= 1
        }
        let rootName = "Search Result"
        let rootIdName = "UDCDocumentItem.\(rootName.capitalized.replacingOccurrences(of: " ", with: ""))"
        pathIdName.append(rootIdName)
        path.append(rootName)
      
        
        var index = -1
        try getDocumentMap(text: documentMapSearchDocumentRequest.text, language: documentMapSearchDocumentRequest.interfaceLanguage, children: udcDocumentItem.childrenId, udcProfile: documentMapSearchDocumentRequest.udcProfile, path: &path, pathIdName: &pathIdName, uvcDocumentMapViewModel: &documentMapSearchDocumentResponse.uvcDocumentMapViewModel, treeLevel: treeLevel, uvcDocumentMapViewTemplateType: documentMapSearchDocumentRequest.uvcDocumentMapViewTemplateType, category: &category, subCategory: &subCategory, parentNodePathIdName: [rootIdName], index: &index, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
                
        for uvcdmvm in documentMapSearchDocumentResponse.uvcDocumentMapViewModel {
            let uvcTreeNode = UVCTreeNode()
            uvcTreeNode._id = try udbcDatabaseOrm!.generateId()
            uvcTreeNode.pathIdName.append(rootIdName)
            uvcTreeNode.language = interfaceLanguage
            uvcTreeNode.level = 0
            uvcTreeNode.uvcViewModel = uvcViewGenerator.getTreeNodeViewModel(name: rootName, description: "", path: "", language: uvcTreeNode.language, isChildrenExist: false, uvcDocumentMapViewTemplateType: documentMapSearchDocumentRequest.uvcDocumentMapViewTemplateType, textColor: UVCColor.get("UVCColor.Black"), udcDocumentTypeIdName: "", isOptionAvailable: false)
            uvcTreeNode.childrenId.removeAll()
            uvcTreeNode.childrenId.append(uvcdmvm.uvcTreeNode[0]._id)
            uvcdmvm.uvcTreeNode[0].parentId.append(uvcTreeNode._id)
            uvcdmvm.uvcTreeNode.insert(uvcTreeNode, at: 0)
        }
        
        if documentMapSearchDocumentResponse.uvcDocumentMapViewModel.count == 0 {
            let uvcTreeNode = UVCTreeNode()
            uvcTreeNode._id = try udbcDatabaseOrm!.generateId()
            var uvcTreeNodeReturn = [UVCTreeNode]()
            getNoData(parentName: rootName, parentId: uvcTreeNode._id, treeLevel: documentMapSearchDocumentRequest.treeLevel, pathIdName: pathIdName, uvcDocumentMapViewTemplateType: documentMapSearchDocumentRequest.uvcDocumentMapViewTemplateType, interfaceLanguage: interfaceLanguage, uvcTreeNodeReturn: &uvcTreeNodeReturn, neuronRequest: neuronRequest)
            documentMapSearchDocumentResponse.uvcDocumentMapViewModel.append(UVCDocumentMapViewModel())
            documentMapSearchDocumentResponse.uvcDocumentMapViewModel[0].uvcTreeNode.append(contentsOf: uvcTreeNodeReturn)
            uvcTreeNodeReturn[0].parentId.append(uvcTreeNode._id)
            uvcTreeNode.pathIdName.append(rootIdName)
            uvcTreeNode.language = interfaceLanguage
            uvcTreeNode.level = 0
            uvcTreeNode.uvcViewModel = uvcViewGenerator.getTreeNodeViewModel(name: rootName, description: "", path: "", language: uvcTreeNode.language, isChildrenExist: false, uvcDocumentMapViewTemplateType: documentMapSearchDocumentRequest.uvcDocumentMapViewTemplateType, textColor: UVCColor.get("UVCColor.Black"), udcDocumentTypeIdName: "", isOptionAvailable: false)
            uvcTreeNode.childrenId.removeAll()
            uvcTreeNode.childrenId.append(uvcTreeNodeReturn[0]._id)
        }
        
        let jsonUtilityDocumentMapSearchDocumentResponse = JsonUtility<DocumentMapSearchDocumentResponse>()
        let jsonRemoveDocumentMapSearchDocumentResponse = jsonUtilityDocumentMapSearchDocumentResponse.convertAnyObjectToJson(jsonObject: documentMapSearchDocumentResponse)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonRemoveDocumentMapSearchDocumentResponse)
    }
    
    private func getChildrenMap(text: String?, language: String, children: [String], udcProfile: [UDCProfile], path: inout [String], pathIdName: inout [String], uvcDocumentMapViewModel: inout UVCDocumentMapViewModel, treeLevel: inout Int, uvcDocumentMapViewTemplateType: String, category: inout String, subCategory: inout String, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        var documentId = ""
        var udcDocumentTypeIdName = "UDCDocumentType.None"
        for child in children {
            documentId = ""
            udcDocumentTypeIdName = "UDCDocumentType.None"
            let databaseOrmUDCDocumentGraphModel = try UDCDocumentGraphModel.get(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, id: child)
            let udcdi = databaseOrmUDCDocumentGraphModel.object[0]
            var isReference = false
            if !udcdi.documentMapObjectId.isEmpty {
                let databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: udcdi.documentMapObjectId)
                if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocument.databaseOrmError[0].name, description: databaseOrmResultUDCDocument.databaseOrmError[0].description))
                    return
                }
                let udcDocument = databaseOrmResultUDCDocument.object[0]
                
                let databaseOrmResultUDCDocumentMap = UDCDocumentGraphModel.get(collectionName: "UDCDocumentMap", udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocument.udcDocumentGraphModelId, language: language)
                if databaseOrmResultUDCDocumentMap.databaseOrmError.count > 0 {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentMap.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentMap.databaseOrmError[0].description))
                    return
                }
                let udcDocumentMap = databaseOrmResultUDCDocumentMap.object[0]
                
                var fieldValueMap = [String: [UDCSentencePatternDataGroupValue]]()
                documentParser.getField(fieldidName: "UDCDocumentItem.ReferenceDocument", childrenId: udcDocumentMap.childrenId, fieldValue: &fieldValueMap, udcDocumentTypeIdName: "UDCDocumentType.DocumentMap", documentLanguage: language)
                let fieldUdcspdvArray = fieldValueMap["UDCDocumentItem.ReferenceDocument"]
                
                if fieldUdcspdvArray != nil {
                    for _ in fieldUdcspdvArray! {
                        isReference = true
                        break
                    }
                }
                if isReference {
                    continue
                }
                documentParser.getField(fieldidName: "UDCDocumentItem.Document", childrenId: udcDocumentMap.childrenId, fieldValue: &fieldValueMap, udcDocumentTypeIdName: "UDCDocumentType.DocumentMap", documentLanguage: language)
                let fieldUdcspdvArray1 = fieldValueMap["UDCDocumentItem.Document"]
                if fieldUdcspdvArray1 != nil {
                    for udcspdgv in fieldUdcspdvArray1! {
                        documentId = udcspdgv.udcDocumentId
                        udcDocumentTypeIdName = udcspdgv.endSubCategoryIdName
                        break
                    }
                }
                documentParser.getField(fieldidName: "UDCDocumentItem.ChildDocument", childrenId: udcDocumentMap.childrenId, fieldValue: &fieldValueMap, udcDocumentTypeIdName: "UDCDocumentType.DocumentMap", documentLanguage: language)
                let fieldUdcspdvArray2 = fieldValueMap["UDCDocumentItem.ChildDocument"]
                if fieldUdcspdvArray2 != nil {
                    for udcspdgv in fieldUdcspdvArray2! {
                        documentId = udcspdgv.udcDocumentId
                        break
                    }
                }
            }
            var name = udcdi.name
            path.append(name)
            if language == "en" {
                name = name.capitalized
            }
            if path.count > 2 {
                subCategory = path[path.count - 2]
                category = path[path.count - 3]
            } else {
                category = path[path.count - 2]
            }
            
            var accessAllowed = false
            var textColor = UVCColor.get("UVCColor.Black")
            if !documentId.isEmpty && !udcDocumentTypeIdName.isEmpty {
                let databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: documentId, language: language)
                if databaseOrmResultUDCDocument.databaseOrmError.count == 0 {
                    let udcDocument = databaseOrmResultUDCDocument.object[0]
                    for udcDocumentAccessProfile in udcDocument.udcDocumentAccessProfile {
                        if udcDocumentAccessProfile.udcProfileItemIdName == "UDCProfileItem.Human" {
                            if !udcDocumentAccessProfile.profileId.isEmpty {
                                if documentParser.getUDCProfile(udcProfile: udcProfile, idName: "UDCProfileItem.Human") == udcDocumentAccessProfile.profileId {
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
                                    if udcDocumentAccessProfile.udcDocumentAccessType.contains("UDCDocumentAccessType.Read") || udcDocumentAccessProfile.udcDocumentAccessType.contains("UDCDocumentAccessType.Write") {
                                        accessAllowed = true
                                    }
                                }
                            }
                        }
                    }
                }
            }
            let uvcTreeNode = UVCTreeNode()
            uvcTreeNode._id = udcdi._id
            for parent in udcdi.parentId {
                uvcTreeNode.parentId.append(parent)
            }
            for children in udcdi.childrenId {
                uvcTreeNode.childrenId.append(children)
            }
            uvcTreeNode.level = treeLevel
            pathIdName.append(udcdi.idName)
            var pathIdNameLocal = [String]()
            
            for (pinIndex, pin) in pathIdName.enumerated() {
                if pinIndex != 1 {
                    pathIdNameLocal.append(pin)
                }
            }
            print(udcdi.name)
            uvcTreeNode.pathIdName.append(contentsOf: pathIdNameLocal)
            uvcTreeNode.objectId = documentId.isEmpty ? udcdi._id : documentId
            uvcTreeNode.objectType = udcDocumentTypeIdName
            uvcTreeNode.isOptionAvailable = true
            uvcTreeNode.isChidlrenOnDemandLoading = udcdi.isChildrenAllowed && udcdi.childrenId.count == 0
            let isChildrenExist = uvcTreeNode.childrenId.count > 0 || uvcTreeNode.isChidlrenOnDemandLoading
            uvcTreeNode.language = language
            uvcTreeNode.isReference = isReference
            var pathParam = ""
            if path.count > 1 {
                pathParam = path.joined(separator: " > ")
            } else {
                pathParam = path.joined()
            }
            if subCategory == category {
                subCategory = ""
            }
            uvcTreeNode.uvcViewModel = uvcViewGenerator.getTreeNodeViewModel(name: udcdi.name,  description: treeLevel == 1 ? subCategory: "", path: treeLevel == 1 ? category: "", language: uvcTreeNode.language, isChildrenExist: isChildrenExist, uvcDocumentMapViewTemplateType: uvcDocumentMapViewTemplateType, textColor: textColor, udcDocumentTypeIdName: udcDocumentTypeIdName, isOptionAvailable: uvcTreeNode.isOptionAvailable)
            uvcDocumentMapViewModel.uvcTreeNode.append(uvcTreeNode)
            if udcdi.childrenId.count > 0 {
                treeLevel += 1
                try getChildrenMap(text: text, language: language, children: udcdi.childrenId, udcProfile: udcProfile, path: &path, pathIdName: &pathIdName, uvcDocumentMapViewModel: &uvcDocumentMapViewModel, treeLevel: &treeLevel,  uvcDocumentMapViewTemplateType: uvcDocumentMapViewTemplateType, category: &category, subCategory: &subCategory, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
                treeLevel -= 1
                
                if neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError!.count > 0 {
                    return
                }
            }
            if udcdi.childrenId.count == 0 && udcdi.isChildrenAllowed && !udcdi.documentMapObjectId.isEmpty {
                let databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: udcdi.documentMapObjectId)
                if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocument.databaseOrmError[0].name, description: databaseOrmResultUDCDocument.databaseOrmError[0].description))
                    return
                }
                let udcDocument = databaseOrmResultUDCDocument.object[0]
                
                let databaseOrmResultUDCDocumentMap = UDCDocumentGraphModel.get(collectionName: "UDCDocumentMap", udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocument.udcDocumentGraphModelId, language: language)
                if databaseOrmResultUDCDocumentMap.databaseOrmError.count > 0 {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentMap.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentMap.databaseOrmError[0].description))
                    return
                }
                let udcDocumentMap = databaseOrmResultUDCDocumentMap.object[0]
                var fieldValueMap = [String: [UDCSentencePatternDataGroupValue]]()
                documentParser.getField(fieldidName: "UDCDocumentItem.ReferenceDocument", childrenId: udcDocumentMap.childrenId, fieldValue: &fieldValueMap, udcDocumentTypeIdName: "UDCDocumentType.DocumentMap", documentLanguage: language)
                let fieldUdcspdvArray = fieldValueMap["UDCDocumentItem.ReferenceDocument"]
                
                if fieldUdcspdvArray != nil {
                    for _ in fieldUdcspdvArray! {
                        isReference = true
                        break
                    }
                }
                
                if isReference {
                    isReference = false
                    path.remove(at: path.count - 1)
                    pathIdName.remove(at: pathIdName.count - 1)
                    continue
                }
                
                documentParser.getField(fieldidName: "UDCDocumentItem.ChildDocument", childrenId: udcDocumentMap.childrenId, fieldValue: &fieldValueMap, udcDocumentTypeIdName: "UDCDocumentType.DocumentMap", documentLanguage: language)
                let fieldUdcspdvArray1 = fieldValueMap["UDCDocumentItem.ChildDocument"]
                if fieldUdcspdvArray1 != nil {
                    for udcspdgv in fieldUdcspdvArray1! {
                        let databaseOrmResultUDCDocumentChild = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: udcspdgv.itemId)
                        if databaseOrmResultUDCDocumentChild.databaseOrmError.count > 0 {
                            // Document map node not found
                            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentChild.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentChild.databaseOrmError[0].description))
                            return
                        }
                        let udcDocumentChild = databaseOrmResultUDCDocumentChild.object[0]
                        
                        let databaseOrmResultUDCDocumentItemChild = UDCDocumentGraphModel.get(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentChild.udcDocumentGraphModelId)
                        if databaseOrmResultUDCDocumentItemChild.databaseOrmError.count > 0 {
                            // Document map node not found
                            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentItemChild.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentItemChild.databaseOrmError[0].description))
                            return
                        }
                        let udcDocumentItemChild = databaseOrmResultUDCDocumentItemChild.object[0]
                        //                        treeLevel += 1
                        try getChildrenMap(text: text, language: language, children: udcDocumentItemChild.childrenId, udcProfile: udcProfile, path: &path, pathIdName: &pathIdName, uvcDocumentMapViewModel: &uvcDocumentMapViewModel, treeLevel: &treeLevel, uvcDocumentMapViewTemplateType: uvcDocumentMapViewTemplateType, category: &category, subCategory: &subCategory, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
                        //                        treeLevel -= 1
                        if neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError!.count > 0 {
                            return
                        }
                    }
                }
                
            }
            path.remove(at: path.count - 1)
            pathIdName.remove(at: pathIdName.count - 1)
        }
    }
    
    private func getDocumentMap(text: String?, language: String, children: [String], udcProfile: [UDCProfile], path: inout [String], pathIdName: inout [String], uvcDocumentMapViewModel: inout [UVCDocumentMapViewModel], treeLevel: Int, uvcDocumentMapViewTemplateType: String, category: inout String, subCategory: inout String, parentNodePathIdName: [String], index: inout Int, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        var documentId = ""
        var udcDocumentTypeIdName = "UDCDocumentType.None"
        let databaseOrmUDCDocumentGraphModel: DatabaseOrmResult<UDCDocumentGraphModel>?
        if text != nil {
            databaseOrmUDCDocumentGraphModel = try UDCDocumentGraphModel.search(collectionName: "UDCDocumentItem", text: text!, limitedTo: 0, sortedBy: "name", udbcDatabaseOrm: udbcDatabaseOrm!, language: language, _id: children)
        } else {
            databaseOrmUDCDocumentGraphModel = try UDCDocumentGraphModel.get(collectionName: "UDCDocumentItem", limitedTo: 0, sortedBy: "name", udbcDatabaseOrm: udbcDatabaseOrm!, language: language, _id: children)
        }
        if databaseOrmUDCDocumentGraphModel!.databaseOrmError.count == 0 {
            
            let udcDocumentItem = databaseOrmUDCDocumentGraphModel!.object

            for udcdi in udcDocumentItem {
                documentId = ""
                udcDocumentTypeIdName = "UDCDocumentType.None"
                if udcdi.level <= 1 {
                    continue
                }
                uvcDocumentMapViewModel.append(UVCDocumentMapViewModel())
                index += 1
                var isReference = false
                if !udcdi.documentMapObjectId.isEmpty {
                    let databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: udcdi.documentMapObjectId)
                    if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocument.databaseOrmError[0].name, description: databaseOrmResultUDCDocument.databaseOrmError[0].description))
                        return
                    }
                    let udcDocument = databaseOrmResultUDCDocument.object[0]
                    
                    let databaseOrmResultUDCDocumentMap = UDCDocumentGraphModel.get(collectionName: "UDCDocumentMap", udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocument.udcDocumentGraphModelId, language: language)
                    if databaseOrmResultUDCDocumentMap.databaseOrmError.count > 0 {
                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentMap.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentMap.databaseOrmError[0].description))
                        return
                    }
                    let udcDocumentMap = databaseOrmResultUDCDocumentMap.object[0]
                    
                    var fieldValueMap = [String: [UDCSentencePatternDataGroupValue]]()
                    documentParser.getField(fieldidName: "UDCDocumentItem.ReferenceDocument", childrenId: udcDocumentMap.childrenId, fieldValue: &fieldValueMap, udcDocumentTypeIdName: "UDCDocumentType.DocumentMap", documentLanguage: language)
                    let fieldUdcspdvArray = fieldValueMap["UDCDocumentItem.ReferenceDocument"]
                    
                    if fieldUdcspdvArray != nil {
                        for _ in fieldUdcspdvArray! {
                            isReference = true
                            break
                        }
                    }
                    if isReference {
                        uvcDocumentMapViewModel.remove(at: uvcDocumentMapViewModel.count - 1)
                        index -= 1
                        continue
                    }
                    documentParser.getField(fieldidName: "UDCDocumentItem.Document", childrenId: udcDocumentMap.childrenId, fieldValue: &fieldValueMap, udcDocumentTypeIdName: "UDCDocumentType.DocumentMap", documentLanguage: language)
                    let fieldUdcspdvArray1 = fieldValueMap["UDCDocumentItem.Document"]
                    if fieldUdcspdvArray1 != nil {
                        for udcspdgv in fieldUdcspdvArray1! {
                            documentId = udcspdgv.udcDocumentId
                            let databaseOrmResultDocumentType = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: udcspdgv.udcDocumentId)
                            if databaseOrmResultDocumentType.databaseOrmError.count > 0 {
                                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultDocumentType.databaseOrmError[0].name, description: databaseOrmResultDocumentType.databaseOrmError[0].description))
                                return
                            }
                            udcDocumentTypeIdName = databaseOrmResultDocumentType.object[0].udcDocumentTypeIdName
//                            if udcspdgv.endCategoryIdName == "UDCDocumentItem.Document" {
//                                udcDocumentTypeIdName = udcspdgv.endCategoryId
//                            } else {
//                                udcDocumentTypeIdName = udcspdgv.endSubCategoryIdName
//                            }
                            break
                        }
                    }
                    documentParser.getField(fieldidName: "UDCDocumentItem.ChildDocument", childrenId: udcDocumentMap.childrenId, fieldValue: &fieldValueMap, udcDocumentTypeIdName: "UDCDocumentType.DocumentMap", documentLanguage: language)
                    let fieldUdcspdvArray2 = fieldValueMap["UDCDocumentItem.ChildDocument"]
                    if fieldUdcspdvArray2 != nil {
                        for udcspdgv in fieldUdcspdvArray2! {
                            documentId = udcspdgv.udcDocumentId
                            break
                        }
                    }
                }
                var name = udcdi.name
                path.append(name)
                if language == "en" {
                    name = name.capitalized
                }
                if path.count > 2 {
                    subCategory = path[path.count - 2]
                    category = path[path.count - 3]
                } else {
                    category = path[path.count - 2]
                }
                
                var accessAllowed = false
                var textColor = UVCColor.get("UVCColor.Black")
                if !documentId.isEmpty && !udcDocumentTypeIdName.isEmpty {
                    let databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: documentId, language: language)
                    if databaseOrmResultUDCDocument.databaseOrmError.count == 0 {
                        let udcDocument = databaseOrmResultUDCDocument.object[0]
                        for udcDocumentAccessProfile in udcDocument.udcDocumentAccessProfile {
                            if udcDocumentAccessProfile.udcProfileItemIdName == "UDCProfileItem.Human" {
                                if !udcDocumentAccessProfile.profileId.isEmpty {
                                    if documentParser.getUDCProfile(udcProfile: udcProfile, idName: "UDCProfileItem.Human") == udcDocumentAccessProfile.profileId {
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
                                        if udcDocumentAccessProfile.udcDocumentAccessType.contains("UDCDocumentAccessType.Read") || udcDocumentAccessProfile.udcDocumentAccessType.contains("UDCDocumentAccessType.Write") {
                                            accessAllowed = true
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                let uvcTreeNode = UVCTreeNode()
                uvcTreeNode._id = udcdi._id
                for parent in udcdi.parentId {
                    uvcTreeNode.parentId.append(parent)
                }
                for children in udcdi.childrenId {
                    uvcTreeNode.childrenId.append(children)
                }
                uvcTreeNode.level = treeLevel
                pathIdName.append(udcdi.idName)
                var pathIdNameLocal = [String]()
                var itemFound = false
                for (pinIndex, pin) in pathIdName.enumerated() {
                    if pin == udcdi.idName {
                        itemFound = true
                    }
                    if pinIndex == 0 || itemFound {
                        pathIdNameLocal.append(pin)
                    }
                }
                print(udcdi.name)
                uvcTreeNode.pathIdName.append(contentsOf: pathIdNameLocal)
                uvcTreeNode.objectId = documentId.isEmpty ? udcdi._id : documentId
                uvcTreeNode.objectType = udcDocumentTypeIdName
                uvcTreeNode.isOptionAvailable = true
                uvcTreeNode.isChidlrenOnDemandLoading = udcdi.isChildrenAllowed && udcdi.childrenId.count == 0
                let isChildrenExist = uvcTreeNode.childrenId.count > 0 || uvcTreeNode.isChidlrenOnDemandLoading
                uvcTreeNode.language = language
                uvcTreeNode.isReference = isReference
                var pathParam = ""
                if path.count > 1 {
                    pathParam = path.joined(separator: " > ")
                } else {
                    pathParam = path.joined()
                }
                if subCategory == category {
                    subCategory = ""
                }
                uvcTreeNode.uvcViewModel = uvcViewGenerator.getTreeNodeViewModel(name: udcdi.name, description: treeLevel == 1 ? subCategory: "", path: treeLevel == 1 ? category: "", language: uvcTreeNode.language, isChildrenExist: isChildrenExist, uvcDocumentMapViewTemplateType: uvcDocumentMapViewTemplateType, textColor: textColor, udcDocumentTypeIdName: udcDocumentTypeIdName, isOptionAvailable: uvcTreeNode.isOptionAvailable)
                uvcDocumentMapViewModel[index].uvcTreeNode.append(uvcTreeNode)
                var treeLevelChild = treeLevel + 1
                try getChildrenMap(text: text, language: language, children: udcdi.childrenId, udcProfile: udcProfile, path: &path, pathIdName: &pathIdName, uvcDocumentMapViewModel: &uvcDocumentMapViewModel[index], treeLevel: &treeLevelChild,  uvcDocumentMapViewTemplateType: uvcDocumentMapViewTemplateType, category: &category, subCategory: &subCategory, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
                path.remove(at: path.count - 1)
                pathIdName.remove(at: pathIdName.count - 1)
            }
        }
        pathIdName.removeAll()
        pathIdName.append(contentsOf: parentNodePathIdName)
        
        
        // Also try to search in the childrens children nodes, if any found
        var isReference = false
        for child in children {
            let databaseOrmUDCDocumentGraphModelSearchFurther = UDCDocumentGraphModel.get(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, id: child)
            if databaseOrmUDCDocumentGraphModelSearchFurther.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmUDCDocumentGraphModelSearchFurther.databaseOrmError[0].name, description: databaseOrmUDCDocumentGraphModelSearchFurther.databaseOrmError[0].description))
                return
            }
            let udcDocumentItemSearchFurther = databaseOrmUDCDocumentGraphModelSearchFurther.object[0]
            path.append(udcDocumentItemSearchFurther.name)
            if (pathIdName.count > 0) && pathIdName[pathIdName.count - 1] != udcDocumentItemSearchFurther.idName  {
                pathIdName.append(udcDocumentItemSearchFurther.idName)
            }
            
            if udcDocumentItemSearchFurther.childrenId.count > 0 {
                //                treeLevel += 1
                try getDocumentMap(text: text, language: language, children: udcDocumentItemSearchFurther.childrenId, udcProfile: udcProfile, path: &path, pathIdName: &pathIdName, uvcDocumentMapViewModel: &uvcDocumentMapViewModel, treeLevel: treeLevel,  uvcDocumentMapViewTemplateType: uvcDocumentMapViewTemplateType, category: &category, subCategory: &subCategory, parentNodePathIdName: parentNodePathIdName, index: &index, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
                //                treeLevel -= 1
                
                if neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError!.count > 0 {
                    return
                }
            }
            if udcDocumentItemSearchFurther.childrenId.count == 0 && udcDocumentItemSearchFurther.isChildrenAllowed && !udcDocumentItemSearchFurther.documentMapObjectId.isEmpty {
                let databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentItemSearchFurther.documentMapObjectId)
                if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocument.databaseOrmError[0].name, description: databaseOrmResultUDCDocument.databaseOrmError[0].description))
                    return
                }
                let udcDocument = databaseOrmResultUDCDocument.object[0]
                
                let databaseOrmResultUDCDocumentMap = UDCDocumentGraphModel.get(collectionName: "UDCDocumentMap", udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocument.udcDocumentGraphModelId, language: language)
                if databaseOrmResultUDCDocumentMap.databaseOrmError.count > 0 {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentMap.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentMap.databaseOrmError[0].description))
                    return
                }
                let udcDocumentMap = databaseOrmResultUDCDocumentMap.object[0]
                var fieldValueMap = [String: [UDCSentencePatternDataGroupValue]]()
                documentParser.getField(fieldidName: "UDCDocumentItem.ReferenceDocument", childrenId: udcDocumentMap.childrenId, fieldValue: &fieldValueMap, udcDocumentTypeIdName: "UDCDocumentType.DocumentMap", documentLanguage: language)
                let fieldUdcspdvArray = fieldValueMap["UDCDocumentItem.ReferenceDocument"]
                
                if fieldUdcspdvArray != nil {
                    for _ in fieldUdcspdvArray! {
                        isReference = true
                        break
                    }
                }
                
                if isReference {
                    isReference = false
                    path.remove(at: path.count - 1)
                    if pathIdName.count > 0 {
                        pathIdName.remove(at: pathIdName.count - 1)
                    }
                    continue
                }
                
                documentParser.getField(fieldidName: "UDCDocumentItem.ChildDocument", childrenId: udcDocumentMap.childrenId, fieldValue: &fieldValueMap, udcDocumentTypeIdName: "UDCDocumentType.DocumentMap", documentLanguage: language)
                let fieldUdcspdvArray1 = fieldValueMap["UDCDocumentItem.ChildDocument"]
                if fieldUdcspdvArray1 != nil {
                    for udcspdgv in fieldUdcspdvArray1! {
                        let databaseOrmResultUDCDocumentChild = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: udcspdgv.itemId)
                        if databaseOrmResultUDCDocumentChild.databaseOrmError.count > 0 {
                            // Document map node not found
                            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentChild.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentChild.databaseOrmError[0].description))
                            return
                        }
                        let udcDocumentChild = databaseOrmResultUDCDocumentChild.object[0]
                        
                        let databaseOrmResultUDCDocumentItemChild = UDCDocumentGraphModel.get(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentChild.udcDocumentGraphModelId)
                        if databaseOrmResultUDCDocumentItemChild.databaseOrmError.count > 0 {
                            // Document map node not found
                            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentItemChild.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentItemChild.databaseOrmError[0].description))
                            return
                        }
                        let udcDocumentItemChild = databaseOrmResultUDCDocumentItemChild.object[0]
                        //                        treeLevel += 1
                        try getDocumentMap(text: text, language: language, children: udcDocumentItemChild.childrenId, udcProfile: udcProfile, path: &path, pathIdName: &pathIdName, uvcDocumentMapViewModel: &uvcDocumentMapViewModel, treeLevel: treeLevel, uvcDocumentMapViewTemplateType: uvcDocumentMapViewTemplateType, category: &category, subCategory: &subCategory, parentNodePathIdName: parentNodePathIdName, index: &index, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
                        //                        treeLevel -= 1
                        if neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError!.count > 0 {
                            return
                        }
                    }
                }
                
            }
            path.remove(at: path.count - 1)
            if pathIdName.count > 0 {
                pathIdName.remove(at: pathIdName.count - 1)
            }
        }
        
    }
    
//    private func createDocumentMap(neuronRequest: NeuronRequest) throws {
//        let uscCreateConnectionResponse = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: USCCreateConnectionResponse())
//        let udcDocumentMap = UDCDocumentMap()
//        udcDocumentMap._id = try (udbcDatabaseOrm?.generateId())!
//        udcDocumentMap.udcProfile = uscCreateConnectionResponse.udcProfile
//        let databaseOrmResultUDCDocumentMap = UDCDocumentMap.save(udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentMap)
//        if databaseOrmResultUDCDocumentMap.databaseOrmError.count > 0 {
//            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentMap.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentMap.databaseOrmError[0].description))
//            return
//        }
//    }
//
//    private func updateDocumentId(neuronRequest: NeuronRequest) throws {
//        let getDocumentResponse = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: GetDocumentResponse())
//
//        let databaseOrmResultUDCDocumentMapNode = UDCDocumentMapNode.update(udbcDatabaseOrm: udbcDatabaseOrm!, id: getDocumentResponse.udcDocumentMapNodeId, documentId: getDocumentResponse.udcDocument._id, name: getDocumentResponse.udcDocument.name) as DatabaseOrmResult<UDCDocumentMapNode>
//        if databaseOrmResultUDCDocumentMapNode.databaseOrmError.count > 0 {
//            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentMapNode.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentMapNode.databaseOrmError[0].description))
//            return
//        }
//    }
//
//    private func removeDocumentMapNode(neuronRequest: NeuronRequest) throws {
//        let removeDocumentMapNodeRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: RemoveDocumentMapNodeRequest())
//
//        let documentLanguage = removeDocumentMapNodeRequest.documentLanguage
//
//        let removeDocumentMapNodeResponse = RemoveDocumentMapNodeResponse()
//        for (udcdmnIndex, udcdmn) in removeDocumentMapNodeRequest.udcDocumentMapNode.enumerated() {
//            // Get the common document map node with document id
//            let databaseOrmResultUDCDocumentMaNodepGet = UDCDocumentMapNode.get(udbcDatabaseOrm: udbcDatabaseOrm!, documentId: udcdmn.documentId!, language: documentLanguage)
//
//            if databaseOrmResultUDCDocumentMaNodepGet.databaseOrmError.count > 0 {
//                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentMaNodepGet.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentMaNodepGet.databaseOrmError[0].description))
//                return
//
//            }
//            let udcDocumentMapNode = databaseOrmResultUDCDocumentMaNodepGet.object[0]
//
//            // Remove the map node
//            let databaseOrmResultUDCDocumentMapNodeRemove = UDCDocumentMapNode.remove(udbcDatabaseOrm: udbcDatabaseOrm!, id: udcdmn._id) as DatabaseOrmResult<UDCDocumentMapNode>
//            if databaseOrmResultUDCDocumentMapNodeRemove.databaseOrmError.count > 0 {
//                // Document map node not found
//                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentMapNodeRemove.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentMapNodeRemove.databaseOrmError[0].description))
//                return
//            }
//
//            // Remove from parent
//            let databaseOrmResultUDCDocumentMapNodeGet = UDCDocumentMapNode.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentMapNode.parentId[0], language: documentLanguage)
//            if databaseOrmResultUDCDocumentMapNodeGet.databaseOrmError.count > 0 {
//                // Document map node not found
//                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentMapNodeGet.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentMapNodeGet.databaseOrmError[0].description))
//                return
//            }
//            let udcDocumentMapNodeParent  = databaseOrmResultUDCDocumentMapNodeGet.object[0]
//            var index = 0
//            for children in udcDocumentMapNodeParent.childrenId {
//                if children == udcdmn._id {
//                    break
//                }
//                index += 1
//            }
//            udcDocumentMapNodeParent.childrenId.remove(at: index)
//
//            let databaseOrmResultUDCDocumentMapNodeUpdate = UDCDocumentMapNode.update(udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentMapNodeParent)
//            if databaseOrmResultUDCDocumentMapNodeUpdate.databaseOrmError.count > 0 {
//                // Document map node not found
//                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentMapNodeUpdate.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentMapNodeUpdate.databaseOrmError[0].description))
//                return
//            }
//            //
//            //            try callDocumentSpecificNeuronForUpdate(neuronRequest: neuronRequest, udcDocumentType: udcdmn.udcDocumentType)
//            //            if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
//            //                return
//            //            }
//
//            // Prepare the response
//
//            removeDocumentMapNodeResponse.udcDocumentMapNodeId.append(udcdmn._id)
//        }
//
//        let jsonUtilityRemoveDocumentMapNodeResponse = JsonUtility<RemoveDocumentMapNodeResponse>()
//        let jsonRemoveDocumentMapNodeResponse = jsonUtilityRemoveDocumentMapNodeResponse.convertAnyObjectToJson(jsonObject: removeDocumentMapNodeResponse)
//        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonRemoveDocumentMapNodeResponse)
//    }
//
//    private func changeDocumentMapNode(neuronRequest: NeuronRequest) throws {
//        let changeDocumentMapNodeRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: ChangeDocumentMapNodeRequest())
//
//        let documentLanguage = changeDocumentMapNodeRequest.documentLanguage
//
//        var udcDocumentMapNode: UDCDocumentMapNode?
//
//        let databaseOrmResultUDCDocumentMaNodepGet = UDCDocumentMapNode.get(udbcDatabaseOrm: udbcDatabaseOrm!, documentId: changeDocumentMapNodeRequest.udcDocumentMapNode.documentId!, language: documentLanguage)
//
//        if databaseOrmResultUDCDocumentMaNodepGet.databaseOrmError.count > 0 {
//            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentMaNodepGet.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentMaNodepGet.databaseOrmError[0].description))
//            return
//
//        }
//        udcDocumentMapNode = databaseOrmResultUDCDocumentMaNodepGet.object[0]
//        udcDocumentMapNode!.name = changeDocumentMapNodeRequest.udcDocumentMapNode.name
//
//        let databaseOrmResultUDCDocumentMapNodeUpdate = UDCDocumentMapNode.update(udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentMapNode!)
//        if databaseOrmResultUDCDocumentMapNodeUpdate.databaseOrmError.count > 0 {
//            // Document map node not found
//            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentMapNodeUpdate.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentMapNodeUpdate.databaseOrmError[0].description))
//            return
//        }
//
//        //        try callDocumentSpecificNeuronForUpdate(neuronRequest: neuronRequest, udcDocumentType: changeDocumentMapNodeRequest.udcDocumentMapNode.udcDocumentType)
//        //        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
//        //            return
//        //        }
//
//        // Prepare the response
//        let changeDocumentMapNodeResponse = ChangeDocumentMapNodeResponse()
//        changeDocumentMapNodeResponse._id = changeDocumentMapNodeRequest.parentId
//        let jsonUtilityChangeDocumentMapNodeResponse = JsonUtility<ChangeDocumentMapNodeResponse>()
//        let jsonChangeDocumentMapNodeResponse = jsonUtilityChangeDocumentMapNodeResponse.convertAnyObjectToJson(jsonObject: changeDocumentMapNodeResponse)
//        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonChangeDocumentMapNodeResponse)
//    }
//
    
    private func callDocumentSpecificNeuronForUpdate(neuronRequest: NeuronRequest, udcDocumentType: String) throws {
        let neuronRequestLocal = NeuronRequest()
        neuronRequestLocal.neuronSource._id = neuronRequest.neuronSource._id
        neuronRequestLocal.neuronOperation.synchronus = true
        neuronRequestLocal.neuronOperation._id = neuronRequest.neuronOperation._id
        neuronRequestLocal.neuronSource.name = DocumentMapNeuron.getName()
        neuronRequestLocal.neuronSource.type = DocumentMapNeuron.getName();
        neuronRequestLocal.neuronOperation.name = neuronRequest.neuronOperation.name
        neuronRequestLocal.neuronOperation.parent = true
        neuronRequestLocal.neuronOperation.neuronData.text = neuronRequest.neuronOperation.neuronData.text
        neuronRequestLocal.neuronTarget.name =  neuronUtility!.getNeuronName(udcDocumentTypeIdName: udcDocumentType)!
        
        neuronUtility!.callNeuron(neuronRequest: neuronRequestLocal, udcDocumentTypeIdName: udcDocumentType)
        
        let neuronResponseLocal = getChildResponse(sourceId: neuronRequestLocal.neuronSource._id)
        
        if neuronResponseLocal.neuronOperation.neuronOperationStatus.neuronOperationError!.count > 0 {
            print("\(DocumentMapNeuron.getName()) Errors from child neuron: \(neuronRequest.neuronOperation.name))")
            neuronResponse.neuronOperation.response = true
            for noe in neuronResponseLocal.neuronOperation.neuronOperationStatus.neuronOperationError! {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(noe)
            }
        } else {
            for noe in neuronResponseLocal.neuronOperation.neuronOperationStatus.neuronOperationSuccess! {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationSuccess?.append(noe)
            }
            print("\(DocumentMapNeuron.getName()) Success from child neuron: \(neuronRequest.neuronOperation.name))")
            
        }
        
    }
    
    private func getDocumentMapNode(rootNodeId: [String], parentPathIdName: [String], language: String) -> UDCDocumentMapNode? {
        for id in rootNodeId {
            let databaseOrmResultUDCDocumentMapNodeGet = UDCDocumentMapNode.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: id, language: language)
            if databaseOrmResultUDCDocumentMapNodeGet.databaseOrmError.count > 0 {
                // Document map node not found
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentMapNodeGet.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentMapNodeGet.databaseOrmError[0].description))
                return nil
            }
            let udcDocumentMapNode = databaseOrmResultUDCDocumentMapNodeGet.object[0]
            if udcDocumentMapNode.pathIdName.joined(separator: "->") == parentPathIdName.joined(separator: "->") {
                return udcDocumentMapNode
            }
            
            if udcDocumentMapNode.childrenId.count > 0 {
                let returnValue = getDocumentMapNode(rootNodeId: udcDocumentMapNode.childrenId, parentPathIdName: parentPathIdName, language: language)
                if returnValue != nil {
                    return returnValue
                }
            }
        }
        
        return nil
    }
    
//    private func addDocumentMapNode(neuronRequest: NeuronRequest) throws {
//        let addDocumentMapNodeRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: AddDocumentMapNodeRequest())
//
//        let documentLanguage = addDocumentMapNodeRequest.documentLanguage
//        let addDocumentMapNodeResponse = AddDocumentMapNodeResponse()
//
//        // Get the common document map
//        let databaseOrmResultUDCDocumentMapGet = UDCDocumentMap.get(udbcDatabaseOrm: udbcDatabaseOrm!, idName: "UDCOptionMap.DocumentMap",  udcProfile: addDocumentMapNodeRequest.udcProfile, language: documentLanguage)
//        if databaseOrmResultUDCDocumentMapGet.databaseOrmError.count > 0 {
//            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentMapGet.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentMapGet.databaseOrmError[0].description))
//            return
//
//        }
//        let udcDocumentMap = databaseOrmResultUDCDocumentMapGet.object[0]
//
//        for parentPathIdName in addDocumentMapNodeRequest.parentPathIdName {
//            // From root node search where the path is found
//            let udcDocumentMapNode = getDocumentMapNode(rootNodeId: udcDocumentMap.udcDocumentMapNodeId, parentPathIdName: parentPathIdName, language: documentLanguage)
//
//            if udcDocumentMapNode == nil {
//                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "PathNotFound", description: "Path not found"))
//                return
//            }
//
//            for udcdmn in addDocumentMapNodeRequest.udcDocumentMapNode {
//                // Save the new node
//                let oldDocumentMapNodeId = udcdmn._id
//                udcdmn._id = try (udbcDatabaseOrm?.generateId())!
//                let databaseOrmResultUDCDocumentMapNodeSave = UDCDocumentMapNode.save(udbcDatabaseOrm: udbcDatabaseOrm!, object: udcdmn)
//                if databaseOrmResultUDCDocumentMapNodeSave.databaseOrmError.count > 0 {
//                    // Document map node save failure
//                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentMapNodeSave.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentMapNodeSave.databaseOrmError[0].description))
//                    return
//                }
//
//                // Linke the new node as child to the parent
//                udcDocumentMapNode!.childrenId.append(udcdmn._id)
//                let databaseOrmResultUDCDocumentMapNodeUpdate = UDCDocumentMapNode.update(udbcDatabaseOrm: udbcDatabaseOrm!, object: udcDocumentMapNode!)
//                if databaseOrmResultUDCDocumentMapNodeUpdate.databaseOrmError.count > 0 {
//                    // Document map node not found
//                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentMapNodeUpdate.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentMapNodeUpdate.databaseOrmError[0].description))
//                    return
//                }
//
//
//                // Prepare the response
//                addDocumentMapNodeResponse.oldUdcDocumentMapNodeId.append(oldDocumentMapNodeId)
//                addDocumentMapNodeResponse.udcDocumentMapNodeId.append(udcdmn._id)
//            }
//        }
//
//        let jsonUtilityAddDocumentNodeResponse = JsonUtility<AddDocumentMapNodeResponse>()
//        let jsonAddDocumentNodeResponse = jsonUtilityAddDocumentNodeResponse.convertAnyObjectToJson(jsonObject: addDocumentMapNodeResponse)
//        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonAddDocumentNodeResponse)
//    }
    
    private func linkAllMap(udcDocumentMapNodeCommon: inout [UDCDocumentMapNode], udcDocumentMapNodeUser: inout [UDCDocumentMapNode], udcDocumentMapNodeApp: inout [UDCDocumentMapNode], udcDocumentMapNode: inout [UDCDocumentMapNode]) {
        for udmnc in udcDocumentMapNodeCommon {
            if udmnc.name == "My Recipes" {
                if udcDocumentMapNodeUser.count > 0 {
                    for udmnu in udcDocumentMapNodeUser {
                        udmnc.childrenId.append(udmnu._id)
                        udmnu.parentId.append(udmnc._id)
                    }
                    
                }
            } else if udmnc.name == "Universe Docs Recipes" {
                if udcDocumentMapNodeApp.count > 0 {
                    for udmna in udcDocumentMapNodeApp {
                        udmnc.childrenId.append(udmna._id)
                        udmna.parentId.append(udmnc._id)
                    }
                    
                }
            }
            udcDocumentMapNode.append(udmnc)
        }
        for udmnu in udcDocumentMapNodeUser {
            udcDocumentMapNode.append(udmnu)
        }
        for udmna in udcDocumentMapNodeApp {
            udcDocumentMapNode.append(udmna)
        }
    }
    
    private func generateDocumentMapView(getDocumentMapRequest: GetDocumentMapRequest, udcDocumentMapNode: inout [UDCDocumentMapNode], language: String, isOptionAvailable: Bool) -> UVCDocumentMapViewModel {
        let uvcDocumentMapViewModel = UVCDocumentMapViewModel()
        let uvcViewGenerator = UVCViewGenerator()

        for udcdmn in udcDocumentMapNode {
            let uvcTreeNode = UVCTreeNode()
            uvcTreeNode._id = udcdmn._id
            for parent in udcdmn.parentId {
                uvcTreeNode.parentId.append(parent)
            }
            for children in udcdmn.childrenId {
                uvcTreeNode.childrenId.append(children)
            }
            uvcTreeNode.level = udcdmn.level
            uvcTreeNode.path = udcdmn.path
            uvcTreeNode.pathIdName = udcdmn.pathIdName
            print("DEBUG MAP \(udcdmn.pathIdName.joined(separator: "->")): \(uvcTreeNode._id)")
            uvcTreeNode.objectId = udcdmn.documentId!
            uvcTreeNode.objectType = udcdmn.udcDocumentType
            uvcTreeNode.isOptionAvailable = isOptionAvailable
            uvcTreeNode.isChidlrenOnDemandLoading = udcdmn.isChidlrenOnDemandLoading
            let isChildrenExist = uvcTreeNode.childrenId.count > 0 || udcdmn.isChidlrenOnDemandLoading
            var textColor = UVCColor.get("UVCColor.Black")
            if udcdmn.childrenId.count == 0 {
                if udcdmn.udcDocumentAccessType.contains("UDCDocumentAccessType.Read") &&
                    udcdmn.udcDocumentAccessType.contains("UDCDocumentAccessType.Write") &&
                    udcdmn.udcDocumentAccessType.contains("UDCDocumentAccessType.Delete") &&
                    udcdmn.udcDocumentAccessType.contains("UDCDocumentAccessType.Share") {
                    textColor = UVCColor.get("UVCColor.DarkGreen")
                } else if udcdmn.udcDocumentAccessType.contains("UDCDocumentAccessType.Read") &&
                    !udcdmn.udcDocumentAccessType.contains("UDCDocumentAccessType.Write") &&
                    !udcdmn.udcDocumentAccessType.contains("UDCDocumentAccessType.Delete") &&
                    !udcdmn.udcDocumentAccessType.contains("UDCDocumentAccessType.Share") {
                    textColor = UVCColor.get("UVCColor.Purple")
                } else if udcdmn.udcDocumentAccessType.contains("UDCDocumentAccessType.Read") &&
                    udcdmn.udcDocumentAccessType.contains("UDCDocumentAccessType.Write") &&
                    !udcdmn.udcDocumentAccessType.contains("UDCDocumentAccessType.Delete") &&
                    !udcdmn.udcDocumentAccessType.contains("UDCDocumentAccessType.Share") {
                    textColor = UVCColor.get("UVCColor.Pink")
                }
            }
            uvcTreeNode.language = udcdmn.language
            uvcTreeNode.isReference = udcdmn.isReference
            uvcTreeNode.uvcViewModel = uvcViewGenerator.getTreeNodeViewModel(name: udcdmn.name, description: udcdmn.description, path: "", language: uvcTreeNode.language, isChildrenExist: isChildrenExist,
                                                                             uvcDocumentMapViewTemplateType: getDocumentMapRequest.uvcDocumentMapViewTemplateType, textColor: textColor, udcDocumentTypeIdName: udcdmn.udcDocumentType, isOptionAvailable: isOptionAvailable)
            uvcDocumentMapViewModel.uvcTreeNode.append(uvcTreeNode)
        }

        return uvcDocumentMapViewModel
    }
    
    private func loadDocumentMapNode(getDocumentMapRequest: GetDocumentMapRequest, udcDocumentMapNodeId: [String], language: String, udcDocumentMapNode: inout [UDCDocumentMapNode], maximumNodesPerParent: Int) {
        var count = 0
        for udcdmnid in udcDocumentMapNodeId {
            if count == maximumNodesPerParent && maximumNodesPerParent > 0 {
                break
            }
            var found: Bool = false
            for udcdmn in udcDocumentMapNode {
                if udcdmn._id == udcdmnid {
                    found = true
                    break
                }
            }
            if found {
                continue
            }
            // Get Document map node
            let databaseOrmResultUDCDocumentMapNode = UDCDocumentMapNode.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: udcdmnid, language: language)
            if databaseOrmResultUDCDocumentMapNode.databaseOrmError.count > 0 {
                // Document map node not found
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentMapNode.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentMapNode.databaseOrmError[0].description))
                return
            }
            let udcDocumentMapNodeLocal = databaseOrmResultUDCDocumentMapNode.object[0]
            print("NAME: \(udcDocumentMapNodeLocal.name)")
            var accessAllowed: Bool = false
            if !udcDocumentMapNodeLocal.documentId!.isEmpty {
                let databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentMapNodeLocal.documentId!, language: udcDocumentMapNodeLocal.language)
                if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
                    accessAllowed = true
                } else {
                    let udcDocument = databaseOrmResultUDCDocument.object[0]
                    for udcDocumentAccessProfile in udcDocument.udcDocumentAccessProfile {
                        if udcDocumentAccessProfile.udcProfileItemIdName == "UDCProfileItem.Human" {
                            if !udcDocumentAccessProfile.profileId.isEmpty {
                                if getDocumentMapRequest.upcHumanProfileId == udcDocumentAccessProfile.profileId {
                                    if udcDocumentAccessProfile.udcDocumentAccessType.contains("UDCDocumentAccessType.Read") || udcDocumentAccessProfile.udcDocumentAccessType.contains("UDCDocumentAccessType.Write") {
                                        accessAllowed = true
                                        udcDocumentMapNodeLocal.udcDocumentAccessType.removeAll()
                                        udcDocumentMapNodeLocal.udcDocumentAccessType.append(contentsOf: udcDocumentAccessProfile.udcDocumentAccessType)
                                    }
                                }
                            }
                        }
                    }
                }
                
            } else {
                accessAllowed = true
            }
            if accessAllowed {
                udcDocumentMapNodeLocal.name = udcDocumentMapNodeLocal.name.capitalized
                for (indexPath, p) in udcDocumentMapNodeLocal.path.enumerated() {
                    udcDocumentMapNodeLocal.path[indexPath] = p.capitalized
                }
                udcDocumentMapNode.append(udcDocumentMapNodeLocal)
            }
            if udcDocumentMapNodeLocal.childrenId.count > 0 && udcDocumentMapNodeLocal.childrenId[0] == "dummy" {
                continue
            }
            count += 1
            if udcDocumentMapNodeLocal.childrenId.count > 0 {
                // Recurse until all childrens are loaded
                loadDocumentMapNode(getDocumentMapRequest: getDocumentMapRequest, udcDocumentMapNodeId: udcDocumentMapNodeLocal.childrenId, language: language, udcDocumentMapNode: &udcDocumentMapNode, maximumNodesPerParent: maximumNodesPerParent)
                if neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError!.count > 0 {
                    return
                }
            }
        }
    }
    
    private func loadDocumentMapNode(getDocumentMapRequest: GetDocumentMapRequest, childrenId: [String], language: String, udcDocumentMapNode: inout [UDCDocumentMapNode], maximumNodesPerParent: Int, pathIdName: inout [String], initialLoad: Bool, treeLevel: inout Int) throws {
        var count = 0
        for documentItemId in childrenId {
            if count == maximumNodesPerParent && maximumNodesPerParent > 0 {
                break
            }
            var found: Bool = false
            for udcdmn in udcDocumentMapNode {
                if udcdmn._id == documentItemId {
                    found = true
                    break
                }
            }
            if found {
                continue
            }
            // Get Document map node
            let databaseOrmResultUDCDocumentItem = UDCDocumentGraphModel.get(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, id: documentItemId)
            if databaseOrmResultUDCDocumentItem.databaseOrmError.count > 0 {
                // Document map node not found
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentItem.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentItem.databaseOrmError[0].description))
                return
            }
            let udcDocumentItem = databaseOrmResultUDCDocumentItem.object[0]
            
            //            if !initialLoad && udcDocumentItem.level - 1 > getDocumentMapRequest.treeLevel {
            //                return
            //            }
            //            if initialLoad && udcDocumentItem.level - 1 > 1 {
            //                return
            //            }
            //
            let udcDocumentMapNodeLocal = UDCDocumentMapNode()
            udcDocumentMapNodeLocal._id = udcDocumentItem._id
            udcDocumentMapNodeLocal.name = udcDocumentItem.name
            udcDocumentMapNodeLocal.parentId.append(contentsOf: udcDocumentItem.parentId)
            if udcDocumentItem.childrenId.count > 0 {
                udcDocumentMapNodeLocal.childrenId.append(contentsOf: udcDocumentItem.childrenId)
            }
            var documentId = ""
            var udcDocumentTypeIdName = "UDCDocumentType.None"
            var fieldValueMap = [String: [UDCSentencePatternDataGroupValue]]()
            
            if !udcDocumentItem.documentMapObjectId.isEmpty {
                let databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentItem.documentMapObjectId)
                if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocument.databaseOrmError[0].name, description: databaseOrmResultUDCDocument.databaseOrmError[0].description))
                    return
                }
                let udcDocument = databaseOrmResultUDCDocument.object[0]
                
                
                let databaseOrmResultParent = UDCDocumentGraphModel.get(collectionName: "UDCDocumentMap", udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocument.udcDocumentGraphModelId, language: language)
                if databaseOrmResultParent.databaseOrmError.count > 0 {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultParent.databaseOrmError[0].name, description: databaseOrmResultParent.databaseOrmError[0].description))
                    return
                }
                let udcDocumentItemConfigurationParent = databaseOrmResultParent.object[0]
                
                let databaseOrmResult = UDCDocumentGraphModel.get(collectionName: "UDCDocumentMap", udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentItemConfigurationParent.childrenId[0], language: language)
                if databaseOrmResult.databaseOrmError.count > 0 {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResult.databaseOrmError[0].name, description: databaseOrmResult.databaseOrmError[0].description))
                    return
                }
                
                let udcDocumentItemConfiguration = databaseOrmResult.object[0]
                var fieldUdcspdvArray: [UDCSentencePatternDataGroupValue]?
                documentParser.getField(fieldidName: "UDCDocumentItem.ReferenceDocument", childrenId: udcDocumentItemConfiguration.childrenId, fieldValue: &fieldValueMap, udcDocumentTypeIdName: "UDCDocumentType.DocumentMap", documentLanguage: language)
                fieldUdcspdvArray = fieldValueMap["UDCDocumentItem.ReferenceDocument"]
                if fieldUdcspdvArray != nil {
                    udcDocumentMapNodeLocal.isReference = true
                    for udcspdgv in fieldUdcspdvArray! {
                        let modelId = udcspdgv.itemId
                        documentId = modelId
                        let databaseOrmResultDocumentItemRef = UDCDocumentGraphModel.get(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, id: modelId, language: language)
                        if databaseOrmResultDocumentItemRef.databaseOrmError.count > 0 {
                            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultDocumentItemRef.databaseOrmError[0].name, description: databaseOrmResultDocumentItemRef.databaseOrmError[0].description))
                            return
                        }
                        let udcDocumentItempRef = databaseOrmResultDocumentItemRef.object[0]
                        if !udcDocumentItempRef.documentMapObjectId.isEmpty {
                            let databaseOrmResultUDCDocumentRef = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentItempRef.documentMapObjectId)
                            if databaseOrmResultUDCDocumentRef.databaseOrmError.count > 0 {
                                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentRef.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentRef.databaseOrmError[0].description))
                                return
                            }
                            let udcDocumentRef = databaseOrmResultUDCDocumentRef.object[0]
                            
                            let databaseOrmResultRefParent = UDCDocumentGraphModel.get(collectionName: "UDCDocumentMap", udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentRef.udcDocumentGraphModelId)
                            if databaseOrmResultRefParent.databaseOrmError.count > 0 {
                                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultRefParent.databaseOrmError[0].name, description: databaseOrmResultRefParent.databaseOrmError[0].description))
                                return
                            }
                            let udcDocumentItemConfigurationRefParent = databaseOrmResultRefParent.object[0]
                            
                            let databaseOrmResultRef = UDCDocumentGraphModel.get(collectionName: "UDCDocumentMap", udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentItemConfigurationRefParent.childrenId[0])
                            if databaseOrmResultRef.databaseOrmError.count > 0 {
                                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultRef.databaseOrmError[0].name, description: databaseOrmResultRef.databaseOrmError[0].description))
                                return
                            }
                            let udcDocumentItemConfigurationRef = databaseOrmResultRef.object[0]
                            var fieldValueMapRef = [String: [UDCSentencePatternDataGroupValue]]()
                            documentParser.getField(fieldidName: "UDCDocumentItem.Document", childrenId: udcDocumentItemConfigurationRef.childrenId, fieldValue: &fieldValueMapRef, udcDocumentTypeIdName: "UDCDocumentType.DocumentMap", documentLanguage: language)
                            let fieldUdcspdvArrayRef = fieldValueMapRef["UDCDocumentItem.Document"]
                            if fieldUdcspdvArrayRef != nil {
                                for udcspdgv in fieldUdcspdvArrayRef! {
                                    documentId = udcspdgv.itemId
                                    let databaseOrmResultDocumentType = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: udcspdgv.udcDocumentId)
                                    if databaseOrmResultDocumentType.databaseOrmError.count > 0 {
                                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultDocumentType.databaseOrmError[0].name, description: databaseOrmResultDocumentType.databaseOrmError[0].description))
                                        return
                                    }
                                    udcDocumentTypeIdName = databaseOrmResultDocumentType.object[0].udcDocumentTypeIdName
                                    
//                                    if udcspdgv.endCategoryIdName == "UDCDocumentItem.Document" {
//                                        udcDocumentTypeIdName = udcspdgv.endCategoryId
//                                    } else {
//                                        udcDocumentTypeIdName = udcspdgv.endSubCategoryIdName
//                                    }
                                    udcDocumentMapNodeLocal.isReference = false
                                    break
                                }
                            }
                        }
                        break
                    }
                }
                if udcDocumentItem.isChildrenAllowed {
                    documentParser.getField(fieldidName: "UDCDocumentItem.ChildDocument", childrenId: udcDocumentItemConfiguration.childrenId, fieldValue: &fieldValueMap, udcDocumentTypeIdName: "UDCDocumentType.DocumentMap", documentLanguage: language)
                    fieldUdcspdvArray = fieldValueMap["UDCDocumentItem.ChildDocument"]
                    if fieldUdcspdvArray != nil {
                        for udcspdgv in fieldUdcspdvArray! {
                            documentId = udcspdgv.itemId
                            break
                        }
                    }
                } else {
                    documentParser.getField(fieldidName: "UDCDocumentItem.Document", childrenId: udcDocumentItemConfiguration.childrenId, fieldValue: &fieldValueMap, udcDocumentTypeIdName: "UDCDocumentType.DocumentMap", documentLanguage: language)
                    fieldUdcspdvArray = fieldValueMap["UDCDocumentItem.Document"]
                    if fieldUdcspdvArray != nil {
                        for udcspdgv in fieldUdcspdvArray! {
                            documentId = udcspdgv.itemId
                            udcDocumentTypeIdName = udcspdgv.endSubCategoryIdName
                            break
                        }
                    }
                }
            }
            udcDocumentMapNodeLocal.documentId = documentId
            
            
            
            udcDocumentMapNodeLocal.language = udcDocumentItem.language
            if initialLoad {
                udcDocumentMapNodeLocal.level = udcDocumentItem.level - 1
            } else {
                if udcDocumentItem.level - 1 == 0 {
                    udcDocumentMapNodeLocal.level = treeLevel - 1
                } else {
                    udcDocumentMapNodeLocal.level = treeLevel
                }
            }
            udcDocumentMapNodeLocal.udcDocumentType = udcDocumentTypeIdName
            pathIdName.append(udcDocumentItem.idName)
            udcDocumentMapNodeLocal.pathIdName.append(contentsOf: pathIdName)
            print("NAME: \(udcDocumentMapNodeLocal.name)")
            var accessAllowed: Bool = false
            if !udcDocumentMapNodeLocal.documentId!.isEmpty {
                let databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentMapNodeLocal.documentId!, language: udcDocumentMapNodeLocal.language)
                if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
                    accessAllowed = true
                } else {
                    let udcDocument = databaseOrmResultUDCDocument.object[0]
                    for udcDocumentAccessProfile in udcDocument.udcDocumentAccessProfile {
                        if udcDocumentAccessProfile.udcProfileItemIdName == "UDCProfileItem.Human" {
                            if !udcDocumentAccessProfile.profileId.isEmpty {
                                if getDocumentMapRequest.upcHumanProfileId == udcDocumentAccessProfile.profileId {
                                    if udcDocumentAccessProfile.udcDocumentAccessType.contains("UDCDocumentAccessType.Read") || udcDocumentAccessProfile.udcDocumentAccessType.contains("UDCDocumentAccessType.Write") {
                                        accessAllowed = true
                                        udcDocumentMapNodeLocal.udcDocumentAccessType.removeAll()
                                        udcDocumentMapNodeLocal.udcDocumentAccessType.append(contentsOf: udcDocumentAccessProfile.udcDocumentAccessType)
                                    }
                                }
                            }
                        }
                    }
                }
                
            } else {
                accessAllowed = true
            }
            if accessAllowed {
                udcDocumentMapNodeLocal.name = udcDocumentMapNodeLocal.name.capitalized
                for (indexPath, p) in udcDocumentMapNodeLocal.path.enumerated() {
                    udcDocumentMapNodeLocal.path[indexPath] = p.capitalized
                }
                udcDocumentMapNode.append(udcDocumentMapNodeLocal)
            }
            count += 1
            if udcDocumentItem.childrenId.count > 0 {
                // Recurse until all childrens are loaded
                udcDocumentMapNodeLocal.isChidlrenOnDemandLoading = false
                treeLevel += 1
                try loadDocumentMapNode(getDocumentMapRequest: getDocumentMapRequest, childrenId: udcDocumentItem.childrenId, language: language, udcDocumentMapNode: &udcDocumentMapNode, maximumNodesPerParent: maximumNodesPerParent, pathIdName: &pathIdName, initialLoad: initialLoad, treeLevel: &treeLevel)
                treeLevel -= 1
                if neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError!.count > 0 {
                    return
                }
            } else if udcDocumentItem.isChildrenAllowed && udcDocumentItem.childrenId.count == 0 {
                udcDocumentMapNodeLocal.isChidlrenOnDemandLoading = true
            } else {
                udcDocumentMapNodeLocal.isChidlrenOnDemandLoading = false
            }
            pathIdName.remove(at: pathIdName.count - 1)
        }
    }
    
    private func getNoData(parentName: String, parentId: String, treeLevel: Int, pathIdName: [String], uvcDocumentMapViewTemplateType: String, interfaceLanguage: String, uvcTreeNodeReturn: inout [UVCTreeNode], neuronRequest: NeuronRequest) {
        let databaseOrmResultUDCOptionMapNode = UDCOptionMapNode.get("UDCOptionMapNode.NoData", udbcDatabaseOrm!, interfaceLanguage)
        if databaseOrmResultUDCOptionMapNode.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCOptionMapNode.databaseOrmError[0].name, description: databaseOrmResultUDCOptionMapNode.databaseOrmError[0].description))
            return
        }
        let udcOptionMapNode = databaseOrmResultUDCOptionMapNode.object[0]
        
        var uvcTreeNode = UVCTreeNode()
        do {
            uvcTreeNode._id = try udbcDatabaseOrm!.generateId()
        } catch {}
        uvcTreeNode.parentId.append(parentId)
        uvcTreeNode.level = treeLevel - 1
        uvcTreeNode.pathIdName = pathIdName
        uvcTreeNode.objectId = ""
        uvcTreeNode.objectType = ""
        
        uvcTreeNode.language = interfaceLanguage
        
        uvcTreeNode.uvcViewModel = uvcViewGenerator.getTreeNodeViewModel(name: parentName, description: "", path: "", language: uvcTreeNode.language, isChildrenExist: false,
                                                                         uvcDocumentMapViewTemplateType: uvcDocumentMapViewTemplateType, textColor: UVCColor.get("UVCColor.Black"), udcDocumentTypeIdName: "", isOptionAvailable: false)
        uvcTreeNodeReturn.append(uvcTreeNode)
        
        uvcTreeNode = UVCTreeNode()
        do {
            uvcTreeNode._id = try udbcDatabaseOrm!.generateId()
        } catch {}
        uvcTreeNode.parentId.append(parentId)
        uvcTreeNode.level = treeLevel
        uvcTreeNode.pathIdName = pathIdName
        uvcTreeNode.pathIdName.append(udcOptionMapNode.name)
        uvcTreeNode.objectId = ""
        uvcTreeNode.objectType = ""
        
        uvcTreeNode.language = interfaceLanguage
        
        uvcTreeNode.uvcViewModel = uvcViewGenerator.getTreeNodeViewModel(name: udcOptionMapNode.name, description: "", path: "", language: uvcTreeNode.language, isChildrenExist: false,
                                                                         uvcDocumentMapViewTemplateType: uvcDocumentMapViewTemplateType, textColor: UVCColor.get("UVCColor.Black"), udcDocumentTypeIdName: "", isOptionAvailable: false)
        uvcTreeNodeReturn.append(uvcTreeNode)
    }
    
    private func getDocumentMap(neuronRequest: NeuronRequest) {
        let getDocumentMapRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: GetDocumentMapRequest())
        
        let interfaceLanguage = getDocumentMapRequest.interfaceLanguage
        
        var udcDocumentMapNode = [UDCDocumentMapNode]()
        //        var udcDocumentMap = UDCDocumentMap()
        
        //         Get the common document map
        //                let databaseOrmResultUDCDocumentMapGet = UDCDocumentMap.get(udbcDatabaseOrm: udbcDatabaseOrm!, name: "UDCOptionMap.DocumentMap", language: interfaceLanguage)
        //                if databaseOrmResultUDCDocumentMapGet.databaseOrmError.count > 0 {
        //                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentMapGet.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentMapGet.databaseOrmError[0].description))
        //                    return
        //
        //                }
        //                udcDocumentMap = databaseOrmResultUDCDocumentMapGet.object[0]
        
        // Get the document of document map
        var getDocumentMapResponse = GetDocumentMapResponse()
        var udcDocumentItemForMap: UDCDocumentGraphModel?
        var initialLoad = true
        var isFolder = true
        var udcDocument: UDCDocument?
        if getDocumentMapRequest.udcDocumentId == nil {
            let databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, udcProfile: getDocumentMapRequest.udcProfile, idName: "UDCDocument.DocumentMap", udcDocumentTypeIdName: "UDCDocumentType.DocumentItem", language: interfaceLanguage)
            if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocument.databaseOrmError[0].name, description: databaseOrmResultUDCDocument.databaseOrmError[0].description))
                return
                
            }
            udcDocument = databaseOrmResultUDCDocument.object[0]
        } else {
            initialLoad = false
            
            if !getDocumentMapRequest.isReference {
                let databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: getDocumentMapRequest.udcDocumentId!)
                if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
                    var uvcTreeNode = [UVCTreeNode]()
                    let databaseOrmDocumentItemParent = UDCDocumentGraphModel.get(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, id: getDocumentMapRequest.parentId)
                    if databaseOrmDocumentItemParent.databaseOrmError.count > 0 {
                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmDocumentItemParent.databaseOrmError[0].name, description: databaseOrmDocumentItemParent.databaseOrmError[0].description))
                        return
                        
                    }
                    let udcDocumentItemParent = databaseOrmDocumentItemParent.object[0]
                    getNoData(parentName: udcDocumentItemParent.name, parentId: getDocumentMapRequest.parentId, treeLevel: getDocumentMapRequest.treeLevel, pathIdName: getDocumentMapRequest.pathIdName!, uvcDocumentMapViewTemplateType: getDocumentMapRequest.uvcDocumentMapViewTemplateType, interfaceLanguage: interfaceLanguage, uvcTreeNodeReturn: &uvcTreeNode, neuronRequest: neuronRequest)
                    getDocumentMapResponse.uvcDocumentMapViewModel.uvcTreeNode.append(contentsOf: uvcTreeNode)
                    getDocumentMapResponse.isDynamicMap = true
                    getDocumentMapResponse.pathIdName = getDocumentMapRequest.pathIdName!
                    let jsonUtilityGetDocumentMapResponse = JsonUtility<GetDocumentMapResponse>()
                    let jsonGetDocumentMapResponse = jsonUtilityGetDocumentMapResponse.convertAnyObjectToJson(jsonObject: getDocumentMapResponse)
                    neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonGetDocumentMapResponse)
                    return
                }
                udcDocument = databaseOrmResultUDCDocument.object[0]
            } else {
                getDocumentMapResponse.isReference = getDocumentMapRequest.isReference
                let databaseOrmDocumentItemEnTitle = UDCDocumentGraphModel.get(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, id: getDocumentMapRequest.udcDocumentId!)
                if databaseOrmDocumentItemEnTitle.databaseOrmError.count > 0 {
                    var uvcTreeNode = [UVCTreeNode]()
                    let databaseOrmDocumentItemParent = UDCDocumentGraphModel.get(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, id: getDocumentMapRequest.parentId)
                    if databaseOrmDocumentItemParent.databaseOrmError.count > 0 {
                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmDocumentItemParent.databaseOrmError[0].name, description: databaseOrmDocumentItemParent.databaseOrmError[0].description))
                        return
                        
                    }
                    let udcDocumentItemParent = databaseOrmDocumentItemParent.object[0]
                    getNoData(parentName: udcDocumentItemParent.name, parentId: getDocumentMapRequest.parentId, treeLevel: getDocumentMapRequest.treeLevel, pathIdName: getDocumentMapRequest.pathIdName!, uvcDocumentMapViewTemplateType: getDocumentMapRequest.uvcDocumentMapViewTemplateType, interfaceLanguage: interfaceLanguage, uvcTreeNodeReturn: &uvcTreeNode, neuronRequest: neuronRequest)
                    getDocumentMapResponse.uvcDocumentMapViewModel.uvcTreeNode.append(contentsOf: uvcTreeNode)
                    getDocumentMapResponse.isDynamicMap = true
                    getDocumentMapResponse.pathIdName = getDocumentMapRequest.pathIdName!
                    let jsonUtilityGetDocumentMapResponse = JsonUtility<GetDocumentMapResponse>()
                    let jsonGetDocumentMapResponse = jsonUtilityGetDocumentMapResponse.convertAnyObjectToJson(jsonObject: getDocumentMapResponse)
                    neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonGetDocumentMapResponse)
                    return
                }
                udcDocumentItemForMap = databaseOrmDocumentItemEnTitle.object[0]
            }
            
        }
        
        if !getDocumentMapRequest.isReference  {
            let databaseOrmDocumentItemEnTitle = UDCDocumentGraphModel.get(collectionName: "UDCDocumentItem", udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocument!.udcDocumentGraphModelId)
            if databaseOrmDocumentItemEnTitle.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmDocumentItemEnTitle.databaseOrmError[0].name, description: databaseOrmDocumentItemEnTitle.databaseOrmError[0].description))
                return
                
            }
            udcDocumentItemForMap = databaseOrmDocumentItemEnTitle.object[0]
        }
        //         Load all the common document map nodes
        var pathIdName = [String]()
        if !initialLoad {
            if !getDocumentMapRequest.isReference {
                var temp = getDocumentMapRequest.pathIdName!
                temp.remove(at: temp.count - 1)
                pathIdName.append(contentsOf: temp)
            } else {
                pathIdName.append(contentsOf: getDocumentMapRequest.pathIdName!)
            }
        }
        do {
            var treeLevel = getDocumentMapRequest.treeLevel
            if !getDocumentMapRequest.isReference {
                treeLevel -= 1
            }
            try loadDocumentMapNode(getDocumentMapRequest: getDocumentMapRequest, childrenId: udcDocumentItemForMap!.childrenId,  language: interfaceLanguage, udcDocumentMapNode: &udcDocumentMapNode, maximumNodesPerParent: 0, pathIdName: &pathIdName, initialLoad: initialLoad, treeLevel: &treeLevel)
        } catch {
            return
        }
        //                loadDocumentMapNode(getDocumentMapRequest: getDocumentMapRequest, udcDocumentMapNodeId: udcDocumentMap.udcDocumentMapNodeId,  language: interfaceLanguage, udcDocumentMapNode: &udcDocumentMapNode, maximumNodesPerParent: 25)
        
        //        let databaseOrmResultUDCDocumentType = UDCDocumentType.get(limitedTo: 0, sortedBy: "_id", udbcDatabaseOrm: udbcDatabaseOrm!, language: neuronRequest.language)
        //        if databaseOrmResultUDCDocumentType.databaseOrmError.count > 0 {
        //            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentType.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentType.databaseOrmError[0].description))
        //            return
        //        }
        //        let udcDocumentType = databaseOrmResultUDCDocumentType.object
        //
        //        for docType in udcDocumentType {
        //            let databaseOrmResultUDCDocumentMap = UDCDocumentMap.get(udbcDatabaseOrm: udbcDatabaseOrm!, idName: "UDCOptionMap.\(docType.idName.components(separatedBy: ".")[1])All", upcCompanyProfileId: getDocumentMapRequest.upcCompanyProfileId, upcApplicationProfileId: getDocumentMapRequest.upcApplicationProfileId)
        //            if databaseOrmResultUDCDocumentMap.databaseOrmError.count == 0 {
        //                let udcDocumentMapLanguage = databaseOrmResultUDCDocumentMap.object[0]
        //                if udcDocumentMapLanguage.language != "en" {
        //                    var udcDocumentMapNodeLanguage = [UDCDocumentMapNode]()
        //                    loadDocumentMapNode(getDocumentMapRequest: getDocumentMapRequest, udcDocumentMapNodeId: udcDocumentMapLanguage.udcDocumentMapNodeId,  language: udcDocumentMapLanguage.language, udcDocumentMapNode: &udcDocumentMapNodeLanguage, maximumNodesPerParent: 25)
        //
        //                    for udcdmn in udcDocumentMapNode {
        //                        if udcdmn.pathIdName[udcdmn.pathIdName.count - 1] == "UDCOptionMap.\(docType.idName.components(separatedBy: ".")[1])All" {
        //                            for udcdmnl in udcDocumentMapNodeLanguage {
        //                                udcdmn.childrenId.append(udcdmnl._id)
        //                            }
        //                        }
        //                    }
        //                }
        //            }
        //        }
        
        // Generate document map view
        let uvcDocumentMapViewModel = generateDocumentMapView(getDocumentMapRequest: getDocumentMapRequest, udcDocumentMapNode: &udcDocumentMapNode, language: interfaceLanguage, isOptionAvailable: true)
        
        // Prepare the response
        getDocumentMapResponse.uvcDocumentMapViewModel = uvcDocumentMapViewModel
        getDocumentMapResponse.pathIdName = getDocumentMapRequest.pathIdName
        getDocumentMapResponse.isDynamicMap = getDocumentMapRequest.udcDocumentId != nil
        let jsonUtilityGetDocumentMapResponse = JsonUtility<GetDocumentMapResponse>()
        let jsonGetDocumentMapResponse = jsonUtilityGetDocumentMapResponse.convertAnyObjectToJson(jsonObject: getDocumentMapResponse)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonGetDocumentMapResponse)
    }
    
    
    private func postProcess(neuronRequest: NeuronRequest) {
        print("\(DocumentMapNeuron.getName()): post process")
        
        
        
        if neuronRequest.neuronOperation.asynchronusProcess == true {
            print("\(DocumentMapNeuron.getName()) Asynchronus so storing response in database")
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
        print("\(DocumentMapNeuron.getName()) Informing: \(String(describing: neuronRequest.neuronSource.name))")
        let neuronSource = neuronUtility!.getDendrite(sourceId: neuronRequest.neuronSource._id, neuronName: neuronRequest.neuronSource.name)
        neuronSource!.setDendrite(neuronRequest: neuronResponse, udbcDatabaseOrm: self.udbcDatabaseOrm!, neuronUtility: self.neuronUtility!)
        
        
        
        defer {
            let neuronSource = neuronUtility!.getDendrite(sourceId: neuronRequest.neuronSource._id, neuronName: neuronRequest.neuronSource.name)
            neuronSource!.setDendrite(neuronRequest: neuronResponse, udbcDatabaseOrm: self.udbcDatabaseOrm!, neuronUtility: self.neuronUtility!)
            DocumentMapNeuron.removeDendrite(sourceId: neuronRequest.neuronSource._id)
        }
        
    }
}
