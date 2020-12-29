//
//  UDCDocumentModel2.swift
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
import UDocsDatabaseUtility
import UDocsViewModel

public class UDCDocumentGraphModel : Codable {
    public var _id: String = ""
    public var idName: String = ""
    public var name: String = ""
    public var objectId: String = ""
    public var objectName: String = ""
    public var documentMapObjectId: String = ""
    public var documentMapObjectName: String = ""
    public var udcSentencePattern = UDCSentencePattern()
    public var isChildrenAllowed: Bool = false
    public var childrenId = [String]()
    public var childrenMap = [UDCChildrenMap]()
    public var parentId = [String]()
    public var level: Int = 0
    public var language: String = ""
    public var udcAnalytic = [UDCAnalytic]()
    public var udcProfile = [UDCProfile]()
    public var pathIdName = [[String]]()
    public var udcDocumentTime = UDCDocumentTime()
    public var udcViewItemCollection = UDCViewItemCollection()
    public var uvcViewItemCollection = UVCViewItemCollection()
    public var udcDocumentGraphModelReferenceId: String = ""
    
    public init() {
        
    }
    
    public func copyToChildMap(name: String) {
        for id in childrenId {
            let udcChildrenMap = UDCChildrenMap()
            udcChildrenMap.name = name
            udcChildrenMap.id = id
            childrenMap.append(udcChildrenMap)
        }
    }
    
    public func getAll(collectionName: String, udbcDatabaseOrm: UDBCDatabaseOrm) -> DatabaseOrmResult<UDCDocumentGraphModel> {
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return DatabaseOrm.getAll(collectionName: collectionName)
    }
    
    public func getSentencePatternDataGroupValue() -> [UDCSentencePatternDataGroupValue] {
        return self.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue
    }
    
    public func removeSentencePatternGroupValue(wordIndex: Int) {
        self.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.remove(at: wordIndex)
    }
    
    public func insertSentencePatternGroupValue(newValue: UDCSentencePatternDataGroupValue, wordIndex: Int) {
        self.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.insert(newValue, at: wordIndex)
    }
    
     public func insertSentencePatternGroupValue(newValue: [UDCSentencePatternDataGroupValue], wordIndex: Int) {
        self.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.insert(contentsOf: newValue, at: wordIndex)
     }
     
    public func appendSentencePatternGroupValue(newValue: UDCSentencePatternDataGroupValue) {
        self.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.append(newValue)
    }
    
    public func appendSentencePatternGroupValue(newValue: [UDCSentencePatternDataGroupValue]) {
        self.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.append(contentsOf: newValue)
    }
    
    public func getSentencePatternGroupValue(wordIndex: Int) -> UDCSentencePatternDataGroupValue {
        return self.udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[wordIndex]
    }
    
    static public func getName() -> String {
        return "UDCDocumentGraphModel"
    }

    static public func remove<T: Codable>(collectionName: String, udbcDatabaseOrm: UDBCDatabaseOrm, id: String, language: String) -> DatabaseOrmResult<T> {
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return DatabaseOrm.remove(collectionName: collectionName, dictionary: ["_id": id, "language": language])
        
    }
    
