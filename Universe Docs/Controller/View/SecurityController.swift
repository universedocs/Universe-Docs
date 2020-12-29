//
//  ConnetionController.swift
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
import UDocsBrain
import UDocsUtility
import UDocsDocumentUtility
import UDocsNeuronModel
import UDocsSecurityNeuronModel
import UDocsViewModel

public class SecurityController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate, UIPopoverPresentationControllerDelegate, PopoverViewControllerDelegate, UVCViewControllerDelegate {
    
    
    let uvcViewController = UVCViewController()
    var activityIndicator: UIActivityIndicatorView?
    public var masterViewController: MasterViewController?
    private var connectUserViewModel: String = ""
    private var createConnectionViewModel: String = ""
    private var forgotPasswordVerifyIdentityViewModel: String = ""
    private var forgotPasswordVerifySecretViewModel: String = ""
    private var forgotPasswordChangePasswordViewModel: String = ""
    private var forgotPasswordChangePasswordDoneViewModel: String = ""
    public var stackView: UIStackView?
    private var nextTextFieldTag: Int = 0
    private var currentOptionCategory: String = ""
    private var currentOperation: String = ""
    var errorMessage = [UVCPopoverNode]()
    private var documentParser = DocumentParser()

    private var currentSender: Any?
    
    @IBOutlet weak var securityView: UIScrollView!
    override public func viewDidLoad() {
        super.viewDidLoad()
        uvcViewController.delegate = self
        securityView.backgroundColor = UIColor(patternImage: UIImage(named: "UniversalDocsConnectBackground")!)
        NotificationCenter.default.addObserver(self, selector: #selector(brainControllerNeuronResponse(_:)), name: .securityControllerNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        ApplicationSetting.deleteAll()
        ApplicationSetting.InterfaceLanguage = "en"
        ApplicationSetting.DocumentLanguage = "en"
        ApplicationSetting.DocumentType = "UDCDocumentType.DocumentItem"
        ApplicationSetting.CursorMode = "false"
        if ApplicationSetting.DeviceUUID == nil {
            ApplicationSetting.DeviceUUID = NSUUID().uuidString
        }
        if ApplicationSetting.DeviceModelName == nil {
            ApplicationSetting.DeviceModelName = modelIdentifier()
        }
        if ApplicationSetting.SecurityToken == nil {
            showActivityIndicator()
            let callBrainControllerNeuron = CallBrainControllerNeuron()
            callBrainControllerNeuron.getSecurityController(sourceName: String(describing: SecurityController.self), language: ApplicationSetting.InterfaceLanguage!)
            currentOperation = SecurityNeuronOperationType.ConnectUser.name
        } else {
            showApplication()
        }
        
    }
    
    func modelIdentifier() -> String {
        let service = IOServiceGetMatchingService(kIOMasterPortDefault,
                                                  IOServiceMatching("IOPlatformExpertDevice"))
        var modelIdentifier: String?
        if let modelData = IORegistryEntryCreateCFProperty(service, "model" as CFString, kCFAllocatorDefault, 0).takeRetainedValue() as? Data {
            modelIdentifier = String(data: modelData, encoding: .utf8)?.trimmingCharacters(in: .controlCharacters)
        }

        if modelIdentifier == nil {
            return "ModelIdentifierError"
        }
        
        IOObjectRelease(service)
        return modelIdentifier!
    }
  
    // Show activity indicator for busy operation
    private func showActivityIndicator() {
        // Disable interaction to the document map and show activity indicator
        activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        activityIndicator!.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(100), height: CGFloat(100))
        
        // Let the user know doing something
        activityIndicator!.color = .green
        activityIndicator!.center = self.view.center
        self.view.addSubview(activityIndicator!)
        activityIndicator!.startAnimating()
        
    }
    
