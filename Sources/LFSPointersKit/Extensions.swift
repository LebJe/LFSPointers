//
//  Extensions.swift
//
//
//  Created by Jeff Lebrun on 4/14/20.
//

import Files
import Foundation

// MARK: - Public Extensions.

public extension NSRegularExpression {
	/// Checks if this regular  expression matches the supplied `String`.
	///
	/// - Returns: `true` if the `String` matches, otherwise, `false`.
	func matches(_ string: String) -> Bool {
		self.firstMatch(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count)) != nil
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

extension LFSPointer: CustomDebugStringConvertible {
	public var debugDescription: String {
		"version \(self.version)\noid sha256:\(self.oid)\nsize \(self.size)"
	}
}

// MARK: - Private Extensions.

extension LFSPointer {
	static func fileNames(
		folder: Folder,
		filename: [URL],
		recursive: Bool = false,
		statusClosure: ((URL, Status) -> Void)? = nil
	) throws -> [LFSPointer] {
		recursive ?
			try folder.files.recursive.compactMap({ file in
				if filename.contains(file.url) {
					do {
						statusClosure?(file.url, .generating)
						return try Self(fromFile: file.url)
					} catch {
						statusClosure?(file.url, .error(error))
						throw error
					}
				}

				return nil
			})
			:
			try folder.files.compactMap({ file in
				if filename.contains(file.url) {
					do {
						statusClosure?(file.url, .generating)
						return try Self(fromFile: file.url)
					} catch {
						statusClosure?(file.url, .error(error))
						throw error
					}
				}

				return nil
			})
	}

	static func singleFile(file: File, statusClosure: ((URL, Status) -> Void)? = nil) throws -> Self {
		do {
			statusClosure?(file.url, .generating)

			return try Self(fromFile: file.url)
		} catch {
			statusClosure?(file.url, .error(error))

			throw error
		}
	}

	static func all(
		folder: Folder,
		recursive: Bool = false,
		statusClosure: ((URL, Status) -> Void)? = nil
	) throws -> [Self] {
		recursive ?
			try folder.files.recursive.map({ file in
				do {
					statusClosure?(file.url, .generating)
					return try Self(fromFile: file.url)
				} catch {
					statusClosure?(file.url, .error(error))
					throw error
				}
			})
			: try folder.files.map({ file in
				do {
					statusClosure?(file.url, .generating)
					return try Self(fromFile: file.url)
				} catch {
					statusClosure?(file.url, .error(error))
					throw error
				}
			})
	}
}