    static public func remove<T: Codable>(collectionName: String, udbcDatabaseOrm: UDBCDatabaseOrm, id: String) -> DatabaseOrmResult<T> {
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return DatabaseOrm.remove(collectionName: collectionName, dictionary: ["_id": id])
        
    }
    static public func get(collectionName: String, udbcDatabaseOrm: UDBCDatabaseOrm, id: String) -> DatabaseOrmResult<UDCDocumentGraphModel> {
           let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
           
           return databaseOrm.find(collectionName: collectionName, dictionary: ["_id": id], limitedTo: 0) as DatabaseOrmResult<UDCDocumentGraphModel>
           
       }
    static public func get(collectionName: String, udbcDatabaseOrm: UDBCDatabaseOrm, id: String, language: String) -> DatabaseOrmResult<UDCDocumentGraphModel> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        
        return databaseOrm.find(collectionName: collectionName, dictionary: ["_id": id, "language": language], limitedTo: 0) as DatabaseOrmResult<UDCDocumentGraphModel>
        
    }
    
    public static func search(collectionName: String, text: String, limitedTo: Int, sortedBy: String,   udbcDatabaseOrm: UDBCDatabaseOrm, language: String = "en", _id: [String]) throws -> DatabaseOrmResult<UDCDocumentGraphModel> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return databaseOrm.find(collectionName: collectionName, dictionary: ["_id": ["$in": _id], "language": language, "name": try NSRegularExpression(pattern: text, options: .caseInsensitive)], limitedTo: limitedTo, sortOrder: UDBCSortOrder.Ascending.name, sortedBy: sortedBy) as DatabaseOrmResult<UDCDocumentGraphModel>
    }
    
    
    public static func get(collectionName: String, text: String, limitedTo: Int, sortedBy: String,   udbcDatabaseOrm: UDBCDatabaseOrm, language: String = "en", _id: [String]) throws -> DatabaseOrmResult<UDCDocumentGraphModel> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return databaseOrm.find(collectionName: collectionName, dictionary: ["_id": ["$in": _id], "language": language, "name": text], limitedTo: limitedTo, sortOrder: UDBCSortOrder.Ascending.name, sortedBy: sortedBy) as DatabaseOrmResult<UDCDocumentGraphModel>
    }
    public static func get(collectionName: String, limitedTo: Int, sortedBy: String,   udbcDatabaseOrm: UDBCDatabaseOrm, language: String = "en", _id: [String]) throws -> DatabaseOrmResult<UDCDocumentGraphModel> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return databaseOrm.find(collectionName: collectionName, dictionary: ["_id": ["$in": _id], "language": language,], limitedTo: limitedTo, sortOrder: UDBCSortOrder.Ascending.name, sortedBy: sortedBy) as DatabaseOrmResult<UDCDocumentGraphModel>
    }

    static public func get(collectionName: String, udbcDatabaseOrm: UDBCDatabaseOrm, idName: String, language: String) -> DatabaseOrmResult<UDCDocumentGraphModel> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        
        return databaseOrm.find(collectionName: collectionName, dictionary: ["idName": idName, "language": language], limitedTo: 0) as DatabaseOrmResult<UDCDocumentGraphModel>
        
    }
    static public func get(collectionName: String, udbcDatabaseOrm: UDBCDatabaseOrm, idName: String, level: Int, language: String) -> DatabaseOrmResult<UDCDocumentGraphModel> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        
        return databaseOrm.find(collectionName: collectionName, dictionary: ["idName": idName, "level": level, "language": language], limitedTo: 0) as DatabaseOrmResult<UDCDocumentGraphModel>
        
    }
    
    static public func update<T: Codable>(collectionName: String, udbcDatabaseOrm: UDBCDatabaseOrm, object: T) -> DatabaseOrmResult<T> {
        let udcRecipe = object as! UDCDocumentGraphModel
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        
        return DatabaseOrm.update(collectionName: collectionName, id: udcRecipe._id, object: object )
        
    }
    
    static public func save<T: Codable>(collectionName: String, udbcDatabaseOrm: UDBCDatabaseOrm, object: T) -> DatabaseOrmResult<T> {
        
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return DatabaseOrm.save(collectionName: collectionName, object: object )
        
    }
    static public func update<T: Codable>(collectionName: String, udbcDatabaseOrm: UDBCDatabaseOrm, id: String, idName: String) -> DatabaseOrmResult<T> {
           let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
           return DatabaseOrm.update(collectionName: collectionName, whereDictionary: ["_id": id], setDictionary: ["idName": idName])
           
       }
    static public func updatePush<T: Codable>(collectionName: String, udbcDatabaseOrm: UDBCDatabaseOrm, id: String, childrenId: String) -> DatabaseOrmResult<T> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return  databaseOrm.updatePush(collectionName: collectionName, whereDictionary: ["_id": id], setDictionary: ["childrenId": childrenId]
        )
        
    }
    
    static public func updatePush<T: Codable>(collectionName: String, udbcDatabaseOrm: UDBCDatabaseOrm, id: String, childrenId: String, position: Int) -> DatabaseOrmResult<T> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return  databaseOrm.updatePush(collectionName: collectionName, whereDictionary: ["_id": id], key: "childrenId", values: [childrenId], position: position
        )
        
    }
    
    static public func updatePull<T: Codable>(collectionName: String, udbcDatabaseOrm: UDBCDatabaseOrm, id: String, childrenId: String) -> DatabaseOrmResult<T> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return  databaseOrm.updatePull(collectionName: collectionName, whereDictionary: ["_id": id], setDictionary: ["childrenId": childrenId]
        )
        
    }
    
}