    // Done with busy work
    private func hideActivityIndicator() {
        // Enable interaction to document map and hide activity monitor
        activityIndicator!.stopAnimating()
    }
  
    
    @objc func brainControllerNeuronResponse(_ notification:Notification) {
        let neuronRequest: NeuronRequest = notification.object as! NeuronRequest
        if neuronRequest.neuronOperation.name == SecurityNeuronOperationType.CreateUserConnection.name  || neuronRequest.neuronOperation.name == SecurityNeuronOperationType.ConnectUser.name || neuronRequest.neuronOperation.name == SecurityNeuronOperationType.SecurityControllerView.name || neuronRequest.neuronOperation.name == "SecurityNeuronOperationType.ForgotPasswordVerifyIdentity" || neuronRequest.neuronOperation.name == "SecurityNeuronOperationType.ForgotPasswordVerifySecret" || neuronRequest.neuronOperation.name == "SecurityNeuronOperationType.ForgotPasswordChangePassword" {
            
            if neuronRequest.neuronOperation.neuronOperationStatus.neuronOperationError!.count > 0 {
                hideActivityIndicator()
                errorMessage.removeAll()
                for neuronOperationError in neuronRequest.neuronOperation.neuronOperationStatus.neuronOperationError! {
                    errorMessage.append(UVCPopoverNode.getNode(name: neuronOperationError.description))
                }
                let errorButton = getErrorButton(operationName: neuronRequest.neuronOperation.name)
                if !errorButton.name.isEmpty {
                    errorButton.uiButton.isHidden = false
                    errorButton.uiButton.setTitle("\(errorMessage.count) Error(s)", for: .normal)
                    showErrorMessageIfAny(errorMessage: errorMessage, sender: errorButton.uiButton)
                }
                return
            }
            if neuronRequest.neuronOperation.neuronOperationStatus.neuronOperationSuccess!.count > 0 {
                hideActivityIndicator()
                if neuronRequest.neuronOperation.name == SecurityNeuronOperationType.CreateUserConnection.name {
                    handleCreateUserConnection(neuronRequest: neuronRequest)
                } else if neuronRequest.neuronOperation.name == SecurityNeuronOperationType.ConnectUser.name {
                    handleConnect(neuronRequest: neuronRequest)
                } else if neuronRequest.neuronOperation.name == SecurityNeuronOperationType.SecurityControllerView.name {
                    handleSecurityControllerView(neuronRequest: neuronRequest)
                } else if neuronRequest.neuronOperation.name == SecurityNeuronOperationType.CreateUserConnection.name {
                    handleCreateUserConnection(neuronRequest: neuronRequest)
                } else if neuronRequest.neuronOperation.name == "SecurityNeuronOperationType.ForgotPasswordVerifyIdentity" {
                    handleForgotPasswordVerifyIdentity(neuronRequest: neuronRequest)
                } else if neuronRequest.neuronOperation.name == "SecurityNeuronOperationType.ForgotPasswordVerifySecret" {
                    handleForgotPasswordVerifySecret(neuronRequest: neuronRequest)
                } else if neuronRequest.neuronOperation.name == "SecurityNeuronOperationType.ForgotPasswordChangePassword" {
                    handleForgotPasswordChangePassword(neuronRequest: neuronRequest)
                }

            }
        }
        
    }
    
