//
//  USCApplicationKeyType.swift
//  UniversalProfileController
//
//  Created by Kumar Muthaiah on 25/10/18.
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

public class USCApplicationAuthenticationType : Codable {
    static public var None = USCApplicationAuthenticationType("USCApplicationAuthenticationType.None", "None")
    static public var UserNamePasswordAuthenticaiton = USCApplicationAuthenticationType("USCApplicationAuthenticationType.UserNamePasswordAuthenticaiton", "User Name Password Authenticaiton")
    static public var SecurityTokenAuthentication = USCApplicationAuthenticationType("USCApplicationAuthenticationType.SecurityTokenAuthentication", "Security Token Authentication")
    static public var PublicPrivateKeyAuthentication = USCApplicationAuthenticationType("USCApplicationAuthenticationType.PublicPrivateKeyAuthentication", "Public Private Key Authentication")
    static public var SecurityPinAuthentication = USCApplicationAuthenticationType("USCApplicationAuthenticationType.SecurityPinAuthentication", "Security Pin Authentication")
    public var name: String = ""
    public var description: String = ""
    
    public init() {
        
    }
    
    private init(_ name: String, _ description: String) {
        self.name = name
        self.description = description
    }
   
}
