//
//  keystroApp.swift
//  keystro
//
//  Created by Ahmad Arif Aulia Sutarman on 25/03/25.
//

import SwiftUI
import RiveRuntime

@main
struct keystroApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .background(Color.black.opacity(0.01))
                .frame(width: 1400/2, height: 1340/2)
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func application(_ application: NSApplication) -> Bool {
        RenderContextManager.shared().defaultRenderer = RendererType.riveRenderer
        return true
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            window.isOpaque = false
            window.backgroundColor = .clear
            window.styleMask = [.borderless, .resizable]
            
            let titleBarView = DraggableTitleBar(frame: NSRect(x: 0, y: 0, width: window.frame.width, height: 32))
            titleBarView.wantsLayer = true
            titleBarView.layer?.backgroundColor = NSColor.clear.cgColor
            window.contentView?.addSubview(titleBarView)

        }
    }
}
