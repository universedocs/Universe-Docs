//
//  DetailViewController.swift
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
import UDocsDocumentGraphNeuronModel
import UDocsDocumentItemNeuronModel
import UDocsDocumentMapNeuronModel
import UDocsNeuronModel
import UDocsPhotoNeuronModel
import UDocsDocumentModel
import UDocsGrammarNeuronModel
import UDocsOptionMapNeuronModel
import PDFKit
import UDocsUtility
import AVKit
import UDocsDocumentUtility

private let reuseIdentifier = "DetailViewCell"
private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
extension UIView {
    func exportAsPdfFromView() -> String {
        
        let pdfPageFrame = self.bounds
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, pdfPageFrame, nil)
        UIGraphicsBeginPDFPageWithInfo(pdfPageFrame, nil)
        guard let pdfContext = UIGraphicsGetCurrentContext() else { return "" }
        self.layer.render(in: pdfContext)
        UIGraphicsEndPDFContext()
        return self.saveViewPdf(data: pdfData)
        
    }
    
    // Save pdf file in document directory
    func saveViewPdf(data: NSMutableData) -> String {
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docDirectoryPath = paths[0]
        let pdfPath = docDirectoryPath.appendingPathComponent("viewPdf.pdf")
        if data.write(to: pdfPath, atomically: true) {
            return pdfPath.path
        } else {
            return ""
        }
    }
    func asImage() -> UIImage? {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0)
            defer { UIGraphicsEndImageContext() }
            guard let currentContext = UIGraphicsGetCurrentContext() else {
                return nil
            }
            self.layer.render(in: currentContext)
            return UIGraphicsGetImageFromCurrentImageContext()
        }
    }
    
    func saveToFile(fileName: String) {
        let image = self.asImage()
        if let data = image!.pngData() {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let docDirectoryPath = paths[0]
            let fullFilePath = docDirectoryPath.appendingPathComponent(fileName)
            print("Image stored in path: \(fullFilePath)")
            try? data.write(to: fullFilePath)
        }
    }
}
class DetailViewController: UICollectionViewController, UIPopoverPresentationControllerDelegate, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    public var aviAudioPlayer : AVAudioPlayer?
    // Models
    public var uvcDocumentGraphModel = [UVCDocumentGraphModel]()
    public var uvcDocumentGraphModelList = [UVCDocumentGraphModel]()
    public var uvcOptionViewModel = [UVCOptionViewModel]()
    public var uvcOptionViewModelList = [UVCOptionViewModel]()
    public var documentItemOptionViewModel = [UVCOptionViewModel]()
    public var documentItemOptionViewModelList = [UVCOptionViewModel]()
    public var documentOptionsOptionViewModel = [UVCOptionViewModel]()
    public var documentOptionsOptionViewModelList = [UVCOptionViewModel]()
    public var objectControllerOptionViewModel = [UVCOptionViewModel]()
    public var objectControllerOptionViewModelList = [UVCOptionViewModel]()
    public var viewConfigurationOptionViewModelList = [UVCOptionViewModel]()
    public var viewTypeConfigurationDictionary = [String: [UVCOptionViewModel]]()
    public var photoOptionViewModel = [UVCOptionViewModel]()
    public var photoOptionViewModelList = [UVCOptionViewModel]()
    public var categoryOptionsOptionViewModel = [UVCOptionViewModel]()
    public var categoryOptionsOptionViewModelList = [UVCOptionViewModel]()
    public var categoryOptionsDictionary = [String: [UVCOptionViewModel]]()
    
    // Controllers
    public var optionViewNavigationController: UINavigationController?
    public var searchBoxViewController = UVCViewController()
    
    // Dictionaries holding titles and labels in respective language
    public var optionTitle = [String: String]()
    public var optionLabel = [String: String]()
    
    // Document informations
    public var documentId: String = ""
    public var documentIdName: String = ""
    public var documentName: String = ""
    public var documentEnglishName: String = ""
    public var documentItemSearchInProgress: Bool = false
    
    // Current location indexes
    public var currentLevel = 0
    public var currentItemIndex = 0
    public var currentNodeIndex = 0
    public var currentSentenceIndex = 0
    
    // UI Controls
    public var documentOptionsButton: UIButton?
    public var documetSentenceSearchBox: UITextField?
    
    // View Controller
    private var uvcViewController = UVCDocumentViewController()
    
    // Object to access master view controller
    public var masterViewController: MasterViewController?
    
    // Other variables
    public var cellWidth: Int = 0
    private var activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
    private var activityIndicatorTitle: String = "Document"
    public var neuronName = ""
    public var currentOptionCategory: String = ""
    public var categoryIndex: Int = 0
    public var focusRequiredAferReload: Bool = false
    private var currentOperationData = [String: [String: Any]]()
    private var currentOperationName: String = ""
    public var currentOperationNameBeforeGettingPhoto: String = ""
    public var currentViewItemPathIdName = [String]()
    private var objectControllerToolbar = UIToolbar()
    public var objectControllerEditMode: Bool = false
    public var isOptionPopoverActive: Bool = false;
    public var viewConfigPathIdName = [String]()
    public var uvcViewItemType: String = "UVCViewItemType.Text"
    public var objectEditMode: Bool = false
    public var groupUVCViewItemType: String = ""
    public var udcViewItemName: String = ""
    public var udcViewItemId: String = ""
    public var viewPathIdName = [String]()
    public var toolbarView: UVCToolbarView?
    public var toolbarViewObjects = [UIView]()
    public var objectControllerView: UVCToolbarView?
    private var uiImageView: UIImageView?
    private var uvcPhoto: UVCPhoto?
    public var isEditableMode: Bool = false
    public var documentMapNodeId: String = ""
    public var documentMapPathIdName = [String]()
    public var photoIdArray = [String]()
    public var photoNameArray = [String]()
    public var photoIsOptionArray = [Bool]()
    public var photoChange: Bool = false
    //    private var searchTextField = UITextField(frame: CGRect(x: 0,y: 0,width: 150,height: 30))
    public var currentPhotoId: String = ""
    public var photoLoadingDone: Bool = false
    private var isAlertOkCancel: Bool = false
    public var isParentNode: Bool = false
    public var searchText: String = ""
    public var documentTitle: String = ""
    public var isSearchBoxVisible: Bool = true
    public var isDocumentItemEditable: Bool = false
    public var isLetterSpaceLocked: Bool = false
    public var isDoubleQuoteLocked: Bool = false
    public var isSearchEnabled: Bool = true
    public var isPopup: Bool = false
    public var popupUdcDocumentTypeIdName: String = ""
    public var parentDetailViewController: DetailViewController?
    public var sourceName: String = "DetailViewController"
    public static var sourceNameTabItemName = [String: String]()
    //    public var isNonSearchEdited: Bool = true
    //    public var isTextEditedBefore: Bool = false
    
    public var toolbar: UIToolbar?
    var alertController:UIAlertController?
 
    func deleteFile(fileName: String) throws {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                    let docDirectoryPath = paths[0]
        let fullFilePath = docDirectoryPath.appendingPathComponent(fileName)
        try FileManager.default.removeItem(at: fullFilePath)
    }
    
    
    @objc func optionButtonPressed(_ sender: Any) {
        uvcViewController.optionButtonPressed(sender)
    }
    
    
    public func addTab(title: String, documentId: String, udcDocumentTypeIdName: String) {
        if CallBrainControllerNeuron.tabNotificationCount > 10 {
            showAlertView(message: "Maximum Tab Reached!")
            return
        }
        let floatingMapCollectionView = DetailViewController(collectionViewLayout: UICollectionViewFlowLayout())
        floatingMapCollectionView.sourceName = "TabNotification\(CallBrainControllerNeuron.tabNotificationCount)"
        DetailViewController.sourceNameTabItemName[floatingMapCollectionView.sourceName] = title
        floatingMapCollectionView.isEditableMode = true
        floatingMapCollectionView.optionLabel = optionLabel
        floatingMapCollectionView.masterViewController = masterViewController
        floatingMapCollectionView.masterViewController?.detailViewController = floatingMapCollectionView
        floatingMapCollectionView.parentDetailViewController = self
        floatingMapCollectionView.neuronName = "DocumentGraphNeuron"
        floatingMapCollectionView.isPopup = true
        floatingMapCollectionView.documentId = documentId
        floatingMapCollectionView.popupUdcDocumentTypeIdName = udcDocumentTypeIdName
        floatingMapCollectionView.collectionView.backgroundColor = UIColor { traitCollection in
            // 2
            switch traitCollection.userInterfaceStyle {
            case .dark:
              // 3
              return UIColor(white: 0.1, alpha: 1.0)
//                return UIColor.black
            default:
              // 4
                return UIColor.white
            }
        }
        floatingMapCollectionView.preferredContentSize = CGSize(width: 600, height: 300)
        
        let optionButton = UIBarButtonItem(title: "UDCOptionMapNode.Done", style: .plain, target: self, action: #selector(optionButtonPressed(_:)))
        #if targetEnvironment(macCatalyst)
        //            tabBarController?.tabBar.items![index].
        //            tabBarController?.tabBar.items![index].setBadgeTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        //            tabBarController?.tabBar.items![index].setBadgeTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Helvetica-Bold", size: 17)!], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Helvetica-Bold", size: 17)!], for: .selected)
        #endif
        floatingMapCollectionView.navigationController?.navigationItem.rightBarButtonItems?.append(optionButton)
        floatingMapCollectionView.navigationController?.navigationItem.title = "Getting Document..."
        let navController = UINavigationController(rootViewController: floatingMapCollectionView)
        navController.modalPresentationStyle = .overCurrentContext
        navController.modalTransitionStyle = .crossDissolve
        let item = UITabBarItem()
        item.title = title.capitalized
        #if targetEnvironment(macCatalyst)
        item.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Helvetica-Bold",
        size: CGFloat( UVCTextSizeType.Regular.size)), NSAttributedString.Key.foregroundColor: UIColor.gray], for: .normal)
        item.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Helvetica-Bold", size: CGFloat( UVCTextSizeType.Regular.size)), NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        #endif
        navController.tabBarItem = item
        tabBarController!.viewControllers?.append(navController)
        tabBarController!.selectedIndex = tabBarController!.viewControllers!.count - 1
    }
    
    public func removeTab(name: String) {
        var removeIndex = -1
        for (vcIndex, vc) in tabBarController!.viewControllers!.enumerated() {
            if vc.tabBarItem.title == name {
                removeIndex = vcIndex
                break
            }
        }
        if removeIndex > 0 {
            tabBarController!.viewControllers!.remove(at: removeIndex)
            DetailViewController.sourceNameTabItemName.removeValue(forKey: name)
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setDocumentTitle(title: getDocumentTitle())
    }
    let uiTextView = UITextView()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        
        
       
        setDocumentTitle(title: getDocumentTitle())
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        optionViewNavigationController = storyboard.instantiateViewController(
            withIdentifier: "OptionNavigationController") as! UINavigationController
        
        // Register cell classes
        self.collectionView!.register(DetailViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.delegate = self
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        layout.itemSize = CGSize(width: width / 2, height: width / 2)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        self.collectionView!.collectionViewLayout = layout
        
        if isPopup {
            NotificationCenter.default.addObserver(self, selector: #selector(brainControllerNeuronResponse(_:)), name:
                CallBrainControllerNeuron.sourceNotificationMap[sourceName], object: nil)
            CallBrainControllerNeuron.tabNotificationCount += 1
            setRightButton(name: ["UDCOptionMapNode.Done"])
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(brainControllerNeuronResponse(_:)), name: .detailViewControllerNotification, object: nil)
            setRightButton(name: ["UDCOptionMapNode.Elipsis"])
        }
      
        uvcViewController.detailViewController = self
        uvcViewController.configureView()
        collectionView.backgroundColor = UIColor { traitCollection in
            // 2
            switch traitCollection.userInterfaceStyle {
            case .dark:
              // 3
              return UIColor(white: 0.1, alpha: 1.0)
//                return UIColor.black
            default:
              // 4
                return UIColor.white
            }
        }
        
    }
    
    private func setupNavigationBar() {
        self.toolbar = UIToolbar(frame: CGRect(x: 0,y: 20,width: self.view.frame.width, height: 100))
        self.toolbar?.isUserInteractionEnabled = true
        self.toolbar!.sizeToFit()
        self.applyEcxtendedNavigationBar()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(toolbarItemViewPressed(tapGestureRecognizer:)))
        
        let icon = UIImageView(frame: CGRect(x: 0, y: 0, width: 10, height: 30))
        icon.image = UIImage(named: "ObjectController")
        icon.contentMode = .scaleAspectFit
        //        icon.backgroundColor = .white
        let text = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        //        text.backgroundColor = .white
        text.text = "Object Controller"
        text.textColor = self.toolbar!.tintColor
        text.textAlignment = .center
        text.numberOfLines = 4
        icon.heightAnchor.constraint(equalToConstant: 30).isActive = true;
        text.heightAnchor.constraint(equalToConstant: 70).isActive = true;
        
        let icon1 = UIImageView(frame: CGRect(x: 0, y: 0, width: 10, height: 100))
        icon1.image = UIImage(named: "Help")
        icon1.contentMode = .scaleAspectFit
        //        icon1.backgroundColor = .white
        let text1 = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        //        text1.backgroundColor = .white
        text1.text = "Help"
        text1.textAlignment = .center
        text1.textColor = self.toolbar!.tintColor
        text1.numberOfLines = 4
        icon1.heightAnchor.constraint(equalToConstant: 30).isActive = true;
        text1.heightAnchor.constraint(equalToConstant: 70).isActive = true;
        
        let icon2 = UIImageView(frame: CGRect(x: 0, y: 0, width: 10, height: 100))
        icon2.image = UIImage(named: "LeftDirectionArrow")
        icon2.contentMode = .scaleAspectFit
        //        icon2.backgroundColor = .white
        let text3 = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        //        text3.backgroundColor = .white
        text3.text = "View Controller"
        text3.textAlignment = .center
        text3.textColor = self.toolbar!.tintColor
        text3.numberOfLines = 4
        icon2.heightAnchor.constraint(equalToConstant: 30).isActive = true;
        text3.heightAnchor.constraint(equalToConstant: 70).isActive = true;
        
        let icon3 = UIImageView(frame: CGRect(x: 0, y: 0, width: 10, height: 100))
        icon3.image = UIImage(named: "RightDirectionArrow")
        icon3.contentMode = .scaleAspectFit
        //        icon3.backgroundColor = .white
        let text2 = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        //        text2.backgroundColor = .white
        text2.text = "Flight Controller"
        text2.textAlignment = .center
        text2.textColor = self.toolbar!.tintColor
        text2.numberOfLines = 4
        icon3.heightAnchor.constraint(equalToConstant: 30).isActive = true;
        text2.heightAnchor.constraint(equalToConstant: 70).isActive = true;
        let icon4 = UIImageView(frame: CGRect(x: 0, y: 0, width: 10, height: 100))
        icon4.image = UIImage(named: "UpDirectionArrow")
        icon4.contentMode = .scaleAspectFit
        //        icon4.backgroundColor = .white
        let text4 = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        //        text4.backgroundColor = .white
        text4.text = "Tight Controller"
        text4.textAlignment = .center
        text4.textColor = self.toolbar!.tintColor
        text4.numberOfLines = 4
        icon4.heightAnchor.constraint(equalToConstant: 30).isActive = true;
        text4.heightAnchor.constraint(equalToConstant: 70).isActive = true;
        
        let stackView = UIStackView(frame: CGRect(x: 0,y: 0,width: 100,height: 100) )
        stackView.distribution = .fillProportionally
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .fill
        stackView.addArrangedSubview(icon)
        stackView.addArrangedSubview(text)
        
        let stackView1 = UIStackView(frame: CGRect(x: 0,y: 0,width: 100,height: 100) )
        stackView1.distribution = .fillProportionally
        stackView1.axis = .vertical
        stackView1.spacing = 0
        stackView1.alignment = .fill
        stackView1.addArrangedSubview(icon1)
        stackView1.addArrangedSubview(text1)
        
        let stackView2 = UIStackView(frame: CGRect(x: 0,y: 0,width: 100,height: 100) )
        stackView2.distribution = .fillProportionally
        stackView2.axis = .vertical
        stackView2.spacing = 0
        stackView2.alignment = .fill
        stackView2.addArrangedSubview(icon2)
        stackView2.addArrangedSubview(text3)
        
        let stackView3 = UIStackView(frame: CGRect(x: 0,y: 0,width: 100,height: 100) )
        stackView3.distribution = .fillProportionally
        stackView3.axis = .vertical
        stackView3.spacing = 0
        stackView3.alignment = .fill
        stackView3.addArrangedSubview(icon3)
        stackView3.addArrangedSubview(text2)
        
        let stackView4 = UIStackView(frame: CGRect(x: 0,y: 0,width: 100,height: 100) )
        stackView4.distribution = .fillProportionally
        stackView4.axis = .vertical
        stackView4.spacing = 0
        stackView4.alignment = .fill
        stackView4.addArrangedSubview(icon4)
        stackView4.addArrangedSubview(text4)
        
        let list = UIView(frame: CGRect(x: 0,y: 0,width:  100,height: 100))
        list.isUserInteractionEnabled = true
        list.addSubview(stackView)
        
        let list2 = UIView(frame: CGRect(x: 0,y: 0,width:  100,height: 100))
        list2.addSubview(stackView1)
        
        let list3 = UIView(frame: CGRect(x: 0,y: 0,width:  100,height: 100))
        list3.addSubview(stackView2)
        
        let list4 = UIView(frame: CGRect(x: 0,y: 0,width:  100,height: 100))
        list4.addSubview(stackView3)
        
        let list5 = UIView(frame: CGRect(x: 0,y: 0,width:  100,height: 100))
        list5.addSubview(stackView4)
        
        let flexibleSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let item = UIBarButtonItem(customView: list)
        //        item.target = self
        //        item.customView!.isUserInteractionEnabled = true
        //        item.customView!.addGestureRecognizer(tapGestureRecognizer)
        //        item.target = self
        //        item.action = #selector(toolbarButtonPressed(sender:))
        let item2 = UIBarButtonItem(customView: list2)
        //        item2.customView!.isUserInteractionEnabled = true
        //        item2.customView!.addGestureRecognizer(tapGestureRecognizer)
        let item3 = UIBarButtonItem(customView: list3)
        let item4 = UIBarButtonItem(customView: list4)
        let item5 = UIBarButtonItem(customView: list5)
        
        
        
        self.toolbar!.setItems([item, item2, item3, item4, item5, flexibleSpace], animated: true)
        self.toolbar!.isUserInteractionEnabled = true
        self.toolbar!.addGestureRecognizer(tapGestureRecognizer)
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            self.navigationItem.titleView = self.toolbar
        } else {
            self.tabBarController!.navigationItem.titleView = self.toolbar
        }
    }
    
    //    @objc private func toolbarButtonPressed(sender: UIBarButtonItem) {
    //        showAlertView(message: "here")
    //    }
    @objc private func toolbarItemViewPressed(tapGestureRecognizer: UITapGestureRecognizer) {
        let toolbarItemView = tapGestureRecognizer.view as! UIView
        var toolbarItemText = ""
        if toolbarItemView is UIStackView {
            let uiLabel = toolbarItemView.subviews[1] as! UILabel
            toolbarItemText = uiLabel.text!
        } else if toolbarItemView is UILabel {
            let uiLabel = toolbarItemView as! UILabel
            toolbarItemText = uiLabel.text!
        } else {
            let uiLabel = toolbarItemView.subviews[0].subviews[1] as! UILabel
            toolbarItemText = uiLabel.text!
        }
        showAlertView(message: toolbarItemText)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        #if !targetEnvironment(macCatalyst)
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            collectionView.contentInset = .zero
        } else {
            collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        collectionView.scrollIndicatorInsets = collectionView.contentInset
        let theAttributes = collectionView.layoutAttributesForItem(at: NSIndexPath(item: currentItemIndex, section: currentNodeIndex) as IndexPath)
        if theAttributes != nil {
            let cellFrameInSuperview = collectionView.convert(theAttributes!.frame, to: collectionView.superview)
            collectionView.scrollRectToVisible(cellFrameInSuperview, animated: true)
        }
        collectionView.scrollToItem(at: IndexPath(item: currentItemIndex,
                                                  section: currentNodeIndex), at: .bottom, animated: true)
        #endif
    }
    
    @objc public func textFieldDidBeginEditing(_ textField: UITextField) {
        uvcViewController.searchBoxEvent(uvcViewItemType: "UVCViewItemType.Text", eventName: "UVCViewItemEvent.Word.Editable.BeginEditing", uiObject: textField)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        uvcViewController.searchBoxEvent(uvcViewItemType: "UVCViewItemType.Text", eventName: "UVCViewItemEvent.Word.Editable.DidChange", uiObject: textField)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        uvcViewController.searchBoxEvent(uvcViewItemType: "UVCViewItemType.Text", eventName: "UVCViewItemEvent.Word.Editable.ReturnKeyPressed", uiObject: textField)
        return true
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        //        self.optionViewController?.resetValues()
        //
        //        self.optionViewController = nil
        
        //        self.optionViewNavigationController = nil
        optionViewNavigationController = nil
    }
    //    @objc public func imageTapped(_ tapGestureRecognizer: UITapGestureRecognizer) {
    //        let vc = UIImagePickerController()
    //        vc.sourceType = .camera
    //        vc.allowsEditing = true
    //        vc.delegate = self
    //        self.present(vc, animated: true)
    //    }
    public func showPhotoPicker(sourceType: UIImagePickerController.SourceType, uiImageView: UIImageView, uvcPhoto: UVCPhoto) {
        //        let documentGraphGetPhotoRequest = DocumentGraphGetPhotoRequest()
        //        documentGraphGetPhotoRequest.udcPhotoDataId = "5d5427864632a55b3d405908"
        //        setCurrentOperation(name: "PhotoNeuron.Get.Item.Photo")
        //        setCurrentOperationData(data: [getCurrentOperation(): [
        //            "language": ApplicationSetting.DocumentLanguage!,
        //            "documentGraphGetPhotoRequest": documentGraphGetPhotoRequest]])
        //        sendRequest()
        //        optionViewController!.dismiss(animated: true, completion: nil)
        
        self.uiImageView = uiImageView
        self.uvcPhoto = uvcPhoto
        let photoPicker = UIImagePickerController()
        photoPicker.sourceType = sourceType
        photoPicker.allowsEditing = true
        photoPicker.delegate = self
        
        self.dismiss(animated: true) {
            self.present(photoPicker, animated: true)
        }
    }
    
    func cropToBounds(image: UIImage, width: Double, height: Double) -> UIImage {
        
        let cgimage = image.cgImage!
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        let contextSize: CGSize = contextImage.size
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)
        
        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = cgimage.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
        return image
    }
    
    private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    
    
    public var detailItem: UVCDocumentMapRequest? {
        didSet {
            uvcViewController.configureView()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        // Start: Added for Mac Catalyst so that it works. Have to investigate to do better!
        if ApplicationSetting.DocumentType == nil {
            ApplicationSetting.deleteAll()
            ApplicationSetting.InterfaceLanguage = "ta"
            ApplicationSetting.DocumentLanguage = "ta"
            ApplicationSetting.DocumentType = "UDCDocumentType.DocumentItem"
            ApplicationSetting.CursorMode = "false"
        }
        // End: Added for Mac Catalyst
        if !UIDevice.current.orientation.isLandscape {
            if ApplicationSetting.DocumentType! != "UDCDocumentType.DocumentItem" {
                if collectionView.cellForItem(at: NSIndexPath(item: 1, section: 2) as IndexPath) != nil {
                    let cell = collectionView.cellForItem(at: NSIndexPath(item: 1, section: 2) as IndexPath) as! DetailViewCell
                    if cell.getViewController().getPhoto() != nil {
                        if (cell.getViewController().getPhoto()?.uvcMeasurement[2].value)! > 670 {
                            let quaterWidth = (cell.getViewController().getPhoto()?.uvcMeasurement[2].value)! / 4
                            let quaterHeight = (cell.getViewController().getPhoto()?.uvcMeasurement[3].value)! / 4
                            let height = quaterHeight * 3
                            let width = (quaterWidth * 3) - 20
                            let imageView = cell.getViewController().getImageView()
                            imageView!.image = imageView!.image!.crop(to: CGSize(width: width, height: height))
                            uvcDocumentGraphModelList[2].uvcViewModel[1].uvcViewItemCollection.uvcPhoto[0].uvcMeasurement[2].value = width
                            uvcDocumentGraphModelList[2].uvcViewModel[1].uvcViewItemCollection.uvcPhoto[0].uvcMeasurement[3].value = height
                            collectionView.reloadItems(at: [NSIndexPath(item: 1, section: 2) as IndexPath])
                        }
                    }
                }
            }
        } else {
            if ApplicationSetting.DocumentType! != "UDCDocumentType.DocumentItem" {
                if collectionView.cellForItem(at: NSIndexPath(item: 1, section: 2) as IndexPath) != nil {
                    let cell = collectionView.cellForItem(at: NSIndexPath(item: 1, section: 2) as IndexPath) as! DetailViewCell
                    if cell.getViewController().getPhoto() != nil {
                        let width = Double(900)
                        let height = Double(340)
                        let imageView = cell.getViewController().getImageView()
                        imageView!.image = imageView!.image!.crop(to: CGSize(width: width, height: height))
                        uvcDocumentGraphModelList[2].uvcViewModel[1].uvcViewItemCollection.uvcPhoto[0].uvcMeasurement[2].value = width
                        uvcDocumentGraphModelList[2].uvcViewModel[1].uvcViewItemCollection.uvcPhoto[0].uvcMeasurement[3].value = height
                        collectionView.reloadItems(at: [NSIndexPath(item: 1, section: 2) as IndexPath])
                    }
                }
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let uiImage = info[.editedImage] as? UIImage else {
            showAlertView(message: "Image not found")
            return
        }
        
        var width: Double = Double(uiImage.size.width)
        var height: Double = Double(uiImage.size.height)
        for uvcMeasurement in uvcPhoto!.uvcMeasurement {
            if uvcMeasurement.type == UVCMeasurementType.Width.name {
                width = uvcMeasurement.value
            } else if uvcMeasurement.type == UVCMeasurementType.Height.name {
                height = uvcMeasurement.value
            }
        }
        uiImageView!.image = uiImage.crop(to: CGSize(width: width, height: height))
        //        UVCPhotoController.getProcessedImage(uvcPhoto: self.uvcPhoto!, uiImageView: &uiImageView!)
        uvcPhoto!.binaryData = uiImageView!.image!.pngData()
        uvcViewController.setImagePickerControllerImage(uiImage: uiImageView!.image!, uvcPhoto: uvcPhoto!)
    }
    
    public func setRightButton(name: [String]) {
        var buttonBarItems = [UIBarButtonItem]()
        for n in name {
            if n == "UDCOptionMapNode.Elipsis" {
                let optionButton = UIBarButtonItem(image: UIImage(named: "Elipsis"), style: .plain, target: self, action: #selector(optionButtonPressed(_:)))
                #if targetEnvironment(macCatalyst)
                if view.traitCollection.userInterfaceStyle == .dark {
                    optionButton.tintColor = UIColor.white
                } else {
                    optionButton.tintColor = UIColor.black
                }
                #endif
                buttonBarItems.append(optionButton)
            } else {
                let optionButton = UIBarButtonItem(title: optionLabel[n], style: .plain, target: self, action: #selector(optionButtonPressed(_:)))
                #if targetEnvironment(macCatalyst)
                if view.traitCollection.userInterfaceStyle == .dark {
                    optionButton.tintColor = UIColor.white
                } else {
                    optionButton.tintColor = UIColor.black
                }
                #endif
                buttonBarItems.append(optionButton)
            }
        }
        
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            self.navigationItem.rightBarButtonItems = buttonBarItems
        } else {
            tabBarController!.navigationItem.rightBarButtonItems = buttonBarItems
        }
    }
    
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        // Stop running when the user releases the left or right arrow key.

        var didHandleEvent = false
        for press in presses {
            guard let key = press.key else { continue }
            if key.charactersIgnoringModifiers == UIKeyCommand.inputUpArrow {
                uvcViewController.handleArrowKeys(name: "UpDirectionArrow")
                didHandleEvent = true
            } else if key.charactersIgnoringModifiers == UIKeyCommand.inputDownArrow {
                uvcViewController.handleArrowKeys(name: "DownDirectionArrow")
                didHandleEvent = true
            } else if key.charactersIgnoringModifiers == UIKeyCommand.inputLeftArrow {
                let searchBox = collectionView.cellForItem(at: NSIndexPath(item: currentItemIndex, section: currentNodeIndex) as IndexPath) as! DetailViewCell
                let uiTextField = searchBox.uvcViewController.uvcUIViewControllerItemCollection.getTextField(tag: 0, name: "UDCDocumentItemMapNode.SearchDocumentItems")?.uiTextField
                if uiTextField!.text!.isEmpty {
                    uvcViewController.handleArrowKeys(name: "LeftDirectionArrow")
                    didHandleEvent = true
                }
            } else if key.charactersIgnoringModifiers == UIKeyCommand.inputRightArrow {
                let searchBox = collectionView.cellForItem(at: NSIndexPath(item: currentItemIndex, section: currentNodeIndex) as IndexPath) as! DetailViewCell
                let uiTextField = searchBox.uvcViewController.uvcUIViewControllerItemCollection.getTextField(tag: 0, name: "UDCDocumentItemMapNode.SearchDocumentItems")?.uiTextField
                if uiTextField!.text!.isEmpty {
                    uvcViewController.handleArrowKeys(name: "RightDirectionArrow")
                    didHandleEvent = true
                }
            }
            
        }
        
        if didHandleEvent == false {
            // Didn't handle this key press, so pass the event to the next responder.
            super.pressesBegan(presses, with: event)
        }
    }
    
    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand.init(input: "e", modifierFlags: [.command], action: #selector(textToSpeechCommand)),
            // F3 function key
            UIKeyCommand.init(input: UIKeyCommand.f3, modifierFlags: [], action: #selector(searchOnOffPressed)),
            // F4 function key
            UIKeyCommand.init(input: UIKeyCommand.f4, modifierFlags: [], action: #selector(letterSpacePressed)),
            // Command + Shift + "d"                    : Delete
            UIKeyCommand.init(input: "d", modifierFlags: [.command, .shift], action: #selector(deleteLinePressed)),
            // Command + "d"                    : Delete
            UIKeyCommand.init(input: "d", modifierFlags: [.command], action: #selector(deletePressed)),
            // Command + Option + "f"           : Format
            UIKeyCommand.init(input: "f", modifierFlags: [.command, .alternate], action: #selector(formatPressed)),
            // Command + Option + "t"           : Configuration
            UIKeyCommand.init(input: "t", modifierFlags: [.command, .alternate], action: #selector(configurationPressed)),
            // Command + Option + Control + "m" : Configuration
            UIKeyCommand.init(input: "m", modifierFlags: [.command, .alternate, .control], action: #selector(documentMapPressed)),
            // Command + Option + "h"           : Information
            UIKeyCommand.init(input: "h", modifierFlags: [.command, .alternate], action: #selector(informationPressed)),
            // Command + Option + "v"           : View
            UIKeyCommand.init(input: "v", modifierFlags: [.command, .alternate], action: #selector(viewPressed)),
            // Command + Option + "o"           : Options
            UIKeyCommand.init(input: "o", modifierFlags: [.command, .alternate], action: #selector(optionPressed)),
            // Command + Left Arrow    : Home
            UIKeyCommand.init(input: UIKeyCommand.inputLeftArrow, modifierFlags: [.command], action: #selector(homePressed)),
            // Command + Right Arrow   : End
            UIKeyCommand.init(input: UIKeyCommand.inputRightArrow, modifierFlags: [.command], action: #selector(endPressed)),
            // Command + Up Arrow      : Page Home
            UIKeyCommand.init(input: UIKeyCommand.inputUpArrow, modifierFlags: [.command], action: #selector(pageHomePressed)),
            // Command + Down Arrow    : Page End
            UIKeyCommand.init(input: UIKeyCommand.inputDownArrow, modifierFlags: [.command], action: #selector(pageEndPressed))
        ]
    }
    @objc public func textToSpeechCommand(keyCommand: UIKeyCommand) {
        alertController = UIAlertController(title: "Enter Text",
                                            message: "Enter some text below",
                                            preferredStyle: .alert)
        alertController!.addTextField(
            configurationHandler: {(textField: UITextField!) in
                        textField.placeholder = "Enter something"
                })
        
        let action = UIAlertAction(title: "Submit",
                                   style: UIAlertAction.Style.default,
                                   handler: {[weak self]
                                    (paramAction:UIAlertAction!) in
                                    if let textFields = self!.alertController?.textFields{
                                        let theTextFields = textFields as [UITextField]
                                        let enteredText = theTextFields[0].text
                                        self!.textToSpeech(text: enteredText!)
                                        
                                    }
                                   })
        alertController?.addAction(action)
        self.present(alertController!,
                                       animated: true,
                                       completion: nil)
    }
    @objc public func textToSpeech(text: String)
    {
        
        let textToSpeechUtility = TextToSpeechUtility()
        do {
            try textToSpeechUtility.speak(player: &aviAudioPlayer, text: "Ready 1 2 3 4 5 6 7 8 9 ten. \(text)", voiceType: .englishStandardMale, languageCode: .englishUS, pitch: 0, speakingRate: 0)
        } catch {
            print("Text to speech error: \(error)")
        }
    }
    
    @objc public func letterSpacePressed(keyCommand: UIKeyCommand)
    {
        if isLetterSpaceLocked {
            isLetterSpaceLocked = false
        } else {
            isLetterSpaceLocked = true
        }
    }
    
    @objc public func deleteLinePressed(keyCommand: UIKeyCommand)
    {
        uvcViewController.deleteLinePressed(keyCommand: keyCommand)
    }
    
    @objc public func deletePressed(keyCommand: UIKeyCommand)
    {
        uvcViewController.deletePressed(keyCommand: keyCommand)
    }
    
    @objc public func formatPressed(keyCommand: UIKeyCommand)
    {
        uvcViewController.formatPressed(keyCommand: keyCommand)
    }
    
    // Can use single key (function key) to enable or disable instead of "Command" + "l"
    @objc public func searchOnOffPressed(keyCommand: UIKeyCommand)
    {
        uvcViewController.searchOnOffPressed(keyCommand: keyCommand)
    }
    
    @objc public func configurationPressed(keyCommand: UIKeyCommand)
    {
        uvcViewController.configurationPressed(keyCommand: keyCommand)
    }
    
    @objc public func documentMapPressed(keyCommand: UIKeyCommand)
    {
        uvcViewController.documentMapPressed(keyCommand: keyCommand)
    }
    
    @objc public func informationPressed(keyCommand: UIKeyCommand)
    {
        uvcViewController.informationPressed(keyCommand: keyCommand)
    }
    
    @objc public func viewPressed(keyCommand: UIKeyCommand)
    {
        uvcViewController.viewPressed(keyCommand: keyCommand)
    }
    
    @objc public func optionPressed(keyCommand: UIKeyCommand)
    {
        uvcViewController.optionPressed(keyCommand: keyCommand)
    }
    
    @objc public func upArrow(keyCommand: UIKeyCommand)
    {
        uvcViewController.upArrow(keyCommand: keyCommand)
    }
    
    @objc public func downArrow(keyCommand: UIKeyCommand)
    {
        uvcViewController.downArrow(keyCommand: keyCommand)
    }
    
    @objc public func leftArrow(keyCommand: UIKeyCommand)
    {
        uvcViewController.leftArrow(keyCommand: keyCommand)
    }
    
    @objc public func rightArrow(keyCommand: UIKeyCommand)
    {
        uvcViewController.rightArrow(keyCommand: keyCommand)
    }
    
    @objc public func homePressed(keyCommand: UIKeyCommand)
    {
        uvcViewController.homePressed(keyCommand: keyCommand)
    }
    
    @objc public func endPressed(keyCommand: UIKeyCommand)
    {
        uvcViewController.endPressed(keyCommand: keyCommand)
    }
    
    @objc public func pageHomePressed(keyCommand: UIKeyCommand)
    {
        uvcViewController.pageHomePressed(keyCommand: keyCommand)
    }
    
    @objc public func pageEndPressed(keyCommand: UIKeyCommand)
    {
        uvcViewController.pageEndPressed(keyCommand: keyCommand)
    }
    public func setEditable(editable: Bool) {
        isEditableMode = editable
        setDocumentTitle(title: getDocumentTitle())
    }
    
    public func getDocumentTitle() -> String {
        return documentTitle.capitalized
    }
    
    public func setDocumentTitle(title: String) {
        
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            //            self.title = title
//            self.navigationController?.navigationBar.topItem?.title = title
                               self.navigationItem.title = title
        } else {
            self.tabBarController!.navigationItem.title = title
        }
        if isPopup {
            setRightButton(name: ["UDCOptionMapNode.Done"])
        } else {
            setRightButton(name: [ "UDCOptionMapNode.Elipsis"])
        }
        //        if self.toolbar == nil {
        //            self.toolbar = UIToolbar(frame: CGRect(x: 0,y: 0,width: self.view.frame.width, height: 150))
        //            toolbar!.autoresizingMask = .flexibleWidth
        //            toolbar!.sizeToFit()
        //        }
        ////        self.navigationController!.navigationBar.isTranslucent = false
        ////        self.navigationController?.isToolbarHidden = false
        ////        self.navigationController?.toolbar!.isHidden = true
        //        toolbarViewObjects.removeAll()
        //        var toolBarItems = [UIBarButtonItem]()
        //        let font = UIFont(name: "Helvetica", size: CGFloat( UVCTextSizeType.Regular.size))
        //        let titleLabel = UILabel(frame: CGRect(x: 0,y: 0,width: self.view.frame.width, height: 150))
        //        titleLabel.text = title
        //        titleLabel.font = font
        //        let titleLabelButton = UIBarButtonItem(customView: titleLabel)
        //
        //        if isEditableMode {
        //            if toolbarView != nil {
        //                toolBarItems.append(titleLabelButton)
        ////                for (tvControllerTextIndex, tvControllerText) in toolbarView!.controllerText.enumerated() {
        ////                    if toolbarView!.uvcViewItemType[tvControllerTextIndex] == "UVCViewItemType.Photo" {
        ////                        let uiImageLocal = UIImage(named: toolbarView!.photoName[tvControllerTextIndex])
        ////                        let uiImageViewLocal = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        ////                        uiImageViewLocal.image = uiImageLocal
        ////                        let imageButtonLocal = UIBarButtonItem(customView: uiImageViewLocal)
        ////                        toolBarItems.append(imageButtonLocal)
        ////                        toolbarViewObjects.append(uiImageViewLocal)
        ////                    } else {
        ////                        let fontAttributes = [NSAttributedString.Key.font: font]
        ////                        let width = (tvControllerText as! NSString).size(withAttributes: fontAttributes).width + 10
        ////                        let titleLabelLocal = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: 30))
        ////                        titleLabelLocal.textColor = toolbar!.tintColor
        ////                        titleLabelLocal.text = tvControllerText
        ////                        titleLabelLocal.font = font
        ////                        let titleLabelButtonLocal = UIBarButtonItem(customView: titleLabelLocal)
        ////                        toolBarItems.append(titleLabelButtonLocal)
        ////                        toolbarViewObjects.append(titleLabelLocal)
        ////                    }
        ////
        ////                }
        //                let searchTextFieldButton = UIBarButtonItem(customView: searchTextField)
        //                toolBarItems.append(searchTextFieldButton)
        //            }
        //        } else {
        //            toolBarItems.append(titleLabelButton)
        //        }
        //        let flexibleSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        //        toolBarItems.append(flexibleSpace)
        //        toolbar!.setItems(toolBarItems, animated: true)
        //        if (UIDevice.current.userInterfaceIdiom == .pad) {
        //            self.navigationItem.titleView = toolbar
        //        } else {
        //            self.tabBarController!.navigationItem.titleView = toolbar
        //        }
        //        self.collectionView.reloadData()
    }
    public func showActivityIndicator(activityDescription: String) {
        DispatchQueue.main.async {
            self.activityIndicator.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(100), height: CGFloat(100))
            self.activityIndicator.color = .green
            if (UIDevice.current.userInterfaceIdiom == .pad) {
                //                if self.navigationItem.title != nil {
                //                    self.activityIndicatorTitle = self.navigationItem.title!
                //                }
                self.navigationItem.title = activityDescription
//                self.setTabBarItems(item: [activityDescription])
//                self.navigationItem.titleView = self.activityIndicator
            } else {
                //                if self.tabBarController!.navigationItem.title != nil {
                //                self.activityIndicatorTitle = self.tabBarController!.navigationItem.title!
                //                }
                self.tabBarController!.navigationItem.title = activityDescription
//                self.tabBarController!.navigationItem.titleView = self.activityIndicator
            }
            
            self.activityIndicator.startAnimating()
            print("Activity in progress: \(activityDescription)")
        }
        self.uvcViewController.setActivitiyInProgress(isActivityInProgress: true)
    }
    
    public func setObjectController(value: String) {
        objectControllerToolbar.items![1].title = value
    }
    
    public func enabledObjectControllerButtons(enable: Bool) {
        for (itemIndex, item) in objectControllerToolbar.items!.enumerated() {
            if itemIndex >= 5 && itemIndex <= 8 {
                item.isEnabled = enable
            }
        }
    }
    
    public func loadObjectControllerView(uiTextFiled: UITextField) {
        if objectControllerView != nil {
            do {
                objectControllerToolbar.isUserInteractionEnabled = true
                objectControllerToolbar.sizeToFit()
                let textEdgeInsets = UIEdgeInsets(top: 0.0, left: -25, bottom: 0, right: -25);
                let imageEdgeInsets = UIEdgeInsets(top: 0.0, left: -15, bottom: 0, right: -15);
                var uiBarButtonItem = [UIBarButtonItem]()
                let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil);
                for (ctIndex, ct) in (objectControllerView?.controllerText.enumerated())! {
                    if objectControllerView!.uvcViewItemType[ctIndex] == "UVCViewItemType.Text" {
                        //                        print("INDEX TEST: \(objectControllerView!.uvcViewItemType[ctIndex]): \(ct): \(ctIndex)")
                        let barButton = UIBarButtonItem(title: ct , style: .plain , target:  self, action:  #selector(objectControllerButtonPressed))
                        barButton.isEnabled = false
                        barButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.black], for: .disabled)
                        barButton.imageInsets = textEdgeInsets
                        uiBarButtonItem.append(barButton)
                    } else {
                        if (objectControllerView?.controllerText[ctIndex].isEmpty)! {
                            //                            print("INDEX TEST: \(objectControllerView!.uvcViewItemType[ctIndex]): \((objectControllerView?.photoName[ctIndex])!): \(ctIndex)")
                            let barButton = UIBarButtonItem(image: UIImage(named: (objectControllerView?.photoName[ctIndex])!) , style: .plain , target:  self, action:  #selector(objectControllerButtonPressed))
                            if objectControllerView?.photoName[ctIndex] != "Elipsis" {
                                barButton.imageInsets = imageEdgeInsets
                            }
                            uiBarButtonItem.append(barButton)
                            if objectControllerView?.photoName[ctIndex] == "DownDirectionArrow" {
                                uiBarButtonItem.append(flexibleSpace)
                            }
                        } else {
                            //                            print("INDEX TEST: \(objectControllerView!.uvcViewItemType[ctIndex]): \(ct): \(ctIndex)")
                            //                            if ctIndex == 7 {
                            //                                let title = objectEditMode ? optionLabel["UDCOptionMapNode.Done"] : optionLabel["UDCOptionMapNode.Edit"]
                            //                                let barButton = UIBarButtonItem(title: title , style: .plain , target:  self, action:  #selector(objectControllerButtonPressed))
                            //                                barButton.imageInsets = textEdgeInsets
                            //                                uiBarButtonItem.append(barButton)
                            //                            } else {
                            let barButton = UIBarButtonItem(title: ct , style: .plain , target:  self, action:  #selector(objectControllerButtonPressed))
                            barButton.imageInsets = textEdgeInsets
                            uiBarButtonItem.append(barButton)
                            //                            }
                            
                        }
                    }
                }
                
                objectControllerToolbar.setItems(uiBarButtonItem, animated: true)
                uiTextFiled.inputAccessoryView  = objectControllerToolbar
                enabledObjectControllerButtons(enable: true)
                for uvcUIButton in searchBoxViewController.uvcUIViewControllerItemCollection.uvcUIButton {
                    uvcUIButton.uiButton.addTarget(self, action: #selector(objectControllerButtonPressed(_:)), for: .touchUpInside)
                }
            } catch {
                showAlertView(message: "Failed to load view controller: \(error)")
            }
        }
    }
    
    
    
    @objc func objectControllerButtonPressed(_ sender: UIBarButtonItem) {
        uvcViewController.objectControllerButtonPressed(sender)
    }
    
    private func applyEcxtendedNavigationBar() {
        self.navigationController!.navigationBar.prefersLargeTitles = true
        self.navigationController!.navigationBar.backgroundColor = .white
        self.navigationController!.navigationBar.shadowImage = UIImage(named: "ImagePlaceHolder")?.crop(to: CGSize(width: 444, height: 55))
        self.navigationController!.navigationBar.isTranslucent = false
        self.navigationController?.isToolbarHidden = false
        self.navigationController?.toolbar!.isHidden = true
        self.navigationController!.navigationBar.layer.shadowOffset = CGSize(width: 0, height: CGFloat(1) / UIScreen.main.scale)
        self.navigationController!.navigationBar.layer.shadowRadius = 0
        
        // UINavigationBar's hairline is adaptive, its properties change with
        // the contents it overlies.  You may need to experiment with these
        // values to best match your content.
        self.navigationController!.navigationBar.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        self.navigationController!.navigationBar.layer.shadowOpacity = 0.25
    }
    
    public func hideActivityIndicator(activityDescription: String) {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            //            if (UIDevice.current.userInterfaceIdiom == .pad) {
            //                self.navigationItem.titleView = nil
            //            } else {
            ////                if self.tabBarController != nil {
            ////                    self.tabBarController!.navigationItem.titleView = nil
            ////                    self.tabBarController!.navigationItem.title = self.activityIndicatorTitle
            ////                }
            //            }
            self.setDocumentTitle(title: self.getDocumentTitle())
            //            self.setupNavigationBar()
            print("Activity stoped: \(activityDescription)")
        }
        self.uvcViewController.setActivitiyInProgress(isActivityInProgress: false)
    }
    
    public func setCurrentOperation(name: String) {
        currentOperationName = name
    }
    
    public func getCurrentOperation() -> String {
        return currentOperationName
    }
    
    public func setCurrentOperationData(data: [String: [String: Any]]) {
        currentOperationData.removeAll()
        currentOperationData = data
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
        self.dismiss(animated: true) {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    public func showAlertViewOKCancel(name: String, message: String, data: Any) {
        let refreshAlert = UIAlertController(title: "Universe Docs", message: message, preferredStyle: UIAlertController.Style.alert)
        isAlertOkCancel = false
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            self.uvcViewController.alertOk(name: name, data: data)
        }))
        
        refreshAlert.addAction(UIAlertAction(title: optionLabel["UDCOptionMapNode.Cancel"], style: .cancel, handler: { (action: UIAlertAction!) in
            self.uvcViewController.alertCancel(name: name, data: data)
        }))
        
        self.dismiss(animated: true) {
            self.present(refreshAlert, animated: true, completion: nil)
        }
    }
    
    @objc func brainControllerNeuronResponse(_ notification:Notification) {
        if notification.name != Notification.Name(rawValue: "DetailViewControllerNotification") && !notification.name.rawValue.hasPrefix(Notification.Name(rawValue: "DetailViewControllerPopupNotification").rawValue) {
            return
        }
        let neuronRequest: NeuronRequest = notification.object as! NeuronRequest
        if neuronRequest.neuronOperation.neuronOperationStatus.neuronOperationError!.count > 0 {
            hideActivityIndicator(activityDescription: "Error")
            showAlertView(message: neuronRequest.neuronOperation.neuronOperationStatus.neuronOperationError![0].description)
            masterViewController!.brainControllerNeuronResponse(notification)
            return
        }
        
        if neuronRequest.neuronOperation.neuronOperationStatus.neuronOperationSuccess!.count > 0 {
            if neuronRequest.neuronOperation.name == "TypeNeuron.Get" {
                
                uvcViewController.handleType(neuronRequest: neuronRequest)
            } else if neuronRequest.neuronOperation.name == "OptionMapNeuron.OptionMap.Get.SearchOption" || neuronRequest.neuronOperation.name == "OptionMapNeuron.OptionMap.Get.DocumentOptions" {
                uvcViewController.handleOptions(neuronRequest: neuronRequest)
            } else if neuronRequest.neuronOperation.name == "DocumentItemNeuron.Search.DocumentItem" {
                uvcViewController.handleDocumentItemSearch(neuronRequest: neuronRequest)
            } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.New" {
                uvcViewController.handleDocumentNew(neuronRequest: neuronRequest)
            } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.Item.Insert" {
                uvcViewController.handledocumentInsertItem(neuronRequest: neuronRequest)
            } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.Item.Change" {
                uvcViewController.handleDocumentChangeItem(neuronRequest: neuronRequest)
            } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.Item.Delete" {
                uvcViewController.handleDocumentDeleteItem(neuronRequest: neuronRequest)
            } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.Item.Reference" {
                uvcViewController.handleDocumentReference(neuronRequest: neuronRequest)
            } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.Insert.NewLine" {
                uvcViewController.handleDocumentNewLine(neuronRequest: neuronRequest)
            } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.Delete.Line" {
                uvcViewController.handleDocumentDeleteLine(neuronRequest: neuronRequest)
            } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Get.ViewController.View" {
                uvcViewController.handleObjectControllerView(neuronRequest: neuronRequest)
            } else if neuronRequest.neuronOperation.name == "PhotoNeuron.Store.Item.Photo" {
                uvcViewController.handleStoreItemPhoto(neuronRequest: neuronRequest)
            } else if neuronRequest.neuronOperation.name == "PhotoNeuron.Get.Item.Photo" {
                //                    uiImageView!.image = UIImage(data: neuronRequest.neuronOperation.neuronData.binaryData!)
                uvcViewController.handlePhoto(neuronRequest: neuronRequest)
            } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Get.View.Configuration.Options" {
                uvcViewController.handleGetViewConfigurationOptions(neuronRequest: neuronRequest)
            } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.Category.Selected" {
                uvcViewController.handleCategory(neuronRequest: neuronRequest)
            } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.Category.Options.Selected" {
                uvcViewController.handleCategoryOptions(neuronRequest: neuronRequest)
            } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.Get.View" {
                
                uvcViewController.handleDocumentGetView(neuronRequest: neuronRequest)
            } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.Delete" {
                uvcViewController.handleDocumentDelete(neuronRequest: neuronRequest)
            } else if neuronRequest.neuronOperation.name == "DocumentGraphNeuron.Document.Get.InterfacePhoto" {
                uvcViewController.handleDocumentInterfacePhoto(neuronRequest: neuronRequest)
            }
            hideActivityIndicator(activityDescription: neuronRequest.neuronOperation.name)
            if neuronRequest.neuronOperation.name == "OptionMapNeuron.OptionMap.Get.SearchOption" {
                uvcViewController.getObjectControllerView()
            }
        } else {
            hideActivityIndicator(activityDescription: "No message")
            
        }
        
    }
    
    private func getOperationDescription(currentOperationName: String) -> String {
        if currentOperationName == "DocumentGraphNeuron.Document.Get.View" {
            return "Getting document..."
        } else if currentOperationName == "PhotoNeuron.Get.Item.Photo" {
            return "Getting photos..."
        } else if currentOperationName == "DocumentGraphNeuron.Document.Delete.Line" {
            return "Deleting line..."
        } else if currentOperationName == "DocumentGraphNeuron.Document.Insert.NewLine" {
            return "Adding new line..."
        } else if currentOperationName == "OptionMapNeuron.OptionMap.Get.SearchOption" || currentOperationName == "OptionMapNeuron.OptionMap.Get.SearchOption" ||
                    currentOperationName == "OptionMapNeuron.OptionMap.Get.DocumentOptions" {
            return "Getting options..."
        }
        return currentOperationName
    }
    
    public func sendRequest(sourceName: String) {
        if uvcViewController.getActivitiyInProgress() {
            return
        }
        CallBrainControllerNeuron.sourceName = "DetailViewController"
        if sourceName == "DetailViewController" {
            
            showActivityIndicator(activityDescription: "\(getOperationDescription(currentOperationName: currentOperationName))...")
        }
        let data = currentOperationData[currentOperationName]
        //        var sourceName = String(describing: DetailViewController.self)
        //        if isPopup {
        //            sourceName = "detailViewControllerTab"
        //        }
        
        if currentOperationName == "DocumentGraphNeuron.Document.Get.View" {
            let callBrainControllerNeuron = CallBrainControllerNeuron()
            callBrainControllerNeuron.getDocumentView(sourceName: sourceName, getDocumentGraphViewRequest: data?["getDocumentGraphViewRequest"] as! GetDocumentGraphViewRequest,  neuronName: data?["neuronName"] as! String)
        } else if currentOperationName == "DocumentGraphNeuron.Document.Category.Selected" {
            let callBrainControllerNeuron = CallBrainControllerNeuron()
            callBrainControllerNeuron.category(sourceName: sourceName, language: data?["language"] as! String, documentCategorySelectedRequest:  data?["documentCategorySelectedRequest"] as! DocumentCategorySelectedRequest)
        } else if currentOperationName == "DocumentGraphNeuron.Document.Category.Options.Selected" {
            let callBrainControllerNeuron = CallBrainControllerNeuron()
            callBrainControllerNeuron.categoryOptions(sourceName: sourceName, language: data?["language"] as! String, documentCategoryOptionSelectedRequest:  data?["documentCategoryOptionSelectedRequest"] as! DocumentCategoryOptionSelectedRequest)
        } else if currentOperationName == "DocumentGraphNeuron.Get.View.Configuration.Options" {
            let callBrainControllerNeuron = CallBrainControllerNeuron()
            callBrainControllerNeuron.getViewConfigurationOptions(sourceName: sourceName, language: data?["language"] as! String, documentGetViewConfigurationOptionsRequest:  data?["documentGetViewConfigurationOptionsRequest"] as! DocumentGetViewConfigurationOptionsRequest)
        } else if currentOperationName == "PhotoNeuron.Store.Item.Photo" {
            let callBrainControllerNeuron = CallBrainControllerNeuron()
            callBrainControllerNeuron.storeItemPhoto(sourceName: sourceName, language: data?["language"] as! String, documentGraphStorePhotoRequest: data?["documentGraphStorePhotoRequest"] as! DocumentStorePhotoRequest, binaryData: data?["binaryData"] as! Data)
        } else if currentOperationName == "PhotoNeuron.Get.Item.Photo" {
            let callBrainControllerNeuron = CallBrainControllerNeuron()
            callBrainControllerNeuron.getItemPhoto(sourceName: sourceName, language: data?["language"] as! String, documentGraphGetPhotoRequest: data?["documentGraphGetPhotoRequest"] as! DocumentGetPhotoRequest)
        } else if currentOperationName == "DocumentGraphNeuron.ObjectController.ViewItem.Insert" {
            let callBrainControllerNeuron = CallBrainControllerNeuron()
            callBrainControllerNeuron.objectController(sourceName: sourceName, language: data?["language"] as! String, objectControllerRequest: data?["objectControllerRequest"] as! ObjectControllerRequest, neuronName:  data?["neuronName"] as! String)
        } else if currentOperationName == "DocumentGraphNeuron.Get.ViewController.View" {
            let callBrainControllerNeuron = CallBrainControllerNeuron()
            callBrainControllerNeuron.getObjectControllerView(sourceName: sourceName, language: data?["language"] as! String, getObjectControllerViewRequest: data?["getObjectControllerViewRequest"] as! GetObjectControllerViewRequest)
        } else if currentOperationName == "DocumentGraphNeuron.Document.Delete.Line" {
            let callBrainControllerNeuron = CallBrainControllerNeuron()
            callBrainControllerNeuron.documentDeleteLine(sourceName: sourceName, language: data?["language"] as! String, documentGraphDeleteLineRequest: data?["documentGraphDeleteLineRequest"] as! DocumentGraphDeleteLineRequest, neuronName: data?["neuronName"] as! String)
        } else if currentOperationName == "DocumentGraphNeuron.Document.Insert.NewLine" {
            let callBrainControllerNeuron = CallBrainControllerNeuron()
            callBrainControllerNeuron.documentNewLine(sourceName: sourceName, language: data?["language"] as! String, documentGraphInsertNewLineRequest: data?["documentGraphInsertNewLineRequest"] as! DocumentGraphInsertNewLineRequest, neuronName: data?["neuronName"] as! String)
        } else if currentOperationName == "DocumentGraphNeuron.Document.Item.Reference" {
            let callBrainControllerNeuron = CallBrainControllerNeuron()
            callBrainControllerNeuron.documentReference(sourceName: sourceName, language: data?["language"] as! String, documentGraphItemReferenceRequest: data?["documentGraphItemReferenceRequest"] as! DocumentGraphItemReferenceRequest, neuronName: data?["neuronName"] as! String)
        } else if currentOperationName == "DocumentGraphNeuron.SaveAsTemplate" {
            let callBrainControllerNeuron = CallBrainControllerNeuron()
            callBrainControllerNeuron.documentSaveAsTemplate(sourceName: sourceName, language: data?["language"] as! String, documentSaveAsTemplateRequest: data?["documentSaveAsTemplateRequest"] as! DocumentGraphSaveAsTemplateRequest)
        } else if currentOperationName == "TypeNeuron.Get" {
            let callBrainControllerNeuron = CallBrainControllerNeuron()
            callBrainControllerNeuron.getType(sourceName: sourceName, type: data?["type"] as! String, category: "", language: data?["language"] as! String, fromText: data?["fromText"] as! String, sortedBy: data?["sortedBy"] as! String, limitedTo: data?["limitedTo"] as! Int, isAll: data?["isAll"] as! Bool, searchText: "")
        } else if currentOperationName == "GrammarNeuron.Sentence.Generate" {
            let callBrainControllerNeuron = CallBrainControllerNeuron()
            callBrainControllerNeuron.getSentence(sourceName: sourceName, language: ApplicationSetting.DocumentLanguage!, sentenceRequest: data?["sentenceRequest"] as! SentenceRequest, neuronName: data?["neuronName"] as! String)
        } else if currentOperationName == "OptionMapNeuron.OptionMap.Get.SearchOption" ||
            currentOperationName == "OptionMapNeuron.OptionMap.Get.DocumentOptions" {
            let callBrainControllerNeuron = CallBrainControllerNeuron()
            if currentOperationName.hasSuffix("SearchOption") {
                callBrainControllerNeuron.getOptions(sourceName: sourceName, language: ApplicationSetting.InterfaceLanguage!, getOptionMapRequest: data?["getOptionMapRequest"] as! GetOptionMapRequest, neuronName: data?["neuronName"] as! String, optionSuffix: "SearchOption")
            } else if currentOperationName.hasSuffix("DocumentOptions") {
                callBrainControllerNeuron.getOptions(sourceName: sourceName, language: ApplicationSetting.InterfaceLanguage!, getOptionMapRequest: data?["getOptionMapRequest"] as! GetOptionMapRequest, neuronName: data?["neuronName"] as! String, optionSuffix: "DocumentOptions")
            }
        } else if currentOperationName == "DocumentItemNeuron.Search.DocumentItem" {
            let callBrainControllerNeuron = CallBrainControllerNeuron()
            callBrainControllerNeuron.searchDocumentItem(sourceName: sourceName, language: ApplicationSetting.DocumentLanguage!, documentGraphItemSearchRequest: data?["documentGraphItemSearchRequest"] as! DocumentGraphItemSearchRequest, neuronName: data?["neuronName"] as! String)
        } /*else if currentOperationName == "DocumentGraphNeuron.User.SentencePattern.Add" {
            let callBrainControllerNeuron = CallBrainControllerNeuron()
            callBrainControllerNeuron.userSentencePatternAdd(sourceName: sourceName, language: ApplicationSetting.DocumentLanguage!, userSentencePatternAddRequest: data?["userSentencePatternAddRequest"] as! UserSentencePatternAddRequest)
        }*/ else if currentOperationName == "RecipeNeuron.User.Word.Add" {
            let callBrainControllerNeuron = CallBrainControllerNeuron()
            callBrainControllerNeuron.userWordAdd(sourceName: sourceName, language: ApplicationSetting.DocumentLanguage!, userWordAddRequest: data?["userWordAddRequest"] as! UserWordAddRequest)
        }  else if currentOperationName == "DocumentGraphNeuron.Document.New" {
            let callBrainControllerNeuron = CallBrainControllerNeuron()
            callBrainControllerNeuron.documentNew(sourceName: sourceName, documentGraphNewRequest: data?["documentGraphNewRequest"] as! DocumentGraphNewRequest, language: ApplicationSetting.DocumentLanguage!, neuronName: data?["neuronName"] as! String)
        } else if currentOperationName == "RecipeNeuron.Document.AddCategory" {
            let callBrainControllerNeuron = CallBrainControllerNeuron()
            callBrainControllerNeuron.documentAddCategory(sourceName: sourceName, documentGraphAddCategoryRequest: data?["documentGraphAddCategoryRequest"] as! DocumentGraphAddCategoryRequest, language: ApplicationSetting.DocumentLanguage!, neuronName: data?["neuronName"] as! String)
        } else if currentOperationName == "DocumentGraphNeuron.Document.Item.Insert" {
            let callBrainControllerNeuron = CallBrainControllerNeuron()
            callBrainControllerNeuron.documentInsertItem(sourceName: sourceName, documentGraphInsertItemRequest: data?["documentGraphInsertItemRequest"] as! DocumentGraphInsertItemRequest, language: data?["language"] as! String, neuronName: data?["neuronName"] as! String)
        } else if currentOperationName == "DocumentGraphNeuron.Document.Item.Change" {
            let callBrainControllerNeuron = CallBrainControllerNeuron()
            callBrainControllerNeuron.documentChangeItem(sourceName: sourceName, documentGraphChangeItemRequest: data?["documentGraphChangeItemRequest"] as! DocumentGraphChangeItemRequest, language: ApplicationSetting.DocumentLanguage!, neuronName: data?["neuronName"] as! String)
        } else if currentOperationName == "DocumentGraphNeuron.Document.Item.Delete" {
            let callBrainControllerNeuron = CallBrainControllerNeuron()
            callBrainControllerNeuron.documentDeleteItem(sourceName: sourceName, documentGraphDeleteItemRequest: data?["documentGraphDeleteItemRequest"] as! DocumentGraphDeleteItemRequest, language: ApplicationSetting.DocumentLanguage!, neuronName: data?["neuronName"] as! String)
        } else if currentOperationName == "DocumentGraphNeuron.DocumentItem.Get" {
            let callBrainControllerNeuron = CallBrainControllerNeuron()
            //            CallBrainControllerNeuron.delegateMap.removeAll()
            //            CallBrainControllerNeuron.delegateMap["DocumentItem.Get.Index"] = data?["DocumentItem.Get.Index"] as! Int
            //            CallBrainControllerNeuron.delegateMap["DocumentItem.Get.SubIndex"] = data?["DocumentItem.Get.SubIndex"] as! Int
            //            CallBrainControllerNeuron.delegateMap["DocumentItem.Get.Section"] = data?["DocumentItem.Get.Section"] as! Int
            //            CallBrainControllerNeuron.delegateMap["DocumentItem.Get.Sender"] = data?["DocumentItem.Get.Sender"]
            //            CallBrainControllerNeuron.delegateMap["DocumentItem.Get.SenderObject"] = data?["DocumentItem.Get.SenderObject"]
            //            if data?["DocumentItem.Get.SenderObject"] is UVCPhoto {
            //                let uvcPhoto = data?["DocumentItem.Get.SenderObject"] as! UVCPhoto
            //                CallBrainControllerNeuron.delegateMap["DocumentItem.Get.ObjectName"] = uvcPhoto.optionObjectName
            let typeRequest = data?["typeRequest"] as! GetDocumentItemOptionRequest
            callBrainControllerNeuron.getType(sourceName: sourceName, typeRequest: typeRequest)
            //            }
            //            if data?["DocumentItem.Get.SenderObject"] is UVCText {
            //                let uvcText = data?["DocumentItem.Get.SenderObject"] as! UVCText
            //                CallBrainControllerNeuron.delegateMap["DocumentItem.Get.ObjectName"] = uvcText.optionObjectName
            //                callBrainControllerNeuron.getType(type: uvcText.optionObjectName, category: uvcText.optionObjectCategoryIdName, language: ApplicationSetting.DocumentLanguage!, fromText: "", sortedBy: "name", limitedTo: 50, isAll: false, searchText: "")
            //            }
            //
        }else if currentOperationName == "DocumentGraphNeuron.DocumentItem.Search" {
            let callBrainControllerNeuron = CallBrainControllerNeuron()
            let typeRequest = data?["typeRequest"] as! GetDocumentItemOptionRequest
            callBrainControllerNeuron.getType(sourceName: sourceName, typeRequest: typeRequest)
        } else if currentOperationName == "DocumentGraphNeuron.Document.Get.InterfacePhoto" {
            let callBrainControllerNeuron = CallBrainControllerNeuron()
            callBrainControllerNeuron.getDocumentInterfacePhoto(sourceName: sourceName, getDocumentInterfacePhotoRequest: data?["getDocumentInterfacePhotoRequest"] as! GetDocumentInterfacePhotoRequest)
        }
    }
    
    
    public func setTabBarItems(item: [String]) {
        for (index, it) in item.enumerated() {
            tabBarController?.tabBar.items![index].title = it.capitalized
            #if targetEnvironment(macCatalyst)
            tabBarController?.tabBar.items![index].setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Helvetica-Bold",
            size: CGFloat( UVCTextSizeType.Regular.size)), NSAttributedString.Key.foregroundColor: UIColor.gray], for: .normal)
            tabBarController?.tabBar.items![index].setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Helvetica-Bold", size: CGFloat( UVCTextSizeType.Regular.size)), NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
