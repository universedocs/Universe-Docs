//
//  ViewController.swift
//  UniversalDocs
//
//  Created by Kumar Muthaiah on 01/11/18.
//  Copyright © 2018 Kumar Muthaiah. All rights reserved.
//
//Copyright 2020 Kumar Muthaiah
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//


import UIKit
import Alamofire
import UDocsUtility
import UDocsBrain
import UDocsDatabaseModel
import UDocsNeuronModel
import UDocsNeuronUtility
import UDocsDocumentMapNeuronModel
import UDocsDocumentGraphNeuronModel
import UDocsDocumentModel
import UDocsPhotoNeuronModel
import UDocsDocumentItemNeuronModel
import UDocsGrammarNeuronModel
import UDocsOptionMapNeuronModel
import UDocsSecurityNeuronModel

extension Notification.Name {
    static let detailViewControllerNotification = Notification.Name("DetailViewControllerNotification")
    static let optionViewControllerNotification = Notification.Name("OptionViewControllerNotification")
    static let masterViewControllerNotification = Notification.Name("MasterViewControllerNotification")
    static let securityControllerNotification = Notification.Name("SecurityControllerNotification")
    static let detailViewControllerTabNotification1 = Notification.Name("DetailViewControllerPopupNotification1")
    static let detailViewControllerTabNotification2 = Notification.Name("DetailViewControllerPopupNotification2")
    static let detailViewControllerTabNotification3 = Notification.Name("DetailViewControllerPopupNotification3")
    static let detailViewControllerTabNotification4 = Notification.Name("DetailViewControllerPopupNotification4")
    static let detailViewControllerTabNotification5 = Notification.Name("DetailViewControllerPopupNotification5")
    static let detailViewControllerTabNotification6 = Notification.Name("DetailViewControllerPopupNotification6")
    static let detailViewControllerTabNotification7 = Notification.Name("DetailViewControllerPopupNotification7")
    static let detailViewControllerTabNotification8 = Notification.Name("DetailViewControllerPopupNotification8")
    static let detailViewControllerTabNotification9 = Notification.Name("DetailViewControllerPopupNotification9")
    static let detailViewControllerTabNotification10 = Notification.Name("DetailViewControllerPopupNotification10")
}

public class CallBrainControllerNeuron : Neuron {
    
    
    let neuronUtility: NeuronUtility? = nil
    var udbcDatabaseOrm: UDBCDatabaseOrm? = nil
    static var dendriteMap: [String : Neuron] = [String : Neuron]()
    static var responseMap: [String : NeuronRequest] = [String : NeuronRequest]()
    static let serialQueue = DispatchQueue(label: "SerialQueue")
    static public var delegateMap = [String: Any]()
    private var applicationSecurityToken = "6bWEqiirrP7yZbG40pwmkw"
    private var upcApplicationProfileId = "UPCApplicationProfile.UniverseDocs"
    private var upcCompanyProfileId = "UPCCompanyProfile.KumarMuthaiah"
    static public var sourceName = ""
    private static var sourceIdToSourceName = [String: String]()
    public static var tabNotificationCount = 1
    public static var sourceNotificationMap: [String: Notification.Name] = ["TabNotification1": Notification.Name.detailViewControllerTabNotification1,"TabNotification2": Notification.Name.detailViewControllerTabNotification2, "TabNotification3": Notification.Name.detailViewControllerTabNotification3, "TabNotification4": Notification.Name.detailViewControllerTabNotification4, "TabNotification5": Notification.Name.detailViewControllerTabNotification5, "TabNotification6": Notification.Name.detailViewControllerTabNotification6, "TabNotification7": Notification.Name.detailViewControllerTabNotification7, "TabNotification8": Notification.Name.detailViewControllerTabNotification8, "TabNotification9": Notification.Name.detailViewControllerTabNotification9, "TabNotification10": Notification.Name.detailViewControllerTabNotification10]
    
    public init() {
        CallBrainControllerNeuron.sourceNotificationMap[String(describing: MasterViewController.self)] = Notification.Name.masterViewControllerNotification
        CallBrainControllerNeuron.sourceNotificationMap[String(describing: SecurityController.self)] = Notification.Name.securityControllerNotification
        CallBrainControllerNeuron.sourceNotificationMap[String(describing: OptionViewController.self)] = Notification.Name.optionViewControllerNotification
        CallBrainControllerNeuron.sourceNotificationMap[String(describing: DetailViewController.self)] = Notification.Name.detailViewControllerNotification
    }
    
    
//    func modelIdentifier() -> String {
//        if let simulatorModelIdentifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] { return simulatorModelIdentifier }
//        var sysinfo = utsname()
//        uname(&sysinfo) // ignore return value
//        return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
//    }
//
    public func connectUser(sourceName: String, userName: String, password: String, eMail: String) {
        callNeuron(sourceName: sourceName, synchronus: true, operationName: SecurityNeuronOperationType.ConnectUser.name, targetName: "SecurityNeuron", objectToSend: USCUserAuthenticationRequest(), dataType: "NeuronDataType.Json", dataOperationName: "NeuronDataOperationName.Json", binaryData: nil)
    }
    
    public func forgotPasswordVerifyIdentity(userName: String, language: String) {
        let uscForgotPasswordVerifyIdentityRequest = USCForgotPasswordVerifyIdentityRequest()
        uscForgotPasswordVerifyIdentityRequest.language = language
        uscForgotPasswordVerifyIdentityRequest.userName = userName
        uscForgotPasswordVerifyIdentityRequest.upcApplicationProfileId = upcApplicationProfileId
        uscForgotPasswordVerifyIdentityRequest.upcCompanyProfileId = upcCompanyProfileId
        
        let jsonUtilityAuthenticationData = JsonUtility<USCForgotPasswordVerifyIdentityRequest>()
        let jsonAuthenticationData = jsonUtilityAuthenticationData.convertAnyObjectToJson(jsonObject: uscForgotPasswordVerifyIdentityRequest)
        
        // Convert brain controller neuron request into json and put it in neuron request
        let brainControllerNeuronRequest = BrainControllerNeuronRequest()
        brainControllerNeuronRequest.authenticationData = jsonAuthenticationData
        let jsonUtilityBrainControllerNeuronRequest = JsonUtility<BrainControllerNeuronRequest>()
        let jsonBrainControllerNeuronRequest = jsonUtilityBrainControllerNeuronRequest.convertAnyObjectToJson(jsonObject: brainControllerNeuronRequest)
        
        // Send the request to the brain controller
        let neuronRequestLocal = NeuronRequest()
        neuronRequestLocal.neuronSource._id =  "\(ApplicationSetting.DeviceModelName!)|\(ApplicationSetting.DeviceUUID!)|\(NSUUID().uuidString)"
        neuronRequestLocal.neuronOperation.synchronus = true
        neuronRequestLocal.neuronSource.name = CallBrainControllerNeuron.getName()
        neuronRequestLocal.neuronSource.type = CallBrainControllerNeuron.getName();
        neuronRequestLocal.neuronOperation.name = "SecurityNeuronOperationType.ForgotPasswordVerifyIdentity"
        neuronRequestLocal.neuronOperation.parent = true
        neuronRequestLocal.neuronTarget.name = "SecurityNeuron"
        neuronRequestLocal.neuronOperation.neuronData.text = jsonBrainControllerNeuronRequest
        let brainControllerNeuron = BrainControllerNeuron.getDendrite(sourceId: neuronRequestLocal.neuronSource._id)
        brainControllerNeuron.setDendrite(neuronRequest: neuronRequestLocal, udbcDatabaseOrm: UDBCRealmDatabaseOrm(),  neuronUtility: NeuronUtilityImplementation())
    }
    
