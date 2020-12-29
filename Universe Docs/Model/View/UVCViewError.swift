//
//  UVCViewError.swift
//  UniversalViewController
//
//  Created by Kumar Muthaiah on 16/11/18.
//  Copyright © 2018 Kumar Muthaiah. All rights reserved.
//

import Foundation

public enum UVCViewError: Error {
    /// "No Database Specified"
    case viewItemNotFound(String)
    
    /// Error with detail message.
    case error(String)
    
    case noError
    
    case failedToGenerateView
    
    /// Default value when created is .noError
    init(){
        self = .noError
    }
    
    /// String representation of the error enum value.
    public func string() -> String {
        switch self {
        case .viewItemNotFound:
            return "View Item Not Found"
            
        case .failedToGenerateView:
            return "Failed to generate view"
       
        default:
            return "Error"
        }
    }
}
