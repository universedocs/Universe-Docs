//
//  SecurityNeuronErrorType.swift
//  UniversalBrainController
//
//  Created by Kumar Muthaiah on 27/10/18.
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

public class SecurityNeuronErrorType {
    static public var None = SecurityNeuronErrorType("SecurityNeuronErrorType.None", "None")
    static public var InvalidUserNameOrPassword = SecurityNeuronErrorType("SecurityNeuronErrorType.InvalidUserNameOrPassword", "Invalid User Name Or Password")
    static public var InvalidSecurityToken = SecurityNeuronErrorType("SecurityNeuronErrorType.InvalidSecurityToken", "Invalid Security Token")
    static public var SecurityTokenExpired = SecurityNeuronErrorType("SecurityNeuronErrorType.SecurityTokenExpired", "Security Token Expired")
    static public var InvalidSecurityOperation = SecurityNeuronErrorType("SecurityNeuronErrorType.InvalidSecurityOperation", "Invalid Security Operation")
    static public var InvalidApplicationInformation = SecurityNeuronErrorType("SecurityNeuronErrorType.InvalidApplicationInformation", "Invalid Application Information")
    static public var InvalidCompanyInformation = SecurityNeuronErrorType("SecurityNeuronErrorType.InvalidCompnyInformation", "Invalid Company Information")
    static public var UserAlreadyExist = SecurityNeuronErrorType("SecurityNeuronErrorType.UserAlreadyExist", "User Already Exist")
   
    public var name: String = ""
    public var description: String = ""
    
    private init(_ name: String, _ description: String) {
        self.name = name
        self.description = description
    }
}


