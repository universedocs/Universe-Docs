//
//  MongoDbKittenOrmError.swift
//  Universe_Docs_Document
//
//  Created by Kumar Muthaiah on 10/10/18.
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

public class DatabaseOrmError : Codable {
    static public var None = DatabaseOrmError("DatabaseOrmErrorType.None", "None")
    static public var ConnectionFailure = DatabaseOrmError("DatabaseOrmErrorType.ConnectionFailure", "Database Connection Failure")
    static public var DisconnectionFailure = DatabaseOrmError("DatabaseOrmErrorType.DisconnectionFailure", "Database Disconnection Failure")
    static public var NoRecords = DatabaseOrmError("DatabaseOrmErrorType.NoRecords", "No Records")
    static public var FailedToFindRecords = DatabaseOrmError("DatabaseOrmErrorType.FailedToFind", "Failed to Find Records")
    static public var FailedToSaveRecords = DatabaseOrmError("DatabaseOrmErrorType.FailedToSave", "Failed to Save Records")
    static public var FailedToUpdateRecords = DatabaseOrmError("DatabaseOrmErrorType.FailedToUpdateRecords", "Failed to Update Records")
    static public var FailedToDeleteRecords = DatabaseOrmError("DatabaseOrmErrorType.FailedToDeleteRecords", "Failed to Delete Records")
    static public var FailedToCreateCollection = DatabaseOrmError("DatabaseOrmErrorType.FailedToCreateCollection", "Failed to create collection")
    public var name: String = ""
    public var description: String = ""
    
    public init() {
        
    }
    
    private init(_ name: String, _ description: String) {
        self.name = name
        self.description = description
    }
    
}
