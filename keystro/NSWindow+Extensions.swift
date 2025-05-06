//
//  NSWindow+Extensions.swift
//  keystro
//
//  Created by Ahmad Arif Aulia Sutarman on 25/03/25.
//

import Cocoa

extension NSWindow {
    static func makeKeyAndTransparent() -> NSWindow {
        let window = NSWindow(
            contentRect: .zero,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.isOpaque = false
        window.backgroundColor = .clear
        window.makeKeyAndOrderFront(nil)
        return window
    }
}
