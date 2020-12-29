//
//  UVCPictureController.swift
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
import Foundation
import UIKit
import Toucan
import UDocsBrain
import UDocsViewModel


public class UVCPhotoController {
    public var delegate: UVCViewControllerDelegate?
    public var uvcViewController: UVCViewController?
    
    public func getView(uvcPhoto: UVCPhoto, view: UIView, uvcUIViewControllerCollection: UVCUIViewControllerItemCollection, uvcViewItemTag: Int, iEditableMode: Bool) -> UIView {
        let uvcMeasurementArray = uvcPhoto.uvcMeasurement
        var xAxis = 0
        var yAxis = 0
        var width: CGFloat = CGFloat(0)
        var height: CGFloat = CGFloat(0)
        for uvcMeasurement in uvcMeasurementArray {
            if uvcMeasurement.type == UVCMeasurementType.XAxis.name {
                xAxis = Int(uvcMeasurement.value)
            } else if uvcMeasurement.type == UVCMeasurementType.YAxis.name {
                yAxis = Int(uvcMeasurement.value)
            } else if uvcMeasurement.type == UVCMeasurementType.Width.name {
                width = CGFloat(uvcMeasurement.value)
            } else if uvcMeasurement.type == UVCMeasurementType.Height.name {
                height = CGFloat(uvcMeasurement.value)
            }
        }
       
        let uiView = UIView(frame: CGRect(x: CGFloat(xAxis), y: CGFloat(yAxis), width: width, height: height))
        var image: UIImage?
        if uvcPhoto.name.hasPrefix("Name") || uvcPhoto.name.hasPrefix("PhotoName") {
            image = UIImage()
        } else {
            image = UIImage(named: uvcPhoto.name)
        }

        
        var imageView = UIImageView(frame: CGRect(x: CGFloat(xAxis), y: CGFloat(yAxis), width: width, height: height))
        imageView.contentMode = .scaleAspectFit
        if uvcPhoto.binaryData != nil {
            imageView.image = UIImage(data: uvcPhoto.binaryData!)
//            imageView.alpha = 0.1
        } else {
            imageView.image = image
        }
        var borderWidth = CGFloat(uvcPhoto.borderWidth)
        if !uvcPhoto.isBorderEnabled {
            borderWidth = 0
        }
//        if view.traitCollection.userInterfaceStyle == .dark {
//            imageView.layer.borderColor = UIColor.white.cgColor
//        } else {
//            imageView.layer.borderColor = UIColor.black.cgColor
//        }
        
        if uvcPhoto.maskName != nil {
//            UVCPhotoController.getProcessedImage(uvcPhoto: uvcPhoto, uiImageView: &imageView)
            if UVCPhotoController.isImageMask(uvcPhoto: uvcPhoto) && !uvcPhoto.isReloaded {
                imageView.layer.borderWidth = CGFloat(borderWidth);
                imageView.layer.borderColor = getUIColor(uvcColorName: uvcPhoto.borderColor, type: "Foreground").cgColor
            } else {
                imageView.layer.borderWidth = CGFloat(borderWidth);
                imageView.layer.borderColor = getUIColor(uvcColorName: uvcPhoto.borderColor, type: "Foreground").cgColor
            }
        } else {
            imageView.layer.borderWidth = CGFloat(borderWidth);
            imageView.layer.borderColor = getUIColor(uvcColorName: uvcPhoto.borderColor, type: "Foreground").cgColor
        }
        
        
        imageView.isUserInteractionEnabled = true
        imageView.tag = uvcViewItemTag
        uiView.addSubview(imageView)
        imageView.leadingAnchor.constraint(equalTo: uiView.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: uiView.trailingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: uiView.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: uiView.bottomAnchor).isActive = true
        
        let uvcUIImageView = UVCUIImageView()
        uvcUIImageView.name = uvcPhoto.name
        uvcUIImageView.uiView = uiView
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        uvcUIImageView.uiView.isUserInteractionEnabled = true
        uvcUIImageView.uiView.addGestureRecognizer(tapGestureRecognizer)
        uvcUIViewControllerCollection.uvcUIImageView.append(uvcUIImageView)
        return uiView
    }
    
