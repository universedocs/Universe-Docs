//
//  UPCCompanyProfile.swift
//  Universe_Docs_Profile
//
//  Created by Kumar Muthaiah on 29/10/18.
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

public class UPCCompanyProfile : Codable {
    public var _id: String = ""
    public var idName: String = ""
    public var name: String = ""
    
    public init() {
        
    }
    
    static private func getName() -> String {
        return "UPCCompanyProfile"
    }
    
    public static func get(udbcDatabaseOrm: UDBCDatabaseOrm, id: String) -> DatabaseOrmResult<UPCCompanyProfile> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        let databaseOrmResult = databaseOrm.find(collectionName: UPCCompanyProfile.getName(), dictionary: ["idName": id], limitedTo: Int(0.0)) as DatabaseOrmResult<UPCCompanyProfile>

       
        return databaseOrmResult
    }
    
    func save<T: Codable>(udbcDatabaseOrm: UDBCDatabaseOrm, object: T) -> DatabaseOrmResult<T> {

            let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
            return DatabaseOrm.save(collectionName: UPCCompanyProfile.getName(), object: object )
   
    }
}
