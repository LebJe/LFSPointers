//
//  ContentView.swift
//  FileToPointer-iOS
//
//  Created by Jeff Lebrun on 4/28/20.
//  Copyright © 2020 LFSPointers. All rights reserved.
//

import LFSPointersKit
import SwiftUI

struct ContentView: View {
	@State private var selection: Int = 0
	@State var version = ""
	@State var hash = ""
	@State var size = ""
	static let files = ["foo", "bar"]

	var body: some View {
		VStack {
			Picker("Select a File", selection: $selection, content: {
				Text("foo" + ".txt").tag(0)
				Text("bar" + ".txt").tag(1)
			}).padding()

			Button("Generate Pointer") {
				let pointer = try! LFSPointer(fromFile: Bundle.main.url(forResource: ContentView.files[self.selection], withExtension: "txt")!)

				self.version = pointer.version
				self.hash = pointer.oid
				self.size = String(pointer.size)
			}
			.padding(5)
			.background(Color.blue)
			.cornerRadius(5)
			.foregroundColor(.white)
			.padding()

			Text("Version: " + version).padding()
			Text("SHA 256 Hash (oid sha256): \n" + hash).padding()
			Text("Size (in bytes): " + size)
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
