//
//  DocumentAppendWordRequest.swift
//  Universe Docs
//
//  Created by Kumar Muthaiah on 20/02/19.
//  Copyright © 2019 Universe Docs. All rights reserved.
//

import Foundation
import Universe_Docs_Document

public class DocumentAppendItemRequest : Codable {
    public var _id: String = ""
    /// In which tree level the category exist?
    public var treeLevel: Int = 0
    /// In the tree level, which list item?
    public var nodeIndex: Int = 0
    public var cursorIndex: Int = 0
    public var sentenceIndex: Int = 0
    public var itemModel: String = ""
    public var documentId: String = ""
    public var parentId: String = ""
    public var nodeId: String? = ""
    public var udcDocumentTypeIdName: String = ""
    public var udcProfile = [UDCProfile]()
    
    public init() {
        
    }
}
