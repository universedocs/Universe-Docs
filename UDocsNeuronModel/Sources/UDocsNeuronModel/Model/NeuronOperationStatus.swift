//
//  NeuronOperationStatus.swift
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

open class NeuronOperationStatus : Codable {
    public var _id: String = ""
    public var status: String = NeuronOperationStatusType.Pending.name
    public var percentageCompleted: Int8 = 0
    public var neuronOperationSuccess: [NeuronOperationSuccess]? = [NeuronOperationSuccess]()
    public var neuronOperationError: [NeuronOperationError]? = [NeuronOperationError]()
    public var neuronOperationWarning: [NeuronOperationWarning]? = [NeuronOperationWarning]()
    
    private enum CodingKeys: CodingKey {
        case _id
        case status
        case percentageCompleted
        case neuronOperationSuccess
        case neuronOperationError
        case neuronOperationWarning
    }
    
}
