//
//  ValidationPatternType.swift
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

public class RegularExpressionPatternType {
    static public var None = RegularExpressionPatternType("RegularExpressionPatternType.None", "None", "", "")
    static public var UserName = RegularExpressionPatternType("RegularExpressionPatternType.UserName", "User Name", "^[A-Za-z0-9]{8,14}", "UserName can have 8-14 characters, with: numbers and alphabhets (A-Z, a-z, 0-9)")
    static public var Password = RegularExpressionPatternType("RegularExpressionPatternType.Password", "Password", "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[$@$!%*#?&])[A-Za-z\\d$@$!%*#?&]{8,14}$", "Password should have 8-14 characters with: atleast one capital case, one lower case, one number, one symbol (A-Z, a-z, 0-9, $, @, $, !, %, *, #, ?, &)")
    static public var EMail = RegularExpressionPatternType("RegularExpressionPatternType.EMail", "E-Mail", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}", "Email can have 2-34 characters with: A-Z, a-z, 0-9 before and after \"@\". After \".\" only A-Z,a-z")
    static public var HumanName = RegularExpressionPatternType("RegularExpressionPatternType.HumanName", "Human Name", "[A-Z0-9a-z\\s&:\\-\\.]{1,}", "Human name can contain minimum 1 character, with: A-Z, a-z, 0-9, Space, &, ., -, :")
    static public var EMailSecret = RegularExpressionPatternType("RegularExpressionPatternType.EMailSecret", "EMail Secret", "[0-9]{6,6}", "E-Mail Secret to have 6 digits")
    static public var Punctuation = RegularExpressionPatternType("RegularExpressionPatternType.Punctuation", "Punctuation", "[\\.,'\"\\-&_;:/]{1,}", "Minimum one character with: .,'\"-&':/")
    
    public var name: String = ""
    public var description: String = ""
    public var pattern: String = ""
    public var helpText: String = ""
    
    private init(_ name: String, _ description: String, _ pattern: String, _ helpText: String) {
        self.name = name
        self.description = description
        self.pattern = pattern
        self.helpText = helpText
    }
    
}
