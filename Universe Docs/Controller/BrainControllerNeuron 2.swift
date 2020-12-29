//
//  BrainControllerNeuron.swift
//  UniversalBrainController
//
//  Created by Kumar Muthaiah on 25/10/18.
//

import Foundation


import Alamofire

open class BrainControllerNeuron : Neuron {
    let neuronUtility = NeuronUtility()
    var udbcDatabaseOrm: UDBCDatabaseOrm?
    static var dendriteMap: [String : Neuron] = [String : Neuron]()
    static var responseMap: [String : NeuronRequest] = [String : NeuronRequest]()
    static let serialQueue = DispatchQueue(label: "SerialQueue")
    var neuronResponse =  NeuronRequest()
    
    private init() {
        
    }
    
    static public func getName() -> String {
        return "BrainControllerNeuron"
    }
    
    static public func getDescription() -> String {
        return "Brain Controller Neuron"
    }
    
    static public func getDendrite(sourceId: String) -> (Neuron) {
        var neuron: Neuron?
        
        serialQueue.sync {
            print("Before: \(dendriteMap.debugDescription)")
            neuron = dendriteMap[sourceId]
            if neuron == nil {
                print("\(getName()): Created: \(sourceId)")
                dendriteMap[sourceId] = BrainControllerNeuron()
                neuron = dendriteMap[sourceId]
            }
            print("After creation: \(dendriteMap.debugDescription)")
        }
        
        return  neuron!;
    }
    
    
    
    private static func setChildResponse(sourceId: String, neuronRequest: NeuronRequest) {
        serialQueue.sync {
            responseMap[sourceId] = neuronRequest
        }
    }
    
