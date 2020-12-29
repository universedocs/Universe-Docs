//
//  UVCMesaurementType.swift
//  Universe_Docs_View
//
//  Created by Kumar Muthaiah on 31/10/18.
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

public class UVCMeasurementType {
    static public var None = UVCMeasurementType("uvcTextTemplateType.None", "None")
    static public var XAxis = UVCMeasurementType("UVCMeasurementType.XAxis", "XAxis")
    static public var YAxis = UVCMeasurementType("UVCMeasurementType.YAxis", "YAxis")
    static public var ZAxis = UVCMeasurementType("UVCMeasurementType.ZAxis", "ZAxis")
    static public var Length = UVCMeasurementType("UVCMeasurementType.Length", "Length")
    static public var Width = UVCMeasurementType("UVCMeasurementType.Width", "Width")
    static public var Height = UVCMeasurementType("UVCMeasurementType.Height", "Height")
    static public var Depth = UVCMeasurementType("UVCMeasurementType.Depth", "Depth")
    static public var Angle = UVCMeasurementType("UVCMeasurementType.Angle", "Angle")
    static public var ElasticityWidthPercent = UVCMeasurementType("UVCMeasurementType.ElasticityWidthPercent", "Elasticity Width Percent")
    static public var ElasticityHeightPercent = UVCMeasurementType("UVCMeasurementType.ElasticityHeightPercent", "Elasticity Height Percent")
    static public var TextPercent = UVCMeasurementType("UVCMeasurementType.TextPercent", "Text Percent")
    public var name: String = ""
    public var description: String = ""
    
    private init(_ name: String, _ description: String) {
        self.name = name
        self.description = description
    }
   
}
