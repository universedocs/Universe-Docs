//
//  OptionViewController.swift
//  Universe Docs
//
//  Created by Kumar Muthaiah on 24/01/19.
//  Copyright © 2019 Universe Docs. All rights reserved.
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
import UDocsBrain
import UDocsViewModel
import UDocsNeuronModel
import UDocsPhotoNeuronModel
import UDocsOptionMapNeuronModel
import UDocsDocumentItemNeuronModel
import UDocsDocumentMapNeuronModel

public protocol OptionViewControllerDelegate
{
    func optionViewControllerOptionSelected(index: Int, parentIndex: Int, level: Int, senderModel: Any, sender: Any)
    func optionViewControllerSelected(index: Int, parentIndex: Int, level: Int, senderModel: [Any], sender: Any)
    func optionViewControllerSelected(index: Int, parentIndex: Int, level: Int, senderModel: [Any])
    func optionViewControllerEditOk(index: Int, parentIndex: Int, level: Int, senderModel: Any, sender: Any)
    func optionViewControllerTextFieldDidChange(index: Int, parentIndex: Int, level: Int, senderModel: Any, sender: Any)
    func optionViewControllerButtonBarItemSelected(path: [String], buttonIndex: Int, senderModel: [Any], sender: Any)
    func optionViewControllerCancelSelected()
    func optionViewControllerEnteredOption(senderModel: [Any])
    func optionViewControllerConnfigureOption(index: Int, parentIndex: Int, level: Int, senderModel: [Any], uvcUIViewControllerItemCollection: UVCUIViewControllerItemCollection)
    func optionViewControllerSearch(idName: String, searchText: String)
    func optionViewControllerEvent(uvcViewItemType: String, eventName: String, uvcObject: Any, uiObject: Any, optionViewCell: OptionViewCell, uvcOptionViewModel: UVCOptionViewModel, parentIndex: Int, callerObject: Any?, operationName: String)
    func optionViewControllerLoadingCompleted()
    func optionViewControllerServerResponsded(response: Any) -> UVCOptionViewRequest
    func optionViewControllerDismissed()
}


extension UVCOptionViewModel {
    
    public func getTextWidth(index: Int) -> CGFloat {
        var width = CGFloat(0)
        let font = UIFont(name: "Helvetica", size: CGFloat( UVCTextSizeType.Regular.size))
        let fontAttributes = [NSAttributedString.Key.font: font]
        var nonEditableText = false
        var isBold = false
        for uvcText in uvcViewModel.uvcViewItemCollection.uvcText {
            if uvcText.uvcTextStyle.intensity > 50 {
                isBold = true
            }
            if uvcText.isEditable && uvcText.uvcViewItemType == "UVCViewItemType.Choice" {
                width += (uvcText.value as! NSString).size(withAttributes: fontAttributes).width + 5
            } else if uvcText.isEditable {
                width += (uvcText.helpText as! NSString).size(withAttributes: fontAttributes).width + 5
            } else {
                nonEditableText = true
                if uvcText.value.count == 1 {
                    width += (uvcText.value as NSString).size(withAttributes: fontAttributes).width + 5
                } else {
                    width += (uvcText.value as NSString).size(withAttributes: fontAttributes).width + 5
                }
            }
        }
        for uvcPhoto in uvcViewModel.uvcViewItemCollection.uvcPhoto {
            for uvcMeasurement in uvcPhoto.uvcMeasurement {
                if uvcMeasurement.type == UVCMeasurementType.Width.name {
                    width = width + CGFloat(uvcMeasurement.value)
                    break
                }
            }
        }
        for uvcButton in uvcViewModel.uvcViewItemCollection.uvcButton {
            if uvcButton.uvcPhoto != nil {
                for uvcPhoto in uvcViewModel.uvcViewItemCollection.uvcPhoto {
                    if uvcPhoto.name == "Elipsis" || uvcPhoto.name == "LeftDirectionArrow" || uvcPhoto.name == "UpDirectionArrow" || uvcPhoto.name == "DownDirectionArrow" || uvcPhoto.name == "RightDirectionArrow" {
                        width += 5
                    }
                }
            } else {
                width += (uvcButton.value as NSString).size(withAttributes: fontAttributes).width + 25
            }
        }
        
        if nonEditableText && !isBold {
            return width
        } else {
            return width + 10
        }
    }
    
    
    public func getTextHeight(index: Int) -> CGFloat {
        var height = CGFloat(0)
        let font = UIFont(name: "Helvetica", size: CGFloat( UVCTextSizeType.Regular.size))
        let fontAttributes = [NSAttributedString.Key.font: font]
        var rowLength = CGFloat(0)
        var first = true
        var singleHeight = CGFloat(0)
        for uvcText in uvcViewModel.uvcViewItemCollection.uvcText {
            if uvcViewModel.uvcViewItemCollection.uvcOnOff.count > 0 {
                height += (uvcText.value as NSString).size(withAttributes: fontAttributes).height + 20
            } else {
                height += (uvcText.value as NSString).size(withAttributes: fontAttributes).height + 15
            }
            if first {
                first = false
                singleHeight = height
            }
            rowLength = CGFloat(uvcViewModel.rowLength!)
        }
        if height == 0 {
            for uvcButton in uvcViewModel.uvcViewItemCollection.uvcButton {
                height += (uvcButton.value as NSString).size(withAttributes: fontAttributes).height
            }
        }
        for uvcPhoto in uvcViewModel.uvcViewItemCollection.uvcPhoto {
            for uvcMeasurement in uvcPhoto.uvcMeasurement {
                if uvcMeasurement.type == UVCMeasurementType.Height.name {
                    height = height + CGFloat(uvcMeasurement.value)
                    break
                }
            }
        }
        if uvcViewModel.uvcViewItemCollection.uvcOnOff.count > 0 {
            height = height + (singleHeight * 1)
        }
        return height
    }
}

