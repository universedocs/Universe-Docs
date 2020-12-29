//
//  StringUtility.swift
//  Universe_Docs_Common
//
//  Created by Kumar Muthaiah on 07/12/18.
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

public class StringUtility {
    private var punctuation : [String] = [
        "~","`","!","@","#","$","%","^","&",
        "*","(",")","-","_","=","+","[","{",
        "]","}","\\","|",";",":","\"","'",
        "<",",",".",">","/","?"
    ]
    
    public init() {
        
    }
    
    public func isPunctuation(text: String) -> Bool {
        for p in punctuation {
            if p == text {
                return true
            }
        }
        
        return false
    }
    
    public func stringBetween(character: Character, andCharacter: Character, from: String) -> String {
        return String(from.split(separator: character)[1].split(separator: andCharacter)[0])
    }
    
    
    
    public func capitalCaseToArray(capitalCaseText: String) -> [String] {
        let indexes = Set(capitalCaseText
         .enumerated()
         .filter { $0.element.isUppercase }
         .map { $0.offset })
         
        let chunks = capitalCaseText
         .map { String($0) }
         .enumerated()
         .reduce([String]()) { chunks, elm -> [String] in
             guard !chunks.isEmpty else { return [elm.element] }
             guard !indexes.contains(elm.offset) else { return chunks + [String(elm.element)] }

             var chunks = chunks
             chunks[chunks.count-1] += String(elm.element)
             return chunks
         }
        
        return chunks
    }
    
    public func getNotMatched(for regex: String, in text: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    public func checkMatched(for regex: String, in text: String) -> Bool {
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", regex)
        return passwordTest.evaluate(with: text)
    }
    
    public func capitalCase(array2d: [[String]]) -> [[String]] {
        var string2dArray = [[String]]()
        var stringArray = [String]()
        for array in array2d {
            stringArray.removeAll()
            for a in array {
                stringArray.append(a.capitalized)
            }
            string2dArray.append(stringArray)
        }
        
        return string2dArray
    }
    

}
