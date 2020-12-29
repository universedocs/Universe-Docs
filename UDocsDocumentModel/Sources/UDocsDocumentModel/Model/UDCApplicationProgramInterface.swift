//
//  USCMailjetCredentials.swift
//  Universe_Docs_Security
//
//  Created by Kumar Muthaiah on 14/01/19.
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


public class UDCApplicationProgramInterface : Codable {
    public var _id: String = ""
    public var idName: String = ""
    public var name: String = ""
    public var description: String = ""
    public var apiCompanyProfileIdName: String = ""
    public var senderEMail: String = ""
    public var senderName: String = ""
    public var apiUrl: String = ""
    public var userName: String = ""
    public var password: String = ""
    public var upcApplicationProfileId: String = ""
    public var upcCompanyProfileId: String = ""
    
    public init() {
        
    }
    
    static public func getName() -> String {
        return "UDCApplicationProgramInterface"
    }
    
    static public func get(udbcDatabaseOrm: UDBCDatabaseOrm, upcApplicationProfileId: String, upcCompanyProfileId: String, apiCompanyProfileIdName: String) -> DatabaseOrmResult<UDCApplicationProgramInterface> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        let mongokittenOrmResult = databaseOrm.find(collectionName: UDCApplicationProgramInterface.getName(), dictionary: ["upcApplicationProfileId": upcApplicationProfileId, "upcCompanyProfileId": upcCompanyProfileId, "apiCompanyProfileIdName": apiCompanyProfileIdName], limitedTo: 0) as DatabaseOrmResult<UDCApplicationProgramInterface>
        
        return mongokittenOrmResult
    }
    
}
