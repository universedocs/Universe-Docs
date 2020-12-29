//
//  NeuronRequest.swift
//  SoftwareBrainController
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
import UDocsUtility
import UDocsDatabaseModel
import UDocsDatabaseUtility

open class NeuronRequest : Codable {
    public var _id: String = ""
    public var neuronSource: NeuronSource = NeuronSource()
    public var neuronTarget: NeuronTarget = NeuronTarget()
    public var neuronOperation: NeuronOperation = NeuronOperation()
   
    public init() {
        
    }
    static private func getName() -> String {
        return "NeuronRequest"
    }
    
    static public func save<T: Codable>(udbcDatabaseOrm: UDBCDatabaseOrm, object: T) -> DatabaseOrmResult<T> {
            let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return databaseOrm.save(collectionName: NeuronRequest.getName(), object: object )
      
    }
    
    static public func get(udbcDatabaseOrm: UDBCDatabaseOrm, query: [String: Any], limitedTo: Int?) -> DatabaseOrmResult<NeuronRequest> {
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm

        return  DatabaseOrm.find(collectionName: NeuronRequest.getName(), dictionary: query, limitedTo: limitedTo) as DatabaseOrmResult<NeuronRequest>
    }
    
    static public func update(udbcDatabaseOrm: UDBCDatabaseOrm, id: String, status: String) -> DatabaseOrmResult<NeuronRequest> {
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        let whereDocument: [String: Any] =  [
                "_id": id]
        let setDocument: [String: Any] = ["neuronOperation.neuronOperationStatus.status": status]
        return DatabaseOrm.update(collectionName: NeuronRequest.getName(), whereDictionary:  whereDocument, setDictionary:  setDocument)
    }
    
    static public func get(udbcDatabaseOrm: UDBCDatabaseOrm, targetName: String, operationId: String) -> DatabaseOrmResult<NeuronRequest> {
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        let filter: [String: Any] =  ["$and":
            [
                ["neuronTarget.name": ["$eq": targetName]],
                ["neuronOperation.id": ["$eq": operationId]]
            ]]
        
        let databaseOrmResult = DatabaseOrm.find(collectionName: NeuronRequest.getName(), dictionary:  filter, limitedTo: Int(1.0), sortOrder: UDBCSortOrder.Descending.name) as DatabaseOrmResult<NeuronRequest>
        if databaseOrmResult.object.count == 0 {
            let databaseOrmError = DatabaseOrmError()
            databaseOrmError.name = "NeuronRequest.TargetNotFound"
            databaseOrmError.description = "Target Not Found"
            databaseOrmResult.databaseOrmError.append(databaseOrmError)
            return databaseOrmResult
        }
        for object in databaseOrmResult.object {
            let objectId = object.neuronOperation.neuronData.objectId
            let collectionName = object.neuronOperation.neuronData.type
            let databaseOrmResultObject = DatabaseOrm.find(collectionName: collectionName, dictionary: [ "_id": objectId], limitedTo: 0) as DatabaseOrmResult<NeuronRequest>
            if databaseOrmResult.object.count == 0 {
                let databaseOrmError = DatabaseOrmError()
                databaseOrmError.name = "NeuronRequest.ObjectNotFound"
                databaseOrmError.description = "Object not found for request"
                databaseOrmResult.databaseOrmError.append(databaseOrmError)
                return databaseOrmResult
            }
            let jsonUtility = JsonUtility<NeuronRequest>()
            object.neuronOperation.neuronData.text = jsonUtility.convertAnyObjectToJson(jsonObject: databaseOrmResultObject.object[0])
        }


        return databaseOrmResult
    }
    
    public func getOperationsFromDatabase(udbcDatabaseOrm: UDBCDatabaseOrm, targetName: String, limitedTo: Int?) -> DatabaseOrmResult<NeuronRequest> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        let filter: [String: Any] =  ["$and":
            [
                ["neuronTarget.name": ["$eq": targetName]]
            ]]

        let databaseOrmResult = databaseOrm.find(collectionName: NeuronRequest.getName(), dictionary:  filter, limitedTo: limitedTo, sortOrder: UDBCSortOrder.Ascending.name) as DatabaseOrmResult<NeuronRequest>
        
        return databaseOrmResult
    }
    
    // **** Don't delete the below one it is required for later use
//
//    public func get(udbcDatabaseOrm: udbcDatabaseOrm) throws ->DatabaseOrmResult {
//        let databaseOrmResult: DatabaseOrmResult = DatabaseOrmResult()
//        do {
//            let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
//            let aggregateDictionary: [Dictionary<String, String>] = [
//                ["collectionName": "NeuronSource", "localField": "neuronSourceId", "foreignField": "_id", "as": "NeuronSource"],
//                ["collectionName": "NeuronGroup", "localField": "NeuronSource.neuronGroupId", "foreignField": "_id", "as": "NeuronSource.NeuronGroup"]
//            ]
//            let unwind: [String] = [
//                "NeuronSource"
//            ]
//            let cursor = try databaseOrm.find(collectionName: "NeuronRequest", unwind: unwind, aggregateDictionary: aggregateDictionary)
//
//            for document in cursor {
//                let jsonUtility: JsonUtility = JsonUtility<Document>()
//                print(jsonUtility.convertAnyObjectToJson(jsonObject: document))
//            }
//        } catch {
//            print(error)
//            throw error
//        }
//
//        return databaseOrmResult
//    }
//
    
}