    private static func getChildResponse(sourceId: String) -> NeuronRequest {
        var neuronResponse: NeuronRequest?
        serialQueue.sync {
            print(responseMap)
            if let _ = responseMap[sourceId] {
                neuronResponse = responseMap[sourceId]
                responseMap.removeValue(forKey: sourceId)
            }
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
    
    
    public func setDendrite(neuronRequest: NeuronRequest, udbcDatabaseOrm: UDBCDatabaseOrm) {
        self.udbcDatabaseOrm = udbcDatabaseOrm
        
        neuronResponse.neuronSource._id = neuronRequest.neuronSource._id
        neuronResponse.neuronOperation._id = neuronRequest.neuronOperation._id
        
        
        var neuronRequestLocal = neuronRequest
        do {
            neuronUtility.setUDBCDatabaseOrm(udbcDatabaseOrm: udbcDatabaseOrm, neuronName: BrainControllerNeuron.getName())
            
            
            let continueProcess = try preProcess(neuronRequest: neuronRequestLocal)
            if continueProcess == false {
                print("\(BrainControllerNeuron.getName()): don't process return")
                return
            }
            validateRequest(neuronRequest: neuronRequest)
            
            if neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError!.count > 0 {
                print("\(BrainControllerNeuron.getName()) error in validation return")
                let neuronSource = NeuronUtility.getDendrite(sourceId: neuronRequest.neuronSource._id, neuronName: neuronRequest.neuronSource.name)
                neuronSource.setDendrite(neuronRequest: neuronResponse, udbcDatabaseOrm: udbcDatabaseOrm)
                return
            }
            
            
            
            // Controller says no need to
            
            neuronResponse.neuronOperation.acknowledgement = false
            
            if neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError!.count == 0 {
                if neuronRequest.neuronOperation.asynchronus == true {
                    print("\(BrainControllerNeuron.getName()) asynchronus store the request and return")
                    neuronResponse.neuronOperation.response = true
                    neuronResponse.neuronOperation.neuronData.text = ""
                    neuronRequest.neuronOperation.neuronOperationStatus.status = NeuronOperationStatusType.Pending.name
                    neuronRequest._id = try udbcDatabaseOrm.generateId()
//                    neuronUtility.storeInDatabase(neuronRequest: neuronRequest)
                    return
                } else {
                    if neuronRequest.neuronOperation.synchronus == true {
//                        if neuronRequest.neuronOperation.asynchronusProcess == true {
//                            print("\(BrainControllerNeuron.getName()) asynchronus so update the status as pending")
//                            let rows = try NeuronRequest.update(udbcDatabaseOrm: udbcDatabaseOrm, id: (neuronRequest._id), status: NeuronOperationStatusType.InProgress.name)
//                        }
                        neuronResponse.neuronOperation.acknowledgement = true
                        neuronResponse.neuronOperation.neuronData.text = ""
                        let neuronSource = NeuronUtility.getDendrite(sourceId: neuronRequest.neuronSource._id, neuronName: neuronRequest.neuronSource.name)
                        neuronSource.setDendrite(neuronRequest: neuronResponse, udbcDatabaseOrm: udbcDatabaseOrm)
                        neuronResponse.neuronOperation.acknowledgement = false
                        try process(neuronRequest: neuronRequestLocal)
                    }
                }
                
            }
            
            
            
        } catch {
            print("\(BrainControllerNeuron.getName()): Error thrown in setdendrite: \(error)")
            neuronResponse.neuronOperation.response = true
            let neuronOperationError = NeuronOperationError()
            neuronOperationError.name = NeuronOperationErrorType.ErrorInProcessing.name
            neuronOperationError.description = error.localizedDescription
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronOperationError)
        }
        
        defer {
            postProcess(neuronRequest: neuronRequest)
        }
    }
    
    private func validateRequest(neuronRequest: NeuronRequest) {
        neuronResponse = neuronUtility.validateRequest(neuronRequest: neuronRequest)
        if neuronUtility.isNeuronOperationError(neuronResponse: neuronResponse) {
            return
        }
        
        
        
    }
    
    private func preProcess(neuronRequest: NeuronRequest) throws -> Bool {
        print("\(BrainControllerNeuron.getName()): pre process")
        neuronResponse.neuronSource._id = neuronRequest.neuronSource._id
        
        print("neuronUtility: pre process: \(neuronRequest.neuronSource._id)")
        let neuronRequestLocal: NeuronRequest = neuronRequest
        
        if neuronRequestLocal.neuronOperation.acknowledgement == true {
            print("\(BrainControllerNeuron.getName()) acknowledgement so return")
            return false
        }
        
        if neuronRequestLocal.neuronOperation.response == true {
            // IS NOT USED AND CAN CAUSE MEMORY
//            BrainControllerNeuron.setChildResponse(sourceId: neuronRequestLocal.neuronSource._id, neuronRequest: neuronRequest)
            print("\(BrainControllerNeuron.getName()) response so return")
            return false
        }
        
        if neuronRequestLocal.neuronOperation.asynchronus == true &&
            neuronRequestLocal.neuronOperation._id.isEmpty {
            neuronRequestLocal.neuronOperation._id = NSUUID().uuidString
        }
        
        if neuronRequest.neuronOperation.name == "NeuronOperation.GetResponse" {
//            neuronResponse = neuronUtility.getFromDatabase(neuronRequest: neuronRequest)
            let neuronSource = NeuronUtility.getDendrite(sourceId: neuronRequest.neuronSource._id, neuronName: neuronRequest.neuronSource.name)
            neuronSource.setDendrite(neuronRequest: neuronResponse, udbcDatabaseOrm: udbcDatabaseOrm!)
            print("\(BrainControllerNeuron.getName()) got response so return")
            return false
        }
        
        return true
    }
    
    private func process(neuronRequest: NeuronRequest) throws {
        print("\(BrainControllerNeuron.getName()): process")
        
        try callRemoteBrainControllerNeuron(neuronRequest: neuronRequest)
        
        if neuronUtility.isNeuronOperationError(neuronResponse: neuronResponse) {
            return
        }
        
        callNeuron(neuronRequest: neuronRequest)
    }
    
    private func callNeuron(neuronRequest: NeuronRequest) {
        
    }
    
    private func callRemoteBrainControllerNeuron(neuronRequest: NeuronRequest) throws {
        let neuronRequestLocal = NeuronRequest()
        neuronRequestLocal.neuronSource._id = neuronRequest.neuronSource._id
        neuronRequestLocal.neuronOperation.synchronus = true
        neuronRequestLocal.neuronOperation._id = neuronRequest.neuronOperation._id
        neuronRequestLocal.neuronSource.name = neuronRequest.neuronSource.name
        neuronRequestLocal.neuronSource.type = neuronRequest.neuronSource.name
        neuronRequestLocal.neuronOperation.name = neuronRequest.neuronOperation.name
        neuronRequestLocal.neuronTarget.name = neuronRequest.neuronTarget.name
        neuronRequestLocal.language = neuronRequest.language
        neuronRequestLocal.neuronOperation.parent = true
        neuronRequestLocal.neuronOperation.neuronData.text = neuronRequest.neuronOperation.neuronData.text
        let jsonUtility = JsonUtility<NeuronRequest>()
        let json = jsonUtility.convertAnyObjectToJson(jsonObject: neuronRequestLocal)
        let parameters = try JSONSerialization.jsonObject(with: json.data(using: .utf8, allowLossyConversion: false)!) as? [String: Any]
        
       
//        AF.request("http://172.20.10.3:80/dendrite", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON(completionHandler: alamoFireResponseHandler)
        AF.request("http://192.168.1.140:83/dendrite", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON(completionHandler: alamoFireResponseHandler)
//        Alamofire.request("http://63.135.170.17/dendrite", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON(completionHandler: alamoFireResponseHandler)


    }
    
    private func alamoFireResponseHandler(completion: DataResponse<Any>) {
        do {
            if let error = completion.error {
                print(error.localizedDescription)
                neuronResponse.neuronOperation.response = true; neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility.getNeuronOperationError(name: NeuronOperationErrorType.ErrorInProcessing.name, description: error.localizedDescription))
                let neuronSource = NeuronUtility.getDendrite(sourceId: neuronResponse.neuronSource._id, neuronName: neuronResponse.neuronSource.name)
                neuronSource.setDendrite(neuronRequest: neuronResponse, udbcDatabaseOrm: udbcDatabaseOrm!)
                return
            }
            
            if let json = completion.result.value {
                let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                
                if let jsonString = String(bytes: jsonData, encoding: String.Encoding.utf8) {
                    let jsonUtility = JsonUtility<NeuronRequest>()
                    let neuronResponseLocal = jsonUtility.convertJsonToAnyObject(json: jsonString)
                    let neuronSource = NeuronUtility.getDendrite(sourceId: neuronResponseLocal.neuronSource._id, neuronName: neuronResponseLocal.neuronSource.name)
                    neuronSource.setDendrite(neuronRequest: neuronResponseLocal, udbcDatabaseOrm: udbcDatabaseOrm!)
                }
                
            }
           
        } catch {
            neuronResponse.neuronOperation.response = true; neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility.getNeuronOperationError(name: NeuronOperationErrorType.ErrorInProcessing.name, description: error.localizedDescription))
            
        }
    }
    
