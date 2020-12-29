//
//  CollectionViewController.swift
//  UniversalViewController
//
//  Created by Kumar Muthaiah on 18/12/18.
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
import UDocsUtility
import UDocsBrain
import UDocsViewModel
import UDocsDocumentModel
import UDocsPhotoNeuronModel
import UDocsOptionMapNeuronModel
import UDocsNeuronModel
import UDocsViewUtility
import UDocsDocumentMapNeuronModel
import UDocsDocumentGraphNeuronModel

private let reuseIdentifier = "NavigationCell"
private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)

var layout: UICollectionViewFlowLayout = {
    let layout = UICollectionViewFlowLayout()
    let width = UIScreen.main.bounds.size.width
    layout.estimatedItemSize = CGSize(width: width, height: 10)
    return layout
}()

public class MasterViewController: UICollectionViewController, UVCNavigationViewCellDelegate, UIPopoverPresentationControllerDelegate, PopoverViewControllerDelegate, OptionViewControllerDelegate, UISearchBarDelegate,UISearchResultsUpdating {
    
    
    
    
    
    //    let searchController = UISearchController(searchResultsController: nil)
    var treeLevel: Int = 1
    var treeLevelSearch: Int = 1
    var viewTitle = ""
    var currentSelectedIndex = 0
    var udcDocumentMapNode: [UDCDocumentMapNode]?
    var detailViewController: DetailViewController? = nil
    var currentOptionCategory: String = ""
    var goToPathList = [String]()
    var goToPathFoundList = [Bool]()
    var startDocumentId: String = ""
    var endDocumentId: String = ""
    let uvcViewGenerator = UVCViewGenerator()
    var documentTabController: UITabBarController? = nil
    var activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
    var activityIndicatorTitle: String = ""
    var isInitialized: Bool = false
    var documentMapOptionsOptionViewModel = [UVCOptionViewModel]()
    var documentMapOptionsOptionViewModelList = [UVCOptionViewModel]()
    var documentMapDocumentOptionsOptionViewModel = [UVCOptionViewModel]()
    var documentMapDocumentOptionsOptionViewModelList = [UVCOptionViewModel]()
    var optionLabel = [String: String]()
    var optionTitle = [String: String]()
    var isActivityInProgress: Bool = false
    var uvcTreeNode = [UVCTreeNode]()
    var uvcTreeNodeList = [UVCTreeNode]()
    var uvcTreeNodeSearch = [UVCTreeNode]()
    var uvcTreeNodeSearchList = [UVCTreeNode]()
    var uvcDocumentMapViewTemplateType = UVCDocumentMapViewTemplateType.Name.name
    var isEditableMode: Bool = false
    var currentPathText = [String]()
    var currentPathTextSearch = [String]()
    var rootViewTitle: String = ""
    var rootViewTitleSearch: String = ""
    var headerView : SearchBarCollectionReusableView?
    var searchText: String = ""
    var isSearchActive: Bool = false
    
    
    
    // The document map is loaded, do the initialization
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let tintColor: UIColor?
        if view.traitCollection.userInterfaceStyle == .dark {
             tintColor = UIColor.white
        } else {
            tintColor = UIColor.black
        }
       
        // we have an iPad, so set the mode
        #if targetEnvironment(macCatalyst)
        splitViewController!.preferredDisplayMode = .allVisible
        #else
        splitViewController!.preferredDisplayMode = .primaryHidden
        #endif
        NotificationCenter.default.addObserver(self, selector: #selector(brainControllerNeuronResponse(_:)), name: .masterViewControllerNotification, object: nil)
        // Get detailview controller as need to call it frequently
        if let split = splitViewController {
            if UIDevice.current.userInterfaceIdiom == .pad {
                let controllers = split.viewControllers
                documentTabController = (controllers[controllers.count-1] as! UITabBarController)
                let navigationController = documentTabController!.viewControllers![0] as! UINavigationController
                detailViewController = navigationController.topViewController as! DetailViewController
                detailViewController?.masterViewController = self
            } else {
                let controllers = split.viewControllers
                let navigationController = (controllers[controllers.count-1] as! UINavigationController)
//                detailViewController = navigationController.topViewController as! DetailViewController
//                               detailViewController?.masterViewController = self
            }
        }
        // Setup the Search Controller
        //        searchController.searchResultsUpdater = self
        //        searchController.obscuresBackgroundDuringPresentation = false
        //        searchController.searchBar.placeholder = "Search Options"
        //
        //        navigationItem.searchController = searchController
        //        definesPresentationContext = true
        //
        //        // Setup the Scope Bar
        //        searchController.searchBar.delegate = self
        // Add observer for brain controller neuron
        
        
        // Set the document map title and hide back button
        navigationItem.title = viewTitle.capitalized
        backButton.title = ""
        backButton.isEnabled = false
        documentMapOption.tintColor = tintColor
        backButton.tintColor = tintColor
        
        // Register cell classes
        self.collectionView!.register(NavigationViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        if let _ = ApplicationSetting.SecurityToken {
            showActivityIndicator()
            getInterfaceOptions()
            
            
        } else {
            disconnect()
        }
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
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
            super.traitCollectionDidChange(previousTraitCollection)
//        print("triat: outside")
//        let optionButton = UIBarButtonItem(image: UIImage(named: "Elipsis"), style: .plain, target: self, action: #selector(documentMapOptionPressed(_:)))
        let tintColor: UIColor?
        if view.traitCollection.userInterfaceStyle == .dark {
             tintColor = UIColor.white
        } else {
            tintColor = UIColor.black
        }
        documentMapOption.tintColor = tintColor
        backButton.tintColor = tintColor
//        var buttonBarItems = [UIBarButtonItem]()
//        buttonBarItems.append(optionButton)
//        setToolbarItems(buttonBarItems, animated: false)
//        documentMapOption.tintColor =
    }
    
    
    public override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if (kind == UICollectionView.elementKindSectionHeader) {
            headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SearchBarCollectionReusableViewMaster", for: indexPath) as? SearchBarCollectionReusableView
            
            return headerView!
        }
        
        return UICollectionReusableView()
        
    }
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    @IBOutlet weak var documentMapOption: UIBarButtonItem!
    @IBAction func documentMapOptionPressed(_ sender: Any) {
        if ApplicationSetting.SecurityToken == nil {
            disconnect()
            return
        }
        if activityIndicator.isAnimating || documentMapOptionsOptionViewModelList.count == 0 {
            return
        }
        showPopover(category: optionTitle["UDCOptionMap.DocumentMapOptions"]!, uvcOptionViewModel: documentMapOptionsOptionViewModelList, width: 350, height: 350, sender: sender, delegate: self as UIPopoverPresentationControllerDelegate, optionDelegate: self, goToOption: "", isDismissedAutomatically: true, optionViewControllerName: "DocumentMapOptions", rightButton: ["", "", ""])
    }
    
    private func disconnect() {
        ApplicationSetting.deleteAll()
        isInitialized = false
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let connectionController = storyboard.instantiateViewController(withIdentifier: "SecurityController") as! SecurityController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //                    dismiss(animated: true, completion: nil)
        appDelegate.window?.rootViewController = connectionController
    }
    
