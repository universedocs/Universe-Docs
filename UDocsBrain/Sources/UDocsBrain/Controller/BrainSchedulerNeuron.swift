//
//  BrainScheduler.swift
//  UniversalBrainController
//
//  Created by Kumar Muthaiah on 15/10/18.
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
import UDocsSecurityNeuron

open class BrainSchedulerNeuron : Neuron {
    public static func getRootResponse(neuronSourceId: String) -> NeuronRequest {
        return NeuronRequest()
    }
    let neuronUtility: NeuronUtility? = nil
    var neuronSource: Neuron?
    var udbcDatabaseOrm: UDBCDatabaseOrm?
    var isPaused: Bool = false
    var isResumed: Bool = false
    var isShutdown: Bool = false
    var dameonStarted: Bool = false
    let serialQueue = DispatchQueue(label: "SerialQueue")
    static var dendriteMap: [String : Neuron] = [String : Neuron]()
    private var responseMap: [String : NeuronRequest] = [String : NeuronRequest]()
    static let serialQueue = DispatchQueue(label: "SerialQueue")
    var neuronResponse = NeuronRequest()
    var brainSchedulerRequest: BrainSchedulerRequest?
    var brainSchedulerResponse: BrainSchedulerRequest?
    
    private init() {
        
    }
    
    static public func getName() -> String {
        return "BrainShceduler"
    }
    
    public static func getDescription() -> String {
        return "Brain Shceduler"
    }
    
