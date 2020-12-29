//
//  UDCUserWordDictionary.swift
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

public class UDCUserWordDictionary : Codable {
    public var _id: String = ""
    public var idName: String = ""
    public var word: String = ""
    public var udcAnalytic = [UDCAnalytic]()
    public var udcProfile = [UDCProfile]()
    public var language: String = ""
    public var udcDocumentTime = UDCDocumentTime()
    public var udcGrammarCategoryIdName: String = ""
    
    public init() {
        
    }
    
    static public func getName() -> String {
        return "UDCUserWordDictionary"
    }
    
    static public func save<T: Codable>(udbcDatabaseOrm: UDBCDatabaseOrm, object: T) -> DatabaseOrmResult<T> {
        
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return DatabaseOrm.save(collectionName: UDCUserWordDictionary.getName(), object: object )
        
    }
    
    public static func get(id: String, _ udbcDatabaseOrm: UDBCDatabaseOrm, _ language: String = "en") -> DatabaseOrmResult<UDCUserWordDictionary> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        let databaseOrmResult = databaseOrm.find(collectionName: getName(), dictionary: ["_id": id,"language": language], limitedTo: Int(0.0)) as DatabaseOrmResult<UDCUserWordDictionary>
        return databaseOrmResult
    }
    
    public static func get(idName: String, _ udbcDatabaseOrm: UDBCDatabaseOrm, _ language: String = "en") -> DatabaseOrmResult<UDCUserWordDictionary> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        let databaseOrmResult = databaseOrm.find(collectionName: getName(), dictionary: ["idName": idName,"language": language], limitedTo: Int(0.0)) as DatabaseOrmResult<UDCUserWordDictionary>
        return databaseOrmResult
    }
    
    public static func getOne(_ name: String, _ udbcDatabaseOrm: UDBCDatabaseOrm, _ language: String = "en") -> DatabaseOrmResult<UDCUserWordDictionary> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        let databaseOrmResult = databaseOrm.find(collectionName: getName(), dictionary: ["name": name,"language": language], limitedTo: Int(0.0)) as DatabaseOrmResult<UDCUserWordDictionary>
//        if databaseOrmResult.object.count > 0 {
//            data[name+"."+language] = databaseOrmResult.object[0]
//        }
        return databaseOrmResult
    }
    
    
    public static func get(greaterThenDescription: String, limitedTo: Int, sortedBy: String,   udbcDatabaseOrm: UDBCDatabaseOrm, language: String = "en") -> DatabaseOrmResult<UDCUserWordDictionary> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return databaseOrm.find(collectionName: UDCUserWordDictionary.getName(), dictionary: ["$and":
            [
                ["name": ["$gt": greaterThenDescription]],
                ["language": language]
            ]], projection: ["idName", "word", "udcAnalytic", "udcProfile", "language","udcDocumentTime",  "udcGrammarCategoryIdName"], limitedTo: limitedTo, sortOrder: "UDBCSortOrder.Ascending", sortedBy: sortedBy) as DatabaseOrmResult<UDCUserWordDictionary>
    }
    
    
    public static func get(greaterThenDescription: String, limitedTo: Int, sortedBy: String,   udbcDatabaseOrm: UDBCDatabaseOrm, language: String = "en", _id: [String]) -> DatabaseOrmResult<UDCUserWordDictionary> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return databaseOrm.find(collectionName: getName(), dictionary: ["$and":
            [
                ["word": ["$gt": greaterThenDescription]],
                ["language": language],
                ["_id": ["$in": _id]]
            ]], projection: ["idName", "word", "udcAnalytic", "udcProfile", "language", "udcDocumentTime", "udcGrammarCategoryIdName"], limitedTo: limitedTo, sortOrder: "UDBCSortOrder.Ascending", sortedBy: sortedBy) as DatabaseOrmResult<UDCUserWordDictionary>
    }
    
    public static func get(limitedTo: Int, sortedBy: String,  udbcDatabaseOrm: UDBCDatabaseOrm, language: String) -> DatabaseOrmResult<UDCUserWordDictionary> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return databaseOrm.find(collectionName: getName(), dictionary: ["language": language], projection: ["idName", "word", "udcAnalytic", "udcProfile", "language", "udcDocumentTime", "udcGrammarCategoryIdName"], limitedTo: limitedTo, sortOrder: "UDBCSortOrder.Ascending", sortedBy: sortedBy) as DatabaseOrmResult<UDCUserWordDictionary>
    }
    
    
    public static func get(limitedTo: Int, sortedBy: String,  udbcDatabaseOrm: UDBCDatabaseOrm, language: String, _id: [String]) -> DatabaseOrmResult<UDCUserWordDictionary> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return databaseOrm.find(collectionName: getName(), dictionary: ["$and":
            [
                ["language": language],
                ["_id": ["$in": _id]]
            ]], projection: ["idName", "word", "udcAnalytic", "udcProfile", "language", "udcDocumentTime", "udcGrammarCategoryIdName"], limitedTo: limitedTo, sortOrder: "UDBCSortOrder.Ascending", sortedBy: sortedBy) as DatabaseOrmResult<UDCUserWordDictionary>
    }
    
    public static func search(text: String, udbcDatabaseOrm: UDBCDatabaseOrm, language: String = "en") throws -> DatabaseOrmResult<UDCUserWordDictionary> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        
        let databaseOrmResult = databaseOrm.find(collectionName: getName(), dictionary: [
            
            "language": language,
            "word": try NSRegularExpression(pattern: text, options: .dotMatchesLineSeparators)
            ], projection: ["idName", "idName", "word", "udcAnalytic", "udcProfile", "language", "udcDocumentTime", "udcGrammarCategoryIdName"], limitedTo: 0, sortOrder: "UDBCSortOrder.Ascending", sortedBy: "word") as DatabaseOrmResult<UDCUserWordDictionary>
        
        return databaseOrmResult
    }
    
}

