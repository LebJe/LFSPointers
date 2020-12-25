//
//  Extensions.swift
//
//
//  Created by Jeff Lebrun on 4/14/20.
//

import Foundation

public extension NSRegularExpression {
	/// Checks if this regular  expression matches the supplied `String`.
	///
	/// - Returns: `true` if the `String` matches, otherwise, `false`.
	func matches(_ string: String) -> Bool {
		firstMatch(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count)) != nil
	}
}

// From: https://github.com/apple/swift-crypto/blob/8f4bfa5bc1951440c15710e9e893721aa4b2765c/Sources/crypto-shasum/main.swift#L73
public extension String {
	init(hexEncoding data: Data) {
		self = data.map { byte in
			let s = String(byte, radix: 16)
			switch s.count {
				case 0:
					return "00"
				case 1:
					return "0" + s
				case 2:
					return s
				default:
					fatalError("Weirdly hex encoded byte")
			}
		}.joined()
	}
}
