//
//  DocumentGraphGetPhotoRequest.swift
//  Universe Docs Brain
//
//  Created by Kumar Muthaiah on 13/08/19.
//

import Foundation
 
public class DocumentGetPhotoRequest : Codable {
    public var _id: String = ""
    public var documentId: String = ""
    public var udcDocumentTypeIdName: String = ""
    public var isOption: Bool = false
    public var udcPhotoDataId: String = ""
    public var udcProfile = [UDCProfile]()
    public var documentLanguage: String = ""
    public var udcDocumentItemId: String = ""
    
    public init() {
        
    }
}
