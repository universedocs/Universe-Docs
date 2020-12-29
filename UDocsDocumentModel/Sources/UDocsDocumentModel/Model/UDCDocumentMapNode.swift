//
//  UDCDocumentMapNode.swift
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

public class UDCDocumentMapNode : Codable {
    public var _id: String = ""
    public var idName: String = ""
    public var name: String = ""
    public var description: String = ""
    public var udcAnalytic = [UDCAnalytic]()
    // Choose default view model for the document
    public var documentId: String? = ""
    public var parentId = [String]()
    public var childrenId = [String]()
    public var level: Int = 0
    public var language: String = "en"
    public var path = [String]()
    public var pathIdName = [String]()
    public var udcDocumentType: String = ""
    public var udcDocumentAccessType = [String]()
    public var isLanguageIndependent: Bool = false
    public var isChidlrenOnDemandLoading: Bool = false
    public var isReference: Bool = false
    
    public init() {
        
    }
    
    static public func getName() -> String {
        return "UDCDocumentMapNode"
    }
    
    static public func get(udbcDatabaseOrm: UDBCDatabaseOrm, id: String, language: String) -> DatabaseOrmResult<UDCDocumentMapNode> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        
        let languageCondition: [String: Any] = ["language": language]
        let isLanguageIndependentCondition: [String: Any] = ["isLanguageIndependent": true]
        let langaugeisLanguageIndependent = [languageCondition, isLanguageIndependentCondition]
        let or: [String: Any] = ["$or": langaugeisLanguageIndependent]
        let idCondition: [String: Any] = ["_id": id]
        let andCondition = [idCondition, or] as [Any]
        let finalCondition: [String: Any] = ["$and" :andCondition]
        return databaseOrm.find(collectionName: UDCDocumentMapNode.getName(), dictionary: finalCondition, limitedTo: 0) as DatabaseOrmResult<UDCDocumentMapNode>
        
    }
    
    static public func get(udbcDatabaseOrm: UDBCDatabaseOrm, id: String) -> DatabaseOrmResult<UDCDocumentMapNode> {
       let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
       
       return databaseOrm.find(collectionName: UDCDocumentMapNode.getName(), dictionary: ["_id": id], limitedTo: 0) as DatabaseOrmResult<UDCDocumentMapNode>
       
    }
       
    static public func get(udbcDatabaseOrm: UDBCDatabaseOrm, documentId: String, language: String) -> DatabaseOrmResult<UDCDocumentMapNode> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        
        return databaseOrm.find(collectionName: UDCDocumentMapNode.getName(), dictionary: ["documentId": documentId, "language": language], limitedTo: 0) as DatabaseOrmResult<UDCDocumentMapNode>
        
    }
    
    static public func get(udbcDatabaseOrm: UDBCDatabaseOrm, idName: String, language: String) -> DatabaseOrmResult<UDCDocumentMapNode> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        
        return databaseOrm.find(collectionName: UDCDocumentMapNode.getName(), dictionary: ["idName": idName, "language": language], limitedTo: 0) as DatabaseOrmResult<UDCDocumentMapNode>
        
    }
    
    static public func save<T: Codable>(udbcDatabaseOrm: UDBCDatabaseOrm, object: T) -> DatabaseOrmResult<T> {
        
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return DatabaseOrm.save(collectionName: UDCDocumentMapNode.getName(), object: object )
        
    }
    
    static public func update<T: Codable>(udbcDatabaseOrm: UDBCDatabaseOrm, object: T) -> DatabaseOrmResult<T> {
        let udcDocumentMapNode = object as! UDCDocumentMapNode
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return DatabaseOrm.update(collectionName: UDCDocumentMapNode.getName(), id: udcDocumentMapNode._id, object: object )
        
    }
    
    static public func remove<T: Codable>(udbcDatabaseOrm: UDBCDatabaseOrm, id: String) -> DatabaseOrmResult<T> {
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return DatabaseOrm.remove(collectionName: UDCDocumentMapNode.getName(), id: id)
        
    }
    
 
    static public func update<T: Codable>(udbcDatabaseOrm: UDBCDatabaseOrm, id: String, documentId: String, name: String) -> DatabaseOrmResult<T> {
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return DatabaseOrm.update(collectionName: UDCDocumentMapNode.getName(), whereDictionary: ["_id": id], setDictionary: ["documentId": documentId, "name": name])
        
    }
    
}
