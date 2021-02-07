//
//  BrainControllerNeuron.swift
//  BrainControllerNeuron
//
//  Created by Kumar Muthaiah on 25/10/18.
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
import UDocsUtility
import Alamofire
import UDocsNeuronModel
import UDocsNeuronUtility

open class BrainControllerNeuron : Neuron {
    
    
    
    public static func getRootResponse(neuronSourceId: String) -> NeuronRequest {
        return NeuronRequest()
    }
    var neuronUtility: NeuronUtility? = nil
    var udbcDatabaseOrm: UDBCDatabaseOrm?
    static var dendriteMap: [String : Neuron] = [String : Neuron]()
    private var responseMap: [String : NeuronRequest] = [String : NeuronRequest]()
    static let serialQueue = DispatchQueue(label: "SerialQueue")
    
    
    private init() {
        
    }
    
    private func process(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        
        #if os(macOS)
        print("\(BrainControllerNeuron.getName()): process")
        let brainControllerNeuronRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: BrainControllerNeuronRequest())
        
        // Getting login screen and forgot password screens handling
        if isForSecurity(neuronRequest: neuronRequest) {
            let neuronRequestLocal = NeuronRequest()
            neuronRequestLocal.neuronSource._id = neuronRequest.neuronSource._id
            neuronRequestLocal.neuronOperation.synchronus = true
            neuronRequestLocal.neuronOperation._id = neuronRequest.neuronOperation._id
            neuronRequestLocal.neuronSource.name = BrainControllerNeuron.getName()
            neuronRequestLocal.neuronSource.type = BrainControllerNeuron.getName()
            neuronRequestLocal.neuronOperation.name = neuronRequest.neuronOperation.name
            neuronRequestLocal.neuronOperation.parent = true
            neuronRequestLocal.neuronOperation.neuronData.text = brainControllerNeuronRequest.authenticationData
            neuronRequestLocal.neuronTarget.name = "SecurityNeuron"
            try callNeuron(neuronRequest: neuronRequestLocal, neuronResponse: &neuronResponse, neuronName: "SecurityNeuron")
            print("\(neuronRequest.neuronOperation.name): Getting security screens")
            return
        }
        
        // For login, logout and authentication for each request
        var neuronRequestLocal = NeuronRequest()
        neuronRequestLocal.neuronSource._id = neuronRequest.neuronSource._id
        neuronRequestLocal.neuronOperation.synchronus = true
        neuronRequestLocal.neuronOperation._id = neuronRequest.neuronOperation._id
        neuronRequestLocal.neuronSource.name = BrainControllerNeuron.getName()
        neuronRequestLocal.neuronSource.type = BrainControllerNeuron.getName()
        neuronRequestLocal.neuronOperation.name = SecurityNeuronOperationType.ConnectUser.name
        neuronRequestLocal.neuronOperation.parent = true
        neuronRequestLocal.neuronOperation.neuronData.text = brainControllerNeuronRequest.authenticationData
        neuronRequestLocal.neuronTarget.name = "SecurityNeuron"
        try callNeuron(neuronRequest: neuronRequestLocal, neuronResponse: &neuronResponse, neuronName: "SecurityNeuron")
        
