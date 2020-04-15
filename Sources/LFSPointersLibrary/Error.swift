//
//  Error.swift
//  
//
//  Created by Jeff Lebrun on 4/14/20.
//

import Foundation

public enum GitLFSError: Error {
	
	case generic(message: String)
	
	/// Thrown when the output of "git lfs pointer --file=foo.txt" is not recognized.
	case malformedGitLFSCommandOutput(output: String)
}
