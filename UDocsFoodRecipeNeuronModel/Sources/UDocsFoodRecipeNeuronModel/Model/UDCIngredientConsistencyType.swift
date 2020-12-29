//
//  UDCFoodConsistencyType.swift
//  Universe_Docs_Document
//
//  Created by Kumar Muthaiah on 13/11/18.
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

public class UDCIngredientConsistencyType : Codable {
    static private var data = [String : UDCIngredientConsistencyType]()
    public var _id: String = ""
    public var idName: String = ""
    public var name: String = ""
    public var language: String = ""
    public var grammarCategory: String = ""
    
    private init() {
        
    }
    
    public static func getName() -> String {
        return "UDCIngredientConsistencyType"
    }
    
    public static func getCollectionName() -> String {
        return "UDCIngredientConsistency"
    }
    
    
    public static func get(id: String, _ udbcDatabaseOrm: UDBCDatabaseOrm, _ language: String = "en") -> DatabaseOrmResult<UDCIngredientConsistencyType> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        let databaseOrmResult = databaseOrm.find(collectionName: getCollectionName(), dictionary: ["_id": id,"language": language], limitedTo: Int(0.0)) as DatabaseOrmResult<UDCIngredientConsistencyType>
        return databaseOrmResult
    }
    
    
    public static func get(greaterThenDescription: String, limitedTo: Int, sortedBy: String,   udbcDatabaseOrm: UDBCDatabaseOrm, language: String = "en") -> DatabaseOrmResult<UDCIngredientConsistencyType> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return databaseOrm.find(collectionName: UDCIngredientConsistencyType.getCollectionName(), dictionary: ["$and":
            [
                ["description": ["$gt": greaterThenDescription]],
                ["language": language]
            ]], projection: ["idName", "name", "language", "grammarCategory"], limitedTo: limitedTo, sortOrder: "UDBCSortOrder.Ascending", sortedBy: sortedBy) as DatabaseOrmResult<UDCIngredientConsistencyType>
    }
    
    public static func get(limitedTo: Int, sortedBy: String,  udbcDatabaseOrm: UDBCDatabaseOrm, language: String = "en") -> DatabaseOrmResult<UDCIngredientConsistencyType> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return databaseOrm.find(collectionName: UDCIngredientConsistencyType.getCollectionName(), dictionary: ["language": language], projection: ["idName", "name", "language", "grammarCategory"], limitedTo: limitedTo, sortOrder: "UDBCSortOrder.Ascending", sortedBy: sortedBy) as DatabaseOrmResult<UDCIngredientConsistencyType>
    }
    
    public static func search(text: String, udbcDatabaseOrm: UDBCDatabaseOrm, language: String = "en") throws -> DatabaseOrmResult<UDCIngredientConsistencyType> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        
        let databaseOrmResult = databaseOrm.find(collectionName: UDCIngredientConsistencyType.getCollectionName(), dictionary: [
            
            "language": language,
            "name": try NSRegularExpression(pattern: text, options: .allowCommentsAndWhitespace)
            ], projection: ["idName", "name", "abbrevation", "language", "grammarCategory"], limitedTo: 0, sortOrder: "UDBCSortOrder.Ascending", sortedBy: "name") as DatabaseOrmResult<UDCIngredientConsistencyType>
        
        return databaseOrmResult
    }
    
    public static func get(_ name: String,  _ udbcDatabaseOrm: UDBCDatabaseOrm, _ language: String = "en") -> DatabaseOrmResult<UDCIngredientConsistencyType> {
        
        if data.count == 0 {
            let databaseOrmResult = get(udbcDatabaseOrm, language)
            for type in databaseOrmResult.object {
                data[type.name+"."+language] = type
            }
        }
        // If the type is not already found in memory, then get from database
        if data[name+"."+language] == nil {
            return getOne(name, udbcDatabaseOrm, language)
        }
        
        let databaseOrmResult = DatabaseOrmResult<UDCIngredientConsistencyType>()
        databaseOrmResult.object.append(data[name+"."+language]!)
        
        return databaseOrmResult
    }
    
    private static func getOne(_ name: String, _ udbcDatabaseOrm: UDBCDatabaseOrm, _ language: String = "en") -> DatabaseOrmResult<UDCIngredientConsistencyType> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        let databaseOrmResult = databaseOrm.find(collectionName: getCollectionName(), dictionary: ["idName": name,"language": language], limitedTo: Int(0.0)) as DatabaseOrmResult<UDCIngredientConsistencyType>
        if databaseOrmResult.object.count > 0 {
            data[name+"."+language] = databaseOrmResult.object[0]
        }
        return databaseOrmResult
    }
    
    public static func get(_ udbcDatabaseOrm: UDBCDatabaseOrm, _ language: String = "en") -> DatabaseOrmResult<UDCIngredientConsistencyType> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        let databaseOrmResult = databaseOrm.find(collectionName: getCollectionName(), dictionary: ["language": language], limitedTo: Int(0.0)) as DatabaseOrmResult<UDCIngredientConsistencyType>
        data.removeAll()
        for type in databaseOrmResult.object {
            data[type.name+"."+language] = type
        }
        
        return databaseOrmResult
    }
    
}
