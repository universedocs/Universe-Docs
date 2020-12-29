//
//  UVCPopoverNode.swift
//  UniversalViewController
//
//  Created by Kumar Muthaiah on 19/12/18.
//  Copyright © 2018 Kumar Muthaiah. All rights reserved.
//

import Foundation

public class UVCPopoverNode : Codable {
    public var _id: String = ""
    public var name: String = ""
    public var description: String = ""
    public var object: String = ""
    public var isEditableMode: Bool = false
    public var path = [String]()
    public var level: Int = 0
    public var language: String = ""
    public var children = [UVCPopoverNode]()
    public var childrenId = [String]()

    public init() {
        
    }

    static public func getNodes(name: [String]) -> [UVCPopoverNode] {
        var uvcPopoverNodeList = [UVCPopoverNode]()
        for n in name {
            let uvcPopoverNode = UVCPopoverNode()
            uvcPopoverNode.name = n
            uvcPopoverNodeList.append(uvcPopoverNode)
        }
        
        return uvcPopoverNodeList
    }
    
    static public func getNode(name: String) -> UVCPopoverNode {
        let uvcPopoverNode = UVCPopoverNode()
        uvcPopoverNode.name = name
        return uvcPopoverNode
    }
    
    static public func getNode(name: String, description: String, object: String, isEditableMode: Bool, path: [String], level: Int, language: String, children: [UVCPopoverNode]) -> UVCPopoverNode {
        let uvcPopoverNode = UVCPopoverNode()
        uvcPopoverNode.name = name
        uvcPopoverNode.description = description
        uvcPopoverNode.object = object
        uvcPopoverNode.isEditableMode = isEditableMode
        uvcPopoverNode.path.append(contentsOf: path)
        uvcPopoverNode.level = level
        uvcPopoverNode.language = language
        uvcPopoverNode.children.append(contentsOf: children)
        return uvcPopoverNode
    }
}
