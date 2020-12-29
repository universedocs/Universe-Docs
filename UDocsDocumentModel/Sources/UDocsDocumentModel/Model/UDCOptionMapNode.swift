//
//  UDCOptionMapNode.swift
//  Universe Docs Document
//
//  Created by Kumar Muthaiah on 03/02/19.
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

public class UDCOptionMapNode : Codable {
    public var _id: String = ""
    public var idName: String = ""
    public var name: String = ""
    public var udcSentencePattern: UDCSentencePattern?
    public var description: String = ""
    public var udcAnalytic = [UDCAnalytic]()
    public var objectId = [String]()
    public var objectName: String = ""
    public var parentId = [String]()
    public var childrenId = [String]()
    public var level: Int = 0
    public var language: String = "en"
    public var path = [[String]]()
    public var pathIdName = [[String]]()
    
    public init() {
        
    }
    
    static public func getName() -> String {
        return "UDCOptionMapNode"
    }
    
    static public func get(udbcDatabaseOrm: UDBCDatabaseOrm, id: String, language: String) -> DatabaseOrmResult<UDCOptionMapNode> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        
        return databaseOrm.find(collectionName: UDCOptionMapNode.getName(), dictionary: ["_id": id, "language": language], limitedTo: 0) as DatabaseOrmResult<UDCOptionMapNode>
        
    }
    
    static public func get(udbcDatabaseOrm: UDBCDatabaseOrm, pathText: String, language: String) -> DatabaseOrmResult<UDCOptionMapNode> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        let path = pathText.components(separatedBy: "->")
        return databaseOrm.find(collectionName: UDCOptionMapNode.getName(), dictionary: ["path": path, "language": language], limitedTo: 0) as DatabaseOrmResult<UDCOptionMapNode>
        
    }
    
    
    static public func save<T: Codable>(udbcDatabaseOrm: UDBCDatabaseOrm, object: T) -> DatabaseOrmResult<T> {
        
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return DatabaseOrm.save(collectionName: UDCOptionMapNode.getName(), object: object )
        
    }
    
    static public func update<T: Codable>(udbcDatabaseOrm: UDBCDatabaseOrm, object: T) -> DatabaseOrmResult<T> {
        let UDCOptionMapNode = object as! UDCOptionMapNode
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return DatabaseOrm.update(collectionName: getName(), id: UDCOptionMapNode._id, object: object )
        
    }
    
    static public func remove<T: Codable>(udbcDatabaseOrm: UDBCDatabaseOrm, id: String) -> DatabaseOrmResult<T> {
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return DatabaseOrm.remove(collectionName: UDCOptionMapNode.getName(), id: id)
        
    }
    
    
    public static func get(_ idName: String, _ udbcDatabaseOrm: UDBCDatabaseOrm, _ language: String = "en") -> DatabaseOrmResult<UDCOptionMapNode> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        let databaseOrmResult = databaseOrm.find(collectionName: getName(), dictionary: ["idName": idName,"language": language], limitedTo: Int(0.0)) as DatabaseOrmResult<UDCOptionMapNode>
        return databaseOrmResult
    }
    
    static public func update<T: Codable>(udbcDatabaseOrm: UDBCDatabaseOrm, id: String, documentId: String, name: String) -> DatabaseOrmResult<T> {
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return DatabaseOrm.update(collectionName: UDCOptionMapNode.getName(), whereDictionary: ["_id": id], setDictionary:   ["documentId": documentId, "name": name])
        
    }
    
}
