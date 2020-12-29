//
//  UDCTechnicalDocument.swift
//  UniversalDocumentController
//
//  Created by Kumar Muthaiah on 12/11/18.
//

import Foundation

public class UDCDocumentModel : Codable {
    public var _id: String  = ""
    public var name: String = ""
    public var udcDocumentType = UDCDocumentType.None.name
    public var documentInformationModel: String = ""
    public var documentModel: String? = ""
    public var documentChatModel: String = ""
    public var documentNotificationModel: String = ""
    public var documentHistoryModel: String = ""
    public var documentTestModel: String = ""

    public init() {
        
    }
}
