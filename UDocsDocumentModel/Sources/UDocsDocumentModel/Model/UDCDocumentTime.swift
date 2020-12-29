//
//  UDCDocumentTime.swift
//  Universe Docs Document
//
//  Created by Kumar Muthaiah on 11/02/19.
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


public class UDCDocumentTime : Codable {
    public var _id: String = ""
    public var creationTime: Date?
    public var createdBy: String = ""
    public var changedTime: Date?
    public var changedBy: String?
    public var removedTime: Date?
    public var removedBy: String?
    public var language: String = ""
    
    public init() {
        
    }
    
    
    static public func getName() -> String {
        return "UDCDocumentTime"
    }
    
    static public func get(udbcDatabaseOrm: UDBCDatabaseOrm, id: String, language: String) -> DatabaseOrmResult<UDCDocumentTime> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        
        return databaseOrm.find(collectionName: UDCDocumentTime.getName(), dictionary: ["_id": id, "language": language], limitedTo: 0) as DatabaseOrmResult<UDCDocumentTime>
        
    }
    
    static public func update<T: Codable>(udbcDatabaseOrm: UDBCDatabaseOrm, object: T) -> DatabaseOrmResult<T> {
        let udcDocumentTime = object as! UDCDocumentTime
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return DatabaseOrm.update(collectionName: UDCDocumentTime.getName(), id: udcDocumentTime._id, object: object )
        
    }
    
    
    static public func update<T: Codable>(udbcDatabaseOrm: UDBCDatabaseOrm, id: String, changedTime: Date, changedBy: String) -> DatabaseOrmResult<T> {
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return DatabaseOrm.update(collectionName: UDCDocumentTime.getName(), whereDictionary: ["_id": id], setDictionary: ["changedTime": changedTime, "changedBy": changedBy])
        
    }
    static public func save<T: Codable>(udbcDatabaseOrm: UDBCDatabaseOrm, object: T) -> DatabaseOrmResult<T> {
        
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return DatabaseOrm.save(collectionName: UDCDocumentTime.getName(), object: object )
        
    }
    
}
