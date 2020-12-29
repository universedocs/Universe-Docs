//
//  DocumentInsertItemData.swift
//  Universe Docs
//
//  Created by Kumar Muthaiah on 20/02/19.
//  Copyright © 2019 Universe Docs. All rights reserved.
//

import Foundation
import Universe_Docs_Document

public class DocumentItemData : Codable {
    public var _id: String = ""
    /// In which tree level the category exist?
    public var treeLevel: Int = 0
    /// In the tree level, which list item?
    public var nodeIndex: Int = 0
    public var itemIndex: Int = 0
    public var sentenceIndex: Int = 0
    public var uvcDocumentModel = UVCDocumentModel()
    
    public init() {
        
    }
}