private let reuseIdentifier = "OptionViewCell"
private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)

class OptionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UVCOptionViewCellDelegate, UIPopoverPresentationControllerDelegate, UICollectionViewDelegateFlowLayout, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating {
    public var delegate: OptionViewControllerDelegate?
    private var treeLevel: Int = 0
    public var goToPath: String = ""
    private var viewTitle: String = ""
    @IBOutlet weak var rightButton1: UIBarButtonItem!
    @IBOutlet weak var rightButton2: UIBarButtonItem!
    private var currentTitle: String = ""
    @IBOutlet weak var rightButton3: UIBarButtonItem!
    private var backButtonDisabled: Bool = false
    private var searchActive: Bool = false
    private var parentPath = [String]()
    private var parentIndex: Int = 0
    public var photoIdArray = [String]()
    private var activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
    private var callerObject: Any?
    private var currentOperationData = [String: [String: Any]]()
    private var currentOperationName: String = ""
    private var searchText: String = ""
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(handleRefresh(_:)),
                                 for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.red
        
        return refreshControl
    }()
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        refreshControl.endRefreshing()
    }
    
    private let searchController = UISearchController(searchResultsController: nil)
    var headerView : SearchBarCollectionReusableView?
    @IBOutlet weak var collectionView: UICollectionView!
    @IBAction func cancelButtonPressed(_ sender: Any) {
        if activityIndicator.isAnimating {
            return
        }
        delegate!.optionViewControllerDismissed()
        dismissOptionList()
        resetValues()
    }
    
    public func resetValues() {
        model!.uvcOptionViewModel.removeAll()
        model!.uvcOptionViewModelList.removeAll()
        model!.optionLabel.removeAll()
        model!.rightButton.removeAll()
        photoIdArray.removeAll()
        model = nil
        request = nil
        delegate = nil
        parentPath.removeAll()
        parentIndex = 0
        rightButton1.title = ""
        rightButton2.title = ""
        rightButton3.title = ""
        rightButton1.isEnabled = false
        rightButton2.isEnabled = false
        rightButton3.isEnabled = false
    }
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(brainControllerNeuronResponse(_:)), name: .optionViewControllerNotification, object: nil)
        
        self.collectionView!.register(OptionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        if let flowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.itemSize = CGSize(width: self.collectionView.bounds.width, height: 30)
            flowLayout.scrollDirection = .vertical
        }
        #if targetEnvironment(macCatalyst)
        rightButton1.tintColor = UIColor.white
        rightButton2.tintColor = UIColor.white
        rightButton3.tintColor = UIColor.white
        cancelButton.tintColor = UIColor.white
        #endif

        rightButton1.title = ""
        rightButton2.title = ""
        rightButton3.title = ""
        rightButton1.isEnabled = false
        rightButton2.isEnabled = false
        rightButton3.isEnabled = false
        handleRightButton(rightButton: model!.rightButton)
        self.collectionView?.addSubview(self.refreshControl)
        collectionView.backgroundColor = UIColor { traitCollection in
                            // 2
                            switch traitCollection.userInterfaceStyle {
                            case .dark:
                              // 3
                                return UIColor(white: 0.1, alpha: 1.0)
                            default:
                              // 4
                                return UIColor.white
                            }
                        }
        loadOptions()
        
    }
    
    private func loadOptions() {
        if model!.opeartionName == "DocumentItemNeuron.Search.DocumentItem" {
            setCurrentOperation(name: model!.opeartionName)
            setCurrentOperationData(data: [getCurrentOperation(): [
                "documentGraphItemSearchRequest": model!.documentGraphItemSearchRequest,
                "neuronName": "DocumentItemNeuron"]])
            sendRequest(source: self)
        } else if model!.opeartionName == "DocumentGraphNeuron.DocumentItem.Get" {
            callerObject = model!.documentGraphItemViewData
            setCurrentOperation(name: model!.opeartionName)
            setCurrentOperationData(data: [getCurrentOperation(): [
                "typeRequest": model!.typeRequest]])
            sendRequest(source: self)
        }
    }
    
    private func setCurrentOperation(name: String) {
        currentOperationName = name
    }
    
    private func getCurrentOperation() -> String {
        return currentOperationName
    }
    
    private func setCurrentOperationData(data: [String: [String: Any]]) {
        currentOperationData.removeAll()
        currentOperationData = data
    }
    
    public func sendRequest(source: Any) {
        if activityIndicator.isAnimating {
            return
        }
        showActivityIndicator(currentOperationName: "\(currentOperationName)...")
        
        let data = currentOperationData[currentOperationName]
        let callBrainControllerNeuron = CallBrainControllerNeuron()
        CallBrainControllerNeuron.sourceName = "OptionViewController"
        
        if currentOperationName == "PhotoNeuron.Get.Item.Photo" {
            callBrainControllerNeuron.getItemPhoto(sourceName: String(describing: OptionViewController.self), language: data?["language"] as! String, documentGraphGetPhotoRequest: data?["documentGraphGetPhotoRequest"] as! DocumentGetPhotoRequest)
        } else if currentOperationName == "DocumentItemNeuron.Search.DocumentItem" {
            callBrainControllerNeuron.searchDocumentItem(sourceName: String(describing: OptionViewController.self), language: ApplicationSetting.DocumentLanguage!, documentGraphItemSearchRequest: data?["documentGraphItemSearchRequest"] as! DocumentGraphItemSearchRequest, neuronName: data?["neuronName"] as! String)
        }  else if currentOperationName == "DocumentGraphNeuron.DocumentItem.Get" {
            let typeRequest = data?["typeRequest"] as! GetDocumentItemOptionRequest
            callBrainControllerNeuron.getType(sourceName: String(describing: OptionViewController.self), typeRequest: typeRequest)
        } else if currentOperationName == "DocumentGraphNeuron.DocumentItem.Search" {
            let typeRequest = data?["typeRequest"] as! GetDocumentItemOptionRequest
            callBrainControllerNeuron.getType(sourceName: String(describing: OptionViewController.self), typeRequest: typeRequest)
        } else if currentOperationName == "DocumentMapNeuron.Search.Document" {
            callBrainControllerNeuron.searchDocument(sourceName: String(describing: OptionViewController.self), language: ApplicationSetting.DocumentLanguage!, documentMapSearchDocumentRequest: data?["documentMapSearchDocumentRequest"] as! DocumentMapSearchDocumentRequest, neuronName: data?["neuronName"] as! String)
        }
        
        
    }
    
    @objc func brainControllerNeuronResponse(_ notification:Notification) {
        if notification.name != Notification.Name(rawValue: "OptionViewControllerNotification") {
            return
        }
        let neuronRequest: NeuronRequest = notification.object as! NeuronRequest
        print("Response for: \(neuronRequest.neuronOperation.name)")
        if neuronRequest.neuronOperation.name == "DocumentItemNeuron.Get.DocumentItem.Options" ||
            neuronRequest.neuronOperation.name == "DocumentItemNeuron.Search.DocumentItem" ||
            neuronRequest.neuronOperation.name == "DocumentGraphNeuron.DocumentItem.Search" ||
            neuronRequest.neuronOperation.name == "DocumentGraphNeuron.DocumentItem.Get" ||
            neuronRequest.neuronOperation.name == "DocumentMapNeuron.Search.Document" ||
            neuronRequest.neuronOperation.name == "PhotoNeuron.Get.Item.Photo" && photoIdArray.count > 0
        {
            if neuronRequest.neuronOperation.neuronOperationStatus.neuronOperationError!.count > 0 {
                hideActivityIndicator(activityDescription: "Error")
                showAlertView(message: neuronRequest.neuronOperation.neuronOperationStatus.neuronOperationError![0].description)
                return
            }
            if neuronRequest.neuronOperation.neuronOperationStatus.neuronOperationSuccess!.count > 0 {
                handleServerResponse(neuronRequest: neuronRequest)
            }
        }
        
    }
    
    public func showAlertView(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
                
                
            }}))
        present(alert, animated: true, completion: nil)
    }
    
    private func getOperationDescription(currentOperationName: String) -> String {
        if currentOperationName.hasPrefix("DocumentItemNeuron.Search.DocumentItem") {
                return "Searching..."
        } else if currentOperationName.hasPrefix("DocumentGraphNeuron.DocumentItem.Get") {
                return "Getting..."
            }
            
            return currentOperationName
        }
    
    public func showActivityIndicator(currentOperationName: String) {
        self.activityIndicator.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(100), height: CGFloat(100))
        self.activityIndicator.color = .green
        self.navigationItem.title = getOperationDescription(currentOperationName: currentOperationName)
