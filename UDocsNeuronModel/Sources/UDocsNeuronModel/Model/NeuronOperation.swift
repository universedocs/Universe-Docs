//
//  NeuronOperation.swift
//  SoftwareBrainController
//
//  Created by Kumar Muthaiah on 05/10/18.
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

open class NeuronOperation : Codable {
    public var _id: String = ""
    public var name: String = ""
    public var synchronus: Bool = false
    public var asynchronus: Bool = false
    public var asynchronusProcess: Bool = false
    public var request: Bool = false
    public var response: Bool = false
    public var acknowledgement: Bool = false
    public var initialize: Bool = false
    public var errorOccured: Bool = false
    public var parent: Bool = false
    public var child: Bool = false
    public var neuronDataId: String = ""
    public var neuronOperationStatusId: String = ""
    public var neuronScheduleId: String = ""
    public var neuronData: NeuronData = NeuronData()
    public var neuronOperationStatus: NeuronOperationStatus = NeuronOperationStatus()
    public var neuronSchedule: NeuronSchedule = NeuronSchedule()
    
    private enum CodingKeys: CodingKey {
        case _id
        case name
        case synchronus
        case asynchronus
        case asynchronusProcess
        case request
        case response
        case acknowledgement
        case initialize
        case errorOccured
        case parent
        case child
        case neuronData
        case neuronOperationStatus
        case neuronSchedule
    }
    
}
