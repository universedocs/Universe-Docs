//
//  AppController.swift
//  UniversalBrainScheduler
//
//  Created by Kumar Muthaiah on 09/11/18.
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

public class BrainShcedulerApplication : Neuron {
    public static func getRootResponse(neuronSourceId: String) -> NeuronRequest {
        return NeuronRequest()
    }
    
    static var dendriteMap: [String : Neuron] = [String : Neuron]()
    private var responseMap: [String : NeuronRequest] = [String : NeuronRequest]()
    static let serialQueue = DispatchQueue(label: "SerialQueue")
    private var databaseOrm: DatabaseOrm?
    private var udbcDatabaseOrm: UDBCDatabaseOrm?
    public init() {
        
    }
    
    public func start() {
//        do {
//            databaseOrm = try DatabaseOrm()
//            udbcDatabaseOrm = UDBCDatabaseOrm()
//            udbcDatabaseOrm!.ormObject = databaseOrm
//            udbcDatabaseOrm!.type = UDBCDatabaseType.MongoDatabase.rawValue
//            let neuronRequestLocal = NeuronRequest()
//            neuronRequestLocal.neuronSource._id = NSUUID.init().uuidString
//            neuronRequestLocal.neuronOperation.synchronus = true
//            neuronRequestLocal.neuronOperation.asynchronusProcess = true
//            neuronRequestLocal.neuronSource.name = BrainSchedulerNeuron.getName()
//            neuronRequestLocal.neuronSource.type = BrainSchedulerNeuron.getName();
//            neuronRequestLocal.neuronOperation.name = "BrainScheduler.Process"
//            neuronRequestLocal.neuronOperation.parent = true
//            let brainSchedulerRequest = BrainSchedulerRequest()
//            let jsonUtility = JsonUtility<BrainSchedulerRequest>()
//            neuronRequestLocal.neuronOperation.neuronData.text = jsonUtility.convertAnyObjectToJson(jsonObject: brainSchedulerRequest)
//            let neuronSource = neuronUtility!.getDendrite(sourceId: neuronRequestLocal.neuronSource._id, neuronName: BrainSchedulerNeuron.getName())
//            neuronSource!.setDendrite(neuronRequest: neuronRequestLocal, udbcDatabaseOrm: udbcDatabaseOrm!)
//            
//            defer {
//                do {
//                    try databaseOrm?.disconnect()
//                } catch {
//                    print(error)
//                }
//            }
//        } catch {
//            print(error)
//        }
    }
    
    static public func getName() -> String {
        return "BrainShcedulerApplication"
    }
    
    public static func getDescription() -> String {
        return "Brain Shceduler Application"
    }
    
    static public func getDendrite(sourceId: String) -> (Neuron) {
        var neuron: Neuron?
        
        serialQueue.sync {
            print("Before: \(dendriteMap.debugDescription)")
            neuron = dendriteMap[sourceId]
            if neuron == nil {
                print("\(getName()): Created: \(sourceId)")
                dendriteMap[sourceId] = BrainShcedulerApplication()
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
    
    private static func removeDendrite(sourceId: String) {
        serialQueue.sync {
            print("neuronUtility: removed neuron: "+sourceId)
            dendriteMap.removeValue(forKey: sourceId)
            print("After removal \(getName()): \(dendriteMap.debugDescription)")
        }
    }
    
    public func setDendrite(neuronRequest: NeuronRequest, udbcDatabaseOrm: UDBCDatabaseOrm,  neuronUtility: NeuronUtility) {
    }
    
}
