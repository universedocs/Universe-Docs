//
//  JsonUtility.swift
//  COpenSSL
//
//  Created by Kumar Muthaiah on 05/10/18.
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

public class JsonUtility<T : Codable> {
    public init() {
        
    }
    
    public func convertAnyObjectToJson(jsonObject: T) -> String {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        //jsonEncoder.dateEncodingStrategy = .formatted(DateFormatter.iso8601Full)
        let jsonData = try! jsonEncoder.encode(jsonObject)
        let json = String(data: jsonData, encoding: String.Encoding.utf8)
        return json!
    }
    
    public func convertJsonToAnyObject(json: String) -> T {
        let decoder = JSONDecoder()
        let data = json.data(using: .utf8) ?? Data()
        // decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
        let classObject = try! decoder.decode(T.self, from: data)
        return classObject;
    }
 
  
   
}

extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