    private func getErrorButton(operationName: String) -> UVCUIButton {
        var errorButton: UVCUIButton?
        if operationName == SecurityNeuronOperationType.ConnectUser.name || operationName == SecurityNeuronOperationType.SecurityControllerView.name {
            errorButton = uvcViewController.uvcUIViewControllerItemCollection.getButton(tag: 0, name: "ConnectErrorLabel")
        } else if operationName == SecurityNeuronOperationType.CreateUserConnection.name {
            errorButton = uvcViewController.uvcUIViewControllerItemCollection.getButton(tag: 0, name: "CreateConnectionErrorLabel")
        } else if operationName.hasPrefix("SecurityNeuronOperationType.ForgotPassword") {
            errorButton = uvcViewController.uvcUIViewControllerItemCollection.getButton(tag: 0, name: "ForgotPasswordErrorLabel")
        }
        errorButton?.uiButton.setTitleColor(UIColor.red, for: .normal)
        if errorButton == nil {
            return UVCUIButton()
        }
        return errorButton!
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func handleForgotPasswordVerifyIdentity(neuronRequest: NeuronRequest) {
        hideActivityIndicator()
        let jsonUtilityUSCForgotPasswordVerifyIdentityResponse = JsonUtility<USCForgotPasswordVerifyIdentityResponse>()
        let uscForgotPasswordVerifyIdentityResponse = jsonUtilityUSCForgotPasswordVerifyIdentityResponse.convertJsonToAnyObject(json: neuronRequest.neuronOperation.neuronData.text)
        if uscForgotPasswordVerifyIdentityResponse.result == true {
            ApplicationSetting.ProfileId = uscForgotPasswordVerifyIdentityResponse.upcHumanProfileId
            let subViews = securityView.subviews
            for subview in subViews {
                subview.removeFromSuperview()
            }
            showView(viewModel: forgotPasswordVerifySecretViewModel,operationName: "SecurityNeuronOperationType.ForgotPasswordVerifySecret")
            currentOperation = "SecurityNeuronOperationType.ForgotPasswordVerifySecret"
        }
    }
    
    
    private func handleForgotPasswordVerifySecret(neuronRequest: NeuronRequest) {
        hideActivityIndicator()
        let jsonUtilityUSCForgotPasswordVerifySecretResponse = JsonUtility<USCForgotPasswordVerifySecretResponse>()
        let uscForgotPasswordVerifySecretResponse = jsonUtilityUSCForgotPasswordVerifySecretResponse.convertJsonToAnyObject(json: neuronRequest.neuronOperation.neuronData.text)
        if uscForgotPasswordVerifySecretResponse.result == true {
            let subViews = securityView.subviews
            for subview in subViews {
                subview.removeFromSuperview()
            }
            showView(viewModel: forgotPasswordChangePasswordViewModel,operationName: "SecurityNeuronOperationType.ForgotPasswordChangePassword")
            currentOperation = "SecurityNeuronOperationType.ForgotPasswordChangePassword"
        }
    }

    private func handleForgotPasswordChangePassword(neuronRequest: NeuronRequest) {
        hideActivityIndicator()
        let jsonUtilityUSCForgotPasswordChangePasswordResponse = JsonUtility<USCForgotPasswordChangePasswordResponse>()
        let uscForgotPasswordChangePasswordResponse = jsonUtilityUSCForgotPasswordChangePasswordResponse.convertJsonToAnyObject(json: neuronRequest.neuronOperation.neuronData.text)
        if uscForgotPasswordChangePasswordResponse.result == true {
            let subViews = securityView.subviews
            for subview in subViews {
                subview.removeFromSuperview()
            }
            showView(viewModel: forgotPasswordChangePasswordDoneViewModel,operationName: "SecurityNeuronOperationType.ForgotPasswordChangePasswordDone")
            currentOperation = "SecurityNeuronOperationType.ForgotPasswordChangePasswordDone"
        }
    }
    
    private func handleCreateUserConnection(neuronRequest: NeuronRequest) {
        hideActivityIndicator()
        handleConnect(neuronRequest: neuronRequest)
    }
    
    private func handleSecurityControllerView(neuronRequest: NeuronRequest) {
        hideActivityIndicator()
        let jsonUtilityUSCSecurityControllerResponse = JsonUtility<USCSecurityControllerResponse>()
        let uscSecurityControllerResponse = jsonUtilityUSCSecurityControllerResponse.convertJsonToAnyObject(json: neuronRequest.neuronOperation.neuronData.text)

        if self.view != nil {
            
            connectUserViewModel = uscSecurityControllerResponse.modelDictionary["ConnectUserViewModel"]!
            createConnectionViewModel = uscSecurityControllerResponse.modelDictionary["CreateConnectionViewModel"]!
            forgotPasswordVerifyIdentityViewModel = uscSecurityControllerResponse.modelDictionary["ForgotPasswordVerifyIdentityViewModel"]!
            forgotPasswordVerifySecretViewModel = uscSecurityControllerResponse.modelDictionary["ForgotPasswordVerifySecretViewModel"]!
            forgotPasswordChangePasswordViewModel = uscSecurityControllerResponse.modelDictionary["ForgotPasswordChangePasswordViewModel"]!
            forgotPasswordChangePasswordDoneViewModel = uscSecurityControllerResponse.modelDictionary["ForgotPasswordChangePasswordDoneViewModel"]!
                showView(viewModel: connectUserViewModel, operationName: neuronRequest.neuronOperation.name)
        }
    }
    
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        if stackView != nil  {
            securityView.contentSize = stackView!.sizeThatFits(CGSize(width: stackView!.frame.width, height: 3000))
        }
    }
    
    
    private func showView(viewModel: String, operationName: String) {
        do {
            let jsonUtilityUVCViewModel = JsonUtility<UVCViewModel>()
            uvcViewController.delegate = self
            stackView = try uvcViewController.getView(uvcViewModel:  jsonUtilityUVCViewModel.convertJsonToAnyObject(json: viewModel), view: self.view, iEditableMode: true) as? UIStackView
        
            securityView.addSubview(stackView!)
            
            setControlEvents()
            stackView!.translatesAutoresizingMaskIntoConstraints = false
            stackView!.centerXAnchor.constraint(equalTo: securityView.centerXAnchor).isActive = true
            stackView!.centerYAnchor.constraint(equalTo: securityView.centerYAnchor).isActive = true
            hideIfAny(operationName: operationName)
        } catch {
            let alert = UIAlertController(title: "Alert", message: "Error in View: \(error.localizedDescription)", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                switch action.style{
                case .default:
                    print("default")
                    
                case .cancel:
                    print("cancel")
                    
                case .destructive:
                    print("destructive")
                    
                    
                }}))
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
    
