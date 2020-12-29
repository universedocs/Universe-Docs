//  MIT License
//
//  Copyright (c) 2017
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

//
//  PathScanner.swift
//  SwiftPath
//
//  Created by Steven Grosmark on 8/25/17.
//  Copyright © 2017 Steven Grosmark. All rights reserved.
//

import Foundation

class PathScanner {
	let source: String
	private (set) var startIndex: String.Index
	let endIndex: String.Index
	
	private var indexStack:[String.Index]
	
	init(string: String) {
		self.source = string
		startIndex = source.startIndex
		endIndex = source.endIndex
		indexStack = []
	}
	
	func pushLocation() {
		indexStack.append(startIndex)
	}
	func popLocation() {
		startIndex = indexStack.removeLast()
	}
	
	var hasMore: Bool { return startIndex < endIndex }
	
	func mustBe(string: String) -> Bool {
		if matches(string: string) {
			advance(by: string.count)
			return true
		}
		return false
	}
	
	func mustMatch(pattern: String ) -> String? {
		if let match = matches(pattern: pattern) {
			advance(by: match.count)
			return match
		}
		return nil
	}
	
	
	func matches(string: String) -> Bool {
		return source[startIndex..<endIndex].hasPrefix(string)
	}
	
	func matches(pattern: String) -> String? {
		if let found = source.range(of: pattern, options: [.regularExpression, .anchored], range: startIndex..<endIndex) {
			return String(source[found])
		}
		return nil
	}
	
	func skipWhitespace() {
		skip(charactersIn: "\(CharacterSet.whitespaces)")
	}
	
	func skip(_ characters: CharacterSet) {
		skip(charactersIn: "\(characters)")
	}
	
	func skip(charactersIn characters: String) {
		while startIndex < endIndex, characters.contains(source[startIndex]) {
			startIndex = source.index(startIndex, offsetBy: 1)
		}
	}
	
	var contextString: String { return String(source[startIndex..<endIndex]) }
	
	func advance(by amount: Int) {
		startIndex = source.index(startIndex, offsetBy: amount)
	}
}
