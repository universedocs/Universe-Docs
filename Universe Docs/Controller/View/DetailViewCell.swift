//
//  DetailViewCell.swift
//  UniversalViewController
//
//  Created by Kumar Muthaiah on 17/12/18.
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
import Foundation
import UIKit
import UDocsBrain
import UDocsViewModel

class DetailViewCell : UICollectionViewCell, UITextFieldDelegate, UVCViewControllerDelegate {
   
    
    var uvcViewController = UVCViewController()
    var delegate: UVCDetailViewCellDelegate?
    var uvcDocumentGraphModel: UVCDocumentGraphModel?
    var searchInProgress: Bool = false
    var index: Int = 0
    var section: Int = 0
    var level: Int = 0
    var width: CGFloat = CGFloat(0.0)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    public func getViewController() -> UVCViewController {
        return uvcViewController
    }

    public func configure(with uvcDocumentGraphModel: UVCDocumentGraphModel, index: Int, isEditableMode: Bool) throws {
        self.uvcDocumentGraphModel = uvcDocumentGraphModel
        uvcViewController.delegate = self
        let stackView = try ((uvcViewController.getView(uvcViewModel: uvcDocumentGraphModel.uvcViewModel[index], view: self, iEditableMode:
            isEditableMode) as? UIStackView)!)
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
        addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 0)
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        

        for uvcUITextField in uvcViewController.uvcUIViewControllerItemCollection.uvcUITextField {
            if uvcUITextField.name.hasSuffix("UDCDocumentItemMapNode.SearchDocumentItems") {
                uvcUITextField.uiTextField.delegate = self
            }
            delegate?.uvcDetalViewCellTextFieldUpdated(uvuiTextField: uvcUITextField, section: section, index: index, level: level, senderModel: uvcDocumentGraphModel)
        }
    }
    
    func uvcViewControllerEvent(uvcViewItemType: String, eventName: String, uvcObject: Any, uiObject: Any) {
        delegate!.detailViewCellEvent(uvcViewItemType: uvcViewItemType, eventName: eventName, uvcObject: uvcObject, uiObject: uiObject, detailViewCell: self)
    }
   
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        let uvcUIText = uvcViewController.uvcUIViewControllerItemCollection.getTextField(tag: textField.tag, name: "")
        delegate?.uvcDetalViewCellReturnPressed(section: section, index: index, level: level, senderModel: uvcDocumentGraphModel, sender: uvcUIText)
        return true
    }
    
//    override var keyCommands: [UIKeyCommand]? {
//        return [
//            UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags: .command, action: #selector(inputLeftArrow)),
//            UIKeyCommand(input: UIKeyCommand.inputRightArrow, modifierFlags: .command, action: #selector(inputRightArrow)),
//            UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags: .command, action: #selector(inputUpArrow)),
//            UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags: .command, action: #selector(inputDownArrow))
//        ]
//    }
//
//    @objc func inputLeftArrow() {
//        print("left")
//    }
//
//    @objc func inputRightArrow() {
//        print("right")
//    }
//
//    @objc func inputUpArrow() {
//        // your code here
//    }
//
//    @objc func inputDownArrow() {
//        // your code here
//    }
}
