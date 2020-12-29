//
//  OptionMapNeuron.swift
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
import UDocsDocumentModel
import UDocsNeuronModel
import UDocsNeuronUtility
import UDocsViewModel
import UDocsViewUtility
import UDocsOptionMapNeuronModel

public class OptionMapNeuron : Neuron {
    
    public static func getRootResponse(neuronSourceId: String) -> NeuronRequest {
        return NeuronRequest()
    }
    
    var neuronUtility: NeuronUtility? = nil
    var udbcDatabaseOrm: UDBCDatabaseOrm?
    static var dendriteMap: [String : Neuron] = [String : Neuron]()
    private var responseMap: [String : NeuronRequest] = [String : NeuronRequest]()
    static let serialQueue = DispatchQueue(label: "SerialQueue")
    var neuronResponse =  NeuronRequest()
    
    
    static public func getName() -> String {
        return "OptionMapNeuron"
    }
    
    static public func getDescription() -> String {
        return "Option Map Neuron"
    }
    
    static public func getDendrite(sourceId: String) -> (Neuron) {
        var neuron: Neuron?
        
        serialQueue.sync {
            print("Before: \(dendriteMap.debugDescription)")
            neuron = dendriteMap[sourceId]
            if neuron == nil {
                print("\(getName()): Created: \(sourceId)")
                dendriteMap[sourceId] = OptionMapNeuron()
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
        
        do {
            self.udbcDatabaseOrm = udbcDatabaseOrm
            
            self.neuronUtility = neuronUtility
            if neuronRequest.neuronOperation.parent == true {
                print("\(OptionMapNeuron.getName()) Parent show setting child to true")
                neuronResponse.neuronOperation.child = true
            }
            
            var neuronRequestLocal = neuronRequest
            
            
            self.neuronUtility!.setUDBCDatabaseOrm(udbcDatabaseOrm: udbcDatabaseOrm, neuronName: OptionMapNeuron.getName())
            
            
            let continueProcess = try preProcess(neuronRequest: neuronRequestLocal)
            if continueProcess == false {
                print("\(OptionMapNeuron.getName()): don't process return")
                return
            }
            
            validateRequest(neuronRequest: neuronRequest)
            
            if neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError!.count > 0 {
                print("\(OptionMapNeuron.getName()) error in validation return")
                let neuronSource = self.neuronUtility!.getDendrite(sourceId: neuronRequest.neuronSource._id, neuronName: neuronRequest.neuronSource.name)
                neuronSource!.setDendrite(neuronRequest: neuronResponse, udbcDatabaseOrm: self.udbcDatabaseOrm!, neuronUtility: self.neuronUtility!)
                return
            }
            
            
            
            // Controller says no need to
            
            neuronResponse.neuronOperation.acknowledgement = false
            
            if neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError!.count == 0 {
                if neuronRequest.neuronOperation.asynchronus == true {
                    print("\(OptionMapNeuron.getName()) asynchronus store the request and return")
                    neuronResponse.neuronOperation.response = true
                    neuronResponse.neuronOperation.neuronData.text = ""
                    self.neuronUtility!.storeInDatabase(neuronRequest: neuronRequest)
                    return
                } else {
                    if neuronRequest.neuronOperation.synchronus == true {
                        if neuronRequest.neuronOperation.asynchronusProcess == true {
                            print("\(OptionMapNeuron.getName()) asynchronus so update the status as pending")
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
            print("\(OptionMapNeuron.getName()): Error thrown in setdendrite: \(error)")
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
        print("\(OptionMapNeuron.getName()): pre process")
        
        print("neuronUtility: pre process: \(neuronRequest.neuronSource._id)")
        let neuronRequestLocal: NeuronRequest = neuronRequest
        
        if neuronRequestLocal.neuronOperation.acknowledgement == true {
            print("\(OptionMapNeuron.getName()) acknowledgement so return")
            return false
        }
        
        if neuronRequestLocal.neuronOperation.response == true {
            setChildResponse(sourceId: neuronRequestLocal.neuronSource._id, neuronRequest: neuronRequest)
            print("\(OptionMapNeuron.getName()) response so return")
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
            print("\(OptionMapNeuron.getName()) got response so return")
            return false
        }
        
        return true
    }
    
    private func process(neuronRequest: NeuronRequest) throws {
        neuronResponse.neuronOperation.response = true
        if neuronRequest.neuronOperation.name.hasPrefix("OptionMapNeuron.OptionMap.Get") {
            getOptionMap(neuronRequest: neuronRequest)
        }
    }
    
    
    private func getOptionMap(neuronRequest: NeuronRequest) {
       let getOptionMapRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: GetOptionMapRequest())
        
        let interfaceLanguage = getOptionMapRequest.interfaceLanguage
        let getOptionMapResponse = GetOptionMapResponse()
        getOptionMapResponse.name = getOptionMapRequest.name

        let databaseOrmResultUDCOptionMap = UDCOptionMap.get(udbcDatabaseOrm: udbcDatabaseOrm!, name: getOptionMapRequest.name, udcProfile: getOptionMapRequest.udcProfile, language: interfaceLanguage)
        if databaseOrmResultUDCOptionMap.databaseOrmError.count > 0 {
            for databaseError in databaseOrmResultUDCOptionMap.databaseOrmError {
                neuronResponse = neuronUtility!.getNeuronResponseError(neuronRequest: neuronRequest, errorName: databaseError.name, errorDescription:  databaseError.description)
            }
        }
        if databaseOrmResultUDCOptionMap.object.count == 0 {
            let jsonUtilityGetOptionMapResponse = JsonUtility<GetOptionMapResponse>()
            let jsonGetOptionMapResponse = jsonUtilityGetOptionMapResponse.convertAnyObjectToJson(jsonObject: getOptionMapResponse)
            neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonGetOptionMapResponse)
            return
        }
        let udcOptionMap = databaseOrmResultUDCOptionMap.object[0]
        
        var udcOptionMapNode = [UDCOptionMapNode]()
        
        loadOptionMapNode(udcOptionMapNodeId: udcOptionMap.udcOptionMapNodeId, language: interfaceLanguage, udcOptionMapNode: &udcOptionMapNode)
        
        let uvcOptionMapViewModel = generateOptionMapView(language: interfaceLanguage, getOptionMapRequest: getOptionMapRequest, udcOptionMapNode: &udcOptionMapNode)
        
        getOptionMapResponse.uvcOptionMapViewModel = uvcOptionMapViewModel
        let jsonUtilityGetOptionMapResponse = JsonUtility<GetOptionMapResponse>()
        let jsonGetOptionMapResponse = jsonUtilityGetOptionMapResponse.convertAnyObjectToJson(jsonObject: getOptionMapResponse)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonGetOptionMapResponse)
    }
    
    
    private func generateOptionMapView(language: String, getOptionMapRequest: GetOptionMapRequest, udcOptionMapNode: inout [UDCOptionMapNode]) -> UVCOptionMapViewModel {
        let uvcOptionMapViewModel = UVCOptionMapViewModel()
        let uvcViewGenerator = UVCViewGenerator()
        
        for udcomn in udcOptionMapNode {
            let uvcOptionViewModel = UVCOptionViewModel()
            uvcOptionViewModel._id = udcomn._id
            uvcOptionViewModel.idName = udcomn.idName
            for parent in udcomn.parentId {
                uvcOptionViewModel.parentId.append(parent)
            }
            for children in udcomn.childrenId {
                uvcOptionViewModel.childrenId.append(children)
            }
            uvcOptionViewModel.objectName = ""
            uvcOptionViewModel.objectIdName = ""
            uvcOptionViewModel.level = udcomn.level
            var path = udcomn.path
            let stringUtility = StringUtility()
            if language == "en" {
                path = stringUtility.capitalCase(array2d: path)
            }
            uvcOptionViewModel.pathIdName.append(contentsOf: udcomn.pathIdName)
            // This will generate check box button, if any option enabled
            var isCheckBox = getOptionMapRequest.isSingleSelect || getOptionMapRequest.isMultiSelect
            for id in udcomn.parentId {
                for sidname in getOptionMapRequest.enableSingleSelectIdName {
                    if isParentMatches(parentId: id, idName: sidname, udcOptionMapNode: udcOptionMapNode) {
                        uvcOptionViewModel.isSingleSelect = true
                        isCheckBox = true
                        break
                    }
                }
                for sidname in getOptionMapRequest.enableMultiSelectIdName {
                    if isParentMatches(parentId: id, idName: sidname, udcOptionMapNode: udcOptionMapNode) {
                        uvcOptionViewModel.isMultiSelect = true
                        isCheckBox = true
                        break
                    }
                }
                if isCheckBox {
                    break
                }
            }
            if getOptionMapRequest.isSingleSelect || getOptionMapRequest.isMultiSelect {
                uvcOptionViewModel.isMultiSelect = getOptionMapRequest.isMultiSelect
                uvcOptionViewModel.isSingleSelect = getOptionMapRequest.isSingleSelect
            }
            let isChildrenExist = udcomn.childrenId.count > 0 || (udcomn.childrenId.count > 0 && udcomn.childrenId[0] == "dummy")
            if let sp = udcomn.udcSentencePattern {
                uvcOptionViewModel.uvcViewModel = generateSentenceViewAsObject(udcSentencePattern: sp, language: language)
            } else {
                var name = udcomn.name
                if language == "en" {
                    name = name.capitalized
                }
                uvcOptionViewModel.uvcViewModel = uvcViewGenerator.getOptionViewModel(name: name, description: "", category: "", subCategory: "", language: language, isChildrenExist: isChildrenExist, isEditable: false, isCheckBox: isCheckBox, photoId: nil, photoObjectName: nil)
            }
            uvcOptionViewModel.uvcViewModel.rowLength = 1
            uvcOptionMapViewModel.uvcOptionViewModel.append(uvcOptionViewModel)
        }
        
        return uvcOptionMapViewModel
    }
    
    private func generateSentenceViewAsObject(udcSentencePattern: UDCSentencePattern, language: String) -> UVCViewModel {
        
        let uvcViewGenerator = UVCViewGenerator()
        let uvcViewModelReturn = UVCViewModel()
        uvcViewModelReturn.language = language
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
        
        
        for udcSentencePatternData in udcSentencePattern.udcSentencePatternData {
            for (udcSentencePatternDataGroupIndex, udcSentencePatternDataGroup) in udcSentencePatternData.udcSentencePatternDataGroup.enumerated() {
                
                for (udcSentencePatternDataGroupValueIndex, udcSentencePatternDataGroupValue) in udcSentencePatternDataGroup.udcSentencePatternDataGroupValue.enumerated() {
                    
                    let value = udcSentencePatternDataGroupValue.item
                    let name = uvcViewGenerator.generateNameWithUniqueId("Name")
                    
                    let uvcText = uvcViewGenerator.getText(name: name, value: value!, description: "", isEditable: udcSentencePatternDataGroupValue.isEditable)
                    uvcText.uvcTextStyle.textColor = UVCColor.get("UVCColor.Black").name
                    uvcText.uvcTextSize.uvcTextSizeType = UVCTextSizeType.Regular.name
                    uvcText.uvcViewItemType = "UVCViewItemType.Text"
                    uvcText.optionObjectIdName = udcSentencePatternDataGroupValue.itemId
                    uvcText.optionObjectCategoryIdName = udcSentencePatternDataGroupValue.endSubCategoryId
                    if !udcSentencePatternDataGroupValue.itemId.isEmpty {
                        uvcText.optionObjectName = String(udcSentencePatternDataGroupValue.itemId.split(separator: ".")[0])
                    }
                    uvcViewModelReturn.uvcViewItemCollection.uvcText.append(uvcText)
                    uvcViewModelReturn.textLength = uvcText.value.count
                    uvcViewModelReturn.rowLength = 1
                    
                    uvcViewItem = UVCViewItem()
                    uvcViewItem.type = "UVCViewItemType.Text"
                    if language == "en" {
                        uvcViewItem.name = name.capitalized
                    } else {
                        uvcViewItem.name = name
                    }
                    uvcTableColumn.uvcViewItem.append(uvcViewItem)
                    
                    
                }
            }
        }
        
        uvcTableRow.uvcTableColumn.append(uvcTableColumn)
        uvcTable.uvcTableRow.append(uvcTableRow)
        uvcViewModelReturn.uvcViewItemCollection.uvcTable.append(uvcTable)
        
        return uvcViewModelReturn
    }
    
    private func isParentMatches(parentId: String, idName: String, udcOptionMapNode: [UDCOptionMapNode]) -> Bool {
        for udcomn in udcOptionMapNode {
            if udcomn._id == parentId && udcomn.idName == idName {
                return true
            }
        }
        
        return false
    }
   
    private func loadOptionMapNode(udcOptionMapNodeId: [String], language: String, udcOptionMapNode: inout [UDCOptionMapNode]) {
        for udcdmnid in udcOptionMapNodeId {
            var found: Bool = false
            for udcdmn in udcOptionMapNode {
                if udcdmn._id == udcdmnid {
                    found = true
                    break
                }
            }
            if found {
                continue
            }
            
            // Get Document map node
            let databaseOrmResultUDCOptionMapNode = UDCOptionMapNode.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: udcdmnid, language: language)
            if databaseOrmResultUDCOptionMapNode.databaseOrmError.count > 0 {
                // Document map node not found
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCOptionMapNode.databaseOrmError[0].name, description: databaseOrmResultUDCOptionMapNode.databaseOrmError[0].description))
                return
            }
            let udcOptionMapNodeLocal = databaseOrmResultUDCOptionMapNode.object[0]
            udcOptionMapNode.append(udcOptionMapNodeLocal)
            if udcOptionMapNodeLocal.childrenId.count > 0 && udcOptionMapNodeLocal.childrenId[0] == "dummy" {
                continue
            }
            if udcOptionMapNodeLocal.childrenId.count > 0 {
                // Recurse until all childrens are loaded
                loadOptionMapNode(udcOptionMapNodeId: udcOptionMapNodeLocal.childrenId, language: language, udcOptionMapNode: &udcOptionMapNode)
                if neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError!.count > 0 {
                    return
                }
            }
        }
    }
    
    private func postProcess(neuronRequest: NeuronRequest) {
        print("\(OptionMapNeuron.getName()): post process")
        
        if neuronRequest.neuronOperation.asynchronusProcess == true {
            print("\(OptionMapNeuron.getName()) Asynchronus so storing response in database")
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
        print("\(OptionMapNeuron.getName()) Informing: \(String(describing: neuronRequest.neuronSource.name))")
        let neuronSource = neuronUtility!.getDendrite(sourceId: neuronRequest.neuronSource._id, neuronName: neuronRequest.neuronSource.name)
        neuronSource!.setDendrite(neuronRequest: neuronResponse, udbcDatabaseOrm: self.udbcDatabaseOrm!, neuronUtility: self.neuronUtility!)
        
        
        
        defer {
            let neuronSource = neuronUtility!.getDendrite(sourceId: neuronRequest.neuronSource._id, neuronName: neuronRequest.neuronSource.name)
            neuronSource!.setDendrite(neuronRequest: neuronResponse, udbcDatabaseOrm: self.udbcDatabaseOrm!, neuronUtility: self.neuronUtility!)
            OptionMapNeuron.removeDendrite(sourceId: neuronRequest.neuronSource._id)
        }
        
    }
}
