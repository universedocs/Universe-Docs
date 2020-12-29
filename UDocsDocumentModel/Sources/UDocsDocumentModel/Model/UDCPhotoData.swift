//
//  UDCPhotoData.swift
//  Universe Docs Document
//
//  Created by Kumar Muthaiah on 18/02/19.
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

public class UDCPhotoData : Codable {
    public var _id: String = ""
    public var data = Data()

    public init() {
        
    }
    
    public static func getName() -> String {
        return "UDCPhotoData"
    }
    
    static public func save<T: Codable>(collectionName: String, udbcDatabaseOrm: UDBCDatabaseOrm, object: T) -> DatabaseOrmResult<T> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return databaseOrm.save(collectionName: collectionName, object: object )
        
    }
    
    static public func remove<T: Codable>(collectionName: String, udbcDatabaseOrm: UDBCDatabaseOrm, id: String) -> DatabaseOrmResult<T> {
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return DatabaseOrm.remove(collectionName: collectionName, dictionary: ["_id": id])
        
    }
    
    public static func get(collectionName: String, id: String, _ udbcDatabaseOrm: UDBCDatabaseOrm) -> DatabaseOrmResult<UDCPhotoData> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        let databaseOrmResult = databaseOrm.find(collectionName: collectionName, dictionary: ["_id": id], limitedTo: Int(0.0)) as DatabaseOrmResult<UDCPhotoData>
        return databaseOrmResult
    }
}
