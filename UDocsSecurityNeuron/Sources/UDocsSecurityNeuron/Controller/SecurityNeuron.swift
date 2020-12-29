//
//  SecurityNeuron.swift
//  UniversalBrainController
//
//  Created by Kumar Muthaiah on 26/10/18.
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
import UDocsUtility
import UDocsSecurityNeuronModel
import UDocsDatabaseModel
import UDocsProfileModel
import UDocsNeuronModel
import UDocsNeuronUtility
import Alamofire
import UDocsViewModel
import UDocsViewUtility
import UDocsDocumentModel
import UDocsValidationUtility

open class SecurityNeuron : Neuron {
    public static func getRootResponse(neuronSourceId: String) -> NeuronRequest {
        return NeuronRequest()
    }
    var neuronUtility: NeuronUtility? = nil
    var udbcDatabaseOrm: UDBCDatabaseOrm?
    static var dendriteMap: [String : Neuron] = [String : Neuron]()
    private var responseMap: [String : NeuronRequest] = [String : NeuronRequest]()
    static let serialQueue = DispatchQueue(label: "SerialQueue")
    let applicationTag = "com.kumarmuthaiah.workspace.UniversalController"
    let defaultSecurityTokenTimeInterval = 60 * 60 * 24 // 24 hours or 1 day
    let defaultSecurityPinTimeInterval = 60 * 5 // 5 minutes
    
    private init() {
        
    }
    
