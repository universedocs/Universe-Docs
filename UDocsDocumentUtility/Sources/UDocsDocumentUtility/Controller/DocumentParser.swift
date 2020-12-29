//
//  DocumentParser.swift
//  Universe Docs Brain
//
//  Created by Kumar Muthaiah on 17/01/20.
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
import UDocsNeuronModel
import UDocsNeuronUtility
import UDocsDatabaseModel
import UDocsDatabaseUtility
import UDocsDocumentModel

public class DocumentParser {
    
    var udbcDatabaseOrm: UDBCDatabaseOrm?
    var neuronUtility: NeuronUtility?
    public init() {
        
    }
    
    
     public func setNeuronUtility(neuronUtility: NeuronUtility, neuronName: String) {
         self.neuronUtility = neuronUtility
     }
     
    public func setUDBCDatabaseOrm(udbcDatabaseOrm: UDBCDatabaseOrm, neuronName: String) {
        self.udbcDatabaseOrm = udbcDatabaseOrm
    }
    
    public func getUDCProfile(udcProfile: [UDCProfile], idName: String) ->String {
           var profileId = ""
           for udcp in udcProfile {
               if udcp.udcProfileItemIdName == idName {
                   profileId = udcp.profileId
                   break
               }
           }
           
           return profileId
       }
    
    public func splitDocumentItem(udcSentencePatternDataGroupValueParam: [UDCSentencePatternDataGroupValue], language: String) -> [String] {
        var documentItemSplit = [String]()
        
        if udcSentencePatternDataGroupValueParam.count == 0 {
            return documentItemSplit
        }
       
        var text = [String]()
        var startCaptureText: Bool = false
        var noSeparator: Bool = true
        var noTranslationSeparator: Bool = true
        if language == "en" {
            startCaptureText = true
        }
        var addToArray: Bool = false
        var udcSentencePatternDataGroupValueLocal = [UDCSentencePatternDataGroupValue]()
        for udcspdgv in udcSentencePatternDataGroupValueParam {
            let udcSentencePatternDataGroupValue = UDCSentencePatternDataGroupValue()
            udcSentencePatternDataGroupValue.item = udcspdgv.item
            udcSentencePatternDataGroupValue.itemIdName = udcspdgv.itemIdName
            udcSentencePatternDataGroupValue.uvcViewItemType = udcspdgv.uvcViewItemType
            udcSentencePatternDataGroupValueLocal.append(udcSentencePatternDataGroupValue)
            if udcspdgv.itemIdName == "UDCDocumentItem.DocumentItemSeparator" {
                noSeparator = false
            }
            if udcspdgv.itemIdName == "UDCDocumentItem.TranslationSeparator" {
                noTranslationSeparator = false
            }
        }
        
        if noSeparator && noTranslationSeparator {
            startCaptureText = true
            for udcspdgv in udcSentencePatternDataGroupValueLocal {
                if udcspdgv.itemIdName == "UDCDocumentItem.TranslationSeparator" && language != "en" {
                    startCaptureText = true
                    continue
                }
                if startCaptureText && udcspdgv.uvcViewItemType != "UVCViewItemType.Photo" {
                    text.append(udcspdgv.item!)
                }
            }
            documentItemSplit.append(text.joined(separator: " "))
            return documentItemSplit
        }
        if udcSentencePatternDataGroupValueLocal[0].itemIdName == "UDCDocumentItem.DocumentItemSeparator" {
            let udcSentencePatternDataGroupValue = UDCSentencePatternDataGroupValue()
            udcSentencePatternDataGroupValue.item = ""
            udcSentencePatternDataGroupValueLocal.insert(udcSentencePatternDataGroupValue, at: 0)
        } else if udcSentencePatternDataGroupValueLocal[udcSentencePatternDataGroupValueLocal.count - 1].itemIdName == "UDCDocumentItem.DocumentItemSeparator" {
            let udcSentencePatternDataGroupValue = UDCSentencePatternDataGroupValue()
            udcSentencePatternDataGroupValue.item = ""
            udcSentencePatternDataGroupValueLocal.append(udcSentencePatternDataGroupValue)
        }
        
        for udcspdgv in udcSentencePatternDataGroupValueLocal {
            if udcspdgv.itemIdName == "UDCDocumentItem.TranslationSeparator" && language != "en" {
                startCaptureText = true
                continue
            }
            if startCaptureText {
                if udcspdgv.itemIdName == "UDCDocumentItem.DocumentItemSeparator" {
                    addToArray = true
                    continue
                }
                if addToArray {
                    addToArray = false
                    documentItemSplit.append(text.joined())
                    text.removeAll()
                }
                if udcspdgv.uvcViewItemType != "UVCViewItemType.Photo" {
                    text.append(udcspdgv.item!)
                }
            }
        }
        documentItemSplit.append(text.joined(separator: " "))
        print("Splitted: \(documentItemSplit)")
        return documentItemSplit
    }
    
