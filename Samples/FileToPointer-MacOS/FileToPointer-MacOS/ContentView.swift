//
//  ContentView.swift
//  FileToPointer-MacOS
//
//  Created by Jeff Lebrun on 4/28/20.
//  Copyright © 2020 LFSPointers. All rights reserved.
//

import SwiftUI
import LFSPointersLibrary

struct ContentView: View {
	@State private var url: URL? = nil
	@State private var text = ""
	@State private var showAlert = false
	
	var alert: Alert {
		Alert(title: Text("Error"), message: Text("Unable to generate pointer for the selected file."), dismissButton: .cancel(Text("OK")))
	}
	
    var body: some View {
		VStack {
			Button("Select File") {
				let openPanel = NSOpenPanel()
				
				openPanel.allowsMultipleSelection = false
				openPanel.canChooseDirectories = false
				openPanel.canChooseFiles = true
				openPanel.resolvesAliases = true
				
				//openPanel.title = ""
				
				let result = openPanel.runModal()
				
				if result == .OK {
					self.url = openPanel.url
				
					if let url = self.url {
						do {
							
							let pointer = try LFSPointer(forFile: url)
							self.text = pointer.stringRep
							
							
						} catch let error {
							print(error)
							self.showAlert.toggle()
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