    private static func isImageMask(uvcPhoto: UVCPhoto) -> Bool {
        if uvcPhoto.maskName != "UVCPhotoMask.Ellipse" && uvcPhoto.maskName != "UVCPhotoMask.RoundedRectangle" {
            return true
        }
    
        return false
    }
    
//    public static func getProcessedImage(uvcPhoto: UVCPhoto, uiImageView: inout UIImageView) {
//        let toucan = Toucan(image: uiImageView.image! )
//
//        if uvcPhoto.maskName == "UVCPhotoMask.Ellipse" {
//            if uvcPhoto.borderWidth > 0 {
//                let _ = toucan.maskWithEllipse(borderWidth: CGFloat(uvcPhoto.borderWidth), borderColor: UVCPhotoController.getUIColor(uvcColorName: uvcPhoto.borderColor, type: "Foreground"))
//            } else {
//                let _ = toucan.maskWithEllipse()
//            }
//            uiImageView.image = toucan.image
//        } else if uvcPhoto.maskName == "UVCPhotoMask.Diamond" {
//            let path = UIBezierPath()
//            path.move(to: CGPoint(x: 0, y: 50))
//            path.addLine(to: CGPoint(x: 50, y: 0))
//            path.addLine(to: CGPoint(x: 100, y: 50))
//
//            path.addLine(to: CGPoint(x: 50, y: 100))
//            path.close()
//            let _ = toucan.maskWithPath(path: path)
//            uiImageView.image = toucan.image
//        } else if uvcPhoto.maskName == "UVCPhotoMask.RoundedRectangle" {
//            if uvcPhoto.borderWidth > 0 {
//                let _ = toucan.maskWithRoundedRect(cornerRadius: 30, borderWidth: CGFloat(uvcPhoto.borderWidth), borderColor: UVCPhotoController.getUIColor(uvcColorName: uvcPhoto.borderColor, type: "Foreground"))
//            } else {
//                let _ = toucan.maskWithRoundedRect(cornerRadius: 30)
//            }
//            uiImageView.image = toucan.image
//            uiImageView.layer.backgroundColor = UIColor.white.cgColor
//        } else {
//            let _ = toucan.maskWithImage(maskImage: UIImage(named: uvcPhoto.maskName!)!)
//            uiImageView.image = toucan.image
//        }
//
//        if isImageMask(uvcPhoto: uvcPhoto) {
//            uiImageView.layer.borderWidth = 0
//        }
//    }
    
    private func getUIColor(uvcColorName: String?, type: String) -> UIColor {
        if uvcColorName == nil {
            return UVCPhotoController.getDefaultColor(type: type)
        } else {
            if uvcColorName!.isEmpty {
                return UVCPhotoController.getDefaultColor(type: type)
            } else {
                return UIColor(hexString: UVCColor.get(uvcColorName!).hexString)
            }
        }
    }
    
    
    private static func getDefaultColor(type: String) -> UIColor {
        
        if type == "Foreground" {
                        return UIColor { traitCollection in
                            // 2
                            switch traitCollection.userInterfaceStyle {
                            case .dark:
                              // 3
                                print("triat: foreground white")
                                return UIColor.white
                            default:
                              // 4
                                print("triat: foreground black")
                                return UIColor.black
                            }
                        }
                    } else {
                        return UIColor { traitCollection in
                                            // 2
                                            switch traitCollection.userInterfaceStyle {
                                            case .dark:
                                              // 3
                                                return UIColor.black
                                            default:
                                              // 4
                                                return UIColor.white
                                            }
                                        }
                    }
    }
    
    @objc public func imageTapped(_ tapGestureRecognizer: UITapGestureRecognizer) {
        let uiImageView = tapGestureRecognizer.view?.subviews[0] as! UIImageView
        let uvcPhoto = uvcViewController!.getPhoto(tag: uiImageView.tag)
        delegate!.uvcViewControllerEvent(uvcViewItemType: "UVCViewItemType.Photo", eventName: "UVCViewItemEvent.Photo.Taped", uvcObject: uvcPhoto as Any, uiObject: uiImageView)
    }
    
}
