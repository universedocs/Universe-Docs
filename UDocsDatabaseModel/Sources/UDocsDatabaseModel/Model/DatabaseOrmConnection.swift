//
//  MongoDbKittenOrmConnection.swift
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

/*
 
 
 */
public struct DatabaseOrmConnection {
    
    public static var host: String        = "localhost"
    public static var port: Int            = 27017
    public static var ssl: Bool            = false
    
    public static var authmode: authModeType    = .none
    
    public static var username: String    = ""
    public static var password: String    = ""
    public static var authdb: String    = ""
    
    /// Database param is used as default if none specified in calls
    public static var database: String    = ""
    
    private init(){}
    
    public enum authModeType {
        case none, standard
    }
}
