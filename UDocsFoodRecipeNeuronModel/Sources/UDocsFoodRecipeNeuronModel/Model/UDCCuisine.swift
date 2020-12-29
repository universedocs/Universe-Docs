//
//  UDCCuisine.swift
//  Universe Docs Document
//
//  Created by Kumar Muthaiah on 15/02/19.
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


public class UDCCuisine : Codable {
    public var _id: String = ""
    public var idName: String = ""
    public var name: String = ""
    public var description: String = ""
    public var foodSourceLanguage: String = ""
    public var language: String = ""
    public var isNationalFood: Bool = false
    public var isStreetFood: Bool = false
    public var udcCuisineStyleIdName = [String]()
    public var udcCusineHistoricalIdName = [String]()
    public var udcReligionIdName = [String]()
    public var udcCardinalDirectionIdName = [String]()
    public var udcCountryIdName = [String]()
    public var udcStateIdName = [String]()
    public var udcCityIdName = [String]()
    public var udcDistrictIdName = [String]()
    public var udcTownIdName = [String]()
    public var udcVillageIdName = [String]()
    public var udcEthinicGroupIdName = [String]()

    public init() {
        
    }
    
}
