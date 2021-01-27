//
//  AppDelegate.swift
//  FileToPointer-MacOS
//
//  Created by Jeff Lebrun on 4/28/20.
//  Copyright © 2020 LFSPointers. All rights reserved.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	var window: NSWindow!

	func applicationDidFinishLaunching(_: Notification) {
		// Create the SwiftUI view that provides the window contents.
		let contentView = ContentView()

		// Create the window and set the content view.
		window = NSWindow(
			contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
			styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
			backing: .buffered, defer: false
		)
		window.center()
		self.window.setFrameAutosaveName("Main Window")
		self.window.contentView = NSHostingView(rootView: contentView)
		self.window.makeKeyAndOrderFront(nil)
	}

	func applicationWillTerminate(_: Notification) {
		// Insert code here to tear down your application
	}
}
