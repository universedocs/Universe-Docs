//
//  NeuronUtilityImplementation.swift
//  UDocsBrain
//
//  Created by Kumar Muthaiah on 07/06/20.
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
import UDocsDatabaseModel
import UDocsUtility
import UDocsNeuronModel
import UDocsNeuronUtility
import UDocsPhotoNeuron
import UDocsDocumentItemNeuron
import UDocsDocumentGraphNeuron
import UDocsOptionMapNeuron
import UDocsDocumentMapNeuron
import UDocsSecurityNeuron
import UDocsGrammarNeuron
import UDocsDocumentItemConfigurationNeuron

open class NeuronUtilityImplementationBase : NeuronUtility {
    public var neuronName: String = ""
    public var udbcDatabaseOrm: UDBCDatabaseOrm? = nil
    
    public init() {
        
    }
    
    open func getDendrite(sourceId: String, neuronName: String) -> Neuron? {
        var neuron: Neuron?
        if neuronName == BrainControllerNeuron.getName() {
            neuron = BrainControllerNeuron.getDendrite(sourceId: sourceId)
        } /*else if neuronName == PhotoNeuron.getName() {
            neuron = PhotoNeuron.getDendrite(sourceId: sourceId)
        } else if neuronName == DocumentItemNeuron.getName() {
            neuron = DocumentItemNeuron.getDendrite(sourceId: sourceId)
        } else if neuronName == DocumentGraphNeuron.getName() {
            neuron = DocumentGraphNeuron.getDendrite(sourceId: sourceId)
        }*/ else if neuronName == BrainControllerApplication.getName() {
            neuron = BrainControllerApplication.getDendrite(sourceId: sourceId)
        }/* else if neuronName == DocumentMapNeuron.getName() {
            neuron = DocumentMapNeuron.getDendrite(sourceId: sourceId)
        } else if neuronName == SecurityNeuron.getName() {
            neuron = SecurityNeuron.getDendrite(sourceId: sourceId)
        } else if neuronName == GrammarNeuron.getName() {
            neuron = GrammarNeuron.getDendrite(sourceId: sourceId)
        } else if neuronName == UniversalBrainControllerTest.getName() {
            neuron = UniversalBrainControllerTest.getDendrite(sourceId: sourceId)
        } else if neuronName == OptionMapNeuron.getName() {
            neuron = OptionMapNeuron.getDendrite(sourceId: sourceId)
        } else if neuronName == DocumentItemConfigurationNeuron.getName() {
            neuron = DocumentItemConfigurationNeuron.getDendrite(sourceId: sourceId)
        } else if neuronName == HumanProfileNeuron.getName() {
            neuron = HumanProfileNeuron.getDendrite(sourceId: sourceId)
        }*/
        
        return neuron
    }
    
    open func callNeuron(neuronRequest: NeuronRequest) -> Bool {
        var called = false
        /*if neuronRequest.neuronTarget.name == PhotoNeuron.getName() {
            let neuron = PhotoNeuron.getDendrite(sourceId: neuronRequest.neuronSource._id)
            neuron.setDendrite(neuronRequest: neuronRequest, udbcDatabaseOrm: udbcDatabaseOrm!,  neuronUtility: self)
            called = true
        } else if neuronRequest.neuronTarget.name == DocumentItemNeuron.getName() {
            let neuron = DocumentItemNeuron.getDendrite(sourceId: neuronRequest.neuronSource._id)
            neuron.setDendrite(neuronRequest: neuronRequest, udbcDatabaseOrm: udbcDatabaseOrm!,  neuronUtility: self)
            called = true
        } else if neuronRequest.neuronTarget.name == DocumentGraphNeuron.getName() {
            let neuron = DocumentGraphNeuron.getDendrite(sourceId: neuronRequest.neuronSource._id)
            neuron.setDendrite(neuronRequest: neuronRequest, udbcDatabaseOrm: udbcDatabaseOrm!,  neuronUtility: self)
            called = true
        } else if neuronRequest.neuronTarget.name == SecurityNeuron.getName() {
            let neuron = SecurityNeuron.getDendrite(sourceId: neuronRequest.neuronSource._id)
            neuron.setDendrite(neuronRequest: neuronRequest, udbcDatabaseOrm: udbcDatabaseOrm!,  neuronUtility: self)
            called = true
        } else */ if neuronRequest.neuronTarget.name == BrainControllerNeuron.getName() {
            let neuron = BrainControllerNeuron.getDendrite(sourceId: neuronRequest.neuronSource._id)
            neuron.setDendrite(neuronRequest: neuronRequest, udbcDatabaseOrm: udbcDatabaseOrm!,  neuronUtility: self)
            called = true
        } /*else if neuronRequest.neuronTarget.name == DocumentMapNeuron.getName() {
            let neuron = DocumentMapNeuron.getDendrite(sourceId: neuronRequest.neuronSource._id)
            neuron.setDendrite(neuronRequest: neuronRequest, udbcDatabaseOrm: udbcDatabaseOrm!,  neuronUtility: self)
            called = true
        } else if neuronRequest.neuronTarget.name == GrammarNeuron.getName() {
            let neuron = GrammarNeuron.getDendrite(sourceId: neuronRequest.neuronSource._id)
            neuron.setDendrite(neuronRequest: neuronRequest, udbcDatabaseOrm: udbcDatabaseOrm!,  neuronUtility: self)
            called = true
        } else if neuronRequest.neuronTarget.name == OptionMapNeuron.getName() {
            let neuron = OptionMapNeuron.getDendrite(sourceId: neuronRequest.neuronSource._id)
            neuron.setDendrite(neuronRequest: neuronRequest, udbcDatabaseOrm: udbcDatabaseOrm!,  neuronUtility: self)
            called = true
        } else if neuronRequest.neuronTarget.name == DocumentItemConfigurationNeuron.getName() {
            let neuron = DocumentItemConfigurationNeuron.getDendrite(sourceId: neuronRequest.neuronSource._id)
            neuron.setDendrite(neuronRequest: neuronRequest, udbcDatabaseOrm: udbcDatabaseOrm!,  neuronUtility: self)
            called = true
        } else if neuronRequest.neuronTarget.name == HumanProfileNeuron.getName() {
            let neuron = HumanProfileNeuron.getDendrite(sourceId: neuronRequest.neuronSource._id)
            neuron.setDendrite(neuronRequest: neuronRequest, udbcDatabaseOrm: udbcDatabaseOrm!,  neuronUtility: self)
            called = true
        }*/
        
        return called
    }
    
