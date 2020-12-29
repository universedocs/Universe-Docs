//
//  UVCViewGenerator.swift
//  Universe_Docs_View
//
//  Created by Kumar Muthaiah on 22/11/18.
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
import UDocsViewModel

public class UVCViewGenerator {
    let boldIntensity: Double = 51
    let defaultHeight: Double = 31
    let defaultWidth:Double = 200
    let level1And2Size: Double = 24
    let level3OrMoreSize: Double = 18
    public static var modelIdentifier = [String]()
    
    public init() {
        UVCViewGenerator.modelIdentifier.append("")
    }
    
    public func get(title: String, name: String, level: Int, isEditable: Bool) -> UVCText {
        let uvcText = UVCText()
        var uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.XAxis.name
        uvcMeasurement.value = 0
        uvcText.uvcMeasurement.append(uvcMeasurement)
        uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.YAxis.name
        uvcMeasurement.value = 0
        uvcText.uvcMeasurement.append(uvcMeasurement)
        uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.Width.name
        uvcMeasurement.value = defaultWidth
        uvcText.uvcMeasurement.append(uvcMeasurement)
        uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.Height.name
        uvcMeasurement.value = defaultHeight
        uvcText.uvcMeasurement.append(uvcMeasurement)
        uvcText.isEditable = isEditable
        uvcText.value = title
        uvcText.name = name
        uvcText.uvcTextSize.uvcTextSizeType = UVCTextSizeType.Regular.name
        uvcText.uvcViewItemType = "UVCViewItemType.Text"
        uvcText.uvcTextStyle.intensity = boldIntensity
        if level == 0 || level == 1 {
            uvcText.uvcTextSize.value = level1And2Size
        } else {
            uvcText.uvcTextSize.value = level3OrMoreSize
        }
        uvcText.uvcTextTemplateType = UVCTextTemplateType.None.name
        return uvcText
    }
    
    
    public func getSerialNumberText(serialNumber: Int) -> UVCText {
        let uvcViewItem = UVCViewItem()
        let name: String = "SerialNumber-\(NSUUID().uuidString)"
        uvcViewItem.name = name
        let uvcText = getText(name: name, value: "\(serialNumber)", description: "", isEditable: false)
        return uvcText
    }
    
    
    public func getButton(title: String, name: String, pictureName: String?) -> UVCButton {
        let uvcButton = UVCButton()
        var uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.XAxis.name
        uvcMeasurement.value = 0
        uvcButton.uvcMeasurement.append(uvcMeasurement)
        uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.YAxis.name
        uvcMeasurement.value = 0
        uvcButton.uvcMeasurement.append(uvcMeasurement)
        uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.Width.name
        uvcMeasurement.value = defaultWidth
        uvcButton.uvcMeasurement.append(uvcMeasurement)
        uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.Height.name
        uvcMeasurement.value = defaultHeight
        uvcButton.uvcMeasurement.append(uvcMeasurement)
        uvcButton.value = title
        uvcButton.name = name
        uvcButton.isOptionAvailable = true
        
        if pictureName != nil {
            let uvcPhoto = getPhoto(name: pictureName!, description: "", isEditable: false)
            var uvcMeasurement = UVCMeasurement()
            uvcMeasurement.type = UVCMeasurementType.XAxis.name
            uvcMeasurement.value = 0
            uvcPhoto.uvcMeasurement.append(uvcMeasurement)
            uvcMeasurement = UVCMeasurement()
            uvcMeasurement.type = UVCMeasurementType.YAxis.name
            uvcMeasurement.value = 0
            uvcPhoto.uvcMeasurement.append(uvcMeasurement)
            uvcMeasurement = UVCMeasurement()
            uvcMeasurement.type = UVCMeasurementType.Width.name
            uvcMeasurement.value = 60
            uvcPhoto.uvcMeasurement.append(uvcMeasurement)
            uvcMeasurement = UVCMeasurement()
            uvcMeasurement.type = UVCMeasurementType.Height.name
            uvcMeasurement.value = 60
            uvcPhoto.uvcMeasurement.append(uvcMeasurement)
            uvcButton.uvcPhoto = uvcPhoto
        }

        return uvcButton
    }
    
    
    public func getButtonModel(title: String, name: String, level: Int, pictureName: String?, parentId: [String], childrenId: [String], objectIdName: String, objectName: String, objectCategoryIdName: String) -> UVCViewModel {
        let uvcViewModel = UVCViewModel()
        let uvcViewGenerator = UVCViewGenerator()
        let uvcButton = uvcViewGenerator.getButton(title: title, name: name, pictureName: pictureName)
        uvcViewModel.textLength = 6
        uvcButton.optionObjectIdName = objectIdName
        uvcButton.optionObjectName = objectName
        uvcButton.optionObjectCategoryIdName = objectCategoryIdName
        uvcButton.parentId.append(contentsOf: parentId)
        uvcButton.childrenId.append(contentsOf: childrenId)
        uvcViewModel.uvcViewItemCollection.uvcButton.append(uvcButton)
        
        var uvcViewItem = UVCViewItem()
        uvcViewItem.name = "\(name)Table"
        uvcViewItem.type = "UVCViewItemType.Table"
        uvcViewModel.uvcViewItem.append(uvcViewItem)
        uvcViewItem = UVCViewItem()
        uvcViewItem.name = "\(name)Buttons"
        uvcViewItem.type = "UVCViewItemType.Text"
        uvcViewModel.uvcViewItem.append(uvcViewItem)
        
        let uvcTable = UVCTable()
        uvcTable.name = "\(name)Table"
        let uvcTableRow = UVCTableRow()
        let uvcTableColumn = UVCTableColumn()
        uvcViewItem = UVCViewItem()
        uvcViewItem.name = name
        uvcViewItem.type = "UVCViewItemType.Button"
        uvcTableColumn.uvcViewItem.append(uvcViewItem)
        uvcTableRow.uvcTableColumn.append(uvcTableColumn)
        uvcTable.uvcTableRow.append(uvcTableRow)
        uvcViewModel.uvcViewItemCollection.uvcTable.append(uvcTable)
        
        return uvcViewModel
    }
    
    public func generateLineNumbers(uvcViewModel: inout [UVCViewModel], uvcdmIndex: Int, parentId: [String], childrenId: [String], editMode: Bool) {
        uvcViewModel.insert(getLineNumberViewModel(lineNumber: uvcdmIndex + 1, parentId: parentId, childrenId: childrenId, editMode: editMode), at: 0)
    }
    
    public func getLineNumberViewModel(lineNumber: Int, parentId: [String], childrenId: [String], editMode: Bool) -> UVCViewModel {
        let uvcViewModel = UVCViewModel()
        var value = ""
//        if editMode {
            value = "\(String(format: "%02d", lineNumber))   "
//        } else {
//            value = " "
//        }
        
        let name = generateNameWithUniqueId("Name")
        let uvcText = getText(name: name, value: value, description: "", isEditable: false)
        uvcViewModel.textLength = value.count
        uvcText.parentId.append(contentsOf: parentId)
        uvcText.childrenId.append(contentsOf: childrenId)
        uvcText.isEditable = false
        uvcText.uvcViewItemType = "UVCViewItemType.Text"
        uvcText.uvcTextStyle.intensity = 0
        uvcText.uvcTextSize.value = 16
        uvcText.uvcTextStyle.textColor = "UVCColor.Gray"
        uvcText.uvcTextTemplateType = UVCTextTemplateType.None.name
        uvcViewModel.uvcViewItemCollection.uvcText.append(uvcText)
        
        var uvcViewItem = UVCViewItem()
        uvcViewItem.name = "\(name)Table"
        uvcViewItem.type = "UVCViewItemType.Table"
        uvcViewModel.uvcViewItem.append(uvcViewItem)
        uvcViewItem = UVCViewItem()
        uvcViewItem.name = "\(name)Texts"
        uvcViewItem.type = "UVCViewItemType.Text"
        uvcViewModel.uvcViewItem.append(uvcViewItem)
        
        let uvcTable = UVCTable()
        uvcTable.name = "\(name)Table"
        let uvcTableRow = UVCTableRow()
        let uvcTableColumn = UVCTableColumn()
        uvcViewItem = UVCViewItem()
        uvcViewItem.name = name
        uvcViewItem.type = "UVCViewItemType.Text"
        uvcTableColumn.uvcViewItem.append(uvcViewItem)
        uvcTableRow.uvcTableColumn.append(uvcTableColumn)
        uvcTable.uvcTableRow.append(uvcTableRow)
        
        uvcViewModel.uvcViewItemCollection.uvcTable.append(uvcTable)
        uvcViewModel.rowLength = 1
        return uvcViewModel
    }
    
