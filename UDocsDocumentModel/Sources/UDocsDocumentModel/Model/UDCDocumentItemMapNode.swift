//
//  UDCDocumentItemMapNode.swift
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

public class UDCDocumentItemMapNode : Codable {
    public var _id: String = ""
    public var idName: String = ""
    public var name: String = ""
    public var udcDocumentTypeIdName: String = ""
    public var udcDocumentId: String = ""
    public var description: String = ""
    public var udcAnalytic = [UDCAnalytic]()
    public var objectId = [String]()
    public var objectName: String = ""
    public var parentId = [String]()
    public var childrenId = [String]()
    public var level: Int = 0
    public var language: String = "en"
    public var pathIdName = [String]()
    
    public init() {
        
    }
    
    static public func getName() -> String {
        return "UDCDocumentItemMapNode"
    }
    
    static public func get(udbcDatabaseOrm: UDBCDatabaseOrm, id: String, language: String) -> DatabaseOrmResult<UDCDocumentItemMapNode> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        
        return databaseOrm.find(collectionName: UDCDocumentItemMapNode.getName(), dictionary: ["_id": id, "language": language], limitedTo: 0) as DatabaseOrmResult<UDCDocumentItemMapNode>
        
    }
    static public func get(udbcDatabaseOrm: UDBCDatabaseOrm, id: String) -> DatabaseOrmResult<UDCDocumentItemMapNode> {
           let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
           
           return databaseOrm.find(collectionName: UDCDocumentItemMapNode.getName(), dictionary: ["_id": id], limitedTo: 0) as DatabaseOrmResult<UDCDocumentItemMapNode>
           
       }
    static public func get(udbcDatabaseOrm: UDBCDatabaseOrm, id: String, language: String, udcDocumentTypeIdName: [String]) -> DatabaseOrmResult<UDCDocumentItemMapNode> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        
        return databaseOrm.find(collectionName: UDCDocumentItemMapNode.getName(), dictionary: ["_id": id, "language": language, "udcDocumentTypeIdName": [ "$in" : udcDocumentTypeIdName]], limitedTo: 0) as DatabaseOrmResult<UDCDocumentItemMapNode>
        
    }
    static public func get(udbcDatabaseOrm: UDBCDatabaseOrm, id: [String], idName: String, language: String, udcDocumentTypeIdName: String, objectName: String) -> DatabaseOrmResult<UDCDocumentItemMapNode> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        
        return databaseOrm.find(collectionName: UDCDocumentItemMapNode.getName(), dictionary: ["_id": [ "$in" : id], "idName": idName, "language": language, "udcDocumentTypeIdName": udcDocumentTypeIdName, "objectName": objectName, "udcDocumentId": ""], limitedTo: 0) as DatabaseOrmResult<UDCDocumentItemMapNode>
        
    }
    static public func get(udbcDatabaseOrm: UDBCDatabaseOrm, id: [String], idName: String, language: String, udcDocumentTypeIdName: String, objectName: String, udcDocumentId: String) -> DatabaseOrmResult<UDCDocumentItemMapNode> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        
        return databaseOrm.find(collectionName: UDCDocumentItemMapNode.getName(), dictionary: ["_id": [ "$in" : id], "idName": idName, "language": language, "udcDocumentTypeIdName": udcDocumentTypeIdName, "objectName": objectName, "udcDocumentId": udcDocumentId], limitedTo: 0) as DatabaseOrmResult<UDCDocumentItemMapNode>
        
    }
    static public func remove(udbcDatabaseOrm: UDBCDatabaseOrm, id: [String], idName: String, language: String, udcDocumentTypeIdName: String, objectName: String, udcDocumentId: String) -> DatabaseOrmResult<UDCDocumentItemMapNode> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        
        return databaseOrm.remove(collectionName: UDCDocumentItemMapNode.getName(), dictionary: ["_id": [ "$in" : id], "idName": idName, "language": language, "udcDocumentTypeIdName": udcDocumentTypeIdName, "objectName": objectName,"udcDocumentId": udcDocumentId]) as DatabaseOrmResult<UDCDocumentItemMapNode>
        
    }
   
    static public func get(udbcDatabaseOrm: UDBCDatabaseOrm, idName: String, language: String, udcDocumentTypeIdName: String, objectName: String) -> DatabaseOrmResult<UDCDocumentItemMapNode> {
           let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
           
           return databaseOrm.find(collectionName: UDCDocumentItemMapNode.getName(), dictionary: ["idName": idName, "language": language, "udcDocumentTypeIdName": udcDocumentTypeIdName, "objectName": objectName], limitedTo: 0) as DatabaseOrmResult<UDCDocumentItemMapNode>
           
       }
    
    static public func remove<T: Codable>(udbcDatabaseOrm: UDBCDatabaseOrm, idName: String, language: String, udcDocumentTypeIdName: String, objectName: String) -> DatabaseOrmResult<T> {
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return DatabaseOrm.remove(collectionName: UDCDocumentItemMapNode.getName(), dictionary: ["idName": idName, "language": language, "udcDocumentTypeIdName": udcDocumentTypeIdName, "objectName": objectName, "udcDocumentId": ""])
        
    }
    static public func removeByDocument<T: Codable>(udbcDatabaseOrm: UDBCDatabaseOrm, idName: String, language: String, udcDocumentTypeIdName: String, objectName: String) -> DatabaseOrmResult<T> {
           let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return DatabaseOrm.remove(collectionName: UDCDocumentItemMapNode.getName(), dictionary: ["idName": idName, "language": language, "udcDocumentTypeIdName": udcDocumentTypeIdName, "objectName": objectName, "$where" : "this.udcDocumentId.length > 0"])
           
       }

    
    static public func save<T: Codable>(udbcDatabaseOrm: UDBCDatabaseOrm, object: T) -> DatabaseOrmResult<T> {
        
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return DatabaseOrm.save(collectionName: UDCDocumentItemMapNode.getName(), object: object )
        
    }
    
    static public func update<T: Codable>(udbcDatabaseOrm: UDBCDatabaseOrm, object: T) -> DatabaseOrmResult<T> {
        let udcDocumentItemMapNode = object as! UDCDocumentItemMapNode
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return DatabaseOrm.update(collectionName: getName(), id: udcDocumentItemMapNode._id, object: object )
        
    }
    
    static public func remove<T: Codable>(udbcDatabaseOrm: UDBCDatabaseOrm, id: String) -> DatabaseOrmResult<T> {
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return DatabaseOrm.remove(collectionName: UDCDocumentItemMapNode.getName(), id: id)
        
    }
    
    static public func remove<T: Codable>(udbcDatabaseOrm: UDBCDatabaseOrm, idName: String) -> DatabaseOrmResult<T> {
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return DatabaseOrm.remove(collectionName: UDCDocumentItemMapNode.getName(), dictionary: ["idName": idName])
        
    }
    
    public static func get(objectName: String, _ udbcDatabaseOrm: UDBCDatabaseOrm, _ language: String = "en") -> DatabaseOrmResult<UDCDocumentItemMapNode> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        let databaseOrmResult = databaseOrm.find(collectionName: getName(), dictionary: ["objectName": objectName,"language": language], limitedTo: Int(0.0)) as DatabaseOrmResult<UDCDocumentItemMapNode>
        return databaseOrmResult
    }
    
    public static func get(objectId: String, _ udbcDatabaseOrm: UDBCDatabaseOrm, _ language: String = "en") -> DatabaseOrmResult<UDCDocumentItemMapNode> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        let databaseOrmResult = databaseOrm.find(collectionName: getName(), dictionary: ["objectId": objectId,"language": language], limitedTo: Int(0.0)) as DatabaseOrmResult<UDCDocumentItemMapNode>
        return databaseOrmResult
    }

    public static func get(_ name: String, _ udbcDatabaseOrm: UDBCDatabaseOrm, _ language: String = "en") -> DatabaseOrmResult<UDCDocumentItemMapNode> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        let databaseOrmResult = databaseOrm.find(collectionName: getName(), dictionary: ["idName": name,"language": language], limitedTo: Int(0.0)) as DatabaseOrmResult<UDCDocumentItemMapNode>
        return databaseOrmResult
    }
    
    static public func update<T: Codable>(udbcDatabaseOrm: UDBCDatabaseOrm, id: String, documentId: String, name: String) -> DatabaseOrmResult<T> {
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return DatabaseOrm.update(collectionName: UDCDocumentItemMapNode.getName(), whereDictionary: ["_id": id], setDictionary: ["documentId": documentId, "name": name])
        
    }
    static public func updatePull<T: Codable>(udbcDatabaseOrm: UDBCDatabaseOrm, id: String, childrenId: String) -> DatabaseOrmResult<T> {
           let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return  databaseOrm.updatePull(collectionName: getName(), whereDictionary: ["_id": id], setDictionary: ["childrenId": childrenId]
           )
           
       }
    
    
    static public func update<T: Codable>(udbcDatabaseOrm: UDBCDatabaseOrm, objectId: String, name: String, idName: String) -> DatabaseOrmResult<T> {
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return DatabaseOrm.update(collectionName: UDCDocumentItemMapNode.getName(), whereDictionary: ["objectId": objectId], setDictionary: ["name": name, "idName": idName])
        
    }
    
}
