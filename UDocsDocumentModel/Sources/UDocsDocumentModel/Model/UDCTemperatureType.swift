//
//  UDCTemperatureType.swift
//  Universe_Docs_Document
//
//  Created by Kumar Muthaiah on 13/11/18.
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
/*
 wikiurl  https://en.wikibooks.org/wiki/Cookbook:Oven_Temperatures
 */
public class UDCTemperatureType : Codable {
    static public var None = UDCTemperatureType("UVCMeasurementType.None", "None")
    static public var Drying = UDCTemperatureType("UVCMeasurementType.Drying", "Drying", [66, 70, 79, 80, 90], ["n/a"])
    static public var VerySlowOrVeryLow = UDCTemperatureType("UVCMeasurementType.VerySlowOrVeryLow", "Very Slow/Very Low", [93, 100, 107, 110, 120, 121, 130], ["1/4", "1/4", "1/4", "1/4", "1/2", "1/2", "1/2"])
    public var _id: String = ""
    public var name: String = ""
    public var description: String = ""
    public var celsius = [Int]()
    public var gasMark = [String]()
    
    private init(_ name: String, _ description: String) {
        self.name = name
        self.description = description
    }
    
    private init(_ name: String, _ description: String, _ celsius: [Int], _ gasMark: [String]) {
        self.name = name
        self.description = description
        self.celsius = celsius
        self.gasMark = gasMark
    }
    
}
