//
//  ViewController.swift
//  UniversalDocs
//
//  Created by Kumar Muthaiah on 01/11/18.
//  Copyright © 2018 Kumar Muthaiah. All rights reserved.
//



import UIKit

import Alamofire


extension Notification.Name {
    static let brainControllerNueronResponseReceived = Notification.Name("brainControllerNueronResponseReceived")
}

public class CallBrainControllerNeuron : Neuron {
    let neuronUtility = NeuronUtility()
    var udbcDatabaseOrm: UDBCDatabaseOrm?
    static var dendriteMap: [String : Neuron] = [String : Neuron]()
    static var responseMap: [String : NeuronRequest] = [String : NeuronRequest]()
    static let serialQueue = DispatchQueue(label: "SerialQueue")
    static public var delegateMap = [String: Any]()
    private var applicationSecurityToken = "6bWEqiirrP7yZbG40pwmkw"
    private var upcApplicationProfileId = "5bd721358d1a9c7d4866c9d9"
    private var upcCompanyProfileId = "5bd721358d1a9c7d4766c9d9"

    public init() {
        
    }
    
    func modelIdentifier() -> String {
        if let simulatorModelIdentifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] { return simulatorModelIdentifier }
        var sysinfo = utsname()
        uname(&sysinfo) // ignore return value
        return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
    }
    
    public func connectUser(userName: String, password: String, eMail: String) {
        callNeuron(synchronus: true, operationName: SecurityNeuronOperationType.ConnectUser.name, targetName: "SecurityNeuron", objectToSend: USCUserAuthenticationRequest(), language: "en")
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
        neuronRequestLocal.neuronSource._id = NSUUID.init().uuidString
        neuronRequestLocal.neuronOperation.synchronus = true
        neuronRequestLocal.neuronSource.name = CallBrainControllerNeuron.getName()
        neuronRequestLocal.neuronSource.type = CallBrainControllerNeuron.getName();
        neuronRequestLocal.neuronOperation.name = "SecurityNeuronOperationType.ForgotPasswordVerifyIdentity"
        neuronRequestLocal.neuronOperation.parent = true
        neuronRequestLocal.neuronTarget.name = "SecurityNeuron"
        neuronRequestLocal.neuronOperation.neuronData.text = jsonBrainControllerNeuronRequest
        let brainControllerNeuron = BrainControllerNeuron.getDendrite(sourceId: neuronRequestLocal.neuronSource._id)
        brainControllerNeuron.setDendrite(neuronRequest: neuronRequestLocal, udbcDatabaseOrm: UDBCDatabaseOrm())
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
        neuronRequestLocal.neuronSource._id = NSUUID.init().uuidString
        neuronRequestLocal.neuronOperation.synchronus = true
        neuronRequestLocal.neuronSource.name = CallBrainControllerNeuron.getName()
        neuronRequestLocal.neuronSource.type = CallBrainControllerNeuron.getName();
        neuronRequestLocal.neuronOperation.name = "SecurityNeuronOperationType.ForgotPasswordVerifySecret"
        neuronRequestLocal.neuronOperation.parent = true
        neuronRequestLocal.neuronTarget.name = "SecurityNeuron"
        neuronRequestLocal.neuronOperation.neuronData.text = jsonBrainControllerNeuronRequest
        let brainControllerNeuron = BrainControllerNeuron.getDendrite(sourceId: neuronRequestLocal.neuronSource._id)
        brainControllerNeuron.setDendrite(neuronRequest: neuronRequestLocal, udbcDatabaseOrm: UDBCDatabaseOrm())
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
        neuronRequestLocal.neuronSource._id = NSUUID.init().uuidString
        neuronRequestLocal.neuronOperation.synchronus = true
        neuronRequestLocal.neuronSource.name = CallBrainControllerNeuron.getName()
        neuronRequestLocal.neuronSource.type = CallBrainControllerNeuron.getName();
        neuronRequestLocal.neuronOperation.name = "SecurityNeuronOperationType.ForgotPasswordChangePassword"
        neuronRequestLocal.neuronOperation.parent = true
        neuronRequestLocal.neuronTarget.name = "SecurityNeuron"
        neuronRequestLocal.neuronOperation.neuronData.text = jsonBrainControllerNeuronRequest
        let brainControllerNeuron = BrainControllerNeuron.getDendrite(sourceId: neuronRequestLocal.neuronSource._id)
        brainControllerNeuron.setDendrite(neuronRequest: neuronRequestLocal, udbcDatabaseOrm: UDBCDatabaseOrm())
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
        neuronRequestLocal.neuronSource._id = NSUUID.init().uuidString
        neuronRequestLocal.neuronOperation.synchronus = true
        neuronRequestLocal.neuronSource.name = CallBrainControllerNeuron.getName()
        neuronRequestLocal.neuronSource.type = CallBrainControllerNeuron.getName();
        neuronRequestLocal.neuronOperation.name = SecurityNeuronOperationType.CreateUserConnection.name
        neuronRequestLocal.neuronOperation.parent = true
        neuronRequestLocal.neuronTarget.name = "SecurityNeuron"
        neuronRequestLocal.neuronOperation.neuronData.text = jsonBrainControllerNeuronRequest
        let brainControllerNeuron = BrainControllerNeuron.getDendrite(sourceId: neuronRequestLocal.neuronSource._id)
        brainControllerNeuron.setDendrite(neuronRequest: neuronRequestLocal, udbcDatabaseOrm: UDBCDatabaseOrm())
    }
    
    public func getSecurityController(language: String) {
        let uscSecurityControllerRequest = USCSecurityControllerRequest()
        uscSecurityControllerRequest.language = language
        uscSecurityControllerRequest.securityToken = applicationSecurityToken
        uscSecurityControllerRequest.upcApplicationProfileId = upcApplicationProfileId
        uscSecurityControllerRequest.upcCompanyProfileId = upcCompanyProfileId
        uscSecurityControllerRequest.deviceId = UIDevice.current.identifierForVendor!.uuidString
        uscSecurityControllerRequest.deviceModelIdentifier = modelIdentifier()
        
        let jsonUtilityAuthenticationData = JsonUtility<USCSecurityControllerRequest>()
        let jsonAuthenticationData = jsonUtilityAuthenticationData.convertAnyObjectToJson(jsonObject: uscSecurityControllerRequest)
        
        // Convert brain controller neuron request into json and put it in neuron request
        let brainControllerNeuronRequest = BrainControllerNeuronRequest()
        brainControllerNeuronRequest.authenticationData = jsonAuthenticationData
        let jsonUtilityBrainControllerNeuronRequest = JsonUtility<BrainControllerNeuronRequest>()
        let jsonBrainControllerNeuronRequest = jsonUtilityBrainControllerNeuronRequest.convertAnyObjectToJson(jsonObject: brainControllerNeuronRequest)
        
        // Send the request to the brain controller
        let neuronRequestLocal = NeuronRequest()
        neuronRequestLocal.neuronSource._id = NSUUID.init().uuidString
        neuronRequestLocal.neuronOperation.synchronus = true
        neuronRequestLocal.neuronSource.name = CallBrainControllerNeuron.getName()
        neuronRequestLocal.neuronSource.type = CallBrainControllerNeuron.getName();
        neuronRequestLocal.neuronOperation.name = SecurityNeuronOperationType.SecurityControllerView.name
        neuronRequestLocal.neuronOperation.parent = true
        neuronRequestLocal.neuronTarget.name = "SecurityNeuron"
        neuronRequestLocal.neuronOperation.neuronData.text = jsonBrainControllerNeuronRequest
        let brainControllerNeuron = BrainControllerNeuron.getDendrite(sourceId: neuronRequestLocal.neuronSource._id)
        brainControllerNeuron.setDendrite(neuronRequest: neuronRequestLocal, udbcDatabaseOrm: UDBCDatabaseOrm())
    }
    
    public func getDocumentMap(userName: String, password: String, eMail: String, language: String, uvcDocumentMapViewTemplateType: String, idName: String) {
        let getDocumentMapRequest = GetDocumentMapRequest()
        getDocumentMapRequest.upcHumanProfileId = ApplicationSetting.ProfileId!
        getDocumentMapRequest.upcApplicationProfileId = upcApplicationProfileId
        getDocumentMapRequest.upcCompanyProfileId = upcCompanyProfileId
        getDocumentMapRequest.uvcDocumentMapViewTemplateType = uvcDocumentMapViewTemplateType
        getDocumentMapRequest.idName = idName
        
        callNeuron(synchronus: true, operationName: "DocumentMapNeuron.DocumentMap.Get", targetName: "DocumentMapNeuron", objectToSend: getDocumentMapRequest, language: language)
    }
    
    public func addDocumentMapNode(userName: String, password: String, eMail: String, language: String, parentId: String, udcDocumentMapNode: UDCDocumentMapNode) {
        let addDocumentMapNodeRequest = AddDocumentMapNodeRequest()
        addDocumentMapNodeRequest.language = language
        addDocumentMapNodeRequest.upcHumanProfileId = ApplicationSetting.ProfileId!
        addDocumentMapNodeRequest.upcApplicationProfileId = upcApplicationProfileId
        addDocumentMapNodeRequest.upcCompanyProfileId = upcCompanyProfileId
        addDocumentMapNodeRequest.udcDoumentMapNodeId = parentId
        addDocumentMapNodeRequest.udcDocumentMapNode = udcDocumentMapNode
        
        callNeuron(synchronus: true, operationName: "DocumentMapNeuron.DocumentMapNode.Add", targetName: "DocumentMapNeuron", objectToSend: addDocumentMapNodeRequest, language: language)
    }
    
    public func changeDocumentMapNode(userName: String, password: String, eMail: String, language: String, id: String, udcDocumentMapNode: UDCDocumentMapNode) {
        let changeDocumentMapNodeRequest = ChangeDocumentMapNodeRequest()
        changeDocumentMapNodeRequest.language = language
        changeDocumentMapNodeRequest.upcHumanProfileId = ApplicationSetting.ProfileId!
        changeDocumentMapNodeRequest.upcApplicationProfileId = upcApplicationProfileId
        changeDocumentMapNodeRequest.upcCompanyProfileId = upcCompanyProfileId
        changeDocumentMapNodeRequest.udcDoumentMapNodeId = id
        changeDocumentMapNodeRequest.udcDocumentMapNode = udcDocumentMapNode
        
        callNeuron(synchronus: true, operationName: "DocumentMapNeuron.DocumentMapNode.Change", targetName: "DocumentMapNeuron", objectToSend: changeDocumentMapNodeRequest, language: language)
    }
    
    public func removeDocumentMapNode(userName: String, password: String, eMail: String, language: String, udcDocumentMapNode: UDCDocumentMapNode) {
        let removeDocumentMapNodeRequest = RemoveDocumentMapNodeRequest()
        removeDocumentMapNodeRequest.language = language
        removeDocumentMapNodeRequest.udcDocumentMapNode = udcDocumentMapNode
        
        callNeuron(synchronus: true, operationName: "DocumentMapNeuron.DocumentMapNode.Remove", targetName: "DocumentMapNeuron", objectToSend: removeDocumentMapNodeRequest, language: language)
    }
    
    public func newDocument(userName: String, password: String, eMail: String, documentid: String, language: String, documentType: String) {
        let getDocumentRequest = GetDocumentRequest()
        getDocumentRequest.documentId = documentid
        getDocumentRequest.language = language
        getDocumentRequest.documentType = documentType

        callNeuron(synchronus: true, operationName: "DocumentNeuron.Document.New", targetName: "DocumentNeuron", objectToSend: getDocumentRequest, language: language)
    }

    public func getDocument(userName: String, password: String, eMail: String, documentid: String, language: String, documentType: String) {
        let getDocumentRequest = GetDocumentRequest()
        getDocumentRequest.documentId = documentid
        getDocumentRequest.language = language
        getDocumentRequest.documentType = documentType
        
        callNeuron(synchronus: true, operationName: "DocumentNeuron.Document.Get", targetName: "DocumentNeuron", objectToSend: getDocumentRequest, language: language)
    }
    
    public func documentNew(documentNewRequest: DocumentNewRequest, language: String, neuronName: String) {
        documentNewRequest.udcProfile.append(contentsOf: getUDCProfile())
        callNeuron(synchronus: true, operationName: "DocumentNeuron.Document.New", targetName: neuronName, objectToSend: documentNewRequest, language: language)
    }
    
    public func documentAddCategory(documentAddCategoryRequest: DocumentAddCategoryRequest, language: String, neuronName: String) {
        documentAddCategoryRequest.udcProfile.append(contentsOf: getUDCProfile())
        callNeuron(synchronus: true, operationName: "RecipeNeuron.Document.AddCategory", targetName: neuronName, objectToSend: documentAddCategoryRequest, language: language)
    }
    
    public func documentInsertItem(documentInsertItemRequest: DocumentInsertItemRequest, language: String, neuronName: String) {
        documentInsertItemRequest.udcProfile.append(contentsOf: getUDCProfile())
        callNeuron(synchronus: true, operationName: "DocumentNeuron.Document.Item.Insert", targetName: neuronName, objectToSend: documentInsertItemRequest, language: language)
    }
    
    public func documentChangeItem(documentChangeItemRequest: DocumentChangeItemRequest, language: String, neuronName: String) {
        documentChangeItemRequest.udcProfile.append(contentsOf: getUDCProfile())
        callNeuron(synchronus: true, operationName: "DocumentNeuron.Document.Item.Change", targetName: neuronName, objectToSend: documentChangeItemRequest, language: language)
    }
    
    public func documentDeleteItem(documentDeleteItemRequest: DocumentDeleteItemRequest, language: String, neuronName: String) {
        documentDeleteItemRequest.udcProfile.append(contentsOf: getUDCProfile())
        callNeuron(synchronus: true, operationName: "DocumentNeuron.Document.Item.Delete", targetName: neuronName, objectToSend: documentDeleteItemRequest, language: language)
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
//        callNeuron(synchronus: true, operationName: "DocumentNeuron.Document.Change", targetName: "DocumentNeuron", objectToSend: saveDocumentRequest, language: language)
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
//        callNeuron(synchronus: true, operationName: "DocumentNeuron.Document.Save", targetName: "DocumentNeuron", objectToSend: saveDocumentRequest, language: language)
//    }
    
    public func getSentencePattern(userName: String, password: String, eMail: String, language: String, category: String) {
        let sentencePatternRequest = SentencePatternRequest()
        sentencePatternRequest.category = category
        sentencePatternRequest.language = "en"
        
        callNeuron(synchronus: true, operationName: "RecipeNeuronOperationType.SentencePattern", targetName: "RecipeNeuron", objectToSend: sentencePatternRequest, language: language)
    }
    
    public func getSentence(language: String, sentenceRequest: SentenceRequest, neuronName: String) {
        callNeuron(synchronus: true, operationName: "GrammarNeuron.Sentence.Generate", targetName: neuronName, objectToSend: sentenceRequest, language: language)
    }
    
    
    public func getOptions(language: String, getOptionMapRequest: GetOptionMapRequest, neuronName: String, optionSuffix: String) {
        getOptionMapRequest.upcApplicationProfileId = upcApplicationProfileId
        getOptionMapRequest.upcCompanyProfileId = upcCompanyProfileId
        if ApplicationSetting.DocumentType != nil {
            getOptionMapRequest.documentType = ApplicationSetting.DocumentType!
        }
        callNeuron(synchronus: true, operationName: "OptionMapNeuron.OptionMap.Get.\(optionSuffix)", targetName: neuronName, objectToSend: getOptionMapRequest, language: ApplicationSetting.DocumentLanguage!)
    }
    
    public func searchDocumentItem(language: String, documentItemSearchRequest: DocumentItemSearchRequest, neuronName: String) {
        documentItemSearchRequest.upcHumanProfileId = ApplicationSetting.ProfileId!
        documentItemSearchRequest.upcCompanyProfileId = upcCompanyProfileId
        documentItemSearchRequest.upcApplicationProfileId = upcApplicationProfileId
        callNeuron(synchronus: true, operationName: "DocumentNeuron.Search.DocumentItem", targetName: neuronName, objectToSend: documentItemSearchRequest, language: language)
    }
    
    public func documentReference(language: String, documentItemReferenceRequest: DocumentItemReferenceRequest, neuronName: String) {
        documentItemReferenceRequest.udcProfile.append(contentsOf: getUDCProfile())
        callNeuron(synchronus: true, operationName: "DocumentNeuron.Document.Item.Reference", targetName: neuronName, objectToSend: documentItemReferenceRequest, language: language)
    }
    
    public func documentNewLine(language: String, documentInsertNewLineRequest: DocumentInsertNewLineRequest, neuronName: String) {
        documentInsertNewLineRequest.udcProfile.append(contentsOf: getUDCProfile())
        callNeuron(synchronus: true, operationName: "DocumentNeuron.Document.Insert.NewLine", targetName: neuronName, objectToSend: documentInsertNewLineRequest, language: language)
    }
    
    public func documentDeleteLine(language: String, documentDeleteLineRequest: DocumentDeleteLineRequest, neuronName: String) {
        documentDeleteLineRequest.udcProfile.append(contentsOf: getUDCProfile())
        callNeuron(synchronus: true, operationName: "DocumentNeuron.Document.Delete.Line", targetName: neuronName, objectToSend: documentDeleteLineRequest, language: language)
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
    
    public func userWordAdd(language: String, userWordAddRequest: UserWordAddRequest) {
        userWordAddRequest.udcUserWordDictionary.language = language
        userWordAddRequest.udcUserWordDictionary.udcProfile.append(contentsOf: getUDCProfile())
        callNeuron(synchronus: true, operationName: "RecipeNeuron.User.Word.Add", targetName: "RecipeNeuron", objectToSend: userWordAddRequest, language: language)
    }
    
    public func documentSaveAsTemplate(language: String, documentSaveAsTemplateRequest: DocumentSaveAsTemplateRequest) {
        documentSaveAsTemplateRequest.udcProfile.append(contentsOf: getUDCProfile())
        callNeuron(synchronus: true, operationName: "DocumentNeuron.SaveAsTemplate", targetName: "DocumentNeuron", objectToSend: documentSaveAsTemplateRequest, language: language)
    }
    
    public func userSentencePatternAdd(language: String, userSentencePatternAddRequest: UserSentencePatternAddRequest) {
        var udcProfile = UDCProfile()
        udcProfile.udcProfileItemIdName = "UDCProfileItem.Human"
        udcProfile.profileId = ApplicationSetting.ProfileId!
        userSentencePatternAddRequest.udcProfile.append(udcProfile)
        udcProfile = UDCProfile()
        udcProfile.udcProfileItemIdName = "UDCProfileItem.Application"
        udcProfile.profileId = upcApplicationProfileId
        userSentencePatternAddRequest.udcProfile.append(udcProfile)
        udcProfile = UDCProfile()
        udcProfile.udcProfileItemIdName = "UDCProfileItem.Company"
        udcProfile.profileId = upcCompanyProfileId
        userSentencePatternAddRequest.udcProfile.append(udcProfile)
        callNeuron(synchronus: true, operationName: "DocumentNeuron.User.SentencePattern.Add", targetName: "RecipeNeuron", objectToSend: userSentencePatternAddRequest, language: language)
    }
    
    public func getType(type: String, language: String, fromText: String, sortedBy: String, limitedTo: Int, isAll: Bool, searchText: String) {
        let typeRequest = TypeRequest()
        typeRequest.type = type
        typeRequest.language = language
        typeRequest.fromText = fromText
        typeRequest.sortedBy = sortedBy
        typeRequest.limitedTo = limitedTo
        typeRequest.isAll = isAll
        typeRequest.searchText = searchText
        
        callNeuron(synchronus: true, operationName: "TypeNeuron.Get", targetName: "TypeNeuron", objectToSend: typeRequest, language: language)
    }
    
    private func callNeuron<T: Codable>(synchronus: Bool, operationName: String, targetName: String, objectToSend: T?, language: String) {
        
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
        neuronRequestLocal.neuronSource._id = NSUUID.init().uuidString
        neuronRequestLocal.language = language
        neuronRequestLocal.neuronOperation.synchronus = synchronus
        neuronRequestLocal.neuronSource.name = CallBrainControllerNeuron.getName()
        neuronRequestLocal.neuronSource.type = CallBrainControllerNeuron.getName();
        neuronRequestLocal.neuronOperation.name = operationName
        neuronRequestLocal.neuronOperation.parent = true
        neuronRequestLocal.neuronTarget.name = targetName
        neuronRequestLocal.neuronOperation.neuronData.text = jsonBrainControllerNeuronRequest
        let brainControllerNeuron = BrainControllerNeuron.getDendrite(sourceId: neuronRequestLocal.neuronSource._id)
        brainControllerNeuron.setDendrite(neuronRequest: neuronRequestLocal, udbcDatabaseOrm: UDBCDatabaseOrm())
    }
    
    
    public func setDendrite(neuronRequest: NeuronRequest, udbcDatabaseOrm: UDBCDatabaseOrm) {
        if neuronRequest.neuronOperation.acknowledgement == true {
            print("\(CallBrainControllerNeuron.getName()): Got Acknowledgement")
            return
        }
        if neuronRequest.neuronOperation.response  == true {
            print("\(CallBrainControllerNeuron.getName()): Got Response")
            // MAY CAUSE MEMORY NO NEED
//            CallBrainControllerNeuron.setChildResponse(sourceId: neuronRequest.neuronSource._id, neuronRequest: neuronRequest)
//            print("***********RESPONSE CAME: "+neuronRequest.neuronOperation.neuronData.text)
            NotificationCenter.default.post(name: .brainControllerNueronResponseReceived, object: neuronRequest)
            print("\(CallBrainControllerNeuron.getName()): Removed dendtrite: \(neuronRequest.neuronSource._id) ")

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
    
    
   
}


