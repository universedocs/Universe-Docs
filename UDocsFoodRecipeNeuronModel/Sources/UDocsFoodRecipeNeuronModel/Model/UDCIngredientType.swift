//
//  UDCIngredientType.swift
//  Universe_Docs_Document
//
//  Created by Kumar Muthaiah on 17/11/18.
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

public class UDCIngredientType : Codable {
    static private var data = [String : UDCIngredientType]()
    public var _id: String = ""
    public var idName: String = ""
    public var name: String = ""
    public var udcIngredientCategoryIdName: String = ""
    public var udcItemStateIdName: String = ""
    public var language: String = ""
    public var grammarCategory: String = ""
    public var isCountable: Bool = false

    private init() {
        
    }
    
    public static func getName() -> String {
        return "UDCIngredientType"
    }
    
    public static func getCollectionName() -> String {
        return "UDCIngredient"
    }
    
    public static func get(greaterThenDescription: String, category: String, limitedTo: Int, sortedBy: String,   udbcDatabaseOrm: UDBCDatabaseOrm, language: String = "en") -> DatabaseOrmResult<UDCIngredientType> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        if !category.isEmpty {
            return databaseOrm.find(collectionName: UDCIngredientType.getCollectionName(), dictionary: ["$and":
            [
                ["name": ["$gt": greaterThenDescription]],
                ["language": language],
                ["udcIngredientCategoryIdName": category]
            ]],  projection: ["idName", "name", "udcIngredientCategoryIdName", "udcItemStateIdName", "language", "grammarCategory",  "isCountable"], limitedTo: limitedTo, sortOrder: "UDBCSortOrder.Ascending", sortedBy: sortedBy) as DatabaseOrmResult<UDCIngredientType>
        } else {
            return databaseOrm.find(collectionName: UDCIngredientType.getCollectionName(), dictionary: ["$and":
                [
                    ["name": ["$gt": greaterThenDescription]],
                    ["language": language]
                ]],  projection: ["idName", "name", "udcIngredientCategoryIdName", "udcItemStateIdName", "language", "grammarCategory",  "isCountable"], limitedTo: limitedTo, sortOrder: "UDBCSortOrder.Ascending", sortedBy: sortedBy) as DatabaseOrmResult<UDCIngredientType>
        }
    }
    
    public static func get(limitedTo: Int, sortedBy: String, category: String,  udbcDatabaseOrm: UDBCDatabaseOrm, language: String = "en") -> DatabaseOrmResult<UDCIngredientType> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        if !category.isEmpty {
            return databaseOrm.find(collectionName: UDCIngredientType.getCollectionName(), dictionary: ["language": language,"udcIngredientCategoryIdName": category], projection: ["idName", "name", "udcIngredientCategoryIdName", "udcItemStateIdName", "language", "grammarCategory", "isCountable"], limitedTo: limitedTo, sortOrder: "UDBCSortOrder.Ascending", sortedBy: sortedBy) as DatabaseOrmResult<UDCIngredientType>
            
        } else {
            return databaseOrm.find(collectionName: UDCIngredientType.getCollectionName(), dictionary: 
                ["language": language]
                , projection: ["idName", "name", "udcIngredientCategoryIdName", "udcItemStateIdName", "language", "grammarCategory",  "isCountable"], limitedTo: limitedTo, sortOrder: "UDBCSortOrder.Ascending", sortedBy: sortedBy) as DatabaseOrmResult<UDCIngredientType>
        }
    }
   
    public static func search(text: String, udbcDatabaseOrm: UDBCDatabaseOrm, language: String = "en") throws -> DatabaseOrmResult<UDCIngredientType> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        print(try NSRegularExpression(pattern: text, options: .caseInsensitive))
        let databaseOrmResult = databaseOrm.find(collectionName: UDCIngredientType.getCollectionName(), dictionary: [
            
                "language": language,
                "name": try NSRegularExpression(pattern: text, options: .caseInsensitive)
//            "name": [ "$regex": "\(text)*", "$options": "i"] as Document
            ], projection: ["idName", "name", "udcIngredientCategoryIdName", "udcItemStateIdName", "language", "grammarCategory", "isCountable"], limitedTo: 0, sortOrder: "UDBCSortOrder.Ascending", sortedBy: "name") as DatabaseOrmResult<UDCIngredientType>
        
        return databaseOrmResult
    }
    
    public static func get(_ name: String,  _ udbcDatabaseOrm: UDBCDatabaseOrm, _ language: String = "en") -> DatabaseOrmResult<UDCIngredientType> {
        
        if data.count == 0 {
            let databaseOrmResult = get(udbcDatabaseOrm, language)
            for type in databaseOrmResult.object {
                data[type.idName+"."+language] = type
            }
        }
        // If the type is not already found in memory, then get from database
        if data[name+"."+language] == nil {
            return getOne(name, udbcDatabaseOrm, language)
        }
        
        let databaseOrmResult = DatabaseOrmResult<UDCIngredientType>()
        databaseOrmResult.object.append(data[name+"."+language]!)
        
        return databaseOrmResult
    }
    
    public static func get(id: String, _ udbcDatabaseOrm: UDBCDatabaseOrm, _ language: String = "en") -> DatabaseOrmResult<UDCIngredientType> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        let databaseOrmResult = databaseOrm.find(collectionName: getCollectionName(), dictionary: ["_id": id,"language": language], limitedTo: Int(0.0)) as DatabaseOrmResult<UDCIngredientType>
        return databaseOrmResult
    }
    
    public static func get(idName: String, _ udbcDatabaseOrm: UDBCDatabaseOrm, _ language: String = "en") -> DatabaseOrmResult<UDCIngredientType> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        let databaseOrmResult = databaseOrm.find(collectionName: getCollectionName(), dictionary: ["idName": idName,"language": language], limitedTo: Int(0.0)) as DatabaseOrmResult<UDCIngredientType>
        return databaseOrmResult
    }
    public static func getOne(_ name: String, _ udbcDatabaseOrm: UDBCDatabaseOrm, _ language: String = "en") -> DatabaseOrmResult<UDCIngredientType> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        let databaseOrmResult = databaseOrm.find(collectionName: getCollectionName(), dictionary: ["name": name,"language": language], limitedTo: Int(0.0)) as DatabaseOrmResult<UDCIngredientType>
//        if databaseOrmResult.object.count > 0 {
//            data[name+"."+language] = databaseOrmResult.object[0]
//        }
        return databaseOrmResult
    }
    
    public static func get(_ udbcDatabaseOrm: UDBCDatabaseOrm, _ language: String = "en") -> DatabaseOrmResult<UDCIngredientType> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        let databaseOrmResult = databaseOrm.find(collectionName: getCollectionName(), dictionary: ["language": language], limitedTo: Int(0.0)) as DatabaseOrmResult<UDCIngredientType>
        data.removeAll()
        for type in databaseOrmResult.object {
            data[type.idName+"."+language] = type
        }
        
        return databaseOrmResult
    }
}
