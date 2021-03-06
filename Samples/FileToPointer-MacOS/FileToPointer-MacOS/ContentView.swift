//
//  ContentView.swift
//  FileToPointer-MacOS
//
//  Created by Jeff Lebrun on 4/28/20.
//  Copyright © 2020 LFSPointers. All rights reserved.
//

import LFSPointersKit
import SwiftUI

struct ContentView: View {
	@State private var url: URL? = nil
	@State private var text = ""
	@State private var showAlert = false

	var alert: Alert {
		Alert(
			title: Text("Error"),
			message: Text("Unable to generate a pointer for the selected file."),
			dismissButton: .cancel(Text("OK"))
		)
	}

	var body: some View {
		VStack {
			Button("Select File") {
				let openPanel = NSOpenPanel()

				openPanel.allowsMultipleSelection = false
				openPanel.canChooseDirectories = false
				openPanel.canChooseFiles = true
				openPanel.resolvesAliases = true

				let result = openPanel.runModal()

				if result == .OK {
					self.url = openPanel.url

					if let url = self.url {
						DispatchQueue.global(qos: .utility).async {
							do {
								let pointer = try LFSPointer(fromFile: url)
								let encoder = JSONEncoder()
								encoder.outputFormatting = [.withoutEscapingSlashes, .prettyPrinted]
								self.text = String(data: try encoder.encode(pointer), encoding: .utf8)!
							} catch {
								print(error)
								self.showAlert.toggle()
							}
						}
					}
				}
			}.padding()

			Text(text)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.alert(isPresented: $showAlert, content: { self.alert })
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
