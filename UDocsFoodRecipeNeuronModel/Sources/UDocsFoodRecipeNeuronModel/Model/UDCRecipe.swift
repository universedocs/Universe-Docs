//
//  UDCRecipe.swift
//  Universe_Docs_Document
//
//  Created by Kumar Muthaiah on 13/11/18.
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
import UDocsDocumentModel

public class UDCRecipe : Codable {
    public var _id: String = ""
    public var name: String = ""
//    public var description: String = ""
//    public var upcHumanProfileId = [String]()
//    public var udcDuration = [UDCDuration]()
//    public var numberOfServings: Int = 1
//    public var udcCuisineType = [String]()
//    public var udcFoodTimingType = [String]()
//    public var udcPhotoId = [String]()
    public var udcRecipeIngredient = [UDCRecipeIngredient]()
    public var udcRecipeStep = [UDCRecipeStep]()
    public var udcReferenceItem = [UDCReferenceItem]()
    // Human Health->
    // https://en.wikipedia.org/wiki/Category:Health->
    // https://en.wikipedia.org/wiki/Category:Food_and_drink->
    // https://en.wikipedia.org/wiki/Category:Nutrition->
    // Carbohydrate
//    public var udcDocumentMapNodeId = [String]()
    public var udcAnalytic = [UDCAnalytic]()
    public var language: String = ""
    public var childId = [String]()
    public var referenceId: String = ""
    
    public init() {
        
    }
    
    static public func getName() -> String {
        return "UDCRecipe"
    }
    
    
    
    static public func get(udbcDatabaseOrm: UDBCDatabaseOrm, id: String, language: String) -> DatabaseOrmResult<UDCRecipe> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        
        return databaseOrm.find(collectionName: UDCRecipe.getName(), dictionary: ["_id": id, "language": language], limitedTo: 0) as DatabaseOrmResult<UDCRecipe>
        
    }
    
    static public func save<T: Codable>(udbcDatabaseOrm: UDBCDatabaseOrm, object: T) -> DatabaseOrmResult<T> {
        
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return DatabaseOrm.save(collectionName: UDCRecipe.getName(), object: object )
        
    }
    
    static public func update<T: Codable>(udbcDatabaseOrm: UDBCDatabaseOrm, object: T) -> DatabaseOrmResult<T> {
        let udcRecipe = object as! UDCRecipe
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return DatabaseOrm.update(collectionName: UDCRecipe.getName(), id: udcRecipe._id, object: object )
        
    }
    
    static public func update<T: Codable>(udbcDatabaseOrm: UDBCDatabaseOrm, id: String, name: String) -> DatabaseOrmResult<T> {
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return DatabaseOrm.update(collectionName: UDCRecipe.getName(), whereDictionary: ["_id": id], setDictionary:  ["name": name])
        
    }
    
    
    
    static public func remove<T: Codable>(udbcDatabaseOrm: UDBCDatabaseOrm, id: String) -> DatabaseOrmResult<T> {
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return DatabaseOrm.remove(collectionName: UDCRecipe.getName(), id: id)
        
    }
}
