//
//  UDCPhoto.swift
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
import UDocsViewModel

public class UDCPhoto : Codable {
    public var _id: String = ""
    public var udcPhotoDataId: String = ""
    public var uvcPhotoSizeType = UVCPhotoSizeType.Regular.name
    public var uvcMeasurement = [UVCMeasurement]()
    public var uvcPhotoFileType = UVCPhotoFileType.Jpeg.name
    /// If there is no photo data id, then it is stored as file in GridFS (greater than 16 MB)
    public var fileName: String = ""
    /// File is in internet and not in database
    public var fileUrl: String = ""
    /// Type of file URL
    public var fileUrlType: String = ""
    public var udcDocumentTime = UDCDocumentTime()
    public var isCategory: Bool? = false
    public var udcPhotoForDevice: [UDCPhotoForDevice]?
    
    public init() {
        
    }

    static public func getName() -> String {
        return "UDCPhoto"
    }

    static public func remove<T: Codable>(collectionName: String, udbcDatabaseOrm: UDBCDatabaseOrm, id: String) -> DatabaseOrmResult<T> {
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return DatabaseOrm.remove(collectionName: collectionName, dictionary: ["_id": id])
        
    }
    
    static public func get(collectionName: String, udbcDatabaseOrm: UDBCDatabaseOrm, id: String) -> DatabaseOrmResult<UDCPhoto> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        
        return databaseOrm.find(collectionName: collectionName, dictionary: ["_id": id], limitedTo: 0) as DatabaseOrmResult<UDCPhoto>
        
    }
    
    static public func update<T: Codable>(collectionName: String, udbcDatabaseOrm: UDBCDatabaseOrm, object: T) -> DatabaseOrmResult<T> {
        let udcRecipe = object as! UDCPhoto
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        
        return DatabaseOrm.update(collectionName: collectionName, id: udcRecipe._id, object: object )
        
    }
    
    static public func save<T: Codable>(collectionName: String, udbcDatabaseOrm: UDBCDatabaseOrm, object: T) -> DatabaseOrmResult<T> {
        
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return DatabaseOrm.save(collectionName: collectionName, object: object )
        
    }
    
    static public func updatePush<T: Codable>(collectionName: String, udbcDatabaseOrm: UDBCDatabaseOrm, id: String, childrenId: String) -> DatabaseOrmResult<T> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return  databaseOrm.updatePush(collectionName: collectionName, whereDictionary: ["_id": id], setDictionary: ["childrenId": childrenId]
        )
        
    }
    
    static public func updatePush<T: Codable>(collectionName: String, udbcDatabaseOrm: UDBCDatabaseOrm, id: String, childrenId: String, position: Int) -> DatabaseOrmResult<T> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return  databaseOrm.updatePush(collectionName: collectionName, whereDictionary: ["_id": id], key: "childrenId", values: [childrenId], position: position
        )
        
    }
    
    static public func updatePull<T: Codable>(collectionName: String, udbcDatabaseOrm: UDBCDatabaseOrm, id: String, childrenId: String) -> DatabaseOrmResult<T> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return  databaseOrm.updatePull(collectionName: collectionName, whereDictionary: ["_id": id], setDictionary: ["childrenId": childrenId]
        )
        
    }
}