    public func getChoiceModel(uvcChoice: UVCChoice) -> UVCViewModel {
        let uvcViewModel = UVCViewModel()
        let choiceName = generateNameWithUniqueId("UVCViewItemType.Choice")
        uvcViewModel.name = choiceName
        
        
        var uvcViewItem = UVCViewItem()
        uvcViewItem.name = "\(uvcChoice.name)Table"
        uvcViewItem.type = "UVCViewItemType.Table"
        uvcViewModel.uvcViewItem.append(uvcViewItem)
        uvcViewItem = UVCViewItem()
        uvcViewItem.name = "\(uvcChoice.name)Choices"
        uvcViewItem.type = "UVCViewItemType.Text"
        uvcViewModel.uvcViewItem.append(uvcViewItem)

        let uvcTable = UVCTable()
        uvcTable.name = "\(uvcChoice.name)Table"
        let uvcTableRow = UVCTableRow()
        let uvcTableColumn = UVCTableColumn()
        for uvcChoiceItem in uvcChoice.uvcChoiceItem {
            var generatedName = generateNameWithUniqueId("ChoiceMark")
            let uvcButtonCheckMark = getButton(title: "", name: generatedName, pictureName: "CheckBox")
            var uvcViewItem = UVCViewItem()
            uvcViewItem.name = generatedName
            uvcViewItem.type = "UVCViewItemType.Button"
            uvcTableColumn.uvcViewItem.append(uvcViewItem)
            uvcViewModel.uvcViewItemCollection.uvcButton.append(uvcButtonCheckMark)
            uvcViewModel.textLength! += 6
            
            generatedName = generateNameWithUniqueId("Name")
            let uvcText = getText(name: generatedName, value: uvcChoiceItem.name, description: "", isEditable: true)
            uvcText.isOptionAvailable = true
            uvcText.isEditable = uvcChoice.isEditable
            uvcText.optionObjectCategoryIdName = uvcChoiceItem.editObjectCategoryIdName
            uvcText.optionObjectName = uvcChoiceItem.editObjectName
            uvcText.optionObjectIdName = uvcChoiceItem.editObjectIdName
            uvcText.uvcViewItemType = "UVCViewItemType.Choice"
            uvcText.uvcTextSize.value = level1And2Size
            uvcText.uvcTextTemplateType = UVCTextTemplateType.None.name
            var uvcMeasurement = UVCMeasurement()
            uvcMeasurement.type = UVCMeasurementType.XAxis.name
            uvcMeasurement.value = 0
            uvcText.uvcMeasurement.append(uvcMeasurement)
            uvcMeasurement = UVCMeasurement()
            uvcMeasurement.type = UVCMeasurementType.YAxis.name
            uvcMeasurement.value = 0
            uvcText.uvcMeasurement.append(uvcMeasurement)
            uvcMeasurement = UVCMeasurement()
            uvcMeasurement.type = UVCMeasurementType.Width.name
            uvcMeasurement.value = 60
            uvcText.uvcMeasurement.append(uvcMeasurement)
            uvcMeasurement = UVCMeasurement()
            uvcMeasurement.type = UVCMeasurementType.Height.name
            uvcMeasurement.value = 60
            uvcText.uvcMeasurement.append(uvcMeasurement)
            uvcViewItem = UVCViewItem()
            uvcViewItem.name = generatedName
            uvcViewItem.type = "UVCViewItemType.Text"
            uvcTableColumn.uvcViewItem.append(uvcViewItem)
            uvcViewModel.uvcViewItemCollection.uvcText.append(uvcText)
            uvcViewModel.textLength! += uvcText.value.count
        }
        uvcTableRow.uvcTableColumn.append(uvcTableColumn)
        uvcTable.uvcTableRow.append(uvcTableRow)
        uvcViewModel.uvcViewItemCollection.uvcTable.append(uvcTable)
        
        
        
        uvcViewModel.rowLength = 1
        
        return uvcViewModel
    }
    
    public func getCategoryView(value: String, language: String, parentId: [String], childrenId: [String], nodeId: [String], sentenceIndex: [Int], wordIndex: [Int], objectId: String, objectName: String, objectCategoryIdName: String, level: Int) -> [UVCViewModel] {
        var uvcViewModel = [UVCViewModel]()
        
        var uvcm = UVCViewModel()
        uvcm.name = ""
        uvcm.description = ""
        uvcm.language = language
        
        // View items
        
        var uvcViewItem = UVCViewItem()
        uvcViewItem.name = "RecipeItemCategoryTable"
        uvcViewItem.type = "UVCViewItemType.Table"
        uvcm.uvcViewItem.append(uvcViewItem)
        uvcViewItem = UVCViewItem()
        uvcViewItem.name = "RecipeItemCategoryTexts"
        uvcViewItem.type = "UVCViewItemType.Text"
        uvcm.uvcViewItem.append(uvcViewItem)
        
        let uvcTable = UVCTable()
        uvcTable.name = "RecipeItemCategoryTable"
        
        let uvcTableRow = UVCTableRow()
        let uvcTableColumn = UVCTableColumn()
        
        
        let uvcViewGenerator = UVCViewGenerator()
//        if level > 0 && wordIndex[0] == 0 {
//            let generatedNameSpacer = uvcViewGenerator.generateNameWithUniqueId("Spacer")
//            let uvcPhoto = uvcViewGenerator.getPhoto(name: generatedNameSpacer, description: "", isEditable: false)
//            var uvcMeasurement = UVCMeasurement()
//            uvcMeasurement.type = UVCMeasurementType.XAxis.name
//            uvcMeasurement.value = 0
//            uvcPhoto.uvcMeasurement.append(uvcMeasurement)
//            uvcMeasurement = UVCMeasurement()
//            uvcMeasurement.type = UVCMeasurementType.YAxis.name
//            uvcMeasurement.value = 0
//            uvcPhoto.uvcMeasurement.append(uvcMeasurement)
//            uvcMeasurement = UVCMeasurement()
//            uvcMeasurement.type = UVCMeasurementType.Width.name
//            uvcMeasurement.value = Double(level) * 25
//            uvcPhoto.uvcMeasurement.append(uvcMeasurement)
//            uvcMeasurement = UVCMeasurement()
//            uvcMeasurement.type = UVCMeasurementType.Height.name
//            uvcMeasurement.value = 0
//            uvcPhoto.uvcMeasurement.append(uvcMeasurement)
//            uvcm.uvcViewItemCollection.uvcPhoto.append(uvcPhoto)
//            uvcViewItem = UVCViewItem()
//            uvcViewItem.name = generatedNameSpacer
//            uvcViewItem.type = "UVCViewItemType.Photo"
//            uvcTableColumn.uvcViewItem.append(uvcViewItem)
//        }
        let uvcText = uvcViewGenerator.get(title: value, name: "Name", level: level, isEditable: false)
        uvcText.uvcTextStyle.textColor = UVCColor.get(level: level)!.name
        uvcText.optionObjectIdName = objectId
        uvcText.optionObjectName = objectName
        uvcText.optionObjectCategoryIdName = objectCategoryIdName
        uvcText.parentId.append(contentsOf: parentId)
        uvcText.childrenId.append(contentsOf: childrenId)
        uvcText.isOptionAvailable = true
        if UVCViewGenerator.modelIdentifier[0] == "x86_64" {
            uvcText.uvcTextSize.uvcTextSizeType = UVCTextSizeType.ExtraLarge.name
        } else {
            uvcText.uvcTextSize.uvcTextSizeType = UVCTextSizeType.Regular.name
        }
        uvcText._id = nodeId[0]
        
        var uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.XAxis.name
        uvcMeasurement.value = 0
        uvcText.uvcMeasurement.append(uvcMeasurement)
        uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.YAxis.name
        uvcMeasurement.value = 0
        uvcText.uvcMeasurement.append(uvcMeasurement)
        uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.Width.name
        uvcMeasurement.value = 100
        uvcText.uvcMeasurement.append(uvcMeasurement)
        uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.Height.name
        uvcMeasurement.value = 31
        uvcText.uvcMeasurement.append(uvcMeasurement)
        uvcm.uvcViewItemCollection.uvcText.append(uvcText)
        uvcm.uvcViewItemCollection.uvcTable.append(uvcTable)
        uvcm.textLength = value.count
        uvcm.rowLength = 1
        uvcViewItem = UVCViewItem()
        uvcViewItem.uvcAlignment.uvcPositionType = UVCPositionType.Left.name
        uvcViewItem.name = "Name"
        uvcViewItem.type = "UVCViewItemType.Text"
        uvcTableColumn.uvcViewItem.append(uvcViewItem)
        uvcTableRow.uvcTableColumn.append(uvcTableColumn)
        uvcTable.uvcTableRow.append(uvcTableRow)
        uvcViewModel.append(uvcm)
        
        return uvcViewModel
    }
    