    private func getOptionMap() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            var getOptionMapRequest = GetOptionMapRequest()
            getOptionMapRequest = GetOptionMapRequest()
            getOptionMapRequest.name = "UDCOptionMap.DocumentMapOptions"
            getOptionMapRequest.documentType = ApplicationSetting.DocumentType!
            let callBrainControllerNeuron = CallBrainControllerNeuron()
            callBrainControllerNeuron.getOptions(sourceName: String(describing: MasterViewController.self), language: ApplicationSetting.InterfaceLanguage!, getOptionMapRequest: getOptionMapRequest, neuronName: "DocumentGraphNeuron", optionSuffix: "DocumentMapOptions")
        }
    }
    
    private func getDocumentMapDocumentOptions() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            var getOptionMapRequest = GetOptionMapRequest()
            getOptionMapRequest = GetOptionMapRequest()
            getOptionMapRequest.name = "UDCOptionMap.DocumentMapDocumentOptions"
            getOptionMapRequest.documentType = ApplicationSetting.DocumentType!
            let callBrainControllerNeuron = CallBrainControllerNeuron()
            callBrainControllerNeuron.getOptions(sourceName: String(describing: MasterViewController.self), language: ApplicationSetting.InterfaceLanguage!, getOptionMapRequest: getOptionMapRequest, neuronName: "OptionMapNeuron", optionSuffix: "DocumentMapDocumentOptions")
        }
    }
    
    private func getInterfaceOptions() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            var getOptionMapRequest = GetOptionMapRequest()
            getOptionMapRequest = GetOptionMapRequest()
            getOptionMapRequest.name = "UDCOptionMap.InterfaceOptions"
            let callBrainControllerNeuron = CallBrainControllerNeuron()
            callBrainControllerNeuron.getOptions(sourceName: String(describing: MasterViewController.self), language: ApplicationSetting.InterfaceLanguage!, getOptionMapRequest: getOptionMapRequest, neuronName: "DocumentGraphNeuron", optionSuffix: "InterfaceOptions")
        }
    }
    
    
    private func refresh() {
        isSearchActive = false
        treeLevel = 1
        uvcTreeNodeList.removeAll()
        self.collectionView?.reloadData()
        handleBackButton()
        showActivityIndicator()
        getInterfaceOptions()
    }
    
    public func optionViewControllerOptionSelected(index: Int, parentIndex: Int, level: Int, senderModel: Any, sender: Any) {
        
    }
    
    public func optionViewControllerSelected(index: Int, parentIndex: Int, level: Int, senderModel: [Any], sender: Any) {
        
    }
    
    func navigationViewCellEvent(uvcViewItemType: String, eventName: String, uvcObject: Any, uiObject: Any, navigationViewCell: NavigationViewCell) {
        if activityIndicator.isAnimating {
            return
        }
        
        if eventName == "UVCViewItemEvent.Button.Pressed" && uvcViewItemType == "UVCViewItemType.Button" {
            let uiButton = uiObject as! UIButton
            let uvcButton = uvcObject as! UVCButton
            if navigationViewCell.uvcTreeNode!.objectType != "UDCDocumentType.None" {
                if uvcButton.name == "OptionsButton" {
                    CallBrainControllerNeuron.delegateMap.removeAll()
                    CallBrainControllerNeuron.delegateMap["uvcTreeNode"] = navigationViewCell.uvcTreeNode
                    showPopover(category: optionTitle["UDCOptionMap.DocumentMapDocumentOptions"]!, uvcOptionViewModel: documentMapDocumentOptionsOptionViewModelList, width: 400, height: 250, sender: uiButton, delegate: self as UIPopoverPresentationControllerDelegate, optionDelegate: self, goToOption: "", isDismissedAutomatically: false, optionViewControllerName: "DocumentMapDocumentOptions", rightButton: ["", "", ""])
                }
            }
        } else if ((eventName == "UVCViewItemEvent.Word.Taped" && uvcViewItemType == "UVCViewItemType.Text") || (eventName == "UVCViewItemEvent.Photo.Taped" && uvcViewItemType == "UVCViewItemType.Photo")) {
            currentSelectedIndex = navigationViewCell.index
            let uvctn: UVCTreeNode?
            if !isSearchActive {
                uvctn = uvcTreeNodeList[navigationViewCell.index]
            } else {
                uvctn = uvcTreeNodeSearchList[navigationViewCell.index]
            }
            let name = uvctn!.getText(name: "Name")!.value
            
            // Show child node
            if uvctn!.children.count > 0 {
                print(uvctn!.pathIdName.joined(separator: "->"))
                if isSearchActive {
                    currentPathTextSearch.append(name)
                    print(currentPathTextSearch.joined(separator: "->"))
                    treeLevelSearch += 1
                    print("Level: \(treeLevelSearch)")
                    print("Has Child")
                    uvcTreeNodeSearchList.removeAll()
                    uvcTreeNodeSearchList = getTreeChildForId(uvcTreeNodeArray: uvcTreeNodeSearch, childId: uvctn!._id, level: uvctn!.level)!
                } else {
                    currentPathText.append(name)
                    print(currentPathText.joined(separator: "->"))
                    treeLevel += 1
                    print("Has Child")
                    uvcTreeNodeList.removeAll()
                    uvcTreeNodeList = getTreeChildForId(uvcTreeNodeArray: uvcTreeNode, childId: uvctn!._id, level: uvctn!.level)!
                }
                viewTitle = name
                handleBackButton()
                self.collectionView?.reloadData()
            } else { // Just a selection
                if uvctn!.isChidlrenOnDemandLoading {
                    if !isSearchActive {
                        treeLevel += 1
                    } else {
                        treeLevelSearch += 1
                    }
                    print("Level: \(treeLevelSearch)")

                    let getDocumentMapRequest = GetDocumentMapRequest()
                    getDocumentMapRequest.udcDocumentId = uvctn!.objectId!
                    getDocumentMapRequest.pathIdName = uvctn!.pathIdName
                    getDocumentMapRequest.uvcDocumentMapViewTemplateType = "UVCDocumentMapViewTemplateType.NamePathPicture"
                    if uvctn!.parentId.count > 0 {
                        getDocumentMapRequest.parentId = uvctn!.parentId[0]
                    }
                    getDocumentMapRequest.isReference = uvctn!.isReference
                    if isSearchActive {
                        currentPathTextSearch.append(name)
                        getDocumentMapRequest.treeLevel = treeLevelSearch
                        uvcTreeNodeSearchList.removeAll()
                    } else {
                        currentPathText.append(name)
                        getDocumentMapRequest.treeLevel = treeLevel
                        uvcTreeNodeList.removeAll()
                    }
                    
                    self.collectionView?.reloadData()
                    uvctn!.children.removeAll()
                    uvctn!.childrenId.removeAll()
                    self.viewTitle = uvctn!.getText(name: "Name")!.value
                    getDocumentMap(getDocumentMapRequest: getDocumentMapRequest)
                    //                    getDocumentMapByPath(uvctn: uvctn)
                } else {
                    print("Selected: \(name)")
                    //                    if !uvctn.isReference {
                    askDetailToShowDocument(id: uvctn!._id, isEditable: false)
                    //                    } else {
                    //                        let getDocumentMapRequest = GetDocumentMapRequest()
                    //                        getDocumentMapRequest.udcDocumentId = uvctn.objectId!
                    //                        getDocumentMapRequest.pathIdName = uvctn.pathIdName
                    //                        getDocumentMapRequest.treeLevel = treeLevel
                    //                        getDocumentMap(getDocumentMapRequest: getDocumentMapRequest)
                    //                    }
                }
            }
        }
    }
    
    private func refreshCurrentDateTimeList() {
        //        if uvcTreeNodeList.count > 0 {
        //            let uvctn = uvcTreeNodeList[0]
        //            let uvctnParent = getParentNode(childrenNode: uvcTreeNode, parentId: uvctn.parentId[0])
        //            if uvctnParent!.isChidlrenOnDemandLoading && ((uvctnParent?.pathIdName.contains("UDCOptionMapNode.Recents"))! || (uvctnParent?.pathIdName.joined(separator: "->").hasSuffix("UDCOptionMapNode.Library->UDCDocumentMapNode.All"))!) {
        //                getDocumentMapByPath(uvctn: uvctnParent!)
        //            }
        //        }
    }
    
    private func getParentNode(childrenNode: [UVCTreeNode], parentId: String) -> UVCTreeNode? {
        for uvctn in childrenNode {
            if parentId == uvctn._id {
                return uvctn
            }
            if uvctn.children.count > 0 {
                let uvctnLocal = getParentNode(childrenNode: uvctn.children, parentId: parentId)
                if uvctnLocal != nil {
                    return uvctnLocal
                }
            }
        }
        
        return nil
    }
    
    private func getDocumentMapByPath(uvctn: UVCTreeNode) {
        uvcTreeNodeList.removeAll()
        self.collectionView?.reloadData()
        uvctn.children.removeAll()
        uvctn.childrenId.removeAll()
        self.viewTitle = uvctn.getText(name: "Name")!.value
        // Go to adds an extra path so check
        handleBackButton()
        let callBrainControllerNeuron = CallBrainControllerNeuron()
        let getDocumentMapByPathRequest = GetDocumentMapByPathRequest()
        getDocumentMapByPathRequest.level = uvctn.level
        getDocumentMapByPathRequest.parentId = uvctn._id
        getDocumentMapByPathRequest.pathIdName = uvctn.pathIdName
        getDocumentMapByPathRequest.uvcDocumentMapViewTemplateType = uvcDocumentMapViewTemplateType
        showActivityIndicator()
        callBrainControllerNeuron.getDocumentMapByPath(sourceName: String(describing: MasterViewController.self), getDocumentMapByPathRequest: getDocumentMapByPathRequest)
    }
    
    public func optionViewControllerEvent(uvcViewItemType: String, eventName: String, uvcObject: Any, uiObject: Any, optionViewCell: OptionViewCell, uvcOptionViewModel: UVCOptionViewModel, parentIndex: Int, callerObject: Any?, operationName: String) {
        let name = uvcOptionViewModel.getText(name: "Name")?.value
        let pathIdName = uvcOptionViewModel.pathIdName[parentIndex].joined(separator: "->")
        print()
        // TODO: To get the pathIdName and check. Add pathIdName in option map node
        // Refresh is choosen get the document map from the server.
        // May be other user as changed the map
        print("Selected: \(pathIdName)")
        if pathIdName == "UDCOptionMapNode.DocumentMapOptions->UDCOptionMapNode.Disconnect" {
            disconnect()
            return
        }
        else if pathIdName == "UDCOptionMapNode.DocumentMapOptions->UDCOptionMapNode.Refresh" {
            refresh()
            return
        }
        else if pathIdName == "UDCOptionMapNode.DocumentMapDocumentOptions->UDCOptionMapNode.EditDocument" {
            print("Selected: \(name)")
            let selectedUvctn = CallBrainControllerNeuron.delegateMap["uvcTreeNode"] as! UVCTreeNode
            //            if !selectedUvctn.isReference {
            CallBrainControllerNeuron.delegateMap.removeAll()
            askDetailToShowDocument(id:  selectedUvctn._id, isEditable: true)
            //            } else {
            //                let getDocumentMapRequest = GetDocumentMapRequest()
            //                getDocumentMapRequest.udcDocumentId = selectedUvctn.objectId!
            //                getDocumentMapRequest.pathIdName = selectedUvctn.pathIdName
            //                getDocumentMapRequest.treeLevel = treeLevel
            //                getDocumentMap(getDocumentMapRequest: getDocumentMapRequest)
            //            }
            return
        }
        else if pathIdName == "UDCOptionMapNode.DocumentMapDocumentOptions->UDCOptionMapNode.DeleteDocument" {
            print("Selected: \(name)")
            self.dismiss(animated: true, completion: nil)
            let selectedUvctn = CallBrainControllerNeuron.delegateMap["uvcTreeNode"] as! UVCTreeNode
            let uvcDocumentMapRequest = UVCDocumentMapRequest()
            uvcDocumentMapRequest.operationName = "DocumentView.DeleteDocument"
            detailViewController!.masterViewController = self
            uvcDocumentMapRequest.uvcTreeNode = selectedUvctn
            detailViewController!.detailItem = uvcDocumentMapRequest
            return
        }
        else if pathIdName == "UDCOptionMapNode.DocumentMapDocumentOptions->UDCOptionMapNode.AddToFavourite" {
            let selectedUvctn = CallBrainControllerNeuron.delegateMap["uvcTreeNode"] as! UVCTreeNode
            let callBrainControllerNeuron = CallBrainControllerNeuron()
            let documentAddToFavouriteRequest = DocumentAddToFavouriteRequest()
            documentAddToFavouriteRequest.udcDocumentTypeIdName = selectedUvctn.objectType
            documentAddToFavouriteRequest.udcDocumentId = selectedUvctn.objectId!
            callBrainControllerNeuron.documentAddToFavourite(sourceName: String(describing: MasterViewController.self), documentAddToFavouriteRequest: documentAddToFavouriteRequest)
            return
        } else if pathIdName.hasPrefix("UDCOptionMapNode.DocumentMapOptions->UDCOptionMapNode.InterfaceLanguage->") {
            let jsonUtility = JsonUtility<UDCHumanLanguageType>()
            let udcHumanLanguageType = jsonUtility.convertJsonToAnyObject(json: uvcOptionViewModel.model)
            ApplicationSetting.DocumentLanguage = udcHumanLanguageType.code6391
            ApplicationSetting.InterfaceLanguage = udcHumanLanguageType.code6391
            refresh()
            return
        }
        // Get the quick options item path
        
        let uvctn = uvcTreeNodeList[0]
        var path = uvcOptionViewModel.pathIdName[0].joined(separator: "->")
        
        
        // If path is same as the current path no need to go there
        if path == uvctn.path.joined(separator: "->") {
            return
        }
        // If path is empty then it is root option list
        if path.isEmpty || uvcOptionViewModel.idName == "UDCOptionMapNode.DocumentMap" {
            treeLevel = 1
            uvcTreeNodeList = uvcTreeNode
            viewTitle = rootViewTitle
            self.collectionView?.reloadData()
            handleBackButton()
            return
        }
        
        if uvcOptionViewModel.idName == "UDCOptionMapNode.Recents" {
            path = "UDCOptionMap.DocumentMap->UDCOptionMapNode.Recents"
            currentPathText.removeAll()
            currentPathText.append(rootViewTitle)
        } else if uvcOptionViewModel.idName == "UDCOptionMapNode.Favourites" {
            path = "UDCOptionMap.DocumentMap->UDCOptionMapNode.Favourites"
            currentPathText.removeAll()
            currentPathText.append(rootViewTitle)
        }
        // Go to the quick option item
        let _ = goTo(path: path, uvcTreeNodeArray: &uvcTreeNode, action: nil)
        handleBackButton()
    }
    
    private func setTitle(title: String) {
        navigationItem.title = title
    }
    
    
    public func optionViewControllerSelected(index: Int, parentIndex: Int, level: Int, senderModel: [Any]) {
        
    }
    
    public func optionViewControllerEditOk(index: Int, parentIndex: Int, level: Int, senderModel: Any, sender: Any) {
        
    }
    
    public func optionViewControllerTextFieldDidChange(index: Int, parentIndex: Int, level: Int, senderModel: Any, sender: Any) {
        
    }
    
    public func optionViewControllerButtonBarItemSelected(path: [String], buttonIndex: Int, senderModel: [Any], sender: Any) {
        
    }
    
    public func optionViewControllerCancelSelected() {
        
    }
    
    public func optionViewControllerEnteredOption(senderModel: [Any]) {
        
    }
    
    public func optionViewControllerConnfigureOption(index: Int, parentIndex: Int, level: Int, senderModel: [Any], uvcUIViewControllerItemCollection: UVCUIViewControllerItemCollection) {
        
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
        self.dismiss(animated: true) {
            self.present(navigationController, animated: true, completion: self.popOverLoadingCompleted)
        }
    }
    
    func optionSelected(index: Int, sender: Any) {
        //        if activityIndicator.isAnimating {
        //            return
        //        }
        //        currentSelectedIndex = index
        //        print("Option: \(index)")
        //        let uvctn = uvcTreeNodeList[index]
        //
        //        let fullPath = "DocumentMapOptions.\(viewTitle)->\(uvctn.path.joined(separator: "->"))"
        //        var path: String = fullPath
        //        if path.hasPrefix("DocumentMapOptions.Document Map->Recipe->") && path != "DocumentMapOptions.Document Map->Recipe->Favourites" && path != "DocumentMapOptions.Document Map->Recipe->Library" && !noOptionList.contains(path) {
        //            path = "DocumentMapOptions.Document Map->Recipe->"
        //        }
        //
        //        // Show the popover with options, based on path. The popover height is based on the number of items in the list
        //        let objects = optionList[path]
        //        print(fullPath)
        //        if objects != nil {
        //            let height = 50 * (objects?.count)!
        //            let popoverNode = UVCPopoverNode.getNodes(name: optionList[path]!)
        //            showPopover(category: path, popoverNode: popoverNode, width: 200, height: height, sender: sender as! UIButton, delegate: self as UIPopoverPresentationControllerDelegate, isLeftOptionEnabled: true, isRightOptionEnabled: false)
        //        }
    }
    
    func textFieldDidChange(index: Int, sender: Any) {
        if activityIndicator.isAnimating {
            return
        }
        print("textFieldDidChange: \(uvcTreeNodeList[index].getText(name: "Name")!.value)")
        uvcTreeNodeList[index].setText(name: "Name", value: (sender as! UITextField).text!)
        
    }
    
    func editOk(index: Int, sender: Any) {
        if activityIndicator.isAnimating {
            return
        }
        
        showActivityIndicator()
        
        if currentOptionCategory == "Change Name" {
            currentOptionCategory = ""
            let uvctn = uvcTreeNodeList[index]
            let value = uvctn.getText(name: "Name")!.value
            var tempPath = uvctn.path
            tempPath.remove(at: tempPath.count - 1)
            print("modified path: \(tempPath)")
            // Update the ui node list
            updateNode(uvcTreeNodeArray: &uvcTreeNode, id: uvctn._id, newNode: uvctn)
            // Update the model
            for udcdmn in udcDocumentMapNode! {
                if udcdmn._id == uvctn._id {
                    print("Updated model")
                    udcdmn.name = value
                    changeDocumentMapNode(id: uvctn._id, udcdmn: udcdmn)
                    break
                }
            }
            // Change the view model of the cell to non editable
//            uvctn.uvcViewModel = uvcViewGenerator.getTreeNodeViewModel(name: value, description: "", language: ApplicationSetting.InterfaceLanguage!, isChildrenExist: uvctn.children.count > 0, isEditable: false)
            uvctn.isEditable = false
            uvcTreeNodeList[index] = uvctn
            askDetailToShowDocument(id: uvctn._id, isEditable: false)
        } else {
            let value = uvcTreeNodeList[index].getText(name: "Name")!.value
            print("edit OK: \(value)")
            uvcTreeNodeList[index].isEditable = false
            let uvctn = uvcTreeNodeList[index]
            // Create the new node with updated value entered by user
            let uvctnNew = UVCTreeNode()
            // Get the view model for editing
//            uvctnNew.uvcViewModel = uvcViewGenerator.getTreeNodeViewModel(name: value, description: value, language: ApplicationSetting.InterfaceLanguage!, isChildrenExist: uvctn.children.count > 0, isEditable: false)
            uvctnNew.path = uvctn.path
            uvctnNew._id = uvctn._id
            uvctnNew.level = uvctn.level
            uvctnNew.isEditable = false
            uvctnNew.path[uvctnNew.path.count - 1] = value
            var tempPath = uvctn.path
            tempPath.remove(at: tempPath.count - 1)
            print("modified path: \(tempPath)")
            // Get the parent id of this added node for sending it to server
            let parentId = getParentId(uvcTreeNodeArray: &uvcTreeNode, path: tempPath.joined(separator: "->"))
            uvctnNew.parentId.append(parentId!)
            uvcTreeNodeList[index] = uvctnNew
            // Put the value in the added node in model
            for udcdmn in udcDocumentMapNode! {
                if udcdmn._id == uvctnNew._id {
                    print("Updated model")
                    udcdmn.name = value
                    // Send to the server
                    addDocumentMapNode(parentId: parentId!, udcdmn: udcdmn)
                    break
                }
            }
        }
        self.collectionView?.reloadData()
    }
    
    private func getDocumentTypeName(name: String) -> String? {
//        if name == UDCDocumentType.Recipe.description {
//            return UDCDocumentType.Recipe.name
//        }
        
        return nil
    }
    
    private func changeDocumentMapNode(id: String, udcdmn: UDCDocumentMapNode) {
        let callBrainControllerNeuron = CallBrainControllerNeuron()
        udcdmn.udcDocumentType = getDocumentTypeName(name: udcdmn.path[0])!
        callBrainControllerNeuron.changeDocumentMapNode(sourceName: String(describing: MasterViewController.self), userName: ApplicationSetting.UserName!, password: ApplicationSetting.Password!, eMail: "", language: ApplicationSetting.InterfaceLanguage!, id: id, udcDocumentMapNode: udcdmn)
    }
    
    private func removeDocumentMapNode(udcDocumentMapNode: UDCDocumentMapNode) {
        let callBrainControllerNeuron = CallBrainControllerNeuron()
        callBrainControllerNeuron.removeDocumentMapNode(sourceName: String(describing: MasterViewController.self), userName: ApplicationSetting.UserName!, password: ApplicationSetting.Password!, eMail: "", language: ApplicationSetting.InterfaceLanguage!, udcDocumentMapNode: udcDocumentMapNode)
    }
    
    private func addDocumentMapNode(parentId: String, udcdmn: UDCDocumentMapNode) {
        let callBrainControllerNeuron = CallBrainControllerNeuron()
        udcdmn.udcDocumentType = getDocumentTypeName(name: udcdmn.path[0])!
        callBrainControllerNeuron.addDocumentMapNode(sourceName: String(describing: MasterViewController.self), userName: ApplicationSetting.UserName!, password: ApplicationSetting.Password!, eMail: "", language: ApplicationSetting.InterfaceLanguage!, parentId: parentId, udcDocumentMapNode: udcdmn)
    }
    
    var masterItem: UVCDocumentMapRequest? {
        didSet {
            configureMasterView()
        }
    }
    
    private func configureMasterView() {
        print("Configure master view")
        if masterItem?.operationName == "DocumentGraphNeuron.Document.Save" || masterItem?.operationName == "DocumentGraphNeuron.Document.Change" {
            updateDocumentId(udcDocumentMapNodeArray: &udcDocumentMapNode!, udcDocumentMapNodeId: (masterItem?.uvcTreeNode._id)!, documentId: (masterItem?.uvcTreeNode.objectId)!, name: (masterItem?.uvcTreeNode.getText(name: "Name")!.value)!)
        } else if masterItem?.operationName == "DocumentMap.Refresh" {
            refresh()
        }  else if masterItem?.operationName == "DocumentMap.RefreshCurrentDateTimeList" {
            refreshCurrentDateTimeList()
        } else if masterItem?.operationName == "DocumentMap.GoTo" {
            goTo(path: (masterItem?.uvcTreeNode.pathIdName.joined(separator: "->"))!, uvcTreeNodeArray: &uvcTreeNode, action: nil)
        }
    }
    
    // Update the ui node list with new id for the add operation
    private func updateDocumentId(udcDocumentMapNodeArray: inout [UDCDocumentMapNode], udcDocumentMapNodeId: String, documentId: String, name: String) {
        
        for uvctn in uvcTreeNodeList {
            if uvctn._id == udcDocumentMapNodeId {
                uvctn.setText(name: "Name", value: name)
                break
            }
        }
        
        updateName(uvcTreeNodeArray: &uvcTreeNode, id: udcDocumentMapNodeId, name: name)
        
        for udcdmn in udcDocumentMapNodeArray {
            if udcdmn._id == udcDocumentMapNodeId {
                print("Updated from \(udcdmn._id) to: \(documentId)")
                udcdmn.documentId = documentId
                udcdmn.name = name
                break
            }
        }
        
        self.collectionView?.reloadData()
    }
    
    // Get parent id for a tree path
    private func getParentId(uvcTreeNodeArray: inout [UVCTreeNode], path: String) -> String? {
        
        for uvctn in uvcTreeNodeArray {
            if uvctn.path.joined(separator: "->") == path {
                return uvctn._id
            }
            if uvctn.children.count > 0 {
                let result = getParentId(uvcTreeNodeArray: &uvctn.children, path: path)
                if result != nil {
                    return result
                }
            }
        }
        return nil
    }
    
    // Add the given children to the parent at specified path
    private func addChildren(uvcTreeNodeArray: inout [UVCTreeNode], newNode: UVCTreeNode, path: String, found: inout Bool) {
        
        for uvctn in uvcTreeNodeArray {
            if uvctn.pathIdName.joined(separator: "->") == path {
                print("Updating at path: \(path) parent name: \(uvctn.getText(name: "Name")!.value)")
                uvctn.children.append(newNode)
                found = true
                return
            }
            if uvctn.children.count > 0 {
                addChildren(uvcTreeNodeArray: &uvctn.children, newNode: newNode, path: path, found: &found)
            }
            if found {
                return
            }
        }
    }
    
    private func addChildren(uvcTreeNodeArray: inout [UVCTreeNode], newNode: [UVCTreeNode], path: String, found: inout Bool) {
        
        for uvctn in uvcTreeNodeArray {
            if uvctn.pathIdName.joined(separator: "->") == path {
                print("Updating at path: \(path) parent name: \(uvctn.getText(name: "Name")!.value)")
                uvctn.children.append(contentsOf: newNode)
                found = true
                return
            }
            if uvctn.children.count > 0 {
                addChildren(uvcTreeNodeArray: &uvctn.children, newNode: newNode, path: path, found: &found)
            }
            if found {
                return
            }
        }
    }
    
    // Update a node based on given id
    private func updateNode(uvcTreeNodeArray: inout [UVCTreeNode], id: String, newNode: UVCTreeNode) {
        
        for uvctn in uvcTreeNodeArray {
            if uvctn._id == id {
                print("Updated tree node")
                uvctn.setText(name: "Name", value: (newNode.getText(name: "Name")?.value)!)
                return
            }
            if uvctn.children.count > 0 {
                updateNode(uvcTreeNodeArray: &uvctn.children, id: id, newNode: newNode)
            }
        }
    }
    
    // Delete a node based on its parent id and the deleted item index
    private func deleteNode(uvcTreeNodeArray: inout [UVCTreeNode], parentId: String, deleteIndex: Int) {
        
        for uvctn in uvcTreeNodeArray {
            if uvctn._id == parentId {
                print("Deleted node \(parentId)")
                uvctn.children.remove(at: deleteIndex)
                return
            }
            if uvctn.children.count > 0 {
                deleteNode(uvcTreeNodeArray: &uvctn.children, parentId: parentId, deleteIndex: deleteIndex)
            }
        }
    }
    
    // Get node list based on id. Also get the parent id of it
    private func getNodeList(uvcTreeNodeArray: inout [UVCTreeNode], id: String, parentId: inout String) -> [UVCTreeNode]! {
        
        for uvctn in uvcTreeNodeArray {
            if uvctn._id == id {
                print("Parent tree node: \(parentId)")
                parentId = uvctn.parentId[0]
                print("Deleted tree node: \(uvctn._id)")
                return uvcTreeNodeArray
            }
            if uvctn.children.count > 0 {
                parentId = uvctn._id
                let result = getNodeList(uvcTreeNodeArray: &uvctn.children, id: id, parentId: &parentId)
                if result != nil {
                    return result
                }
            }
        }
        
        return nil
    }
    
    // Go to the specified option list and do actions if specified
    private func goTo(path: String, uvcTreeNodeArray: inout [UVCTreeNode], action: String?) {
        for uvctn in uvcTreeNodeArray {
            let name = uvctn.getText(name: "Name")!.value
            currentPathText.append(name)
            print("Map Path: \(currentPathText.joined(separator: "->"))")
            let fullPath = uvctn.pathIdName.joined(separator: "->")
            print(fullPath)
            if fullPath == path {
                // No childrens do nothing
                if uvctn.children.count == 0 && !uvctn.isChidlrenOnDemandLoading {
                    return
                } else { // Return the children of the found item
                    
                    viewTitle = name
                    if uvctn.isChidlrenOnDemandLoading {
                        treeLevel = uvctn.level + 1
                        getDocumentMapByPath(uvctn: uvctn)
                        return
                    } else {
                        treeLevel = uvctn.children[0].level
                    }
                    uvcTreeNodeList = uvctn.children
                    startDocumentId = uvctn.children[0]._id
                    endDocumentId = uvctn.children[uvctn.children.count - 1]._id
                }
                //                if action != nil {
                //                    if action == "Add Recipe" {
                //                        // Create a new UI node
                //                        let uvctnNew = UVCTreeNode()
                //                        uvctnNew.level = treeLevel
                //                        let nameNew = "Untitled \(untitledIndex)"
                //                        uvctnNew.uvcViewModel = uvcViewGenerator.getTreeNodeViewModel(name: nameNew, description: "Untitled \(untitledIndex) Description", language: ApplicationSetting.InterfaceLanguage!, isChildrenExist: false, isEditable: true)
                //                        for parent in uvctn.parentId {
                //                            uvctnNew.parentId.append(parent)
                //                        }
                //                        uvctnNew.path = uvctn.path
                //                        uvctnNew._id = nameNew
                //                        uvctnNew.isEditable = true
                //                        uvctnNew.level = uvctn.children[0].level
                //                        treeLevel = uvctnNew.level
                //                        uvctnNew.path.append(nameNew)
                //                        untitledIndex += 1
                //                        uvcTreeNodeList.append(uvctnNew)
                //                        uvctn.children.append(uvctnNew)
                //
                //                        // Calculate the index in the model to add
                //                        var indexUdcdmn: Int = -1
                //                        for udcdmn in udcDocumentMapNode! {
                //                            if udcdmn._id == uvctn._id {
                //                                indexUdcdmn += 1
                //                                break
                //                            }
                //                        }
                //
                //                        // Add to model
                //                        udcDocumentMapNode![indexUdcdmn].childrenId.append(uvctnNew._id)
                //                        let udcDocumentMapNodeNew = UDCDocumentMapNode()
                //                        udcDocumentMapNodeNew.parentId.append(uvctn._id)
                //                        udcDocumentMapNodeNew._id = uvctnNew._id
                //                        udcDocumentMapNodeNew.path = uvctnNew.path
                //                        udcDocumentMapNodeNew.name = nameNew
                //                        udcDocumentMapNodeNew.level = uvctnNew.level
                //                        udcDocumentMapNode?.append(udcDocumentMapNodeNew)
                //                    }
                //                }
                self.collectionView?.reloadData()
                handleBackButton()
                return
            } else {
                if uvctn.children.count > 0 {
                    goTo(path: path, uvcTreeNodeArray: &uvctn.children, action: action)
                }
                currentPathText.remove(at: currentPathText.count - 1)
            }
            
            // Recursive
            
        }
    }
    
    // Back is pressed go to the previous option list p
    @IBAction func backPressed(_ sender: Any) {
        if activityIndicator.isAnimating {
            return
        }
        
        let uvctn: UVCTreeNode?
        if !isSearchActive {
            uvctn = uvcTreeNodeList[0]
            uvcTreeNodeList.removeAll()
            treeLevel -= 1
        } else {
            uvctn = uvcTreeNodeSearchList[0]
            uvcTreeNodeSearchList.removeAll()
            treeLevelSearch -= 1
        }
        print("Level: \(treeLevelSearch)")

        //        var tempPath = currentPathText
        //        tempPath.remove(at: tempPath.count - 1)
        var tempPathIdName = uvctn!.pathIdName
        tempPathIdName.remove(at: tempPathIdName.count - 1)
        let pathIdName = tempPathIdName.joined(separator: "->")
        if isSearchActive {
            currentPathTextSearch.joined(separator: "->")
        } else {
            currentPathText.joined(separator: "->")
        }
        
        //        removeChildrensIfIsChidlrenOnDemandLoading(uvcTreeNodeArray: uvcTreeNode, path: uvctn.pathIdName.joined(separator: "->"))
        // Get the parent's list and show it as current
        if !isSearchActive {
            uvcTreeNodeList = getTreeParentForPath(uvcTreeNodeArray: uvcTreeNode, path: pathIdName, level: treeLevel)!
        } else {
            if uvctn!.children.count == 0 && uvctn!.level == 2 {
                uvcTreeNodeSearchList = getTreeParentForPath(uvcTreeNodeArray: uvcTreeNodeSearch, path: pathIdName, level: treeLevelSearch)!
            } else {
                uvcTreeNodeSearchList = getTreeParentForPath(uvcTreeNodeArray: uvcTreeNodeSearch, path: pathIdName, level: treeLevelSearch)!
            }
        }
        print(tempPathIdName.joined(separator: "->"))
        
        // Choose the proper title
        if isSearchActive {
            if currentPathTextSearch.count > 1 {
                viewTitle = currentPathTextSearch[currentPathTextSearch.count - 2]
            } else {
                viewTitle = currentPathTextSearch[0]
            }
            handleBackButton()
            currentPathTextSearch.remove(at: currentPathTextSearch.count - 1)
        } else {
            if currentPathText.count > 1 {
                viewTitle = currentPathText[currentPathText.count - 2]
            } else {
                viewTitle = currentPathText[0]
            }
            handleBackButton()
            currentPathText.remove(at: currentPathText.count - 1)
        }
        self.collectionView?.reloadData()
    }
    
    public func getTabController() -> UITabBarController? {
        let controllers = splitViewController!.viewControllers
        for controller in controllers {
            if controller is UITabBarController {
                return controller as! UITabBarController
            }
        }
        
        return nil
    }
    
    private func setAndShowDetailedView(object: UVCDocumentMapRequest) {
        documentTabController!.navigationItem.leftBarButtonItem = splitViewController!.displayModeButtonItem
        documentTabController!.navigationItem.leftItemsSupplementBackButton = true
        documentTabController!.navigationItem.title = "test"
        documentTabController?.selectedViewController = documentTabController?.viewControllers![0]
        if UIDevice.current.userInterfaceIdiom == .phone {
            let navigationController = splitViewController?.viewControllers[(splitViewController?.viewControllers.count)!-1] as! UINavigationController
            
            
            detailViewController?.masterViewController = self
            
            navigationController.pushViewController(documentTabController!, animated: true)
            detailViewController?.detailItem = object
            
        } else {
            detailViewController!.masterViewController = self
            detailViewController?.detailItem = object
        }
    }
    
    
    // Show activity indicator for busy operation
    private func showActivityIndicator() {
        // Disable interaction to the document map and show activity indicator
        self.collectionView?.isUserInteractionEnabled = false
        activityIndicator.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(100), height: CGFloat(100))
        
        // Let the user know doing something
        activityIndicator.color = .green
        activityIndicatorTitle = navigationItem.title!
        navigationItem.titleView = activityIndicator
        activityIndicator.startAnimating()
        isActivityInProgress = true
    }
    
    // Done with busy work
    private func hideActivityIndicator() {
        // Enable interaction to document map and hide activity monitor
        self.collectionView?.isUserInteractionEnabled = true
        activityIndicator.stopAnimating()
        isActivityInProgress = false
        navigationItem.titleView = nil
        self.setTitle(title: self.viewTitle)
    }
    
    private func askDetailToShowDocument(id: String, isEditable: Bool) {
        
        if !isSearchActive {
            for uvctnl in uvcTreeNodeList {
                if uvctnl._id == id {
                    if uvctnl.objectId == nil {
                        break
                    }
                    print("Document id: \(uvctnl.objectId!): \(uvctnl.getText(name: "Name")!.value)")
                    let uvcDocumentMapRequest = UVCDocumentMapRequest()
                    if (uvctnl.objectId!.isEmpty) {
                        uvcDocumentMapRequest.operationName = "DocumentView.GetNewDocument"
                    } else {
                        uvcDocumentMapRequest.operationName = "DocumentView.GetDocument"
                    }
                    detailViewController!.masterViewController = self
                    uvcDocumentMapRequest.uvcTreeNode = uvctnl
                    uvcDocumentMapRequest.isEditable = isEditable
                    setAndShowDetailedView(object: uvcDocumentMapRequest)
                    break
                }
            }
        } else {
            for uvctnl in uvcTreeNodeSearchList {
                if uvctnl._id == id {
                    if uvctnl.objectId == nil {
                        break
                    }
                    print("Document id: \(uvctnl.objectId!): \(uvctnl.getText(name: "Name")!.value)")
                    let uvcDocumentMapRequest = UVCDocumentMapRequest()
                    if (uvctnl.objectId!.isEmpty) {
                        uvcDocumentMapRequest.operationName = "DocumentView.GetNewDocument"
                    } else {
                        uvcDocumentMapRequest.operationName = "DocumentView.GetDocument"
                    }
                    detailViewController!.masterViewController = self
                    uvcDocumentMapRequest.uvcTreeNode = uvctnl
                    uvcDocumentMapRequest.isEditable = isEditable
                    setAndShowDetailedView(object: uvcDocumentMapRequest)
                    break
                }
            }
        }
    }
    private func askDetailToShowDocument(uvctn: UVCTreeNode, isEditable: Bool) {
        print("Document id: \(uvctn.objectId!): \(uvctn.getText(name: "Name")!.value)")
        let uvcDocumentMapRequest = UVCDocumentMapRequest()
        if (uvctn.objectId!.isEmpty) {
            uvcDocumentMapRequest.operationName = "DocumentView.GetNewDocument"
        } else {
            uvcDocumentMapRequest.operationName = "DocumentView.GetDocument"
        }
        detailViewController!.masterViewController = self
        uvcDocumentMapRequest.uvcTreeNode = uvctn
        uvcDocumentMapRequest.isEditable = isEditable
        setAndShowDetailedView(object: uvcDocumentMapRequest)
    }
    
    // User as selected an item in the popover
    public func popoverItemSelected(index: Int, switchOn: Bool) {
        
        //            if currentOptionCategory.hasPrefix("DocumentMapOptions") {
        //                // Get the currently shown list in document map
        //                let uvctn = uvcTreeNodeList[currentSelectedIndex]
        //                let fullPath = "\(viewTitle)->\(uvctn.path.joined(separator: "->"))"
        //                var path: String = fullPath
        //
        //                // Modify the path specially for Recipes option
        //                if path.hasPrefix("DocumentMapOptions.Document Map->Recipe->") && path != "DocumentMapOptions.Document Map->Recipe->Favourites" && path != "DocumentMapOptions.Document Map->Recipe->Library" && !noOptionList.contains(path) {
        //                    path = "DocumentMapOptions.Document Map->Recipe->"
        //                }
        //
        //                // Get the option list based on the path
        //                let objects = optionList[path]
        //                print("Path: \(fullPath)")
        //                let selected = objects![index]
        //                print("Selected: \(selected)")
        //
        //                // Add new recipe
        //                if selected == "Add Recipe" {
        //                    // Go to the Add Recipe option list and at the end add an item
        //                    let _ = goTo(path: path, uvcTreeNodeArray: &uvcTreeNode, action: selected)
        //                    handleBackButton()
        //                } else if selected == "Change Name" {
        //                    // Make the item editable by changing the model
        //                    currentOptionCategory = selected
        //                    uvctn.isEditable = true
        //                    uvctn.uvcViewModel = uvcViewGenerator.getTreeNodeViewModel(name: uvctn.getText(name: "Name")!.value, description: "", language: ApplicationSetting.InterfaceLanguage!, isChildrenExist: false, isEditable: true)
        //                    self.collectionView?.reloadData()
        //                } else if selected == "Change Document" {
        //                    let uvcDocumentMapRequest = UVCDocumentMapRequest()
        //                    uvcDocumentMapRequest.operationName = "DocumentView.ChangeDocument"
        //                    for udcdmn in udcDocumentMapNode! {
        //                        if udcdmn._id == uvctn._id {
        //                            uvcDocumentMapRequest.udcDocumentMapNode = udcdmn
        //                            break
        //                        }
        //                    }
        //                    setAndShowDetailedView(object: uvcDocumentMapRequest)
        //                } else if selected == "Remove" {
        //                    // Confirm user, for safety
        //                    let alert = UIAlertController(title: "Alert", message: "Are you sure?", preferredStyle: .alert)
        //
        //                    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (UIAlertAction) -> Void in
        //                        self.showActivityIndicator()
        //                        for udcdmn in self.udcDocumentMapNode! {
        //                            if udcdmn._id == uvctn._id {
        //                                self.removeDocumentMapNode(udcDocumentMapNode: udcdmn)
        //                                break
        //                            }
        //                        }
        //
        //                    }))
        //                    alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        //
        //                    // Handle already active issue
        //                    if presentedViewController == nil {
        //                        self.detailViewController!.present(alert, animated: true, completion: nil)
        //                    } else {
        //                        detailViewController!.dismiss(animated: false) { () -> Void in
        //                            self.detailViewController!.present(alert, animated: true, completion: nil)
        //                        }
        //                    }
        //                }
        //            } else if currentOptionCategory.hasPrefix("DocumentMapMainOptions") {
        /*if documentMapOptionList[index] == "Disconnect" {
         ApplicationSetting.deleteAll()
         isInitialized = false
         
         let storyboard = UIStoryboard(name: "Main", bundle: nil)
         let connectionController = storyboard.instantiateViewController(withIdentifier: "SecurityController") as! SecurityController
         let appDelegate = UIApplication.shared.delegate as! AppDelegate
         //                    dismiss(animated: true, completion: nil)
         appDelegate.window?.rootViewController = connectionController
         return
         }
         // Refresh is choosen get the document map from the server.
         // May be other user as changed the map
         print("Selected: \(documentMapOptionList[index])")
         if documentMapOptionList[index] == "Refresh" {
         treeLevel = 0
         uvcTreeNodeList.removeAll()
         self.collectionView?.reloadData()
         handleBackButton()
         showActivityIndicator()
         getDocumentMap()
         return
         }
         
         // Get the quick options item path
         let path = goToOptionList[documentMapOptionList[index]]
         let uvctn = uvcTreeNodeList[0]
         
         // If path is same as the current path no need to go there
         if path == uvctn.path.joined(separator: "->") {
         return
         }
         if path != nil {
         // If path is empty then it is root option list
         if path!.isEmpty {
         treeLevel = 0
         uvcTreeNodeList = uvcTreeNode
         navigationItem.title = viewTitle
         self.collectionView?.reloadData()
         handleBackButton()
         return
         }
         
         // Go to the quick option item
         let _ = goTo(path: path!, uvcTreeNodeArray: &uvcTreeNode, action: nil)
         handleBackButton()
         }*/
        //            }
        
    }
    
    // Fill up the childrens based on Id's, so that easy to handle the tree in this document map
    private func fillUpChilds() {
        var startWithIndex = 0
        for uvctn in uvcTreeNode {
            if uvctn.childrenId.count > 0 {
                let uvctnChilds = getChildrens(uvcTreeNodeArray: uvcTreeNode, childrenId: uvctn.childrenId)
                uvctn.parentId.append(uvctn._id)
                for child in uvctnChilds {
                    uvctn.children.append(child)
                }
                
            }
        }
        
    }
    
    // Back button handle it
    func handleBackButton() {
        var tl = treeLevel
        if isSearchActive {
            tl = treeLevelSearch
        }
        if tl == 1 {
            if isSearchActive {
                viewTitle = rootViewTitleSearch
            } else {
                viewTitle = rootViewTitle
            }
        }
        setTitle(title: viewTitle)
        if tl == 1 {
            backButton.title = ""
            backButton.isEnabled = false
        } else {
            backButton.title = optionLabel["UDCOptionMapNode.Back"]!
            backButton.isEnabled = true
        }
    }
    
    func getDocumentMap(getDocumentMapRequest: GetDocumentMapRequest) {
        getDocumentMapRequest.darkMode = self.view.traitCollection.userInterfaceStyle == .dark
        let callBrainControllerNeuron = CallBrainControllerNeuron()
        CallBrainControllerNeuron.delegateMap.removeAll()
        CallBrainControllerNeuron.delegateMap["Authentication"] = self
        callBrainControllerNeuron.getDocumentMap(sourceName: String(describing: MasterViewController.self), getDocumentMapRequest: getDocumentMapRequest)
        
        
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
    
    // Brain controller neuron responded
    @objc func brainControllerNeuronResponse(_ notification:Notification) {
        if notification.name != Notification.Name(rawValue: "MasterViewControllerNotification") {
            return
        }
        let neuronRequest: NeuronRequest = notification.object as! NeuronRequest
        
        if neuronRequest.neuronOperation.neuronOperationStatus.neuronOperationError!.count > 0 {
            hideActivityIndicator()
            if neuronRequest.neuronOperation.neuronOperationStatus.neuronOperationError![0].name == "SecurityNeuronErrorType.SecurityTokenExpired" {
                disconnect()
                return
            }
            showAlertView(message: neuronRequest.neuronOperation.neuronOperationStatus.neuronOperationError![0].description)
            return
        }
        if neuronRequest.neuronOperation.neuronOperationStatus.neuronOperationSuccess!.count > 0 {
            if neuronRequest.neuronOperation.name == "DocumentMapNeuron.DocumentMap.Get" {
                handleGetDocument(neuronRequest: neuronRequest)
            } else if neuronRequest.neuronOperation.name == "DocumentMapNeuron.DocumentMapNode.Add" {
                handleAddDocumentMapNode(neuronRequest: neuronRequest)
            } else if neuronRequest.neuronOperation.name == "DocumentMapNeuron.DocumentMapNode.Change" {
                handleChangeDocumentMapNode(neuronRequest: neuronRequest)
            } else if neuronRequest.neuronOperation.name == "DocumentMapNeuron.DocumentMapNode.Remove" {
                handleRemoveDocumentMapNode(neuronRequest: neuronRequest)
            } else if neuronRequest.neuronOperation.name == "OptionMapNeuron.OptionMap.Get.DocumentMapOptions" || neuronRequest.neuronOperation.name == "OptionMapNeuron.OptionMap.Get.DocumentMapDocumentOptions" {
                handleOptions(neuronRequest: neuronRequest)
            } else if neuronRequest.neuronOperation.name == "OptionMapNeuron.OptionMap.Get.InterfaceOptions" {
                handleInterfaceOptions(neuronRequest: neuronRequest)
            } else if neuronRequest.neuronOperation.name == "DocumentMapNeuron.DocumentMap.Get.ByPath" {
                handleGetDocumentMapByPath(neuronRequest: neuronRequest)
            } else if neuronRequest.neuronOperation.name == "DocumentMapNeuron.Search.Document" {
                handleSearchDocument(neuronRequest: neuronRequest)
            }
        }
        
    }
    
    
    private func handleOptions(neuronRequest: NeuronRequest) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            let jsonUtility = JsonUtility<GetOptionMapResponse>()
            
            let getOptionMapResponse = jsonUtility.convertJsonToAnyObject(json: neuronRequest.neuronOperation.neuronData.text)
            
            if getOptionMapResponse.name == "UDCOptionMap.DocumentMapOptions" {
                self.documentMapOptionsOptionViewModel.removeAll()
                self.documentMapOptionsOptionViewModelList.removeAll()
                for uvcovm in getOptionMapResponse.uvcOptionMapViewModel.uvcOptionViewModel {
                    self.documentMapOptionsOptionViewModel.append(uvcovm)
                }
                self.optionTitle["UDCOptionMap.DocumentMapOptions"] = self.documentMapOptionsOptionViewModel[0].getText(name: "Name")!.value
                self.fillUpDocumentMapOptionsChilds()
                for uvcovm in self.documentMapOptionsOptionViewModel {
                    if uvcovm.level == 1 {
                        self.documentMapOptionsOptionViewModelList.append(uvcovm)
                    }
                }
                self.documentMapOptionsOptionViewModel = self.documentMapOptionsOptionViewModelList
                self.getDocumentMapDocumentOptions()
            } else if getOptionMapResponse.name == "UDCOptionMap.DocumentMapDocumentOptions" {
                self.documentMapDocumentOptionsOptionViewModel.removeAll()
                self.documentMapDocumentOptionsOptionViewModelList.removeAll()
                for uvcovm in getOptionMapResponse.uvcOptionMapViewModel.uvcOptionViewModel {
                    self.documentMapDocumentOptionsOptionViewModel.append(uvcovm)
                }
                self.optionTitle["UDCOptionMap.DocumentMapDocumentOptions"] = self.documentMapDocumentOptionsOptionViewModel[0].getText(name: "Name")!.value
                self.fillUpOptionViewModelChilds(uvcOptionViewModel: &self.documentMapDocumentOptionsOptionViewModel)
                for uvcovm in self.documentMapDocumentOptionsOptionViewModel {
                    if uvcovm.level == 1 {
                        self.documentMapDocumentOptionsOptionViewModelList.append(uvcovm)
                    }
                }
                self.documentMapDocumentOptionsOptionViewModel = self.documentMapDocumentOptionsOptionViewModelList
                let uvcDocumentMapRequest = UVCDocumentMapRequest()
                uvcDocumentMapRequest.operationName = "DocumentView.Get.DocumentOptions"
                self.detailViewController!.detailItem = uvcDocumentMapRequest
            }
            self.hideActivityIndicator()
        }
        
    }
    
    
    private func handleInterfaceOptions(neuronRequest: NeuronRequest) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            let jsonUtility = JsonUtility<GetOptionMapResponse>()
            
            let getOptionMapResponse = jsonUtility.convertJsonToAnyObject(json: neuronRequest.neuronOperation.neuronData.text)
            
            if getOptionMapResponse.name == "UDCOptionMap.InterfaceOptions" {
                var tabBarItems = [String]()
                for uvcopvm in getOptionMapResponse.uvcOptionMapViewModel.uvcOptionViewModel {
                    if uvcopvm.idName == "UDCOptionMapNode.Back" {
                        self.optionLabel["UDCOptionMapNode.Back"] = uvcopvm.getText(name: "Name")!.value
                        self.detailViewController!.optionLabel["UDCOptionMapNode.Back"] = self.optionLabel["UDCOptionMapNode.Back"]
                    }
                    if uvcopvm.idName == "UDCOptionMapNode.NotInList" {
                        self.optionLabel["UDCOptionMapNode.NotInList"] = uvcopvm.getText(name: "Name")!.value
                        self.detailViewController!.optionLabel["UDCOptionMapNode.NotInList"] = self.optionLabel["UDCOptionMapNode.NotInList"]
                    }
                    if uvcopvm.idName == "UDCOptionMapNode.SearchForDocument" {
                        self.optionLabel["UDCOptionMapNode.SearchForDocument"] = uvcopvm.getText(name: "Name")!.value
                        self.detailViewController!.optionLabel["UDCOptionMapNode.SearchForDocument"] = self.optionLabel["UDCOptionMapNode.SearchForDocument"]
                    }
                    if uvcopvm.idName == "UDCOptionMapNode.Cancel" {
                        self.optionLabel["UDCOptionMapNode.Cancel"] = uvcopvm.getText(name: "Name")!.value
                        self.detailViewController!.optionLabel["UDCOptionMapNode.Cancel"] = self.optionLabel["UDCOptionMapNode.Cancel"]
                    }
                    if uvcopvm.idName == "UDCOptionMapNode.Document" {
                        self.detailViewController!.optionLabel["UDCOptionMapNode.Document"] = uvcopvm.getText(name: "Name")!.value
                        tabBarItems.append(uvcopvm.getText(name: "Name")!.value)
                    }
//                    if uvcopvm.idName == "UDCOptionMapNode.Analytics" {
//                        self.detailViewController!.optionLabel["UDCOptionMapNode.Analytics"] = uvcopvm.getText(name: "Name")!.value
//                        tabBarItems.append(uvcopvm.getText(name: "Name")!.value)
//                    }
                    if uvcopvm.idName == "UDCOptionMapNode.Done" {
                        self.optionLabel["UDCOptionMapNode.Done"] = uvcopvm.getText(name: "Name")!.value
                        self.detailViewController!.optionLabel["UDCOptionMapNode.Done"] = self.optionLabel["UDCOptionMapNode.Done"]
                    }
                    if uvcopvm.idName == "UDCOptionMapNode.Edit" {
                        self.optionLabel["UDCOptionMapNode.Edit"] = uvcopvm.getText(name: "Name")!.value
                        self.detailViewController!.optionLabel["UDCOptionMapNode.Edit"] = self.optionLabel["UDCOptionMapNode.Edit"]
                    }
                    if uvcopvm.idName == "UDCOptionMapNode.Tool" {
                        self.optionLabel["UDCOptionMapNode.Tool"] = uvcopvm.getText(name: "Name")!.value
                        self.detailViewController!.optionLabel["UDCOptionMapNode.Tool"] = self.optionLabel["UDCOptionMapNode.Tool"]
                    }
                    if uvcopvm.idName == "UDCOptionMapNode.View" {
                        self.optionLabel["UDCOptionMapNode.View"] = uvcopvm.getText(name: "Name")!.value
                        self.detailViewController!.optionLabel["UDCOptionMapNode.View"] = self.optionLabel["UDCOptionMapNode.View"]
                    }
                    if uvcopvm.idName == "UDCOptionMapNode.Format" {
                        self.optionLabel["UDCOptionMapNode.Format"] = uvcopvm.getText(name: "Name")!.value
                        self.detailViewController!.optionLabel["UDCOptionMapNode.Format"] = self.optionLabel["UDCOptionMapNode.Format"]
                    }
                    if uvcopvm.idName == "UDCOptionMapNode.Select" {
                        self.optionLabel["UDCOptionMapNode.Select"] = uvcopvm.getText(name: "Name")!.value
                        self.detailViewController!.optionLabel["UDCOptionMapNode.Select"] = self.optionLabel["UDCOptionMapNode.Select"]
                    }
                    if uvcopvm.idName == "UDCOptionMapNode.Delete" {
                        self.optionLabel["UDCOptionMapNode.Delete"] = uvcopvm.getText(name: "Name")!.value
                        self.detailViewController!.optionLabel["UDCOptionMapNode.Delete"] = self.optionLabel["UDCOptionMapNode.Delete"]
                    }
                    
                }
                self.detailViewController?.setTabBarItems(item: tabBarItems)
                let getDocumentMapRequest = GetDocumentMapRequest()
                self.getDocumentMap(getDocumentMapRequest: getDocumentMapRequest)
            }
            self.hideActivityIndicator()
        }
        
    }
    
    func showPopover(category: String, uvcOptionViewModel: [UVCOptionViewModel]?, width: Int, height: Int, sender: Any?, delegate: UIPopoverPresentationControllerDelegate, optionDelegate: OptionViewControllerDelegate, goToOption: String, isDismissedAutomatically: Bool, optionViewControllerName: String, rightButton: [String]) {
        currentOptionCategory = category
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navigationController = storyboard.instantiateViewController(
            withIdentifier: "OptionNavigationController") as! UINavigationController
        // Use the popover presentation style for your view controller.
        navigationController.modalPresentationStyle = .popover
        let popoverViewController = navigationController.viewControllers[0] as! OptionViewController
        
        //        OptionViewController.optionViewControllers[optionViewControllerName] = popoverViewController
        popoverViewController.delegate = optionDelegate
        popoverViewController.goToPath = goToOption
        // Specify the anchor point for the popover.
        var heightLocal = height
        navigationController.popoverPresentationController!.delegate = delegate
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            navigationController.popoverPresentationController!.permittedArrowDirections = [.down, .up, .right, .left]
        } else {
            navigationController.popoverPresentationController!.permittedArrowDirections = [.down, .up]
        }
        if sender is UIBarButtonItem {
            if delegate is DetailViewController {
                navigationController.popoverPresentationController!.barButtonItem = navigationItem.rightBarButtonItem
            } else {
                navigationController.popoverPresentationController!.barButtonItem  = (sender as! UIBarButtonItem)
            }
        } else if sender is UIButton {
            let uiButton = (sender as! UIButton)
            navigationController.popoverPresentationController!.sourceRect = uiButton.bounds
            navigationController.popoverPresentationController?.sourceView = uiButton
        } else if sender is UITextField {
            let uiTextField = (sender as! UITextField)
            navigationController.popoverPresentationController!.sourceRect = uiTextField.bounds
            navigationController.popoverPresentationController?.sourceView = uiTextField
        } else if sender is UIView {
            let uiView = (sender as! UIView)
            navigationController.popoverPresentationController!.sourceRect = uiView.bounds
            navigationController.popoverPresentationController?.sourceView = uiView
        }
        let uvcOptionView = UVCOptionView()
        uvcOptionView.width = width
        uvcOptionView.height = heightLocal
        uvcOptionView.title = category
        uvcOptionView.rightButton = rightButton
        uvcOptionView.optionLabel["UDCOptionMapNode.Back"] = optionLabel["UDCOptionMapNode.Back"]!
        uvcOptionView.optionLabel["UDCOptionMapNode.Cancel"] = optionLabel["UDCOptionMapNode.Cancel"]!
        uvcOptionView.uvcOptionViewModelList.append(contentsOf: uvcOptionViewModel!)
        uvcOptionView.uvcOptionViewModel.append(contentsOf:
            uvcOptionViewModel!)
        popoverViewController.model = uvcOptionView
        popoverViewController.isModalInPopover = !isDismissedAutomatically
        // Present the view controller (in a popover).
        self.dismiss(animated: true) {
            self.present(navigationController, animated: true, completion: self.popOverLoadingCompleted)
        }
    }
    
    private func popOverLoadingCompleted() {
        
    }
    
    private func fillUpOptionViewModelChilds(uvcOptionViewModel: inout [UVCOptionViewModel]) {
        for uvcovm in uvcOptionViewModel {
            if uvcovm.childrenId.count > 0 {
                let uvcovmChilds = getChildrens(uvcOptionViewModelArray: uvcOptionViewModel, childrenId: uvcovm.childrenId)
                uvcovm.parentId.append(uvcovm._id)
                for child in uvcovmChilds {
                    uvcovm.children.append(child)
                }
                
            }
        }
        
    }
    
    private func fillUpDocumentMapOptionsChilds() {
        for uvcovm in documentMapOptionsOptionViewModel {
            if uvcovm.childrenId.count > 0 {
                let uvcovmChilds = getChildrens(uvcOptionViewModelArray: documentMapOptionsOptionViewModel, childrenId: uvcovm.childrenId)
                uvcovm.parentId.append(uvcovm._id)
                for child in uvcovmChilds {
                    uvcovm.children.append(child)
                }
                
            }
        }
        
    }
    
    private func getChildrens(uvcOptionViewModelArray: [UVCOptionViewModel], childrenId: [String]) -> [UVCOptionViewModel] {
        var uvcOptionViewModelReturn = [UVCOptionViewModel]()
        for children in childrenId {
            for uvcovm in uvcOptionViewModelArray {
                if uvcovm._id == children {
                    uvcOptionViewModelReturn.append(uvcovm)
                }
            }
        }
        
        return uvcOptionViewModelReturn
    }
    
    // Update the ui node list with new id for the add operation
    private func updateId(uvcTreeNodeArray: inout [UVCTreeNode], id: String, newId: String) {
        
        for uvctn in uvcTreeNodeArray {
            if uvctn._id == id {
                print("Updated from \(uvctn._id) to: \(newId)")
                uvctn._id = newId
                return
            }
            if uvctn.children.count > 0 {
                updateId(uvcTreeNodeArray: &uvctn.children, id: id, newId: newId)
                
            }
        }
    }
    
    private func updateName(uvcTreeNodeArray: inout [UVCTreeNode], id: String, name: String) {
        
        for uvctn in uvcTreeNodeArray {
            if uvctn._id == id {
                print("Updated from \(uvctn.getText(name: "Name")) to: \(name)")
                uvctn.setText(name: "Name", value: name)
                return
            }
            if uvctn.children.count > 0 {
                updateName(uvcTreeNodeArray: &uvctn.children, id: id, name: name)
                
            }
        }
    }
    
    private func handleChangeDocumentMapNode(neuronRequest: NeuronRequest) {
        print("Update done")
        hideActivityIndicator()
        
        
    }
    
    private func handleRemoveDocumentMapNode(neuronRequest: NeuronRequest) {
//        let jsonUtility = JsonUtility<RemoveDocumentMapNodeResponse>()
//        let removeDocumentMapNodeResponse = jsonUtility.convertJsonToAnyObject(json: neuronRequest.neuronOperation.neuronData.text)
//
//        var parentId = ""
//
//        // Get the option list where the item is located and also the parent id
//        var uvctnList = self.getNodeList(uvcTreeNodeArray: &self.uvcTreeNode, id: removeDocumentMapNodeResponse.udcDocumentMapNodeId, parentId: &parentId)
//        var nodeIndex = 0
//        for uvctn1 in uvctnList! {
//            if uvctn1._id == removeDocumentMapNodeResponse.udcDocumentMapNodeId {
//                break
//            }
//            nodeIndex += 1
//        }
//
//        // Remove the item
//        if nodeIndex != -1 {
//            uvctnList?.remove(at: nodeIndex)
//            self.uvcTreeNodeList = uvctnList!
//        }
//
//        self.deleteNode(uvcTreeNodeArray: &self.uvcTreeNode, parentId: parentId, deleteIndex: nodeIndex)
//        var deleteIndex = 0
//
//        // Find the index of the removed item in the model
//        for (deleteInd, udcdmn) in self.udcDocumentMapNode!.enumerated() {
//            if udcdmn._id == removeDocumentMapNodeResponse.udcDocumentMapNodeId {
//                print("Deleted from document map node")
//                deleteIndex = deleteInd
//                break
//            }
//        }
//
//        // Remove from mdoel
//        self.udcDocumentMapNode!.remove(at: deleteIndex)
//
//        print("Remove done")
//        self.collectionView?.reloadData()
//        hideActivityIndicator()
//
    }
    
    // Handle the add option item operation
    private func handleAddDocumentMapNode(neuronRequest: NeuronRequest) {
//        let jsonUtility = JsonUtility<AddDocumentMapNodeResponse>()
//        let addDocumentMapNodeResponse = jsonUtility.convertJsonToAnyObject(json: neuronRequest.neuronOperation.neuronData.text)
//        // If the current list is containing the old document map node id, then put
//        // the new id
//        for uvctn in uvcTreeNodeList {
//            if uvctn._id == addDocumentMapNodeResponse.oldUdcDocumentMapNodeId {
//                uvctn._id = addDocumentMapNodeResponse.udcDocumentMapNodeId
//            }
//        }
//        // Update the UI node list with the new id
//        updateId(uvcTreeNodeArray: &uvcTreeNode, id: addDocumentMapNodeResponse.oldUdcDocumentMapNodeId, newId: addDocumentMapNodeResponse.udcDocumentMapNodeId)
//        hideActivityIndicator()
//        self.collectionView?.reloadData()
    }
    
    private func handleGetDocumentMapByPath(neuronRequest: NeuronRequest) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            self.hideActivityIndicator()
            let jsonUtility = JsonUtility<GetDocumentMapByPathResponse>()
            let getDocumentMapByPathResponse = jsonUtility.convertJsonToAnyObject(json: neuronRequest.neuronOperation.neuronData.text)
            let uvcNavigationViewModel = getDocumentMapByPathResponse.uvcDocumentMapViewModel
            var found = false
            self.addChildren(uvcTreeNodeArray: &self.uvcTreeNode, newNode: uvcNavigationViewModel.uvcTreeNode, path: getDocumentMapByPathResponse.pathIdName.joined(separator: "->"), found: &found)
            self.uvcTreeNodeList.removeAll()
            for uvctn in uvcNavigationViewModel.uvcTreeNode {
                self.uvcTreeNodeList.append(uvctn)
            }
            self.collectionView?.reloadData()
        }
    }
    
    // Handle the get document map operation
    private func handleGetDocument(neuronRequest: NeuronRequest) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            // Put the model and view model in respective places
            let jsonUtility = JsonUtility<GetDocumentMapResponse>()
            let getDocumentMapResponse = jsonUtility.convertJsonToAnyObject(json: neuronRequest.neuronOperation.neuronData.text)
            if !getDocumentMapResponse.isDynamicMap {
                self.uvcTreeNode.removeAll()
                self.uvcTreeNodeList.removeAll()
                self.currentPathText.removeAll()
                self.rootViewTitle = getDocumentMapResponse.uvcDocumentMapViewModel.uvcTreeNode[0].getText(name: "Name")!.value
                self.viewTitle = self.rootViewTitle
                self.currentPathText.append(self.viewTitle)
                let uvcNavigationViewModel = getDocumentMapResponse.uvcDocumentMapViewModel
                self.uvcTreeNode = uvcNavigationViewModel.uvcTreeNode
                // Fill up childrens for each children id to form a tree
                self.fillUpChilds()
                // Only the level 0 add to the current list
                for uvctn in self.uvcTreeNode {
                    if uvctn.level == 1 {
                        self.uvcTreeNodeList.append(uvctn)
                    }
                }
                // Update the ui list to hold the level 0
                self.uvcTreeNode = self.uvcTreeNodeList
                self.uvcDocumentMapViewTemplateType = uvcNavigationViewModel.uvcDocumentMapViewTemplateType
                self.navigationItem.titleView = nil
                self.treeLevel = 1
                self.handleBackButton()
                self.getOptionMap()
                self.collectionView?.reloadData()
                self.hideActivityIndicator()
            } else {
                self.hideActivityIndicator()
                if !getDocumentMapResponse.isReferenceDocument {
                    let uvcNavigationViewModel = getDocumentMapResponse.uvcDocumentMapViewModel
                    if !self.isSearchActive {
                        self.fillTreeNodeChilds(uvcTreeNode: &uvcNavigationViewModel.uvcTreeNode)
                        var uvcTreeNodeLocal = [UVCTreeNode]()
                        for (uvctnIndex, uvctn) in uvcNavigationViewModel.uvcTreeNode.enumerated() {
                            if uvctn.level == self.treeLevel {
                                uvcTreeNodeLocal.append(uvctn)
                            }
                        }
                        
                        var found = false
                        self.addChildren(uvcTreeNodeArray: &self.uvcTreeNode, newNode: uvcTreeNodeLocal, path: getDocumentMapResponse.pathIdName!.joined(separator: "->"), found: &found)
                        self.uvcTreeNodeList.removeAll()
                        for uvctn in uvcNavigationViewModel.uvcTreeNode {
                            if uvctn.level == self.treeLevel {
                                self.uvcTreeNodeList.append(uvctn)
                            }
                        }
                    } else {
                        self.fillTreeNodeChilds(uvcTreeNode: &uvcNavigationViewModel.uvcTreeNode)
                        var uvcTreeNodeLocal = [UVCTreeNode]()
                        for (uvctnIndex, uvctn) in uvcNavigationViewModel.uvcTreeNode.enumerated() {
                            if uvctn.level == self.treeLevelSearch {
                                uvcTreeNodeLocal.append(uvctn)
                            }
                        }
                        
                        var found = false
                        self.addChildren(uvcTreeNodeArray: &self.uvcTreeNodeSearch, newNode: uvcTreeNodeLocal, path: getDocumentMapResponse.pathIdName!.joined(separator: "->"), found: &found)
                        self.uvcTreeNodeSearchList.removeAll()
                        for uvctn in uvcNavigationViewModel.uvcTreeNode {
                            if uvctn.level == self.treeLevelSearch {
                                self.uvcTreeNodeSearchList.append(uvctn)
                            }
                        }
                    }
                    self.handleBackButton()
                    self.collectionView?.reloadData()
                } else {
                    self.askDetailToShowDocument(uvctn: getDocumentMapResponse.uvcDocumentMapViewModel.uvcTreeNode[0], isEditable: false)
                }
            }
        }
    }
    
    
    private func fillTreeNodeChilds(uvcTreeNode: inout [UVCTreeNode]) {
        var startWithIndex = 0
        for uvcovm in uvcTreeNode {
            if uvcovm.childrenId.count > 0 {
                let uvcovmChilds = getChildrens(uvcTreeNodeArray: uvcTreeNode, childrenId: uvcovm.childrenId)
                uvcovm.parentId.append(uvcovm._id)
                for child in uvcovmChilds {
                    uvcovm.children.append(child)
                }
                
            }
        }
        
    }
    
    
    public override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    public override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if isSearchActive {
            return uvcTreeNodeSearchList.count
        } else {
            return uvcTreeNodeList.count
        }
    }
    
    // Get the children for the specified node id
    private func getTreeChildForId(uvcTreeNodeArray: [UVCTreeNode], childId: String, level: Int) -> [UVCTreeNode]? {
        
        for uvctn in uvcTreeNodeArray {
            if uvctn._id == childId && uvctn.level == level {
                return uvctn.children
            }
            if uvctn.children.count > 0 {
                let uvcTreeNodeArrayReturn = getTreeChildForId(uvcTreeNodeArray: uvctn.children, childId: childId, level: level)
                if uvcTreeNodeArrayReturn != nil {
                    return uvcTreeNodeArrayReturn
                }
            }
        }
        
        return nil
    }
    
    // Get childrens for the specified children id
    private func getChildrens(uvcTreeNodeArray: [UVCTreeNode], childrenId: [String]) -> [UVCTreeNode] {
        var uvcTreeNodeReturn = [UVCTreeNode]()
        for children in childrenId {
            for (uvtnIndex, uvtn) in uvcTreeNodeArray.enumerated() {
                if uvtn._id == children {
                    uvcTreeNodeReturn.append(uvtn)
                }
            }
        }
        
        return uvcTreeNodeReturn
    }
    
    private func removeChildrensIfIsChidlrenOnDemandLoading(uvcTreeNodeArray: [UVCTreeNode], path: String) {
        for uvctn in uvcTreeNodeArray {
            if uvctn.pathIdName.joined(separator: "->").hasSuffix(path) {
                if uvctn.isChidlrenOnDemandLoading {
                    uvctn.childrenId.removeAll()
                    uvctn.children.removeAll()
                }
                return
            }
            if uvctn.children.count > 0 {
                removeChildrensIfIsChidlrenOnDemandLoading(uvcTreeNodeArray: uvctn.children, path: path)
            }
        }
    }
    
    
    // Get the parent list for the specfied path
    private func getTreeParentForPath(uvcTreeNodeArray: [UVCTreeNode], path: String, level: Int) -> [UVCTreeNode]? {
        
        for uvctn in uvcTreeNodeArray {
            if uvctn.pathIdName.joined(separator: "->").hasSuffix(path) && uvctn.level == level {
                if uvctn.isChidlrenOnDemandLoading {
                    uvctn.childrenId.removeAll()
                    uvctn.children.removeAll()
                }
                return uvcTreeNodeArray
            }
            if uvctn.children.count > 0 {
                let uvcTreeNodeArrayReturn =  getTreeParentForPath(uvcTreeNodeArray: uvctn.children, path: path, level: level)
                if uvcTreeNodeArrayReturn != nil {
                    return uvcTreeNodeArrayReturn
                }
            }
        }
        
        return nil
    }
    
    public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! NavigationViewCell
        
        // Configure the cell
        
        do {
            // Diplay the cell based on the current document map view template (name, name and description, etc.,)
            if !isSearchActive {
                let cellTreeNode = uvcTreeNodeList[indexPath.row]
                try cell.configure(with: cellTreeNode, uvcNavigationTemplateType: uvcDocumentMapViewTemplateType, isEditableMode: cellTreeNode.isEditable)
            } else {
                let cellTreeNode = uvcTreeNodeSearchList[indexPath.row]
                try cell.configure(with: cellTreeNode, uvcNavigationTemplateType: uvcDocumentMapViewTemplateType, isEditableMode: cellTreeNode.isEditable)
            }
        } catch {
            print(error)
        }
        cell.index = indexPath.row
        cell.delegate = self
        
        return cell
    }
    
    
    public func optionViewControllerSearch(idName: String, searchText: String) {
    }
    
    public func optionViewControllerLoadingCompleted() {
        
    }
    
    public func optionViewControllerServerResponsded(response: Any) -> UVCOptionViewRequest {
        return UVCOptionViewRequest()
    }
    public func optionViewControllerDismissed() {
        
    }
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty && isSearchActive {
            self.searchText = ""
            self.viewTitle = rootViewTitle
            isSearchActive = false
            handleBackButton()
            self.collectionView.reloadData()
        } else {
            isSearchActive = true
        }
    }
    
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.text = searchText
    }
    
    public func updateSearchResults(for searchController: UISearchController) {
        
    }
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
    }
   
  
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        showActivityIndicator()
        searchText = searchBar.text!
        let documentMapSearchDocumentRequest = DocumentMapSearchDocumentRequest()
        if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            documentMapSearchDocumentRequest.text = searchText.trimmingCharacters(in: .whitespaces)
        }
        documentMapSearchDocumentRequest.treeLevel = 1
        
        documentMapSearchDocumentRequest.uvcDocumentMapViewTemplateType = "UVCDocumentMapViewTemplateType.NameDescriptionPathPicture"
        let callBrainControllerNeuron = CallBrainControllerNeuron()
        callBrainControllerNeuron.searchDocument(sourceName: String(describing: MasterViewController.self), language: String((searchBar.textInputMode!.primaryLanguage?.split(separator: "-")[0])!), documentMapSearchDocumentRequest: documentMapSearchDocumentRequest, neuronName: "DocumentMapNeuron")
    }
  
    
    private func handleSearchDocument(neuronRequest: NeuronRequest) {
        let jsonUtility = JsonUtility<DocumentMapSearchDocumentResponse>()
        
        let documentMapSearchDocumentResponse = jsonUtility.convertJsonToAnyObject(json: neuronRequest.neuronOperation.neuronData.text)
        self.uvcTreeNodeSearch.removeAll()
        self.uvcTreeNodeSearchList.removeAll()
        self.currentPathTextSearch.removeAll()
        self.rootViewTitleSearch = documentMapSearchDocumentResponse.uvcDocumentMapViewModel[0].uvcTreeNode[0].getText(name: "Name")!.value
        self.viewTitle = self.rootViewTitleSearch
        self.currentPathTextSearch.append(self.viewTitle)
        var uvcTreeNodeArray = [[UVCTreeNode]]()
        var uvcTreeNodeListLocal = [UVCTreeNode]()
        for (uvcNavigationViewModelIndex, uvcNavigationViewModel) in documentMapSearchDocumentResponse.uvcDocumentMapViewModel.enumerated() {
            uvcTreeNodeArray.append(uvcNavigationViewModel.uvcTreeNode)
            // Fill up childrens for each children id to form a tree
            self.fillUpChildsSearch(uvcTreeNodeArray: &uvcTreeNodeArray[uvcNavigationViewModelIndex])
            // Only the level 0 add to the current list
            for uvctn in uvcTreeNodeArray[uvcNavigationViewModelIndex] {
                if uvctn.level == 1 {
                    uvcTreeNodeListLocal.append(uvctn)
                }
            }
            // Update the ui list to hold the level 0
            uvcTreeNodeArray[uvcNavigationViewModelIndex] = uvcTreeNodeListLocal
            uvcTreeNodeListLocal.removeAll()
        }
        for uvctn in uvcTreeNodeArray {
            self.uvcTreeNodeSearch.append(contentsOf: uvctn)
            self.uvcTreeNodeSearchList.append(contentsOf: uvctn)
        }
        self.uvcDocumentMapViewTemplateType = documentMapSearchDocumentResponse.uvcDocumentMapViewModel[0].uvcDocumentMapViewTemplateType
        self.navigationItem.titleView = nil
        self.handleBackButton()
        self.collectionView?.reloadData()
        self.hideActivityIndicator()
    }
    
    private func fillUpChildsSearch(uvcTreeNodeArray: inout [UVCTreeNode]) {
        var startWithIndex = 0
        for uvctn in uvcTreeNodeArray {
            if uvctn.childrenId.count > 0 {
                let uvctnChilds = getChildrens(uvcTreeNodeArray: uvcTreeNodeArray, childrenId: uvctn.childrenId)
                uvctn.parentId.append(uvctn._id)
                for child in uvctnChilds {
                    uvctn.children.append(child)
                }
                
            }
        }
        
    }
}