    static public func getDendrite(sourceId: String) -> (Neuron) {
        var neuron: Neuron?
        
        serialQueue.sync {
            print("Before: \(dendriteMap.debugDescription)")
            neuron = dendriteMap[sourceId]
            if neuron == nil {
                print("\(getName()): Created: \(sourceId)")
                dendriteMap[sourceId] = BrainSchedulerNeuron()
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
    
    public func setDendrite(neuronRequest: NeuronRequest, udbcDatabaseOrm: UDBCDatabaseOrm,  neuronUtility: NeuronUtility) {
        self.udbcDatabaseOrm = udbcDatabaseOrm
        
        
        neuronResponse.neuronSource._id = neuronRequest.neuronSource._id
        neuronResponse.neuronOperation._id = neuronRequest.neuronOperation._id
        
        
        var neuronRequestLocal = neuronRequest
        do {
            self.neuronUtility!.setUDBCDatabaseOrm(udbcDatabaseOrm: udbcDatabaseOrm, neuronName: BrainSchedulerNeuron.getName())
            
            
            let continueProcess = try preProcess(neuronRequest: neuronRequestLocal)
            if continueProcess == false {
                print("\(BrainSchedulerNeuron.getName()): don't process return")
                return
            }
            validateRequest(neuronRequest: neuronRequest)
            
            if neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError!.count > 0 {
                print("\(BrainSchedulerNeuron.getName()) error in validation return")
                let neuronSource = self.neuronUtility!.getDendrite(sourceId: neuronRequest.neuronSource._id, neuronName: neuronRequest.neuronSource.name)
                neuronSource!.setDendrite(neuronRequest: neuronResponse, udbcDatabaseOrm: self.udbcDatabaseOrm!, neuronUtility: self.neuronUtility!)
                return
            }
            
            
            
            // Controller says no need to
            
            neuronResponse.neuronOperation.acknowledgement = false
            
            if neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError!.count == 0 {
                if neuronRequest.neuronOperation.asynchronus == true {
                    print("\(BrainSchedulerNeuron.getName()) asynchronus store the request and return")
                    neuronResponse.neuronOperation.response = true
                    neuronResponse.neuronOperation.neuronData.text = ""
                    self.neuronUtility!.storeInDatabase(neuronRequest: neuronRequest)
                    return
                } else {
                    if neuronRequest.neuronOperation.synchronus == true {
                        
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
            print("\(BrainSchedulerNeuron.getName()): Error thrown in setdendrite: \(error)")
            neuronResponse.neuronOperation.response = true
            let neuronOperationError = NeuronOperationError()
            neuronOperationError.name = "UnknownError"
            neuronOperationError.description = error.localizedDescription
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronOperationError)
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
        print("\(BrainSchedulerNeuron.getName()): pre process")
        neuronResponse.neuronSource._id = neuronRequest.neuronSource._id
        
        print("neuronUtility: pre process: \(neuronRequest.neuronSource._id)")
        let neuronRequestLocal: NeuronRequest = neuronRequest
        
        if neuronRequestLocal.neuronOperation.acknowledgement == true {
            print("\(BrainSchedulerNeuron.getName()) acknowledgement so return")
            return false
        }
        
        if neuronRequestLocal.neuronOperation.response == true {
            setChildResponse(operationName: neuronRequestLocal.neuronOperation.name, neuronRequest: neuronRequest)
            print("\(BrainSchedulerNeuron.getName()) response so return")
            return false
        }
        
        if neuronRequestLocal.neuronOperation.asynchronus == true &&
            neuronRequestLocal.neuronOperation._id.isEmpty {
            neuronRequestLocal.neuronOperation._id = NSUUID().uuidString
        }
        
        if neuronRequest.neuronOperation.name == "NeuronOperation.GetResponse" {
            let databaseOrmResultFromDatabase = neuronUtility!.getFromDatabase(neuronRequest: neuronRequest)
            if databaseOrmResultFromDatabase.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultFromDatabase.databaseOrmError[0].name, description: databaseOrmResultFromDatabase.databaseOrmError[0].description))
                return false
            }
            neuronResponse = databaseOrmResultFromDatabase.object[0]
            let neuronSource = neuronUtility!.getDendrite(sourceId: neuronRequest.neuronSource._id, neuronName: neuronRequest.neuronSource.name)
            neuronSource!.setDendrite(neuronRequest: neuronResponse, udbcDatabaseOrm: self.udbcDatabaseOrm!, neuronUtility: self.neuronUtility!)
            print("\(BrainSchedulerNeuron.getName()) got response so return")
            return false
        }
        
        return true
    }
    
    private func process(neuronRequest: NeuronRequest) throws {
        print("process")
        var neuronResponseLocal = neuronResponse
        
        // Start Dameon only for first time
        if dameonStarted == false {
            dameonStarted = true
            neuronResponseLocal = startDameon(neuronRequest: neuronRequest)
            // Acknowledge user of the starting dameon
            let neuronResponse = NeuronRequest()
            neuronUtility!.storeInDatabase(neuronRequest: neuronResponse)
            neuronResponseLocal.neuronOperation.neuronData.text = neuronUtility!.getNeuronResponse(object: BrainSchedulerResponse())
            return
        } else {
            processOperation(neuronRequest: neuronRequest)
        }
        
        neuronResponse.neuronOperation.response = true
        neuronResponseLocal.neuronOperation.neuronData.text = neuronUtility!.getNeuronResponse(object: BrainSchedulerResponse())
        return
    }
    
    func callNeuron(neuronName: String, neuronRequest: NeuronRequest, udbcDatabaseOrm: UDBCDatabaseOrm,  neuron: Neuron)   {
        
        print("\(BrainSchedulerNeuron.getName()) Update the status to in progress")
        let databaseOrmResultUpdate = NeuronRequest.update(udbcDatabaseOrm: udbcDatabaseOrm, id: (neuronRequest._id), status: NeuronOperationStatusType.InProgress.name)
     
        if databaseOrmResultUpdate.databaseOrmError.count > 0 {
            print("\(databaseOrmResultUpdate.databaseOrmError[0].name): \(databaseOrmResultUpdate.databaseOrmError[0].description)")
        }
        
        switch neuronName {
        case "SecurityNeuron":
            print("*******Calling local brain")
            let neuronRequestLocal = NeuronRequest()
            neuronRequestLocal.neuronSource._id = neuronRequest.neuronSource._id
            neuronRequestLocal.neuronOperation.synchronus = true
            neuronRequestLocal.neuronOperation._id = neuronRequest.neuronOperation._id
            neuronRequestLocal.neuronSource.name = BrainControllerNeuron.getName()
            neuronRequestLocal.neuronSource.type = BrainControllerNeuron.getName();
            neuronRequestLocal.neuronOperation.name = neuronRequest.neuronOperation.name
            neuronRequestLocal.neuronOperation.parent = true
            neuronRequestLocal.neuronOperation.neuronData.text = neuronRequest.neuronOperation.neuronData.text
            neuronRequestLocal.neuronTarget.name = neuronName
            let securityNeuron = SecurityNeuron.getDendrite(sourceId: neuronRequestLocal.neuronSource._id)
            
            securityNeuron.setDendrite(neuronRequest: neuronRequestLocal, udbcDatabaseOrm: udbcDatabaseOrm, neuronUtility: self.neuronUtility!)
            
            let neuronResponseLocal = getChildResponse(operationName: neuronRequestLocal.neuronOperation.name)
            
            if neuronResponseLocal.neuronOperation.neuronOperationStatus.neuronOperationError!.count > 0 {
                print("\(BrainControllerNeuron.getName()) Errors from child: \(neuronRequest.neuronOperation.name))")
                neuronResponse.neuronOperation.response = true
                for noe in neuronResponseLocal.neuronOperation.neuronOperationStatus.neuronOperationError! {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(noe)
                }
            } else {
                for noe in neuronResponseLocal.neuronOperation.neuronOperationStatus.neuronOperationSuccess! {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationSuccess?.append(noe)
                }
                print("\(BrainControllerNeuron.getName()) Success from child: \(neuronRequest.neuronOperation.name))")
                neuronResponse.neuronOperation.neuronData.text = neuronResponseLocal.neuronOperation.neuronData.text
            }
            print("\(BrainSchedulerNeuron.getName()) Update the status to completed")
            let databaseOrmResultUpdate = NeuronRequest.update(udbcDatabaseOrm: udbcDatabaseOrm, id: (neuronRequest._id), status: NeuronOperationStatusType.Completed.name)
            if databaseOrmResultUpdate.databaseOrmError.count > 0 {
                return
            }
            let databaseOrmResultStoreInDatabase = neuronUtility!.storeInDatabase(neuronRequest: neuronResponse)
            if databaseOrmResultStoreInDatabase.databaseOrmError.count > 0 {
                return
            }
        default:
            break
        }
    }
    
    private func authenticateUser(neuronRequest: NeuronRequest) {
        
    }
    class APIManager {
        
        
        func post(neuronRequest: NeuronRequest, parameters: [String: Any], onSuccess: @escaping(NeuronRequest, NeuronRequest) -> Void, onFailure: @escaping(NeuronRequest, NeuronRequest) -> Void){
            
            let Url = String(format: "http://192.168.1.141:8080/dendrite")
            guard let serviceUrl = URL(string: Url) else { return }
            var request = URLRequest(url: serviceUrl)
            request.httpMethod = "POST"
            guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
                return
            }
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = httpBody
            
            let session = URLSession.shared
            
            
            let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                if(error != nil){
                    onFailure(NeuronRequest(), NeuronRequest())
                } else{
                    if let data = data {
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: [])
                            
                            let jsonData = try JSONSerialization.data(withJSONObject: json, options: [] )
                            let convertedString = String(data: jsonData, encoding: String.Encoding.utf8)
                           
                            let jsonUtility = JsonUtility<NeuronRequest>()
                            let neuronResponse = jsonUtility.convertJsonToAnyObject(json: convertedString!)
                            onSuccess(neuronRequest, neuronResponse)
                        }catch {
                            print(error)
                            onFailure(NeuronRequest(), NeuronRequest())
                        }
                    }
                    
                }
                
            })
            task.resume()
        }
        
    }
    
    private func pause() {
        isPaused = true
    }
    
    private func resume() {
        isPaused = false
    }
    
    func onFailure(neuronRequest: NeuronRequest, neuronResponse: NeuronRequest)  {
        print("********FAILURE********")
    }
    
    
    func onSuccess(neuronRequest: NeuronRequest, neuronResponse: NeuronRequest) {
        print("********SUCCESS********")
        pause()
        do {
            neuronResponse._id = try (udbcDatabaseOrm?.generateId())!
            neuronResponse.neuronOperation.neuronOperationStatus.status = NeuronOperationStatusType.Completed.name
            let databaseOrmResultStoreInDatabase = neuronUtility!.storeInDatabase(neuronRequest: neuronResponse)
            if databaseOrmResultStoreInDatabase.databaseOrmError.count > 0 {
                print("\(databaseOrmResultStoreInDatabase.databaseOrmError[0].name): \(databaseOrmResultStoreInDatabase.databaseOrmError[0].description)")
            }
//            let neuronSource = neuronUtility!.getDendrite(sourceId: neuronRequest.neuronSource._id, neuronName: neuronRequest.neuronSource.name)
//            neuronSource!.setDendrite(neuronRequest: neuronResponse, udbcDatabaseOrm: self.udbcDatabaseOrm!)
        } catch {
            print(error)
        }
        defer {
            resume()
        }
    }
    
    private func callRemoteBrainControllerNeuron(neuronRequest: NeuronRequest) throws {
        pause()
        let neuronRequestLocal = NeuronRequest()
        neuronRequestLocal.neuronSource._id = neuronRequest.neuronSource._id
        neuronRequestLocal.neuronOperation.synchronus = true
        neuronRequestLocal.neuronOperation._id = neuronRequest.neuronOperation._id
        neuronRequestLocal.neuronSource.name = BrainSchedulerNeuron.getName()
        neuronRequestLocal.neuronSource.type = BrainSchedulerNeuron.getName();
        neuronRequestLocal.neuronOperation.name = neuronRequest.neuronOperation.name
        neuronRequestLocal.neuronOperation.parent = true
        neuronRequestLocal.neuronOperation.neuronData.text = neuronRequest.neuronOperation.neuronData.text
        let jsonUtility = JsonUtility<NeuronRequest>()
        let json = jsonUtility.convertAnyObjectToJson(jsonObject: neuronRequestLocal)
        let parameters = try JSONSerialization.jsonObject(with: json.data(using: .utf8, allowLossyConversion: false)!) as? [String: Any]
        
        let apiManager = APIManager()
        apiManager.post(neuronRequest: neuronRequest, parameters: parameters!, onSuccess: onSuccess, onFailure: onFailure)
        defer {
            resume()
        }
    }
    
    private func dameonProcess(neuronRequest: NeuronRequest)  {
        let neuronRequestLocal = neuronRequest
        
        let targetName: String = neuronRequest.neuronTarget.name
        neuronRequestLocal.neuronOperation.synchronus = true
        neuronRequestLocal.neuronOperation.asynchronusProcess = true
        callNeuron(neuronName: targetName, neuronRequest: neuronRequestLocal, udbcDatabaseOrm: udbcDatabaseOrm!,  neuron: self)
        
        return
    }
    
    private func startDameon(neuronRequest: NeuronRequest) -> (NeuronRequest) {
        let _ = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: BrainSchedulerRequest())
        
        serialQueue.sync {
            while(true) {
                if isPaused == true {
                    Thread.sleep(forTimeInterval: 1)
                    continue
                }
                
                    let databaseOrmResultOperationsFromDatabase = neuronUtility!.getOperationsFromDatabase(neuronRequest: neuronRequest)
                
                if databaseOrmResultOperationsFromDatabase.databaseOrmError.count > 0 {
                    print("\(databaseOrmResultOperationsFromDatabase.databaseOrmError[0].name): \(databaseOrmResultOperationsFromDatabase.databaseOrmError[0].description)")
                }
            
                for nr in databaseOrmResultOperationsFromDatabase.object {
          
                    if nr.neuronOperation.name.starts(with: "NeuronOperation.BrainScheduler") {
                    // Check any operation requested by user
                        processOperation(neuronRequest: nr)
                    }
                    if isShutdown == true {
                        break
                    }
                    if isPaused == false || isResumed == true {
                         if !nr.neuronOperation.name.starts(with: "NeuronOperation.BrainScheduler") {
                            // Process
                            let _ = dameonProcess(neuronRequest: nr)
                            
                        }
                    }
                }
                if neuronRequest.neuronOperation.name == "NeuronOperation.BrainScheduler.ProcessAndExit" {
                    // Acknowledge user of the command execution
                    let neuronResponse = NeuronRequest()
                    let databaseOrmResultStoreInDatabase = neuronUtility!.storeInDatabase(neuronRequest: neuronResponse)
                    if databaseOrmResultStoreInDatabase.databaseOrmError.count > 0 {
                        print("\(databaseOrmResultStoreInDatabase.databaseOrmError[0].name): \(databaseOrmResultStoreInDatabase.databaseOrmError[0].description)")
                    }
                    break
                }
                // Sleep here so that CPU is not occupied
                Thread.sleep(forTimeInterval: 1)
            }
        }
        
        return neuronResponse
    }
    
    private func processOperation(neuronRequest: NeuronRequest) {
        if neuronRequest.neuronOperation.name == "NeuronOperation.BrainScheduler.Pause" {
            isPaused = true
            isResumed = false
            // Acknowledge user of the command execution
            let neuronResponse = NeuronRequest()
            let databaseOrmResultStoreInDatabase = neuronUtility!.storeInDatabase(neuronRequest: neuronResponse)
            if databaseOrmResultStoreInDatabase.databaseOrmError.count > 0 {
                print("\(databaseOrmResultStoreInDatabase.databaseOrmError[0].name): \(databaseOrmResultStoreInDatabase.databaseOrmError[0].description)")
            }
        } else if neuronRequest.neuronOperation.name == "NeuronOperation.BrainScheduler.Resume" {
            isResumed = true
            isPaused = false
            // Acknowledge user of the command execution
            let neuronResponse = NeuronRequest()
            let databaseOrmResultStoreInDatabase = neuronUtility!.storeInDatabase(neuronRequest: neuronResponse)
            if databaseOrmResultStoreInDatabase.databaseOrmError.count > 0 {
                print("\(databaseOrmResultStoreInDatabase.databaseOrmError[0].name): \(databaseOrmResultStoreInDatabase.databaseOrmError[0].description)")
            }
        } else if neuronRequest.neuronOperation.name == "NeuronOperation.BrainScheduler.Shutdown" {
            isShutdown = true
            // Acknowledge user of the command execution
            let neuronResponse = NeuronRequest()
            let databaseOrmResultStoreInDatabase = neuronUtility!.storeInDatabase(neuronRequest: neuronResponse)
            if databaseOrmResultStoreInDatabase.databaseOrmError.count > 0 {
                print("\(databaseOrmResultStoreInDatabase.databaseOrmError[0].name): \(databaseOrmResultStoreInDatabase.databaseOrmError[0].description)")
            }
        }
    }

    
    private func postProcess(neuronRequest: NeuronRequest) {
        print("\(BrainSchedulerNeuron.getName()): post process")
        
        
       
      
                if neuronRequest.neuronOperation.asynchronusProcess == true {
                    print("\(BrainSchedulerNeuron.getName()) Asynchronus so storing response in database")
                    neuronResponse.neuronOperation.neuronOperationStatus.status = NeuronOperationStatusType.Completed.name
                    
                    let databaseOrmResultUpdate = NeuronRequest.update(udbcDatabaseOrm: udbcDatabaseOrm!, id: (neuronRequest._id), status: NeuronOperationStatusType.Completed.name)
                    if databaseOrmResultUpdate.databaseOrmError.count > 0 {
                        print("\(databaseOrmResultUpdate.databaseOrmError[0].name): \(databaseOrmResultUpdate.databaseOrmError[0].description)")
                    }
                    let databaseOrmResultStoreInDatabase = neuronUtility!.storeInDatabase(neuronRequest: neuronResponse)
                    if databaseOrmResultStoreInDatabase.databaseOrmError.count > 0 {
                        print("\(databaseOrmResultStoreInDatabase.databaseOrmError[0].name): \(databaseOrmResultStoreInDatabase.databaseOrmError[0].description)")
                    }
                }
                print("\(BrainSchedulerNeuron.getName()) Informing: \(String(describing: neuronRequest.neuronSource.name))")
                let neuronSource = neuronUtility!.getDendrite(sourceId: neuronRequest.neuronSource._id, neuronName: neuronRequest.neuronSource.name)
        neuronSource!.setDendrite(neuronRequest: neuronResponse, udbcDatabaseOrm: self.udbcDatabaseOrm!, neuronUtility: self.neuronUtility!)
               
            
        
        defer {
             BrainSchedulerNeuron.removeDendrite(sourceId: neuronRequest.neuronSource._id)
            print("brain scheduler neuron RESPONSE MAP: \(responseMap)")
        }
        
    }
    
}
