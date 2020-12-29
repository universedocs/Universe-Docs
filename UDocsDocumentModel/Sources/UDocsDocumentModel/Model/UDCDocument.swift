//
//  UDCDocumentObject.swift
//  Universe_Docs_Document
//
//  Created by Kumar Muthaiah on 12/11/18.
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

public class UDCDocument : Codable {
    public var _id: String = ""
    public var idName: String = ""
    public var documentGroupId: String = ""
    public var categoryId: String = ""
    public var modelVersion: String = ""
    public var modelName: String = ""
    public var modelDescription: String = ""
    public var modelTechnicalName: String = ""
    public var version: String = ""
    public var name: String = ""
    public var description: String = ""
    public var language: String = ""
    public var technicalName: String = ""
    public var childId = [String]()
    public var referenceId: String = ""
    public var udcProfile = [UDCProfile]()
    public var udcAnalytic = [UDCAnalytic]()
    public var udcDocumentHistory = [UDCDcumentHistory]()
    public var udcDocumentGraphModelId: String = ""
    public var udcDocumentTypeIdName: String = ""
    public var udcDocumentVisibilityType: String = "UDCDocumentVisibilityType.Restricted"
    public var udcDocumentAccessProfile = [UDCDocumentAccessProfile]()
    public var udcDocumentTime = UDCDocumentTime()
    
    public init() {
        
    }
    
    static public func getName() -> String {
        return "UDCDocument"
    }
    
