//
//  NeuronSessionInterval.swift
//  UniversalBrainController
//
//  Created by Kumar Muthaiah on 15/10/18.
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

open class BrainSchedulerSessionInterval : Codable {
    public var _id: String = ""
    public var milliseconds: UInt = 0
    public var seconds: UInt = 0
    public var minutes: Int8 = 0
    public var hours: Int8 = 0
    public var days: Int32 = 0
    public var years: UInt = 0
    
    private enum CodingKeys: CodingKey {
        case _id
        case milliseconds
        case seconds
        case minutes
        case hours
        case days
        case years
    }
}
