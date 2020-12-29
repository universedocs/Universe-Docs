//
//  Test.swift
//  UDocsBrainRealmDatabase
//
//  Created by Kumar Muthaiah on 13/06/20.
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
import RealmSwift

@objcMembers public class Test : Object, Codable {
    
    
    dynamic public var _id: String = ""
    
    public required init() {
        
    }
    
    override public static func primaryKey() -> String? {
        return "_id"
    }
    enum CodingKeys: String, CodingKey {
        case _id
    }
    
    required convenience public init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        _id = try container.decode(String.self, forKey: ._id)
    }
    
    public func start() {
        // Application start below code
        var udbcDatabaseOrm: UDBCDatabaseOrm?
        udbcDatabaseOrm = UDBCRealmDatabaseOrm()
        
        let databaseOrm = RealmDatabaseOrm()
        udbcDatabaseOrm!.ormObject = databaseOrm
        udbcDatabaseOrm!.type = UDBCDatabaseType.RealmDatabase.rawValue
        
        let databaseOrmResult = databaseOrm.connect()
        if databaseOrmResult.databaseOrmError.count > 0 {
            print("Error in connection")
            return
        }
        
        // In the model below code
        let dOrm = udbcDatabaseOrm!.ormObject as! DatabaseOrm
        let databaseOrmResultUDCDocument = dOrm.find(collectionName: "", dictionary: ["_id": ""], limitedTo: 0) as DatabaseOrmResult<UDCDocument>
        print(databaseOrmResultUDCDocument.rowsAffected)
    }
}