    private func process(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        print("\(SecurityNeuron.getName()): process")
        
        if neuronRequest.neuronOperation.name == SecurityNeuronOperationType.SecurityControllerView.name {
            try getSecurityControllerView(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else if neuronRequest.neuronOperation.name == SecurityNeuronOperationType.ConnectUser.name {
            try openConnection(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else if neuronRequest.neuronOperation.name == SecurityNeuronOperationType.CreateUserConnection.name {
            try createConnection(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else if neuronRequest.neuronOperation.name == SecurityNeuronOperationType.DisconnectUser.name {
            try closeConnection(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else if neuronRequest.neuronOperation.name == "SecurityNeuronOperationType.ForgotPasswordVerifyIdentity" {
            try forgotPasswordVerifyIdentity(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else if neuronRequest.neuronOperation.name == "SecurityNeuronOperationType.ForgotPasswordVerifySecret" {
            try forgotPasswordVerifySecret(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else if neuronRequest.neuronOperation.name == "SecurityNeuronOperationType.ForgotPasswordChangePassword" {
            try forgotPasswordChangePassword(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        } else {
            print("\(SecurityNeuron.getName()) Invalid Security Operation")
            neuronResponse.neuronOperation.response = true
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: SecurityNeuronErrorType.InvalidSecurityOperation.name, description: SecurityNeuronErrorType.InvalidSecurityOperation.description))
            
        }
        
        neuronResponse.neuronOperation.response = true
        neuronResponse.neuronSource._id = neuronRequest.neuronSource._id
    }
    
    /// Verify identityf for forgot password request
    private func forgotPasswordVerifyIdentity(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let uscForgotPasswordVerifyIdentityRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: USCForgotPasswordVerifyIdentityRequest())
        
        var validationParameters = [String : String]()
        validationParameters["UserName"] = uscForgotPasswordVerifyIdentityRequest.userName
        checkParameters(parameters: validationParameters, neuronResponse: &neuronResponse)
        if neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError!.count > 0 {
            return
        }
        
        // Get Human profile id based on user name
        let upcUserApplicationProfile = getApplicationProfile(userName: uscForgotPasswordVerifyIdentityRequest.userName, upcApplicationProfileId: uscForgotPasswordVerifyIdentityRequest.upcApplicationProfileId, upcCompanyProfileId: uscForgotPasswordVerifyIdentityRequest.upcCompanyProfileId, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        
        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
            return
        }
        let humanProfileId = (upcUserApplicationProfile?.userProfileId)!
        
        // Get human profile
        let databaseOrmResultUPCHumanProfile = UPCHumanProfile.get(udbcDatabaseOrm: udbcDatabaseOrm!, profileId: humanProfileId)
        if databaseOrmResultUPCHumanProfile.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUPCHumanProfile.databaseOrmError[0].name, description: databaseOrmResultUPCHumanProfile.databaseOrmError[0].description))
            return
        }
        let upcHumanProfile = databaseOrmResultUPCHumanProfile.object[0]
        let emailProfileId = upcHumanProfile.upcEmailProfileId
        
        // Get EMail profile based on human profile id
        let databaseOrmResultUPCEMailProfile = UPCEMailProfile.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: emailProfileId)
        if databaseOrmResultUPCEMailProfile.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUPCEMailProfile.databaseOrmError[0].name, description: databaseOrmResultUPCEMailProfile.databaseOrmError[0].description))
            return
        }
        let upcEmailProfile = databaseOrmResultUPCEMailProfile.object[0]
        let eMail = "\(upcEmailProfile.localPart)@\(upcEmailProfile.domain)"
        
        // Get Mailjet API details (credentials)
        let databaseOrmResultUDCApplicationProgramInterface = UDCApplicationProgramInterface.get(udbcDatabaseOrm: udbcDatabaseOrm!, upcApplicationProfileId: uscForgotPasswordVerifyIdentityRequest.upcApplicationProfileId, upcCompanyProfileId: uscForgotPasswordVerifyIdentityRequest.upcCompanyProfileId, apiCompanyProfileIdName: "UPCCompanyProfile.Mailjet")
        if databaseOrmResultUDCApplicationProgramInterface.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUDCApplicationProgramInterface.databaseOrmError[0].name, description: databaseOrmResultUDCApplicationProgramInterface.databaseOrmError[0].description))
            return
        }
        let udcApplicationProgramInterface = databaseOrmResultUDCApplicationProgramInterface.object[0]
        
        // Generate and save the security pin
        let emailSecret = generateRandomDigits(6)
        let uscSecurityPinAuthentication = USCSecurityPinAuthentication()
        uscSecurityPinAuthentication._id = try (udbcDatabaseOrm?.generateId())!
        uscSecurityPinAuthentication.securityPin = emailSecret
        uscSecurityPinAuthentication.expiryTime =  Date().addingTimeInterval(TimeInterval(defaultSecurityPinTimeInterval))
        let databaseOrmResultuscSecurityPinAuthentication =  USCSecurityPinAuthentication.save(udbcDatabaseOrm: udbcDatabaseOrm!, object: uscSecurityPinAuthentication)
        if databaseOrmResultuscSecurityPinAuthentication.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultuscSecurityPinAuthentication.databaseOrmError[0].name, description: databaseOrmResultuscSecurityPinAuthentication.databaseOrmError[0].description))
            return
        }
        
        // Remove if already have security pin for the profile id in user application profile
        for upcUserApplicationAuthentication in (upcUserApplicationProfile?.upcUserApplicationAuthentication)! {
            if upcUserApplicationAuthentication.authenticationType == USCApplicationAuthenticationType.SecurityPinAuthentication.name {
                let databaseOrmResultUPCUserApplicationProfileUpdate = UPCUserApplicationProfile.updatePull(udbcDatabaseOrm: udbcDatabaseOrm!, userProfileId: upcHumanProfile._id, upcApplicationProfileId: uscForgotPasswordVerifyIdentityRequest.upcApplicationProfileId, upcCompanyProfileId: uscForgotPasswordVerifyIdentityRequest.upcCompanyProfileId, upcUserApplicationAuthentication: upcUserApplicationAuthentication) as DatabaseOrmResult<UPCUserApplicationProfile>
                if databaseOrmResultUPCUserApplicationProfileUpdate.databaseOrmError.count > 0 {
                
                    print("Failed to remove security pin in user applciation profile for human profile: "+upcHumanProfile._id)
                }
                let databaseOrmResultUSCSecurityPinAuthentication = USCSecurityPinAuthentication.remove(udbcDatabaseOrm: udbcDatabaseOrm!, id: upcUserApplicationAuthentication.authenticationId) as DatabaseOrmResult<USCSecurityPinAuthentication>
                if databaseOrmResultUSCSecurityPinAuthentication.databaseOrmError.count > 0 {
                    print("Failed to remove security pin for human profile: "+upcHumanProfile._id)
                }
            }
        }
        
        // Store the security pin authentication information in user application profile
        let upcUserApplicationAuthentication = UPCUserApplicationAuthentication()
        upcUserApplicationAuthentication._id = try (udbcDatabaseOrm?.generateId())!
        upcUserApplicationAuthentication.authenticationType = USCApplicationAuthenticationType.SecurityPinAuthentication.name
        upcUserApplicationAuthentication.authenticationId = databaseOrmResultuscSecurityPinAuthentication.id
        upcUserApplicationProfile?.upcUserApplicationAuthentication.append(upcUserApplicationAuthentication)
        let databaseOrmResultUPCUserApplicationProfileUpdate = UPCUserApplicationProfile.updatePush(udbcDatabaseOrm: udbcDatabaseOrm!, userProfileId: upcHumanProfile._id, upcApplicationProfileId: uscForgotPasswordVerifyIdentityRequest.upcApplicationProfileId, upcCompanyProfileId: uscForgotPasswordVerifyIdentityRequest.upcCompanyProfileId, upcUserApplicationAuthentication: upcUserApplicationAuthentication) as DatabaseOrmResult<UPCUserApplicationProfile>
        if databaseOrmResultUPCUserApplicationProfileUpdate.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUPCUserApplicationProfileUpdate.databaseOrmError[0].name, description: databaseOrmResultUPCUserApplicationProfileUpdate.databaseOrmError[0].description))
            return
        }
        
        // Prepare EMail
        let uscMailjetEMailRequest = USCMailjetEMailRequest()
        let uscMailjetMessagesRequest = USCMailjetMessagesRequest()
        uscMailjetMessagesRequest.From.Email = udcApplicationProgramInterface.senderEMail
        uscMailjetMessagesRequest.From.Name = udcApplicationProgramInterface.senderName
        let uscMailjetTo = USCMailjetToRequest()
        uscMailjetTo.Email = eMail
        if !upcHumanProfile.middleName.isEmpty {
            uscMailjetTo.Name = "\(upcHumanProfile.firstName) \(upcHumanProfile.middleName) \(upcHumanProfile.lastName)"
        } else {
            uscMailjetTo.Name = "\(upcHumanProfile.firstName) \(upcHumanProfile.lastName)"
        }
        uscMailjetMessagesRequest.To.append(uscMailjetTo)
        uscMailjetMessagesRequest.Subject = "Universe Docs - Forgot Password"
        uscMailjetMessagesRequest.HtmlPart = getEmailSecretMessage(userFullName: uscMailjetTo.Name, emailSecret: emailSecret)
        uscMailjetEMailRequest.Messages.append(uscMailjetMessagesRequest)
        let jsonUtilityUSCMailjetEMailModel = JsonUtility<USCMailjetEMailRequest>()
        let jsonUSCMailjetEMailModel = jsonUtilityUSCMailjetEMailModel.convertAnyObjectToJson(jsonObject: uscMailjetEMailRequest)
        let parameters = try JSONSerialization.jsonObject(with: jsonUSCMailjetEMailModel.data(using: .utf8, allowLossyConversion: false)!) as? [String: Any]
        
        let credentialData = "\(udcApplicationProgramInterface.userName):\(udcApplicationProgramInterface.password)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString(options: [])
        let headers: HTTPHeaders = ["Authorization": "Basic \(base64Credentials)"]
        
        // Send the EMail
        AF.request(udcApplicationProgramInterface.apiUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: alamoFireResponseHandler)
        
        // Package the response
        let uscForgotPasswordVerifyIdentityResponse = USCForgotPasswordVerifyIdentityResponse()
        uscForgotPasswordVerifyIdentityResponse.upcHumanProfileId = upcHumanProfile._id
        uscForgotPasswordVerifyIdentityResponse.result = true
        let jsonUtilityUSCForgotPasswordVerifyIdentityResponse = JsonUtility<USCForgotPasswordVerifyIdentityResponse>()
        let jsonUSCForgotPasswordVerifyIdentityResponse = jsonUtilityUSCForgotPasswordVerifyIdentityResponse.convertAnyObjectToJson(jsonObject: uscForgotPasswordVerifyIdentityResponse)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonUSCForgotPasswordVerifyIdentityResponse)
    }
    #if os(macOS)
    #if targetEnvironment(macCatalyst)
    private func alamoFireResponseHandler(completion: DataResponse<Any>) {
        do {
            if let json = completion.data {
                let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)

                if let jsonString = String(bytes: jsonData, encoding: String.Encoding.utf8) {
                    let jsonUtilityUSCMailjetEMailResponse = JsonUtility<USCMailjetEMailResponse>()
                    let uscMailjetEMailResponse = jsonUtilityUSCMailjetEMailResponse.convertJsonToAnyObject(json: jsonString)
                    print("Mailjet: \(uscMailjetEMailResponse.Messages.To[0].Email): \(uscMailjetEMailResponse.Messages.Status)")
                }

            }

        } catch {
            print("Error in processing mailjet response")
        }
    }

    #endif
    private func alamoFireResponseHandler(completion: DataResponse<Any, AFError>) {
        do {
            if let json = completion.data {
                let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)

                if let jsonString = String(bytes: jsonData, encoding: String.Encoding.utf8) {
                    let jsonUtilityUSCMailjetEMailResponse = JsonUtility<USCMailjetEMailResponse>()
                    let uscMailjetEMailResponse = jsonUtilityUSCMailjetEMailResponse.convertJsonToAnyObject(json: jsonString)
                    print("Mailjet: \(uscMailjetEMailResponse.Messages.To[0].Email): \(uscMailjetEMailResponse.Messages.Status)")
                }

            }

        } catch {
            print("Error in processing mailjet response")
        }
    }
    #else
    private func alamoFireResponseHandler(completion: DataResponse<Any, AFError>) {
        do {
            if let json = completion.data {
                let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)

                if let jsonString = String(bytes: jsonData, encoding: String.Encoding.utf8) {
                    let jsonUtilityUSCMailjetEMailResponse = JsonUtility<USCMailjetEMailResponse>()
                    let uscMailjetEMailResponse = jsonUtilityUSCMailjetEMailResponse.convertJsonToAnyObject(json: jsonString)
                    print("Mailjet: \(uscMailjetEMailResponse.Messages.To[0].Email): \(uscMailjetEMailResponse.Messages.Status)")
                }

            }

        } catch {
            print("Error in processing mailjet response")
        }
    }
    #endif
    private func getEmailSecretMessage(userFullName: String, emailSecret: String) -> String {
        
        let htmlPart: String = "Hi \(userFullName),<br><br>Your E-Mail Secret is: <b>\(emailSecret)</b><br><br>Enter this secret in UniversalDocs to verify. Don't share with anybody for the safety of your account. Expires after 5 minutes.<br><br>Regards,<br><b>Universe Docs</b>"
        
        return htmlPart
    }
    
    func generateRandomDigits(_ digitNumber: Int) -> String {
        var number = ""
        for i in 0..<digitNumber {
            var randomNumber = arc4random_uniform(10)
            while randomNumber == 0 && i == 0 {
                randomNumber = arc4random_uniform(10)
            }
            number += "\(randomNumber)"
        }
        return number
    }
    
    
    private func callSpecificNeuronForUpdate(neuronRequest: inout NeuronRequest, neuronName: String) throws {
        let neuronRequestLocal = NeuronRequest()
        neuronRequestLocal.neuronSource._id = neuronRequest.neuronSource._id
        neuronRequestLocal.neuronOperation.synchronus = true
        neuronRequestLocal.neuronOperation._id = neuronRequest.neuronOperation._id
        neuronRequestLocal.neuronSource.name = SecurityNeuron.getName()
        neuronRequestLocal.neuronSource.type = SecurityNeuron.getName();
        neuronRequestLocal.neuronOperation.name = neuronRequest.neuronOperation.name
        neuronRequestLocal.neuronOperation.parent = true
        neuronRequestLocal.neuronOperation.neuronData.text = neuronRequest.neuronOperation.neuronData.text
        neuronRequestLocal.neuronTarget.name =  neuronName
        
        neuronUtility!.callNeuron(neuronRequest: neuronRequestLocal)
        
        let neuronResponseLocal = getChildResponse(operationName: neuronRequestLocal.neuronOperation.name)
        
        if neuronResponseLocal.neuronOperation.neuronOperationStatus.neuronOperationError!.count > 0 {
            print("\(SecurityNeuron.getName()) Errors from child neuron: \(neuronRequest.neuronOperation.name))")
            neuronRequest.neuronOperation.response = true
            for noe in neuronResponseLocal.neuronOperation.neuronOperationStatus.neuronOperationError! {
                neuronRequest.neuronOperation.neuronOperationStatus.neuronOperationError?.append(noe)
            }
        } else {
            for noe in neuronResponseLocal.neuronOperation.neuronOperationStatus.neuronOperationSuccess! {
                neuronRequest.neuronOperation.neuronOperationStatus.neuronOperationSuccess?.append(noe)
            }
            print("\(SecurityNeuron.getName()) Success from child neuron: \(neuronRequest.neuronOperation.name))")
            
        }
        
    }
    
    private func forgotPasswordVerifySecret(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let uscForgotPasswordVerifySecretRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: USCForgotPasswordVerifySecretRequest())
        
        var validationParameters = [String : String]()
        validationParameters["EMailSecret"] = uscForgotPasswordVerifySecretRequest.emailSecret
        checkParameters(parameters: validationParameters, neuronResponse: &neuronResponse)
        if neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError!.count > 0 {
            return
        }
        
        // Get the user application profile based on input
        let databaseOrmResultUPCUserApplicationProfile = UPCUserApplicationProfile.get(udbcDatabaseOrm: udbcDatabaseOrm!, profileId: uscForgotPasswordVerifySecretRequest.upcHumanProfileId, upcApplicationProfileId: uscForgotPasswordVerifySecretRequest.upcApplicationProfileId, upcCompanyProfileId: uscForgotPasswordVerifySecretRequest.upcCompanyProfileId)
        if databaseOrmResultUPCUserApplicationProfile.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUPCUserApplicationProfile.databaseOrmError[0].name, description: databaseOrmResultUPCUserApplicationProfile.databaseOrmError[0].description))
            return
        }
        
        // Based on the authentication id get the security pin authentication
        let upcApplicationProfile = databaseOrmResultUPCUserApplicationProfile.object[0]
        for upcUserApplicationAuthentication in upcApplicationProfile.upcUserApplicationAuthentication {
            if upcUserApplicationAuthentication.authenticationType == USCApplicationAuthenticationType.SecurityPinAuthentication.name {
                let databaseOrmResultUSCSecurityPinAuthentication = USCSecurityPinAuthentication.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: upcUserApplicationAuthentication.authenticationId)
                if databaseOrmResultUSCSecurityPinAuthentication.databaseOrmError.count > 0 {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUSCSecurityPinAuthentication.databaseOrmError[0].name, description: databaseOrmResultUSCSecurityPinAuthentication.databaseOrmError[0].description))
                    return
                }
                let uscSecurityPinAuthentication = databaseOrmResultUSCSecurityPinAuthentication.object[0]
                
                // Compare and set the result
                if (uscSecurityPinAuthentication.expiryTime)! < Date() {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "EMailSecretExpired", description: "E-Mail Secret Expired or You requested again"))
                        return
                    
                } else {
                    if uscSecurityPinAuthentication.securityPin != uscForgotPasswordVerifySecretRequest.emailSecret {
                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "EMailSecretInvalid", description: "E-Mail Secret Invalid"))
                        return
                    }
                }
                break
            }
        }
        
        // Package the response
        let uscForgotPasswordVerifySecretResponse = USCForgotPasswordVerifySecretResponse()
        uscForgotPasswordVerifySecretResponse.result = true
        let jsonUtilityUSCForgotPasswordVerifySecretResponse = JsonUtility<USCForgotPasswordVerifySecretResponse>()
        let jsonUSCForgotPasswordVerifySecretResponse = jsonUtilityUSCForgotPasswordVerifySecretResponse.convertAnyObjectToJson(jsonObject: uscForgotPasswordVerifySecretResponse)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonUSCForgotPasswordVerifySecretResponse)
    }
    
    private func forgotPasswordChangePassword(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let uscForgotPasswordChangePasswordRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: USCForgotPasswordChangePasswordRequest())
        
        var validationParameters = [String : String]()
        validationParameters["Password"] = uscForgotPasswordChangePasswordRequest.newPassword
        checkParameters(parameters: validationParameters, neuronResponse: &neuronResponse)
        if neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError!.count > 0 {
            return
        }
        
        // Get user application profile containing authentication id
        let databaseOrmResultUPCUserApplicationProfile = UPCUserApplicationProfile.get(udbcDatabaseOrm: udbcDatabaseOrm!, profileId: uscForgotPasswordChangePasswordRequest.upcHumanProfileId, upcApplicationProfileId: uscForgotPasswordChangePasswordRequest.upcApplicationProfileId, upcCompanyProfileId: uscForgotPasswordChangePasswordRequest.upcCompanyProfileId)
        if databaseOrmResultUPCUserApplicationProfile.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUPCUserApplicationProfile.databaseOrmError[0].name, description: databaseOrmResultUPCUserApplicationProfile.databaseOrmError[0].description))
            return
        }
        
        // Use the authentication id to update user name password authentication
        let upcApplicationProfile = databaseOrmResultUPCUserApplicationProfile.object[0]
        for upcUserApplicationAuthentication in upcApplicationProfile.upcUserApplicationAuthentication {
            if upcUserApplicationAuthentication.authenticationType == USCApplicationAuthenticationType.UserNamePasswordAuthenticaiton.name {
                let databaseOrmResultUSCUserNamePasswordAuthenticationGet = USCUserNamePasswordAuthentication.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: upcUserApplicationAuthentication.authenticationId)
                if databaseOrmResultUSCUserNamePasswordAuthenticationGet.databaseOrmError.count > 0 {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUSCUserNamePasswordAuthenticationGet.databaseOrmError[0].name, description: databaseOrmResultUSCUserNamePasswordAuthenticationGet.databaseOrmError[0].description))
                    return
                }
                let uscUserNamePasswordAuthentiation = databaseOrmResultUSCUserNamePasswordAuthenticationGet.object[0]
                uscUserNamePasswordAuthentiation.password = BCrypt.hash(password: uscForgotPasswordChangePasswordRequest.newPassword)
                let databaseOrmResultUSCUserNamePasswordAuthentication = USCUserNamePasswordAuthentication.update(udbcDatabaseOrm: udbcDatabaseOrm!, object: uscUserNamePasswordAuthentiation)
                if databaseOrmResultUSCUserNamePasswordAuthentication.databaseOrmError.count > 0 {
                    neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUSCUserNamePasswordAuthentication.databaseOrmError[0].name, description: databaseOrmResultUSCUserNamePasswordAuthentication.databaseOrmError[0].description))
                    return
                }
                break
            }
        }
        
        // Package the response
        let uscForgotPasswordChangePasswordResponse = USCForgotPasswordChangePasswordResponse()
        uscForgotPasswordChangePasswordResponse.result = true
        let jsonUtilityUSCForgotPasswordChangePasswordResponse = JsonUtility<USCForgotPasswordChangePasswordResponse>()
        let jsonUSCForgotPasswordChangePasswordResponse = jsonUtilityUSCForgotPasswordChangePasswordResponse.convertAnyObjectToJson(jsonObject: uscForgotPasswordChangePasswordResponse)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonUSCForgotPasswordChangePasswordResponse)
    }
    
    private func checkParameters(parameters: [String : String], neuronResponse: inout NeuronRequest) {
        let validationUtil = ValidationUtil()
        var helpText: String = ""
        for validationItem in parameters {
            if validationItem.key == "UserName" && !validationUtil.isValidUserName(value: validationItem.value, helpText: &helpText) {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "InvalidUserName", description: "Invalid User Name. \(helpText)"))
            } else if validationItem.key == "Password" && !validationUtil.isValidPassword(value: validationItem.value, helpText: &helpText) {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "InvalidPassword", description: "Invalid Password. \(helpText)"))
            } else if validationItem.key == "FirstName" && !validationUtil.isValidHumanName(value: validationItem.value, helpText: &helpText) {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "InvalidFirstName", description: "Invalid First Name. \(helpText)"))
            } else if validationItem.key == "MiddleName" && !validationItem.value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !validationUtil.isValidHumanName(value: validationItem.value, helpText: &helpText) {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "InvalidMiddleName", description: "Invalid Middle Name. \(helpText)"))
            } else if validationItem.key == "LastName" && !validationUtil.isValidHumanName(value: validationItem.value, helpText: &helpText) {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "InvalidLastName", description: "Invalid Last Name. \(helpText)"))
            } else if validationItem.key == "EMail" && !validationUtil.isValidEmail(value: validationItem.value, helpText: &helpText) {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "InvalidEMail", description: "Invalid EMail. \(helpText)"))
            } else if validationItem.key == "EMailSecret" && !validationUtil.isValidEMailSecret(value: validationItem.value, helpText: &helpText) {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "InvalidEMailSecret", description: "Invalid E-Mail Secret. \(helpText)"))
            }
        }
    }
    
    private func getSecurityControllerView(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let uscSecurityControllerRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: USCSecurityControllerRequest())
        
        
        // Verify application basic information
        let continueProcess = try validateApplicationAndCompanyInformation(upcApplicationProfileId: uscSecurityControllerRequest.upcApplicationProfileId, upcCompanyProfileId: uscSecurityControllerRequest.upcCompanyProfileId, neuronResponse: &neuronResponse)
        if !continueProcess {
            return
        }
        
        // Verify the application security information
        
        // Get the device profile id for the device model identifier
