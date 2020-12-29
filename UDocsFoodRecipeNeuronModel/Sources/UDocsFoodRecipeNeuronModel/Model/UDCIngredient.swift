//
//  UDCNutrition.swift
//  Universe Docs Document
//
//  Created by Kumar Muthaiah on 27/01/19.
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

/// Contains ingredient information.
/// Food: https://www.nutritionvalue.org/search.php?food_query=banana
public class UDCIngredient : Codable {
    public var _id: String = ""
    public var idName: String = ""
    public var name: String = ""
    public var udcRecipeItemCategoryIdName: String = ""
    public var udcItemStateIdName: String = ""
    public var language: String = ""
    public var grammarCategory: String = ""
    public var udcMeasurement = [UDCMeasurement]()
    public var udcIngredientItem = [UDCIngredientItem]()

    public init() {
        
    }
    
    public static func getName() -> String {
        return "UDCIngredient"
    }
    
    static public func save<T: Codable>(udbcDatabaseOrm: UDBCDatabaseOrm, object: T) -> DatabaseOrmResult<T> {
        
        let DatabaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        return DatabaseOrm.save(collectionName: UDCIngredient.getName(), object: object )
        
    }
}
