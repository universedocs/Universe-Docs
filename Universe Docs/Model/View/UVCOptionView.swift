//
//  UVCPopoverView.swift
//  UniversalViewController
//
//  Created by Kumar Muthaiah on 03/01/19.
//  Copyright © 2019 Kumar Muthaiah. All rights reserved.
//

import Foundation
import UDocsBrain
import UDocsViewModel
import UDocsDocumentItemNeuronModel
import UDocsDocumentGraphNeuronModel
import UDocsDocumentMapNeuronModel

public class UVCOptionView : Codable {
    public var _id: String = ""
    public var idName: String = ""
    public var width: Int = 0
    public var height: Int = 0
    public var uvcOptionViewModel = [UVCOptionViewModel]()
    public var uvcOptionViewModelList = [UVCOptionViewModel]()
    public var uvcOptionViewModelBackupList = [UVCOptionViewModel]()
    public var title: String = ""
    public var optionLabel = [String: String]()
    public var rightButton = [String]()
    
    // Operaiton for which any one of the below server objects is used to request server for options data
    public var opeartionName: String = ""
    public var neuronName: String = ""
    // Server request objects required to get data from server before displaying options
    public var documentGraphItemSearchRequest: DocumentGraphItemSearchRequest?
    public var documentGraphItemReferenceRequest: DocumentGraphItemReferenceRequest?
    public var typeRequest: GetDocumentItemOptionRequest?
    public var documentGraphItemViewData: DocumentGraphItemViewData?
    public var documentMapSearchDocumentRequest: DocumentMapSearchDocumentRequest?
}