    public func getTitleView(value: String, language: String, parentId: [String], childrenId: [String], nodeId: [String], sentenceIndex: [Int], wordIndex: [Int], isEditable: Bool, objectId: String, objectName: String) -> [UVCViewModel] {
        var uvcViewModel = [UVCViewModel]()
        let uvcm = UVCViewModel()
        uvcm.name = ""
        uvcm.description = ""
        uvcm.language = language
        
        // View items
        
        var uvcViewItem = UVCViewItem()
        uvcViewItem.name = "RecipeItemCategoryTable"
        uvcViewItem.type = "UVCViewItemType.Table"
        uvcm.uvcViewItem.append(uvcViewItem)
        uvcViewItem = UVCViewItem()
        uvcViewItem.name = "RecipeItemCategoryTexts"
        uvcViewItem.type = "UVCViewItemType.Text"
        uvcm.uvcViewItem.append(uvcViewItem)
        
        let uvcTable = UVCTable()
        uvcTable.name = "RecipeItemCategoryTable"
        
        let uvcTableRow = UVCTableRow()
        let uvcTableColumn = UVCTableColumn()
        uvcViewItem = UVCViewItem()
        uvcViewItem.uvcAlignment.uvcPositionType = UVCPositionType.Left.name
        uvcViewItem.name = "Name"
        uvcViewItem.type = "UVCViewItemType.Text"
        uvcTableColumn.uvcViewItem.append(uvcViewItem)
        uvcTableRow.uvcTableColumn.append(uvcTableColumn)
        uvcTable.uvcTableRow.append(uvcTableRow)
        
        let uvcViewGenerator = UVCViewGenerator()
        let uvcText = uvcViewGenerator.get(title: value, name: "Name", level: 1, isEditable: isEditable)
        uvcText.optionObjectIdName = objectId
        uvcText.optionObjectName = objectName
        uvcText.helpText = "Enter Recipe Title"
        uvcText.parentId.append(contentsOf: parentId)
        uvcText.childrenId.append(contentsOf: childrenId)
        uvcText._id = nodeId[0]
        
        uvcText.uvcTextSize.uvcTextSizeType = UVCTextSizeType.Regular.name
        var uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.XAxis.name
        uvcMeasurement.value = 0
        uvcText.uvcMeasurement.append(uvcMeasurement)
        uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.YAxis.name
        uvcMeasurement.value = 0
        uvcText.uvcMeasurement.append(uvcMeasurement)
        uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.Width.name
        uvcMeasurement.value = 100
        uvcText.uvcMeasurement.append(uvcMeasurement)
        uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.Height.name
        uvcMeasurement.value = 31
        uvcText.uvcMeasurement.append(uvcMeasurement)
        uvcm.uvcViewItemCollection.uvcText.append(uvcText)
        uvcm.uvcViewItemCollection.uvcTable.append(uvcTable)
        uvcm.textLength = value.count
        uvcm.rowLength = 1
        uvcViewModel.append(uvcm)
        
        return uvcViewModel
    }
    
    public func getPhotoModel(isEditable: Bool, editObjectCategoryIdName: String, editObjectName: String, editObjectIdName: String, level: Int, isOptionAvailable: Bool, width: Double, height: Double, itemIndex: Int, isCategory: Bool, isBorderEnabled: Bool, isDeviceOptionsAvailable: Bool) -> UVCViewModel {
        let uvcViewModel = UVCViewModel()
        uvcViewModel.uvcViewItemType = "UVCViewItemType.Photo"
        let photoName = generateNameWithUniqueId(uvcViewModel.uvcViewItemType)
        uvcViewModel.name = photoName
        
        var uvcViewItem = UVCViewItem()
        uvcViewItem.name = "\(photoName)Table"
        uvcViewItem.type = "UVCViewItemType.Table"
        uvcViewModel.uvcViewItem.append(uvcViewItem)
        uvcViewItem = UVCViewItem()
        uvcViewItem.name = "\(photoName)Photos"
        uvcViewItem.type = "UVCViewItemType.Photo"
        uvcViewModel.uvcViewItem.append(uvcViewItem)
        
        let uvcTable = UVCTable()
        uvcTable.name = "\(photoName)Table"
        let uvcTableRow = UVCTableRow()
        let uvcTableColumn = UVCTableColumn()

        let generatedName = generateNameWithUniqueId("Name")
        
//        if level > 0 && itemIndex == 0 {
//            let generatedNameSpacer = generateNameWithUniqueId("Spacer")
//            let uvcPhoto = getPhoto(name: generatedNameSpacer, description: "", isEditable: false)
//            uvcPhoto.isOptionAvailable = false
//            var uvcMeasurement = UVCMeasurement()
//            uvcMeasurement.type = UVCMeasurementType.XAxis.name
//            uvcMeasurement.value = 0
//            uvcPhoto.uvcMeasurement.append(uvcMeasurement)
//            uvcMeasurement = UVCMeasurement()
//            uvcMeasurement.type = UVCMeasurementType.YAxis.name
//            uvcMeasurement.value = 0
//            uvcPhoto.uvcMeasurement.append(uvcMeasurement)
//            uvcMeasurement = UVCMeasurement()
//            uvcMeasurement.type = UVCMeasurementType.Width.name
//            uvcMeasurement.value = Double(level) * 25
//            uvcPhoto.uvcMeasurement.append(uvcMeasurement)
//            uvcMeasurement = UVCMeasurement()
//            uvcMeasurement.type = UVCMeasurementType.Height.name
//            uvcMeasurement.value = 0
//            uvcPhoto.uvcMeasurement.append(uvcMeasurement)
//            uvcViewModel.uvcViewItemCollection.uvcPhoto.append(uvcPhoto)
//            uvcViewItem = UVCViewItem()
//            uvcViewItem.name = generatedNameSpacer
//            uvcViewItem.type = "UVCViewItemType.Photo"
//            uvcTableColumn.uvcViewItem.append(uvcViewItem)
//        }
        let uvcPhoto = getPhoto(name: generatedName, description: "", isEditable: isEditable)
        uvcPhoto.optionObjectCategoryIdName = editObjectCategoryIdName
        uvcPhoto.optionObjectName = editObjectName
        uvcPhoto.optionObjectIdName = editObjectIdName
        uvcPhoto.isOptionAvailable = isOptionAvailable
        uvcPhoto.borderColor = UVCColor.get(level: level)!.name
        uvcPhoto.isBorderEnabled = isBorderEnabled
        uvcPhoto.isDeviceOptionsAvailable = isDeviceOptionsAvailable
        if isCategory {
            uvcPhoto.borderWidth = 5
        } else {
            uvcPhoto.borderWidth = 2
        }
        uvcPhoto.maskName = "UVCPhotoMask.RoundedRectangle"
        var uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.XAxis.name
        uvcMeasurement.value = 0
        uvcPhoto.uvcMeasurement.append(uvcMeasurement)
        uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.YAxis.name
        uvcMeasurement.value = 0
        uvcPhoto.uvcMeasurement.append(uvcMeasurement)
        uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.Width.name
        var w = width
        var h = height
        if w == 0 {
            w = 125
        }
        uvcMeasurement.value = w
        uvcPhoto.uvcMeasurement.append(uvcMeasurement)
        uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.Height.name
        if h == 0 {
            h = 60
        }
        uvcMeasurement.value = h
        uvcPhoto.uvcMeasurement.append(uvcMeasurement)
        uvcViewModel.uvcViewItemCollection.uvcPhoto.append(uvcPhoto)
        uvcViewItem = UVCViewItem()
        uvcViewItem.name = generatedName
        uvcViewItem.type = "UVCViewItemType.Photo"
        uvcTableColumn.uvcViewItem.append(uvcViewItem)

        uvcTableRow.uvcTableColumn.append(uvcTableColumn)
        uvcTable.uvcTableRow.append(uvcTableRow)
        uvcViewModel.uvcViewItemCollection.uvcTable.append(uvcTable)
        
        return uvcViewModel
    }
    
