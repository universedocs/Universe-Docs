//
//  NeuronUtility.swift
//  COpenSSL
//
//  Created by Kumar Muthaiah on 05/10/18.
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
import UDocsNeuronModel

/*
 * Author: Kumar Muthaiah
 */
public protocol NeuronUtility  {
    var neuronName: String { get set }
    var udbcDatabaseOrm: UDBCDatabaseOrm? { get set }
    
    func callNeuron(neuronRequest: NeuronRequest) -> Bool
    func getNeuronName(udcDocumentTypeIdName: String) -> String?
    func getCollectionName(udcDocumentTypeIdName: String) -> String?
    func getDocumentType(collectionName: String) -> String?
    func callNeuron(neuronRequest: NeuronRequest, udcDocumentTypeIdName: String) -> Bool
    func getDendrite(sourceId: String, neuronName: String) -> Neuron?
    func setUDBCDatabaseOrm(udbcDatabaseOrm: UDBCDatabaseOrm, neuronName: String)
    func setUNCMain( neuronName: String)
    func getNeuronOperationSuccess(name: String, description: String) -> NeuronOperationSuccess
    func getNeuronOperationError(name: String, description: String) -> NeuronOperationError
    func getNeuronResponse<T : Codable>(object: T) -> String
    func getNeuronRequest<T : Codable>(json: String, object: T) -> T
    func getNeuronAcknowledgement(neuronRequest: NeuronRequest) -> NeuronRequest
    func getNeuronResponseSuccess(neuronRequest: NeuronRequest, responseText: String) -> NeuronRequest
    func getNeuronResponseSuccess(neuronRequest: NeuronRequest, responseText: String, binaryData: Data) -> NeuronRequest
    func getNeuronResponseError(neuronRequest: NeuronRequest, errorName: String, errorDescription: String) -> NeuronRequest
    func getNeuronResponseNone(neuronRequest: NeuronRequest) -> NeuronRequest
    func validateRequest(neuronRequest: NeuronRequest) -> NeuronRequest
    func isNeuronOperationError(neuronResponse: NeuronRequest) -> Bool
    func isNeuronOperationSuccess(neuronResponse: NeuronRequest) -> Bool
    func isNeuronOperationWarning(neuronResponse: NeuronRequest) -> Bool
    func storeInDatabase(neuronRequest: NeuronRequest) -> DatabaseOrmResult<NeuronRequest>
    func getFromDatabase(neuronRequest: NeuronRequest) -> DatabaseOrmResult<NeuronRequest>
    func getOperationsFromDatabase(neuronRequest: NeuronRequest) -> DatabaseOrmResult<NeuronRequest>
    func getNeuronOperationsFromDatabase(neuronRequest: NeuronRequest, neuronName: String) -> DatabaseOrmResult<NeuronRequest>
}
