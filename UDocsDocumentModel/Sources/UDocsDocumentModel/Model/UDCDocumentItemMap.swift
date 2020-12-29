//
//  UDCDocumentItemMapMap.swift
//  Universe_Docs_Document
//
//  Created by Kumar Muthaiah on 16/12/18.
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
import UDocsDatabaseModel
import UDocsDatabaseUtility
import UDocsDatabaseUtility

public class UDCDocumentItemMap : Codable {
    public var _id: String = ""
    public var idName: String = ""
    public var name: String = ""
    public var udcDocumentItemMapNodeId = [String]()
    public var language: String = ""
    public var udcProfile = [UDCProfile]()

    public init() {
        
    }

    static public func getName() -> String {
        return "UDCDocumentItemMap"
    }
    
    static public func get(udbcDatabaseOrm: UDBCDatabaseOrm, id: String, language: String) -> DatabaseOrmResult<UDCDocumentItemMap> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        
        return databaseOrm.find(collectionName: UDCDocumentItemMap.getName(), dictionary: ["_id": id, "language": language], limitedTo: 0) as DatabaseOrmResult<UDCDocumentItemMap>
        
    }
    
    static public func get(udbcDatabaseOrm: UDBCDatabaseOrm, name: String, language: String) -> DatabaseOrmResult<UDCDocumentItemMap> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        
        return databaseOrm.find(collectionName: UDCDocumentItemMap.getName(), dictionary: ["idName": name, "language": language], limitedTo: 0) as DatabaseOrmResult<UDCDocumentItemMap>
        
    }
    
    static public func get(udbcDatabaseOrm: UDBCDatabaseOrm, idName: String, udcProfile: [UDCProfile], language: String) -> DatabaseOrmResult<UDCDocumentItemMap> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm

        var all = [[String: Any]]()
        for udcp in udcProfile {
            if udcp.udcProfileItemIdName != "UDCProfileItem.Human" {
                let element: [String: Any] = ["udcProfileItemIdName": udcp.udcProfileItemIdName, "profileId": udcp.profileId]
                let elementMatch: [String: Any] = ["$elemMatch": element]
                all.append(elementMatch)
            }
        }
        let udcProfileAll: [String: Any] = ["$all": all]
        return databaseOrm.find(collectionName: UDCDocumentItemMap.getName(), dictionary: ["idName": idName, "udcProfile": udcProfileAll, "language": language], limitedTo: 0) as DatabaseOrmResult<UDCDocumentItemMap>
        
    }
    
    static public func save<T: Codable>(udbcDatabaseOrm: UDBCDatabaseOrm, object: T) -> DatabaseOrmResult<T> {
        
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return DatabaseOrm.save(collectionName: UDCDocumentItemMap.getName(), object: object )
        
    }
    
    
    static public func update<T: Codable>(udbcDatabaseOrm: UDBCDatabaseOrm, object: T) -> DatabaseOrmResult<T> {
        let udcRecipe = object as! UDCDocumentItemMap
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return DatabaseOrm.update(collectionName: UDCDocumentItemMap.getName(), id: udcRecipe._id, object: object )
        
    }
}