        // If security issue, return
        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) ||
            neuronRequest.neuronOperation.name == SecurityNeuronOperationType.ConnectUser.name ||
            neuronRequest.neuronOperation.name == SecurityNeuronOperationType.DisconnectUser.name {
            print("\(neuronRequest.neuronOperation.name): Issue in security")
            return
        }
        
        print("\(neuronRequest.neuronOperation.name): Security check passed. Calling neuron \(neuronRequest.neuronTarget.name)....")
        //         Call the actual neuron to process
        neuronRequestLocal = NeuronRequest()
        neuronRequestLocal.neuronSource._id = neuronRequest.neuronSource._id
        neuronRequestLocal.neuronOperation.synchronus = true
        neuronRequestLocal.neuronOperation._id = neuronRequest.neuronOperation._id
        neuronRequestLocal.neuronSource.name = BrainControllerNeuron.getName()
        neuronRequestLocal.neuronSource.type = BrainControllerNeuron.getName()
        neuronRequestLocal.neuronOperation.name = neuronRequest.neuronOperation.name
        neuronRequestLocal.neuronOperation.parent = true
        neuronRequestLocal.neuronOperation.neuronData.text = brainControllerNeuronRequest.requestData
        neuronRequestLocal.neuronOperation.neuronData.dataOperationName = neuronRequest.neuronOperation.neuronData.dataOperationName
        neuronRequestLocal.neuronOperation.neuronData.type = neuronRequest.neuronOperation.neuronData.type
        neuronRequestLocal.neuronOperation.neuronData.binaryData = neuronRequest.neuronOperation.neuronData.binaryData
        neuronRequestLocal.neuronTarget.name = neuronRequest.neuronTarget.name
        try callNeuron(neuronRequest: neuronRequestLocal, neuronResponse: &neuronResponse, neuronName: neuronRequest.neuronTarget.name)
        neuronResponse.neuronOperation.response = true

        #else
        var neuronRequestLocal = NeuronRequest()
        neuronRequestLocal = NeuronRequest()
        neuronRequestLocal.neuronSource._id = neuronRequest.neuronSource._id
        neuronRequestLocal.neuronOperation.synchronus = true
        neuronRequestLocal.neuronOperation._id = neuronRequest.neuronOperation._id
        neuronRequestLocal.neuronSource.name = neuronRequest.neuronSource.name
        neuronRequestLocal.neuronSource.type = neuronRequest.neuronSource.type
        neuronRequestLocal.neuronOperation.name = neuronRequest.neuronOperation.name
        neuronRequestLocal.neuronOperation.parent = true
        neuronRequestLocal.neuronOperation.neuronData.text = neuronRequest.neuronOperation.neuronData.text
        neuronRequestLocal.neuronOperation.neuronData.dataOperationName = neuronRequest.neuronOperation.neuronData.dataOperationName
        neuronRequestLocal.neuronOperation.neuronData.type = neuronRequest.neuronOperation.neuronData.type
        neuronRequestLocal.neuronOperation.neuronData.binaryData = neuronRequest.neuronOperation.neuronData.binaryData
        neuronRequestLocal.neuronTarget.name = neuronRequest.neuronTarget.name
        try callNeuron(neuronRequest: neuronRequestLocal, neuronResponse: &neuronResponse, neuronName: neuronRequest.neuronTarget.name)
        neuronResponse.neuronOperation.acknowledgement = true
        #endif
    }
    
    private func isForSecurity(neuronRequest: NeuronRequest) -> Bool {
        if neuronRequest.neuronOperation.name == "SecurityNeuronOperationType.ForgotPasswordVerifyIdentity" ||
            neuronRequest.neuronOperation.name == SecurityNeuronOperationType.CreateUserConnection.name ||
            neuronRequest.neuronOperation.name == SecurityNeuronOperationType.SecurityControllerView.name ||
            neuronRequest.neuronOperation.name == "SecurityNeuronOperationType.ForgotPasswordVerifySecret"  ||
            neuronRequest.neuronOperation.name == "SecurityNeuronOperationType.ForgotPasswordChangePassword" {
            return true
        }
        
        return false
    }
    
    private func callNeuron(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest, neuronName: String) throws {
        let neuronRequestLocal = NeuronRequest()
        neuronRequestLocal.neuronSource._id = neuronRequest.neuronSource._id
        neuronRequestLocal.neuronOperation.synchronus = true
        neuronRequestLocal.neuronOperation._id = neuronRequest.neuronOperation._id
        #if os(macOS)
        neuronRequestLocal.neuronSource.name = BrainControllerNeuron.getName()
        neuronRequestLocal.neuronSource.type = BrainControllerNeuron.getName()
        #else
        neuronRequestLocal.neuronSource.name = neuronRequest.neuronSource.name
        neuronRequestLocal.neuronSource.type = neuronRequest.neuronSource.type
        #endif
        neuronRequestLocal.neuronOperation.name = neuronRequest.neuronOperation.name
        neuronRequestLocal.neuronOperation.parent = true
        neuronRequestLocal.neuronOperation.neuronData.type = neuronRequest.neuronOperation.neuronData.type
        neuronRequestLocal.neuronOperation.neuronData.dataOperationName = neuronRequest.neuronOperation.neuronData.dataOperationName
        neuronRequestLocal.neuronOperation.neuronData.text = neuronRequest.neuronOperation.neuronData.text
        neuronRequestLocal.neuronOperation.neuronData.binaryData = neuronRequest.neuronOperation.neuronData.binaryData
        neuronRequestLocal.neuronTarget.name = neuronName
        
        if !neuronUtility!.callNeuron(neuronRequest: neuronRequestLocal) {
            try callRemoteNeuron(neuronRequest: neuronRequestLocal)
        }
        
        let neuronResponseLocal = getChildResponse(sourceId: neuronRequest.neuronSource._id)
        
        if neuronResponseLocal.neuronOperation.neuronOperationStatus.neuronOperationError!.count > 0 {
            print("\(BrainControllerNeuron.getName()) Errors from child neuron: \(neuronRequest.neuronOperation.name))")
            neuronResponse.neuronOperation.response = true
            for noe in neuronResponseLocal.neuronOperation.neuronOperationStatus.neuronOperationError! {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(noe)
            }
        } else {
            for noe in neuronResponseLocal.neuronOperation.neuronOperationStatus.neuronOperationSuccess! {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationSuccess?.append(noe)
            }
            print("\(BrainControllerNeuron.getName()) Success from child neuron: \(neuronRequest.neuronOperation.name))")
            
        }
        neuronResponse.neuronOperation.neuronData.text =  neuronResponseLocal.neuronOperation.neuronData.text
        neuronResponse.neuronOperation.neuronData.binaryData =  neuronResponseLocal.neuronOperation.neuronData.binaryData
        //        print("Response: \(neuronResponse.neuronOperation.neuronData.text)")
    }
    
     private func callRemoteNeuron(neuronRequest: NeuronRequest) throws {
            let jsonUtilityBrainControllerNeuronRequest = JsonUtility<BrainControllerNeuronRequest>()
            let brainControllerNeuronRequest = jsonUtilityBrainControllerNeuronRequest.convertJsonToAnyObject(json: neuronRequest.neuronOperation.neuronData.text)
            let neuronRequestLocal = NeuronRequest()
            neuronRequestLocal.neuronSource._id = neuronRequest.neuronSource._id
            neuronRequestLocal.neuronOperation.synchronus = true
            neuronRequestLocal.neuronOperation._id = neuronRequest.neuronOperation._id
            neuronRequestLocal.neuronSource.name = neuronRequest.neuronSource.name
            neuronRequestLocal.neuronSource.type = neuronRequest.neuronSource.name
            neuronRequestLocal.neuronOperation.name = neuronRequest.neuronOperation.name
            neuronRequestLocal.neuronTarget.name = neuronRequest.neuronTarget.name
            neuronRequestLocal.neuronOperation.parent = true
            neuronRequestLocal.neuronOperation.neuronData.type = neuronRequest.neuronOperation.neuronData.type
            neuronRequestLocal.neuronOperation.neuronData.dataOperationName = neuronRequest.neuronOperation.neuronData.dataOperationName
            neuronRequestLocal.neuronOperation.neuronData.text = neuronRequest.neuronOperation.neuronData.text
            neuronRequestLocal.neuronOperation.neuronData.binaryData = neuronRequest.neuronOperation.neuronData.binaryData
            let jsonUtility = JsonUtility<NeuronRequest>()
            let json = jsonUtility.convertAnyObjectToJson(jsonObject: neuronRequestLocal)
            
    //        let baseUrl = "http://172.20.10.6:83"
            let baseUrl = "http://192.168.1.3:83"
    //        let baseUrl = "http://127.0.0.1:83"
    //        let baseUrl = "https://63.135.170.17"
    //        let baseUrl = "https://192.168.1.142:83"
            if neuronRequest.neuronOperation.neuronData.type == "NeuronDataType.Binary" && neuronRequest.neuronOperation.neuronData.dataOperationName == "NeuronDataOperationName.Store.Binary" {
                let headers: HTTPHeaders = ["Content-Type": "multipart/form-data"]
                let data = neuronRequest.neuronOperation.neuronData.binaryData!
                neuronRequest.neuronOperation.neuronData.binaryData = nil
                
                // ********** Change it to AF.upload() in production, since only specific ip is trusted
                
                #if os(macOS)
                AF.upload(multipartFormData: {multipartFormData in
                    multipartFormData.append(json.data(using: .utf8, allowLossyConversion: false)!, withName: "Json Data", mimeType: "application/json")
                    multipartFormData.append(data, withName: "Binary Data", mimeType: "image/png")
                }, to: "\(baseUrl)/dendriteBinaryRequest", usingThreshold: UInt64.init(), method: .post, headers: headers).responseJSON(completionHandler: alamoFireResponseHandlerJsonData)
                #else
                AF.upload(multipartFormData: {multipartFormData in
                    multipartFormData.append(json.data(using: .utf8, allowLossyConversion: false)!, withName: "Json Data", mimeType: "application/json")
                    multipartFormData.append(data, withName: "Binary Data", mimeType: "image/png")
                }, to: "\(baseUrl)/dendriteBinaryRequest", usingThreshold: UInt64.init(), method: .post, headers: headers).responseJSON(completionHandler: alamoFireResponseHandlerJsonData)
                #endif
            } else {
                let parameters = try JSONSerialization.jsonObject(with: json.data(using: .utf8, allowLossyConversion: false)!) as? [String: Any]
                if neuronRequest.neuronOperation.neuronData.type == "NeuronDataType.Binary" && neuronRequest.neuronOperation.neuronData.dataOperationName == "NeuronDataOperationName.Get.Binary" {
                    
                    // ********** Change it to AF.request() in production, since only specific ip is trusted
                    
                    AF.request("\(baseUrl)/dendriteBinaryResponse", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseData { dataResponse in
                        var neuronResponse = NeuronRequest()
                        neuronResponse.neuronOperation.response = true

                        if let error = dataResponse.error {
                            print(error.localizedDescription)
                            neuronResponse.neuronOperation.response = true; neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(self.neuronUtility!.getNeuronOperationError(name: NeuronOperationErrorType.ErrorInProcessing.name, description: error.localizedDescription))
                            let neuronSource = self.neuronUtility!.getDendrite(sourceId: neuronResponse.neuronSource._id, neuronName: neuronResponse.neuronSource.name)
                            neuronSource!.setDendrite(neuronRequest: neuronResponse, udbcDatabaseOrm: self.udbcDatabaseOrm!, neuronUtility: self.neuronUtility!)
                            return
                        }

                        if dataResponse.response?.statusCode != 200 {
                            neuronResponse.neuronOperation.response = true;
                            neuronResponse = self.neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: "")
                            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(self.neuronUtility!.getNeuronOperationError(name: "\(dataResponse.response!.statusCode)", description: "HTTP Status Code: \(dataResponse.response!.statusCode). Due to limitation in HTTP interface tool, unable to give useful error message. Check with provider!"))
                            let neuronSource = self.neuronUtility!.getDendrite(sourceId: neuronResponse.neuronSource._id, neuronName: neuronResponse.neuronSource.name)
                            neuronSource!.setDendrite(neuronRequest: neuronResponse, udbcDatabaseOrm: self.udbcDatabaseOrm!, neuronUtility: self.neuronUtility!)
                            return
                        }

                        if let data = dataResponse.data {
                            neuronResponse = self.neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: "", binaryData: data)
                            let neuronSource = self.neuronUtility!.getDendrite(sourceId: neuronResponse.neuronSource._id, neuronName: neuronResponse.neuronSource.name)
                            neuronSource!.setDendrite(neuronRequest: neuronResponse, udbcDatabaseOrm: self.udbcDatabaseOrm!, neuronUtility: self.neuronUtility!)
                        }
                    }
                } else {
                    
                    // ********** Change it to AF.request() in production, since only specific ip is trusted
                    
                    AF.request("\(baseUrl)/dendrite", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON(completionHandler: alamoFireResponseHandlerJsonData)
                }
            }
        }
        
        private func getMimeType(uvcContentType: String) -> String {
            if uvcContentType == "UVCPhotoFileType.Png" {
                return "image/png"
            } else if uvcContentType == "UVCPhotoFileType.Jpeg" {
                return "image/jpeg"
            }
            
            return "application/json"
        }
        
    #if os(macOS)
        private func alamoFireResponseHandlerBinaryData(completion: DataResponse<Data, AFError>) {
            var neuronResponse = NeuronRequest()
            neuronResponse.neuronOperation.response = true
            
            if let error = completion.error {
                print(error.localizedDescription)
                neuronResponse.neuronOperation.response = true; neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(self.neuronUtility!.getNeuronOperationError(name: NeuronOperationErrorType.ErrorInProcessing.name, description: error.localizedDescription))
                let neuronSource = self.neuronUtility!.getDendrite(sourceId: neuronResponse.neuronSource._id, neuronName: neuronResponse.neuronSource.name)
                neuronSource!.setDendrite(neuronRequest: neuronResponse, udbcDatabaseOrm: udbcDatabaseOrm!, neuronUtility: self.neuronUtility!)
                return
            }
            
            if let data = completion.data {
                neuronResponse.neuronOperation.neuronData.binaryData = data
                let neuronSource = self.neuronUtility!.getDendrite(sourceId: neuronResponse.neuronSource._id, neuronName: neuronResponse.neuronSource.name)
                neuronSource!.setDendrite(neuronRequest: neuronResponse, udbcDatabaseOrm: udbcDatabaseOrm!, neuronUtility: self.neuronUtility!)
            }
            neuronResponse = NeuronRequest()
        }
    #else
    private func alamoFireResponseHandlerBinaryData(completion: DataResponse<Data, AFError>) {
        var neuronResponse = NeuronRequest()
        neuronResponse.neuronOperation.response = true
        
        if let error = completion.error {
            print(error.localizedDescription)
            neuronResponse.neuronOperation.response = true; neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(self.neuronUtility!.getNeuronOperationError(name: NeuronOperationErrorType.ErrorInProcessing.name, description: error.localizedDescription))
            let neuronSource = self.neuronUtility!.getDendrite(sourceId: neuronResponse.neuronSource._id, neuronName: neuronResponse.neuronSource.name)
            neuronSource!.setDendrite(neuronRequest: neuronResponse, udbcDatabaseOrm: udbcDatabaseOrm!, neuronUtility: self.neuronUtility!)
            return
        }
        
        if let data = completion.data {
            neuronResponse.neuronOperation.neuronData.binaryData = data
            let neuronSource = self.neuronUtility!.getDendrite(sourceId: neuronResponse.neuronSource._id, neuronName: neuronResponse.neuronSource.name)
            neuronSource!.setDendrite(neuronRequest: neuronResponse, udbcDatabaseOrm: udbcDatabaseOrm!, neuronUtility: self.neuronUtility!)
        }
        neuronResponse = NeuronRequest()
    }
    #endif
    #if os(macOS)
        private func alamoFireResponseHandlerJsonData(completion: DataResponse<Any, AFError>) {
            var neuronResponse = NeuronRequest()
            neuronResponse.neuronOperation.response = true
            
            do {
                if let error = completion.error {
                    print(error.localizedDescription)
                    neuronResponse.neuronOperation.response = true; neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(self.neuronUtility!.getNeuronOperationError(name: NeuronOperationErrorType.ErrorInProcessing.name, description: error.localizedDescription))
                    let neuronSource = self.neuronUtility!.getDendrite(sourceId: neuronResponse.neuronSource._id, neuronName: "CallBrainControllerNeuron")
                    neuronSource!.setDendrite(neuronRequest: neuronResponse, udbcDatabaseOrm: udbcDatabaseOrm!, neuronUtility: self.neuronUtility!)
                    return
                }
                
                 let json = try completion.result.get()
                    let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                    
                    if let jsonString = String(bytes: jsonData, encoding: String.Encoding.utf8) {
                        let jsonUtility = JsonUtility<NeuronRequest>()
                        let neuronResponseLocal = jsonUtility.convertJsonToAnyObject(json: jsonString)
                        neuronResponse = self.neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronResponseLocal, responseText: neuronResponseLocal.neuronOperation.neuronData.text)
                        let neuronSource = self.neuronUtility!.getDendrite(sourceId: neuronResponseLocal.neuronSource._id, neuronName: neuronResponseLocal.neuronSource.name)
                        neuronSource!.setDendrite(neuronRequest: neuronResponseLocal, udbcDatabaseOrm: udbcDatabaseOrm!, neuronUtility: self.neuronUtility!)
                    }
                    
                
               
            } catch {
                neuronResponse.neuronOperation.response = true; neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(self.neuronUtility!.getNeuronOperationError(name: NeuronOperationErrorType.ErrorInProcessing.name, description: error.localizedDescription))
                
            }
            neuronResponse = NeuronRequest()
        }
    #else
    private func alamoFireResponseHandlerJsonData(completion: DataResponse<Any, AFError>) {
               var neuronResponse = NeuronRequest()
               neuronResponse.neuronOperation.response = true
               
               do {
                   if let error = completion.error {
                       print(error.localizedDescription)
                       neuronResponse.neuronOperation.response = true; neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(self.neuronUtility!.getNeuronOperationError(name: NeuronOperationErrorType.ErrorInProcessing.name, description: error.localizedDescription))
                       let neuronSource = self.neuronUtility!.getDendrite(sourceId: neuronResponse.neuronSource._id, neuronName: "CallBrainControllerNeuron")
                       neuronSource!.setDendrite(neuronRequest: neuronResponse, udbcDatabaseOrm: udbcDatabaseOrm!, neuronUtility: self.neuronUtility!)
                       return
                   }
                   
                    let json = try completion.result.get()
                       let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                       
                       if let jsonString = String(bytes: jsonData, encoding: String.Encoding.utf8) {
                           let jsonUtility = JsonUtility<NeuronRequest>()
                           let neuronResponseLocal = jsonUtility.convertJsonToAnyObject(json: jsonString)
                           neuronResponse = self.neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronResponseLocal, responseText: neuronResponseLocal.neuronOperation.neuronData.text)
//                            neuronResponseLocal.neuronOperation.response = true
                           let neuronSource = self.neuronUtility!.getDendrite(sourceId: neuronResponseLocal.neuronSource._id, neuronName: neuronResponseLocal.neuronSource.name)
                            neuronSource!.setDendrite(neuronRequest: neuronResponseLocal, udbcDatabaseOrm: udbcDatabaseOrm!, neuronUtility: self.neuronUtility!)
                       }
                       
                   
                  
               } catch {
                   neuronResponse.neuronOperation.response = true; neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(self.neuronUtility!.getNeuronOperationError(name: NeuronOperationErrorType.ErrorInProcessing.name, description: error.localizedDescription))
                   
               }
               neuronResponse = NeuronRequest()
           }
    #endif
    //        private func alamoFireResponseHandlerBinaryData(completion: DataResponse<Any, AFError>) {
    //            var neuronResponse = NeuronRequest()
    //            neuronResponse.neuronOperation.response = true
    //
    //            if let error = completion.error {
    //                print(error.localizedDescription)
    //                neuronResponse.neuronOperation.response = true; neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility.getNeuronOperationError(name: NeuronOperationErrorType.ErrorInProcessing.name, description: error.localizedDescription))
    //                let neuronSource = NeuronUtility.getDendrite(sourceId: neuronResponse.neuronSource._id, neuronName: neuronResponse.neuronSource.name)
    //                neuronSource.setDendrite(neuronRequest: neuronResponse, udbcDatabaseOrm: udbcDatabaseOrm!)
    //                return
    //            }
    //
    //            if let data = completion.data {
    //                neuronResponse.neuronOperation.neuronData.binaryData = data
    //                let neuronSource = NeuronUtility.getDendrite(sourceId: neuronResponse.neuronSource._id, neuronName: neuronResponse.neuronSource.name)
    //                neuronSource.setDendrite(neuronRequest: neuronResponse, udbcDatabaseOrm: udbcDatabaseOrm!)
    //            }
    //            neuronResponse = NeuronRequest()
    //        }
    //
    //        private func alamoFireResponseHandlerJsonData(completion: DataResponse<Any, AFError>) {
    //            var neuronResponse = NeuronRequest()
    //            neuronResponse.neuronOperation.response = true
    //
    //            do {
    //                if let error = completion.error {
    //                    print(error.localizedDescription)
    //                    neuronResponse.neuronOperation.response = true; neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility.getNeuronOperationError(name: NeuronOperationErrorType.ErrorInProcessing.name, description: error.localizedDescription))
    //                    let neuronSource = NeuronUtility.getDendrite(sourceId: neuronResponse.neuronSource._id, neuronName: CallBrainControllerNeuron.getName())
    //                    neuronSource.setDendrite(neuronRequest: neuronResponse, udbcDatabaseOrm: udbcDatabaseOrm!)
    //                    return
    //                }
    //
    //                let json = try completion.result.get()
    //                let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
    //
    //                if let jsonString = String(bytes: jsonData, encoding: String.Encoding.utf8) {
    //                    let jsonUtility = JsonUtility<NeuronRequest>()
    //                    let neuronResponseLocal = jsonUtility.convertJsonToAnyObject(json: jsonString)
    //                    neuronResponse = neuronUtility.getNeuronResponseSuccess(neuronRequest: neuronResponseLocal, responseText: neuronResponseLocal.neuronOperation.neuronData.text)
    //                    let neuronSource = NeuronUtility.getDendrite(sourceId: neuronResponseLocal.neuronSource._id, neuronName: neuronResponseLocal.neuronSource.name)
    //                    neuronSource.setDendrite(neuronRequest: neuronResponseLocal, udbcDatabaseOrm: udbcDatabaseOrm!)
    //                }
    //
    //
    //
    //            } catch {
    //                neuronResponse.neuronOperation.response = true; neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility.getNeuronOperationError(name: NeuronOperationErrorType.ErrorInProcessing.name, description: error.localizedDescription))
    //
    //            }
    //            neuronResponse = NeuronRequest()
    //        }
    
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
    
    
    
    private func setChildResponse(sourceId: String, neuronRequest: NeuronRequest) {
        responseMap[sourceId] = neuronRequest
    }
    
    private func getChildResponse(sourceId: String) -> NeuronRequest {
        var neuronResponse: NeuronRequest?
        print(responseMap)
        if let _ = responseMap[sourceId] {
            neuronResponse = responseMap[sourceId]
            responseMap.removeValue(forKey: sourceId)
            print("Removed response for operation: \(sourceId)")
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
        
        self.neuronUtility = neuronUtility
        var neuronResponse =  NeuronRequest()
        
        
        var neuronRequestLocal = neuronRequest
        do {
            self.neuronUtility!.setUDBCDatabaseOrm(udbcDatabaseOrm: udbcDatabaseOrm, neuronName: BrainControllerNeuron.getName())
            
            
            let continueProcess = try preProcess(neuronRequest: neuronRequestLocal, neuronResponse: &neuronResponse)
            if continueProcess == false {
                print("\(BrainControllerNeuron.getName()): don't process return")
                return
            }
            validateRequest(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            
            if neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError!.count > 0 {
                print("\(BrainControllerNeuron.getName()) error in validation return")
                let neuronSource = self.neuronUtility!.getDendrite(sourceId: neuronRequest.neuronSource._id, neuronName: neuronRequest.neuronSource.name)
                neuronSource!.setDendrite(neuronRequest: neuronResponse, udbcDatabaseOrm: self.udbcDatabaseOrm!, neuronUtility: neuronUtility)
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
                    self.neuronUtility!.storeInDatabase(neuronRequest: neuronRequest)
                    return
                } else {
                    if neuronRequest.neuronOperation.synchronus == true {
                        if neuronRequest.neuronOperation.asynchronusProcess == true {
                            print("\(BrainControllerNeuron.getName()) asynchronus so update the status as pending")
                            let rows = try NeuronRequest.update(udbcDatabaseOrm: udbcDatabaseOrm, id: (neuronRequest._id), status: NeuronOperationStatusType.InProgress.name)
                        }
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
            print("\(BrainControllerNeuron.getName()): Error thrown in setdendrite: \(error)")
            neuronResponse.neuronOperation.response = true
            let neuronOperationError = NeuronOperationError()
            neuronOperationError.name = NeuronOperationErrorType.ErrorInProcessing.name
            neuronOperationError.description = error.localizedDescription
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronOperationError)
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
        print("\(BrainControllerNeuron.getName()): pre process")
        
        print("neuronUtility: pre process: \(neuronRequest.neuronSource._id)")
        let neuronRequestLocal: NeuronRequest = neuronRequest
        
        if neuronRequestLocal.neuronOperation.acknowledgement == true {
            print("\(BrainControllerNeuron.getName()) acknowledgement so return")
            return false
        }
        
        if neuronRequestLocal.neuronOperation.response == true {
            setChildResponse(sourceId: neuronRequestLocal.neuronSource._id, neuronRequest: neuronRequest)
            print("\(BrainControllerNeuron.getName()) response so return")
            return false
        }
        
        neuronResponse.neuronSource._id = neuronRequest.neuronSource._id
        neuronResponse.neuronOperation._id = neuronRequest.neuronOperation._id
        
        
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
            print("\(BrainControllerNeuron.getName()) got response so return")
            return false
        }
        
        return true
    }
    
    
    
    private func postProcess(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) {
        print("\(BrainControllerNeuron.getName()): post process")
        
        
        
        if neuronRequest.neuronOperation.asynchronusProcess == true {
            print("\(BrainControllerNeuron.getName()) Asynchronus so storing response in database")
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
        print("\(BrainControllerNeuron.getName()) Informing: \(String(describing: neuronRequest.neuronSource.name))")
        let neuronSource = neuronUtility!.getDendrite(sourceId: neuronRequest.neuronSource._id, neuronName: neuronRequest.neuronSource.name)
        neuronSource!.setDendrite(neuronRequest: neuronResponse, udbcDatabaseOrm: self.udbcDatabaseOrm!, neuronUtility: self.neuronUtility!)
        
        
        defer {
            BrainControllerNeuron.removeDendrite(sourceId: neuronRequest.neuronSource._id)
            print("brain controller neuron RESPONSE MAP: \(responseMap)")
            print("brain controller  Dendrite MAP: \(BrainControllerNeuron.dendriteMap)")
            
        }
        
    }
    
}
