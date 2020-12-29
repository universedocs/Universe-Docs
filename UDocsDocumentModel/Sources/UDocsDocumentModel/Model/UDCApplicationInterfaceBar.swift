//
//  UDCApplicationInterfaceBar.swift
//  Universe Docs Brain
//
//  Created by Kumar Muthaiah on 12/11/19.
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

public class UDCApplicationInterfaceBar :  Codable {
    public var _id: String = ""
    public var upcCompanyProfileId: String = ""
    public var upcApplicationProfileId: String = ""
    public var udcInterfaceBarIdName: String = ""
    public var udcInterfaceBarId: String = ""
    public var language: String = ""
    
    public init() {
        
    }
    
    
    static public func getName() -> String {
        return "UDCApplicationInterfaceBar"
    }
    
    static public func save<T: Codable>(udbcDatabaseOrm: UDBCDatabaseOrm, object: T) -> DatabaseOrmResult<T> {
        
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return DatabaseOrm.save(collectionName: getName(), object: object )
        
    }
    
    static public func remove<T: Codable>(udbcDatabaseOrm: UDBCDatabaseOrm, udcInterfaceBarId: String, udcInterfaceBarIdName: String,  upcCompanyProfileId: String, upcApplicationProfileId: String, language: String) -> DatabaseOrmResult<T> {
           let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
           return DatabaseOrm.remove(collectionName: getName(), dictionary: ["udcInterfaceBarId": udcInterfaceBarId, "udcInterfaceBarIdName": udcInterfaceBarIdName, "upcCompanyProfileId": upcCompanyProfileId, "upcApplicationProfileId": upcApplicationProfileId, "language": language])
           
    }
    
    public static func get(udcInterfaceBarId: String, udcInterfaceBarIdName: String,  upcCompanyProfileId: String, upcApplicationProfileId: String, _ udbcDatabaseOrm: UDBCDatabaseOrm, _ language: String = "en") -> DatabaseOrmResult<UDCApplicationInterfaceBar> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        let databaseOrmResult = databaseOrm.find(collectionName: getName(), dictionary: ["udcInterfaceBarId": udcInterfaceBarId, "udcInterfaceBarIdName": udcInterfaceBarIdName, "upcCompanyProfileId": upcCompanyProfileId, "upcApplicationProfileId": upcApplicationProfileId,"language": language], limitedTo: Int(0.0)) as DatabaseOrmResult<UDCApplicationInterfaceBar>
        return databaseOrmResult
    }
    
    
    
    static public func update<T: Codable>(udbcDatabaseOrm: UDBCDatabaseOrm, udcInterfaceBarId: String, udcInterfaceBarIdName: String,  upcCompanyProfileId: String, upcApplicationProfileId: String, newUDCInterfaceBarIdName: String, language: String) -> DatabaseOrmResult<T> {
           let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
     
           
           return  databaseOrm.update(collectionName: getName(), whereDictionary: [
            "udcInterfaceBarId": udcInterfaceBarId, "udcInterfaceBarIdName": udcInterfaceBarIdName, "upcCompanyProfileId": upcCompanyProfileId, "upcApplicationProfileId": upcApplicationProfileId,"language": language], setDictionary: ["udcInterfaceBarIdName": newUDCInterfaceBarIdName])
        
       }
}