    private func setControlEvents() {
        for uvcUIButton in uvcViewController.uvcUIViewControllerItemCollection.uvcUIButton {
            uvcUIButton.uiButton.addTarget(self, action: #selector(handleButtonPressed(_:)), for: .touchUpInside)
            if uvcUIButton.name == "ConnectErrorLabel" && uvcUIButton.name == "CreateConnectionErrorLabel" {
                uvcUIButton.uiButton.setTitleColor(UIColor.red, for: .normal)
                uvcUIButton.uiButton.isHidden = true
            }
        }
        for uvcUITextField in uvcViewController.uvcUIViewControllerItemCollection.uvcUITextField {
            uvcUITextField.uiTextField.delegate = self
            uvcUITextField.uiTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
    }
    
    private func handleConnect(neuronRequest: NeuronRequest) {
        hideActivityIndicator()
        if neuronRequest.neuronOperation.name == SecurityNeuronOperationType.CreateUserConnection.name {
            let jsonUtilityUSCCreateConnectionResponse = JsonUtility<USCCreateConnectionResponse>()
            let uscCreateConnectionResponse = jsonUtilityUSCCreateConnectionResponse.convertJsonToAnyObject(json: neuronRequest.neuronOperation.neuronData.text)
            ApplicationSetting.ProfileId = documentParser.getUDCProfile(udcProfile: uscCreateConnectionResponse.udcProfile, idName: "UDCProfileItem.Human")
            ApplicationSetting.SecurityToken = uscCreateConnectionResponse.uscSecurityTokenAuthentication.securityToken
        } else {
            let jsonUtilityUSCSecurityControllerResponse = JsonUtility<USCUserAuthenticationResponse>()
            let uscUserAuthenticationResponse = jsonUtilityUSCSecurityControllerResponse.convertJsonToAnyObject(json: neuronRequest.neuronOperation.neuronData.text)
            if !uscUserAuthenticationResponse.userProfileId.isEmpty {
                ApplicationSetting.ProfileId = uscUserAuthenticationResponse.userProfileId
            }
            ApplicationSetting.SecurityToken = uscUserAuthenticationResponse.uscSecurityTokenAuthentication.securityToken
        }
       showApplication()
    }
    
    private func showApplication() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let splitViewController = storyboard.instantiateViewController(withIdentifier: "SplitView") as! UISplitViewController
        splitViewController.preferredDisplayMode = .primaryHidden
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let tabController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UITabBarController
        var masterViewController: MasterViewController?
        for viewController in tabController.viewControllers! {
            let individualNavigationController = viewController as! UINavigationController
            individualNavigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
            individualNavigationController.topViewController!.navigationItem.leftItemsSupplementBackButton = true
            
        }
        splitViewController.delegate = appDelegate
        appDelegate.window?.rootViewController = splitViewController
    }
   
    private func hideIfAny(operationName: String) {
        let errorButton = getErrorButton(operationName: operationName)
        errorButton.uiButton.isHidden = true
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        let uvcUITextField = uvcViewController.uvcUIViewControllerItemCollection.getTextField(tag: textField.tag, name: "")
        if uvcUITextField!.name == "UserName" || uvcUITextField!.name == "EMail" {
            textField.text = textField.text?.lowercased()
        } else if uvcUITextField!.name == "FirstName" || uvcUITextField!.name == "MiddleName" || uvcUITextField!.name == "LastName" {
            textField.text = textField.text?.capitalized
        }
    }
    
    @objc private func handleButtonPressed(_ sender: UIButton) {
        let uvcUIButton = uvcViewController.uvcUIViewControllerItemCollection.getButton(tag: sender.tag, name: "")
        if uvcUIButton != nil {
            if uvcUIButton!.name == "CreateConnection" {
                if currentOperation == SecurityNeuronOperationType.CreateUserConnection.name {
                    showActivityIndicator()
                    let callBrainControllerNeuron = CallBrainControllerNeuron()
                    let userName = uvcViewController.uvcUIViewControllerItemCollection.getTextField(tag: 0, name: "UserName")?.uiTextField.text
                    let password = uvcViewController.uvcUIViewControllerItemCollection.getTextField(tag: 0, name: "Password")?.uiTextField.text
                    ApplicationSetting.UserName = userName!
                    ApplicationSetting.Password = password!
                    let firstName = uvcViewController.uvcUIViewControllerItemCollection.getTextField(tag: 0, name: "FirstName")?.uiTextField.text
                    let middleName = uvcViewController.uvcUIViewControllerItemCollection.getTextField(tag: 0, name: "MiddleName")?.uiTextField.text
                    let lastName = uvcViewController.uvcUIViewControllerItemCollection.getTextField(tag: 0, name: "LastName")?.uiTextField.text
                    let eMail = uvcViewController.uvcUIViewControllerItemCollection.getTextField(tag: 0, name: "EMail")?.uiTextField.text
                    callBrainControllerNeuron.createConnection(userName: userName!, password: password!, firstName: firstName!, middleName: middleName!, lastName: lastName!, eMail: eMail!, language: ApplicationSetting.InterfaceLanguage!)
                } else { // Just showing screen
                    let subViews = securityView.subviews
                    for subview in subViews {
                        subview.removeFromSuperview()
                    }
                    showView(viewModel: createConnectionViewModel,operationName: SecurityNeuronOperationType.CreateUserConnection.name)
                    currentOperation = SecurityNeuronOperationType.CreateUserConnection.name
                }
            } else if uvcUIButton!.name == "GoToConnect" {
                currentOperation = SecurityNeuronOperationType.ConnectUser.name
                let subViews = securityView.subviews
                for subview in subViews {
                    subview.removeFromSuperview()
                }
                showView(viewModel: connectUserViewModel,operationName: SecurityNeuronOperationType.ConnectUser.name)
            } else if uvcUIButton!.name == "Connect" {
                currentOperation = SecurityNeuronOperationType.ConnectUser.name
                hideIfAny(operationName: SecurityNeuronOperationType.ConnectUser.name)
                currentSender = sender
                let userName = uvcViewController.uvcUIViewControllerItemCollection.getTextField(tag: 0, name: "UserName")?.uiTextField.text
                let password = uvcViewController.uvcUIViewControllerItemCollection.getTextField(tag: 0, name: "Password")?.uiTextField.text
                showActivityIndicator()
                let name = uvcViewController.uvcUIViewControllerItemCollection.getButton(tag: sender.tag, name: "")!.name
                if name == "Connect" {
                    ApplicationSetting.UserName = userName!
                    ApplicationSetting.Password = password!
                    let callBrainControllerNeuron = CallBrainControllerNeuron()
                    callBrainControllerNeuron.connectUser(sourceName: String(describing: SecurityController.self), userName: userName!, password: password!, eMail: "")
                }
            } else if uvcUIButton!.name.hasSuffix("ErrorLabel") {
                showErrorMessageIfAny(errorMessage: errorMessage, sender: sender)
            } else if uvcUIButton!.name == "ForgotPassword" {
                
                    showForgotPasswordVerifyIdentityView()
                
            } else if uvcUIButton!.name == "GetSecretInEMail" {
            
                showActivityIndicator()
                let callBrainControllerNeuron = CallBrainControllerNeuron()
                let userName = uvcViewController.uvcUIViewControllerItemCollection.getTextField(tag: 0, name: "UserName")?.uiTextField.text
                callBrainControllerNeuron.forgotPasswordVerifyIdentity(userName: userName!, language: ApplicationSetting.InterfaceLanguage!)
            
            } else if uvcUIButton!.name == "Verify" {
                
                showActivityIndicator()
                let callBrainControllerNeuron = CallBrainControllerNeuron()
                let emailSecret = uvcViewController.uvcUIViewControllerItemCollection.getTextField(tag: 0, name: "EMailSecret")?.uiTextField.text
                callBrainControllerNeuron.forgotPasswordVerifySecret(emailSecret: emailSecret!, language: ApplicationSetting.InterfaceLanguage!)
                
            } else if uvcUIButton!.name == "DidNotGetSecret" {
                
               showForgotPasswordVerifyIdentityView()
            } else if uvcUIButton!.name == "Recover" {
                
                let newPassword = uvcViewController.uvcUIViewControllerItemCollection.getTextField(tag: 0, name: "NewPassword")?.uiTextField.text
                let confirmPassword = uvcViewController.uvcUIViewControllerItemCollection.getTextField(tag: 0, name: "ConfirmPassword")?.uiTextField.text
                if newPassword != confirmPassword {
                    let errorButton = getErrorButton(operationName: "SecurityNeuronOperationType.ForgotPasswordChangePassword")
                    errorButton.uiButton.isHidden = false
                    errorButton.uiButton.setTitle("\(errorMessage.count) Error(s)", for: .normal)
                    errorMessage.removeAll()
                    errorMessage.append(UVCPopoverNode.getNode(name: "Password does not match. Check"))
                    showErrorMessageIfAny(errorMessage: errorMessage, sender: errorButton.uiButton)
                    return
                }
                showActivityIndicator()
                let callBrainControllerNeuron = CallBrainControllerNeuron()
                callBrainControllerNeuron.forgotPasswordChangePassword(newPassword: newPassword!, language: ApplicationSetting.InterfaceLanguage!)
            }
        }
    }
    
    private func showForgotPasswordVerifyIdentityView() {
        let subViews = securityView.subviews
        for subview in subViews {
            subview.removeFromSuperview()
        }
        showView(viewModel: forgotPasswordVerifyIdentityViewModel,operationName: "SecurityNeuronOperationType.ForgotPasswordVerifyIdentity")
        currentOperation = "SecurityNeuronOperationType.ForgotPasswordVerifyIdentity"
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if stackView != nil  {
            securityView.contentSize = stackView!.sizeThatFits(CGSize(width: stackView!.frame.width, height: 3000))
        }
        
    }
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        for uvcUITextField in uvcViewController.uvcUIViewControllerItemCollection.uvcUITextField {
            if uvcUITextField.uiTextField.isFirstResponder {
                uvcUITextField.uiTextField.resignFirstResponder()
                break
            }
        }

        return true;
    }
    
