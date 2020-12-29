//
//  GetObjectControllerViewResponse.swift
//  Universe Docs Brain
//
//  Created by Kumar Muthaiah on 03/02/19.
//

import Foundation

public class GetObjectControllerViewResponse : Codable {
    public var _id: String = ""
    public var controllerText = [String]()
    public var photoName = [String]()
    
    public init() {
        
    }
}
