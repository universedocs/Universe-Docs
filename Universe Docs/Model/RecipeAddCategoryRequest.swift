//
//  RecipeAddCategoryRequest.swift
//  Universe Docs
//
//  Created by Kumar Muthaiah on 18/02/19.
//  Copyright © 2019 Universe Docs. All rights reserved.
//

import Foundation
import Universe_Docs_Document

/// Recipe add category request
public class DocumentAddCategoryRequest : Codable {
    public var _id: String = ""
    /// Document id of the document containing category. If not empty
    public var documentId: String = ""
    /// In which tree level the category exist?
    public var treeLevel: Int = 0
    /// In the tree level, which list item?
    public var treeListIndex: Int = 0
    /// Model of the document. Contains category details
    public var udcDocumentModel = UDCDocumentModel2()
    
    public init() {
        
    }
}