    public func forgotPasswordVerifySecret(emailSecret: String, language: String) {
        let uscForgotPasswordVerifySecretRequest = USCForgotPasswordVerifySecretRequest()
        uscForgotPasswordVerifySecretRequest.emailSecret = emailSecret
        uscForgotPasswordVerifySecretRequest.upcHumanProfileId = ApplicationSetting.ProfileId!
        uscForgotPasswordVerifySecretRequest.upcApplicationProfileId = upcApplicationProfileId
        uscForgotPasswordVerifySecretRequest.upcCompanyProfileId = upcCompanyProfileId
        uscForgotPasswordVerifySecretRequest.language = language
        
        let jsonUtilityAuthenticationData = JsonUtility<USCForgotPasswordVerifySecretRequest>()
        let jsonAuthenticationData = jsonUtilityAuthenticationData.convertAnyObjectToJson(jsonObject: uscForgotPasswordVerifySecretRequest)
        
        // Convert brain controller neuron request into json and put it in neuron request
        let brainControllerNeuronRequest = BrainControllerNeuronRequest()
        brainControllerNeuronRequest.authenticationData = jsonAuthenticationData
        let jsonUtilityBrainControllerNeuronRequest = JsonUtility<BrainControllerNeuronRequest>()
        let jsonBrainControllerNeuronRequest = jsonUtilityBrainControllerNeuronRequest.convertAnyObjectToJson(jsonObject: brainControllerNeuronRequest)
        
        // Send the request to the brain controller
        let neuronRequestLocal = NeuronRequest()
        neuronRequestLocal.neuronSource._id =   "\(ApplicationSetting.DeviceModelName!)|\(ApplicationSetting.DeviceUUID!)|\(NSUUID().uuidString)"
        neuronRequestLocal.neuronOperation.synchronus = true
        neuronRequestLocal.neuronSource.name = CallBrainControllerNeuron.getName()
        neuronRequestLocal.neuronSource.type = CallBrainControllerNeuron.getName();
        neuronRequestLocal.neuronOperation.name = "SecurityNeuronOperationType.ForgotPasswordVerifySecret"
        neuronRequestLocal.neuronOperation.parent = true
        neuronRequestLocal.neuronTarget.name = "SecurityNeuron"
        neuronRequestLocal.neuronOperation.neuronData.text = jsonBrainControllerNeuronRequest
        let brainControllerNeuron = BrainControllerNeuron.getDendrite(sourceId: neuronRequestLocal.neuronSource._id)
        brainControllerNeuron.setDendrite(neuronRequest: neuronRequestLocal, udbcDatabaseOrm: UDBCRealmDatabaseOrm(),  neuronUtility: NeuronUtilityImplementation())
    }
    
    public func forgotPasswordChangePassword(newPassword: String, language: String) {
        let uscForgotPasswordChangePasswordRequest = USCForgotPasswordChangePasswordRequest()
        uscForgotPasswordChangePasswordRequest.upcHumanProfileId = ApplicationSetting.ProfileId!
        uscForgotPasswordChangePasswordRequest.upcApplicationProfileId = upcApplicationProfileId
        uscForgotPasswordChangePasswordRequest.upcCompanyProfileId = upcCompanyProfileId
        uscForgotPasswordChangePasswordRequest.language = language
        uscForgotPasswordChangePasswordRequest.newPassword = newPassword
        
        let jsonUtilityAuthenticationData = JsonUtility<USCForgotPasswordChangePasswordRequest>()
        let jsonAuthenticationData = jsonUtilityAuthenticationData.convertAnyObjectToJson(jsonObject: uscForgotPasswordChangePasswordRequest)
        
        // Convert brain controller neuron request into json and put it in neuron request
        let brainControllerNeuronRequest = BrainControllerNeuronRequest()
        brainControllerNeuronRequest.authenticationData = jsonAuthenticationData
        let jsonUtilityBrainControllerNeuronRequest = JsonUtility<BrainControllerNeuronRequest>()
        let jsonBrainControllerNeuronRequest = jsonUtilityBrainControllerNeuronRequest.convertAnyObjectToJson(jsonObject: brainControllerNeuronRequest)
        
        // Send the request to the brain controller
        let neuronRequestLocal = NeuronRequest()
        neuronRequestLocal.neuronSource._id =   "\(ApplicationSetting.DeviceModelName!)|\(ApplicationSetting.DeviceUUID!)|\(NSUUID().uuidString)"
        neuronRequestLocal.neuronOperation.synchronus = true
        neuronRequestLocal.neuronSource.name = CallBrainControllerNeuron.getName()
        neuronRequestLocal.neuronSource.type = CallBrainControllerNeuron.getName();
        neuronRequestLocal.neuronOperation.name = "SecurityNeuronOperationType.ForgotPasswordChangePassword"
        neuronRequestLocal.neuronOperation.parent = true
        neuronRequestLocal.neuronTarget.name = "SecurityNeuron"
        neuronRequestLocal.neuronOperation.neuronData.text = jsonBrainControllerNeuronRequest
        let brainControllerNeuron = BrainControllerNeuron.getDendrite(sourceId: neuronRequestLocal.neuronSource._id)
        brainControllerNeuron.setDendrite(neuronRequest: neuronRequestLocal, udbcDatabaseOrm: UDBCRealmDatabaseOrm(),  neuronUtility: NeuronUtilityImplementation())
    }
    
    public func createConnection(userName: String, password: String, firstName: String, middleName: String, lastName: String, eMail: String, language: String) {
        let uscCreateConnectionRequest =  USCCreateConnectionRequest()
        uscCreateConnectionRequest.upcHumanProfile._id = ApplicationSetting.ProfileId ?? ""
        uscCreateConnectionRequest.upcHumanProfile.firstName = firstName
        uscCreateConnectionRequest.upcHumanProfile.middleName = middleName
        uscCreateConnectionRequest.upcHumanProfile.lastName = lastName
        uscCreateConnectionRequest.language = language
        if !eMail.isEmpty {
            let eMailSplit = eMail.split(separator: "@")
            uscCreateConnectionRequest.upcEmailProfile.localPart = String(eMailSplit[0])
            uscCreateConnectionRequest.upcEmailProfile.domain = String(eMailSplit[1])
            uscCreateConnectionRequest.upcHumanProfile.upcEmailProfileId = "N/A"
        }
        uscCreateConnectionRequest.upcApplicationProfileId = upcApplicationProfileId
        uscCreateConnectionRequest.upcCompanyProfileId = upcCompanyProfileId
        uscCreateConnectionRequest.uscUserNamePasswordAuthentication.userName = ApplicationSetting.UserName!
        uscCreateConnectionRequest.uscUserNamePasswordAuthentication.password = ApplicationSetting.Password!
        
        let jsonUtilityAuthenticationData = JsonUtility<USCCreateConnectionRequest>()
        let jsonAuthenticationData = jsonUtilityAuthenticationData.convertAnyObjectToJson(jsonObject: uscCreateConnectionRequest)
        
        // Convert brain controller neuron request into json and put it in neuron request
        let brainControllerNeuronRequest = BrainControllerNeuronRequest()
        brainControllerNeuronRequest.authenticationData = jsonAuthenticationData
        let jsonUtilityBrainControllerNeuronRequest = JsonUtility<BrainControllerNeuronRequest>()
        let jsonBrainControllerNeuronRequest = jsonUtilityBrainControllerNeuronRequest.convertAnyObjectToJson(jsonObject: brainControllerNeuronRequest)
        
        // Send the request to the brain controller
        let neuronRequestLocal = NeuronRequest()
        neuronRequestLocal.neuronSource._id =   "\(ApplicationSetting.DeviceModelName!)|\(ApplicationSetting.DeviceUUID!)|\(NSUUID().uuidString)"
        neuronRequestLocal.neuronOperation.synchronus = true
        neuronRequestLocal.neuronSource.name = CallBrainControllerNeuron.getName()
        neuronRequestLocal.neuronSource.type = CallBrainControllerNeuron.getName();
        neuronRequestLocal.neuronOperation.name = SecurityNeuronOperationType.CreateUserConnection.name
        neuronRequestLocal.neuronOperation.parent = true
        neuronRequestLocal.neuronTarget.name = "SecurityNeuron"
        neuronRequestLocal.neuronOperation.neuronData.text = jsonBrainControllerNeuronRequest
        let brainControllerNeuron = BrainControllerNeuron.getDendrite(sourceId: neuronRequestLocal.neuronSource._id)
        brainControllerNeuron.setDendrite(neuronRequest: neuronRequestLocal, udbcDatabaseOrm: UDBCRealmDatabaseOrm(),  neuronUtility: NeuronUtilityImplementation())
    }
    
