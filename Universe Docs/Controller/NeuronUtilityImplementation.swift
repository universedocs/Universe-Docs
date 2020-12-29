//
//  NeuronUtilityImplementation.swift
//  Universe Docs Brain
//
//  Created by Kumar Muthaiah on 07/06/20.
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
import UDocsBrain
import UDocsFoodRecipeNeuron
import UDocsTaskNeuron
import UDocsNeuronModel
import UDocsNeuronUtility

public class NeuronUtilityImplementation : NeuronUtilityImplementationBase {
    
    public override init() {
        super.init()
    }
    
    public override func getDendrite(sourceId: String, neuronName: String) -> Neuron? {
        var neuron = super.getDendrite(sourceId: sourceId, neuronName: neuronName)
        if neuron != nil {
            return neuron
        }
        
        if neuronName == FoodRecipeNeuron.getName() {
            neuron = FoodRecipeNeuron.getDendrite(sourceId: sourceId)
        } else if neuronName == TaskNeuron.getName() {
            neuron = TaskNeuron.getDendrite(sourceId: sourceId)
        } else if neuronName == CallBrainControllerNeuron.getName() {
            neuron = CallBrainControllerNeuron.getDendrite(sourceId: sourceId)
        }
        
        return neuron
    }
    
    public override func callNeuron(neuronRequest: NeuronRequest) -> Bool {
        var called = super.callNeuron(neuronRequest: neuronRequest)
        if called {
            return called
        }
        
        if neuronRequest.neuronTarget.name == FoodRecipeNeuron.getName() {
            let neuron = FoodRecipeNeuron.getDendrite(sourceId: neuronRequest.neuronSource._id)
            neuron.setDendrite(neuronRequest: neuronRequest, udbcDatabaseOrm: udbcDatabaseOrm!,  neuronUtility: self)
            called = true
        } else if neuronRequest.neuronTarget.name == TaskNeuron.getName() {
            let neuron = TaskNeuron.getDendrite(sourceId: neuronRequest.neuronSource._id)
            neuron.setDendrite(neuronRequest: neuronRequest, udbcDatabaseOrm: udbcDatabaseOrm!,  neuronUtility: self)
            called = true
        }
        
        return called
    }
    
    public override func getNeuronName(udcDocumentTypeIdName: String) -> String? {
        var name = super.getNeuronName(udcDocumentTypeIdName: udcDocumentTypeIdName)
        if name != nil {
            return name
        }
        
        if udcDocumentTypeIdName == "UDCDocumentType.RecipeNeuron" {
            name = FoodRecipeNeuron.getName()
        } else if udcDocumentTypeIdName == "UDCDocumentType.Task" {
            name = TaskNeuron.getName()
        } else if udcDocumentTypeIdName == "UDCDocumentType.CallBrainControllerNeuron" {
            name = CallBrainControllerNeuron.getName()
        }
        
        return name
    }
    
    public override func callNeuron(neuronRequest: NeuronRequest, udcDocumentTypeIdName: String) -> Bool {
        var called = super.callNeuron(neuronRequest: neuronRequest, udcDocumentTypeIdName: udcDocumentTypeIdName)
        if called {
            return called
        }
        
        if udcDocumentTypeIdName == "UDCDocumentType.FoodRecipeNeuron" {
            let neuron = FoodRecipeNeuron.getDendrite(sourceId: neuronRequest.neuronSource._id)
            neuron.setDendrite(neuronRequest: neuronRequest, udbcDatabaseOrm: udbcDatabaseOrm!,  neuronUtility: self)
            called = true
        } else if udcDocumentTypeIdName == "UDCDocumentType.Task" {
            let neuron = TaskNeuron.getDendrite(sourceId: neuronRequest.neuronSource._id)
            neuron.setDendrite(neuronRequest: neuronRequest, udbcDatabaseOrm: udbcDatabaseOrm!,  neuronUtility: self)
            called = true
        } else if udcDocumentTypeIdName == "UDCDocumentType.CallBrainControllerNeuron" {
            let neuron = CallBrainControllerNeuron.getDendrite(sourceId: neuronRequest.neuronSource._id)
            neuron.setDendrite(neuronRequest: neuronRequest, udbcDatabaseOrm: udbcDatabaseOrm!,  neuronUtility: self)
            called = true
        }
        
        return called
    }
}
