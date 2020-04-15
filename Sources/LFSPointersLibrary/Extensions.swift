//
//  Extensions.swift
//  
//
//  Created by Jeff Lebrun on 4/14/20.
//

import Foundation

public extension NSRegularExpression {
	func matches(_ string: String) -> Bool {
		let range = NSRange(location: 0, length: string.utf16.count)
		return firstMatch(in: string, options: [], range: range) != nil
	}
}
