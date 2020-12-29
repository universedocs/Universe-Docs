//
//  DocumentGetViewTypeConfigurationResponse.swift
//  Universe Docs Brain
//
//  Created by Kumar Muthaiah on 24/08/19.
//

import Foundation

public class DocumentGetViewConfigurationResponse : Codable {
    public var _id: String = ""
    public var uvcOptionViewModel = [UVCOptionViewModel]()
    
    public init() {
        
    }
}
