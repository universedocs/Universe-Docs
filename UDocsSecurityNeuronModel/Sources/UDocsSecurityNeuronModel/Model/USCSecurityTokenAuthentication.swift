//
//  UPCSecurityTokenAuthentication.swift
//  UniversalProfileController
//
//  Created by Kumar Muthaiah on 25/10/18.
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

public class USCSecurityTokenAuthentication : Codable {
    public var _id: String = ""
    public var securityToken: String = ""
    public var expiryTime: Date?
    
    public init() {
        
    }
    
    static public func getName() -> String {
        return "USCSecurityTokenAuthentication"
    }
    
    static public func get(udbcDatabaseOrm: UDBCDatabaseOrm, id: String) -> DatabaseOrmResult<USCSecurityTokenAuthentication> {
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return DatabaseOrm.find(collectionName: USCSecurityTokenAuthentication.getName(), dictionary: ["_id": id], limitedTo: Int(0.0)) as DatabaseOrmResult<USCSecurityTokenAuthentication>
    }
    
    static public func get(udbcDatabaseOrm: UDBCDatabaseOrm, userName: String) -> DatabaseOrmResult<USCSecurityTokenAuthentication> {
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return DatabaseOrm.find(collectionName: USCSecurityTokenAuthentication.getName(), dictionary: ["userName": userName], limitedTo: Int(0.0)) as DatabaseOrmResult<USCSecurityTokenAuthentication>
    }
    
    static public func save<T: Codable>(udbcDatabaseOrm: UDBCDatabaseOrm, object: T) -> DatabaseOrmResult<T> {
        
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return DatabaseOrm.save(collectionName: USCSecurityTokenAuthentication.getName(), object: object )
        
    }
  
    static public func update<T: Codable>(udbcDatabaseOrm: UDBCDatabaseOrm, id: String, securityToken: String, expiryTime: Date) -> DatabaseOrmResult<T> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
  
        
        return  databaseOrm.update(collectionName: USCSecurityTokenAuthentication.getName(), whereDictionary: [
        "_id": id], setDictionary: ["securityToken": securityToken, "expiryTime": expiryTime])
     
    }
    
   
}