    public func getSecurityController(sourceName: String, language: String) {
        let uscSecurityControllerRequest = USCSecurityControllerRequest()
        uscSecurityControllerRequest.language = language
        uscSecurityControllerRequest.securityToken = applicationSecurityToken
        uscSecurityControllerRequest.upcApplicationProfileId = upcApplicationProfileId
        uscSecurityControllerRequest.upcCompanyProfileId = upcCompanyProfileId
        
        
        
        let jsonUtilityAuthenticationData = JsonUtility<USCSecurityControllerRequest>()
        let jsonAuthenticationData = jsonUtilityAuthenticationData.convertAnyObjectToJson(jsonObject: uscSecurityControllerRequest)
        
        // Convert brain controller neuron request into json and put it in neuron request
        let brainControllerNeuronRequest = BrainControllerNeuronRequest()
        brainControllerNeuronRequest.authenticationData = jsonAuthenticationData
        let jsonUtilityBrainControllerNeuronRequest = JsonUtility<BrainControllerNeuronRequest>()
        let jsonBrainControllerNeuronRequest = jsonUtilityBrainControllerNeuronRequest.convertAnyObjectToJson(jsonObject: brainControllerNeuronRequest)
        
        // Send the request to the brain controller
        let neuronRequestLocal = NeuronRequest()
        neuronRequestLocal.neuronSource._id =   "\(ApplicationSetting.DeviceModelName!)|\(ApplicationSetting.DeviceUUID!)|\(NSUUID().uuidString)"
        CallBrainControllerNeuron.sourceIdToSourceName[neuronRequestLocal.neuronSource._id] = sourceName
        neuronRequestLocal.neuronOperation.synchronus = true
        neuronRequestLocal.neuronSource.name = CallBrainControllerNeuron.getName()
        neuronRequestLocal.neuronSource.type = CallBrainControllerNeuron.getName();
        neuronRequestLocal.neuronOperation.name = SecurityNeuronOperationType.SecurityControllerView.name
        neuronRequestLocal.neuronOperation.parent = true
        neuronRequestLocal.neuronTarget.name = "SecurityNeuron"
        neuronRequestLocal.neuronOperation.neuronData.text = jsonBrainControllerNeuronRequest
        let brainControllerNeuron = BrainControllerNeuron.getDendrite(sourceId: neuronRequestLocal.neuronSource._id)
        brainControllerNeuron.setDendrite(neuronRequest: neuronRequestLocal, udbcDatabaseOrm: UDBCRealmDatabaseOrm(),  neuronUtility: NeuronUtilityImplementation())
    }
    
    public func getDocumentMap(sourceName: String, getDocumentMapRequest: GetDocumentMapRequest) {
        getDocumentMapRequest.upcHumanProfileId = ApplicationSetting.ProfileId!
        getDocumentMapRequest.upcApplicationProfileId = upcApplicationProfileId
        getDocumentMapRequest.upcCompanyProfileId = upcCompanyProfileId
        getDocumentMapRequest.udcProfile = getUDCProfile()
        getDocumentMapRequest.documentLanguage = ApplicationSetting.DocumentLanguage!
        getDocumentMapRequest.interfaceLanguage = ApplicationSetting.InterfaceLanguage!
        callNeuron(sourceName: sourceName, synchronus: true, operationName: "DocumentMapNeuron.DocumentMap.Get", targetName: "DocumentMapNeuron", objectToSend: getDocumentMapRequest,  dataType: "NeuronDataType.Json", dataOperationName: "NeuronDataOperationName.Json", binaryData: nil)
    }
    
    public func getDocumentMapByPath(sourceName: String, getDocumentMapByPathRequest: GetDocumentMapByPathRequest) {
        getDocumentMapByPathRequest.upcHumanProfileId = ApplicationSetting.ProfileId!
        getDocumentMapByPathRequest.upcApplicationProfileId = upcApplicationProfileId
        getDocumentMapByPathRequest.upcCompanyProfileId = upcCompanyProfileId
        getDocumentMapByPathRequest.documentLanguage = ApplicationSetting.DocumentLanguage!
        getDocumentMapByPathRequest.interfaceLanguage = ApplicationSetting.InterfaceLanguage!
        getDocumentMapByPathRequest.udcProfile.append(contentsOf: getUDCProfile())
        callNeuron(sourceName: sourceName, synchronus: true, operationName: "DocumentMapNeuron.DocumentMap.Get.ByPath", targetName: "DocumentGraphNeuron", objectToSend: getDocumentMapByPathRequest,  dataType: "NeuronDataType.Json", dataOperationName: "NeuronDataOperationName.Json", binaryData: nil)
    }
    
    public func documentDelete(sourceName: String, documentGraphDeleteRequest: DocumentGraphDeleteRequest) {
        documentGraphDeleteRequest.udcProfile.append(contentsOf: getUDCProfile())
        documentGraphDeleteRequest.upcApplicationProfileId = upcApplicationProfileId
        documentGraphDeleteRequest.upcCompanyProfileId = upcCompanyProfileId
        documentGraphDeleteRequest.documentLanguage = ApplicationSetting.DocumentLanguage!
        documentGraphDeleteRequest.interfaceLanguage = ApplicationSetting.InterfaceLanguage!
        documentGraphDeleteRequest.udcProfile.append(contentsOf: getUDCProfile())
        callNeuron(sourceName: sourceName, synchronus: true, operationName: "DocumentGraphNeuron.Document.Delete", targetName: "DocumentGraphNeuron", objectToSend: documentGraphDeleteRequest,  dataType: "NeuronDataType.Json", dataOperationName: "NeuronDataOperationName.Json", binaryData: nil)
    }
    
    public func getDocumentInterfacePhoto(sourceName: String, getDocumentInterfacePhotoRequest: GetDocumentInterfacePhotoRequest) {
        getDocumentInterfacePhotoRequest.udcProfile.append(contentsOf: getUDCProfile())
        getDocumentInterfacePhotoRequest.documentLanguage = ApplicationSetting.DocumentLanguage!
        callNeuron(sourceName: sourceName, synchronus: true, operationName: "DocumentGraphNeuron.Document.Get.InterfacePhoto", targetName: "DocumentGraphNeuron", objectToSend: getDocumentInterfacePhotoRequest,  dataType: "NeuronDataType.Json", dataOperationName: "NeuronDataOperationName.Json", binaryData: nil)
    }
    
