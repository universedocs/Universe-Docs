//
//  UDBCMongoDatabaseOrm.swift
//  UDBCRealmDatabaseOrm
//
//  Created by Kumar Muthaiah on 07/06/20.
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
import UDocsUtility
import UDocsDatabaseModel
//import UDocsRealmDatabaseUtility

public class UDBCRealmDatabaseOrm : UDBCDatabaseOrm {
    public var ormObject: AnyObject? = nil
    public var type: String = ""
    
    public init() {
        
    }
    
    public func generateId() throws -> String {
//         if type == UDBCDatabaseType.RealmDatabase.rawValue {
//            let databaseOrm = self.ormObject as! RealmDatabaseOrm
//            return databaseOrm.generateId()
//               } else {
                   return ""
//               }
    }
    
    public func generateId(collectionName: String, uniqueName: String) throws -> String {
        return "\(collectionName).\(uniqueName.replacingOccurrences(of: " ", with: "").capitalized)"
    }
    
    
}
