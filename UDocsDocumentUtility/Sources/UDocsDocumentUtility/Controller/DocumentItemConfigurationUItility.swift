//
//  DocumentItemConfigurationUItility.swift
//  Universe Docs Brain
//
//  Created by Kumar Muthaiah on 07/03/20.
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
import UDocsDatabaseModel
import UDocsNeuronModel
import UDocsNeuronUtility
import UDocsDocumentModel

public class DocumentItemConfigurationUtility {
    var neuronName: String = ""
    var neuronUtility: NeuronUtility?
    var documentParser = DocumentParser()
    
    var udbcDatabaseOrm: UDBCDatabaseOrm?
    
    public init() {
        
    }
    
    public func setNeuronUtility(neuronUtility: NeuronUtility, neuronName: String) {
        self.neuronUtility = neuronUtility
    }
    
    public func setUDBCDatabaseOrm(udbcDatabaseOrm: UDBCDatabaseOrm, neuronName: String) {
        self.udbcDatabaseOrm = udbcDatabaseOrm
        neuronUtility!.setUDBCDatabaseOrm(udbcDatabaseOrm: udbcDatabaseOrm, neuronName: neuronName)
        documentParser.setNeuronUtility(neuronUtility: self.neuronUtility!,  neuronName: neuronName)
        documentParser.setUDBCDatabaseOrm(udbcDatabaseOrm: udbcDatabaseOrm, neuronName: neuronName)
    }
    public func getDocumentItemConfiguration(name: String, udcDocumentItem: UDCDocumentGraphModel, udcDocumentId: String, neuronResponse: inout NeuronRequest, language: String, udcProfile: [UDCProfile]) throws -> [UDCSentencePatternDataGroupValue]? {
        var udcSentencePatternDataGroupValueArray = [UDCSentencePatternDataGroupValue]()
        let udcSentencePatternDataGroupValue = UDCSentencePatternDataGroupValue()
        
        let databaseOrmResultUDCDocument = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentId)
        if databaseOrmResultUDCDocument.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocument.databaseOrmError[0].name, description: databaseOrmResultUDCDocument.databaseOrmError[0].description))
            udcSentencePatternDataGroupValueArray.append(udcSentencePatternDataGroupValue)
            return udcSentencePatternDataGroupValueArray
        }
        let udcDocument = databaseOrmResultUDCDocument.object[0]
        
        let databaseOrmResultUDCDocumentConfig = UDCDocument.get(udbcDatabaseOrm: udbcDatabaseOrm!, udcProfile: udcProfile, udcDocumentTypeIdName: "UDCDocumentType.DocumentItemConfiguration", idName: udcDocument.idName, language: language)
        if databaseOrmResultUDCDocumentConfig.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCDocumentConfig.databaseOrmError[0].name, description: databaseOrmResultUDCDocumentConfig.databaseOrmError[0].description))
            udcSentencePatternDataGroupValueArray.append(udcSentencePatternDataGroupValue)
            return udcSentencePatternDataGroupValueArray
        }
        let udcDocumentConfig = databaseOrmResultUDCDocumentConfig.object[0]
        
        let databaseOrmResult = UDCDocumentGraphModel.get(collectionName: "UDCDocumentItemConfiguration", udbcDatabaseOrm: udbcDatabaseOrm!, id: udcDocumentConfig.udcDocumentGraphModelId, language: language)
        if databaseOrmResult.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResult.databaseOrmError[0].name, description: databaseOrmResult.databaseOrmError[0].description))
            udcSentencePatternDataGroupValueArray.append(udcSentencePatternDataGroupValue)
            return udcSentencePatternDataGroupValueArray
        }
        let udcDocumentItemConfiguration = databaseOrmResult.object[0]
        var fieldValueMap = [String: [UDCSentencePatternDataGroupValue]]()
        documentParser.getField(fieldidName: name, childrenId: udcDocumentItemConfiguration.childrenId, fieldValue: &fieldValueMap, udcDocumentTypeIdName: "UDCDocumentType.DocumentItemConfiguration", documentLanguage: language)
        return fieldValueMap[name]
    }
}
