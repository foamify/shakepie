//
//  DraggableTitleBar.swift
//  keystro
//
//  Created by Ahmad Arif Aulia Sutarman on 25/03/25.
//

import Cocoa

class DraggableTitleBar: NSView {
    override func mouseDown(with event: NSEvent) {
        window?.performDrag(with: event)
    }
}