    public static func search(collectionName: String, text: String, udcDocumentTypeIdName: String, limitedTo: Int, sortedBy: String,   udbcDatabaseOrm: UDBCDatabaseOrm, language: String = "en") throws -> DatabaseOrmResult<UDCDocument> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return databaseOrm.find(collectionName: collectionName, dictionary: ["udcDocumentTypeIdName": udcDocumentTypeIdName, "language": language, "name": try NSRegularExpression(pattern: text, options: .caseInsensitive)], limitedTo: limitedTo, sortOrder: UDBCSortOrder.Ascending.name, sortedBy: sortedBy) as DatabaseOrmResult<UDCDocument>
    }
    
    public static func search(collectionName: String, text: String, limitedTo: Int, sortedBy: String,   udbcDatabaseOrm: UDBCDatabaseOrm, language: String = "en") throws -> DatabaseOrmResult<UDCDocument> {
         let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
         return databaseOrm.find(collectionName: collectionName, dictionary: ["language": language, "name": try NSRegularExpression(pattern: text, options: .caseInsensitive)], limitedTo: limitedTo, sortOrder: UDBCSortOrder.Ascending.name, sortedBy: sortedBy) as DatabaseOrmResult<UDCDocument>
     }
    
    public static func get(text: String, udcDocumentTypeIdName: String, limitedTo: Int, sortedBy: String,   udbcDatabaseOrm: UDBCDatabaseOrm, language: String = "en") throws -> DatabaseOrmResult<UDCDocument> {
           let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
           return databaseOrm.find(collectionName: getName(), dictionary: ["udcDocumentTypeIdName": udcDocumentTypeIdName, "language": language, "name": text], limitedTo: limitedTo, sortOrder: UDBCSortOrder.Ascending.name, sortedBy: sortedBy) as DatabaseOrmResult<UDCDocument>
       }
       
    public static func get(text: String, limitedTo: Int, sortedBy: String,   udbcDatabaseOrm: UDBCDatabaseOrm, language: String = "en") throws -> DatabaseOrmResult<UDCDocument> {
             let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
             return databaseOrm.find(collectionName: getName(), dictionary: [ "language": language, "name": text], limitedTo: limitedTo, sortOrder: UDBCSortOrder.Ascending.name, sortedBy: sortedBy) as DatabaseOrmResult<UDCDocument>
         }
         
    
    static public func get(udbcDatabaseOrm: UDBCDatabaseOrm, id: String, language: String) -> DatabaseOrmResult<UDCDocument> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        
        return databaseOrm.find(collectionName: UDCDocument.getName(), dictionary: ["_id": id, "language": language], limitedTo: 0) as DatabaseOrmResult<UDCDocument>
        
    }
    static public func get(collectionName: String, udbcDatabaseOrm: UDBCDatabaseOrm, id: String, language: String) -> DatabaseOrmResult<UDCDocument> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        
        return databaseOrm.find(collectionName: collectionName, dictionary: ["_id": id, "language": language], limitedTo: 0) as DatabaseOrmResult<UDCDocument>
        
    }
    static public func get(udbcDatabaseOrm: UDBCDatabaseOrm, udcProfile: [UDCProfile], udcDocumentTypeIdName: String, language: String) -> DatabaseOrmResult<UDCDocument> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        var all = [[String: Any]]()
        for udcp in udcProfile {
            let element: [String: Any] = ["udcProfileItemIdName": udcp.udcProfileItemIdName, "profileId": udcp.profileId]
            let elementMatch: [String: Any] = ["$elemMatch": element]
            all.append(elementMatch)
        }
        let udcProfileAll: [String: Any] = ["$all": all]
        let document: [String: Any] =  ["udcDocumentTypeIdName": udcDocumentTypeIdName, "language": language, "udcProfile": udcProfileAll]
        return databaseOrm.find(collectionName: UDCDocument.getName(), dictionary: document, limitedTo: 0) as DatabaseOrmResult<UDCDocument>
        
    }
    static public func get(udbcDatabaseOrm: UDBCDatabaseOrm, udcProfile: [UDCProfile], language: String) -> DatabaseOrmResult<UDCDocument> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        var all = [[String: Any]]()
        for udcp in udcProfile {
            let element: [String: Any] = ["udcProfileItemIdName": udcp.udcProfileItemIdName, "profileId": udcp.profileId]
            let elementMatch: [String: Any] = ["$elemMatch": element]
            all.append(elementMatch)
        }
        let udcProfileAll: [String: Any] = ["$all": all]
        let document: [String: Any] =  [ "language": language, "udcProfile": udcProfileAll]
        return databaseOrm.find(collectionName: UDCDocument.getName(), dictionary: document, limitedTo: 0) as DatabaseOrmResult<UDCDocument>
        
    }
    
    static public func get(udbcDatabaseOrm: UDBCDatabaseOrm, udcProfile: [UDCProfile], udcDocumentTypeIdName: String) -> DatabaseOrmResult<UDCDocument> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        var all = [[String: Any]]()
        for udcp in udcProfile {
            let element: [String: Any] = ["udcProfileItemIdName": udcp.udcProfileItemIdName, "profileId": udcp.profileId]
            let elementMatch: [String: Any] = ["$elemMatch": element]
            all.append(elementMatch)
        }
        let udcProfileAll: [String: Any] = ["$all": all]
        let document: [String: Any] =  ["udcDocumentTypeIdName": udcDocumentTypeIdName, "udcProfile": udcProfileAll]
        return databaseOrm.find(collectionName: UDCDocument.getName(), dictionary: document, limitedTo: 0) as DatabaseOrmResult<UDCDocument>
        
    }
    static public func get(udbcDatabaseOrm: UDBCDatabaseOrm, udcProfile: [UDCProfile], udcDocumentTypeIdName: String, idName: String, language: String) -> DatabaseOrmResult<UDCDocument> {
           let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
           var all = [[String: Any]]()
           for udcp in udcProfile {
               let element: [String: Any] = ["udcProfileItemIdName": udcp.udcProfileItemIdName, "profileId": udcp.profileId]
               let elementMatch: [String: Any] = ["$elemMatch": element]
               all.append(elementMatch)
           }
           let udcProfileAll: [String: Any] = ["$all": all]
           let document: [String: Any] =  ["udcDocumentTypeIdName": udcDocumentTypeIdName, "language": language, "udcProfile": udcProfileAll, "idName": idName]
           return databaseOrm.find(collectionName: UDCDocument.getName(), dictionary: document, limitedTo: 0) as DatabaseOrmResult<UDCDocument>
           
       }
    
    static public func get(udbcDatabaseOrm: UDBCDatabaseOrm, udcProfile: [UDCProfile], udcDocumentTypeIdName: String, idName: String) -> DatabaseOrmResult<UDCDocument> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        var all = [[String: Any]]()
        for udcp in udcProfile {
            let element: [String: Any] = ["udcProfileItemIdName": udcp.udcProfileItemIdName, "profileId": udcp.profileId]
            let elementMatch: [String: Any] = ["$elemMatch": element]
            all.append(elementMatch)
        }
        let udcProfileAll: [String: Any] = ["$all": all]
        let document: [String: Any] =  ["udcDocumentTypeIdName": udcDocumentTypeIdName, "udcProfile": udcProfileAll, "idName": idName]
        return databaseOrm.find(collectionName: UDCDocument.getName(), dictionary: document, limitedTo: 0) as DatabaseOrmResult<UDCDocument>
        
    }
    static public func get(udbcDatabaseOrm: UDBCDatabaseOrm,  udcDocumentTypeIdName: String, language: String) -> DatabaseOrmResult<UDCDocument> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        let document: [String: Any] =  ["udcDocumentTypeIdName": udcDocumentTypeIdName, "language": language]
        return databaseOrm.find(collectionName: UDCDocument.getName(), dictionary: document, limitedTo: 0) as DatabaseOrmResult<UDCDocument>
        
    }
    static public func get(udbcDatabaseOrm: UDBCDatabaseOrm, documentGroupId: String, notEqualsId: String, language: String) -> DatabaseOrmResult<UDCDocument> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return databaseOrm.find(collectionName: UDCDocument.getName(), dictionary: ["documentGroupId": documentGroupId, "_id": [ "$ne": notEqualsId], "language": language], limitedTo: 0) as DatabaseOrmResult<UDCDocument>
        
    }
    static public func get(udbcDatabaseOrm: UDBCDatabaseOrm, udcProfile: [UDCProfile], idName: String, udcDocumentTypeIdName: String, notEqualsDocumentGroupId: String) -> DatabaseOrmResult<UDCDocument> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        var all = [[String: Any]]()
        for udcp in udcProfile {
            let element: [String: Any] = ["udcProfileItemIdName": udcp.udcProfileItemIdName, "profileId": udcp.profileId]
            let elementMatch: [String: Any] = ["$elemMatch": element]
            all.append(elementMatch)
        }
        let udcProfileAll: [String: Any] = ["$all": all]
        return databaseOrm.find(collectionName: UDCDocument.getName(), dictionary: ["documentGroupId": [ "$ne": notEqualsDocumentGroupId], "idName": idName, "udcDocumentTypeIdName": udcDocumentTypeIdName, "udcProfile": udcProfileAll], limitedTo: 0) as DatabaseOrmResult<UDCDocument>
        
    }
    static public func get(udbcDatabaseOrm: UDBCDatabaseOrm, idName: String, udcProfile: [UDCProfile], udcDocumentTypeIdName: String, notEqualsLanguage: String) -> DatabaseOrmResult<UDCDocument> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        var all = [[String: Any]]()
        for udcp in udcProfile {
            let element: [String: Any] = ["udcProfileItemIdName": udcp.udcProfileItemIdName, "profileId": udcp.profileId]
            let elementMatch: [String: Any] = ["$elemMatch": element]
            all.append(elementMatch)
        }
        let udcProfileAll: [String: Any] = ["$all": all]
        return databaseOrm.find(collectionName: UDCDocument.getName(), dictionary: ["language": [ "$ne": notEqualsLanguage], "idName": idName, "udcProfile": udcProfileAll, "udcDocumentTypeIdName": udcDocumentTypeIdName], limitedTo: 0) as DatabaseOrmResult<UDCDocument>
        
    }
    static public func get(udbcDatabaseOrm: UDBCDatabaseOrm, idName: String) -> DatabaseOrmResult<UDCDocument> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        
        return databaseOrm.find(collectionName: UDCDocument.getName(), dictionary: ["idName": idName], limitedTo: 0) as DatabaseOrmResult<UDCDocument>
        
    }
    static public func get(udbcDatabaseOrm: UDBCDatabaseOrm, udcProfile: [UDCProfile], idName: String, udcDocumentTypeIdName: String, language: String) -> DatabaseOrmResult<UDCDocument> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        var all = [[String: Any]]()
        for udcp in udcProfile {
            let element: [String: Any] = ["udcProfileItemIdName": udcp.udcProfileItemIdName, "profileId": udcp.profileId]
            let elementMatch: [String: Any] = ["$elemMatch": element]
            all.append(elementMatch)
        }
        let udcProfileAll: [String: Any] = ["$all": all]
        return databaseOrm.find(collectionName: UDCDocument.getName(), dictionary: ["idName": idName, "language": language, "udcProfile": udcProfileAll, "udcDocumentTypeIdName": udcDocumentTypeIdName], limitedTo: 0) as DatabaseOrmResult<UDCDocument>
        
    }
    
    static public func get(udbcDatabaseOrm: UDBCDatabaseOrm, id: String) -> DatabaseOrmResult<UDCDocument> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        
        return databaseOrm.find(collectionName: UDCDocument.getName(), dictionary: ["_id": id], limitedTo: 0) as DatabaseOrmResult<UDCDocument>
        
    }
    
    static public func get(udbcDatabaseOrm: UDBCDatabaseOrm, language: String) -> DatabaseOrmResult<UDCDocument> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        
        return databaseOrm.find(collectionName: UDCDocument.getName(), dictionary: ["language": language], limitedTo: 0) as DatabaseOrmResult<UDCDocument>
        
    }
    
    static public func get(udbcDatabaseOrm: UDBCDatabaseOrm) -> DatabaseOrmResult<UDCDocument> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        
        return databaseOrm.getAll(collectionName: UDCDocument.getName()) as DatabaseOrmResult<UDCDocument>
        
    }
    static public func save<T: Codable>(udbcDatabaseOrm: UDBCDatabaseOrm, object: T) -> DatabaseOrmResult<T> {
        
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return DatabaseOrm.save(collectionName: UDCDocument.getName(), object: object )
        
    }
    
    
    static public func update<T: Codable>(udbcDatabaseOrm: UDBCDatabaseOrm, object: T) -> DatabaseOrmResult<T> {
        let udcRecipe = object as! UDCDocument
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return DatabaseOrm.update(collectionName: UDCDocument.getName(), id: udcRecipe._id, object: object )
        
    }
    
    
    static public func update<T: Codable>(udbcDatabaseOrm: UDBCDatabaseOrm, id: String, name: String) -> DatabaseOrmResult<T> {
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return DatabaseOrm.update(collectionName: UDCDocument.getName(), whereDictionary: ["_id": id], setDictionary: ["name": name])
        
    }
    
    static public func update<T: Codable>(udbcDatabaseOrm: UDBCDatabaseOrm, id: String, idName: String) -> DatabaseOrmResult<T> {
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return DatabaseOrm.update(collectionName: UDCDocument.getName(), whereDictionary: ["_id": id], setDictionary: ["idName": idName])
        
    }
    
    static public func remove<T: Codable>(udbcDatabaseOrm: UDBCDatabaseOrm, id: String, language: String) -> DatabaseOrmResult<T> {
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return DatabaseOrm.remove(collectionName: UDCDocument.getName(), dictionary: ["_id": id, "language": language])
    }
}