    @objc func keyboardWillShow(notification:NSNotification){
    
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.securityView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        securityView.contentInset = contentInset
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        securityView.contentInset = contentInset
    }
//    func textFieldShouldReturn(_ textField: UITextField!) -> Bool // called when 'return' key pressed. return NO to ignore.
//    {
//        textField.resignFirstResponder()
//        return true;
//    }
    
    
    
    private func showErrorMessageIfAny(errorMessage: [UVCPopoverNode], sender: Any?) {
        if errorMessage.count > 0 {
            var count = errorMessage.count
            for em in errorMessage {
                if em.name.count / 30 > 1 {
                    count += 1
                }
            }
            let height = 62 * (count + 1)
            showPopover(category: "ErrorMessage", popoverNode: errorMessage, width: 300, height: height, sender: sender!, delegate: self, isLeftOptionEnabled: true, isRightOptionEnabled: false)
        }
    }
    
    func showPopover(category: String, popoverNode: [UVCPopoverNode]?, width: Int, height: Int, sender: Any, delegate: UIPopoverPresentationControllerDelegate,
                     isLeftOptionEnabled: Bool, isRightOptionEnabled: Bool) {
        currentOptionCategory = category
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navigationController = storyboard.instantiateViewController(
            withIdentifier: "PopoverNavigationController") as! UINavigationController
        // Use the popover presentation style for your view controller.
        navigationController.modalPresentationStyle = .popover
        let popoverViewController = navigationController.viewControllers[0] as! PopoverViewController
        popoverViewController.delegate = (delegate  as! PopoverViewControllerDelegate)
        popoverViewController.isLeftOptionEnabled = isLeftOptionEnabled
        popoverViewController.isRightOptionEnabled = isRightOptionEnabled
        // Specify the anchor point for the popover.
        navigationController.popoverPresentationController!.delegate = delegate
        
        if sender is UIBarButtonItem {
            if delegate is DetailViewController {
                navigationController.popoverPresentationController!.barButtonItem = navigationItem.rightBarButtonItem
            } else {
                navigationController.popoverPresentationController!.barButtonItem  = (sender as! UIBarButtonItem)
            }
        } else {
            let uiButton = (sender as! UIButton)
            navigationController.popoverPresentationController!.sourceRect = uiButton.bounds
            navigationController.popoverPresentationController?.sourceView = uiButton
        }
        
        
        let uvcPopoverView = UVCPopoverView()
        uvcPopoverView.width = width
        uvcPopoverView.height = height
        for tn in popoverNode! {
            uvcPopoverView.uvcPopoverNode.append(tn)
        }
        popoverViewController.model = uvcPopoverView
        // Present the view controller (in a popover).
        self.present(navigationController, animated: true)
    }
    
    public func popoverItemSelected(index: Int, switchOn: Bool) {
        
    }
    
    public func uvcViewControllerEvent(uvcViewItemType: String, eventName: String, uvcObject: Any, uiObject: Any) {
        // Keyboard not showing so focus when clicked
        if uiObject is UITextField {
            focusTextField(uiTextField: uiObject as! UITextField)
        }
    }
    
    
    func focusTextField(uiTextField: UITextField) {
        uiTextField.perform(#selector(uiTextField.becomeFirstResponder), with: nil, afterDelay: 0.1)
    }
    

}


