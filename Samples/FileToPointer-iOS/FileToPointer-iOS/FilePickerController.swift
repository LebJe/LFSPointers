//
//  FilePickerController.swift
//  FileToPointer-iOS
//
//  Created by Jeff Lebrun on 4/28/20.
//  Copyright © 2020 LFSPointers. All rights reserved.
//

import Foundation
import SwiftUI
import MobileCoreServices

struct FilePickerController: UIViewControllerRepresentable {
	var callback: (URL) -> ()
	
	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}
	
	func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<FilePickerController>) {
		// Update the controller
	}
	
	func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
		print("Making the picker")
		let controller = UIDocumentPickerViewController(documentTypes: [String(kUTTypeText)], in: .open)
		
		controller.delegate = context.coordinator
		print("Setup the delegate \(context.coordinator)")
		
		return controller
	}
	
	class Coordinator: NSObject, UIDocumentPickerDelegate {
		var parent: FilePickerController
		
		init(_ pickerController: FilePickerController) {
			self.parent = pickerController
			print("Setup a parent")
			print("Callback: \(parent.callback)")
		}
		
		func documentPicker(didPickDocumentsAt: [URL]) {
			print("Selected a document: \(didPickDocumentsAt[0])")
			parent.callback(didPickDocumentsAt[0])
		}
		
		func documentPickerWasCancelled() {
			print("Document picker was thrown away :(")
		}
		
		deinit {
			print("Coordinator going away")
		}
	}
}
