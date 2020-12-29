//
//  File.swift
//  UniversalViewController
//
//  Created by Kumar Muthaiah on 23/12/18.
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
import Foundation
import UDocsBrain
import UDocsViewModel

public class UVCProgressIndicatorController {
    
    public func getView(uvcProgressIndicator: UVCProgressIndicator, view: UIView, uvcUIViewControllerCollection: UVCUIViewControllerItemCollection, uvcViewItemTag: Int, iEditableMode: Bool) -> UIView {
        let uvcMeasurementArray = uvcProgressIndicator.uvcMeasurement
        var xAxis = 0
        var yAxis = 0
        var width = 0
        var height = 0
        for uvcMeasurement in uvcMeasurementArray {
            if uvcMeasurement.type == UVCMeasurementType.XAxis.name {
                xAxis = Int(uvcMeasurement.value)
            } else if uvcMeasurement.type == UVCMeasurementType.YAxis.name {
                yAxis = Int(uvcMeasurement.value)
            } else if uvcMeasurement.type == UVCMeasurementType.Width.name {
                width = Int(uvcMeasurement.value)
            } else if uvcMeasurement.type == UVCMeasurementType.Height.name {
                height = Int(uvcMeasurement.value)
            }
        }
        
        
        let indicator: UIActivityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        indicator.frame = CGRect(x: CGFloat(xAxis), y: CGFloat(yAxis), width: CGFloat(width), height: CGFloat(height))
        indicator.color = .green
        
        let uvcUIProgressIndicator = UVCUIProgressIndicator()
        uvcUIProgressIndicator.uiActivityIndicatorView = indicator
        uvcUIProgressIndicator.name = uvcProgressIndicator.name
        uvcUIViewControllerCollection.uvcUIProgressIndicator.append(uvcUIProgressIndicator)
        
        return indicator
    }
    
}