    public func addDocumentMapNode(sourceName: String, userName: String, password: String, eMail: String, language: String, parentId: String, udcDocumentMapNode: UDCDocumentMapNode) {
//        let addDocumentMapNodeRequest = AddDocumentMapNodeRequest()
//        addDocumentMapNodeRequest.language = language
//        addDocumentMapNodeRequest.upcHumanProfileId = ApplicationSetting.ProfileId!
//        addDocumentMapNodeRequest.upcApplicationProfileId = upcApplicationProfileId
//        addDocumentMapNodeRequest.upcCompanyProfileId = upcCompanyProfileId
//        addDocumentMapNodeRequest.parentId = parentId
//        addDocumentMapNodeRequest.udcDocumentMapNode.append(udcDocumentMapNode)
//        addDocumentMapNodeRequest.documentLanguage = ApplicationSetting.DocumentLanguage!
//        addDocumentMapNodeRequest.interfaceLanguage = ApplicationSetting.InterfaceLanguage!
//        callNeuron(sourceName: sourceName, synchronus: true, operationName: "DocumentMapNeuron.DocumentMapNode.Add", targetName: "DocumentMapNeuron", objectToSend: addDocumentMapNodeRequest, dataType: "NeuronDataType.Json", dataOperationName: "NeuronDataOperationName.Json", binaryData: nil)
    }
    
    public func changeDocumentMapNode(sourceName: String, userName: String, password: String, eMail: String, language: String, id: String, udcDocumentMapNode: UDCDocumentMapNode) {
        let changeDocumentMapNodeRequest = ChangeDocumentMapNodeRequest()
        changeDocumentMapNodeRequest.language = language
        changeDocumentMapNodeRequest.upcHumanProfileId = ApplicationSetting.ProfileId!
        changeDocumentMapNodeRequest.upcApplicationProfileId = upcApplicationProfileId
        changeDocumentMapNodeRequest.upcCompanyProfileId = upcCompanyProfileId
        changeDocumentMapNodeRequest.udcDoumentMapNodeId = id
        //        changeDocumentMapNodeRequest.udcDocumentMapNode = udcDocumentMapNode
        
        callNeuron(sourceName: sourceName, synchronus: true, operationName: "DocumentMapNeuron.DocumentMapNode.Change", targetName: "DocumentMapNeuron", objectToSend: changeDocumentMapNodeRequest, dataType: "NeuronDataType.Json", dataOperationName: "NeuronDataOperationName.Json", binaryData: nil)
    }
    
    public func removeDocumentMapNode(sourceName: String, userName: String, password: String, eMail: String, language: String, udcDocumentMapNode: UDCDocumentMapNode) {
//        let removeDocumentMapNodeRequest = RemoveDocumentMapNodeRequest()
//        removeDocumentMapNodeRequest.language = language
//        removeDocumentMapNodeRequest.udcDocumentMapNode.append(udcDocumentMapNode)
//
//        callNeuron(sourceName: sourceName, synchronus: true, operationName: "DocumentMapNeuron.DocumentMapNode.Remove", targetName: "DocumentMapNeuron", objectToSend: removeDocumentMapNodeRequest, dataType: "NeuronDataType.Json", dataOperationName: "NeuronDataOperationName.Json", binaryData: nil)
    }
    
    public func newDocument(sourceName: String, userName: String, password: String, eMail: String, documentid: String, language: String, documentType: String) {
//        let getDocumentRequest = GetDocumentRequest()
//        getDocumentRequest.documentId = documentid
//        getDocumentRequest.language = language
//        getDocumentRequest.documentType = documentType
//
//        callNeuron(sourceName: sourceName, synchronus: true, operationName: "DocumentGraphNeuron.Document.New", targetName: "DocumentGraphNeuron", objectToSend: getDocumentRequest,  dataType: "NeuronDataType.Json", dataOperationName: "NeuronDataOperationName.Json", binaryData: nil)
    }
    
    public func getDocument(sourceName: String, userName: String, password: String, eMail: String, documentid: String, language: String, documentType: String) {
//        let getDocumentRequest = GetDocumentRequest()
//        getDocumentRequest.documentId = documentid
//        getDocumentRequest.language = language
//        getDocumentRequest.documentType = documentType
//
//        callNeuron(sourceName: sourceName, synchronus: true, operationName: "DocumentGraphNeuron.Document.Get", targetName: "DocumentGraphNeuron", objectToSend: getDocumentRequest,  dataType: "NeuronDataType.Json", dataOperationName: "NeuronDataOperationName.Json", binaryData: nil)
    }
    
    public func documentNew(sourceName: String, documentGraphNewRequest: DocumentGraphNewRequest, language: String, neuronName: String) {
        documentGraphNewRequest.upcCompanyProfileId = upcCompanyProfileId
        documentGraphNewRequest.upcApplicationProfileId = upcApplicationProfileId
        documentGraphNewRequest.documentLanguage = ApplicationSetting.DocumentLanguage!
        documentGraphNewRequest.interfaceLanguage = ApplicationSetting.InterfaceLanguage!
        documentGraphNewRequest.udcProfile.append(contentsOf: getUDCProfile())
        callNeuron(sourceName: sourceName, synchronus: true, operationName: "DocumentGraphNeuron.Document.New", targetName: neuronName, objectToSend: documentGraphNewRequest,  dataType: "NeuronDataType.Json", dataOperationName: "NeuronDataOperationName.Json", binaryData: nil)
    }
    
    public func documentAddCategory(sourceName: String, documentGraphAddCategoryRequest: DocumentGraphAddCategoryRequest, language: String, neuronName: String) {
        documentGraphAddCategoryRequest.udcProfile.append(contentsOf: getUDCProfile())
        callNeuron(sourceName: sourceName, synchronus: true, operationName: "RecipeNeuron.Document.AddCategory", targetName: neuronName, objectToSend: documentGraphAddCategoryRequest, dataType: "NeuronDataType.Json", dataOperationName: "NeuronDataOperationName.Json", binaryData: nil)
    }
    
    public func documentInsertItem(sourceName: String, documentGraphInsertItemRequest: DocumentGraphInsertItemRequest, language: String, neuronName: String) {
        documentGraphInsertItemRequest.udcProfile.append(contentsOf: getUDCProfile())
        documentGraphInsertItemRequest.upcApplicationProfileId = upcApplicationProfileId
        documentGraphInsertItemRequest.upcCompanyProfileId = upcCompanyProfileId
        if language.isEmpty {
            documentGraphInsertItemRequest.documentLanguage = ApplicationSetting.DocumentLanguage!
        } else {
            documentGraphInsertItemRequest.documentLanguage = language
        }
        documentGraphInsertItemRequest.interfaceLanguage = ApplicationSetting.InterfaceLanguage!
        callNeuron(sourceName: sourceName, synchronus: true, operationName: "DocumentGraphNeuron.Document.Item.Insert", targetName: neuronName, objectToSend: documentGraphInsertItemRequest, dataType: "NeuronDataType.Json", dataOperationName: "NeuronDataOperationName.Json", binaryData: nil)
    }
   
    
    public func documentChangeItem(sourceName: String, documentGraphChangeItemRequest: DocumentGraphChangeItemRequest, language: String, neuronName: String) {
        documentGraphChangeItemRequest.udcProfile.append(contentsOf: getUDCProfile())
        documentGraphChangeItemRequest.upcApplicationProfileId = upcApplicationProfileId
        documentGraphChangeItemRequest.upcCompanyProfileId = upcCompanyProfileId
        documentGraphChangeItemRequest.documentLanguage = ApplicationSetting.DocumentLanguage!
        callNeuron(sourceName: sourceName, synchronus: true, operationName: "DocumentGraphNeuron.Document.Item.Change", targetName: neuronName, objectToSend: documentGraphChangeItemRequest, dataType: "NeuronDataType.Json", dataOperationName: "NeuronDataOperationName.Json", binaryData: nil)
    }
    
