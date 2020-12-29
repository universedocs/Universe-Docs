//
//  UDCSentenceGrammarPattern.swift
//  Universe Docs Document
//
//  Created by Kumar Muthaiah on 22/01/19.
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

public class UDCSentenceGrammarPattern : Codable {
    public var _id: String = ""
    public var idName: String = ""
    public var name: String = ""
    public var language: String = ""
    public var udcSentenceGrammarPatternData: [UDCSentenceGrammarPatternData] = [UDCSentenceGrammarPatternData]()
    
    public init() {
        
    }
    
    static public func getName() -> String {
        return "UDCSentenceGrammarPattern"
    }
    
    static public func get(udbcDatabaseOrm: UDBCDatabaseOrm, name: String, language: String) -> DatabaseOrmResult<UDCSentenceGrammarPattern> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        
        return databaseOrm.find(collectionName: UDCSentenceGrammarPattern.getName(), dictionary: ["idName": name, "language": language], limitedTo: 0) as DatabaseOrmResult<UDCSentenceGrammarPattern>
        
    }
    
    static public func get(udbcDatabaseOrm: UDBCDatabaseOrm, id: String, language: String) -> DatabaseOrmResult<UDCSentenceGrammarPattern> {
        let databaseOrm = udbcDatabaseOrm.ormObject as! DatabaseOrm
        
        return databaseOrm.find(collectionName: UDCSentenceGrammarPattern.getName(), dictionary: ["_id": id, "language": language], limitedTo: 0) as DatabaseOrmResult<UDCSentenceGrammarPattern>
        
    }
}
