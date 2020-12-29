//
//  USCGenerateAuthentication.swift
//  UniversalProfileController
//
//  Created by Kumar Muthaiah on 25/10/18.
//
//Copyright 2020 Kumar Muthaiah
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
import Foundation
import UDocsSecurityNeuronModel

public class USCGenerateApplicationAuthentication {
    var applicationTag: String = ""
    
    public init(applicationTag: String) {
        self.applicationTag = applicationTag
    }
    
    public func generateAuthentication(type: String) -> AnyObject {
        var authenticationObject: AnyObject?
        
        if type == USCApplicationAuthenticationType.SecurityTokenAuthentication.name {
            authenticationObject = generateSecurityTokenAuthentication()
        }
        
        return authenticationObject!
    }
    
    private func generateSecurityTokenAuthentication() -> USCSecurityTokenAuthentication {
        let uscSecurityTokenAuthentication = USCSecurityTokenAuthentication()
        let uRandom = URandom()
        uscSecurityTokenAuthentication.securityToken = uRandom.secureToken.replacingOccurrences(of: "-", with: "a")
        return uscSecurityTokenAuthentication
    }
    
}