//            tabBarController?.tabBar.items![index].
//            tabBarController?.tabBar.items![index].setBadgeTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
//            tabBarController?.tabBar.items![index].setBadgeTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
            #endif
        }
    }
    
    public override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return uvcDocumentGraphModelList.count
    }
    
    public override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return uvcDocumentGraphModelList[section].uvcViewModel.count
    }
    
    public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! DetailViewCell
        
        
        // Configure the cell
        cell.searchInProgress = documentItemSearchInProgress
        cell.index = indexPath.row
        cell.section = indexPath.section
        cell.delegate = uvcViewController
        if indexPath.item == 1 && indexPath.section == 2 && ApplicationSetting.DocumentType! != "UDCDocumentType.DocumentItem" {
            if uvcDocumentGraphModelList[2].uvcViewModel[1].uvcViewItemCollection.uvcPhoto.count > 0 {
                if UIDevice.current.orientation.isLandscape {
                    let width = Double(900)
                    let height = Double(340)
                    uvcDocumentGraphModelList[2].uvcViewModel[1].uvcViewItemCollection.uvcPhoto[0].uvcMeasurement[2].value = width
                    uvcDocumentGraphModelList[2].uvcViewModel[1].uvcViewItemCollection.uvcPhoto[0].uvcMeasurement[3].value = height
                } else {
                    if uvcDocumentGraphModelList[2].uvcViewModel[1].uvcViewItemCollection.uvcPhoto[0].uvcMeasurement[2].value > 670 {
                        let quaterWidth = uvcDocumentGraphModelList[2].uvcViewModel[1].uvcViewItemCollection.uvcPhoto[0].uvcMeasurement[2].value / 4
                        let quaterHeight = uvcDocumentGraphModelList[2].uvcViewModel[1].uvcViewItemCollection.uvcPhoto[0].uvcMeasurement[3].value / 4
                        let height = quaterHeight * 3
                        let width = (quaterWidth * 3) - 20
                        uvcDocumentGraphModelList[2].uvcViewModel[1].uvcViewItemCollection.uvcPhoto[0].uvcMeasurement[2].value = width
                        uvcDocumentGraphModelList[2].uvcViewModel[1].uvcViewItemCollection.uvcPhoto[0].uvcMeasurement[3].value = height
                    }
                }
            }
        }
        do {
            // Diplay the cell based on the current document map view template (name, name and description, etc.,)
            print("section: \(indexPath.section)")
            let uvcViewModel = uvcDocumentGraphModelList[indexPath.section]
            cell.level = uvcViewModel.level
            
            try cell.configure(with: uvcViewModel, index: indexPath.row, isEditableMode: isEditableMode)
        } catch {
            print(error)
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section > uvcDocumentGraphModelList.count - 1 {
            return CGSize(width: 0, height: 0)
        }
        let uvcViewModel = uvcDocumentGraphModelList[indexPath.section]
        var width = uvcViewModel.getTextWidth(index: indexPath.item, section: indexPath.section, isParentNode: uvcDocumentGraphModelList[indexPath.section].isChildrenAllowed && indexPath.item != 0)
        var height = uvcViewModel.getTextHeight(index: indexPath.item, section: indexPath.section, isParentNode: uvcDocumentGraphModelList[indexPath.section].isChildrenAllowed && indexPath.item != 0)
        
        
        return CGSize(width: width, height: height)
    }
    
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//            super.traitCollectionDidChange(previousTraitCollection)
////        print("triat: outside")
//        if isPopup {
//            setRightButton(name: ["UDCOptionMapNode.Done"])
//        } else {
//            setRightButton(name: ["UDCOptionMapNode.Elipsis"])
//        }
//        if uvcDocumentGraphModelList.count == 0 {
//            return
//        }
//        
//        for section in 0...uvcDocumentGraphModelList.count - 1 {
//            
//            for (uvcvmIndex, uvcvm) in uvcDocumentGraphModelList[section].uvcViewModel.enumerated() {
////                print("triat: type \(uvcvm.uvcViewItemType)")
//                if uvcvm.uvcViewItemType == "UVCViewItemType.Photo" {
//                    if uvcDocumentGraphModelList[section].uvcViewModel[uvcvmIndex].uvcViewItemCollection.uvcPhoto[0].borderColor.isEmpty {
////                    print("triat: inside \(section)-\(uvcvmIndex)")
//                        collectionView.reloadItems(at: [NSIndexPath(item: uvcvmIndex, section: section) as IndexPath])
//                    }
//                }
//            }
////            collectionView.layoutIfNeeded()
//        }
//    }
    
    public func getNodeAt(uvcOptionViewModelArray: [UVCOptionViewModel], index: Int, level: Int, currentLevel: Int) -> UVCOptionViewModel? {
        for uvcovm in uvcOptionViewModelArray {
            if level == currentLevel {
                return uvcOptionViewModelArray[index]
            }
            if uvcovm.children.count > 0 {
                let uvcOptionViewModelReturn = getNodeAt(uvcOptionViewModelArray: uvcovm.children, index: index, level: level, currentLevel: currentLevel + 1)
                if uvcOptionViewModelReturn != nil {
                    return uvcOptionViewModelReturn
                }
            }
        }
        
        return nil
    }
    
    public func checkChildrenFound(path: String) -> Bool {
        for uvcdm in uvcDocumentGraphModelList {
            if uvcdm.pathIdName[0].joined(separator: "->") == path {
                return uvcdm.childrenId.count > 0
            }
        }
        
        return false
    }
    
    public func checkPathFound(path: String) -> Bool {
        for uvcdm in uvcDocumentGraphModelList {
            if uvcdm.pathIdName[0].joined(separator: "->") == path {
                return true
            }
        }
        
        return false
    }
    public func attachChildrenToNode(path: String, uvcOptionViewModelArray: inout [UVCOptionViewModel], children: [UVCOptionViewModel], rightBarButton: [String]) {
        for uvcovm in uvcOptionViewModelArray {
            if uvcovm.pathIdName[0].joined(separator: "->") == path {
                uvcovm.children.removeAll()
                uvcovm.children.append(contentsOf: children)
                return
            }
            if uvcovm.childrenId.count > 0 {
                attachChildrenToNode(path: path, uvcOptionViewModelArray: &uvcovm.children, children: children, rightBarButton: rightBarButton)
            }
        }
    }
    
    public func getSelectedItemsAt(path: String, uvcOptionViewModelArray: [UVCOptionViewModel], selectedItem: inout [UVCOptionViewModel]) {
        for uvcovm in uvcOptionViewModelArray {
            if uvcovm.pathIdName[0].joined(separator: "->") == path {
                for child in uvcovm.children {
                    if child.isSelected {
                        selectedItem.append(child)
                    }
                }
            }
            if uvcovm.childrenId.count > 0 {
                getSelectedItemsAt(path: path, uvcOptionViewModelArray: uvcovm.children, selectedItem: &selectedItem)
            }
        }
    }
    
    func showOptionPopover(category: String, width: Int, height: Int, sender: Any?, delegate: UIPopoverPresentationControllerDelegate, optionLabel: [String], optionSelection: [Bool], searchOptionDelegate: SearchOptionDelegate) {
        currentOptionCategory = category
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navigationController = storyboard.instantiateViewController(
            withIdentifier: "SearchOptionNavigationController") as! UINavigationController
        // Use the popover presentation style for your view controller.
        navigationController.modalPresentationStyle = .popover
        let optionViewController = navigationController.viewControllers[0] as! SearchOption
        
        // Specify the anchor point for the popover.
        navigationController.popoverPresentationController!.delegate = delegate
        
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
        }
        optionViewController.width = width
        optionViewController.height = height
        optionViewController.setOptionLabel(optionLabel: optionLabel)
        optionViewController.setOptionSelection(optionSelection: optionSelection)
        optionViewController.delegate = searchOptionDelegate
        // Present the view controller (in a popover).
        self.present(navigationController, animated: true)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    
    func showPopover(category: String, uvcOptionViewModel: [UVCOptionViewModel]?, width: Int, height: Int, sender: Any?, delegate: UIPopoverPresentationControllerDelegate, optionDelegate: OptionViewControllerDelegate, goToOption: String, isDismissedAutomatically: Bool, optionViewControllerName: String, rightButton: [String], idName: String, operationName: String?, documentGraphItemSearchRequest: DocumentGraphItemSearchRequest?, documentGraphItemReferenceRequest: DocumentGraphItemReferenceRequest?, typeRequest: GetDocumentItemOptionRequest?, documentGraphItemViewData: DocumentGraphItemViewData?, documentMapSearchDocumentRequest: DocumentMapSearchDocumentRequest?) {
        
        currentOptionCategory = category
        let optionViewController: OptionViewController?
        
        if optionViewNavigationController == nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            optionViewNavigationController = storyboard.instantiateViewController(
                withIdentifier: "OptionNavigationController") as! UINavigationController
        }
        // Use the popover presentation style for your view controller.
        optionViewNavigationController!.modalPresentationStyle = .popover
        optionViewController = optionViewNavigationController!.viewControllers[0] as! OptionViewController
        
        optionViewController!.delegate = optionDelegate
        optionViewController!.goToPath = goToOption
        // Specify the anchor point for the popover.
        optionViewNavigationController!.popoverPresentationController!.delegate = delegate
        //        if (UIDevice.current.userInterfaceIdiom == .pad) {
        //        } else {
        //            optionViewNavigationController!.popoverPresentationController!.permittedArrowDirections = [.down, .up]
        //        }
        if sender == nil {
            optionViewNavigationController!.popoverPresentationController!.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: CGFloat(width), height: CGFloat(0))
            
            
            //                CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY,width: width,height: height)
            optionViewNavigationController!.popoverPresentationController?.sourceView = self.view
            optionViewNavigationController!.popoverPresentationController!.permittedArrowDirections = []
            
        } else {
            optionViewNavigationController!.popoverPresentationController!.permittedArrowDirections = [.down, .up, .right, .left]
            
            if sender is UIBarButtonItem {
                //            if delegate is DetailViewController {
                //                navigationController.popoverPresentationController!.barButtonItem = navigationItem.rightBarButtonItem
                //            } else {
                optionViewNavigationController!.popoverPresentationController!.barButtonItem  = (sender as! UIBarButtonItem)
                //            }
            } else if sender is UILabel {
                let uiLabel = (sender as! UILabel)
                optionViewNavigationController!.popoverPresentationController!.sourceRect = uiLabel.bounds
                optionViewNavigationController!.popoverPresentationController?.sourceView = uiLabel
            } else if sender is UITextField {
                let uiTextField = (sender as! UITextField)
                optionViewNavigationController!.popoverPresentationController!.sourceRect = uiTextField.bounds
                optionViewNavigationController!.popoverPresentationController?.sourceView = uiTextField
            } else if sender is UIImageView {
                let uiImageView = (sender as! UIImageView)
                optionViewNavigationController!.popoverPresentationController!.sourceRect = uiImageView.bounds
                optionViewNavigationController!.popoverPresentationController?.sourceView = uiImageView
            } else if sender is UIButton {
                let uiButton = (sender as! UIButton)
                optionViewNavigationController!.popoverPresentationController!.sourceRect = uiButton.bounds
                optionViewNavigationController!.popoverPresentationController?.sourceView = uiButton
            }
        }
        let uvcOptionView = UVCOptionView()
        uvcOptionView.width = width
        uvcOptionView.height = height
        uvcOptionView.title = category
        uvcOptionView.idName = idName
        uvcOptionView.rightButton = rightButton
        for ol in optionLabel {
            uvcOptionView.optionLabel[ol.key] = ol.value
        }
        if uvcOptionViewModel != nil {
            uvcOptionView.uvcOptionViewModelList.append(contentsOf: uvcOptionViewModel!)
            uvcOptionView.uvcOptionViewModel.append(contentsOf:
                uvcOptionViewModel!)
        }
        uvcOptionView.opeartionName = operationName!
        uvcOptionView.documentGraphItemSearchRequest = documentGraphItemSearchRequest
        uvcOptionView.documentGraphItemReferenceRequest = documentGraphItemReferenceRequest
        uvcOptionView.documentMapSearchDocumentRequest = documentMapSearchDocumentRequest
        uvcOptionView.typeRequest = typeRequest
        uvcOptionView.documentGraphItemViewData = documentGraphItemViewData
        uvcOptionView.neuronName = neuronName
        optionViewController!.model = uvcOptionView
        optionViewController!.isModalInPopover = isDismissedAutomatically
        // Present the view controller (in a popover).
        self.dismiss(animated: true) {
            self.present(self.optionViewNavigationController!, animated: true, completion: self.optionViewControllerLoadingCompleted)
        }
    }
    
    private func optionViewControllerLoadingCompleted() {
        uvcViewController.optionViewControllerLoadingCompleted()
    }
    
}


