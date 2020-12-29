//
//  UDCDocumentGraphModelType.swift
//  Universe Docs Document
//
//  Created by Kumar Muthaiah on 18/02/19.
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

public class UDCDocumentGraphModelType : Codable {
    public var _id: String = ""
    public var idName: String = ""
    public var name: String = ""
    public var objectId: String = ""
    public var objectName: String = ""
    public var udcSentencePattern = UDCSentencePattern()
    public var pathIdName = [[String]]()
    public var childrenId = [String]()
    public var language: String = ""
    
    public init() {
        
    }
    
    static public func getName() -> String {
        return "UDCDocumentGraphModelType"
    }
    
    public static func get(collectionName: String, udbcDatabaseOrm: UDBCDatabaseOrm, id: String, language: String) -> DatabaseOrmResult<UDCDocumentGraphModelType> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        
        return databaseOrm.find(collectionName: collectionName, dictionary: ["_id": id, "language": language], limitedTo: 0) as DatabaseOrmResult<UDCDocumentGraphModelType>
        
    }
    
    public static func get(collectionName: String, idName: String, _ udbcDatabaseOrm: UDBCDatabaseOrm, _ language: String = "en") -> DatabaseOrmResult<UDCDocumentGraphModelType> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        let databaseOrmResult = databaseOrm.find(collectionName: collectionName, dictionary: ["idName": idName,"language": language], limitedTo: Int(0.0)) as DatabaseOrmResult<UDCDocumentGraphModelType>
        return databaseOrmResult
    }
    
    public static func get(collectionName: String, greaterThenDescription: String, limitedTo: Int, sortedBy: String,   udbcDatabaseOrm: UDBCDatabaseOrm, language: String = "en") -> DatabaseOrmResult<UDCDocumentGraphModelType> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return databaseOrm.find(collectionName: collectionName, dictionary: ["$and":
            [
                ["description": ["$gt": greaterThenDescription]],
                ["language": language]
            ]], projection: ["idName", "name", "udcSentencePattern", "pathIdName", "language", "childrenId", "objectId", "objectName"], limitedTo: limitedTo, sortOrder: "UDBCSortOrder.Ascending", sortedBy: sortedBy) as DatabaseOrmResult<UDCDocumentGraphModelType>
    }
    
    public static func get(collectionName: String, limitedTo: Int, sortedBy: String,  udbcDatabaseOrm: UDBCDatabaseOrm, language: String = "en") -> DatabaseOrmResult<UDCDocumentGraphModelType> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return databaseOrm.find(collectionName: collectionName, dictionary: ["language": language], projection: ["idName", "name", "udcSentencePattern", "pathIdName", "language", "childrenId", "objectId", "objectName"], limitedTo: limitedTo, sortOrder: "UDBCSortOrder.Ascending", sortedBy: sortedBy) as DatabaseOrmResult<UDCDocumentGraphModelType>
    }
    
    public static func get(collectionName: String, idName: String, limitedTo: Int, sortedBy: String,  udbcDatabaseOrm: UDBCDatabaseOrm, language: String = "en") -> DatabaseOrmResult<UDCDocumentGraphModelType> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return databaseOrm.find(collectionName: collectionName, dictionary: ["language": language, "idName": idName], projection: ["idName", "name", "udcSentencePattern", "pathIdName", "language", "childrenId", "objectId", "objectName"], limitedTo: limitedTo, sortOrder: "UDBCSortOrder.Ascending", sortedBy: sortedBy) as DatabaseOrmResult<UDCDocumentGraphModelType>
    }
    
    public static func search(collectionName: String, text: String, udbcDatabaseOrm: UDBCDatabaseOrm, language: String = "en") throws -> DatabaseOrmResult<UDCDocumentGraphModelType> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        
        let databaseOrmResult = databaseOrm.find(collectionName: collectionName, dictionary: [
            
            "language": language,
            "name": try NSRegularExpression(pattern: text, options: .allowCommentsAndWhitespace)
            ], projection: ["idName", "name", "udcSentencePattern", "pathIdName", "language", "childrenId", "objectId", "objectName"], limitedTo: 0, sortOrder: "UDBCSortOrder.Ascending", sortedBy: "name") as DatabaseOrmResult<UDCDocumentGraphModelType>
        
        return databaseOrmResult
    }
    
    public static func getOne(collectionName: String, _ name: String, _ udbcDatabaseOrm: UDBCDatabaseOrm, _ language: String = "en") -> DatabaseOrmResult<UDCDocumentGraphModelType> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        let databaseOrmResult = databaseOrm.find(collectionName: collectionName, dictionary: ["name": name,"language": language], limitedTo: Int(0.0)) as DatabaseOrmResult<UDCDocumentGraphModelType>
        //        if databaseOrmResult.object.count > 0 {
        //            data[name+"."+language] = databaseOrmResult.object[0]
        //        }
        return databaseOrmResult
    }
}
