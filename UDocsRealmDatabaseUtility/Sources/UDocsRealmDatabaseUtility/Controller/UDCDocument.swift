//
//  Test.swift
//  UDocsBrainRealmDatabase
//
//  Created by Kumar Muthaiah on 13/06/20.
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
import RealmSwift

@objcMembers public class UDCDocument : Object, Codable {
    dynamic var _id: String = ""
    dynamic var idName: String = ""
    dynamic var documentGroupId: String = ""
    dynamic var categoryId: String = ""
    dynamic var modelVersion: String = ""
    dynamic var modelName: String = ""
    dynamic var modelDescription: String = ""
    dynamic var modelTechnicalName: String = ""
    dynamic var version: String = ""
    dynamic var name: String = ""
    dynamic var desc: String = ""
    dynamic var language: String = ""
    dynamic var technicalName: String = ""
    dynamic var referenceId: String = ""
    dynamic var udcDocumentGraphModelId: String = ""
    dynamic var udcDocumentTypeIdName: String = ""
    dynamic var udcDocumentVisibilityType: String = ""
    
    dynamic var childId = List<String>()
    dynamic var test = List<Test>()
    
    public required init() {
        
    }
    
    override public static func primaryKey() -> String? {
        return "_id"
    }
    
    enum CodingKeys: String, CodingKey {
        case _id
        case idName
        case documentGroupId
        case categoryId
        case modelVersion
        case modelName
        case modelDescription
        case modelTechnicalName
        case version
        case name
        case desc
        case language
        case technicalName
        case referenceId
        case udcDocumentGraphModelId
        case udcDocumentTypeIdName
        case udcDocumentVisibilityType
        case childId
        case test
    }
    
    required convenience public init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        _id = try container.decode(String.self, forKey: ._id)
        idName = try container.decode(String.self, forKey: .idName)
        documentGroupId = try container.decode(String.self, forKey: .documentGroupId)
        categoryId = try container.decode(String.self, forKey: .categoryId)
        modelVersion = try container.decode(String.self, forKey: .modelVersion)
        modelName = try container.decode(String.self, forKey: .modelName)
        modelDescription = try container.decode(String.self, forKey: .modelDescription)
        modelTechnicalName = try container.decode(String.self, forKey: .modelTechnicalName)
        version = try container.decode(String.self, forKey: .version)
        name = try container.decode(String.self, forKey: .name)
        desc = try container.decode(String.self, forKey: .desc)
        language = try container.decode(String.self, forKey: .language)
        technicalName = try container.decode(String.self, forKey: .technicalName)
        referenceId = try container.decode(String.self, forKey: .referenceId)
        udcDocumentGraphModelId = try container.decode(String.self, forKey: .udcDocumentGraphModelId)
        udcDocumentTypeIdName = try container.decode(String.self, forKey: .udcDocumentTypeIdName)
        udcDocumentVisibilityType = try container.decode(String.self, forKey: .udcDocumentVisibilityType)
        let childIdArray = try container.decode([String].self, forKey: .childId)
        childId.append(objectsIn: childIdArray)
        let testArray = try container.decode([Test].self, forKey: .test)
        test.append(objectsIn: testArray)
    }
   
    
   
}
