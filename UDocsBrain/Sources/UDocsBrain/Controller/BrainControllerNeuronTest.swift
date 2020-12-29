//
//  BrainControllerTest.swift
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
import UDocsDatabaseModel
import UDocsDatabaseUtility
import UDocsNeuronModel
import UDocsNeuronUtility


public class BrainControllerNeuronTest : Neuron {
    public static func getRootResponse(neuronSourceId: String) -> NeuronRequest {
        return NeuronRequest()
    }
    static var dendriteMap: [String : Neuron] = [String : Neuron]()
    private var responseMap: [String : NeuronRequest] = [String : NeuronRequest]()
    static let serialQueue = DispatchQueue(label: "SerialQueue")
    var udbcDatabaseOrm: UDBCDatabaseOrm?
    
    static public func getDescription() -> String {
        return "Brain Controller Neuron Test"
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
    
    private func setChildResponse(operationName: String, neuronRequest: NeuronRequest) {
        responseMap[operationName] = neuronRequest
    }
    
    public func getChildResponse(operationName: String) -> NeuronRequest {
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
            print("After removal: \(dendriteMap.debugDescription)")
        }
    }
    
    public func setDendrite(neuronRequest: NeuronRequest, udbcDatabaseOrm: UDBCDatabaseOrm,  neuronUtility: NeuronUtility) {
        if neuronRequest.neuronOperation.acknowledgement {
            print("\(BrainControllerNeuronTest.getName()): Got Acknowledgement")
            return
        }
        if neuronRequest.neuronOperation.response {
            print("\(BrainControllerNeuronTest.getName()): Got Response")
            setChildResponse(operationName: neuronRequest.neuronOperation.name, neuronRequest: neuronRequest)
        }
        
    }
    
    
    static public func getName() -> String {
        return "BrainControllerNeuronTest"
    }
   
    
    
    public func testBrainControllerNeuron() {
//        do {
//            let databaseOrm = try DatabaseOrm()
//            let udbcDatabaseOrm = UDBCDatabaseOrm()
//            udbcDatabaseOrm.ormObject = databaseOrm
//            udbcDatabaseOrm.type = UDBCDatabaseType.MongoDatabase.rawValue
//
//            let sourceId = NSUUID().uuidString
//            let brainControllerNeuron = BrainControllerNeuron.getDendrite(sourceId: sourceId)
//            let neuronRequest = NeuronRequest()
//            neuronRequest.neuronOperation.synchronus = true
//            neuronRequest.neuronOperation.name = SecurityNeuronOperationType.ConnectUser.name
//            neuronRequest.neuronSource.name = "UniversalBrainControllerTest"
//            neuronRequest.neuronTarget.name = SecurityNeuron.getName()
//            let uscApplicationAuthenticationRequest = USCUserAuthenticationRequest()
//            uscApplicationAuthenticationRequest.userProfileId = "5bd3412c7c2dfee4b561648a"
//            uscApplicationAuthenticationRequest.upcApplicationProfileId = "5bd3412f7c2dfee4b661648a"
//            uscApplicationAuthenticationRequest.type.append(USCApplicationAuthenticationType.UserNamePasswordAuthenticaiton.name)
//
//            uscApplicationAuthenticationRequest.uscUserNamePasswordAuthentication.userName = "kumarmuthaiah"
//            uscApplicationAuthenticationRequest.uscUserNamePasswordAuthentication.password = "test"
//            let jsonUtility = JsonUtility<USCUserAuthenticationRequest>()
//
//            neuronRequest.neuronOperation.neuronData.text = jsonUtility.convertAnyObjectToJson(jsonObject: uscApplicationAuthenticationRequest)
//            let jsonUtility1 = JsonUtility<NeuronRequest>()
//            print(jsonUtility1.convertAnyObjectToJson(jsonObject: neuronRequest))
//            brainControllerNeuron.setDendrite(neuronRequest: neuronRequest, udbcDatabaseOrm: udbcDatabaseOrm)
//            let neuronResponse = getChildResponse(operationName: neuronRequest.neuronOperation.name)
//            if neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.count == 0 {
//                for success in neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationSuccess! {
//                    print("Output: \(success.name), description: \(success.description)")
//                }
//            } else {
//                for error in neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError! {
//                    print("Error: \(error.name), description: \(error.description)")
//                }
//
//            }
//
//            defer {
//                do {
//                    try databaseOrm.disconnect()
//                } catch {
//                    print(error)
//                }
//
//            }
//        } catch {
//            print(error)
//        }
    }
    
    public func addRegisteUserData() {
//        do {
//            let databaseOrm = try DatabaseOrm()
//            let udbcDatabaseOrm = UDBCDatabaseOrm()
//            udbcDatabaseOrm.ormObject = databaseOrm
//            udbcDatabaseOrm.type = UDBCDatabaseType.MongoDatabase.rawValue
//
//            let uscRegisterUserRequest = USCCreateConnectionRequest()
//            uscRegisterUserRequest.upcApplicationProfileId = "5bd721358d1a9c7d4866c9d9"
//            uscRegisterUserRequest.upcCompanyProfileId = "5bd721358d1a9c7d4766c9d9"
//            let upcHumanProfile = UPCHumanProfile()
//            upcHumanProfile._id = try udbcDatabaseOrm.generateId()
//            upcHumanProfile.firstName = "Uma"
//            upcHumanProfile.lastName = "Meyyappan"
//            uscRegisterUserRequest.upcHumanProfile = upcHumanProfile
//            let uscUserNamePasswordAuthentication = USCUserNamePasswordAuthentication()
//            uscUserNamePasswordAuthentication.userName = "umameyyappan"
//            uscUserNamePasswordAuthentication.password = BCrypt.hash(password: "test1")
//            uscRegisterUserRequest.uscUserNamePasswordAuthentication = uscUserNamePasswordAuthentication
//            let jsonUtility = JsonUtility<USCCreateConnectionRequest>()
//            let text = jsonUtility.convertAnyObjectToJson(jsonObject: uscRegisterUserRequest)
//            print(text)
//
//            defer {
//                do {
//                    try databaseOrm.disconnect()
//                } catch {
//                    print(error)
//                }
//
//            }
//        } catch {
//            print(error)
//        }
    }
}
