//
//  Application.swift
//  UniversalBrainController
//
//  Created by Kumar Muthaiah on 28/10/18.
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

public class BrainControllerApplication : Neuron {
    static var dendriteMap: [String : Neuron] = [String : Neuron]()
    private var responseMap: [String : NeuronRequest] = [String : NeuronRequest]()
    static var rootResponseMap: [String : NeuronRequest] = [String : NeuronRequest]()
    static let serialQueue = DispatchQueue(label: "SerialQueue")
    static let serialQueue1 = DispatchQueue(label: "SerialQueue1")
    
    
    static public func getDescription() -> String {
        return "Brain Controller Application"
    }
    
    static public func getDendrite(sourceId: String) -> (Neuron) {
        var neuron: Neuron?
        
        serialQueue.sync {
            print("Before: \(dendriteMap.debugDescription)")
            neuron = dendriteMap[sourceId]
            if neuron == nil {
                print("\(getName()): Created: \(sourceId)")
                dendriteMap[sourceId] = BrainControllerApplication()
                neuron = dendriteMap[sourceId]
            }
            print("After creation: \(dendriteMap.debugDescription)")
        }
        
        return  neuron!;
    }
    
    private func setChildResponse(sourceId: String, neuronRequest: NeuronRequest) {
        responseMap[sourceId] = neuronRequest
    }
    
    private func getChildResponse(sourceId: String) -> NeuronRequest {
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
   
    
    public func setDendrite(neuronRequest: NeuronRequest,  udbcDatabaseOrm: UDBCDatabaseOrm, neuronUtility: NeuronUtility) {
        
        if neuronRequest.neuronOperation.acknowledgement == true {
            print("\(BrainControllerApplication.getName()): Got Acknowledgement")
            return
        }
        if neuronRequest.neuronOperation.response  == true {
            print("\(BrainControllerApplication.getName()): Got Response")
            BrainControllerApplication.setRootResponse(neuronSourceId: neuronRequest.neuronSource._id, request: neuronRequest)
            BrainControllerApplication.removeDendrite(sourceId: neuronRequest.neuronSource._id)
            print("Brain controller application Neuron  Dendrite MAP: \(BrainControllerApplication.dendriteMap)")
        }
        
    }
    
    static public func getName() -> String {
        return "BrainControllerApplication"
    }
    
    public static func getRootResponse(neuronSourceId: String) -> NeuronRequest {
        var neuronResponse: NeuronRequest?
//        serialQueue1.sync {
            
            if let _ = rootResponseMap[neuronSourceId] {
                neuronResponse = rootResponseMap[neuronSourceId]
                rootResponseMap.removeValue(forKey: neuronSourceId)
                print("Root response map: \(rootResponseMap)")
            }
//        }
        if neuronResponse == nil {
            neuronResponse = NeuronRequest()
        }
        
        return neuronResponse!
    }
    
    private static func setRootResponse(neuronSourceId: String, request: NeuronRequest) {
//        serialQueue1.sync {
            print("\(BrainControllerNeuron.getName()) setting child response")
            rootResponseMap[neuronSourceId] = request
//        }
    }
}
