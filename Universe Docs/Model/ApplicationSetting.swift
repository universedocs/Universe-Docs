//
//  Settings.swift
//  UniversalViewController
//
//  Created by Kumar Muthaiah on 04/01/19.
//  Copyright © 2019 Kumar Muthaiah. All rights reserved.
//

import Foundation

public class ApplicationSetting {
    
    public static var SecurityToken: String? {
        get { return UserDefaults.standard.string(forKey: ApplicationSettingKeyType.SecurityToken.name) }
        set(value) { UserDefaults.standard.set(value, forKey: ApplicationSettingKeyType.SecurityToken.name) }
    }
    
    public static var UserName: String? {
        get { return UserDefaults.standard.string(forKey: ApplicationSettingKeyType.UserName.name) }
        set(value) { UserDefaults.standard.set(value, forKey: ApplicationSettingKeyType.UserName.name) }
    }
    
    public static var Password: String? {
        get { return UserDefaults.standard.string(forKey: ApplicationSettingKeyType.Password.name) }
        set(value) { UserDefaults.standard.set(value, forKey: ApplicationSettingKeyType.Password.name) }
    }
    
    public static var ProfileId: String? {
        get { return UserDefaults.standard.string(forKey: ApplicationSettingKeyType.ProfileId.name) }
        set(value) { UserDefaults.standard.set(value, forKey: ApplicationSettingKeyType.ProfileId.name) }
    }
    
    public static var InterfaceLanguage: String? {
        get { return UserDefaults.standard.string(forKey: ApplicationSettingKeyType.InterfaceLanguage.name) }
        set(value) { UserDefaults.standard.set(value, forKey: ApplicationSettingKeyType.InterfaceLanguage.name) }
    }
    
    public static var DocumentLanguage: String? {
        get { return UserDefaults.standard.string(forKey: ApplicationSettingKeyType.DocumentLanguage.name) }
        set(value) { UserDefaults.standard.set(value, forKey: ApplicationSettingKeyType.DocumentLanguage.name) }
    }
    
    public static var DocumentType: String? {
        get { return UserDefaults.standard.string(forKey: ApplicationSettingKeyType.DocumentType.name) }
        set(value) { UserDefaults.standard.set(value, forKey: ApplicationSettingKeyType.DocumentType.name) }
    }
    
    public static var CursorMode: String? {
        get { return UserDefaults.standard.string(forKey: ApplicationSettingKeyType.CursorMode.name) }
        set(value) { UserDefaults.standard.set(value, forKey: ApplicationSettingKeyType.CursorMode.name) }
    }
    
    public static var DeviceUUID: String? {
        get { return UserDefaults.standard.string(forKey: ApplicationSettingKeyType.DeviceUUID.name) }
        set(value) { UserDefaults.standard.set(value, forKey: ApplicationSettingKeyType.DeviceUUID.name) }
    }
    
    public static var DeviceModelName: String? {
        get { return UserDefaults.standard.string(forKey: ApplicationSettingKeyType.DeviceModelName.name) }
        set(value) { UserDefaults.standard.set(value, forKey: ApplicationSettingKeyType.DeviceModelName.name) }
    }
    
    public static func deleteAll(exclude: [ApplicationSettingKeyType] = []) {
        let saveKeys = exclude.map({ $0.name })
        for key in UserDefaults.standard.dictionaryRepresentation().keys {
            if !saveKeys.contains(key) {
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
    }
}