    public func documentDeleteItem(sourceName: String, documentGraphDeleteItemRequest: DocumentGraphDeleteItemRequest, language: String, neuronName: String) {
        documentGraphDeleteItemRequest.udcProfile.append(contentsOf: getUDCProfile())
        documentGraphDeleteItemRequest.upcApplicationProfileId = upcApplicationProfileId
        documentGraphDeleteItemRequest.upcCompanyProfileId = upcCompanyProfileId
        documentGraphDeleteItemRequest.documentLanguage = ApplicationSetting.DocumentLanguage!
        callNeuron(sourceName: sourceName, synchronus: true, operationName: "DocumentGraphNeuron.Document.Item.Delete", targetName: neuronName, objectToSend: documentGraphDeleteItemRequest, dataType: "NeuronDataType.Json", dataOperationName: "NeuronDataOperationName.Json", binaryData: nil)
    }
    
    public func getDocumentView(sourceName: String, getDocumentGraphViewRequest: GetDocumentGraphViewRequest, neuronName: String) {
        getDocumentGraphViewRequest.udcProfile.append(contentsOf: getUDCProfile())
        getDocumentGraphViewRequest.udcProfile = getUDCProfile()
        getDocumentGraphViewRequest.interfaceLanguage = ApplicationSetting.InterfaceLanguage!
        callNeuron(sourceName: sourceName, synchronus: true, operationName: "DocumentGraphNeuron.Document.Get.View", targetName: neuronName, objectToSend: getDocumentGraphViewRequest, dataType: "NeuronDataType.Json", dataOperationName: "NeuronDataOperationName.Json", binaryData: nil)
    }
    
    //    public func changeDocument(userName: String, password: String, eMail: String, model: String, language: String, documentType: String, version: String, reason: String, categoryId: String, name: String, description: String, udcDocumentMapNodeId: String, udcDocument: UDCDocument) {
    //        let udcDocumentLocal = udcDocument
    //        udcDocumentLocal.language = language
    //        udcDocumentLocal.upcHumanProfileId.append(ApplicationSetting.HumanProfileId!)
    //        udcDocumentLocal.upcApplicationProfileId.append(upcApplicationProfileId)
    //        udcDocumentLocal.upcCompanyProfileId.append(upcCompanyProfileId)
    //        udcDocumentLocal.categoryId = categoryId
    //        udcDocumentLocal.name = name
    //        udcDocumentLocal.description = description
    //
    //        udcDocumentLocal.udcDocumentModel[0].documentModel = model
    //        udcDocumentLocal.udcDocumentModel[0].udcDocumentType = "UDCDocumentViewType.Recipe"
    //
    //        let udcDcumentHistory = UDCDcumentHistory()
    //        udcDcumentHistory.time = Date()
    //        udcDcumentHistory.humanProfileId = udcDocumentLocal.upcHumanProfileId[0]
    //        udcDcumentHistory.reason = reason
    //        udcDcumentHistory.version = version
    //        udcDocumentLocal.udcDocumentHistory.append(udcDcumentHistory)
    //        let saveDocumentRequest = SaveDocumentRequest()
    //        saveDocumentRequest.udcDocument = udcDocumentLocal
    //        saveDocumentRequest.udcDocumentMapNodeId = udcDocumentMapNodeId
    //
    //        callNeuron(synchronus: true, operationName: "DocumentGraphNeuron.Document.Change", targetName: "DocumentGraphNeuron", objectToSend: saveDocumentRequest, language: language)
    //    }
    //
    //    public func saveDocument(userName: String, password: String, eMail: String, model: String, language: String, documentType: String, version: String, reason: String, categoryId: String, name: String, description: String, udcDocumentMapNodeId: String, udcDocument: UDCDocument) {
    //        let udcDocumentLocal = udcDocument
    //        udcDocumentLocal.language = language
    //        udcDocumentLocal.upcHumanProfileId.append(ApplicationSetting.HumanProfileId!)
    //        udcDocumentLocal.upcApplicationProfileId.append(upcApplicationProfileId)
    //        udcDocumentLocal.upcCompanyProfileId.append(upcCompanyProfileId)
    //        udcDocumentLocal.categoryId = categoryId
    //        udcDocumentLocal.name = name
    //        udcDocumentLocal.description = description
    //
    //        let udcDocumentModel = UDCDocumentModel()
    //        udcDocumentModel.documentModel = model
    //        udcDocumentModel.udcDocumentType = "UDCDocumentViewType.Recipe"
    //        udcDocumentLocal.udcDocumentModel.append(udcDocumentModel)
    //
    //        let udcDcumentHistory = UDCDcumentHistory()
    //        udcDcumentHistory.time = Date()
    //        udcDcumentHistory.humanProfileId = udcDocumentLocal.upcHumanProfileId[0]
    //        udcDcumentHistory.reason = reason
    //        udcDcumentHistory.version = version
    //        udcDocumentLocal.udcDocumentHistory.append(udcDcumentHistory)
    //        let saveDocumentRequest = SaveDocumentRequest()
    //        saveDocumentRequest.udcDocument = udcDocumentLocal
    //        saveDocumentRequest.udcDocumentMapNodeId = udcDocumentMapNodeId
    //
    //        callNeuron(synchronus: true, operationName: "DocumentGraphNeuron.Document.Save", targetName: "DocumentGraphNeuron", objectToSend: saveDocumentRequest, language: language)
    //    }
    
    public func getSentencePattern(sourceName: String, userName: String, password: String, eMail: String, language: String, category: String) {
        let sentencePatternRequest = SentencePatternRequest()
        sentencePatternRequest.category = category
        sentencePatternRequest.language = "en"
        
        callNeuron(sourceName: sourceName, synchronus: true, operationName: "RecipeNeuronOperationType.SentencePattern", targetName: "RecipeNeuron", objectToSend: sentencePatternRequest,  dataType: "NeuronDataType.Json", dataOperationName: "NeuronDataOperationName.Json", binaryData: nil)
    }
    
    public func getSentence(sourceName: String, language: String, sentenceRequest: SentenceRequest, neuronName: String) {
        callNeuron(sourceName: sourceName, synchronus: true, operationName: "GrammarNeuron.Sentence.Generate", targetName: neuronName, objectToSend: sentenceRequest, dataType: "NeuronDataType.Json", dataOperationName: "NeuronDataOperationName.Json", binaryData: nil)
    }
    
    
    public func getOptions(sourceName: String, language: String, getOptionMapRequest: GetOptionMapRequest, neuronName: String, optionSuffix: String) {
        getOptionMapRequest.udcProfile = getUDCProfile()
        getOptionMapRequest.documentLanguage = ApplicationSetting.DocumentLanguage!
        getOptionMapRequest.interfaceLanguage = ApplicationSetting.InterfaceLanguage!
        if ApplicationSetting.DocumentType != nil {
            getOptionMapRequest.documentType = ApplicationSetting.DocumentType!
        }
        callNeuron(sourceName: sourceName, synchronus: true, operationName: "OptionMapNeuron.OptionMap.Get.\(optionSuffix)", targetName: neuronName, objectToSend: getOptionMapRequest,  dataType: "NeuronDataType.Json", dataOperationName: "NeuronDataOperationName.Json", binaryData: nil)
    }
    
