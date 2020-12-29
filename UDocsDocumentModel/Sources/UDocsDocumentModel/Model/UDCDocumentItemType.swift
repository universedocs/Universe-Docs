//
//  UDCRecipeItemType.swift
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

public class UDCDocumentItemType : Codable {
    static private var data = [String : UDCDocumentItemType]()
    public var _id: String = ""
    public var idName: String = ""
    public var name: String = ""
    public var udcDocumentItemCategoryIdName: String = ""
    public var language: String = ""
    public var udcGrammarCategory: String = ""
    
    public init() {
        
    }
    
    public static func getName() -> String {
        return "UDCDocumentItemType"
    }
    
    public static func get(collectionName: String, id: String, _ udbcDatabaseOrm: UDBCDatabaseOrm, _ language: String = "en") -> DatabaseOrmResult<UDCDocumentItemType> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        let databaseOrmResult = databaseOrm.find(collectionName: collectionName, dictionary: ["_id": id,"language": language], limitedTo: Int(0.0)) as DatabaseOrmResult<UDCDocumentItemType>
        return databaseOrmResult
    }
    
    public static func get(collectionName: String, greaterThenDescription: String, limitedTo: Int, sortedBy: String,   udbcDatabaseOrm: UDBCDatabaseOrm, language: String = "en", _id: [String]) -> DatabaseOrmResult<UDCDocumentItemType> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return databaseOrm.find(collectionName: collectionName, dictionary: ["$and":
            [
                ["name": ["$gt": greaterThenDescription]],
                ["language": language],
                ["_id": ["$in": _id]]
            ]], projection: ["idName", "name", "language", "udcDocumentItemCategoryIdName", "udcGrammarCategory"], limitedTo: limitedTo, sortOrder: "UDBCSortOrder.Ascending", sortedBy: sortedBy) as DatabaseOrmResult<UDCDocumentItemType>
    }
    
    public static func get(collectionName: String, limitedTo: Int, sortedBy: String,  udbcDatabaseOrm: UDBCDatabaseOrm, language: String) -> DatabaseOrmResult<UDCDocumentItemType> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return databaseOrm.find(collectionName: collectionName, dictionary: 
                ["language": language]
            , projection: ["idName", "name", "language", "udcDocumentItemCategoryIdName", "udcGrammarCategory"], limitedTo: limitedTo, sortOrder: "UDBCSortOrder.Ascending", sortedBy: sortedBy) as DatabaseOrmResult<UDCDocumentItemType>
    }
    
    
    public static func get(collectionName: String, limitedTo: Int, sortedBy: String,  udbcDatabaseOrm: UDBCDatabaseOrm, language: String, _id: [String]) -> DatabaseOrmResult<UDCDocumentItemType> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return databaseOrm.find(collectionName: collectionName, dictionary: ["$and":
            [
                ["language": language],
                ["_id": ["$in": _id]]
            ]], projection: ["idName", "name", "language", "udcDocumentItemCategoryIdName", "udcGrammarCategory"], limitedTo: limitedTo, sortOrder: "UDBCSortOrder.Ascending", sortedBy: sortedBy) as DatabaseOrmResult<UDCDocumentItemType>
    }
    
    public static func search(collectionName: String, text: String, udbcDatabaseOrm: UDBCDatabaseOrm, language: String = "en") throws -> DatabaseOrmResult<UDCDocumentItemType> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        
        let databaseOrmResult = databaseOrm.find(collectionName: collectionName, dictionary: [
            
            "language": language,
            "name": try NSRegularExpression(pattern: text, options: .allowCommentsAndWhitespace)
            ], projection: ["idName", "name", "language", "udcDocumentItemCategoryIdName", "udcGrammarCategory"], limitedTo: 0, sortOrder: "UDBCSortOrder.Ascending", sortedBy: "name") as DatabaseOrmResult<UDCDocumentItemType>
        
        return databaseOrmResult
    }
    
    public static func get(collectionName: String, _ name: String,  _ udbcDatabaseOrm: UDBCDatabaseOrm, _ language: String = "en") -> DatabaseOrmResult<UDCDocumentItemType> {
        
        if data.count == 0 {
            let databaseOrmResult = get(collectionName: collectionName, udbcDatabaseOrm, language)
            for type in databaseOrmResult.object {
                data[type.name+"."+language] = type
            }
        }
        // If the type is not already found in memory, then get from database
        if data[name+"."+language] == nil {
            return getOne(collectionName: collectionName, name, udbcDatabaseOrm, language)
        }
        
        let databaseOrmResult = DatabaseOrmResult<UDCDocumentItemType>()
        databaseOrmResult.object.append(data[name+"."+language]!)
        
        return databaseOrmResult
    }
    
    private static func getOne(collectionName: String, _ name: String, _ udbcDatabaseOrm: UDBCDatabaseOrm, _ language: String = "en") -> DatabaseOrmResult<UDCDocumentItemType> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        let databaseOrmResult = databaseOrm.find(collectionName: collectionName, dictionary: ["idName": name,"language": language], limitedTo: Int(0.0)) as DatabaseOrmResult<UDCDocumentItemType>
        if databaseOrmResult.object.count > 0 {
            data[name+"."+language] = databaseOrmResult.object[0]
        }
        return databaseOrmResult
    }
    
    public static func get(collectionName: String, _ udbcDatabaseOrm: UDBCDatabaseOrm, _ language: String = "en") -> DatabaseOrmResult<UDCDocumentItemType> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        let databaseOrmResult = databaseOrm.find(collectionName: collectionName, dictionary: ["language": language], limitedTo: Int(0.0)) as DatabaseOrmResult<UDCDocumentItemType>
        data.removeAll()
        for type in databaseOrmResult.object {
            data[type.name+"."+language] = type
        }
        
        return databaseOrmResult
    }
}
