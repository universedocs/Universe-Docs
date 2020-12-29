//
//  ValidationUtil.swift
//  UniversalBrainController
//
//  Created by Kumar Muthaiah on 11/01/19.
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

public class ValidationUtil {
    public init() {
        
    }
    func validateValue(regex: String, value: String) -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: value)
    }
    
    public func isValidPunctuation(value: String, helpText: inout String) -> Bool {
        if !validateValue(regex: RegularExpressionPatternType.Punctuation.pattern, value: value) {
            helpText = RegularExpressionPatternType.Punctuation.helpText
            return false
        }
        
        return true
    }
    
    public func isValidEmail(value: String, helpText: inout String) -> Bool {
        if !validateValue(regex: RegularExpressionPatternType.EMail.pattern, value: value) {
            helpText = RegularExpressionPatternType.EMail.helpText
            return false
        }
        
        return true
    }
    
    
    public func isValidUserName(value: String, helpText: inout String) -> Bool {
        if !validateValue(regex: RegularExpressionPatternType.UserName.pattern, value: value) {
            helpText = RegularExpressionPatternType.UserName.helpText
            return false
        }
        
        return true
    }
    
    public func isValidPassword(value: String, helpText: inout String) -> Bool {
        if !validateValue(regex: RegularExpressionPatternType.Password.pattern, value: value) {
            helpText = RegularExpressionPatternType.Password.helpText
            return false
        }
        
        return true
    }
    
    
    public func isValidHumanName(value: String, helpText: inout String) -> Bool {
        if !validateValue(regex: RegularExpressionPatternType.HumanName.pattern, value: value) {
            helpText = RegularExpressionPatternType.HumanName.helpText
            return false
        }
        
        return true
    }
    
    public func isValidEMailSecret(value: String, helpText: inout String) -> Bool {
        if !validateValue(regex: RegularExpressionPatternType.EMailSecret.pattern, value: value) {
            helpText = RegularExpressionPatternType.HumanName.helpText
            return false
        }
        
        return true
    }
   
}