    open func getNeuronName(udcDocumentTypeIdName: String) -> String? {
        /*if udcDocumentTypeIdName == "UDCDocumentType.PhotoDocument" {
            return PhotoNeuron.getName()
        } else if udcDocumentTypeIdName == "UDCDocumentType.DocumentItem" {
            return DocumentItemNeuron.getName()
        } else if udcDocumentTypeIdName == "UDCDocumentType.DocumentItemConfiguration" {
            return DocumentItemConfigurationNeuron.getName()
        } else if udcDocumentTypeIdName == "UDCDocumentType.HumanProfile" {
            return HumanProfileNeuron.getName()
        }*/
        
        return nil
    }
    
    public func getCollectionName(udcDocumentTypeIdName: String) -> String? {
        return "UDC\(udcDocumentTypeIdName.components(separatedBy: ".")[1])"
    }
    
    public func getDocumentType(collectionName: String) -> String? {
        return "UDCDocumentType.\(collectionName.components(separatedBy: "UDC")[1])"
    }
    
    open func callNeuron(neuronRequest: NeuronRequest, udcDocumentTypeIdName: String) -> Bool {
        var called = false
        /*if udcDocumentTypeIdName == "UDCDocumentType.PhotoDocument" {
            let neuron = PhotoNeuron.getDendrite(sourceId: neuronRequest.neuronSource._id)
            neuron.setDendrite(neuronRequest: neuronRequest, udbcDatabaseOrm: udbcDatabaseOrm!,  neuronUtility: self)
            called = true
        } else if udcDocumentTypeIdName == "UDCDocumentType.DocumentItem" {
            let neuron = DocumentItemNeuron.getDendrite(sourceId: neuronRequest.neuronSource._id)
            neuron.setDendrite(neuronRequest: neuronRequest, udbcDatabaseOrm: udbcDatabaseOrm!,  neuronUtility: self)
            called = true
        } else if udcDocumentTypeIdName == "UDCDocumentType.DocumentItemConfiguration" {
            let neuron = DocumentItemConfigurationNeuron.getDendrite(sourceId: neuronRequest.neuronSource._id)
            neuron.setDendrite(neuronRequest: neuronRequest, udbcDatabaseOrm: udbcDatabaseOrm!,  neuronUtility: self)
            called = true
        } else if udcDocumentTypeIdName == "UDCDocumentType.HumanProfile" {
            let neuron = HumanProfileNeuron.getDendrite(sourceId: neuronRequest.neuronSource._id)
            neuron.setDendrite(neuronRequest: neuronRequest, udbcDatabaseOrm: udbcDatabaseOrm!,  neuronUtility: self)
            called = true
        }*/
        
        return called
    }
    
    public func setUDBCDatabaseOrm(udbcDatabaseOrm: UDBCDatabaseOrm, neuronName: String) {
        self.udbcDatabaseOrm = udbcDatabaseOrm
    }
    
