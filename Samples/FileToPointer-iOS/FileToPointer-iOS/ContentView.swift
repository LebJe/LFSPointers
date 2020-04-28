//
//  ContentView.swift
//  FileToPointer-iOS
//
//  Created by Jeff Lebrun on 4/28/20.
//  Copyright © 2020 LFSPointers. All rights reserved.
//

import SwiftUI
import LFSPointersLibrary

struct ContentView: View {
	@State private var selection: Int = 0
	var version = ""
	var hash = ""
	var size = ""
	static let files = ["foo", "bar"]
	
    var body: some View {
		let pointer = try! LFSPointer.pointer(forFile: Bundle.main.url(forResource: ContentView.files[selection], withExtension: "txt")!)
		
		return VStack {
			Picker("Select a File", selection: $selection, content: {
				ForEach(Self.files, id: \.self) {
					Text($0)
				}
			}).padding()
			
			Text(pointer.version)
			Text("oid sha256:" + pointer.oid)
			Text(String(pointer.size))
		}
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
