//
//  NeuronTestController.swift
//  BSON
//
//  Created by Kumar Muthaiah on 18/10/18.
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
import UDocsDatabaseUtility
import UDocsNeuronModel
import UDocsNeuronUtility


public class UniversalBrainControllerTest : Neuron {
//    private var neuronUtility = NeuronUtility()
    static var dendriteMap: [String : Neuron] = [String : Neuron]()
    private var responseMap: [String : NeuronRequest] = [String : NeuronRequest]()
    static var rootResponseMap: [String : NeuronRequest] = [String : NeuronRequest]()
    static let serialQueue = DispatchQueue(label: "SerialQueue")
    static let serialQueue1 = DispatchQueue(label: "SerialQueue1")
    
    public init() {
        
    }
    
    public func databaseTest() {
//        DatabaseOrmConnection.host = "localhost"
//        DatabaseOrmConnection.port = 27017
//        //DatabaseOrmConnection.database = "UniverseDocs"
//        DatabaseOrmConnection.database = "UniversalController"
//        let databaseOrm = DatabaseOrm()
//        databaseOrm.connect()
//        databaseOrm.disconnect()
    }

    public func start(sourceId: String) throws {
//        let databaseOrm = DatabaseOrm()
//        let databaesOrmResult = databaseOrm.connect()
//
//        let udbcDatabaseOrm = UDBCDatabaseOrm()
//        udbcDatabaseOrm.ormObject = databaseOrm
//        udbcDatabaseOrm.type = UDBCDatabaseType.MongoDatabase.rawValue
//
//        let udcDocumentGraphModel = UDCDocumentGraphModel()
//        udcDocumentGraphModel.idName = "UDCDocumentGraphModel.Test"
//        let databaseOrmUDCDocumentGraphModel = databaseOrm.save(collectionName: "UDCTest", object: udcDocumentGraphModel)
//        if databaseOrmUDCDocumentGraphModel.databaseOrmError.count > 0 {
//            print(databaseOrmUDCDocumentGraphModel.databaseOrmError[0].name)
//            print(databaseOrmUDCDocumentGraphModel.databaseOrmError[0].description)
//        }
//        neuronUtility!.setUDBCDatabaseOrm(udbcDatabaseOrm: udbcDatabaseOrm, neuronName: "GrammarNeuron")
//        var neuronResponse = NeuronRequest()
//        let udcSentencePatternRequest = UDCSentencePatternRequest()
//        // 1
//        var udcSentencePatternDataRequest = UDCSentencePatternDataRequest()
//        udcSentencePatternDataRequest.orderNumber = 1
//        var udcSentencePatternDataGroupRequest = UDCSentencePatternDataGroupRequest()
//        var udcSentencePatternDataGroupValueRequest = UDCSentencePatternDataGroupValueRequest()
//        udcSentencePatternDataGroupValueRequest.value = "1"
//        udcSentencePatternDataGroupRequest.udcSentencePatternDataGroupValueRequest.append(udcSentencePatternDataGroupValueRequest)
//        udcSentencePatternDataGroupValueRequest = UDCSentencePatternDataGroupValueRequest()
//        udcSentencePatternDataGroupValueRequest.value = "cup"
//        udcSentencePatternDataGroupRequest.udcSentencePatternDataGroupValueRequest.append(udcSentencePatternDataGroupValueRequest)
//        udcSentencePatternDataRequest.udcSentencePatternDataGroupRequest.append(udcSentencePatternDataGroupRequest)
//        // 1.1 
//        udcSentencePatternDataGroupRequest = UDCSentencePatternDataGroupRequest()
//        udcSentencePatternDataGroupValueRequest = UDCSentencePatternDataGroupValueRequest()
//        udcSentencePatternDataGroupValueRequest.value = "1"
//        udcSentencePatternDataGroupRequest.udcSentencePatternDataGroupValueRequest.append(udcSentencePatternDataGroupValueRequest)
//        udcSentencePatternDataGroupValueRequest = UDCSentencePatternDataGroupValueRequest()
//        udcSentencePatternDataGroupValueRequest.value = "deci liter"
//        udcSentencePatternDataGroupRequest.udcSentencePatternDataGroupValueRequest.append(udcSentencePatternDataGroupValueRequest)
//        udcSentencePatternDataRequest.udcSentencePatternDataGroupRequest.append(udcSentencePatternDataGroupRequest)
//        udcSentencePatternRequest.udcSentencePatternDataRequest.append(udcSentencePatternDataRequest)
//        
//        // 2.1
//        udcSentencePatternDataRequest = UDCSentencePatternDataRequest()
//        udcSentencePatternDataRequest.orderNumber = 2
//        udcSentencePatternDataGroupRequest = UDCSentencePatternDataGroupRequest()
//        udcSentencePatternDataGroupValueRequest = UDCSentencePatternDataGroupValueRequest()
//        udcSentencePatternDataGroupValueRequest.value = "fresh"
//        udcSentencePatternDataGroupRequest.udcSentencePatternDataGroupValueRequest.append(udcSentencePatternDataGroupValueRequest)
//        udcSentencePatternDataRequest.udcSentencePatternDataGroupRequest.append(udcSentencePatternDataGroupRequest)
//        // 2.2
//        udcSentencePatternDataGroupRequest = UDCSentencePatternDataGroupRequest()
//        udcSentencePatternDataGroupValueRequest = UDCSentencePatternDataGroupValueRequest()
//        udcSentencePatternDataGroupValueRequest.value = "frozen"
//        udcSentencePatternDataGroupRequest.udcSentencePatternDataGroupValueRequest.append(udcSentencePatternDataGroupValueRequest)
//        udcSentencePatternDataRequest.udcSentencePatternDataGroupRequest.append(udcSentencePatternDataGroupRequest)
//        udcSentencePatternRequest.udcSentencePatternDataRequest.append(udcSentencePatternDataRequest)
//        // 3
//        udcSentencePatternDataRequest = UDCSentencePatternDataRequest()
//        udcSentencePatternDataRequest.orderNumber = 3
//        udcSentencePatternDataGroupRequest = UDCSentencePatternDataGroupRequest()
//        udcSentencePatternDataGroupValueRequest = UDCSentencePatternDataGroupValueRequest()
//        udcSentencePatternDataGroupValueRequest.value = "blueberrie"
//        udcSentencePatternDataGroupRequest.udcSentencePatternDataGroupValueRequest.append(udcSentencePatternDataGroupValueRequest)
//        udcSentencePatternDataRequest.udcSentencePatternDataGroupRequest.append(udcSentencePatternDataGroupRequest)
//        udcSentencePatternRequest.udcSentencePatternDataRequest.append(udcSentencePatternDataRequest)
//        
//        let jsonUtility = JsonUtility<SentenceRequest>()
//        let sentenceRequest = SentenceRequest()
//        sentenceRequest.udcSentencePatternRequest = udcSentencePatternRequest
//        // 5c173ddf74b318f9852952ed - item state
//        // 5c173ddf74b318f9872952ed - no item state
//        sentenceRequest.udcSentencePatternRequest.udcSentenceGrammarPatternId = "5c173ddf74b318f9852952ed"
//        sentenceRequest.udcSentencePatternRequest.language = "en"
//        
//        let text = jsonUtility.convertAnyObjectToJson(jsonObject: sentenceRequest)
//        try callNeuron(sourceId: sourceId, neuronName: "GrammarNeuron", text: text, operationName: "GrammarNeuron.Sentence.Generate", neuronResponse: &neuronResponse, udbcDatabaseOrm: udbcDatabaseOrm)
//        print(neuronResponse.neuronOperation.neuronData.text)
//        defer {
//            let _ = databaseOrm.disconnect()
//        }
    
    }