    public func getCurrentFieldValue(udcDocumentGraphModel: UDCDocumentGraphModel, currentValue: String, fieldValue: inout [UDCSentencePatternDataGroupValue], fieldIdName: inout String, fieldFound: inout Bool, parentName: inout String, udcDocumentTypeIdName: String) {
        fieldFound = false
        
        if udcDocumentGraphModel.level <= 1 {
            return
        }
        
        if udcDocumentGraphModel.getSentencePatternDataGroupValue().count == 0 {
            return
        }
        
        let databaseOrmResultUDCDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentGraphModel.parentId[0])
        let parent = databaseOrmResultUDCDocumentGraphModel.object[0]
        parentName = parent.idName
        
        for udcspdgv in udcDocumentGraphModel.getSentencePatternDataGroupValue() {
            if udcspdgv.item != ":" && !fieldFound {
                fieldIdName = udcspdgv.itemIdName
                continue
            }
            if udcspdgv.item == ":" {
                fieldFound = true
                continue
            }
            if fieldFound {
                if udcspdgv.item != "," && currentValue != "," {
                    fieldValue.append(udcspdgv)
                }
            }
        }
        
    }
    
    
    public func getField(fieldidName: String, childrenId: [String], fieldValue: inout [String: [UDCSentencePatternDataGroupValue]], udcDocumentTypeIdName: String, documentLanguage: String) {
        var fieldFound = false
        
        for child in childrenId {
            let databaseOrmResultUDCDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: child)
            let udcDocumentGraphModel: UDCDocumentGraphModel?
            if databaseOrmResultUDCDocumentGraphModel.databaseOrmError.count == 0 {
                udcDocumentGraphModel = databaseOrmResultUDCDocumentGraphModel.object[0]
                if udcDocumentGraphModel!.level > 1 {
                    if udcDocumentGraphModel!.getSentencePatternDataGroupValue().count == 0 {
                        continue
                    }
                    
                    var idName = ""
                    fieldFound = false
                    for udcspdgv in udcDocumentGraphModel!.getSentencePatternDataGroupValue() {
                        if udcspdgv.item != ":" && !fieldFound {
                            idName = udcspdgv.itemIdName
                            continue
                        }
                        if udcspdgv.item == ":" {
                            if idName == fieldidName {
                                fieldFound = true
                            }
                            continue
                        }
                        if fieldFound {
                            if udcspdgv.item != "," {
                                if fieldValue[idName] == nil {
                                    fieldValue[idName] = [UDCSentencePatternDataGroupValue]()
                                }
                                fieldValue[idName]!.append(udcspdgv)
                            }
                        }
                    }
                }
                if fieldFound && fieldValue.count > 0 {
                    break
                }
                if fieldValue.count == 0 && udcDocumentGraphModel!.childrenId.count > 0 {
                    getField(fieldidName: fieldidName, childrenId: udcDocumentGraphModel!.childrenId, fieldValue: &fieldValue, udcDocumentTypeIdName: udcDocumentTypeIdName, documentLanguage: documentLanguage)
                }
            }
            
        }
    }
    
    public func setFieldValue(fieldidName: String, childrenId: [String], fieldValue: [UDCSentencePatternDataGroupValue], udcDocumentTypeIdName: String, documentLanguage: String, udcDocumentGraphModelResult: inout UDCDocumentGraphModel, fieldFound: inout Bool, modelId: inout String, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) {
        
        for child in childrenId {
            let databaseOrmResultUDCDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: child)
            let udcDocumentGraphModel: UDCDocumentGraphModel?
            if databaseOrmResultUDCDocumentGraphModel.databaseOrmError.count == 0 {
                udcDocumentGraphModel = databaseOrmResultUDCDocumentGraphModel.object[0]
                modelId = udcDocumentGraphModel!._id
                if udcDocumentGraphModel!.level > 1 {
                    if udcDocumentGraphModel!.getSentencePatternDataGroupValue().count == 0 {
                        continue
                    }
                    
                    var idName = ""
                    fieldFound = false
                    var valueIndex = 0
                    for (udcspdgvIndex, udcspdgv) in udcDocumentGraphModel!.getSentencePatternDataGroupValue().enumerated() {
                        if udcspdgv.item != ":" && !fieldFound {
                            idName = udcspdgv.itemIdName
                            continue
                        }
                        if udcspdgv.item == ":" {
                            if idName == fieldidName {
                                fieldFound = true
                                valueIndex = udcspdgvIndex + 1
                                break
                            }
                            continue
                        }
                    }
                    if fieldFound {
                        if udcDocumentGraphModel!.getSentencePatternDataGroupValue().count-1 > valueIndex {
                            for _ in valueIndex...udcDocumentGraphModel!.getSentencePatternDataGroupValue().count-1 {
                                udcDocumentGraphModel!.removeSentencePatternGroupValue(wordIndex: valueIndex)
                            }
                            for udcspdgv in fieldValue {
                                udcDocumentGraphModel!.insertSentencePatternGroupValue(newValue: udcspdgv, wordIndex: valueIndex)
                            }
                        } else {
                            udcDocumentGraphModel!.appendSentencePatternGroupValue(newValue: fieldValue)
                        }
                        udcDocumentGraphModelResult = udcDocumentGraphModel!
                    }
                }
                if fieldFound {
                    break
                }
                if fieldValue.count == 0 && udcDocumentGraphModel!.childrenId.count > 0 {
                    setFieldValue(fieldidName: fieldidName, childrenId: udcDocumentGraphModel!.childrenId, fieldValue: fieldValue, udcDocumentTypeIdName: udcDocumentTypeIdName, documentLanguage: documentLanguage, udcDocumentGraphModelResult: &udcDocumentGraphModelResult, fieldFound: &fieldFound, modelId: &modelId, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
                }
            }
            
        }
    }
    
    public func getFields(childrenId: [String], fieldValue: inout [String: [UDCSentencePatternDataGroupValue]], udcDocumentTypeIdName: String, documentLanguage: String) {
        var fieldFound = false
        
        for child in childrenId {
            let databaseOrmResultUDCDocumentGraphModel = UDCDocumentGraphModel.get(collectionName: neuronUtility!.getCollectionName(udcDocumentTypeIdName: udcDocumentTypeIdName)!, udbcDatabaseOrm: udbcDatabaseOrm!, id: child, language: documentLanguage)
            if databaseOrmResultUDCDocumentGraphModel.databaseOrmError.count == 0 {
                let udcDocumentGraphModel = databaseOrmResultUDCDocumentGraphModel.object[0]
                
                if udcDocumentGraphModel.level > 1 {
                    if udcDocumentGraphModel.getSentencePatternDataGroupValue().count == 0 {
                        continue
                    }
                    
                    var idName = ""
                    fieldFound = false
                    for udcspdgv in udcDocumentGraphModel.getSentencePatternDataGroupValue() {
                        if udcspdgv.item != ":" && !fieldFound {
                            idName = udcspdgv.itemIdName
                            continue
                        }
                        if udcspdgv.item == ":" {
                            fieldFound = true
                            continue
                        }
                        if fieldFound {
                            if udcspdgv.item != "," {
                                if fieldValue[idName] == nil {
                                    fieldValue[idName] = [UDCSentencePatternDataGroupValue]()
                                }
                                fieldValue[idName]!.append(udcspdgv)
                            }
                        }
                    }
                }
                if udcDocumentGraphModel.childrenId.count > 0 {
                    getFields(childrenId: udcDocumentGraphModel.childrenId, fieldValue: &fieldValue, udcDocumentTypeIdName: udcDocumentTypeIdName, documentLanguage: documentLanguage)
                }
            }
            
        }
        
    }
}
