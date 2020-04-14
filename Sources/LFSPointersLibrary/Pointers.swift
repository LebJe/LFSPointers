//
//  File.swift
//  
//
//  Created by Jeff Lebrun on 4/14/20.
//

import Foundation
import Files
import SwiftShell

struct LFSPointer {
	let version: String
	let oid: String
	let size: Int
	
	static func pointers() -> [LFSPointer] {
		[]
	}
}