    public func getChoiceItemModel(item: String, isEditable: Bool, editObjectCategoryIdName: String, editObjectName: String, editObjectIdName: String) -> UVCViewModel {
        let uvcViewModel = UVCViewModel()
        let choiceName = generateNameWithUniqueId("UVCViewItemType.Choice")
        uvcViewModel.name = choiceName
        
        
        var uvcViewItem = UVCViewItem()
        uvcViewItem.name = "\(item)Table"
        uvcViewItem.type = "UVCViewItemType.Table"
        uvcViewModel.uvcViewItem.append(uvcViewItem)
        uvcViewItem = UVCViewItem()
        uvcViewItem.name = "\(item)Choices"
        uvcViewItem.type = "UVCViewItemType.Text"
        uvcViewModel.uvcViewItem.append(uvcViewItem)
        
        let uvcTable = UVCTable()
        uvcTable.name = "\(item)Table"
        let uvcTableRow = UVCTableRow()
        let uvcTableColumn = UVCTableColumn()
    
        var generatedName = generateNameWithUniqueId("ChoiceMark")
        let uvcButtonCheckMark = getButton(title: "", name: generatedName, pictureName: "CheckBox")
        uvcViewItem = UVCViewItem()
        uvcViewItem.name = generatedName
        uvcViewItem.type = "UVCViewItemType.Button"
        uvcTableColumn.uvcViewItem.append(uvcViewItem)
        uvcViewModel.uvcViewItemCollection.uvcButton.append(uvcButtonCheckMark)
        uvcViewModel.textLength! += 6
        
        generatedName = generateNameWithUniqueId("Name")
        let uvcText = getText(name: generatedName, value: item, description: "", isEditable: true)
        uvcText.isOptionAvailable = true
        uvcText.isEditable = isEditable
        uvcText.optionObjectCategoryIdName = editObjectCategoryIdName
        uvcText.optionObjectName = editObjectName
        uvcText.optionObjectIdName = editObjectIdName
        uvcText.uvcViewItemType = "UVCViewItemType.Choice"
        uvcText.uvcTextSize.value = level1And2Size
        uvcText.uvcTextTemplateType = UVCTextTemplateType.None.name
        var uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.XAxis.name
        uvcMeasurement.value = 0
        uvcText.uvcMeasurement.append(uvcMeasurement)
        uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.YAxis.name
        uvcMeasurement.value = 0
        uvcText.uvcMeasurement.append(uvcMeasurement)
        uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.Width.name
        uvcMeasurement.value = 60
        uvcText.uvcMeasurement.append(uvcMeasurement)
        uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.Height.name
        uvcMeasurement.value = 60
        uvcText.uvcMeasurement.append(uvcMeasurement)
        uvcViewItem = UVCViewItem()
        uvcViewItem.name = generatedName
        uvcViewItem.type = "UVCViewItemType.Text"
        uvcTableColumn.uvcViewItem.append(uvcViewItem)
        uvcViewModel.uvcViewItemCollection.uvcText.append(uvcText)
        uvcViewModel.textLength! += uvcText.value.count
        
        uvcTableRow.uvcTableColumn.append(uvcTableColumn)
        uvcTable.uvcTableRow.append(uvcTableRow)
        uvcViewModel.uvcViewItemCollection.uvcTable.append(uvcTable)
        
        uvcViewModel.rowLength = 1
        
        return uvcViewModel
    }
    
    public func getBlankUnderline(name: String, text: String, textLength: Int, isHelpText: Bool, editObjectCategoryIdName: String, editObjectName: String, editObjectIdName: String) -> UVCViewModel {
        let uvcViewModel = UVCViewModel()
        uvcViewModel.uvcViewItemType = "UVCViewItemType.BlankUnderline"
        let choiceName = generateNameWithUniqueId(uvcViewModel.uvcViewItemType)
        uvcViewModel.name = choiceName
        
        var uvcViewItem = UVCViewItem()
        uvcViewItem.name = "\(name)Table"
        uvcViewItem.type = "UVCViewItemType.Table"
        uvcViewModel.uvcViewItem.append(uvcViewItem)
        uvcViewItem = UVCViewItem()
        uvcViewItem.name = "\(name)BlankUnderline"
        uvcViewItem.type = "UVCViewItemType.BlankUnderline"
        uvcViewModel.uvcViewItem.append(uvcViewItem)
        
        let uvcTable = UVCTable()
        uvcTable.name = "\(name)Table"
        let uvcTableRow = UVCTableRow()
        var uvcTableColumn = UVCTableColumn()
        
        var generatedName = generateNameWithUniqueId("Name")
        let uvcText = getText(name: name, value: text, description: "", isEditable: true)
        uvcText.isOptionAvailable = false
        uvcText.isEditable = true
        uvcText.optionObjectCategoryIdName = editObjectCategoryIdName
        uvcText.optionObjectName = editObjectName
        uvcText.optionObjectIdName = editObjectIdName
        if isHelpText {
            uvcText.uvcTextStyle.textColor = UVCColor.get("UVCColor.Gray").name
        }
        uvcText.uvcTextSize.value = level1And2Size
        uvcText.uvcTextTemplateType = UVCTextTemplateType.None.name
        var uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.XAxis.name
        uvcMeasurement.value = 0
        uvcText.uvcMeasurement.append(uvcMeasurement)
        uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.YAxis.name
        uvcMeasurement.value = 0
        uvcText.uvcMeasurement.append(uvcMeasurement)
        uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.Width.name
        uvcMeasurement.value = 60
        uvcText.uvcMeasurement.append(uvcMeasurement)
        uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.Height.name
        uvcMeasurement.value = 60
        uvcText.uvcMeasurement.append(uvcMeasurement)
        uvcViewItem = UVCViewItem()
        uvcViewItem.name = name
        uvcViewItem.type = "UVCViewItemType.Text"
        uvcViewModel.uvcViewItemCollection.uvcText.append(uvcText)
        uvcTableColumn.uvcViewItem.append(uvcViewItem)
        uvcTableRow.uvcTableColumn.append(uvcTableColumn)
        uvcTable.uvcTableRow.append(uvcTableRow)

        uvcTableColumn = UVCTableColumn()
        generatedName = generateNameWithUniqueId("Name")
        let uvcPhoto = UVCPhoto()
        uvcPhoto.name = ""
        uvcPhoto.optionObjectCategoryIdName = editObjectCategoryIdName
        uvcPhoto.optionObjectName = editObjectName
        uvcPhoto.optionObjectIdName = editObjectIdName
        uvcPhoto.borderColor = "UVCColor.Black"
        uvcPhoto.borderWidth = 1
        uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.XAxis.name
        uvcMeasurement.value = 0
        uvcPhoto.uvcMeasurement.append(uvcMeasurement)
        uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.YAxis.name
        uvcMeasurement.value = 0
        uvcPhoto.uvcMeasurement.append(uvcMeasurement)
        uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.Width.name
        uvcMeasurement.value = Double(textLength) * 30
        uvcPhoto.uvcMeasurement.append(uvcMeasurement)
        uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.Height.name
        uvcMeasurement.value = 2
        uvcPhoto.uvcMeasurement.append(uvcMeasurement)
        uvcViewModel.uvcViewItemCollection.uvcPhoto.append(uvcPhoto)
        uvcViewItem = UVCViewItem()
        uvcViewItem.name = generatedName
        uvcViewItem.type = "UVCViewItemType.Photo"
        uvcTableColumn.uvcViewItem.append(uvcViewItem)
        uvcTableRow.uvcTableColumn.append(uvcTableColumn)
        uvcTable.uvcTableRow.append(uvcTableRow)
        
        uvcViewModel.uvcViewItemCollection.uvcTable.append(uvcTable)
        
        uvcViewModel.rowLength = 1
        
        return uvcViewModel
    }
    