//        self.navigationItem.titleView = self.activityIndicator
        self.activityIndicator.startAnimating()
        print("Activity in progress: \(currentOperationName)")
    }
    
    public func hideActivityIndicator(activityDescription: String) {
        self.activityIndicator.stopAnimating()
        self.navigationItem.title = currentTitle
        print("Activity stoped: \(activityDescription)")
    }
    
    private func handleServerResponse(neuronRequest: NeuronRequest) {
        
        hideActivityIndicator(activityDescription: "Ooption Controller Server Request: Stoping: \(neuronRequest.neuronOperation.name)" )
        var uvcOptionViewRequest: UVCOptionViewRequest?
        if neuronRequest.neuronOperation.name != "PhotoNeuron.Get.Item.Photo" {
            if delegate == nil {
                return
            }
            uvcOptionViewRequest = delegate!.optionViewControllerServerResponsded(response: neuronRequest)
        }
        if neuronRequest.neuronOperation.name == "PhotoNeuron.Get.Item.Photo" {
            for uvcovm in model!.uvcOptionViewModelList {
                for uvcPhoto in uvcovm.uvcViewModel.uvcViewItemCollection.uvcPhoto {
                    if uvcPhoto.optionObjectIdName == photoIdArray[0] {
                        uvcPhoto.binaryData = neuronRequest.neuronOperation.neuronData.binaryData
                    }
                }
                
            }
            self.collectionView.reloadData()
            photoIdArray.remove(at: 0)
            if photoIdArray.count > 0 {
                let documentGraphGetPhotoRequest = DocumentGetPhotoRequest()
                documentGraphGetPhotoRequest.udcDocumentItemId = photoIdArray[0]
                documentGraphGetPhotoRequest.udcPhotoDataId = photoIdArray[0]
                documentGraphGetPhotoRequest.isOption = true
                setCurrentOperation(name: "PhotoNeuron.Get.Item.Photo")
                setCurrentOperationData(data: [getCurrentOperation(): [
                    "language": ApplicationSetting.DocumentLanguage!,
                    "documentGraphGetPhotoRequest": documentGraphGetPhotoRequest]])
                sendRequest(source: self)
            }
        } else {
            if uvcOptionViewRequest!.operationName == "OptionViewController.Dismiss" {
                if delegate == nil {
                    return
                }
                delegate!.optionViewControllerDismissed()
                resetValues()
                dismissOptionList()
            } else if uvcOptionViewRequest!.operationName == "OptionViewController.Load.Options" {
                if uvcOptionViewRequest!.uvcOptionViewModel!.count == 0 {
                    dismissOptionList()
                    return
                }
                 
                model!.uvcOptionViewModelList.removeAll()
                if uvcOptionViewRequest!.uvcOptionViewModel!.count > 0 {
                model!.uvcOptionViewModelList.append(contentsOf: uvcOptionViewRequest!.uvcOptionViewModel!)
                }
                viewTitle = uvcOptionViewRequest!.title
                handleBackButton()
                self.collectionView.reloadData()
                for uvcovm in model!.uvcOptionViewModelList {
                    for uvcPhoto in uvcovm.uvcViewModel.uvcViewItemCollection.uvcPhoto {
                        if !uvcPhoto.optionObjectIdName.isEmpty || uvcPhoto.isChanged! {
                            photoIdArray.append(uvcPhoto.optionObjectIdName)
                        }
                    }
                    
                }
                if photoIdArray.count > 0 {
                    let documentGraphGetPhotoRequest = DocumentGetPhotoRequest()
                    documentGraphGetPhotoRequest.udcDocumentItemId = photoIdArray[0]
                    documentGraphGetPhotoRequest.udcPhotoDataId = photoIdArray[0]
                    documentGraphGetPhotoRequest.isOption = true
                    setCurrentOperation(name: "PhotoNeuron.Get.Item.Photo")
                    setCurrentOperationData(data: [getCurrentOperation(): [
                        "language": ApplicationSetting.DocumentLanguage!,
                        "documentGraphGetPhotoRequest": documentGraphGetPhotoRequest]])
                    sendRequest(source: self)
                }
            }
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        if activityIndicator.isAnimating {
            return
        }
        if model!.uvcOptionViewModelList.count == 0 {
            return
        }
        
        treeLevel -= 1
        let uvctn = model!.uvcOptionViewModelList[0]
        model!.uvcOptionViewModelList.removeAll()
        parentIndex = 0
        var found = false
        for (pIndex, p) in uvctn.pathIdName.enumerated() {
            if p.joined(separator: "->").hasPrefix(parentPath.joined(separator: "->")) {
                parentIndex = pIndex
                found = true
                break
            }
            if found {
                break
            }
        }
        var tempPath = uvctn.pathIdName[parentIndex]
        tempPath.remove(at: tempPath.count - 1)
        let path = tempPath.joined(separator: "->")
        print(path)
        print(parentPath)
        print(parentIndex)
        treeLevel = 1
        var parent = UVCOptionViewModel()
        // Get the parent's list and show it as current
        model!.uvcOptionViewModelList = getTreeParentForPath(uvcOptionViewModelArray: model!.uvcOptionViewModel, path: path, parent: &parent)!
        
        // Choose the proper title
        //            navigationItem.title = parentName
        if tempPath.count > 1 {
            navigationItem.title = tempPath[tempPath.count - 2]
        } else {
            navigationItem.title = tempPath[0]
        }
        if parentPath.count > 1 {
            parentPath.remove(at: parentPath.count - 1)
        }
        handleBackButton()
        self.collectionView?.reloadData()
        delegate!.optionViewControllerEnteredOption(senderModel: model!.uvcOptionViewModelList as [Any])
    }
    
    @IBAction func rightButton2Pressed(_ sender: Any) {
        if activityIndicator.isAnimating {
            return
        }
//        if model!.uvcOptionViewModelList.count == 0 {
//            return
//        }
        var uvcOptionViewModeList = [UVCOptionViewModel]()
        var tempPath = [String]()
        if model!.uvcOptionViewModelList.count > 0 {
            tempPath = model!.uvcOptionViewModelList[0].pathIdName[0]
            tempPath.remove(at: tempPath.count - 1)
            for uvcovm in model!.uvcOptionViewModelList {
                if uvcovm.isSelected {
                    uvcOptionViewModeList.append(uvcovm)
                }
            }
        }
        delegate!.optionViewControllerButtonBarItemSelected(path: tempPath, buttonIndex: 2, senderModel: uvcOptionViewModeList, sender: sender)
        resetValues()
        dismissOptionList()
    }
    
    @IBAction func rightButton1Pressed(_ sender: Any) {
        if activityIndicator.isAnimating {
            return
        }
        var uvcOptionViewModeList = [UVCOptionViewModel]()
        var tempPath = [String]()
        if model!.uvcOptionViewModelList.count > 0 {
            tempPath = model!.uvcOptionViewModelList[0].pathIdName[0]
            tempPath.remove(at: tempPath.count - 1)
            for uvcovm in model!.uvcOptionViewModelList {
                if uvcovm.isSelected {
                    uvcOptionViewModeList.append(uvcovm)
                }
            }
        }
        delegate!.optionViewControllerButtonBarItemSelected(path: tempPath, buttonIndex: 1, senderModel: uvcOptionViewModeList, sender: sender)
        resetValues()
        dismissOptionList()
    }
    
    
    @IBAction func rightButton3Pressed(_ sender: Any) {
        if activityIndicator.isAnimating {
            return
        }
        var uvcOptionViewModeList = [UVCOptionViewModel]()
        var tempPath = [String]()
        if model!.uvcOptionViewModelList.count > 0 {
            tempPath = model!.uvcOptionViewModelList[0].pathIdName[0]
            tempPath.remove(at: tempPath.count - 1)
            for uvcovm in model!.uvcOptionViewModelList {
                if uvcovm.isSelected {
                    uvcOptionViewModeList.append(uvcovm)
                }
            }
        }
        delegate!.optionViewControllerButtonBarItemSelected(path: tempPath, buttonIndex: 3, senderModel: uvcOptionViewModeList, sender: sender)
        resetValues()
        dismissOptionList()
    }
    var model: UVCOptionView? {
        didSet {
            if model == nil {
                return
            }
            let screenRect: CGRect = UIScreen.main.bounds
            var width = model!.width
            var height = model!.height
            if model!.width == 0 {
                width = Int(screenRect.width)
            }
            if model!.height == 0 {
                height = Int(screenRect.height)
            }
            navigationItem.title = model!.title
            parentPath.append(model!.title)
            viewTitle = model!.title
            if model!.optionLabel.count > 0 {
                backButton.title = model!.optionLabel["UDCOptionMapNode.Back"]!
                cancelButton.title = model!.optionLabel["UDCOptionMapNode.Cancel"]!
            }
            treeLevel = 1
            handleRightButton(rightButton: model!.rightButton)
            handleBackButton()
            self.preferredContentSize = CGSize(width: width, height: height)
            if collectionView == nil {
                return
            }
            photoIdArray.removeAll()
            for uvcom in model!.uvcOptionViewModelList {
                for uvcPhoto in uvcom.uvcViewModel.uvcViewItemCollection.uvcPhoto {
                    photoIdArray.append(uvcPhoto.optionObjectIdName)
                }
            }
            collectionView.reloadData()
            if !goToPath.isEmpty {
                goToOption(path: goToPath, uvcOptionViewModelArray: model!.uvcOptionViewModelList)
            }
        }
    }
    
    deinit {
        print("OptionViewController.deniit")
    }
    var request: UVCOptionViewRequest? {
        didSet {
            if request == nil {
                return
            }
            if request!.operationName == "OptionViewController.Put.Photo" {
                if model == nil {
                    return
                }
                if photoIdArray.count > 0 {
                    var found: Bool = false
                    for uvcom in model!.uvcOptionViewModelList {
                        for uvcPhoto in uvcom.uvcViewModel.uvcViewItemCollection.uvcPhoto {
                            if uvcPhoto.optionObjectIdName == photoIdArray[0] {
                                uvcPhoto.binaryData = request!.binaryData!
                                found = true
                                break
                            }
                        }
                        if found { break }
                    }
                    photoIdArray.remove(at: 0)
                    collectionView.reloadData()
                }
            } else if request!.operationName == "OptionViewController.Children.Add" {
                
                model!.uvcOptionViewModelList = addChildrenToNode(path: (request?.pathIdName.joined(separator: "->"))!, uvcOptionViewModelArray: &model!.uvcOptionViewModel, children: (request?.uvcOptionViewModel)!, isAppended: (request?.isAppended)!)!
                
                if collectionView != nil {
                    goToOption(path: request!.pathIdName.joined(separator: "->"), uvcOptionViewModelArray: model!.uvcOptionViewModel)
                    collectionView.reloadData()
                }
                
            } else if request!.operationName == "OptionViewController.Children.DeleteAll" {
                model!.uvcOptionViewModelList = removeChildrenAt(path: (request?.path.joined(separator: "->"))!, uvcOptionViewModelArray: &model!.uvcOptionViewModel, itemsToDelete: nil, selectedOnly: false)!
            } else if request!.operationName == "OptionViewController.Children.DeleteItems" {
                model!.uvcOptionViewModelList = removeChildrenAt(path: (request?.path.joined(separator: "->"))!, uvcOptionViewModelArray: &model!.uvcOptionViewModel, itemsToDelete: request!.uvcOptionViewModel, selectedOnly: true)!
            } else if request!.operationName == "OptionViewController.Children.DeleteSelectedItems" {
                model!.uvcOptionViewModelList = removeSelectedChildrenAt(path: (request?.path.joined(separator: "->"))!, uvcOptionViewModelArray: &model!.uvcOptionViewModel)!
            } else if request!.operationName == "OptionViewController.Option.ShowAtPath" {
                treeLevel = 1
                goToOption(path: request!.pathIdName.joined(separator: "->"), uvcOptionViewModelArray: model!.uvcOptionViewModel)
                self.collectionView?.reloadData()
            } else if request!.operationName == "OptionViewController.Option.GoToRoot" {
                treeLevel = 1
                model!.uvcOptionViewModelList = model!.uvcOptionViewModel
                if collectionView != nil {
                    collectionView.reloadData()
                }
                
            } else if request!.operationName == "OptionViewController.Error" {
                if request!.errorMessage.isEmpty {
                    resetTitle()
                } else {
                    currentTitle = navigationItem.title!
                    navigationItem.title = request!.errorMessage
                }
            } else if request!.operationName == "OptionViewController.DisableBackButon" {
                backButton.title = ""
                backButton.isEnabled = false
                backButtonDisabled = true
            } else if request!.operationName == "OptionViewController.EnabledBackButon" {
                backButtonDisabled = false
                handleBackButton()
            } else if request!.operationName == "OptionViewController.SearchResult" {
                model!.uvcOptionViewModelBackupList.removeAll()
                model!.uvcOptionViewModelBackupList.append(contentsOf: model!.uvcOptionViewModelList)
                model!.uvcOptionViewModelList = request!.uvcOptionViewModel!
                if collectionView != nil {
                    collectionView.reloadData()
                }
            } else if request!.operationName == "OptionViewController.Search.Reset" {
                if (model!.uvcOptionViewModelList.count > 0) && model!.uvcOptionViewModelList[0].getText(name: "Name")!.value == "None" {
                    model!.uvcOptionViewModelList = model!.uvcOptionViewModelBackupList
                    if collectionView != nil {
                        collectionView.reloadData()
                    }
                }
            } else if request!.operationName == "OptionViewController.Title" {
                navigationItem.title = request!.title
                viewTitle = request!.title
            } else if request!.operationName == "OptionViewController.CallMeWithSelected" {
                var uvcovmList = [UVCOptionViewModel]()
                if model!.uvcOptionViewModelList.count == 0 {
                    delegate?.optionViewControllerSelected(index: 0, parentIndex: parentIndex, level: treeLevel, senderModel: uvcovmList as [Any])
                    return
                }
                for uvcovm in model!.uvcOptionViewModelList {
                    if uvcovm.isSelected {
                        uvcovmList.append(uvcovm)
                    }
                }
                if uvcovmList.count == 0 {
                    uvcovmList.append(model!.uvcOptionViewModelList[0])
                }
                delegate?.optionViewControllerSelected(index: 0,  parentIndex: parentIndex, level: treeLevel, senderModel: uvcovmList as [Any])
                self.dismiss(animated: true, completion: nil)
            }
            
            if request?.rightButton.count == 3 {
                handleRightButton(rightButton: (request?.rightButton)!)
            }
        }
    }
    
    private func resetTitle() {
        navigationItem.title = currentTitle
    }
    
    func uvcOptionViewCellConnfigureOption(index: Int, level: Int, senderModel: [Any], uvcUIViewControllerItemCollection: UVCUIViewControllerItemCollection) {
        delegate?.optionViewControllerConnfigureOption(index: index, parentIndex: parentIndex, level: level, senderModel: senderModel, uvcUIViewControllerItemCollection: uvcUIViewControllerItemCollection)
    }
    
    
    func uvcOptionViewCellOptionSelected(index: Int, level: Int, senderModel: Any, sender: Any) {
        if model!.uvcOptionViewModelList.count == 0 {
            return
        }
        
        delegate?.optionViewControllerOptionSelected(index: index, parentIndex: parentIndex, level: treeLevel, senderModel: model!.uvcOptionViewModelList[index], sender: sender)
    }
    
    func optionViewCellEvent(uvcViewItemType: String, eventName: String, uvcObject: Any, uiObject: Any, optionViewCell: OptionViewCell) {
        if model!.uvcOptionViewModelList.count == 0 {
            return
        }
        
        let uvcovm = model!.uvcOptionViewModelList[optionViewCell.index]
        
        if uvcovm.isDocument {
            delegate!.optionViewControllerEvent(uvcViewItemType: uvcViewItemType, eventName: eventName, uvcObject: uvcObject, uiObject: uiObject, optionViewCell: optionViewCell, uvcOptionViewModel: optionViewCell.uvcOptionViewModel!, parentIndex: parentIndex, callerObject: callerObject, operationName: model!.opeartionName)
            return
        }
        
        let name = uvcovm.getText(name: "Name")!.value
        let uvcovmSender = optionViewCell.uvcOptionViewModel!
        
        // Show child node
        if uvcovm.children.count > 0 {
            parentPath.append(uvcovm.getText(name: "Name")!.value)
            treeLevel += 1
            print("Has Child")
            uvcovmSender.isSelected = true
            if uvcovmSender.isSingleSelect {
                for (indexItem, uvcpvmli) in model!.uvcOptionViewModelList.enumerated() {
                    if indexItem != optionViewCell.index && uvcpvmli.isSelected {
                        uvcpvmli.isSelected = false
                        uvcpvmli.changeCheckBox(name: "CheckBoxButton", enabled: false)
                    }
                }
            }
            
            model!.uvcOptionViewModelList.removeAll()
            model!.uvcOptionViewModelList = getTreeChildForId(uvcOptionViewModelArray: model!.uvcOptionViewModel, childId: uvcovm._id)!
            for uvcovm in model!.uvcOptionViewModelList {
                if uvcovm.isMultiSelect || uvcovm.isSingleSelect {
                    if !uvcovm.isSelected {
                        uvcovm.isSelected = false
                        uvcovm.changeCheckBox(name: "CheckBoxButton", enabled: false)
                    } else {
                        uvcovm.isSelected = true
                        uvcovm.changeCheckBox(name: "CheckBoxButton", enabled: true)
                    }
                } 
            }
            navigationItem.title = name
            handleBackButton()
            self.collectionView?.reloadData()
            photoIdArray.removeAll()
            for uvcom in model!.uvcOptionViewModelList {
                for uvcPhoto in uvcom.uvcViewModel.uvcViewItemCollection.uvcPhoto {
                    photoIdArray.append(uvcPhoto.optionObjectIdName)
                }
            }
            //            delegate!.optionViewControllerLoadingCompleted()
            delegate!.optionViewControllerEnteredOption(senderModel: model!.uvcOptionViewModelList as [Any])
        } else { // Just a selection
//            if uvcovm.isChidlrenOnDemandLoading {
//                let documentMapSearchDocumentRequest = DocumentMapSearchDocumentRequest()
//                documentMapSearchDocumentRequest.treeLevel = treeLevel
//                documentMapSearchDocumentRequest.udcDocumentId = uvcovm._id
//                setCurrentOperation(name: "DocumentMapNeuron.Search.Document")
//                setCurrentOperationData(data: [getCurrentOperation(): [
//                    "documentMapSearchDocumentRequest" : documentMapSearchDocumentRequest,
//                    "neuronName": "DocumentMapNeuron"]])
//                sendRequest(source: self)
//            } else {
                if uvcovmSender.isMultiSelect || uvcovmSender.isSingleSelect {
                    if !uvcovmSender.isSelected {
                        uvcovmSender.isSelected = true
                        uvcovmSender.changeCheckBox(name: "CheckBoxButton", enabled: true)
                    }
                    model!.uvcOptionViewModelList[optionViewCell.index] = uvcovmSender
                    // If single select then clear all other selections
                    if uvcovmSender.isSingleSelect {
                        for (indexItem, uvcpvmli) in model!.uvcOptionViewModelList.enumerated() {
                            if indexItem != optionViewCell.index && uvcpvmli.isSelected {
                                uvcpvmli.isSelected = false
                                uvcpvmli.changeCheckBox(name: "CheckBoxButton", enabled: false)
                            }
                        }
                    }
                    self.collectionView?.reloadData()
                }
                print("Selected: \(name)")
                delegate!.optionViewControllerEvent(uvcViewItemType: uvcViewItemType, eventName: eventName, uvcObject: uvcObject, uiObject: uiObject, optionViewCell: optionViewCell, uvcOptionViewModel: uvcovm, parentIndex: parentIndex, callerObject: callerObject, operationName: model!.opeartionName)
                
                if uvcovmSender.isDismissedOnSelection && !activityIndicator.isAnimating {
                    delegate!.optionViewControllerDismissed()
                    resetValues()
                    dismissOptionList()
                }
//            }
        }
    }
    
    func uvcOptionViewCellSelected(index: Int, level: Int, senderModel: [Any], optionViewCell: OptionViewCell) {
        optionViewCellEvent(uvcViewItemType: "UVCViewItemType.Table", eventName: "UVCViewItemEvent.Table.Taped", uvcObject: self, uiObject: self, optionViewCell: optionViewCell)
    }
    
    private func dismissOptionList() {
        //        self.presentingViewController?.dismiss(animated: true, completion: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    private func handleRightButton(rightButton: [String]) {
        rightButton1.title = rightButton[0]
        rightButton2.title = rightButton[1]
        rightButton3.title = rightButton[2]
        if !rightButton[0].isEmpty {
            rightButton1.isEnabled = true
        } else {
            rightButton1.isEnabled = false
        }
        if !rightButton[1].isEmpty {
            rightButton2.isEnabled = true
        } else {
            rightButton2.isEnabled = false
        }
        if !rightButton[2].isEmpty {
            rightButton3.isEnabled = true
        } else {
            rightButton3.isEnabled = false
        }
        
    }
    
    public func goToOption(path: String, uvcOptionViewModelArray: [UVCOptionViewModel]) {
        for uvcovm in uvcOptionViewModelArray {
            if uvcovm.isDocument {
                continue
            }
            let name = uvcovm.getText(name: "Name")!.value
            for pin in uvcovm.pathIdName {
                let fullPath = pin.joined(separator: "->")
                print(fullPath)
                if path.hasSuffix(fullPath) {
                    // No childrens do nothing
                    if uvcovm.children.count == 0 {
                        return
                    } else { // Return the children of the found item
                        treeLevel = uvcovm.children[0].level
                        navigationItem.title = name
                        handleBackButton()
                        model!.uvcOptionViewModelList = uvcovm.children
                        return
                    }
                }
            }
            if uvcovm.childrenId.count > 0 {
                goToOption(path: path, uvcOptionViewModelArray: uvcovm.children)
            }
        }
    }
    
    func uvcOptionViewCellEditOk(index: Int, level: Int, senderModel: Any, sender: Any) {
        delegate?.optionViewControllerEditOk(index: index, parentIndex: parentIndex, level: treeLevel, senderModel: model!.uvcOptionViewModelList[index], sender: sender)
    }
    
    func uvcOptionViewCellTextFieldDidChange(index: Int, level: Int, senderModel: Any, sender: Any) {
        delegate?.optionViewControllerTextFieldDidChange(index: index, parentIndex: parentIndex, level: treeLevel, senderModel: model!.uvcOptionViewModelList[index], sender: sender)
    }
    
    
    // Back button handle it
    func handleBackButton() {
        if backButtonDisabled {
            return
        }
        if treeLevel == 1  {
            navigationItem.title = viewTitle
            backButton.title = ""
            backButton.isEnabled = false
        } else {
            backButton.title = model!.optionLabel["UDCOptionMapNode.Back"]!
            backButton.isEnabled = true
        }
    }
    
    // Get the parent list for the specfied path
    private func getTreeParentForPath(uvcOptionViewModelArray: [UVCOptionViewModel], path: String, parent: inout UVCOptionViewModel) -> [UVCOptionViewModel]? {
        
        for uvcovm in uvcOptionViewModelArray {
            print(uvcovm.pathIdName[0].joined(separator: "->"))
            for p in uvcovm.pathIdName {
                if p.joined(separator: "->") == path {
                    parent = uvcovm
                    treeLevel = uvcOptionViewModelArray[0].level
                    return uvcOptionViewModelArray
                }
            }
            if uvcovm.children.count > 0 {
                let uvcOptionViewModelArrayReturn =  getTreeParentForPath(uvcOptionViewModelArray: uvcovm.children, path: path, parent: &parent)
                if uvcOptionViewModelArrayReturn != nil {
                    return uvcOptionViewModelArrayReturn
                }
            }
        }
        
        return nil
    }
    
    public func addChildrenToNode(path: String, uvcOptionViewModelArray: inout [UVCOptionViewModel], children: [UVCOptionViewModel], isAppended: Bool) -> [UVCOptionViewModel]? {
        for uvcovm in uvcOptionViewModelArray {
            for pin in uvcovm.pathIdName {
                print("Reference find: \(pin.joined(separator: "->"))")
                if pin.joined(separator: "->") == path {
                    if !isAppended {
                        uvcovm.children.removeAll()
                    }
                    uvcovm.children.append(contentsOf: children)
                    for child in children {
                        uvcovm.childrenId.append(child._id)
                    }
                    return uvcovm.children
                }
            }
            if uvcovm.childrenId.count > 0 {
                let returnResult = addChildrenToNode(path: path, uvcOptionViewModelArray: &uvcovm.children, children: children, isAppended: isAppended)
                if returnResult != nil {
                    return returnResult
                }
            }
        }
        
        return nil
    }
    
    public func removeChildrenAt(path: String, uvcOptionViewModelArray: inout [UVCOptionViewModel], itemsToDelete: [UVCOptionViewModel]?, selectedOnly: Bool) -> [UVCOptionViewModel]? {
        for uvcovm in uvcOptionViewModelArray {
            if uvcovm.pathIdName[0].joined(separator: "->") == path {
                if itemsToDelete == nil {
                    uvcovm.children.removeAll()
                } else {
                    var indexArray = [Int]()
                    for (index, child) in uvcovm.children.enumerated() {
                        for itemToDelete in itemsToDelete! {
                            if child._id == itemToDelete._id {
                                if selectedOnly && !child.isSelected {
                                    continue
                                }
                                indexArray.append(index)
                            }
                        }
                        
                    }
                    for index in indexArray {
                        uvcovm.children.remove(at: index)
                    }
                }
                return uvcovm.children
            }
            if uvcovm.childrenId.count > 0 {
                let returnResult = removeChildrenAt(path: path, uvcOptionViewModelArray: &uvcovm.children, itemsToDelete: itemsToDelete, selectedOnly: selectedOnly)
                if returnResult != nil {
                    return returnResult
                }
            }
        }
        
        return nil
    }
    
    public func removeSelectedChildrenAt(path: String, uvcOptionViewModelArray: inout [UVCOptionViewModel]) -> [UVCOptionViewModel]? {
        for uvcovm in uvcOptionViewModelArray {
            if uvcovm.pathIdName[0].joined(separator: "->") == path {
                var idArray = [String]()
                for child in uvcovm.children {
                    if child.isSelected {
                        idArray.append(child._id)
                    }
                }
                for id in idArray {
                    let childrenNew = uvcovm.children.filter { $0._id != id  }
                    uvcovm.children.removeAll()
                    uvcovm.children.append(contentsOf: childrenNew)
                }
                return uvcovm.children
            }
            if uvcovm.childrenId.count > 0 {
                let returnResult = removeSelectedChildrenAt(path: path, uvcOptionViewModelArray: &uvcovm.children)
                if returnResult != nil {
                    return returnResult
                }
            }
        }
        
        return nil
    }
    
    private func getTreeChildForId(uvcOptionViewModelArray: [UVCOptionViewModel], childId: String) -> [UVCOptionViewModel]? {
        
        for uvcovm in uvcOptionViewModelArray {
            if uvcovm._id == childId {
                return uvcovm.children
            }
            if uvcovm.children.count > 0 {
                let uvcOptionViewModelArrayReturn = getTreeChildForId(uvcOptionViewModelArray: uvcovm.children, childId: childId)
                if uvcOptionViewModelArrayReturn != nil {
                    return uvcOptionViewModelArrayReturn
                }
            }
        }
        
        return nil
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if (kind == UICollectionView.elementKindSectionHeader) {
            headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SearchBarCollectionReusableView", for: indexPath) as? SearchBarCollectionReusableView
            
            return headerView!
        }
        
        return UICollectionReusableView()
        
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if model == nil {
            return 0
        }
        // #warning Incomplete implementation, return the number of items
        return model!.uvcOptionViewModelList.count
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! OptionViewCell
        if model == nil {
            return cell
        }
        // Configure the cell
        cell.index = indexPath.row
        cell.level = treeLevel
        cell.delegate = self
        do {
            // Diplay the cell based on the current document map view template (name, name and description, etc.,)
            print("section: \(indexPath.section)")
            let cellModel = model!.uvcOptionViewModelList[indexPath.row]
            if cellModel.isHidden {
                return cell
            }
            try cell.configure(with: cellModel, isEditableMode: false)
        } catch {
            print(error)
        }
        
        
        return cell
    }
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! OptionViewCell
        if model == nil {
            return CGSize(width: 0, height: 0)
        }
        
        let cellModel = model!.uvcOptionViewModelList[indexPath.row]
        let height = cellModel.getTextHeight(index: indexPath.item)
        
        
        return CGSize(width: 350, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 8, left: 8, bottom: 8, right: 8)
    }
    
    
    @IBAction func searchPresed(_ sender: Any) {
        
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        if self.searchText.trimmingCharacters(in: .whitespaces).isEmpty && searchActive {
            searchActive = false
            if model!.opeartionName == "DocumentGraphNeuron.DocumentItem.Get" {
                setCurrentOperation(name: "DocumentGraphNeuron.DocumentItem.Get")
                let typeRequest = GetDocumentItemOptionRequest()
                typeRequest.type = model!.typeRequest!.type
                typeRequest.category = model!.typeRequest!.category
                typeRequest.language = ApplicationSetting.DocumentLanguage!
                typeRequest.fromText = ""
                typeRequest.sortedBy = "name"
                typeRequest.limitedTo = 50
                typeRequest.isAll = false
                typeRequest.searchText = ""
                typeRequest.uvcViewItemType = model!.typeRequest!.uvcViewItemType
                
                setCurrentOperationData(data: [getCurrentOperation(): [
                    "typeRequest" : typeRequest]])
                sendRequest(source: self)
            }
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
        searchBar.text = searchText
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if activityIndicator.isAnimating {
            return
        }
        searchText = searchBar.text!
        if model!.opeartionName == "DocumentGraphNeuron.DocumentItem.Get" {
            setCurrentOperation(name: "DocumentGraphNeuron.DocumentItem.Get")
            let typeRequest = GetDocumentItemOptionRequest()
            typeRequest.type = model!.typeRequest!.type
            typeRequest.category = model!.typeRequest!.category
            typeRequest.language = ApplicationSetting.DocumentLanguage!
            typeRequest.fromText = ""
            typeRequest.sortedBy = "name"
            typeRequest.limitedTo = 50
            typeRequest.isAll = false
            typeRequest.searchText = searchText.trimmingCharacters(in: .whitespaces)
            typeRequest.uvcViewItemType = model!.typeRequest!.uvcViewItemType
            
            setCurrentOperationData(data: [getCurrentOperation(): [
                "typeRequest" : typeRequest]])
            sendRequest(source: self)
        } else if model!.opeartionName == "DocumentMapNeuron.Search.Document" {
            let documentMapSearchDocumentRequest = DocumentMapSearchDocumentRequest()
            if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
                documentMapSearchDocumentRequest.text = searchText.trimmingCharacters(in: .whitespaces)
            }
            documentMapSearchDocumentRequest.treeLevel = treeLevel
            documentMapSearchDocumentRequest.udcDocumentId = model!.documentMapSearchDocumentRequest!.udcDocumentId
            setCurrentOperation(name: model!.opeartionName)
            setCurrentOperationData(data: [getCurrentOperation(): [
                "documentMapSearchDocumentRequest" : documentMapSearchDocumentRequest,
                "neuronName": "DocumentMapNeuron"]])
            sendRequest(source: self)
        }
    }
}
