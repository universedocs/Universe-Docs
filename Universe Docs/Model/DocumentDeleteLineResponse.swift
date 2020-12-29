//
//  DocumentDeleteLineResponse.swift
//  Universe Docs Brain
//
//  Created by Kumar Muthaiah on 16/07/19.
//

import Foundation

public class DocumentDeleteLineResponse : Codable {
    public var _id: String = ""
    public var documentItemViewInsertData = [DocumentItemViewData]()
    public var documentItemViewDeleteData = [DocumentItemViewData]()
    public var documentItemViewChangeData = [DocumentItemViewData]()
    
    public init() {
        
    }
}
