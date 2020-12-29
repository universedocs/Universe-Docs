//
//  UDCGrammarUtility.swift
//  Universe Docs Document
//
//  Created by Kumar Muthaiah on 28/01/19.
//  Copyright © 2019 Universe Docs. All rights reserved.
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
import UDocsDocumentModel

public class UDCGrammarUtility {
    
    public init() {
        
    }
    
    // Adds sentence pattern data group value to existing sentence pattern
    public func getSetencePattern(udcSentencePattern: inout UDCSentencePattern, udcSentencePatternDataGroupValue: [UDCSentencePatternDataGroupValue]) {
        if udcSentencePattern.udcSentencePatternData.count == 0 {
            // Add new data
            udcSentencePattern.udcSentencePatternData.append(UDCSentencePatternData())
            // Add new data group
            udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup.append(UDCSentencePatternDataGroup())
            
            udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].category = "UDCGrammarCategory.Sentence"
            // Add given data group value
            udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.append(contentsOf: udcSentencePatternDataGroupValue)
        } else {
            let sentencePatternData = udcSentencePattern.udcSentencePatternData[udcSentencePattern.udcSentencePatternData.count - 1]
            let sentencePatternDataGroup = sentencePatternData.udcSentencePatternDataGroup[sentencePatternData.udcSentencePatternDataGroup.count - 1]
            
            sentencePatternDataGroup.udcSentencePatternDataGroupValue.append(contentsOf: udcSentencePatternDataGroupValue)
        }
    }
//    
//    public func getSentencePatternDataGroupValue(udcSentencePatternDataGroupValue: [UDCSentencePatternDataGroupValue]) -> [UDCSentencePatternDataGroupValue] {
////        var udcSentencePatternDataGroupValueArray = [UDCSentencePatternDataGroupValue]()
////        for udcspdgv in udcSentencePatternDataGroupValue {
////            var udcSentencePatternDataGroupValueLocal = UDCSentencePatternDataGroupValue()
////            udcSentencePatternDataGroupValueLocal._id = udcspdgv._id
////            udcSentencePatternDataGroupValueLocal.category = udcspdgv.category
////            udcSentencePatternDataGroupValueLocal.endCategory = udcspdgv.endCategory
////            udcSentencePatternDataGroupValueLocal.isCountable = udcspdgv.isCountable
////            udcSentencePatternDataGroupValueLocal.isSubject = udcspdgv.isSubject
////            udcSentencePatternDataGroupValueLocal.item = udcspdgv.item
////            udcSentencePatternDataGroupValueLocal.itemIdName = udcspdgv.itemIdName
////            udcSentencePatternDataGroupValueLocal.itemState = udcspdgv.itemState
////            udcSentencePatternDataGroupValueLocal.itemType = udcspdgv.itemType
////            if udcspdgv.referenceTargetId.count > 0 {
////                udcSentencePatternDataGroupValueLocal.referenceSourceId.append(contentsOf: udcspdgv.referenceTargetId)
////            }
////            if udcspdgv.referenceSourceId.count > 0 {
////                udcSentencePatternDataGroupValueLocal.referenceSourceId.append(contentsOf: udcspdgv.referenceSourceId)
////            }
////            udcSentencePatternDataGroupValueLocal.tense = udcspdgv.tense
//            udcSentencePatternDataGroupValueArray.append(udcSentencePatternDataGroupValueLocal)
//        }
//        
//        return udcSentencePatternDataGroupValueArray
//    }
    //
    //    public func getSetencePattern(udcSentencePattern: inout UDCSentencePattern, udcSentencePatternDataGroupValue: [UDCSentencePatternDataGroupValue]) {
    //        if udcSentencePattern.udcSentencePatternData.count == 0 {
    //            udcSentencePattern.udcSentencePatternData.append(UDCSentencePatternData())
    //        }
    //        let sentencePatternData = udcSentencePattern.udcSentencePatternData[udcSentencePattern.udcSentencePatternData.count - 1]
    //        sentencePatternData.udcSentencePatternDataGroup.append(UDCSentencePatternDataGroup())
    //        sentencePatternData.udcSentencePatternDataGroup[sentencePatternData.udcSentencePatternDataGroup.count - 1].udcSentencePatternDataGroupValue.append(contentsOf: udcSentencePatternDataGroupValue)
    //    }
    
    /// Adds a sentence pattern to existing sentence pattern
    public func getSetencePattern(udcSentencePattern: inout UDCSentencePattern, udcSentencePatternIn: UDCSentencePattern, udcSentencePatternDataGroupValue: UDCSentencePatternDataGroupValue) {
        if udcSentencePattern.udcSentencePatternData.count == 0 {
            // Add new data
            udcSentencePattern.udcSentencePatternData.append(UDCSentencePatternData())
            // Add new data group
            udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup.append(UDCSentencePatternDataGroup())
            
            udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].category = "UDCGrammarCategory.Sentence"
            // Add given data group value
            udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue.append(UDCSentencePatternDataGroupValue())
            udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].category = "UDCGrammarCategory.Sentence"
            udcSentencePattern.udcSentencePatternData[0].udcSentencePatternDataGroup[0].udcSentencePatternDataGroupValue[0].udcSentencePattern = udcSentencePattern
        } else {
            
            let sentencePatternData = udcSentencePattern.udcSentencePatternData[udcSentencePattern.udcSentencePatternData.count - 1]
            let sentencePatternDataGroup = sentencePatternData.udcSentencePatternDataGroup[sentencePatternData.udcSentencePatternDataGroup.count - 1]
            sentencePatternDataGroup.udcSentencePatternDataGroupValue[sentencePatternDataGroup.udcSentencePatternDataGroupValue.count - 1].udcSentencePattern = udcSentencePattern
        }
    }
}
