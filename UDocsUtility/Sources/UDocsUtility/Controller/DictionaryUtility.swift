//
//  DictionaryUtility.swift
//  UDocsUtility
//
//  Created by Kumar Muthaiah on 03/09/20.
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
import SwiftyJSON

extension URLSession {
    func synchronousDataTask(urlrequest: URLRequest) -> (data: Data?, response: URLResponse?, error: Error?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let dataTask = self.dataTask(with: urlrequest) {
            data = $0
            response = $1
            error = $2
            
            semaphore.signal()
        }
        dataTask.resume()
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        return (data, response, error)
    }
}

extension String {
    var decodingUnicodeCharacters: String { applyingTransform(.init("Hex-Any"), reverse: false) ?? "" }
}

public class DictionaryUtility {
    public init() {
        
    }
    
    func containsDictionaryWord(input: String) -> Bool {
        for chr in input {
            if (!(chr >= "a" && chr <= "z") && !(chr >= "A" && chr <= "Z") && chr != ".") {
                return false
            }
        }
        let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return true || Set(input).isSubset(of: nums)
    }
    
    
    // Tamil: https://api.agarathi.com/dictionary
    // English: https://od-api.oxforddictionaries.com:443/api/v2
    public func getEntries(word: String, language: String) -> [String: String]? {
        var dictionaryData = [String: String]()
        let appId = "76f26511"
        let appKey = "03779c070df04ae7c3ee8c6ec9c417d4"
        var actualLanguage = language
        let locale = Locale.current.regionCode!.lowercased()
        // ta - tamil, hi - hindi, es - Spanish, lv - Latvian, en-us, sw, gu - Gujarati, ro - Romanian
        if language == "en" {
            if locale == "in" {
                actualLanguage = "\(language)-gb"
            } else {
                actualLanguage = "\(language)-\(locale)"
            }
        }
        // "definitions" or "domains" or "etymologies" or "examples" or "pronunciations" or "regions" or "registers" or "variantForms"
        let fields = "definitions"
        let strictMatch = "false"
        var word_id = word
        if language != "en" {
            word_id = word.lowercased().addingPercentEncoding(withAllowedCharacters: .letters)!
        }
        if !containsDictionaryWord(input: word_id) && language == "en" {
            return dictionaryData
        }
        let urlString = "https://od-api.oxforddictionaries.com/api/v2/entries/\(language)/\(word_id)?fields=\(fields)&strictMatch=\(strictMatch)"
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(appId, forHTTPHeaderField: "app_id")
        request.addValue(appKey, forHTTPHeaderField: "app_key")
        
        let (data, _, error) = URLSession.shared.synchronousDataTask(urlrequest: request)
        if let error = error {
            print("DictionaryUtility: \(error)")
        }
        else {
            var found: Bool = false
            do {
                let json = try JSON(data: data!)
                for result in json["results"].arrayValue {
                    for lexicalEntries in result["lexicalEntries"].arrayValue {
                        if language == "en" {
                            dictionaryData["lexicalCategory"] = lexicalEntries["lexicalCategory"]["text"].stringValue
                        } else {
                            LanguageTranslatorUtility.shared.start(with: "AIzaSyDJ8nljsfXfyMzkQPx4dmim_mgDKeZCAwY")
                            print("cat: \(lexicalEntries["lexicalCategory"]["text"].stringValue)")
                            dictionaryData["lexicalCategory"] = LanguageTranslatorUtility.shared.translate(text: lexicalEntries["lexicalCategory"]["text"].stringValue, target: "ta", source: "en")
                        }
                        if lexicalEntries["entries"].arrayValue.count > 0 {
                            if language == "en" {
                                dictionaryData["definitions"] = lexicalEntries["entries"].arrayValue[0]["senses"].arrayValue[0]["definitions"].arrayValue[0].stringValue
                            } else {
                                if lexicalEntries["entries"].arrayValue[0]["senses"].arrayValue[0]["definitions"].arrayValue.count > 0 {
                                    dictionaryData["definitions"] = lexicalEntries["entries"].arrayValue[0]["senses"].arrayValue[0]["definitions"].arrayValue[0].stringValue.decodingUnicodeCharacters
                                }
                            }
                        }
                        found = true
                        break
                    }
                    if found { break }
                }
            } catch {
                
            }
        }
        
        return dictionaryData
    }
}
