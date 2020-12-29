//
//  UPCHumanProfile.swift
//  Universe_Docs_Profile
//
//  Created by Kumar Muthaiah on 26/10/18.
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

public class UPCHumanProfile : Codable {
    public var _id: String = ""
    public var idName: String = ""
    public var name: String = ""
    public var firstName: String = ""
    public var middleName: String = ""
    public var lastName: String = ""
    public var upcEmailProfileId: String = ""
    public var language: String = ""
    
    public init() {
        
    }
    
    static public func getName() -> String {
        return "UPCHumanProfile"
    }
    
    static public func save<T: Codable>(udbcDatabaseOrm: UDBCDatabaseOrm, object: T) -> DatabaseOrmResult<T> {
      
            let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
            return DatabaseOrm.save(collectionName: UPCHumanProfile.getName(), object: object )
      
        
    }
    
    public static func get(limitedTo: Int, sortedBy: String,  udbcDatabaseOrm: UDBCDatabaseOrm, language: String = "en") -> DatabaseOrmResult<UPCHumanProfile> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return databaseOrm.find(collectionName: getName(), dictionary: ["language": language]
            , projection: ["idName", "name", "language", "firstName", "middleName", "lastName", "upcEmailProfileId"], limitedTo: limitedTo, sortOrder: "UDBCSortOrder.Ascending", sortedBy: sortedBy) as DatabaseOrmResult<UPCHumanProfile>
    }
    
    public static func search(text: String, udbcDatabaseOrm: UDBCDatabaseOrm, language: String = "en") throws -> DatabaseOrmResult<UPCHumanProfile> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        
        let databaseOrmResult = databaseOrm.find(collectionName: getName(), dictionary: [
            
            "language": language,
            "name": try NSRegularExpression(pattern: text, options: .allowCommentsAndWhitespace)
            ], projection: ["idName", "name", "language", "firstName", "middleName", "lastName", "upcEmailProfileId" ], limitedTo: 0, sortOrder: "UDBCSortOrder.Ascending", sortedBy: "name") as DatabaseOrmResult<UPCHumanProfile>
        
        return databaseOrmResult
    }
    
    
       public static func get(greaterThenDescription: String, limitedTo: Int, sortedBy: String,   udbcDatabaseOrm: UDBCDatabaseOrm, language: String = "en") -> DatabaseOrmResult<UPCHumanProfile> {
           let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
           return databaseOrm.find(collectionName: getName(), dictionary: ["$and":
               [
                   ["name": ["$gt": greaterThenDescription]],
                   ["language": language]
               ]], projection: ["idName", "name", "language", "firstName", "middleName", "lastName", "upcEmailProfileId"], limitedTo: limitedTo, sortOrder: "UDBCSortOrder.Ascending", sortedBy: sortedBy) as DatabaseOrmResult<UPCHumanProfile>
       }
       
       
    
    public static func get(idName: String, _ udbcDatabaseOrm: UDBCDatabaseOrm, _ language: String = "en") -> DatabaseOrmResult<UPCHumanProfile> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        let databaseOrmResult = databaseOrm.find(collectionName: getName(), dictionary: ["idName": idName,"language": language], limitedTo: Int(0.0)) as DatabaseOrmResult<UPCHumanProfile>
        return databaseOrmResult
    }

    public static func get(_ name: String, _ udbcDatabaseOrm: UDBCDatabaseOrm, _ language: String = "en") -> DatabaseOrmResult<UPCHumanProfile> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        let databaseOrmResult = databaseOrm.find(collectionName: getName(), dictionary: ["name": name,"language": language], limitedTo: Int(0.0)) as DatabaseOrmResult<UPCHumanProfile>
        return databaseOrmResult
    }
    
    public static func get(_ udbcDatabaseOrm: UDBCDatabaseOrm, _ language: String = "en") -> DatabaseOrmResult<UPCHumanProfile> {
           let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
           let databaseOrmResult = databaseOrm.find(collectionName: getName(), dictionary: ["language": language], limitedTo: Int(0.0)) as DatabaseOrmResult<UPCHumanProfile>
           
           
           return databaseOrmResult
       }
    
    static public func get(udbcDatabaseOrm: UDBCDatabaseOrm, profileId: String) -> DatabaseOrmResult<UPCHumanProfile> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        let mongokittenOrmResult = databaseOrm.find(collectionName: UPCHumanProfile.getName(), dictionary: ["idName": profileId], limitedTo: 0) as DatabaseOrmResult<UPCHumanProfile>
        
        return mongokittenOrmResult
    }
    
}