//        let databaseOrmResultUPCDeviceProfile = UPCDeviceProfile.get(udbcDatabaseOrm: udbcDatabaseOrm!, modelIdentifier: uscSecurityControllerRequest.deviceModelIdentifier)
//        if databaseOrmResultUPCDeviceProfile.databaseOrmError.count > 0 {
//            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUPCDeviceProfile.databaseOrmError[0].name, description: databaseOrmResultUPCDeviceProfile.databaseOrmError[0].description))
//            return
//        }
//        let upcDeviceProfileId = databaseOrmResultUPCDeviceProfile.object[0]._id
        
        // Get the application security token
        let databaseOrmResultUSCApplicationSecurityToken = USCApplicationSecurityToken.get(udbcDatabaseOrm: udbcDatabaseOrm!, upcApplicationProfileId: uscSecurityControllerRequest.upcApplicationProfileId, upcCompanyProfileId: uscSecurityControllerRequest.upcCompanyProfileId)
        if databaseOrmResultUSCApplicationSecurityToken.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUSCApplicationSecurityToken.databaseOrmError[0].name, description: databaseOrmResultUSCApplicationSecurityToken.databaseOrmError[0].description))
            return
        }
        let uscApplicationSecurityToken = databaseOrmResultUSCApplicationSecurityToken.object[0]
        var securityToken = uscApplicationSecurityToken.securityToken
        
        // Check if device id exist.
