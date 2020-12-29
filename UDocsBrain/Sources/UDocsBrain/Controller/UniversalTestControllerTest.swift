//
//  UniversalTestControllerTest.swift
//  UniversalBrainController
//
//  Created by Kumar Muthaiah on 25/10/18.
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



public class UniversalTestControllerTest {

//func testTestObject() {
//    // This is an example of a functional test case.
//    // Use XCTAssert and related functions to verify your tests produce the correct results.
//    do {
//        DatabaseOrmConnection.host = "localhost"
//        DatabaseOrmConnection.port = 27017
//        DatabaseOrmConnection.database = "UniversalController"
//        DatabaseOrmConnection.username = "kumar"
//        DatabaseOrmConnection.password = "Rael93*"
//        let databaseOrm = try DatabaseOrm()
//        let utcDatabaseOrm = UDBCDatabaseOrm()
//        utcDatabaseOrm.ormObject = databaseOrm
//        utcDatabaseOrm.type = UDCDatabaseType.MongoDatabase.rawValue
//
//        let utcTestObject = UTCTestObject().json
//        utcTestObject["_id"].stringVallue = try utcDatabaseOrm.generateId()
//        utcTestObject.name = "Universal Controller"
//        utcTestObject.enabled = true
//        utcTestObject.totalItems = 1
//        utcTestObject.enabled = true
//        let utcTestItem = UTCTestItem()
//        utcTestItem._id = try utcDatabaseOrm.generateId()
//        utcTestItem.name = "Add Neuron"
//        utcTestItem.description = "Add Neuron"
//        utcTestItem.enabled = true
//        utcTestItem.totalSuites = 1
//        let utcTestSuite = UTCTestSuite()
//        utcTestSuite._id = try utcDatabaseOrm.generateId()
//        utcTestSuite.name = "Adds Two Numbers"
//        utcTestSuite.enabled = true
//        utcTestSuite.totalCases = 1
//        let utcTestCase = UTCTestCase()
//        utcTestCase._id = try utcDatabaseOrm.generateId()
//        utcTestCase.name = "Add Two Numbers"
//        utcTestCase.enabled = true
//        utcTestCase.totalSteps = 1
//        utcTestCase.enabled = true
//        let addNeuronRequest = try AddNeuronRequest()
//        addNeuronRequest._id = try utcDatabaseOrm.generateId()
//        addNeuronRequest.operand1 = "234"
//        addNeuronRequest.operand2 = "346"
//        let jsonUtilityAddRequest = JsonUtility<AddNeuronRequest>()
//        utcTestCase.utcTestInput.text = jsonUtilityAddRequest.convertAnyObjectToJson(jsonObject: addNeuronRequest)
//        let addNeuronResponse = AddNeuronResponse()
//        addNeuronRequest._id = try utcDatabaseOrm.generateId()
//        addNeuronResponse.result = "580.0"
//        let jsonUtilityAddResponse = JsonUtility<AddNeuronResponse>()
//        utcTestCase.utcTestExpectedOutput.text = jsonUtilityAddResponse.convertAnyObjectToJson(jsonObject: addNeuronResponse)
//        let utcTestStep = UTCTestStep()
//        utcTestStep._id = try utcDatabaseOrm.generateId()
//        utcTestStep.name = "Add Two Numbers"
//        utcTestStep.enabled = true
//        utcTestStep.description = "Given two numbers will add and return the result"
//        utcTestCase.utcTestStep.append(utcTestStep)
//        utcTestSuite.utcTestCase.append(utcTestCase)
//        utcTestItem.utcTestSuite.append(utcTestSuite)
//        utcTestObject.utcTestItem = utcTestItem
//
//        let _ = try utcTestObject.save(udbcDatabaseOrm: utcDatabaseOrm)
//        let utcTest = UTCTest()
//        utcTest._id = try utcDatabaseOrm.generateId()
//        utcTest.enabled = true
//        let _ = try utcTest.save(udbcDatabaseOrm: utcDatabaseOrm)
//
//        defer {
//            do {
//                try databaseOrm.disconnect()
//            } catch {
//                print(error)
//            }
//        }
//    } catch {
//        print(error)
//    }
//}
//
//func testTestObjectCalculator() {
//    // This is an example of a functional test case.
//    // Use XCTAssert and related functions to verify your tests produce the correct results.
//    do {
//        DatabaseOrmConnection.host = "localhost"
//        DatabaseOrmConnection.port = 27017
//        DatabaseOrmConnection.database = "UniversalController"
//        DatabaseOrmConnection.username = "kumar"
//        DatabaseOrmConnection.password = "Rael93*"
//        let databaseOrm = try DatabaseOrm()
//        let utcDatabaseOrm = UDBCDatabaseOrm()
//        utcDatabaseOrm.ormObject = databaseOrm
//        utcDatabaseOrm.type = UDCDatabaseType.MongoDatabase.rawValue
//
//        let utcTestObject = UTCTestObject()
//        utcTestObject._id = try utcDatabaseOrm.generateId()
//        utcTestObject.name = "Universal Controller"
//        utcTestObject.enabled = true
//        utcTestObject.totalItems = 1
//        utcTestObject.enabled = true
//        let utcTestItem = UTCTestItem()
//        utcTestItem._id = try utcDatabaseOrm.generateId()
//        utcTestItem.name = "Calculator Neuron"
//        utcTestItem.description = "Calculator Neuron"
//        utcTestItem.enabled = true
//        utcTestItem.totalSuites = 1
//        let utcTestSuite = UTCTestSuite()
//        utcTestSuite._id = try utcDatabaseOrm.generateId()
//        utcTestSuite.name = "Adds Two Numbers"
//        utcTestSuite.enabled = true
//        utcTestSuite.totalCases = 1
//        let utcTestCase = UTCTestCase()
//        utcTestCase._id = try utcDatabaseOrm.generateId()
//        utcTestCase.name = "Add Two Numbers"
//        utcTestCase.enabled = true
//        utcTestCase.totalSteps = 1
//        utcTestCase.enabled = true
//        let calculatorNeuronRequest = CalculatorNeuronRequest()
//        calculatorNeuronRequest._id = try utcDatabaseOrm.generateId()
//        calculatorNeuronRequest.operand1 = "234"
//        calculatorNeuronRequest.operand2 = "346"
//        calculatorNeuronRequest.type = "add"
//        let jsonUtilityAddRequest = JsonUtility<CalculatorNeuronRequest>()
//        utcTestCase.utcTestInput.text = jsonUtilityAddRequest.convertAnyObjectToJson(jsonObject: calculatorNeuronRequest)
//        let calculatorNeuronResponse = CalculatorNeuronResponse()
//        calculatorNeuronResponse._id = try utcDatabaseOrm.generateId()
//        calculatorNeuronResponse.result = "580.0"
//        let jsonUtilityAddResponse = JsonUtility<CalculatorNeuronResponse>()
//        utcTestCase.utcTestExpectedOutput.text = jsonUtilityAddResponse.convertAnyObjectToJson(jsonObject: calculatorNeuronResponse)
//        let utcTestStep = UTCTestStep()
//        utcTestStep._id = try utcDatabaseOrm.generateId()
//        utcTestStep.name = "Add Two Numbers"
//        utcTestStep.enabled = true
//        utcTestStep.description = "Given two numbers will add and return the result"
//        utcTestCase.utcTestStep.append(utcTestStep)
//        utcTestSuite.utcTestCase.append(utcTestCase)
//        utcTestItem.utcTestSuite.append(utcTestSuite)
//        utcTestObject.utcTestItem = utcTestItem
//
//        let _ = try utcTestObject.save(udbcDatabaseOrm: utcDatabaseOrm)
//        let utcTest = UTCTest()
//        utcTest._id = try utcDatabaseOrm.generateId()
//        utcTest.enabled = true
//        let _ = try utcTest.save(udbcDatabaseOrm: utcDatabaseOrm)
//
//        defer {
//            do {
//                try databaseOrm.disconnect()
//            } catch {
//                print(error)
//            }
//        }
//    } catch {
//        print(error)
//    }
//}
}