    public func setUNCMain( neuronName: String) {
        
    }
    
    public func getNeuronOperationSuccess(name: String, description: String) -> NeuronOperationSuccess {
        let neuronOperationSuccess = NeuronOperationSuccess()
        neuronOperationSuccess.name = name
        neuronOperationSuccess.description = description
        return neuronOperationSuccess
    }
    
    public func getNeuronOperationError(name: String, description: String) -> NeuronOperationError {
        let neuronOperationError = NeuronOperationError()
        neuronOperationError.name = name
        neuronOperationError.description = description
        return neuronOperationError
    }
    
    
    public func getNeuronResponse<T : Codable>(object: T) -> String {
        let jsonUtilityResp = JsonUtility<T>()
        return jsonUtilityResp.convertAnyObjectToJson(jsonObject: object)
    }
    
    public func getNeuronRequest<T : Codable>(json: String, object: T) -> T {
        let jsonUtilityResp = JsonUtility<T>()
        return jsonUtilityResp.convertJsonToAnyObject(json: json)
    }
    
    public func getNeuronAcknowledgement(neuronRequest: NeuronRequest) -> NeuronRequest {
        let neuronResponse = NeuronRequest()
        if neuronRequest.neuronOperation.parent == true {
            neuronResponse.neuronOperation.child = true
        }
        neuronResponse.neuronOperation.response = false
        neuronResponse.neuronOperation.name = neuronRequest.neuronOperation.name
        neuronResponse.neuronOperation.acknowledgement = true
        neuronResponse.neuronSource._id = neuronRequest.neuronSource._id
        neuronResponse.neuronSource.name = neuronRequest.neuronSource.name
        neuronResponse.neuronOperation.name = neuronRequest.neuronOperation.name
        neuronResponse.neuronTarget.name = neuronName
        
        
        return neuronResponse
    }
    
    
    public func getNeuronResponseSuccess(neuronRequest: NeuronRequest, responseText: String) -> NeuronRequest {
        let neuronResponse = NeuronRequest()
        if neuronRequest.neuronOperation.parent == true {
            neuronResponse.neuronOperation.child = true
        }
        neuronResponse.neuronOperation.response = true
        neuronResponse.neuronOperation.name = neuronRequest.neuronOperation.name
        neuronResponse.neuronOperation.acknowledgement = false
        neuronResponse.neuronSource._id = neuronRequest.neuronSource._id
        neuronResponse.neuronSource.name = neuronRequest.neuronSource.name
        neuronResponse.neuronOperation.name = neuronRequest.neuronOperation.name
        neuronResponse.neuronOperation.neuronData.text = responseText
        neuronResponse.neuronTarget.name = neuronName
        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationSuccess?.append(getNeuronOperationSuccess(name: NeuronOperationStatusType.Success.name, description: NeuronOperationStatusType.Success.description))
        
        return neuronResponse
    }
    
    public func getNeuronResponseSuccess(neuronRequest: NeuronRequest, responseText: String, binaryData: Data) -> NeuronRequest {
        let neuronResponse = NeuronRequest()
        if neuronRequest.neuronOperation.parent == true {
            neuronResponse.neuronOperation.child = true
        }
        neuronResponse.neuronOperation.response = true
        neuronResponse.neuronOperation.name = neuronRequest.neuronOperation.name
        neuronResponse.neuronOperation.acknowledgement = false
        neuronResponse.neuronSource._id = neuronRequest.neuronSource._id
        neuronResponse.neuronSource.name = neuronRequest.neuronSource.name
        neuronResponse.neuronOperation.name = neuronRequest.neuronOperation.name
        neuronResponse.neuronOperation.neuronData.text = responseText
        neuronResponse.neuronOperation.neuronData.binaryData = binaryData
        neuronResponse.neuronTarget.name = neuronName
        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationSuccess?.append(getNeuronOperationSuccess(name: NeuronOperationStatusType.Success.name, description: NeuronOperationStatusType.Success.description))
        
        return neuronResponse
    }
    
    public func getNeuronResponseError(neuronRequest: NeuronRequest, errorName: String, errorDescription: String) -> NeuronRequest {
        let neuronResponse = NeuronRequest()
        if neuronRequest.neuronOperation.parent == true {
            neuronResponse.neuronOperation.child = true
        }
        neuronResponse.neuronOperation.response = true
        neuronResponse.neuronOperation.name = neuronRequest.neuronOperation.name
        neuronResponse.neuronOperation.acknowledgement = false
        neuronResponse.neuronSource._id = neuronRequest.neuronSource._id
        neuronResponse.neuronSource.name = neuronRequest.neuronSource.name
        neuronResponse.neuronOperation.name = neuronRequest.neuronOperation.name
        neuronResponse.neuronTarget.name = neuronName
        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(getNeuronOperationError(name: errorName, description: errorDescription))
        
        return neuronResponse
    }
    
