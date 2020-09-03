//
//  Extensions.swift
//  
//
//  Created by Jeff Lebrun on 4/14/20.
//

import Foundation

public extension NSRegularExpression {
	/// Checks if this regular  expression matches the supplied `String`.
	/// - Returns: `true` if the `String` matches, otherwise, `false`.
	func matches(_ string: String) -> Bool {
		firstMatch(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count)) != nil
	}
}
