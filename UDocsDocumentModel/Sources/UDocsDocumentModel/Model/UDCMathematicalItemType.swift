//
//  UDCMathematicalItemType.swift
//  Universe Docs Document
//
//  Created by Kumar Muthaiah on 30/01/19.
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

public class UDCMathematicalItemType : Codable {
    static private var data = [String : UDCMathematicalItemType]()
    public var _id: String = ""
    public var idName: String = ""
    public var name: String = ""
    public var udcMathematicalCategoryIdName: String = ""
    public var language: String = ""
    
    public init() {
        
    }
    
    public static func getName() -> String {
        return "UDCMathematicalItemType"
    }
    
    public static func getCollectionName() -> String {
        return "UDCMathematicalItem"
    }
    
    public static func get(id: String, _ udbcDatabaseOrm: UDBCDatabaseOrm, _ language: String = "en") -> DatabaseOrmResult<UDCMathematicalItemType> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        let databaseOrmResult = databaseOrm.find(collectionName: getCollectionName(), dictionary: ["_id": id,"language": language], limitedTo: Int(0.0)) as DatabaseOrmResult<UDCMathematicalItemType>
        return databaseOrmResult
    }
    
    public static func get(idName: String, _ udbcDatabaseOrm: UDBCDatabaseOrm, _ language: String = "en") -> DatabaseOrmResult<UDCMathematicalItemType> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        let databaseOrmResult = databaseOrm.find(collectionName: getCollectionName(), dictionary: ["idName": idName,"language": language], limitedTo: Int(0.0)) as DatabaseOrmResult<UDCMathematicalItemType>
        return databaseOrmResult
    }
    
    public static func get(greaterThenDescription: String, limitedTo: Int, sortedBy: String,   udbcDatabaseOrm: UDBCDatabaseOrm, language: String = "en", _id: [String]) -> DatabaseOrmResult<UDCMathematicalItemType> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return databaseOrm.find(collectionName: UDCMathematicalItemType.getCollectionName(), dictionary: ["$and":
            [
                ["name": ["$gt": greaterThenDescription]],
                ["language": language],
                ["_id": ["$in": _id]]
            ]], projection: ["idName", "name", "language", "udcMathematicalCategoryIdName"], limitedTo: limitedTo, sortOrder: "UDBCSortOrder.Ascending", sortedBy: sortedBy) as DatabaseOrmResult<UDCMathematicalItemType>
    }
    
    public static func get(greaterThenDescription: String, category: String, limitedTo: Int, sortedBy: String,   udbcDatabaseOrm: UDBCDatabaseOrm, language: String = "en") -> DatabaseOrmResult<UDCMathematicalItemType> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        if !category.isEmpty {
            return databaseOrm.find(collectionName: UDCMathematicalItemType.getCollectionName(), dictionary: ["$and":
            [
                ["name": ["$gt": greaterThenDescription]],
                ["language": language],
                ["udcMathematicalCategoryIdName": ["$in": [category]]]
            ]], projection: ["idName", "name", "language", "udcMathematicalCategoryIdName"], limitedTo: limitedTo, sortOrder: "UDBCSortOrder.Ascending", sortedBy: sortedBy) as DatabaseOrmResult<UDCMathematicalItemType>
        } else {
            return databaseOrm.find(collectionName: UDCMathematicalItemType.getCollectionName(), dictionary: ["$and":
                [
                    ["name": ["$gt": greaterThenDescription]],
                    ["language": language]
                ]], projection: ["idName", "name", "language", "udcMathematicalCategoryIdName"], limitedTo: limitedTo, sortOrder: "UDBCSortOrder.Ascending", sortedBy: sortedBy) as DatabaseOrmResult<UDCMathematicalItemType>
        }
    }
    
    public static func get(limitedTo: Int, sortedBy: String, category: String, udbcDatabaseOrm: UDBCDatabaseOrm, language: String = "en") -> DatabaseOrmResult<UDCMathematicalItemType> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        if !category.isEmpty {
            return databaseOrm.find(collectionName: UDCMathematicalItemType.getCollectionName(), dictionary: ["language": language, "udcMathematicalCategoryIdName": ["$in": [category]]], projection: ["idName", "name", "language", "udcMathematicalCategoryIdName"], limitedTo: limitedTo, sortOrder: "UDBCSortOrder.Ascending", sortedBy: sortedBy) as DatabaseOrmResult<UDCMathematicalItemType>
        } else {
            return databaseOrm.find(collectionName: UDCMathematicalItemType.getCollectionName(), dictionary: ["language": language], projection: ["idName", "name", "language", "udcMathematicalCategoryIdName"], limitedTo: limitedTo, sortOrder: "UDBCSortOrder.Ascending", sortedBy: sortedBy) as DatabaseOrmResult<UDCMathematicalItemType>
        }
    }
    
    public static func get(limitedTo: Int, sortedBy: String,  udbcDatabaseOrm: UDBCDatabaseOrm, language: String = "en", _id: [String]) -> DatabaseOrmResult<UDCMathematicalItemType> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return databaseOrm.find(collectionName: UDCMathematicalItemType.getCollectionName(), dictionary: ["$and":
            [
                ["language": language],
                ["_id": ["$in": _id]]
            ]], projection: ["idName", "name", "language", "udcMathematicalCategoryIdName"], limitedTo: limitedTo, sortOrder: "UDBCSortOrder.Ascending", sortedBy: sortedBy) as DatabaseOrmResult<UDCMathematicalItemType>
    }
    
    public static func search(text: String, udbcDatabaseOrm: UDBCDatabaseOrm, language: String = "en") throws -> DatabaseOrmResult<UDCMathematicalItemType> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        
        let databaseOrmResult = databaseOrm.find(collectionName: UDCMathematicalItemType.getCollectionName(), dictionary: [
            
            "language": language,
            "name": ["$regex": "\(text)", "$options": "si"]
//            "name": try NSRegularExpression(pattern: text, options: .ignoreMetacharacters)
            ], projection: ["idName", "name", "language", "udcMathematicalCategoryIdName"], limitedTo: 0, sortOrder: "UDBCSortOrder.Ascending", sortedBy: "name") as DatabaseOrmResult<UDCMathematicalItemType>
        
        return databaseOrmResult
    }
    
    public static func get(_ name: String,  _ udbcDatabaseOrm: UDBCDatabaseOrm, _ language: String = "en") -> DatabaseOrmResult<UDCMathematicalItemType> {
        
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
        
        let databaseOrmResult = DatabaseOrmResult<UDCMathematicalItemType>()
        databaseOrmResult.object.append(data[name+"."+language]!)
        
        return databaseOrmResult
    }
    
    private static func getOne(_ name: String, _ udbcDatabaseOrm: UDBCDatabaseOrm, _ language: String = "en") -> DatabaseOrmResult<UDCMathematicalItemType> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        let databaseOrmResult = databaseOrm.find(collectionName: getCollectionName(), dictionary: ["idName": name,"language": language], limitedTo: Int(0.0)) as DatabaseOrmResult<UDCMathematicalItemType>
        if databaseOrmResult.object.count > 0 {
            data[name+"."+language] = databaseOrmResult.object[0]
        }
        return databaseOrmResult
    }
    
    public static func get(_ udbcDatabaseOrm: UDBCDatabaseOrm, _ language: String = "en") -> DatabaseOrmResult<UDCMathematicalItemType> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        let databaseOrmResult = databaseOrm.find(collectionName: getCollectionName(), dictionary: ["language": language], limitedTo: Int(0.0)) as DatabaseOrmResult<UDCMathematicalItemType>
        data.removeAll()
//        for type in databaseOrmResult.object {
//            data[type.name+"."+language] = type
//        }
        
        return databaseOrmResult
    }
    
}
