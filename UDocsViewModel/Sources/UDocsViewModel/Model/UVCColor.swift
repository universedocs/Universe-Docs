//
//  UVCColor.swift
//  Universe_Docs_View
//
//  Created by Kumar Muthaiah on 31/10/18.
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

public class UVCColor : Codable {
    static private var data = [String : UVCColor]()
    public var name: String = ""
    public var description: String = ""
    public var hexString: String = ""
    public var level: Int = -1
    
    private init(_ name: String, _ description: String, _ hexString: String, level: Int = -1) {
        self.name = name
        self.description = description
        self.hexString = hexString
        self.level = level
    }
    
    public static func get(_ name: String) -> UVCColor {
        if UVCColor.data.count == 0 {
            UVCColor.data["UVCColor.Red"] = UVCColor("UVCColor.Red", "Red", "#FF3B30")
            UVCColor.data["UVCColor.LightRed"] = UVCColor("UVCColor.LightRed", "Light Red", "")
            UVCColor.data["UVCColor.DarkRed"] = UVCColor("UVCColor.DarkRed", "Dark Red", "")
            UVCColor.data["UVCColor.Green"] = UVCColor("UVCColor.Green", "Green", "#4CD964")
            UVCColor.data["UVCColor.GlowingGreen"] = UVCColor("UVCColor.LightGreen", "Light Green", "#90ee90")
            UVCColor.data["UVCColor.DarkGreen"] = UVCColor("UVCColor.DarkGreen", "Dark Green", "006400")
            UVCColor.data["UVCColor.Blue"] = UVCColor("UVCColor.Blue", "Blue", "#007AFF")
            UVCColor.data["UVCColor.LightBlue"] = UVCColor("UVCColor.LightBlue", "Light Blue", "#5ac8fa")
            UVCColor.data["UVCColor.TeaBlue"] = UVCColor("UVCColor.TeaBlue", "Tea Blue", "#64d3ff")
            UVCColor.data["UVCColor.DarkBlue"] = UVCColor("UVCColor.DarkBlue", "Dark Blue", "#5856d6")
            UVCColor.data["UVCColor.DeepBlue"] = UVCColor("UVCColor.DeepBlue", "Deep Blue", "#007aff")
            UVCColor.data["UVCColor.Yellow"] = UVCColor("UVCColor.Yellow", "Yellow", "#b58900")
            UVCColor.data["UVCColor.LightYellow"] = UVCColor("UVCColor.LightYellow", "Light Yellow", "feffc3")
            UVCColor.data["UVCColor.DarkYellow"] = UVCColor("UVCColor.DarkYellow", "Dark Yellow", "#fff26d")
            UVCColor.data["UVCColor.White"] = UVCColor("UVCColor.White", "White", "#ffffff")
            UVCColor.data["UVCColor.Black"] = UVCColor("UVCColor.Black", "Black", "#000000")
            UVCColor.data["UVCColor.Orange"] = UVCColor("UVCColor.Orange", "Orange", "#cb4b16")
            UVCColor.data["UVCColor.Purple"] = UVCColor("UVCColor.Purple", "Purple", "#800080")
            UVCColor.data["UVCColor.Pink"] = UVCColor("UVCColor.Pink", "Pink", "#FF2D55")
            UVCColor.data["UVCColor.Gray"] = UVCColor("UVCColor.Gray", "Gray", "#A9A9A9")
            UVCColor.data["UVCColor.Magneta"] = UVCColor("UVCColor.Gray", "Magneta", "#d33682")
            UVCColor.data["UVCColor.Cyan"] = UVCColor("UVCColor.Gray", "Cyan", "#21FFFF")
            UVCColor.data["UVCColor.Plum"] = UVCColor("UVCColor.Gray", "Plum", "#75507b")
            UVCColor.data["UVCColor.Slate"] = UVCColor("UVCColor.Gray", "Slate", "##555753")
            UVCColor.data["UVCColor.Brown"] = UVCColor("UVCColor.Brown", "Brown", "#C0392B")
            UVCColor.data["UVCColor.LightGreen"] = UVCColor("UVCColor.LightGreen", "Light Green", "#9FF1DD")
            UVCColor.data["UVCColor.LightBrown"] = UVCColor("UVCColor.LightBrown", "Light Brown", "#c39b77")
            UVCColor.data["UVCColor.LightBlue"] = UVCColor("UVCColor.LightBlue", "Light Blue", "#addae6")
        }
        
        if name.isEmpty {
            return UVCColor("", "", "")
        }
        return UVCColor.data[name]!
    }
    
    /// Returns colour based on level. Parent: dark color, Child: light color.
    /// Reserved colours: black, white, red, green (button)
    public static func get(level: Int) -> UVCColor? {
        if level == 0 {
            return UVCColor.get("")
        } else if level == 1 {
            return UVCColor.get("")
        } else if level == 2 {
            return UVCColor.get("UVCColor.DarkGreen")
        } else if level == 3 {
            return UVCColor.get("UVCColor.LightGreen")
        } else if level == 4 {
            return UVCColor.get("UVCColor.Blue")
        } else if level == 5 {
            return UVCColor.get("UVCColor.TeaBlue")
        } else if level == 6 {
            return UVCColor.get("UVCColor.Brown")
        } else if level == 7 {
            return UVCColor.get("UVCColor.LightBrown")
        } else if level == 8 {
            return UVCColor.get("UVCColor.Purple")
        } else if level == 9 {
            return UVCColor.get("UVCColor.Pink")
        } else if level == 10 {
            return UVCColor.get("UVCColor.Orange")
        }  else if level == 11 {
            return UVCColor.get("UVCColor.Yellow")
        }  else {
            return nil
        }
    }
    
}