    public func getSearchBoxViewModel(name: String, value: String, level: Int, pictureName: String?, helpText: String, parentId: [String], childrenId: [String], language: String) -> UVCViewModel {
        var textLength = 0
        let uvcViewModel = UVCViewModel()
        
        var uvcViewItem = UVCViewItem()
        uvcViewItem.name = "\(name)Table"
        uvcViewItem.type = "UVCViewItemType.Table"
        uvcViewModel.uvcViewItem.append(uvcViewItem)
        uvcViewItem = UVCViewItem()
        uvcViewItem.name = "\(name)Texts"
        uvcViewItem.type = "UVCViewItemType.Text"
        uvcViewModel.uvcViewItem.append(uvcViewItem)
        
        
        let uvcTable = UVCTable()
        uvcTable.name = "\(name)Table"
        let uvcTableRow = UVCTableRow()
        var uvcTableColumn = UVCTableColumn()

        
//        if level > 0 {
//            let generatedNameSpacer = generateNameWithUniqueId("Spacer")
//            let uvcPhoto = getPhoto(name: generatedNameSpacer, description: "", isEditable: false)
//            var uvcMeasurement = UVCMeasurement()
//            uvcMeasurement.type = UVCMeasurementType.XAxis.name
//            uvcMeasurement.value = 0
//            uvcPhoto.uvcMeasurement.append(uvcMeasurement)
//            uvcMeasurement = UVCMeasurement()
//            uvcMeasurement.type = UVCMeasurementType.YAxis.name
//            uvcMeasurement.value = 0
//            uvcPhoto.uvcMeasurement.append(uvcMeasurement)
//            uvcMeasurement = UVCMeasurement()
//            uvcMeasurement.type = UVCMeasurementType.Width.name
//            uvcMeasurement.value = Double(level) * 25
//            uvcPhoto.uvcMeasurement.append(uvcMeasurement)
//            uvcMeasurement = UVCMeasurement()
//            uvcMeasurement.type = UVCMeasurementType.Height.name
//            uvcMeasurement.value = 0
//            uvcPhoto.uvcMeasurement.append(uvcMeasurement)
//            uvcViewModel.uvcViewItemCollection.uvcPhoto.append(uvcPhoto)
//            uvcViewItem = UVCViewItem()
//            uvcViewItem.name = generatedNameSpacer
//            uvcViewItem.type = "UVCViewItemType.Photo"
//            uvcTableColumn.uvcViewItem.append(uvcViewItem)
//        }
        
        let uvcPhoto = getPhoto(name: "BlackVerticalLine", description: "", isEditable: false)
        var uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.XAxis.name
        uvcMeasurement.value = 0
        uvcPhoto.uvcMeasurement.append(uvcMeasurement)
        uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.YAxis.name
        uvcMeasurement.value = 0
        uvcPhoto.uvcMeasurement.append(uvcMeasurement)
        uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.Width.name
        uvcMeasurement.value = 25
        uvcPhoto.uvcMeasurement.append(uvcMeasurement)
        uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.Height.name
        uvcMeasurement.value = 25
        uvcPhoto.uvcMeasurement.append(uvcMeasurement)
        uvcViewModel.uvcViewItemCollection.uvcPhoto.append(uvcPhoto)
        uvcViewItem = UVCViewItem()
        uvcViewItem.name = "BlackVerticalLine"
        uvcViewItem.type = "UVCViewItemType.Photo"
        uvcTableColumn.uvcViewItem.append(uvcViewItem)

        var uvcText = getText(name: name, value: value, description: "", isEditable: true)
        textLength += helpText.count
        uvcText.parentId.append(contentsOf: parentId)
        uvcText.childrenId.append(contentsOf: childrenId)
        uvcText.isOptionAvailable = false
        uvcText.isEditable = true
        uvcText.uvcViewItemType = "UVCViewItemType.Text"
        uvcText.uvcTextStyle.intensity = boldIntensity
        uvcText.helpText = helpText
        if level == 1 || level == 2 {
            uvcText.uvcTextSize.value = level1And2Size
        } else {
            uvcText.uvcTextSize.value = level3OrMoreSize
        }
        uvcText.uvcTextTemplateType = UVCTextTemplateType.None.name
        uvcViewModel.uvcViewItemCollection.uvcText.append(uvcText)
        uvcViewItem = UVCViewItem()
        uvcViewItem.name = name
        uvcViewItem.type = "UVCViewItemType.Text"

        uvcTableColumn.uvcViewItem.append(uvcViewItem)
        uvcTableRow.uvcTableColumn.append(uvcTableColumn)
        uvcTable.uvcTableRow.append(uvcTableRow)

        uvcViewModel.uvcViewItemCollection.uvcTable.append(uvcTable)
        uvcViewModel.textLength = textLength
        uvcViewModel.rowLength = 1
        
        return uvcViewModel
    }
    
    public func getText(name: String, value: String, description: String, isEditable: Bool) -> UVCText {
        let uvcText = UVCText()
        var uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.XAxis.name
        uvcMeasurement.value = 0
        uvcText.uvcMeasurement.append(uvcMeasurement)
        uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.YAxis.name
        uvcMeasurement.value = 0
        uvcText.uvcMeasurement.append(uvcMeasurement)
        uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.Width.name
        uvcMeasurement.value = defaultWidth
        uvcText.uvcMeasurement.append(uvcMeasurement)
        uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.Height.name
        uvcMeasurement.value = defaultHeight
        uvcText.uvcMeasurement.append(uvcMeasurement)
        uvcText.uvcTextSize.uvcTextSizeType = UVCTextSizeType.Regular.name
        uvcText.name = name
        uvcText.value = value
        uvcText.description = description
        uvcText.isEditable = isEditable
        uvcText.uvcViewItemType = "UVCViewItemType.Text"
        uvcText.uvcTextSize.value = 16
        
        return uvcText
    }
    
    public func getPhoto(name: String, description: String, isEditable: Bool) -> UVCPhoto {
        let uvcPhoto = UVCPhoto()
        uvcPhoto.name = name
        uvcPhoto.uvcText = getText(name: "\(name)Text", value: description, description: "", isEditable: isEditable)
//        uvcPhoto.isDrawn = true
        uvcPhoto.uvcAlignment.uvcMeasurementType = UVCMeasurementType.YAxis.name
        uvcPhoto.uvcAlignment.uvcPositionType = UVCPositionType.Left.name
        return uvcPhoto
    }
    