//        let databaseOrmResultUSCUserDeviceApplicationProfile = USCUserDeviceApplicationProfile.get(udbcDatabaseOrm: udbcDatabaseOrm!, upcApplicationProfileId: uscSecurityControllerRequest.upcApplicationProfileId, upcCompanyProfileId: uscSecurityControllerRequest.upcCompanyProfileId, deviceId: uscSecurityControllerRequest.deviceId)
//        if databaseOrmResultUSCApplicationSecurityToken.databaseOrmError.count > 0 {
//            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUSCApplicationSecurityToken.databaseOrmError[0].name, description: databaseOrmResultUSCApplicationSecurityToken.databaseOrmError[0].description))
//            return`
//        }
        
        // If not add it to user device application profile.
        // Use the device profile id, application security token got from previous
        // steps
//        if databaseOrmResultUSCUserDeviceApplicationProfile.object.count == 0 {
//            let uscUserDeviceApplicationProfile = USCUserDeviceApplicationProfile()
//            uscUserDeviceApplicationProfile._id = try (udbcDatabaseOrm?.generateId())!
//            uscUserDeviceApplicationProfile.deviceId = uscSecurityControllerRequest.deviceId
//            uscUserDeviceApplicationProfile.upcApplicationProfileId = uscSecurityControllerRequest.upcApplicationProfileId
//            uscUserDeviceApplicationProfile.upcCompanyProfileId = uscSecurityControllerRequest.upcCompanyProfileId
//            uscUserDeviceApplicationProfile.upcDeviceProfileId = upcDeviceProfileId
//            uscUserDeviceApplicationProfile.uscApplicationSecurityToken = securityToken
//            let databaseOrmResultUSCUserDeviceApplicationProfileSave = USCUserDeviceApplicationProfile.save(udbcDatabaseOrm: udbcDatabaseOrm!, object: uscUserDeviceApplicationProfile)
//            if databaseOrmResultUSCUserDeviceApplicationProfileSave.databaseOrmError.count > 0 {
//                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUSCUserDeviceApplicationProfileSave.databaseOrmError[0].name, description: databaseOrmResultUSCUserDeviceApplicationProfileSave.databaseOrmError[0].description))
//                return
//            }
//        } else {
//            securityToken = databaseOrmResultUSCUserDeviceApplicationProfile.object[0].uscApplicationSecurityToken
//        }
        
        // Application security token in request matches with
        // application security token in user device applcation profile
        // or matches with new application security token
        if securityToken != uscSecurityControllerRequest.securityToken {
            if securityToken != uscApplicationSecurityToken.securityToken {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: "ApplicationSecurityValidationFailure", description: "Application Security Validation Failure"))
                return
            }
        }

        let uscSecurityControllerResponse = USCSecurityControllerResponse()

        // If matches check expirty in aplication security token.
        // If expired generate the new security token and put in
        // application security token and update the expirty date to another
        // 1 day
        var newSecurityToken: String = ""
        if (uscApplicationSecurityToken.expiryTime)! > Date() {
            let uscGenerateApplicationAuthentication = USCGenerateApplicationAuthentication(applicationTag: applicationTag)
            newSecurityToken = (uscGenerateApplicationAuthentication.generateAuthentication(type: USCApplicationAuthenticationType.SecurityTokenAuthentication.name) as! USCSecurityTokenAuthentication).securityToken
            uscApplicationSecurityToken.securityToken = newSecurityToken
            uscApplicationSecurityToken.expiryTime =  Date().addingTimeInterval(TimeInterval(defaultSecurityTokenTimeInterval))
            let databaseOrmResultUSCApplicationSecurityToken = USCApplicationSecurityToken.save(udbcDatabaseOrm: udbcDatabaseOrm!, object: uscApplicationSecurityToken)
            
            if databaseOrmResultUSCApplicationSecurityToken.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUSCApplicationSecurityToken.databaseOrmError[0].name, description: databaseOrmResultUSCApplicationSecurityToken.databaseOrmError[0].description))
                return
            }
            uscSecurityControllerResponse.securityToken = newSecurityToken
        }
        
        // If user device application profile security token and
        // application security token not matches put the
        // new security token either from generated or from
        // application security token.
