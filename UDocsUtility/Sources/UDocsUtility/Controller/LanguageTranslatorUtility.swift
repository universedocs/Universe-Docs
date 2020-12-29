//
//  SwiftGoogleTranslate.swift
//  SwiftGoogleTranslate
//
//  Created by Maxim on 10/29/18.
//  Copyright © 2018 Maksym Bilan. All rights reserved.
//
//  Kumar Muthaiah, 01-Dec-2020: Modified code to use synchronized call and class name change
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

/// A helper class for using Google Translate API.
public class LanguageTranslatorUtility {
    
    /// Shared instance.
    public static let shared = LanguageTranslatorUtility()

    /// Language response structure.
    public struct Language {
        public let language: String
        public let name: String
    }
    
    /// Detect response structure.
    public struct Detection {
        public let language: String
        public let isReliable: Bool
        public let confidence: Float
    }
    
    /// API structure.
    private struct API {
        /// Base Google Translation API url.
        static let base = "https://translation.googleapis.com/language/translate/v2"
        
        /// A translate endpoint.
        struct translate {
            static let method = "POST"
            static let url = API.base
        }
        
        /// A detect endpoint.
        struct detect {
            static let method = "POST"
            static let url = API.base + "/detect"
        }
        
        /// A list of languages endpoint.
        struct languages {
            static let method = "GET"
            static let url = API.base + "/languages"
        }
    }
    
    /// API key.
    private var apiKey: String!
    /// Default URL session.
    private let session = URLSession(configuration: .default)
    
    /**
        Initialization.
    
        - Parameters:
            - apiKey: A valid API key to handle requests for this API. If you are using OAuth 2.0 service account credentials (recommended), do not supply this parameter.
    */
    public func start(with apiKey: String) {
        self.apiKey = apiKey
    }
    
    /**
        Translates input text, returning translated text.
    
        - Parameters:
            - text: The input text to translate. Repeat this parameter to perform translation operations on multiple text inputs.
            - target: The language to use for translation of the input text.
            - format: The format of the source text, in either HTML (default) or plain-text. A value of html indicates HTML and a value of text indicates plain-text.
            - source: The language of the source text. If the source language is not specified, the API will attempt to detect the source language automatically and return it within the response.
            - model: The translation model. Can be either base to use the Phrase-Based Machine Translation (PBMT) model, or nmt to use the Neural Machine Translation (NMT) model. If omitted, then nmt is used. If the model is nmt, and the requested language translation pair is not supported for the NMT model, then the request is translated using the base model.
    */
    public func translate(text: String, target: String, source: String, format: String = "text", model: String = "base") -> String {
        guard var urlComponents = URLComponents(string: API.translate.url) else {
            
            return ""
        }
        
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "key", value: apiKey))
        queryItems.append(URLQueryItem(name: "q", value: text))
        queryItems.append(URLQueryItem(name: "target", value: target))
        queryItems.append(URLQueryItem(name: "source", value: source))
        queryItems.append(URLQueryItem(name: "format", value: format))
        queryItems.append(URLQueryItem(name: "model", value: model))
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            
            return ""
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = API.translate.method
        
        let _ = session.synchronousDataTask(urlrequest: urlRequest)
        let (data, _, error) = URLSession.shared.synchronousDataTask(urlrequest: urlRequest)
        if let error = error {
            print("DictionaryUtility: \(error)")
        }
        else {
            do {
                let json = try JSON(data: data!)
                return json["data"]["translations"][0]["translatedText"].string!
            } catch {
            }
        }

        return ""
    }
    
    /**
        Detects the language of text within a request.
    
        - Parameters:
            - text: The input text upon which to perform language detection. Repeat this parameter to perform language detection on multiple text inputs.
    */
    public func detect(text: String) -> String {
        guard var urlComponents = URLComponents(string: API.detect.url) else {
            return ""
        }
        
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "key", value: apiKey))
        queryItems.append(URLQueryItem(name: "q", value: text))
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            return ""
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = API.detect.method
        
        let _ = session.synchronousDataTask(urlrequest: urlRequest)
        let (data, _, error) = URLSession.shared.synchronousDataTask(urlrequest: urlRequest)
        if let error = error {
            print("DictionaryUtility: \(error)")
        }
        else {
            do {
                let json = try JSON(data: data!)
                
                return json["data"]["detections"][0][0]["language"].string!
            } catch {
            }
        }
        
        return ""
    }
    
    /**
        Returns a list of supported languages for translation.
    
        - Parameters:
            - target: The target language code for the results. If specified, then the language names are returned in the name field of the response, localized in the target language. If you do not supply a target language, then the name field is omitted from the response and only the language codes are returned.
            - model: The translation model of the supported languages. Can be either base to return languages supported by the Phrase-Based Machine Translation (PBMT) model, or nmt to return languages supported by the Neural Machine Translation (NMT) model. If omitted, then all supported languages are returned. Languages supported by the NMT model can only be translated to or from English (en).
            - completion: A completion closure with an array of Language structures and an error if there is.
    */
    public func languages(target: String = "en", model: String = "base") -> [String] {
        guard var urlComponents = URLComponents(string: API.languages.url) else {
            return [""]
        }
        
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "key", value: apiKey))
        queryItems.append(URLQueryItem(name: "target", value: target))
        queryItems.append(URLQueryItem(name: "model", value: model))
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            
            return [""]
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = API.languages.method
        
        let _ = session.synchronousDataTask(urlrequest: urlRequest)
        let (data, _, error) = URLSession.shared.synchronousDataTask(urlrequest: urlRequest)
        if let error = error {
            print("DictionaryUtility: \(error)")
        }
        else {
            do {
                let json = try JSON(data: data!)
                
                var value = [String]()
                for langauges in json["data"]["languages"].arrayValue {
                    value.append(langauges["language"].string!)
                }
                return value
                
            } catch {
            }
        }
        
        return [""]
    }
    
}
