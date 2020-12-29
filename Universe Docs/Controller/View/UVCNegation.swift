//
//  UVCOnOff.swift
//  Universe Docs
//
//  Created by Kumar Muthaiah on 12/02/19.
//  Copyright © 2019 Universe Docs. All rights reserved.
//

import Foundation

public class UVCOnOff : Codable {
    public var _id: String = ""
    public var name: String = ""
    public var isEditable: Bool = false
    public var isSelected: Bool = false
    public var description: String = ""
    public var uvcText = UVCText()
    public var parentId = [String]()
    public var childrenId = [String]()
    public var path = [String]()
    
    public init() {
        
    }
}