    public func getViewControllerView(name: [String], title: [String], photo: [String], language: String) -> UVCViewModel {
        let uvcViewModel = UVCViewModel()
        uvcViewModel.name = "ViewControllerToolbar"
        uvcViewModel.description = ""
        uvcViewModel.language = language
        
        var uvcViewItem = UVCViewItem()
        uvcViewItem.name = "\(uvcViewModel.name)Table"
        uvcViewItem.type = "UVCViewItemType.Table"
        uvcViewModel.uvcViewItem.append(uvcViewItem)
        uvcViewItem = UVCViewItem()
        uvcViewItem.name = "\(uvcViewModel.name)Buttons"
        uvcViewItem.type = "UVCViewItemType.Button"
        uvcViewModel.uvcViewItem.append(uvcViewItem)
        
        let uvcTable = UVCTable()
        uvcTable.name = uvcViewItem.name
        let uvcTableRow = UVCTableRow()
        let uvcTableColumn = UVCTableColumn()
        for (titleLocalIndex, titleLocal) in title.enumerated() {
            uvcViewItem = UVCViewItem()
            uvcViewItem.uvcAlignment.uvcPositionType = UVCPositionType.Center.name
            uvcViewItem.name = name[titleLocalIndex]
            uvcViewItem.type = "UVCViewItemType.Button"
            uvcTableColumn.uvcViewItem.append(uvcViewItem)
            
            if photo[titleLocalIndex].isEmpty {
                let uvcButton = getButton(title: titleLocal, name: name[titleLocalIndex], pictureName: nil)
                uvcButton.uvcTextStyle.backgroundColor = "UVCColor.TeaBlue"
                uvcButton.uvcTextStyle.textColor = "UVCColor.Black"
                uvcViewModel.uvcViewItemCollection.uvcButton.append(uvcButton)
            } else if name[titleLocalIndex] == "option" {
                let uvcButton = getButton(title: "", name: name[titleLocalIndex], pictureName: nil)
                uvcButton.uvcTextStyle.backgroundColor = "UVCColor.TeaBlue"
                uvcButton.uvcTextStyle.textColor = "UVCColor.Black"
                let uvcPhoto = getPhoto(name: "Elipsis", description: "", isEditable: false)
                var uvcMeasurement = UVCMeasurement()
                uvcMeasurement.type = UVCMeasurementType.XAxis.name
                uvcMeasurement.value = 0
                uvcPhoto.uvcMeasurement.append(uvcMeasurement)
                uvcMeasurement = UVCMeasurement()
                uvcMeasurement.type = UVCMeasurementType.YAxis.name
                uvcMeasurement.value = 0
                uvcPhoto.uvcMeasurement.append(uvcMeasurement)
                uvcMeasurement = UVCMeasurement()
                uvcMeasurement.type = UVCMeasurementType.Width.name
                uvcMeasurement.value = 60
                uvcPhoto.uvcMeasurement.append(uvcMeasurement)
                uvcMeasurement = UVCMeasurement()
                uvcMeasurement.type = UVCMeasurementType.Height.name
                uvcMeasurement.value = 60
                uvcPhoto.uvcMeasurement.append(uvcMeasurement)
                uvcViewModel.uvcViewItemCollection.uvcPhoto.append(uvcPhoto)
                uvcButton.uvcPhoto = uvcPhoto
                uvcViewModel.uvcViewItemCollection.uvcButton.append(uvcButton)
            } else {
                let uvcButton = getButton(title: "", name: name[titleLocalIndex], pictureName: photo[titleLocalIndex])
                uvcButton.uvcTextStyle.backgroundColor = "UVCColor.TeaBlue"
                uvcButton.uvcTextStyle.textColor = "UVCColor.Black"
                uvcViewModel.uvcViewItemCollection.uvcButton.append(uvcButton)
            }
        }
        uvcTableRow.uvcTableColumn.append(uvcTableColumn)
        uvcTable.uvcTableRow.append(uvcTableRow)
        uvcViewModel.uvcViewItemCollection.uvcTable.append(uvcTable)
        
        return uvcViewModel
    }
    
    public func getTreeNodeViewModel(name: String, description: String, path: String, language: String, isChildrenExist: Bool, uvcDocumentMapViewTemplateType: String, textColor: UVCColor, udcDocumentTypeIdName: String, isOptionAvailable: Bool) -> UVCViewModel {
        let uvcm = UVCViewModel()
        uvcm.name = ""
        uvcm.description = ""
        uvcm.language = language
        
        // View items
        
        var uvcViewItem = UVCViewItem()
        uvcViewItem.name = "NavigationCellTable"
        uvcViewItem.type = "UVCViewItemType.Table"
        uvcm.uvcViewItem.append(uvcViewItem)
        uvcViewItem = UVCViewItem()
        uvcViewItem.name = "NavigationCellTexts"
        uvcViewItem.type = "UVCViewItemType.Text"
        uvcm.uvcViewItem.append(uvcViewItem)
        uvcViewItem = UVCViewItem()
        uvcViewItem.name = "NavigationCellPicture"
        uvcViewItem.type = "UVCViewItemType.Photo"
        uvcm.uvcViewItem.append(uvcViewItem)
        
        var uvcTable = UVCTable()
        uvcTable.name = "NavigationCellTable"
        var uvcTableRow = UVCTableRow()
        var uvcTableColumn = UVCTableColumn()
        uvcViewItem = UVCViewItem()
        uvcViewItem.uvcAlignment.uvcPositionType = UVCPositionType.Center.name
        if isOptionAvailable {
            uvcViewItem.name = "OptionsButton"
            uvcViewItem.type = "UVCViewItemType.Button"
            uvcTableColumn.uvcViewItem.append(uvcViewItem)
        }
        uvcViewItem = UVCViewItem()
        uvcViewItem.name = "PictureTable"
        uvcViewItem.uvcAlignment.uvcPositionType = UVCPositionType.Center.name
        uvcViewItem.type = "UVCViewItemType.Table"
        uvcTableColumn.uvcViewItem.append(uvcViewItem)
        uvcViewItem = UVCViewItem()
        uvcViewItem.name = "TextTable"
        uvcViewItem.uvcAlignment.uvcPositionType = UVCPositionType.Center.name
        uvcViewItem.type = "UVCViewItemType.Table"
        uvcTableColumn.uvcViewItem.append(uvcViewItem)
        if isChildrenExist {
            uvcViewItem = UVCViewItem()
            uvcViewItem.name = "ChildButton"
            uvcViewItem.uvcAlignment.uvcPositionType = UVCPositionType.Center.name
            uvcViewItem.type = "UVCViewItemType.Button"
            uvcTableColumn.uvcViewItem.append(uvcViewItem)
        }
        uvcTableRow.uvcTableColumn.append(uvcTableColumn)
        uvcTable.uvcTableRow.append(uvcTableRow)
        uvcm.uvcViewItemCollection.uvcTable.append(uvcTable)
        
        uvcTable = UVCTable()
        uvcTable.name = "PictureTable"
        uvcTableRow = UVCTableRow()
        uvcTableColumn = UVCTableColumn()
        uvcTableColumn.name = "NavigationCellColumn1"
        uvcViewItem = UVCViewItem()
        uvcViewItem.name = udcDocumentTypeIdName
        uvcViewItem.type = "UVCViewItemType.Photo"
        uvcTableColumn.uvcViewItem.append(uvcViewItem)
        uvcTableRow.uvcTableColumn.append(uvcTableColumn)
        uvcTable.uvcTableRow.append(uvcTableRow)
        uvcm.uvcViewItemCollection.uvcTable.append(uvcTable)
        
        uvcTable = UVCTable()
        uvcTable.name = "TextTable"
        uvcTableRow = UVCTableRow()
        uvcTableColumn = UVCTableColumn()
        uvcTableColumn.name = "NavigationCellColumn2"
        uvcTableColumn.uvcDirectionType = UVCDirectionType.Vertical.name
        uvcViewItem = UVCViewItem()
        uvcViewItem.name = "Name"
        uvcViewItem.type = "UVCViewItemType.Text"
        uvcTableColumn.uvcViewItem.append(uvcViewItem)
        if uvcDocumentMapViewTemplateType == UVCDocumentMapViewTemplateType.NameDescriptionPicture.name || uvcDocumentMapViewTemplateType == "UVCDocumentMapViewTemplateType.NameDescriptionPathPicture" {
            uvcViewItem = UVCViewItem()
            uvcViewItem.name = "Description"
            uvcViewItem.type = "UVCViewItemType.Text"
            uvcViewItem.uvcAlignment.uvcPositionType = UVCPositionType.Left.name
            uvcTableColumn.uvcViewItem.append(uvcViewItem)
        }
        if uvcDocumentMapViewTemplateType == "UVCDocumentMapViewTemplateType.NameDescriptionPathPicture" || uvcDocumentMapViewTemplateType == "UVCDocumentMapViewTemplateType.NamePathPicture" {
            uvcViewItem = UVCViewItem()
            uvcViewItem.name = "Path"
            uvcViewItem.type = "UVCViewItemType.Text"
            uvcViewItem.uvcAlignment.uvcPositionType = UVCPositionType.Left.name
            uvcTableColumn.uvcViewItem.append(uvcViewItem)
        }
        uvcTableRow.uvcTableColumn.append(uvcTableColumn)
        uvcTable.uvcTableRow.append(uvcTableRow)
        uvcm.uvcViewItemCollection.uvcTable.append(uvcTable)
        
        let uvcViewGenerator = UVCViewGenerator()
        
        if isOptionAvailable {
            var uvcPhoto = uvcViewGenerator.getPhoto(name: "ElipsisVertical", description: "Help Information", isEditable: false)
            var uvcMeasurement = UVCMeasurement()
            uvcMeasurement.type = UVCMeasurementType.XAxis.name
            uvcMeasurement.value = 0
            uvcPhoto.uvcMeasurement.append(uvcMeasurement)
            uvcMeasurement = UVCMeasurement()
            uvcMeasurement.type = UVCMeasurementType.YAxis.name
            uvcMeasurement.value = 0
            uvcPhoto.uvcMeasurement.append(uvcMeasurement)
            uvcMeasurement = UVCMeasurement()
            uvcMeasurement.type = UVCMeasurementType.Width.name
            uvcMeasurement.value = 60
            uvcPhoto.uvcMeasurement.append(uvcMeasurement)
            uvcMeasurement = UVCMeasurement()
            uvcMeasurement.type = UVCMeasurementType.Height.name
            uvcMeasurement.value = 60
            uvcPhoto.uvcMeasurement.append(uvcMeasurement)
            uvcm.uvcViewItemCollection.uvcPhoto.append(uvcPhoto)
            
            let optionButton = uvcViewGenerator.getButton(title: "", name: "OptionsButton", pictureName: "")
            optionButton.uvcPhoto = uvcPhoto
            uvcm.uvcViewItemCollection.uvcButton.append(optionButton)
        }

        var uvcPhoto = uvcViewGenerator.getPhoto(name: udcDocumentTypeIdName, description: "Help Information", isEditable: false)
        var uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.XAxis.name
        uvcMeasurement.value = 0
        uvcPhoto.uvcMeasurement.append(uvcMeasurement)
        uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.YAxis.name
        uvcMeasurement.value = 0
        uvcPhoto.uvcMeasurement.append(uvcMeasurement)
        uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.Width.name
        uvcMeasurement.value = 60
        uvcPhoto.uvcMeasurement.append(uvcMeasurement)
        uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.Height.name
        uvcMeasurement.value = 60
        uvcPhoto.uvcMeasurement.append(uvcMeasurement)
        uvcm.uvcViewItemCollection.uvcPhoto.append(uvcPhoto)
        
        var uvcText = uvcViewGenerator.getText(name: "Name", value: name, description: "Name of the recipe", isEditable: false)
        uvcText.uvcTextStyle.textColor = textColor.name
        uvcText.modelValuePath = "name"
        uvcText.isMultiline = true
        uvcText.uvcTextSize.uvcTextSizeType = UVCTextSizeType.Regular.name
        uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.XAxis.name
        uvcMeasurement.value = 0
        uvcText.uvcMeasurement.append(uvcMeasurement)
        uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.YAxis.name
        uvcMeasurement.value = 0
        uvcText.uvcMeasurement.append(uvcMeasurement)
        uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.Width.name
        uvcMeasurement.value = 100
        uvcText.uvcMeasurement.append(uvcMeasurement)
        uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.Height.name
        uvcMeasurement.value = 60
        uvcText.uvcMeasurement.append(uvcMeasurement)
        uvcm.uvcViewItemCollection.uvcText.append(uvcText)
        
        if uvcDocumentMapViewTemplateType == UVCDocumentMapViewTemplateType.NameDescriptionPicture.name || uvcDocumentMapViewTemplateType == "UVCDocumentMapViewTemplateType.NameDescriptionPathPicture" {
            uvcText = uvcViewGenerator.getText(name: "Description", value: description.capitalized, description: "", isEditable: true)
            uvcText.modelValuePath = "description"
            uvcText.isMultiline = true
            uvcText.uvcTextSize.value = 14
            uvcText.uvcTextStyle.textColor = UVCColor.get("UVCColor.Orange").name
            uvcText.uvcTextSize.uvcTextSizeType = UVCTextSizeType.Tiny.name
            uvcm.uvcViewItemCollection.uvcText.append(uvcText)
        }
        
        if uvcDocumentMapViewTemplateType == "UVCDocumentMapViewTemplateType.NameDescriptionPathPicture" || uvcDocumentMapViewTemplateType == "UVCDocumentMapViewTemplateType.NamePathPicture" {
            uvcText = uvcViewGenerator.getText(name: "Path", value: path.capitalized, description: "", isEditable: true)
            uvcText.modelValuePath = "description"
            uvcText.isMultiline = true
            uvcText.uvcTextSize.value = 14
            uvcText.uvcTextStyle.textColor = UVCColor.get("UVCColor.Red").name
            uvcText.uvcTextSize.uvcTextSizeType = UVCTextSizeType.Tiny.name
            uvcm.uvcViewItemCollection.uvcText.append(uvcText)
        }

        if isChildrenExist {
            uvcm.uvcViewItemCollection.uvcButton.append(uvcViewGenerator.getButton(title: ">", name: "ChildButton", pictureName: ""))
        }
        
        return uvcm
    }
    