//        if securityToken != uscApplicationSecurityToken.securityToken && databaseOrmResultUSCUserDeviceApplicationProfile.object.count > 0 {
//            let uscUserDeviceApplicationProfile = databaseOrmResultUSCUserDeviceApplicationProfile.object[0]
//            if newSecurityToken.isEmpty {
//                uscUserDeviceApplicationProfile.uscApplicationSecurityToken = uscApplicationSecurityToken.securityToken
//            } else {
//                 uscUserDeviceApplicationProfile.uscApplicationSecurityToken = newSecurityToken
//            }
//            let databaseOrmResultUSCUserDeviceApplicationProfileSave = USCUserDeviceApplicationProfile.save(udbcDatabaseOrm: udbcDatabaseOrm!, object: uscUserDeviceApplicationProfile)
//            if databaseOrmResultUSCUserDeviceApplicationProfileSave.databaseOrmError.count > 0 {
//                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUSCUserDeviceApplicationProfileSave.databaseOrmError[0].name, description: databaseOrmResultUSCUserDeviceApplicationProfileSave.databaseOrmError[0].description))
//                return
//            }
//            uscSecurityControllerResponse.securityToken = newSecurityToken
//        }
        
        // Generate the view models
        print(uscSecurityControllerRequest.language)
        let uvcViewModelConnectUser = getView(name: "ConnectUserView", language: uscSecurityControllerRequest.language, neuronResponse: &neuronResponse)
        let jsonUtilityConnectionControllerView = JsonUtility<UVCViewModel>()
        let jsonConnectUserViewModel = jsonUtilityConnectionControllerView.convertAnyObjectToJson(jsonObject: uvcViewModelConnectUser!)
        let uvcViewModelCreateConnection = getView(name: "CreateConnectionView", language: uscSecurityControllerRequest.language, neuronResponse: &neuronResponse)
        let jsonCreateConnectionViewModel = jsonUtilityConnectionControllerView.convertAnyObjectToJson(jsonObject: uvcViewModelCreateConnection!)
        let uvcViewModelForgotPasswordVerifyIdentity = getView(name: "ForgotPasswordVerifyIdentityView", language: uscSecurityControllerRequest.language, neuronResponse: &neuronResponse)
        let jsonCreateForgotPasswordVerifyIdentity = jsonUtilityConnectionControllerView.convertAnyObjectToJson(jsonObject: uvcViewModelForgotPasswordVerifyIdentity!)
        let uvcViewModelForgotPasswordVerifySecret = getView(name: "ForgotPasswordVerifySecretView", language: uscSecurityControllerRequest.language, neuronResponse: &neuronResponse)
        let jsonCreateForgotPasswordForgotPasswordVerifySecret = jsonUtilityConnectionControllerView.convertAnyObjectToJson(jsonObject: uvcViewModelForgotPasswordVerifySecret!)
        let uvcViewModelForgotPasswordChangePassword = getView(name: "ForgotPasswordChangePasswordView", language: uscSecurityControllerRequest.language, neuronResponse: &neuronResponse)
        let jsonCreateForgotPasswordForgotPasswordChangePassword = jsonUtilityConnectionControllerView.convertAnyObjectToJson(jsonObject: uvcViewModelForgotPasswordChangePassword!)
        let uvcViewModelForgotPasswordChangePasswordDone = getView(name: "ForgotPasswordChangePasswordDoneView", language: uscSecurityControllerRequest.language, neuronResponse: &neuronResponse)
        let jsonCreateForgotPasswordForgotPasswordChangePasswordDone = jsonUtilityConnectionControllerView.convertAnyObjectToJson(jsonObject: uvcViewModelForgotPasswordChangePasswordDone!)
        
        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
            return
        }
        
        // Package the response
        uscSecurityControllerResponse.modelDictionary["ConnectUserViewModel"] = jsonConnectUserViewModel
        uscSecurityControllerResponse.modelDictionary["CreateConnectionViewModel"] = jsonCreateConnectionViewModel
        uscSecurityControllerResponse.modelDictionary["ForgotPasswordVerifyIdentityViewModel"] = jsonCreateForgotPasswordVerifyIdentity
        uscSecurityControllerResponse.modelDictionary["ForgotPasswordVerifySecretViewModel"] = jsonCreateForgotPasswordForgotPasswordVerifySecret
        uscSecurityControllerResponse.modelDictionary["ForgotPasswordChangePasswordViewModel"] = jsonCreateForgotPasswordForgotPasswordChangePassword
        uscSecurityControllerResponse.modelDictionary["ForgotPasswordChangePasswordDoneViewModel"] = jsonCreateForgotPasswordForgotPasswordChangePasswordDone
        
        let jsonUtilityUSCSecurityControllerResponse = JsonUtility<USCSecurityControllerResponse>()
        let jsonUSCSecurityControllerResponse = jsonUtilityUSCSecurityControllerResponse.convertAnyObjectToJson(jsonObject: uscSecurityControllerResponse)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: jsonUSCSecurityControllerResponse)
    }
    
    private func closeConnection(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
    }
    
    private func createConnection(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let uscCreateConnectionRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: USCCreateConnectionRequest())
        
        let eMail = "\(uscCreateConnectionRequest.upcEmailProfile.localPart)@\(uscCreateConnectionRequest.upcEmailProfile.domain)"
        var validationParameters = [String : String]()
        validationParameters["UserName"] = uscCreateConnectionRequest.uscUserNamePasswordAuthentication.userName
        validationParameters["Password"] = uscCreateConnectionRequest.uscUserNamePasswordAuthentication.password
        validationParameters["FirstName"] = uscCreateConnectionRequest.upcHumanProfile.firstName
        validationParameters["MiddleName"] = uscCreateConnectionRequest.upcHumanProfile.middleName
        validationParameters["LastName"] = uscCreateConnectionRequest.upcHumanProfile.lastName
        validationParameters["EMail"] = eMail
        checkParameters(parameters: validationParameters, neuronResponse: &neuronResponse)
        if neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError!.count > 0 {
            return
        }
        
        // Verify company profile id and application profile id
        let continueProcess = try validateApplicationAndCompanyInformation(upcApplicationProfileId: uscCreateConnectionRequest.upcApplicationProfileId, upcCompanyProfileId: uscCreateConnectionRequest.upcCompanyProfileId, neuronResponse: &neuronResponse)
        if !continueProcess {
            // Not a valid company profile and application profile id
            return
        }
        
        // If user already exist then report
        var databaseOrmResultUSCUserNamePasswordAuthentication = USCUserNamePasswordAuthentication.get(udbcDatabaseOrm: udbcDatabaseOrm!, userName: uscCreateConnectionRequest.uscUserNamePasswordAuthentication.userName)
        if databaseOrmResultUSCUserNamePasswordAuthentication.databaseOrmError.count > 0 {
            if databaseOrmResultUSCUserNamePasswordAuthentication.databaseOrmError[0].name != DatabaseOrmError.NoRecords.name {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUSCUserNamePasswordAuthentication.databaseOrmError[0].name, description: databaseOrmResultUSCUserNamePasswordAuthentication.databaseOrmError[0].description))
                return
            }
        }
        if databaseOrmResultUSCUserNamePasswordAuthentication.object.count > 0 { neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: SecurityNeuronErrorType.UserAlreadyExist.name, description: SecurityNeuronErrorType.UserAlreadyExist.description))
        }
        
        // Save email profile and generate user profile id
        uscCreateConnectionRequest.upcEmailProfile._id = try (udbcDatabaseOrm?.generateId())!
        let databaseOrmResultUPCEMailProfile = UPCEMailProfile.save(udbcDatabaseOrm: udbcDatabaseOrm!, object: uscCreateConnectionRequest.upcEmailProfile)
        if databaseOrmResultUPCEMailProfile.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUPCEMailProfile.databaseOrmError[0].name, description: databaseOrmResultUPCEMailProfile.databaseOrmError[0].description))
            return
        }
        let emailProfileId = databaseOrmResultUPCEMailProfile.id
        
        // Save human profile and generate user profile id
        uscCreateConnectionRequest.upcHumanProfile._id = try (udbcDatabaseOrm?.generateId())!
        uscCreateConnectionRequest.upcHumanProfile.upcEmailProfileId = emailProfileId
        if uscCreateConnectionRequest.upcHumanProfile.middleName.isEmpty {
            uscCreateConnectionRequest.upcHumanProfile.name = "\(uscCreateConnectionRequest.upcHumanProfile.firstName) \(uscCreateConnectionRequest.upcHumanProfile.lastName)"
        } else {
            uscCreateConnectionRequest.upcHumanProfile.name = "\(uscCreateConnectionRequest.upcHumanProfile.firstName) \(uscCreateConnectionRequest.upcHumanProfile.middleName) \(uscCreateConnectionRequest.upcHumanProfile.lastName)"
        }
        let databaseOrmResultUPCHumanProfile = UPCHumanProfile.save(udbcDatabaseOrm: udbcDatabaseOrm!, object: uscCreateConnectionRequest.upcHumanProfile)
        if databaseOrmResultUPCHumanProfile.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUPCHumanProfile.databaseOrmError[0].name, description: databaseOrmResultUPCHumanProfile.databaseOrmError[0].description))
            return
        }
        let userProfileId = databaseOrmResultUPCHumanProfile.id
        
        // Save user name and password and generate its id
        uscCreateConnectionRequest.uscUserNamePasswordAuthentication._id = try (udbcDatabaseOrm?.generateId())!
        uscCreateConnectionRequest.uscUserNamePasswordAuthentication.password = BCrypt.hash(password: uscCreateConnectionRequest.uscUserNamePasswordAuthentication.password)
        databaseOrmResultUSCUserNamePasswordAuthentication = USCUserNamePasswordAuthentication.save(udbcDatabaseOrm: udbcDatabaseOrm!, object: uscCreateConnectionRequest.uscUserNamePasswordAuthentication)
        if databaseOrmResultUSCUserNamePasswordAuthentication.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUSCUserNamePasswordAuthentication.databaseOrmError[0].name, description: databaseOrmResultUSCUserNamePasswordAuthentication.databaseOrmError[0].description))
            return
        }
        let authenticationIdUserNamePasswordId = databaseOrmResultUSCUserNamePasswordAuthentication.id
        let uscGenerateApplicationAuthentication = USCGenerateApplicationAuthentication(applicationTag: applicationTag)
        
        // Generate security token and set expiry time. Also save it in database
        let uscSecurityTokenAuthenticationGenerated = uscGenerateApplicationAuthentication.generateAuthentication(type: USCApplicationAuthenticationType.SecurityTokenAuthentication.name) as! USCSecurityTokenAuthentication
        let uscSecurityTokenAuthentication = USCSecurityTokenAuthentication()
        uscSecurityTokenAuthentication._id = try (udbcDatabaseOrm?.generateId())!
        uscSecurityTokenAuthentication.securityToken = uscSecurityTokenAuthenticationGenerated.securityToken
        uscSecurityTokenAuthentication.expiryTime = Date().addingTimeInterval(TimeInterval(defaultSecurityTokenTimeInterval))
        let databaseOrmResultUSCSecurityTokenAuthentication = USCSecurityTokenAuthentication.save(udbcDatabaseOrm: udbcDatabaseOrm!, object: uscSecurityTokenAuthentication)
        if databaseOrmResultUSCSecurityTokenAuthentication.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUSCSecurityTokenAuthentication.databaseOrmError[0].name, description: databaseOrmResultUSCSecurityTokenAuthentication.databaseOrmError[0].description))
            return
        }
        let authenticationIdSecurityTokenId = databaseOrmResultUSCSecurityTokenAuthentication.id
        
        // Save the user application profile with the above values
        let upcUserApplicationProfile = UPCUserApplicationProfile()
        upcUserApplicationProfile._id = try (udbcDatabaseOrm?.generateId())!
        upcUserApplicationProfile.userProfileId = userProfileId
        upcUserApplicationProfile.upcApplicationProfileId = uscCreateConnectionRequest.upcApplicationProfileId
        upcUserApplicationProfile.upcCompanyProfileId = uscCreateConnectionRequest.upcCompanyProfileId
        let upcUserApplicationAuthenticationUserNamePassword = UPCUserApplicationAuthentication()
        upcUserApplicationAuthenticationUserNamePassword.authenticationType = USCApplicationAuthenticationType.UserNamePasswordAuthenticaiton.name
        upcUserApplicationAuthenticationUserNamePassword._id = try (udbcDatabaseOrm?.generateId())!
        upcUserApplicationAuthenticationUserNamePassword.authenticationId = authenticationIdUserNamePasswordId
        upcUserApplicationProfile.upcUserApplicationAuthentication.append(upcUserApplicationAuthenticationUserNamePassword)
        let upcUserApplicationAuthenticationSecurityToken = UPCUserApplicationAuthentication()
        upcUserApplicationAuthenticationSecurityToken._id = try (udbcDatabaseOrm?.generateId())!
        upcUserApplicationAuthenticationSecurityToken.authenticationType = USCApplicationAuthenticationType.SecurityTokenAuthentication.name
        upcUserApplicationAuthenticationSecurityToken.authenticationId = authenticationIdSecurityTokenId
        upcUserApplicationProfile.upcUserApplicationAuthentication.append(upcUserApplicationAuthenticationSecurityToken)
        let databaseOrmResultUPCUserApplicationProfile = UPCUserApplicationProfile.save(udbcDatabaseOrm: udbcDatabaseOrm!, object: upcUserApplicationProfile)
        if databaseOrmResultUPCUserApplicationProfile.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUPCUserApplicationProfile.databaseOrmError[0].name, description: databaseOrmResultUPCUserApplicationProfile.databaseOrmError[0].description))
            return
        }
        
        
        // Prepare the register user response and put it in neuron response
        let uscCreateConnectionResponse = USCCreateConnectionResponse()
        var udcProfile = UDCProfile()
        udcProfile.profileId = userProfileId
        udcProfile.udcProfileItemIdName = "UDCProfileItem.Human"
        uscCreateConnectionResponse.udcProfile.append(udcProfile)
        udcProfile = UDCProfile()
        udcProfile.profileId = uscCreateConnectionRequest.upcApplicationProfileId
        udcProfile.udcProfileItemIdName = "UDCProfileItem.Application"
        uscCreateConnectionResponse.udcProfile.append(udcProfile)
        udcProfile = UDCProfile()
        udcProfile.profileId = uscCreateConnectionRequest.upcCompanyProfileId
        udcProfile.udcProfileItemIdName = "UDCProfileItem.Company"
        uscCreateConnectionResponse.udcProfile.append(udcProfile)
        uscCreateConnectionResponse.uscSecurityTokenAuthentication = uscSecurityTokenAuthentication
        let jsonUtility = JsonUtility<USCCreateConnectionResponse>()
        let text = jsonUtility.convertAnyObjectToJson(jsonObject: uscCreateConnectionResponse)
        neuronResponse = neuronUtility!.getNeuronResponseSuccess(neuronRequest: neuronRequest, responseText: text)

        try callSpecificNeuronForUpdate(neuronRequest: &neuronResponse, neuronName: SecurityNeuron.getName())
    }
    
    private func validateApplicationAndCompanyInformation(upcApplicationProfileId: String?, upcCompanyProfileId: String?, neuronResponse: inout NeuronRequest) throws -> Bool {
        let databaseOrmResultUPCApplicationProfile = UPCApplicationProfile.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: upcApplicationProfileId!)
        if databaseOrmResultUPCApplicationProfile.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: SecurityNeuronErrorType.InvalidApplicationInformation.name, description: SecurityNeuronErrorType.InvalidApplicationInformation.description))
            
            return false
        }
        let databaserOrmUPCCompanyProfile = UPCCompanyProfile.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: upcCompanyProfileId!)
        if databaserOrmUPCCompanyProfile.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: SecurityNeuronErrorType.InvalidCompanyInformation.name, description: SecurityNeuronErrorType.InvalidCompanyInformation.description))
            return false
        }
        
        return true
    }
    
    private func getApplicationProfile(userName: String, upcApplicationProfileId: String, upcCompanyProfileId: String, neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) -> UPCUserApplicationProfile? {
        let databaseOrmResultUSCUserNamePasswordAuthentication = USCUserNamePasswordAuthentication.get(udbcDatabaseOrm: udbcDatabaseOrm!, userName: userName)
        if databaseOrmResultUSCUserNamePasswordAuthentication.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUSCUserNamePasswordAuthentication.databaseOrmError[0].name, description: databaseOrmResultUSCUserNamePasswordAuthentication.databaseOrmError[0].description))
            return nil
        }
        let uscUserNamePasswordAuthentication = databaseOrmResultUSCUserNamePasswordAuthentication.object[0]
        let databaseOrmResultUPCUserApplicationProfileProfileId = UPCUserApplicationProfile.get(udbcDatabaseOrm: udbcDatabaseOrm!, authenticationId: uscUserNamePasswordAuthentication._id, upcApplicationProfileId: upcApplicationProfileId, upcCompanyProfileId: upcCompanyProfileId)
        if databaseOrmResultUPCUserApplicationProfileProfileId.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUPCUserApplicationProfileProfileId.databaseOrmError[0].name, description: databaseOrmResultUPCUserApplicationProfileProfileId.databaseOrmError[0].description))
            return nil
        }
        let upcUserApplicationProfile = databaseOrmResultUPCUserApplicationProfileProfileId.object[0]
        return upcUserApplicationProfile
    }
    
    private func openConnection(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws {
        let uscUserAuthenticationRequest = neuronUtility!.getNeuronRequest(json: neuronRequest.neuronOperation.neuronData.text, object: USCUserAuthenticationRequest())
        
        if uscUserAuthenticationRequest.uscSecurityTokenAuthentication.securityToken.isEmpty {
            var validationParameters = [String : String]()
            validationParameters["UserName"] = uscUserAuthenticationRequest.uscUserNamePasswordAuthentication.userName
            validationParameters["Password"] = uscUserAuthenticationRequest.uscUserNamePasswordAuthentication.password
            checkParameters(parameters: validationParameters, neuronResponse: &neuronResponse)
            if neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError!.count > 0 {
                return
            }
        }

        let continueProcess = try validateApplicationAndCompanyInformation(upcApplicationProfileId: uscUserAuthenticationRequest.upcApplicationProfileId, upcCompanyProfileId: uscUserAuthenticationRequest.upcCompanyProfileId, neuronResponse: &neuronResponse)
        if !continueProcess {
            return
        }
        let uscApplicationAuthenticationResponse = USCUserAuthenticationResponse()

        // Get the user application profile based on profile id and application profile id
        var upcUserApplicationProfile: UPCUserApplicationProfile?
        if !uscUserAuthenticationRequest.userProfileId.isEmpty {
            let databaseOrmResultUPCUserApplicationProfile = UPCUserApplicationProfile.get(udbcDatabaseOrm: udbcDatabaseOrm!, profileId: uscUserAuthenticationRequest.userProfileId, upcApplicationProfileId: uscUserAuthenticationRequest.upcApplicationProfileId, upcCompanyProfileId: uscUserAuthenticationRequest.upcCompanyProfileId)
            if databaseOrmResultUPCUserApplicationProfile.databaseOrmError.count > 0 {
                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUPCUserApplicationProfile.databaseOrmError[0].name, description: databaseOrmResultUPCUserApplicationProfile.databaseOrmError[0].description))
                return
            }
            upcUserApplicationProfile = databaseOrmResultUPCUserApplicationProfile.object[0]
        } else {
            upcUserApplicationProfile = getApplicationProfile(userName: uscUserAuthenticationRequest.uscUserNamePasswordAuthentication.userName, upcApplicationProfileId: uscUserAuthenticationRequest.upcApplicationProfileId, upcCompanyProfileId: uscUserAuthenticationRequest.upcCompanyProfileId, neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            
            if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
                return
            }
            uscApplicationAuthenticationResponse.userProfileId = (upcUserApplicationProfile?.userProfileId)!
        }
        
        
        // Loop through all the authentication types and validate against user input
        var securityTokenIndex: Int = 0
        for (index, userApplicationAuthentication) in (upcUserApplicationProfile!.upcUserApplicationAuthentication).enumerated() {
            if userApplicationAuthentication.authenticationType == USCApplicationAuthenticationType.SecurityTokenAuthentication.name {
                
                securityTokenIndex = index
                break
            }
        }
        for type in uscUserAuthenticationRequest.type {
            for userApplicationAuthentication in (upcUserApplicationProfile!.upcUserApplicationAuthentication) {
                if userApplicationAuthentication.authenticationType == type &&
                    type == USCApplicationAuthenticationType.UserNamePasswordAuthenticaiton.name {
                    let databaseOrmResultUSCUserNamePasswordAuthentication = USCUserNamePasswordAuthentication.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: userApplicationAuthentication.authenticationId)
                    if databaseOrmResultUSCUserNamePasswordAuthentication.databaseOrmError.count > 0 {
                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUSCUserNamePasswordAuthentication.databaseOrmError[0].name, description: databaseOrmResultUSCUserNamePasswordAuthentication.databaseOrmError[0].description))
                        return
                    }
                    let userNamePasswordAuthenticationFromDb = databaseOrmResultUSCUserNamePasswordAuthentication.object[0]
                    // Verify the user name and password after un-hashing password
                    if try BCrypt.verify(password: uscUserAuthenticationRequest.uscUserNamePasswordAuthentication.password, matchesHash: userNamePasswordAuthenticationFromDb.password) && uscUserAuthenticationRequest.uscUserNamePasswordAuthentication.userName == userNamePasswordAuthenticationFromDb.userName {  // Success verification
                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationSuccess?.append(neuronUtility!.getNeuronOperationSuccess(name: SecurityNeuronSuccessType.UserNamePasswordAuthenticationSuccess.name, description: SecurityNeuronSuccessType.UserNamePasswordAuthenticationSuccess.description))
                        
                        // Get the security token that is already stored
                        var databaseOrmResultUSCSecurityTokenAuthentication = USCSecurityTokenAuthentication.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: ((upcUserApplicationProfile!.upcUserApplicationAuthentication[securityTokenIndex].authenticationId)))
                        if databaseOrmResultUSCSecurityTokenAuthentication.databaseOrmError.count > 0 {
                            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUSCSecurityTokenAuthentication.databaseOrmError[0].name, description: databaseOrmResultUSCSecurityTokenAuthentication.databaseOrmError[0].description))
                            return
                        }
                        let uscSecurityTokenAuthenticationFromDb = databaseOrmResultUSCSecurityTokenAuthentication.object[0]
                        // Put it in application authentication response
                        uscApplicationAuthenticationResponse.type.append(USCApplicationAuthenticationType.UserNamePasswordAuthenticaiton.name)
                        uscApplicationAuthenticationResponse.uscSecurityTokenAuthentication.securityToken = (uscSecurityTokenAuthenticationFromDb.securityToken)
                        uscApplicationAuthenticationResponse.uscSecurityTokenAuthentication.expiryTime =
                            uscSecurityTokenAuthenticationFromDb.expiryTime
                        neuronResponse.neuronOperation.neuronData.text = neuronUtility!.getNeuronResponse(object: uscApplicationAuthenticationResponse)
                        
                        // Extend the expiry time another 24 hours
                        uscSecurityTokenAuthenticationFromDb.expiryTime = Date().addingTimeInterval(TimeInterval(defaultSecurityTokenTimeInterval))
                        databaseOrmResultUSCSecurityTokenAuthentication = USCSecurityTokenAuthentication.update(udbcDatabaseOrm: udbcDatabaseOrm!, id: uscSecurityTokenAuthenticationFromDb._id, securityToken: uscSecurityTokenAuthenticationFromDb.securityToken, expiryTime: uscSecurityTokenAuthenticationFromDb.expiryTime!)
                        if databaseOrmResultUSCSecurityTokenAuthentication.databaseOrmError.count > 0 {
                            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUSCSecurityTokenAuthentication.databaseOrmError[0].name, description: databaseOrmResultUSCSecurityTokenAuthentication.databaseOrmError[0].description))
                            return
                        }
                    } else {
                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: SecurityNeuronErrorType.InvalidUserNameOrPassword.name, description: SecurityNeuronErrorType.InvalidUserNameOrPassword.description))
                        
                    }
                } else if userApplicationAuthentication.authenticationType == type  &&
                    type == USCApplicationAuthenticationType.SecurityTokenAuthentication.name{
                    let databaseOrmResultUSCSecurityTokenAuthentication = USCSecurityTokenAuthentication.get(udbcDatabaseOrm: udbcDatabaseOrm!, id: userApplicationAuthentication.authenticationId)
                    
                    if databaseOrmResultUSCSecurityTokenAuthentication.object.count == 0 {
                        neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: SecurityNeuronErrorType.InvalidSecurityToken.name, description: SecurityNeuronErrorType.InvalidSecurityToken.description))
                    } else {
                        let uscSecurityTokenAuthenticationFromDb = databaseOrmResultUSCSecurityTokenAuthentication.object[0]
                        if uscSecurityTokenAuthenticationFromDb.securityToken == uscUserAuthenticationRequest.uscSecurityTokenAuthentication.securityToken {
                            // User current time in server so that no body can cheat
                            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationSuccess?.append(neuronUtility!.getNeuronOperationSuccess(name: SecurityNeuronSuccessType.SecurityTokenAuthenticationSuccess.name, description: SecurityNeuronSuccessType.SecurityTokenAuthenticationSuccess.description))
                            
                        }
                        if (uscSecurityTokenAuthenticationFromDb.expiryTime)! < Date() {
                            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: SecurityNeuronErrorType.SecurityTokenExpired.name, description: SecurityNeuronErrorType.SecurityTokenExpired.description))
                            
                        } else {
                            if !neuronUtility!.isNeuronOperationSuccess(neuronResponse: neuronResponse) {
                                neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationSuccess?.append(neuronUtility!.getNeuronOperationSuccess(name: SecurityNeuronSuccessType.SecurityTokenAuthenticationSuccess.name, description: SecurityNeuronSuccessType.SecurityTokenAuthenticationSuccess.description))
                            }
                            
                        }
                    }
                }
            }
        }
        
    }
    
    private func getView(name: String, language: String, neuronResponse: inout NeuronRequest) -> UVCViewModel? {
        let databaseOrmResultUVCViewModel = UVCViewModel.get(udbcDatabaseOrm: udbcDatabaseOrm!, name: name, language: language)
        if databaseOrmResultUVCViewModel.databaseOrmError.count > 0 {
            neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError?.append(neuronUtility!.getNeuronOperationError(name: databaseOrmResultUVCViewModel.databaseOrmError[0].name, description: databaseOrmResultUVCViewModel.databaseOrmError[0].description))
            return nil
        }
        let uvcViewModel = databaseOrmResultUVCViewModel.object[0]
        return uvcViewModel
    }
    
    static public func getName() -> String {
        return "SecurityNeuron"
    }
    
    static public func getDescription() -> String {
        return "Security Neuron"
    }
    
    static public func getDendrite(sourceId: String) -> (Neuron) {
        var neuron: Neuron?
        
        serialQueue.sync {
            print("Before: \(dendriteMap.debugDescription)")
            neuron = dendriteMap[sourceId]
            if neuron == nil {
                print("\(getName()): Created: \(sourceId)")
                dendriteMap[sourceId] = SecurityNeuron()
                neuron = dendriteMap[sourceId]
            }
            print("After creation: \(dendriteMap.debugDescription)")
        }
        
        return  neuron!;
    }
    
    
    
    private func setChildResponse(operationName: String, neuronRequest: NeuronRequest) {
        responseMap[operationName] = neuronRequest
    }
    
    public func getChildResponse(operationName: String) -> NeuronRequest {
        var neuronResponse: NeuronRequest?
        print(responseMap)
        if let _ = responseMap[operationName] {
            neuronResponse = responseMap[operationName]
            responseMap.removeValue(forKey: operationName)
        }
        if neuronResponse == nil {
            neuronResponse = NeuronRequest()
        }
        
        return neuronResponse!
    }
    
    public static func getDendriteSize() -> (Int) {
        return dendriteMap.count
    }
    
    private static func removeDendrite(sourceId: String) {
        serialQueue.sync {
            print("neuronUtility: removed neuron: "+sourceId)
            dendriteMap.removeValue(forKey: sourceId)
            print("After removal \(getName()): \(dendriteMap.debugDescription)")
        }
    }
    
    
    public func setDendrite(neuronRequest: NeuronRequest, udbcDatabaseOrm: UDBCDatabaseOrm,  neuronUtility: NeuronUtility) {
        var neuronResponse = NeuronRequest()
        do {
            self.udbcDatabaseOrm = udbcDatabaseOrm
            
            self.neuronUtility = neuronUtility
            
            if neuronRequest.neuronOperation.parent == true {
                print("\(SecurityNeuron.getName()) Parent show setting child to true")
                neuronResponse.neuronOperation.child = true
            }
            
            var neuronRequestLocal = neuronRequest
            
            if neuronResponse.neuronOperation._id.isEmpty {
                neuronResponse.neuronOperation._id = try udbcDatabaseOrm.generateId()
            }
            
            self.neuronUtility!.setUDBCDatabaseOrm(udbcDatabaseOrm: udbcDatabaseOrm, neuronName: SecurityNeuron.getName())
            self.neuronUtility!.setUNCMain( neuronName: SecurityNeuron.getName())

            
            let continueProcess = try preProcess(neuronRequest: neuronRequestLocal, neuronResponse: &neuronResponse)
            if continueProcess == false {
                print("\(SecurityNeuron.getName()): don't process return")
                return
            }
            
            validateRequest(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
            
            if neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError!.count > 0 {
                print("\(SecurityNeuron.getName()) error in validation return")
                let neuronSource = self.neuronUtility!.getDendrite(sourceId: neuronRequest.neuronSource._id, neuronName: neuronRequest.neuronSource.name)
                neuronSource!.setDendrite(neuronRequest: neuronResponse, udbcDatabaseOrm: udbcDatabaseOrm,  neuronUtility: self.neuronUtility!)
                return
            }
            
            
            
            // Controller says no need to
            
            neuronResponse.neuronOperation.acknowledgement = false
            
            if neuronResponse.neuronOperation.neuronOperationStatus.neuronOperationError!.count == 0 {
                if neuronRequest.neuronOperation.asynchronus == true {
                    print("\(SecurityNeuron.getName()) asynchronus store the request and return")
                    neuronResponse.neuronOperation.response = true
                    neuronResponse.neuronOperation.neuronData.text = ""
                    self.neuronUtility!.storeInDatabase(neuronRequest: neuronRequest)
                    return
                } else {
                    if neuronRequest.neuronOperation.synchronus == true {
                        if neuronRequest.neuronOperation.asynchronusProcess == true {
                            print("\(SecurityNeuron.getName()) asynchronus so update the status as pending")
                            let rows = try NeuronRequest.update(udbcDatabaseOrm: udbcDatabaseOrm, id: (neuronRequest._id), status: NeuronOperationStatusType.InProgress.name)
                        }
                        neuronResponse = self.neuronUtility!.getNeuronAcknowledgement(neuronRequest: neuronRequest)
                        neuronResponse.neuronOperation.acknowledgement = true
                        neuronResponse.neuronOperation.neuronData.text = ""
                        let neuronSource = self.neuronUtility!.getDendrite(sourceId: neuronRequest.neuronSource._id, neuronName: neuronRequest.neuronSource.name)
                        neuronSource!.setDendrite(neuronRequest: neuronResponse, udbcDatabaseOrm: udbcDatabaseOrm,  neuronUtility: self.neuronUtility!)
                        neuronResponse.neuronOperation.acknowledgement = false
                        try process(neuronRequest: neuronRequestLocal, neuronResponse: &neuronResponse)
                    }
                }
                
            }
            
            
            
        } catch {
            print("\(SecurityNeuron.getName()): Error thrown in setdendrite: \(error)")
            neuronResponse = self.neuronUtility!.getNeuronResponseError(neuronRequest: neuronRequest, errorName: NeuronOperationErrorType.ErrorInProcessing.name, errorDescription:  error.localizedDescription)
            
        }
        
        defer {
            postProcess(neuronRequest: neuronRequest, neuronResponse: &neuronResponse)
        }
    }
    
    private func validateRequest(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) {
        neuronResponse = neuronUtility!.validateRequest(neuronRequest: neuronRequest)
        if neuronUtility!.isNeuronOperationError(neuronResponse: neuronResponse) {
            return
        }
        
        
    }
    
    private func preProcess(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) throws -> Bool {
        print("\(SecurityNeuron.getName()): pre process")
        neuronResponse.neuronSource._id = neuronRequest.neuronSource._id
        
        print("neuronUtility: pre process: \(neuronRequest.neuronSource._id)")
        let neuronRequestLocal: NeuronRequest = neuronRequest
        
        if neuronRequestLocal.neuronOperation.acknowledgement == true {
            print("\(SecurityNeuron.getName()) acknowledgement so return")
            return false
        }
        
        if neuronRequestLocal.neuronOperation.response == true {
            setChildResponse(operationName: neuronRequestLocal.neuronOperation.name, neuronRequest: neuronRequest)
            print("\(SecurityNeuron.getName()) response so return")
            return false
        }
        
        if neuronRequestLocal.neuronOperation.asynchronus == true &&
            neuronRequestLocal.neuronOperation._id.isEmpty {
            neuronRequestLocal.neuronOperation._id = NSUUID().uuidString
        }
        
        if neuronRequest.neuronOperation.name == "NeuronOperation.GetResponse" {
            let databaseOrmResultFromDatabase = neuronUtility!.getFromDatabase(neuronRequest: neuronRequest)
            if databaseOrmResultFromDatabase.databaseOrmError.count > 0 {
                for databaseError in databaseOrmResultFromDatabase.databaseOrmError {
                    neuronResponse = neuronUtility!.getNeuronResponseError(neuronRequest: neuronRequest, errorName: databaseError.name, errorDescription:  databaseError.description)
                }
                return false
            }
            neuronResponse = databaseOrmResultFromDatabase.object[0]
            let neuronSource = neuronUtility!.getDendrite(sourceId: neuronRequest.neuronSource._id, neuronName: neuronRequest.neuronSource.name)
            neuronSource!.setDendrite(neuronRequest: neuronResponse, udbcDatabaseOrm: self.udbcDatabaseOrm!, neuronUtility: self.neuronUtility!)
            print("\(SecurityNeuron.getName()) got response so return")
            return false
        }
        
        return true
    }
    
    
    
    private func postProcess(neuronRequest: NeuronRequest, neuronResponse: inout NeuronRequest) {
        print("\(SecurityNeuron.getName()): post process")
        
        
   
                if neuronRequest.neuronOperation.asynchronusProcess == true {
                    print("\(SecurityNeuron.getName()) Asynchronus so storing response in database")
                    neuronResponse.neuronOperation.neuronOperationStatus.status = NeuronOperationStatusType.Completed.name
                    let databaseOrmResultUpdate = NeuronRequest.update(udbcDatabaseOrm: udbcDatabaseOrm!, id: (neuronRequest._id), status: NeuronOperationStatusType.Completed.name)
                    if databaseOrmResultUpdate.databaseOrmError.count > 0 {
                        for databaseError in databaseOrmResultUpdate.databaseOrmError {
                            neuronResponse = neuronUtility!.getNeuronResponseError(neuronRequest: neuronRequest, errorName: databaseError.name, errorDescription:  databaseError.description)
                        }
                    }
                    let databaseOrmResultStoreInDatabase = neuronUtility!.storeInDatabase(neuronRequest: neuronResponse)
                    if databaseOrmResultUpdate.databaseOrmError.count > 0 {
                        for databaseError in databaseOrmResultUpdate.databaseOrmError {
                            neuronResponse = neuronUtility!.getNeuronResponseError(neuronRequest: neuronRequest, errorName: databaseError.name, errorDescription:  databaseError.description)
                        }
                    }
                    
                }
                print("\(SecurityNeuron.getName()) Informing: \(String(describing: neuronRequest.neuronSource.name))")
                let neuronSource = neuronUtility!.getDendrite(sourceId: neuronRequest.neuronSource._id, neuronName: neuronRequest.neuronSource.name)
        neuronSource!.setDendrite(neuronRequest: neuronResponse, udbcDatabaseOrm: self.udbcDatabaseOrm!, neuronUtility: self.neuronUtility!)
               
            
        defer {
            SecurityNeuron.removeDendrite(sourceId: neuronRequest.neuronSource._id)
            print("Security neuron RESPONSE MAP: \(responseMap)")
            print("Security Neuron  Dendrite MAP: \(SecurityNeuron.dendriteMap)")
        }
        
    }
    
}
