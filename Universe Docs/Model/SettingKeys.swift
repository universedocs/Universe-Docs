//
//  File.swift
//  UniversalViewController
//
//  Created by Kumar Muthaiah on 04/01/19.
//  Copyright © 2019 Kumar Muthaiah. All rights reserved.
//

import Foundation

public class ApplicationSettingKeyType {
    static public var SecurityToken = ApplicationSettingKeyType("ApplicationSettingKeyType.SecurityToken", "Security Token")
    static public var UserName = ApplicationSettingKeyType("ApplicationSettingKeyType.UserName", "User Name")
    static public var Password = ApplicationSettingKeyType("ApplicationSettingKeyType.Password", "Password")
    static public var ProfileId = ApplicationSettingKeyType("ApplicationSettingKeyType.ProfileId", "Profile Id")
    static public var InterfaceLanguage = ApplicationSettingKeyType("ApplicationSettingKeyType.InterfaceLanguage", "Interface Language")
    static public var DocumentLanguage = ApplicationSettingKeyType("ApplicationSettingKeyType.DocumentLanguage", "Document Language")
    static public var DocumentType = ApplicationSettingKeyType("ApplicationSettingKeyType.DocumentType", "Document Type")
    static public var CursorMode = ApplicationSettingKeyType("ApplicationSettingKeyType.CursorMode", "Cursor Mode")
    static public var DeviceUUID = ApplicationSettingKeyType("ApplicationSettingKeyType.DeviceUUID", "Device UUID")
    static public var DeviceModelName = ApplicationSettingKeyType("ApplicationSettingKeyType.DeviceModelName", "Device Model Name")
    public var name: String = ""
    public var description: String = ""
    
    private init(_ name: String, _ description: String) {
        self.name = name
        self.description = description
    }
}
