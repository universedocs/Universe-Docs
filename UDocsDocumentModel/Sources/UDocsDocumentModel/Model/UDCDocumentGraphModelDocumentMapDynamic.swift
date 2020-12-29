//
//  UDCDocumentGraphModelReference.swift
//  Universe Docs Brain
//
//  Created by Kumar Muthaiah on 12/12/19.
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

public class UDCDocumentGraphModelDocumentMapDynamic : Codable {
    public var _id: String = ""
    public var pathIdName: String = ""
    public var language: String = ""
    public var udcDocumentId: String = ""
    public var udcDocumentTypeIdName: String = ""
    public var udcDocumentAccessTypeIdName = [String]()
    public var udcProfile = [UDCProfile]()
    public var udcDocumentTime = UDCDocumentTime()
    
    public init() {
        
    }
    
    static public func save<T: Codable>(collectionName: String, udbcDatabaseOrm: UDBCDatabaseOrm, object: T) -> DatabaseOrmResult<T> {
        
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return DatabaseOrm.save(collectionName: collectionName, object: object )
        
    }
    
    static public func get(collectionName: String, udbcDatabaseOrm: UDBCDatabaseOrm, pathIdName: String, udcProfile: [UDCProfile], udcDocumentId: String, udcDocumentTypeIdName: String, language: String) -> DatabaseOrmResult<UDCDocumentGraphModelDocumentMapDynamic> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        var all = [[String: Any]]()
        for udcp in udcProfile {
            let element: [String: Any] = ["udcProfileItemIdName": udcp.udcProfileItemIdName, "profileId": udcp.profileId]
            let elementMatch: [String: Any] = ["$elemMatch": element]
            all.append(elementMatch)
        }
        let udcProfileAll: [String: Any] = ["$all": all]
        return databaseOrm.find(collectionName: collectionName, dictionary: ["pathIdName": pathIdName, "udcProfile": udcProfileAll, "udcDocumentId": udcDocumentId, "udcDocumentTypeIdName": udcDocumentTypeIdName, "language": language], limitedTo: 0, sortOrder: UDBCSortOrder.Descending.name, sortedBy: "udcDocumentTime.changedTime") as DatabaseOrmResult<UDCDocumentGraphModelDocumentMapDynamic>
        
    }
    
    static public func get(collectionName: String, udbcDatabaseOrm: UDBCDatabaseOrm, pathIdName: String, udcProfile: [UDCProfile]) -> DatabaseOrmResult<UDCDocumentGraphModelDocumentMapDynamic> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        var all = [[String: Any]]()
        for udcp in udcProfile {
            let element: [String: Any] = ["udcProfileItemIdName": udcp.udcProfileItemIdName, "profileId": udcp.profileId]
            let elementMatch: [String: Any] = ["$elemMatch": element]
            all.append(elementMatch)
        }
        let udcProfileAll: [String: Any] = ["$all": all]
        return databaseOrm.find(collectionName: collectionName, dictionary: ["pathIdName": pathIdName, "udcProfile": udcProfileAll], limitedTo: 0, sortOrder: UDBCSortOrder.Descending.name, sortedBy: "udcDocumentTime.changedTime") as DatabaseOrmResult<UDCDocumentGraphModelDocumentMapDynamic>
        
    }
    
    static public func update<T: Codable>(collectionName: String, udbcDatabaseOrm: UDBCDatabaseOrm, object: T) -> DatabaseOrmResult<T> {
        let udcRecipe = object as! UDCDocumentGraphModelDocumentMapDynamic
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        
        return DatabaseOrm.update(collectionName: collectionName, id: udcRecipe._id, object: object )
        
    }
    static public func remove<T: Codable>(collectionName: String, udbcDatabaseOrm: UDBCDatabaseOrm, udcDocumentId: String, language: String) -> DatabaseOrmResult<T> {
           let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
           return DatabaseOrm.remove(collectionName: collectionName, dictionary: ["udcDocumentId": udcDocumentId, "language": language])
           
       }
    
}