    public func searchDocument(sourceName: String, language: String?, documentMapSearchDocumentRequest: DocumentMapSearchDocumentRequest, neuronName: String) {
        documentMapSearchDocumentRequest.udcProfile = getUDCProfile()
        if language == nil {
            documentMapSearchDocumentRequest.documentLanguage = ApplicationSetting.DocumentLanguage!
            documentMapSearchDocumentRequest.interfaceLanguage = ApplicationSetting.InterfaceLanguage!
        } else {
            documentMapSearchDocumentRequest.documentLanguage = language!
            documentMapSearchDocumentRequest.interfaceLanguage = language!
        }
        callNeuron(sourceName: sourceName, synchronus: true, operationName: "DocumentMapNeuron.Search.Document", targetName: neuronName, objectToSend: documentMapSearchDocumentRequest, dataType: "NeuronDataType.Json", dataOperationName: "NeuronDataOperationName.Json", binaryData: nil)
    }
    
    public func searchDocumentItem(sourceName: String, language: String, documentGraphItemSearchRequest: DocumentGraphItemSearchRequest, neuronName: String) {
        documentGraphItemSearchRequest.udcProfile = getUDCProfile()
        documentGraphItemSearchRequest.documentLanguage = ApplicationSetting.DocumentLanguage!
        documentGraphItemSearchRequest.interfaceLanguage = ApplicationSetting.InterfaceLanguage!
        callNeuron(sourceName: sourceName, synchronus: true, operationName: "DocumentItemNeuron.Search.DocumentItem", targetName: neuronName, objectToSend: documentGraphItemSearchRequest, dataType: "NeuronDataType.Json", dataOperationName: "NeuronDataOperationName.Json", binaryData: nil)
    }
    
    public func documentReference(sourceName: String, language: String, documentGraphItemReferenceRequest: DocumentGraphItemReferenceRequest, neuronName: String) {
        documentGraphItemReferenceRequest.udcProfile.append(contentsOf: getUDCProfile())
        documentGraphItemReferenceRequest.documentLanguage = ApplicationSetting.DocumentLanguage!
        documentGraphItemReferenceRequest.interfaceLanguage = ApplicationSetting.InterfaceLanguage!
        callNeuron(sourceName: sourceName, synchronus: true, operationName: "DocumentGraphNeuron.Document.Item.Reference", targetName: neuronName, objectToSend: documentGraphItemReferenceRequest, dataType: "NeuronDataType.Json", dataOperationName: "NeuronDataOperationName.Json", binaryData: nil)
    }
    
    public func documentNewLine(sourceName: String, language: String, documentGraphInsertNewLineRequest: DocumentGraphInsertNewLineRequest, neuronName: String) {
        documentGraphInsertNewLineRequest.udcProfile.append(contentsOf: getUDCProfile())
        documentGraphInsertNewLineRequest.documentLanguage = ApplicationSetting.DocumentLanguage!
        documentGraphInsertNewLineRequest.interfaceLanguage = ApplicationSetting.InterfaceLanguage!
        callNeuron(sourceName: sourceName, synchronus: true, operationName: "DocumentGraphNeuron.Document.Insert.NewLine", targetName: neuronName, objectToSend: documentGraphInsertNewLineRequest, dataType: "NeuronDataType.Json", dataOperationName: "NeuronDataOperationName.Json", binaryData: nil)
    }
    
    public func documentDeleteLine(sourceName: String, language: String, documentGraphDeleteLineRequest: DocumentGraphDeleteLineRequest, neuronName: String) {
        documentGraphDeleteLineRequest.udcProfile.append(contentsOf: getUDCProfile())
        documentGraphDeleteLineRequest.documentLanguage = ApplicationSetting.DocumentLanguage!
        documentGraphDeleteLineRequest.interfaceLanguage = ApplicationSetting.InterfaceLanguage!
        callNeuron(sourceName: sourceName, synchronus: true, operationName: "DocumentGraphNeuron.Document.Delete.Line", targetName: neuronName, objectToSend: documentGraphDeleteLineRequest, dataType: "NeuronDataType.Json", dataOperationName: "NeuronDataOperationName.Json", binaryData: nil)
    }
    
    public func objectController(sourceName: String, language: String, objectControllerRequest: ObjectControllerRequest, neuronName: String) {
        callNeuron(sourceName: sourceName, synchronus: true, operationName: "DocumentGraphNeuron.ObjectController.ViewItem.Insert", targetName: neuronName, objectToSend: objectControllerRequest, dataType: "NeuronDataType.Json", dataOperationName: "NeuronDataOperationName.Json", binaryData: nil)
    }
    
    public func getUDCProfile() -> [UDCProfile] {
        var udcProfileArray = [UDCProfile]()
        var udcProfile = UDCProfile()
        udcProfile.udcProfileItemIdName = "UDCProfileItem.Human"
        udcProfile.profileId = ApplicationSetting.ProfileId!
        udcProfileArray.append(udcProfile)
        udcProfile = UDCProfile()
        udcProfile.udcProfileItemIdName = "UDCProfileItem.Application"
        udcProfile.profileId = upcApplicationProfileId
        udcProfileArray.append(udcProfile)
        udcProfile = UDCProfile()
        udcProfile.udcProfileItemIdName = "UDCProfileItem.Company"
        udcProfile.profileId = upcCompanyProfileId
        udcProfileArray.append(udcProfile)
        
        return udcProfileArray
    }
    
    public func userWordAdd(sourceName: String, language: String, userWordAddRequest: UserWordAddRequest) {
        userWordAddRequest.udcUserWordDictionary.language = language
        userWordAddRequest.udcUserWordDictionary.udcProfile.append(contentsOf: getUDCProfile())
        callNeuron(sourceName: sourceName, synchronus: true, operationName: "RecipeNeuron.User.Word.Add", targetName: "RecipeNeuron", objectToSend: userWordAddRequest, dataType: "NeuronDataType.Json", dataOperationName: "NeuronDataOperationName.Json", binaryData: nil)
    }
    
    public func documentSaveAsTemplate(sourceName: String, language: String, documentSaveAsTemplateRequest: DocumentGraphSaveAsTemplateRequest) {
        documentSaveAsTemplateRequest.udcProfile.append(contentsOf: getUDCProfile())
        callNeuron(sourceName: sourceName, synchronus: true, operationName: "DocumentGraphNeuron.SaveAsTemplate", targetName: "DocumentGraphNeuron", objectToSend: documentSaveAsTemplateRequest, dataType: "NeuronDataType.Json", dataOperationName: "NeuronDataOperationName.Json", binaryData: nil)
    }
    
//    public func userSentencePatternAdd(sourceName: String, language: String, userSentencePatternAddRequest: UserSentencePatternAddRequest) {
//        var udcProfile = UDCProfile()
//        udcProfile.udcProfileItemIdName = "UDCProfileItem.Human"
//        udcProfile.profileId = ApplicationSetting.ProfileId!
//        userSentencePatternAddRequest.udcProfile.append(udcProfile)
//        udcProfile = UDCProfile()
//        udcProfile.udcProfileItemIdName = "UDCProfileItem.Application"
//        udcProfile.profileId = upcApplicationProfileId
//        userSentencePatternAddRequest.udcProfile.append(udcProfile)
//        udcProfile = UDCProfile()
//        udcProfile.udcProfileItemIdName = "UDCProfileItem.Company"
//        udcProfile.profileId = upcCompanyProfileId
//        userSentencePatternAddRequest.udcProfile.append(udcProfile)
//        callNeuron(sourceName: sourceName, synchronus: true, operationName: "DocumentGraphNeuron.User.SentencePattern.Add", targetName: "RecipeNeuron", objectToSend: userSentencePatternAddRequest,  dataType: "NeuronDataType.Json", dataOperationName: "NeuronDataOperationName.Json", binaryData: nil)
//    }
    