    public func getNeuronResponseNone(neuronRequest: NeuronRequest) -> NeuronRequest {
        let neuronResponse = NeuronRequest()
        if neuronRequest.neuronOperation.parent == true {
            neuronRequest.neuronOperation.child = true
        }
        neuronResponse.neuronOperation.response = true
        neuronResponse.neuronOperation.name = neuronRequest.neuronOperation.name
        neuronResponse.neuronOperation.acknowledgement = false
        neuronResponse.neuronSource._id = neuronRequest.neuronSource._id
        neuronResponse.neuronSource.name = neuronRequest.neuronSource.name
        neuronResponse.neuronOperation.name = neuronRequest.neuronOperation.name
        neuronResponse.neuronTarget.name = neuronName
        
        return neuronResponse
    }
    
    public func validateRequest(neuronRequest: NeuronRequest) -> NeuronRequest {
        let neuronResponse = getNeuronResponseNone(neuronRequest: neuronRequest)
        
        if neuronRequest.neuronSource.name.isEmpty {
            neuronResponse.neuronOperation.response = true
            let neuronOperationError = NeuronOperationError()
            neuronOperationError.name = NeuronOperationErrorType.SourceNameRequired.name
            neuronOperationError.description = NeuronOperationErrorType.SourceNameRequired.description;            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronOperationError)
            return neuronResponse
        }
        if neuronRequest.neuronOperation.name.isEmpty {
            neuronResponse.neuronOperation.response = true
            let neuronOperationError = NeuronOperationError()
            neuronOperationError.name = NeuronOperationErrorType.OperationNameRequired.name
            neuronOperationError.description = NeuronOperationErrorType.OperationNameRequired.description
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronOperationError)
            return neuronResponse
        }
        
        return neuronResponse
    }
    
    public func isNeuronOperationError(neuronResponse: NeuronRequest) -> Bool {
        if (neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.count)! > 0 {
            return true
        }
        
        return false
    }
    
    
    public func isNeuronOperationSuccess(neuronResponse: NeuronRequest) -> Bool {
        if (neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationSuccess?.count)! > 0 {
            return true
        }
        
        return false
    }
    
    
    
    public func isNeuronOperationWarning(neuronResponse: NeuronRequest) -> Bool {
        if (neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationWarning?.count)! > 0 {
            return true
        }
        
        return false
    }
    
    public func storeInDatabase(neuronRequest: NeuronRequest) -> DatabaseOrmResult<NeuronRequest> {
        print("NeuronController: store in database")
        
        if neuronRequest.neuronOperation.asynchronusProcess != true &&
            neuronRequest.neuronOperation.asynchronus == false {
            neuronRequest.neuronOperation.neuronData.text = ""
        }
        return NeuronRequest.save(udbcDatabaseOrm: udbcDatabaseOrm!, object: neuronRequest)
        
    }
    
    public func getFromDatabase(neuronRequest: NeuronRequest) -> DatabaseOrmResult<NeuronRequest> {
        print("NeuronController: get from database")
        
        return NeuronRequest.get(udbcDatabaseOrm: udbcDatabaseOrm!, targetName: neuronRequest.neuronTarget.name, operationId: neuronRequest.neuronOperation._id);
    }
    
    public func getOperationsFromDatabase(neuronRequest: NeuronRequest) -> DatabaseOrmResult<NeuronRequest> {
        print("NeuronController: get operations from database")
        
        let query: [String: Any] =  ["$and":
            [
                ["neuronOperation.neuronOperationStatus.status": ["$eq": NeuronOperationStatusType.Pending.name]],
                ["neuronOperation.neuronSchedule.scheduleTime": ["$lte": Date()]]
            ]]
        return NeuronRequest.get(udbcDatabaseOrm: udbcDatabaseOrm!, query: query, limitedTo: 1)
    }
    
    public func getNeuronOperationsFromDatabase(neuronRequest: NeuronRequest, neuronName: String) -> DatabaseOrmResult<NeuronRequest> {
        print("NeuronController: get operations from database")
        let query: [String: Any] =  ["$and":
            [
                ["neuronOperation.name": ["$eq": neuronName]],
                ["neuronOperation.neuronOperationStatus.status": ["$eq": NeuronOperationStatusType.Pending.name]],
                ["neuronOperation.neuronSchedule.scheduleTime": ["$lte": Date()]]
            ]]
        return NeuronRequest.get(udbcDatabaseOrm: udbcDatabaseOrm!, query: query, limitedTo: 1)
        
    }
    

}