extension UIImage {
    func crop(to:CGSize) -> UIImage {
        
        guard let cgimage = self.cgImage else { return self }
        
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        
        guard let newCgImage = contextImage.cgImage else { return self }
        
        let contextSize: CGSize = contextImage.size
        
        //Set to square
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        let cropAspect: CGFloat = to.width / to.height
        
        var cropWidth: CGFloat = to.width
        var cropHeight: CGFloat = to.height
        
        if to.width > to.height { //Landscape
            cropWidth = contextSize.width
            cropHeight = contextSize.width / cropAspect
            posY = (contextSize.height - cropHeight) / 2
        } else if to.width < to.height { //Portrait
            cropHeight = contextSize.height
            cropWidth = contextSize.height * cropAspect
            posX = (contextSize.width - cropWidth) / 2
        } else { //Square
            if contextSize.width >= contextSize.height { //Square on landscape (or square)
                cropHeight = contextSize.height
                cropWidth = contextSize.height * cropAspect
                posX = (contextSize.width - cropWidth) / 2
            }else{ //Square on portrait
                cropWidth = contextSize.width
                cropHeight = contextSize.width / cropAspect
                posY = (contextSize.height - cropHeight) / 2
            }
        }
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: cropWidth, height: cropHeight)
        
        // Create bitmap image from context using the rect
        guard let imageRef: CGImage = newCgImage.cropping(to: rect) else { return self}
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let cropped: UIImage = UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
        
