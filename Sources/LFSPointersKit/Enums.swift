//
//  Enums.swift
//  
//
//  Created by Jeff Lebrun on 4/16/20.
//

import Foundation

/// The search types to use when filtering files.
public enum SearchTypes {
	
	/// Searches for all files that match any of the filenames in the array.
	case fileNames([URL])
	
	/// Searches for all files whose name matches the regular expression.
	case regex(NSRegularExpression)
	
	/// Searches for all files.
	case all
}


public enum Status {
	case writing(LFSPointer),
		 appending(LFSPointer),
		 generating, error(Error),
		 regexDoesntMatch(NSRegularExpression)
}
