//
//  RealmDatabaseOrm.swift
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
import RealmSwift
import UDocsUtility
import UDocsDatabaseModel

public class RealmDatabaseOrm : DatabaseOrmRealm {
    var realm: Realm?
    
    public init() {
        
    }
    
    public static func getName() -> String {
        return ""
    }
    
    public func connect() -> DatabaseOrmResult<String> {
        realm = try! Realm()
        return DatabaseOrmResult<String>()
    }
    
    public func disconnect() -> DatabaseOrmResult<String> {
        return DatabaseOrmResult<String>()
    }
    
    public func generateId() -> String {
        return ""
    }
    
    public func save<T>(collectionName: String, object: T) -> DatabaseOrmResult<T> where T : Decodable, T : Encodable {
        return DatabaseOrmResult<T>()
    }
    
    public func find<T>(collectionName: String, dictionary: [String : Any], limitedTo: Int?, sortOrder: String) -> DatabaseOrmResult<T> where T : Decodable, T : Encodable, T: Object {
//        let expresion = "\\s*\\b\(text)\\b\\s*"
//        let predicate = NSPredicate(format: "udcDocumentTypeIdName == \(udcDocumentTypeIdName)' AND language == '\(language)' AND SELF.name LIKE[c] %@", expresion)
        var formatArray = [String]()
        for dict in dictionary {
            formatArray.append("\(dict.key) == \(dict.value)")
        }
        let predicate = NSPredicate(format: formatArray.joined(separator: " AND "))
        let databaseOrmResult = DatabaseOrmResult<T>()
        let result = realm!.objects(T.self).filter(predicate)
        databaseOrmResult.rowsAffected = result.count
        return DatabaseOrmResult<T>()
    }
    
    public func find<T>(collectionName: String, dictionary: [String : Any], limitedTo: Int?, sortOrder: String, sortedBy: String) -> DatabaseOrmResult<T> where T : Decodable, T : Encodable, T: Object {
        return DatabaseOrmResult<T>()
    }
    
    public func find<T>(collectionName: String, dictionary: [String : Any], projection: [String]?, limitedTo: Int?, sortOrder: String, sortedBy: String) -> DatabaseOrmResult<T> where T : Decodable, T : Encodable, T: Object {
        return DatabaseOrmResult<T>()
    }
    
    public func find<T>(collectionName: String, dictionary: [String : Any], limitedTo: Int?) -> DatabaseOrmResult<T> where T : Decodable, T : Encodable, T: Object {
        return DatabaseOrmResult<T>()
    }
    
    public func getAll<T>(collectionName: String) -> DatabaseOrmResult<T> where T : Decodable, T : Encodable, T: Object {
        return DatabaseOrmResult<T>()
    }
    
    public func update<T>(collectionName: String, whereDictionary: [String : Any], setDictionary: [String : Any]) -> DatabaseOrmResult<T> where T : Decodable, T : Encodable, T: Object {
        return DatabaseOrmResult<T>()
    }
    
    public func updatePush<T>(collectionName: String, whereDictionary: [String : Any], setDictionary: [String : Any]) -> DatabaseOrmResult<T> where T : Decodable, T : Encodable, T: Object {
        return DatabaseOrmResult<T>()
    }
    
    public func updatePush<T>(collectionName: String, whereDictionary: [String : Any], key: String, values: [String], position: Int) -> DatabaseOrmResult<T> where T : Decodable, T : Encodable, T: Object {
        return DatabaseOrmResult<T>()
    }
    
    public func updatePull<T>(collectionName: String, whereDictionary: [String : Any], setDictionary: [String : Any]) -> DatabaseOrmResult<T> where T : Decodable, T : Encodable, T: Object {
        return DatabaseOrmResult<T>()
    }
    
    public func update<T>(collectionName: String, id: String, object: T) -> DatabaseOrmResult<T> where T : Decodable, T : Encodable, T: Object {
        return DatabaseOrmResult<T>()
    }
    
    public func update<T>(collectionName: String, whereDictionary: [String : Any], object: T) -> DatabaseOrmResult<T> where T : Decodable, T : Encodable, T: Object {
        return DatabaseOrmResult<T>()
    }
    
    public func remove<T>(collectionName: String, id: String) -> DatabaseOrmResult<T> where T : Decodable, T : Encodable, T: Object {
        return DatabaseOrmResult<T>()
    }
    
    public func remove<T>(collectionName: String, dictionary: [String : Any]) -> DatabaseOrmResult<T> where T : Decodable, T : Encodable, T: Object {
        return DatabaseOrmResult<T>()
    }
    
}
