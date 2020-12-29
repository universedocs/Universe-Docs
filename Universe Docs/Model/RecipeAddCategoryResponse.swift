//
//  RecipeAddCategoryResponse.swift
//  Universe Docs
//
//  Created by Kumar Muthaiah on 18/02/19.
//  Copyright © 2019 Universe Docs. All rights reserved.
//

import Foundation
import Universe_Docs_Document

/// Recipe add category response
public class DocumentAddCategoryResponse : Codable {
    public var _id: String = ""
    /// Document id for the document containing category
    public var documentId: String = ""
    // View of the recipe document containing category
    public var uvcDocumentModel = UVCDocumentModel()
    // Model of the recipe document after updated by the server
    public var udcDocumentModel = UDCDocumentModel2()
    
    public init() {
        
    }
}