    private func callNeuron(sourceId: String, neuronName: String, text: String, operationName: String, neuronResponse: inout NeuronRequest, udbcDatabaseOrm: UDBCDatabaseOrm) throws {
//        let neuronRequestLocal = NeuronRequest()
//        neuronRequestLocal.neuronSource._id = sourceId
//        neuronRequestLocal.neuronOperation.synchronus = true
//        neuronRequestLocal.neuronOperation._id = try udbcDatabaseOrm.generateId()
//        neuronRequestLocal.neuronSource.name = "UniversalBrainControllerTest"
//        neuronRequestLocal.neuronSource.type = "UniversalBrainControllerTest"
//        neuronRequestLocal.neuronOperation.name = operationName
//        neuronRequestLocal.neuronOperation.parent = true
//        neuronRequestLocal.neuronOperation.neuronData.text = text
//        neuronRequestLocal.neuronTarget.name =  neuronName
//
//        neuronUtility!.callNeuron(neuronRequest: neuronRequestLocal)
//
//        let neuronResponseLocal = getChildResponse(operationName: neuronRequestLocal.neuronOperation.name)
//
//        if neuronResponseLocal.neuronOperation.neuronOperationStatus.neuronOperationError!.count > 0 {
//            print("\(DocumentGraphNeuron.getName()) Errors from child neuron: \(neuronRequestLocal.neuronOperation.name))")
//            neuronResponse.neuronOperation.response = true
//            for noe in neuronResponseLocal.neuronOperation.neuronOperationStatus.neuronOperationError! {
//                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(noe)
//            }
//        } else {
//            for noe in neuronResponseLocal.neuronOperation.neuronOperationStatus.neuronOperationSuccess! {
//                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationSuccess?.append(noe)
//            }
//            print("\(DocumentGraphNeuron.getName()) Success from child neuron: \(neuronRequestLocal.neuronOperation.name))")
//            neuronResponse.neuronOperation.neuronData.text = neuronResponseLocal.neuronOperation.neuronData.text
//
//        }
    }
    static public func getDescription() -> String {
        return "UniversalBrainControllerTest"
    }