    public func getObjectControllerView(sourceName: String, language: String, getObjectControllerViewRequest: GetObjectControllerViewRequest) {
        getObjectControllerViewRequest.udcProfile = getUDCProfile()
        getObjectControllerViewRequest.documentLanguage = ApplicationSetting.DocumentLanguage!
        getObjectControllerViewRequest.interfaceLanguage = ApplicationSetting.InterfaceLanguage!
        callNeuron(sourceName: sourceName, synchronus: true, operationName: "DocumentGraphNeuron.Get.ViewController.View", targetName: "DocumentGraphNeuron", objectToSend: getObjectControllerViewRequest, dataType: "NeuronDataType.Json", dataOperationName: "NeuronDataOperationName.Json", binaryData: nil)
    }
    
    public func storeItemPhoto(sourceName: String, language: String, documentGraphStorePhotoRequest: DocumentStorePhotoRequest, binaryData: Data) {
        documentGraphStorePhotoRequest.udcProfile.append(contentsOf: getUDCProfile())
        documentGraphStorePhotoRequest.documentLanguage = ApplicationSetting.DocumentLanguage!
        documentGraphStorePhotoRequest.interfaceLanguage = ApplicationSetting.InterfaceLanguage!
        callNeuron(sourceName: sourceName, synchronus: true, operationName: "PhotoNeuron.Store.Item.Photo", targetName: "PhotoNeuron", objectToSend: documentGraphStorePhotoRequest,  dataType: "NeuronDataType.Binary", dataOperationName: "NeuronDataOperationName.Store.Binary", binaryData: binaryData)
    }
    
    public func getItemPhoto(sourceName: String, language: String, documentGraphGetPhotoRequest: DocumentGetPhotoRequest) {
        documentGraphGetPhotoRequest.udcDocumentTypeIdName = ApplicationSetting.DocumentType!
        documentGraphGetPhotoRequest.udcProfile.append(contentsOf: getUDCProfile())
        documentGraphGetPhotoRequest.documentLanguage = ApplicationSetting.DocumentLanguage!
        callNeuron(sourceName: sourceName, synchronus: true, operationName: "PhotoNeuron.Get.Item.Photo", targetName: "PhotoNeuron", objectToSend: documentGraphGetPhotoRequest,  dataType: "NeuronDataType.Binary", dataOperationName: "NeuronDataOperationName.Get.Binary", binaryData: nil)
    }
    
    public func getViewConfigurationOptions(sourceName: String, language: String, documentGetViewConfigurationOptionsRequest: DocumentGetViewConfigurationOptionsRequest) {
        documentGetViewConfigurationOptionsRequest.udcProfile = getUDCProfile()
        documentGetViewConfigurationOptionsRequest.udcProfile.append(contentsOf: getUDCProfile())
        documentGetViewConfigurationOptionsRequest.documentLanguage = ApplicationSetting.DocumentLanguage!
        documentGetViewConfigurationOptionsRequest.interfaceLanguage = ApplicationSetting.InterfaceLanguage!
        callNeuron(sourceName: sourceName, synchronus: true, operationName: "DocumentGraphNeuron.Get.View.Configuration.Options", targetName: "DocumentGraphNeuron", objectToSend: documentGetViewConfigurationOptionsRequest, dataType: "NeuronDataType.Json", dataOperationName: "NeuronDataOperationName.Json", binaryData: nil)
    }
    
    public func category(sourceName: String, language: String, documentCategorySelectedRequest: DocumentCategorySelectedRequest) {
        documentCategorySelectedRequest.upcCompanyProfileId = upcCompanyProfileId
        documentCategorySelectedRequest.upcApplicationProfileId = upcApplicationProfileId
        documentCategorySelectedRequest.udcProfile.append(contentsOf: getUDCProfile())
        documentCategorySelectedRequest.documentLanguage = ApplicationSetting.DocumentLanguage!
        documentCategorySelectedRequest.interfaceLanguage = ApplicationSetting.InterfaceLanguage!
        callNeuron(sourceName: sourceName, synchronus: true, operationName: "DocumentGraphNeuron.Document.Category.Selected", targetName: "DocumentGraphNeuron", objectToSend: documentCategorySelectedRequest, dataType: "NeuronDataType.Json", dataOperationName: "NeuronDataOperationName.Json", binaryData: nil)
    }
    
    public func categoryOptions(sourceName: String, language: String, documentCategoryOptionSelectedRequest: DocumentCategoryOptionSelectedRequest) {
        documentCategoryOptionSelectedRequest.upcCompanyProfileId = upcCompanyProfileId
        documentCategoryOptionSelectedRequest.upcApplicationProfileId = upcApplicationProfileId
        documentCategoryOptionSelectedRequest.udcProfile.append(contentsOf: getUDCProfile())
        documentCategoryOptionSelectedRequest.documentLanguage = ApplicationSetting.DocumentLanguage!
        documentCategoryOptionSelectedRequest.interfaceLanguage = ApplicationSetting.InterfaceLanguage!
        callNeuron(sourceName: sourceName, synchronus: true, operationName: "DocumentGraphNeuron.Document.Category.Options.Selected", targetName: "DocumentGraphNeuron", objectToSend: documentCategoryOptionSelectedRequest, dataType: "NeuronDataType.Json", dataOperationName: "NeuronDataOperationName.Json", binaryData: nil)
    }
    
    public func documentAddToFavourite(sourceName: String, documentAddToFavouriteRequest: DocumentAddToFavouriteRequest) {
        documentAddToFavouriteRequest.upcCompanyProfileId = upcCompanyProfileId
        documentAddToFavouriteRequest.upcApplicationProfileId = upcApplicationProfileId
        documentAddToFavouriteRequest.udcProfile.append(contentsOf: getUDCProfile())
        documentAddToFavouriteRequest.documentLanguage = ApplicationSetting.DocumentLanguage!
        documentAddToFavouriteRequest.interfaceLanguage = ApplicationSetting.InterfaceLanguage!
        callNeuron(sourceName: sourceName, synchronus: true, operationName: "DocumentGraphNeuron.Document.Add.To.Favourite", targetName: "DocumentGraphNeuron", objectToSend: documentAddToFavouriteRequest, dataType: "NeuronDataType.Json", dataOperationName: "NeuronDataOperationName.Json", binaryData: nil)
    }
    
    public func getType(sourceName: String, typeRequest: GetDocumentItemOptionRequest) {
        typeRequest.documentLanguage = ApplicationSetting.DocumentLanguage!
        typeRequest.interfaceLanguage = ApplicationSetting.InterfaceLanguage!
        typeRequest.udcProfile = getUDCProfile()
        callNeuron(sourceName: sourceName, synchronus: true, operationName: "DocumentItemNeuron.Get.DocumentItem.Options", targetName: "DocumentItemNeuron", objectToSend: typeRequest, dataType: "NeuronDataType.Json", dataOperationName: "NeuronDataOperationName.Json", binaryData: nil)
    }
    
