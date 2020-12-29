//
//  UDCDocumentRecent.swift
//  Universe Docs Brain
//
//  Created by Kumar Muthaiah on 13/09/19.
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

public class UDCDocumentRecent : Codable {
    public var _id: String = ""
    public var upcHumanProfileId: String = ""
    public var upcApplicationProfileId: String = ""
    public var upcCompanyProfileId: String = ""
    public var udcDocumentId: String = ""
    public var udcDocumentTypeIdName: String = ""
    public var udcDocumentTime = UDCDocumentTime()
    
    public init() {
        
    }
    
    static public func getName() -> String {
        return "UDCDocumentRecent"
    }
    
    static public func get(udbcDatabaseOrm: UDBCDatabaseOrm, id: String, language: String) -> DatabaseOrmResult<UDCDocumentRecent> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        
        return databaseOrm.find(collectionName: getName(), dictionary: ["_id": id, "language": language], limitedTo: 0) as DatabaseOrmResult<UDCDocumentRecent>
        
    }
    
    static public func update<T: Codable>(udbcDatabaseOrm: UDBCDatabaseOrm, object: T) -> DatabaseOrmResult<T> {
        let UDCDocumentRecent = object as! UDCDocumentRecent
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return DatabaseOrm.update(collectionName: getName(), id: UDCDocumentRecent._id, object: object )
        
    }
    
    static public func remove<T: Codable>(udbcDatabaseOrm: UDBCDatabaseOrm, udcDocumentId: String) -> DatabaseOrmResult<T> {
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return DatabaseOrm.remove(collectionName: getName(), dictionary: ["udcDocumentId": udcDocumentId])
        
    }
    
    public static func get(upcHumanProfileId: String, upcApplicationProfileId: String, upcCompanyProfileId: String, limitedTo: Int, sortOrder: String, sortedBy: String,  udbcDatabaseOrm: UDBCDatabaseOrm, language: String = "en") -> DatabaseOrmResult<UDCDocumentRecent> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return databaseOrm.find(collectionName: getName(), dictionary: ["upcHumanProfileId": upcHumanProfileId, "upcApplicationProfileId": upcApplicationProfileId, "upcCompanyProfileId": upcCompanyProfileId], projection: ["upcHumanProfileId", "upcApplicationProfileId", "upcCompanyProfileId", "udcDocumentId", "udcDocumentTypeIdName", "udcDocumentTime"], limitedTo: limitedTo, sortOrder: sortOrder, sortedBy: sortedBy) as DatabaseOrmResult<UDCDocumentRecent>
    }
    
    public static func get(upcHumanProfileId: String, upcApplicationProfileId: String, upcCompanyProfileId: String, udcDocumentTypeIdName: String, limitedTo: Int, sortOrder: String, sortedBy: String,  udbcDatabaseOrm: UDBCDatabaseOrm, language: String = "en") -> DatabaseOrmResult<UDCDocumentRecent> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return databaseOrm.find(collectionName: getName(), dictionary: ["upcHumanProfileId": upcHumanProfileId, "upcApplicationProfileId": upcApplicationProfileId, "upcCompanyProfileId": upcCompanyProfileId, "udcDocumentTypeIdName": udcDocumentTypeIdName], projection: ["upcHumanProfileId", "upcApplicationProfileId", "upcCompanyProfileId", "udcDocumentId", "udcDocumentTypeIdName", "udcDocumentTime"], limitedTo: limitedTo, sortOrder: sortOrder, sortedBy: sortedBy) as DatabaseOrmResult<UDCDocumentRecent>
    }
    
    static public func save<T: Codable>(udbcDatabaseOrm: UDBCDatabaseOrm, object: T) -> DatabaseOrmResult<T> {
        
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return DatabaseOrm.save(collectionName: getName(), object: object )
        
    }
}