    public func generateNameWithUniqueId(_ name: String) -> String {
        return "\(name)-\(NSUUID().uuidString)"
    }
    
    public func getOptionViewModel(name: String, description: String, category: String, subCategory: String, language: String, isChildrenExist: Bool, isEditable: Bool, isCheckBox: Bool, photoId: String?, photoObjectName: String?) -> UVCViewModel {
        let uvcm = UVCViewModel()
        uvcm.name = ""
        uvcm.description = ""
        uvcm.language = language
        uvcm.rowLength = 1
        // View items
        
        var uvcViewItem = UVCViewItem()
        uvcViewItem.name = "OptionViewCellTable"
        uvcViewItem.type = "UVCViewItemType.Table"
        uvcm.uvcViewItem.append(uvcViewItem)
        uvcViewItem = UVCViewItem()
        uvcViewItem.name = "OptionViewCellTexts"
        uvcViewItem.type = "UVCViewItemType.Text"
        uvcm.uvcViewItem.append(uvcViewItem)
        
        var uvcTable = UVCTable()
        uvcTable.name = "OptionViewCellTable"
        var uvcTableRow = UVCTableRow()
        var uvcTableColumn = UVCTableColumn()
        if isCheckBox {
            uvcViewItem = UVCViewItem()
            uvcViewItem.uvcAlignment.uvcPositionType = UVCPositionType.Center.name
            uvcViewItem.name = "CheckBoxButton"
            uvcViewItem.type = "UVCViewItemType.Button"
            uvcTableColumn.uvcViewItem.append(uvcViewItem)
        }
        uvcViewItem = UVCViewItem()
        uvcViewItem.name = "TextTable"
        uvcViewItem.uvcAlignment.uvcPositionType = UVCPositionType.Left.name
        uvcViewItem.type = "UVCViewItemType.Table"
        uvcTableColumn.uvcViewItem.append(uvcViewItem)
        if isChildrenExist {
            uvcViewItem = UVCViewItem()
            uvcViewItem.name = "ChildButton"
            uvcViewItem.uvcAlignment.uvcPositionType = UVCPositionType.Center.name
            uvcViewItem.type = "UVCViewItemType.Button"
            uvcTableColumn.uvcViewItem.append(uvcViewItem)
        }
        uvcTableRow.uvcTableColumn.append(uvcTableColumn)
        uvcTable.uvcTableRow.append(uvcTableRow)
        uvcm.uvcViewItemCollection.uvcTable.append(uvcTable)
        
        
        
        uvcTable = UVCTable()
        uvcTable.name = "TextTable"
        uvcTableRow = UVCTableRow()
        uvcTableColumn = UVCTableColumn()
        uvcTableColumn.name = "NavigationCellColumn2"
        uvcTableColumn.uvcDirectionType = UVCDirectionType.Vertical.name
        let generatedName = generateNameWithUniqueId("PhotoName")
        if (photoObjectName != nil) && photoObjectName! == "UDCDocumentItemPhoto" {
            uvcViewItem = UVCViewItem()
            uvcViewItem.name = generatedName
            uvcViewItem.type = "UVCViewItemType.Photo"
            uvcViewItem.uvcAlignment.uvcPositionType = UVCPositionType.Left.name
            uvcTableColumn.uvcViewItem.append(uvcViewItem)
        }
        uvcViewItem = UVCViewItem()
        uvcViewItem.name = "Name"
        uvcViewItem.type = "UVCViewItemType.Text"
        uvcViewItem.uvcAlignment.uvcPositionType = UVCPositionType.Left.name
        uvcTableColumn.uvcViewItem.append(uvcViewItem)
        if !subCategory.isEmpty {
            uvcm.rowLength = uvcm.rowLength! + 1
        uvcViewItem = UVCViewItem()
        uvcViewItem.name = "SubCategory"
        uvcViewItem.type = "UVCViewItemType.Text"
        uvcViewItem.uvcAlignment.uvcPositionType = UVCPositionType.Left.name
        uvcTableColumn.uvcViewItem.append(uvcViewItem)
        }
        
        if !category.isEmpty {
            uvcm.rowLength = uvcm.rowLength! + 1
        uvcViewItem = UVCViewItem()
        uvcViewItem.name = "Category"
        uvcViewItem.type = "UVCViewItemType.Text"
        uvcViewItem.uvcAlignment.uvcPositionType = UVCPositionType.Left.name
        uvcTableColumn.uvcViewItem.append(uvcViewItem)
        }
        uvcTableRow.uvcTableColumn.append(uvcTableColumn)
        uvcTable.uvcTableRow.append(uvcTableRow)
        uvcm.uvcViewItemCollection.uvcTable.append(uvcTable)
        
        let uvcViewGenerator = UVCViewGenerator()
        var uvcMeasurement = UVCMeasurement()
        if isCheckBox {
            let optionButton = uvcViewGenerator.getButton(title: "", name: "CheckBoxButton", pictureName: "")
            
            let uvcPhoto = uvcViewGenerator.getPhoto(name: "", description: "Help Information", isEditable: false)
            uvcPhoto.optionObjectName = "dummy"
            uvcPhoto.optionObjectIdName = "dummy"
            
            uvcMeasurement.type = UVCMeasurementType.XAxis.name
            uvcMeasurement.value = 0
            uvcPhoto.uvcMeasurement.append(uvcMeasurement)
            uvcMeasurement = UVCMeasurement()
            uvcMeasurement.type = UVCMeasurementType.YAxis.name
            uvcMeasurement.value = 0
            uvcPhoto.uvcMeasurement.append(uvcMeasurement)
            uvcMeasurement = UVCMeasurement()
            uvcMeasurement.type = UVCMeasurementType.Width.name
            uvcMeasurement.value = 60
            uvcPhoto.uvcMeasurement.append(uvcMeasurement)
            uvcMeasurement = UVCMeasurement()
            uvcMeasurement.type = UVCMeasurementType.Height.name
            uvcMeasurement.value = 60
            uvcPhoto.uvcMeasurement.append(uvcMeasurement)
            optionButton.uvcPhoto = uvcPhoto
            uvcm.uvcViewItemCollection.uvcButton.append(optionButton)
        }
        
        if (photoObjectName != nil) && photoObjectName! == "UDCDocumentItemPhoto" {
            let uvcPhoto = getPhoto(name: generatedName, description: "", isEditable: isEditable)
            uvcPhoto.optionObjectCategoryIdName = category
            uvcPhoto.optionObjectName = photoObjectName!
            uvcPhoto.optionObjectIdName = photoId!
            uvcPhoto.borderColor = "UVCColor.Green"
            uvcPhoto.borderWidth = 5
            uvcPhoto.maskName = "UVCPhotoMask.RoundedRectangle"
            uvcMeasurement = UVCMeasurement()
            uvcMeasurement.type = UVCMeasurementType.XAxis.name
            uvcMeasurement.value = 0
            uvcPhoto.uvcMeasurement.append(uvcMeasurement)
            uvcMeasurement = UVCMeasurement()
            uvcMeasurement.type = UVCMeasurementType.YAxis.name
            uvcMeasurement.value = 0
            uvcPhoto.uvcMeasurement.append(uvcMeasurement)
            uvcMeasurement = UVCMeasurement()
            uvcMeasurement.type = UVCMeasurementType.Width.name
            uvcMeasurement.value = 100
            uvcPhoto.uvcMeasurement.append(uvcMeasurement)
            uvcMeasurement = UVCMeasurement()
            uvcMeasurement.type = UVCMeasurementType.Height.name
            uvcMeasurement.value = 50
            uvcPhoto.uvcMeasurement.append(uvcMeasurement)
            uvcm.uvcViewItemCollection.uvcPhoto.append(uvcPhoto)
            uvcm.rowLength = uvcm.rowLength! + 2
        }
        
        var uvcText: UVCText?
        uvcText = uvcViewGenerator.getText(name: "Name", value: name, description: "Name of the recipe", isEditable: isEditable)
        uvcText!.optionObjectName = "dummy"
        uvcText!.optionObjectIdName = "dummy"

        uvcText!.isMultiline = true
        uvcText!.modelValuePath = "name"
        uvcText!.uvcTextStyle.intensity = 51
        uvcText!.uvcTextSize.uvcTextSizeType = UVCTextSizeType.Regular.name
        uvcText!.uvcTextStyle.textColor = UVCColor.get(level: 0)!.name
        uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.XAxis.name
        uvcMeasurement.value = 0
        uvcText!.uvcMeasurement.append(uvcMeasurement)
        uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.YAxis.name
        uvcMeasurement.value = 0
        uvcText!.uvcMeasurement.append(uvcMeasurement)
        uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.Width.name
        uvcMeasurement.value = 100
        uvcText!.uvcMeasurement.append(uvcMeasurement)
        uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.Height.name
        uvcMeasurement.value = 31
        uvcText!.uvcMeasurement.append(uvcMeasurement)
        uvcm.uvcViewItemCollection.uvcText.append(uvcText!)
        
        if !subCategory.isEmpty {
            uvcText = uvcViewGenerator.getText(name: "SubCategory", value: subCategory, description: "", isEditable: true)
            uvcText!.optionObjectName = "dummy"
            uvcText!.optionObjectIdName = "dummy"

            uvcText!.modelValuePath = "description"
            uvcText!.uvcTextSize.uvcTextSizeType = UVCTextSizeType.Regular.name
            uvcText!.uvcTextStyle.textColor = UVCColor.get(level: 2)!.name
            uvcm.uvcViewItemCollection.uvcText.append(uvcText!)
        }
        
        if !category.isEmpty {
            uvcText = uvcViewGenerator.getText(name: "Category", value: category, description: "", isEditable: true)
            uvcText!.optionObjectName = "dummy"
            uvcText!.optionObjectIdName = "dummy"

            uvcText!.modelValuePath = "description"
            uvcText!.uvcTextSize.uvcTextSizeType = UVCTextSizeType.Regular.name
            uvcText!.uvcTextStyle.textColor = UVCColor.get(level: 3)!.name
            uvcm.uvcViewItemCollection.uvcText.append(uvcText!)
        }
        
        if isChildrenExist {
            uvcm.uvcViewItemCollection.uvcButton.append(uvcViewGenerator.getButton(title: ">", name: "ChildButton", pictureName: ""))
        }
        
        return uvcm
    }
    
