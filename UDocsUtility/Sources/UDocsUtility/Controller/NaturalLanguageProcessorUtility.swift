//
//  NaturalLanguageProcessorUtility.swift
//  Universe Docs Brain
//
//  Created by Kumar Muthaiah on 04/11/19.
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
import NaturalLanguage

public class NaturalLanguageProcessorUtility {
    public init() {
        
    }
    
    public func process(text: String, word: inout [String]) {
        #if targetEnvironment(macCatalyst)
            let tokenizer = NLTokenizer(unit: .word)
            tokenizer.string = text
            
            tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { tokenRange, _ in
                word.append(String(text[tokenRange]))
                return true
            }
        #endif
    }
    
    public func process(text: String, word: inout [String], wordTag: inout [String], language: inout String) {
        #if targetEnvironment(macCatalyst)
            let tagger = NLTagger(tagSchemes: [.lexicalClass])
            tagger.string = text
            language = tagger.dominantLanguage.debugDescription
            let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace]
            tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lexicalClass, options: options) { tag, tokenRange in
                if let tag = tag {
                    word.append(String(text[tokenRange]))
                    wordTag.append(tag.rawValue)
                }
                return true
            }
        #endif
    }
}