    public func getType(sourceName: String, type: String, category: String, language: String, fromText: String, sortedBy: String, limitedTo: Int, isAll: Bool, searchText: String) {
        let typeRequest = GetDocumentItemOptionRequest()
        typeRequest.type = type
        typeRequest.category = category
        typeRequest.language = language
        typeRequest.fromText = fromText
        typeRequest.sortedBy = sortedBy
        typeRequest.limitedTo = limitedTo
        typeRequest.isAll = isAll
        typeRequest.searchText = searchText
        typeRequest.documentLanguage = ApplicationSetting.DocumentLanguage!
        typeRequest.interfaceLanguage = ApplicationSetting.InterfaceLanguage!
        
        callNeuron(sourceName: sourceName, synchronus: true, operationName: "DocumentItemNeuron.Get.DocumentItem.Options", targetName: "DocumentItemNeuron", objectToSend: typeRequest, dataType: "NeuronDataType.Json", dataOperationName: "NeuronDataOperationName.Json", binaryData: nil)
    }
    
    private func callNeuron<T: Codable>(sourceName: String, synchronus: Bool, operationName: String, targetName: String, objectToSend: T?, dataType: String, dataOperationName: String, binaryData: Data?) {
        
        let uscUserAuthenticationRequest =  USCUserAuthenticationRequest()
        uscUserAuthenticationRequest.userProfileId = ApplicationSetting.ProfileId ?? ""
        uscUserAuthenticationRequest.upcApplicationProfileId = upcApplicationProfileId
        uscUserAuthenticationRequest.upcCompanyProfileId = upcCompanyProfileId
        let securityToken = ApplicationSetting.SecurityToken ?? ""
        if !securityToken.isEmpty {
            uscUserAuthenticationRequest.type.append(USCApplicationAuthenticationType.SecurityTokenAuthentication.name)
            uscUserAuthenticationRequest.uscSecurityTokenAuthentication.securityToken = ApplicationSetting.SecurityToken!
        } else {
            uscUserAuthenticationRequest.type.append(USCApplicationAuthenticationType.UserNamePasswordAuthenticaiton.name)
            uscUserAuthenticationRequest.uscUserNamePasswordAuthentication.userName = ApplicationSetting.UserName!
            uscUserAuthenticationRequest.uscUserNamePasswordAuthentication.password = ApplicationSetting.Password!
        }
        
        // Convert document neuron request and user authentication request to json and
        // put it in brain controller neuron request
        let jsonUtilityRequestObject = JsonUtility<T>()
        var jsonRequestObject = ""
        if objectToSend != nil {
            jsonRequestObject = jsonUtilityRequestObject.convertAnyObjectToJson(jsonObject: objectToSend!)
        }
        let jsonUtilityUSCUserAuthenticationRequest = JsonUtility<USCUserAuthenticationRequest>()
        let jsonUSCUserAuthenticationRequest = jsonUtilityUSCUserAuthenticationRequest.convertAnyObjectToJson(jsonObject: uscUserAuthenticationRequest)
        
        // Convert brain controller neuron request into json and put it in neuron request
        let brainControllerNeuronRequest = BrainControllerNeuronRequest()
        if objectToSend != nil {
            brainControllerNeuronRequest.requestData = jsonRequestObject
        }
        brainControllerNeuronRequest.authenticationData = jsonUSCUserAuthenticationRequest
        let jsonUtilityBrainControllerNeuronRequest = JsonUtility<BrainControllerNeuronRequest>()
        let jsonBrainControllerNeuronRequest = jsonUtilityBrainControllerNeuronRequest.convertAnyObjectToJson(jsonObject: brainControllerNeuronRequest)
        
        // Send the request to the brain controller
        let neuronRequestLocal = NeuronRequest()
        neuronRequestLocal.neuronSource._id =   "\(ApplicationSetting.DeviceModelName!)|\(ApplicationSetting.DeviceUUID!)|\(NSUUID().uuidString)"
        CallBrainControllerNeuron.sourceIdToSourceName[neuronRequestLocal.neuronSource._id] = sourceName
        neuronRequestLocal.neuronOperation.synchronus = synchronus
        neuronRequestLocal.neuronSource.name = CallBrainControllerNeuron.getName()
        neuronRequestLocal.neuronSource.type = CallBrainControllerNeuron.getName()
        neuronRequestLocal.neuronOperation.name = operationName
        neuronRequestLocal.neuronOperation.parent = true
        neuronRequestLocal.neuronTarget.name = targetName
        neuronRequestLocal.neuronOperation.neuronData.text = jsonBrainControllerNeuronRequest
        neuronRequestLocal.neuronOperation.neuronData.dataOperationName = dataOperationName
        neuronRequestLocal.neuronOperation.neuronData.type = dataType
        neuronRequestLocal.neuronOperation.neuronData.binaryData = binaryData
        let brainControllerNeuron = BrainControllerNeuron.getDendrite(sourceId: neuronRequestLocal.neuronSource._id)
        brainControllerNeuron.setDendrite(neuronRequest: neuronRequestLocal, udbcDatabaseOrm: UDBCRealmDatabaseOrm(),  neuronUtility: NeuronUtilityImplementation())
    }
    
    
    public func setDendrite(neuronRequest: NeuronRequest, udbcDatabaseOrm: UDBCDatabaseOrm,  neuronUtility: NeuronUtility) {
        if neuronRequest.neuronOperation.acknowledgement == true {
            print("\(CallBrainControllerNeuron.getName()): Got Acknowledgement")
            return
        }
        if neuronRequest.neuronOperation.response  == true {
            print("\(CallBrainControllerNeuron.getName()): Got Response")
            // MAY CAUSE MEMORY NO NEED
            //            CallBrainControllerNeuron.setChildResponse(sourceId: neuronRequest.neuronSource._id, neuronRequest: neuronRequest)
            //            print("***********RESPONSE CAME: "+neuronRequest.neuronOperation.neuronData.text)
            var sourceName: String?
            if neuronRequest.neuronSource._id.isEmpty {
                sourceName = String(describing: DetailViewController.self)
            } else {
                sourceName = CallBrainControllerNeuron.sourceIdToSourceName[neuronRequest.neuronSource._id]!
            }
            
            NotificationCenter.default.post(name: CallBrainControllerNeuron.sourceNotificationMap[sourceName!]!, object: neuronRequest)
            print("\(CallBrainControllerNeuron.getName()): Removed dendtrite: \(neuronRequest.neuronSource._id) ")
            CallBrainControllerNeuron.sourceIdToSourceName.removeValue(forKey: neuronRequest.neuronSource._id)
            CallBrainControllerNeuron.removeDendrite(sourceId: neuronRequest.neuronSource._id)
        }
    }
    
    
    static public func getName() -> String {
        return "CallBrainControllerNeuron"
    }
    
    static public func getDescription() -> String {
        return "Call BrainController Neuron"
    }
    
    static public func getDendrite(sourceId: String) -> (Neuron) {
        var neuron: Neuron?
        
        serialQueue.sync {
            print("Before: \(dendriteMap.debugDescription)")
            neuron = dendriteMap[sourceId]
            if neuron == nil {
                print("\(getName()): Created: \(sourceId)")
                dendriteMap[sourceId] = CallBrainControllerNeuron()
                neuron = dendriteMap[sourceId]
            }
            print("After creation: \(dendriteMap.debugDescription)")
        }
        
        return  neuron!;
    }
    
    
    
    private static func setChildResponse(sourceId: String, neuronRequest: NeuronRequest) {
        serialQueue.sync {
            responseMap[sourceId] = neuronRequest
        }
    }
    
    private static func getChildResponse(sourceId: String) -> NeuronRequest {
        var neuronResponse: NeuronRequest?
        serialQueue.sync {
            print(responseMap)
            if let _ = responseMap[sourceId] {
                neuronResponse = responseMap[sourceId]
                responseMap.removeValue(forKey: sourceId)
            }
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
    
    
    public static func getRootResponse(neuronSourceId: String) -> NeuronRequest {
        return NeuronRequest()
    }
}