    private func postProcess(neuronRequest: NeuronRequest) {
        print("\(BrainControllerNeuron.getName()): post process")
        
        
        
        do {
            if neuronRequest.neuronOperation.asynchronusProcess == true {
                print("\(BrainControllerNeuron.getName()) Asynchronus so storing response in database")
                neuronResponse.neuronOperation.neuronOperationStatus.status = NeuronOperationStatusType.Completed.name
                
//                let rows = try NeuronRequest.update(udbcDatabaseOrm: udbcDatabaseOrm!, id: (neuronRequest._id), status: NeuronOperationStatusType.Completed.name)
//                neuronUtility.storeInDatabase(neuronRequest: neuronResponse)
            }
            print("\(BrainControllerNeuron.getName()) Informing: \(String(describing: neuronRequest.neuronSource.name))")
            let neuronSource = NeuronUtility.getDendrite(sourceId: neuronRequest.neuronSource._id, neuronName: neuronRequest.neuronSource.name)
            neuronSource.setDendrite(neuronRequest: neuronResponse, udbcDatabaseOrm: udbcDatabaseOrm!)
            
        } catch {
            print(error)
            print("\(BrainControllerNeuron.getName()): Error thrown in post process: \(error)")
            neuronResponse.neuronOperation.response = true; neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility.getNeuronOperationError(name: NeuronOperationErrorType.ErrorInProcessing.name, description: error.localizedDescription))
            
        }
        
        defer {
            print("\(BrainControllerNeuron.getName()): Removed dendtrite: \(neuronRequest.neuronSource._id) ")
            BrainControllerNeuron.removeDendrite(sourceId: neuronRequest.neuronSource._id)
        }
        
    }
    
}