        UIGraphicsBeginImageContextWithOptions(to, false, self.scale)
        cropped.draw(in: CGRect(x: 0, y: 0, width: to.width, height: to.height))
        let resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resized ?? self
    }
    
}
extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
extension String {
    subscript(i: Int) -> String {
        return String(self[index(startIndex, offsetBy: i)])
    }
}

extension UVCDocumentGraphModel {
    
    private func isNearByPunctuation(text: String) -> Bool {
        if UVCDocumentViewController.punctuation.contains(text) && !isNearByPunctuationWithSpace(text: text) {
            return true
        }
        
        return false
    }
    private func isNearByPunctuationWithSpace(text: String) -> Bool {
        if text == "\\" && text == "||" && text == "&" && text == "<" && text == ">" && text == "(" && text == ")" {
            return true
        }
        
        return false
    }
    public func getTextWidth(index: Int, section: Int, isParentNode: Bool) -> CGFloat {
        var width = CGFloat(0)
        var nonEditableText = false
        var isBold = false
        var isNextPunctuation = false
        var isPunctuation = false
//        var isNextPunctuationWithSpace = false
//        var isPunctuationWithSpace = false
        var font: UIFont?
        if isParentNode {
            font = UIFont(name: "Helvetica", size: CGFloat( 26))
        } else {
            font = UIFont(name: "Helvetica", size: CGFloat( UVCTextSizeType.Regular.size))
        }
        if index > uvcViewModel.count - 1 {
            return width
        }
        var fontAttributes = [NSAttributedString.Key: UIFont]()
        for uvcText in uvcViewModel[index].uvcViewItemCollection.uvcText {

            fontAttributes = [NSAttributedString.Key.font: font!]
            print(uvcText.value)
            if (index + 1 <= uvcViewModel.count - 1 && uvcViewModel.count > 0) && uvcViewModel[index + 1].uvcViewItemCollection.uvcText.count > 0 && !uvcViewModel[index + 1].uvcViewItemCollection.uvcText[0].value.isEmpty {
                if isNearByPunctuation(text: uvcViewModel[index + 1].uvcViewItemCollection.uvcText[0].value[0]) {
                    isNextPunctuation = true
                }
//                if isNearByPunctuationWithSpace(text: uvcViewModel[index + 1].uvcViewItemCollection.uvcText[0].value[0]) {
//                    isNextPunctuationWithSpace = true
//                }
            }
            if !uvcText.value.isEmpty {
                if isNearByPunctuation(text: uvcText.value[0]) {
                    isPunctuation = true
                }
//                if isNearByPunctuationWithSpace(text: uvcText.value[0]) {
//                    isPunctuationWithSpace = true
//                }
            }
            if uvcText.uvcTextStyle.intensity > 50 {
                isBold = true
            }
            if uvcText.isOptionAvailable {
                nonEditableText = true
                if !isNextPunctuation {
                    if !isPunctuation {
                        if uvcText.uvcViewItemType == "UVCViewItemType.Choice" {
                            width += (uvcText.value as! NSString).size(withAttributes: fontAttributes).width + 45
                        } else {
//                            if isBold {
//                                width += (uvcText.value as! NSString).size(withAttributes: fontAttributes).width
//                            } else {
                                width += (uvcText.value as! NSString).size(withAttributes: fontAttributes).width + 10
//                            }
                        }
//                        if isBold {
//                            width += 5
//                        }
//                        if isParentNode {
//                            width += 15
//                        }
                    } else {
//                        if isPunctuationWithSpace {
//                            width = (uvcText.value as! NSString).size(withAttributes: fontAttributes).width + 2
//                        } else {
                            width = 15
//                        }
                    }
                } else {
                    if isBold {
                        width += (uvcText.value as! NSString).size(withAttributes: fontAttributes).width
                    } else {
//                        if isNextPunctuationWithSpace {
//                          width += (uvcText.value as! NSString).size(withAttributes: fontAttributes).width + 10
//                        } else {
                            width += (uvcText.value as! NSString).size(withAttributes: fontAttributes).width + 1
//                        }
                    }
                }
            } else if uvcText.isEditable {
                width += (uvcText.helpText as! NSString).size(withAttributes: fontAttributes).width + 15
            }else {
                nonEditableText = true
                if uvcText.value.count == 1 {
                    width += (uvcText.value as NSString).size(withAttributes: fontAttributes).width + 5
                } else {
                    width += (uvcText.value as NSString).size(withAttributes: fontAttributes).width + 5
                }
            }
        }
        for uvcPhoto in uvcViewModel[index].uvcViewItemCollection.uvcPhoto {
            for uvcMeasurement in uvcPhoto.uvcMeasurement {
                if uvcMeasurement.type == UVCMeasurementType.Width.name {
                    width = width + CGFloat(uvcMeasurement.value)
                    break
                }
            }
        }
        for uvcButton in uvcViewModel[index].uvcViewItemCollection.uvcButton {
            if uvcButton.uvcPhoto != nil {
                for uvcPhoto in uvcViewModel[index].uvcViewItemCollection.uvcPhoto {
                    if uvcPhoto.name == "CheckBox" || uvcPhoto.name == "Elipsis" || uvcPhoto.name == "LeftDirectionArrow" || uvcPhoto.name == "UpDirectionArrow" || uvcPhoto.name == "DownDirectionArrow" || uvcPhoto.name == "RightDirectionArrow" {
                        width += 5
                    }
                }
            } else {
                width += (uvcButton.value as NSString).size(withAttributes: fontAttributes).width + 45
            }
        }
        
        if nonEditableText && !isBold {
            return width
        } else {
            return width + 5
        }
    }
    
    
    public func getTextHeight(index: Int, section: Int, isParentNode: Bool) -> CGFloat {
        var height = CGFloat(0)
        var font: UIFont?
        if isParentNode {
            font = UIFont(name: "Helvetica", size: CGFloat( 24))
        } else {
            font = UIFont(name: "Helvetica", size: CGFloat( UVCTextSizeType.Regular.size))
        }
        let fontAttributes = [NSAttributedString.Key.font: font]
        var rowLength = CGFloat(0)
        if index > uvcViewModel.count - 1 {
            return height
        }
        for uvcText in uvcViewModel[index].uvcViewItemCollection.uvcText {
            height += (uvcText.value as NSString).size(withAttributes: fontAttributes).height
            rowLength = CGFloat(uvcViewModel[index].rowLength!)
        }
        if height == 0 {
            for uvcButton in uvcViewModel[index].uvcViewItemCollection.uvcButton {
                height += (uvcButton.value as NSString).size(withAttributes: fontAttributes).height
            }
            height += 10
        }
        for uvcPhoto in uvcViewModel[index].uvcViewItemCollection.uvcPhoto {
            for uvcMeasurement in uvcPhoto.uvcMeasurement {
                if uvcMeasurement.type == UVCMeasurementType.Height.name {
                    height = height + CGFloat(uvcMeasurement.value)
                    break
                }
            }
        }
        if rowLength > 1 {
            height = rowLength * height
        }
        if isParentNode {
            height += 10
        }
        //        return height + 40
        return height + 5
    }
}
