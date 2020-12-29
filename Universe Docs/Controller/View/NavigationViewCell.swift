//
//  NavigationViewCell.swift
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

class NavigationViewCell : UICollectionViewCell, UVCViewControllerDelegate {
    var uvcViewController = UVCViewController()
    var delegate: UVCNavigationViewCellDelegate?
    var uvcTreeNode: UVCTreeNode?
    var index: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    public func configure(with uvcTreeNode: UVCTreeNode, uvcNavigationTemplateType: String, isEditableMode: Bool) throws {
        self.uvcTreeNode = uvcTreeNode
        uvcViewController.delegate = self
        let stackView = try ((uvcViewController.getView(uvcViewModel: uvcTreeNode.uvcViewModel, view: self, iEditableMode:
            isEditableMode) as? UIStackView)!)
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
        addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 0)
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(textTaped(_:)))
        self.addGestureRecognizer(tapGestureRecognizer)

    }
    
    func uvcViewControllerEvent(uvcViewItemType: String, eventName: String, uvcObject: Any, uiObject: Any) {
        delegate!.navigationViewCellEvent(uvcViewItemType: uvcViewItemType, eventName: eventName, uvcObject: uvcObject, uiObject: uiObject, navigationViewCell: self)
    }
    
    @objc private func textTaped(_ tapGestureRecognizer: UITapGestureRecognizer) {
        let uiView = tapGestureRecognizer.view
        delegate!.navigationViewCellEvent(uvcViewItemType: "UVCViewItemType.TableCell", eventName: "UVCViewItemEvent.Taped", uvcObject: UVCText(), uiObject: uiView, navigationViewCell: self)
    }
    
}
