//
//  UDCTest.swift
//  UDocsDocumentModel
//
//  Created by Kumar Muthaiah on 03/10/20.
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
import UDocsDatabaseUtility
import UDocsDatabaseModel


public class UDCTest {
    public init() {
        
    }
    public func start() {
//        var databaseOrm: DatabaseOrm = MongoDatabaseOrm()
//        var udbcDatabaseOrm: UDBCDatabaseOrm = UDBCMongoDatabaseOrm()
//        do {
//            
//            let databaesOrmResult = databaseOrm.connect(userName: DatabaseOrmConnection.username, password: DatabaseOrmConnection.password, host: DatabaseOrmConnection.host, port: DatabaseOrmConnection.port, databaseName: DatabaseOrmConnection.database)
//            udbcDatabaseOrm.ormObject = databaseOrm as AnyObject
//            udbcDatabaseOrm.type = UDBCDatabaseType.MongoDatabase.rawValue
//            let databaseOrmResultUDCDocumentGraphModel = UDCDocumentGraphModel.getAll(collectionName: "UDCFoodRecipe", udbcDatabaseOrm: udbcDatabaseOrm)
//            if databaesOrmResult.databaseOrmError.count > 0 {
//                print(databaesOrmResult.databaseOrmError[0].description)
//                return
//            }
//            print("Size: \(databaseOrmResultUDCDocumentGraphModel.object.count): \(databaseOrmResultUDCDocumentGraphModel.object[databaseOrmResultUDCDocumentGraphModel.object.count - 1]._id)")
//            let udcdm = databaseOrmResultUDCDocumentGraphModel.object
//            for (modelIndex, model) in udcdm.enumerated() {
//                if model.childrenMap.count > 0 {
//                    if model.language == "en" {
//                        model.childrenMap = ["has": model.childrenId(model.language)]
//                    } else {
//                        model.childrenMap = ["உள்ளது": model.childrenId(model.language)]
//                    }
//                } else {
//                    model.removeAllChildrenId()
//                }
//                print("Saving \(modelIndex)...")
//                let result = UDCDocumentGraphModel.update(collectionName: "UDCFoodRecipe", udbcDatabaseOrm: udbcDatabaseOrm, object: model)
//                if result.databaseOrmError.count > 0 {
//                    print(result.databaseOrmError[0].description)
//                    return
//                }
//            }
//        } catch {
//            print(error)
//        }
//        
//        defer {
//            databaseOrm.disconnect()
//        }
    }
    
}