    public func getOnOff(name: String, isSelected: Bool, isEditable: Bool) -> UVCOnOff {
        let uvcOnOff = UVCOnOff()
        uvcOnOff.name = name
        uvcOnOff.isEditable = isEditable
        uvcOnOff.isSelected = isSelected
        uvcOnOff.uvcText.value = isSelected ? "On" : "Off"
        uvcOnOff.uvcText.isMultiline = true
        uvcOnOff.uvcText.modelValuePath = "name"
        uvcOnOff.uvcText.uvcTextSize.uvcTextSizeType = UVCTextSizeType.Regular.name
        var uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.XAxis.name
        uvcMeasurement.value = 0
        uvcOnOff.uvcText.uvcMeasurement.append(uvcMeasurement)
        uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.YAxis.name
        uvcMeasurement.value = 0
        uvcOnOff.uvcText.uvcMeasurement.append(uvcMeasurement)
        uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.Width.name
        uvcMeasurement.value = 100
        uvcOnOff.uvcText.uvcMeasurement.append(uvcMeasurement)
        uvcMeasurement = UVCMeasurement()
        uvcMeasurement.type = UVCMeasurementType.Height.name
        uvcMeasurement.value = 31
        uvcOnOff.uvcText.uvcMeasurement.append(uvcMeasurement)
        
        return uvcOnOff
    }
}