    static public func getDendrite(sourceId: String) -> (Neuron) {
        var neuron: Neuron?
        
        serialQueue.sync {
            print("Before: \(dendriteMap.debugDescription)")
            neuron = dendriteMap[sourceId]
            if neuron == nil {
                print("\(getName()): Created: \(sourceId)")
                dendriteMap[sourceId] = UniversalBrainControllerTest()
                neuron = dendriteMap[sourceId]
            }
            print("After creation: \(dendriteMap.debugDescription)")
        }
        
        return  neuron!;
    }

    private func setChildResponse(operationName: String, neuronRequest: NeuronRequest) {
        responseMap[operationName] = neuronRequest
    }

    private func getChildResponse(operationName: String) -> NeuronRequest {
        var neuronResponse: NeuronRequest?
        print(responseMap)
        if let _ = responseMap[operationName] {
            neuronResponse = responseMap[operationName]
            responseMap.removeValue(forKey: operationName)
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


    public func setDendrite(neuronRequest: NeuronRequest,  udbcDatabaseOrm: UDBCDatabaseOrm,  neuronUtility: NeuronUtility) {
        
        if neuronRequest.neuronOperation.acknowledgement == true {
            print("\(UniversalBrainControllerTest.getName()): Got Acknowledgement")
            return
        }
        if neuronRequest.neuronOperation.response  == true {
            print("\(UniversalBrainControllerTest.getName()): Got Response")
            let neuronResponseLocal = neuronRequest
            setChildResponse(operationName: neuronRequest.neuronOperation.name, neuronRequest: neuronResponseLocal)
            UniversalBrainControllerTest.removeDendrite(sourceId: neuronRequest.neuronSource._id)
            print("Brain controller application Neuron  Dendrite MAP: \(UniversalBrainControllerTest.dendriteMap)")
        }
        
    }

    static public func getName() -> String {
        return "UniversalBrainControllerTest"
    }

    public static func getRootResponse(neuronSourceId: String) -> NeuronRequest {
        var neuronResponse: NeuronRequest?
        serialQueue1.sync {
            
            if let _ = rootResponseMap[neuronSourceId] {
                neuronResponse = rootResponseMap[neuronSourceId]
                rootResponseMap.removeValue(forKey: neuronSourceId)
                print("Root response map: \(rootResponseMap)")
            }
        }
        if neuronResponse == nil {
            neuronResponse = NeuronRequest()
        }
        
        return neuronResponse!
    }

    private static func setRootResponse(neuronSourceId: String, request: NeuronRequest) {
        serialQueue1.sync {
            print("\(BrainControllerNeuron.getName()) setting child response")
            rootResponseMap[neuronSourceId] = request
        }
    }

 
}
