//
//  ContentView.swift
//  keystro
//
//  Created by Ahmad Arif Aulia Sutarman on 25/03/25.
//

import RiveRuntime
import SwiftUI
import AppKit

struct RiveController: NSViewControllerRepresentable {
    let resource: String

    init(resource: String) {
        self.resource = resource
    }

    func makeNSViewController(context: Context) -> AnimationViewController {
        return AnimationViewController(resource: resource)
    }

    func updateNSViewController(_ nsViewController: AnimationViewController, context: Context) {
        // log update
        print("Updating RiveViewController")
    }
}

class AnimationViewController: NSViewController {
    var simpleVM: RiveViewModel
    private var didAppearOnce = false // Add this flag

    init(resource: String) {
        self.simpleVM = RiveViewModel(fileName: resource, fit: .scaleDown, alignment: .center)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        // Reset flag if needed, depending on desired behavior on re-appearance
        // didAppearOnce = false 
        
        // Check if view already has subviews to avoid adding multiple times if viewWillAppear is called again without the view being removed
        if view.subviews.isEmpty {
            let riveView = simpleVM.createRiveView()
            view.addSubview(riveView)
            riveView.frame = view.bounds
        } else {
             // Optionally update frame if view size might change
             view.subviews.first?.frame = view.bounds
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear() // Call super

        guard !didAppearOnce else { return } // Exit if already appeared once
        didAppearOnce = true // Set the flag

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            print("Firing trigger: spawn-in") // Log the trigger attempt
            self?.simpleVM.triggerInput("spawn-in")
            self?.simpleVM.triggerInput("appear", path: "btnred")
            self?.simpleVM.triggerInput("appear", path: "btngreen")
        }
    }
}

class KeystroVM: RiveViewModel {
    init() {
        super.init(fileName: "keystro_app_(whole)")
        let textRunMap = [
            "menuitem-general": "General",
            "menuitem-keystroke": "Keystroke",
            "menuitem-cursor": "Cursor",
            "menuitem-sounds": "Sounds",
            "menuitem-license": "License",
            "menuitem-about": "About",
            "menuitem-exit": "Exit",
        ]
        
        do {
            for (path, text) in textRunMap {
                try super.setTextRunValue("menuitemtext", path: path, textValue: text)
            }
        } catch {
            print("Error setting text value: \(error)")
        }
        
        super.setInput("focused", value: true, path: "menuitem-general")
    }
    
    func view() -> some View {
        return super.view().frame(width: 1400/2, height: 1340/2)
    }
    
    // keystroke shortcut checkbox
    
    var _keystrokeShortcutCheckbox: Bool = false
        
    
    var keystrokeShortcutCheckbox: Bool {
        get {
            return _keystrokeShortcutCheckbox
        }
        set {
            _keystrokeShortcutCheckbox = newValue
            super.setInput("checked", value: newValue, path: "keystroke-checkbox")
        }
    }
    
    // keystroke switch
    
    var _keystrokeSwitch: Bool = false
    
    var keystrokeSwitch: Bool {
        get {
            return _keystrokeSwitch
        }
        set {
            _keystrokeSwitch = newValue
            super.setInput("switch-right", value: newValue, path: "keystroke-switch")
        }
    }
    
    // menu item selection
    
    enum MenuItem: String, CaseIterable {
        case general = "menuitem-general"
        case keystroke = "menuitem-keystroke"
        case cursor = "menuitem-cursor"
        case sounds = "menuitem-sounds"
        case license = "menuitem-license"
        case about = "menuitem-about"
        // Note: "exit" is handled separately as it's not a selectable/focusable state
        
        // Helper to get the Rive path string
        var rivePath: String { self.rawValue }
    }
    
    private var selectedMenuItem: MenuItem = .general {
        didSet {
            print("Selected menu item: \(selectedMenuItem)")
            
            // Reset focus for all menu items
            for item in MenuItem.allCases {
                super.setInput("focused", value: false, path: item.rivePath)
            }
            
            // Set focus for the selected menu item
            super.setInput("focused", value: true, path: selectedMenuItem.rivePath)
        }
    }
    
    // Map event names to menu items for cleaner handling
    private let menuItemClickEvents: [String: MenuItem] = [
        "general-clicked": .general,
        "keystroke-clicked": .keystroke,
        "cursor-clicked": .cursor,
        "sounds-clicked": .sounds,
        "license-clicked": .license,
        "about-clicked": .about
    ]
    
    @objc func onRiveEventReceived(onRiveEvent riveEvent: RiveEvent) {
        if let openUrlEvent = riveEvent as? RiveOpenUrlEvent {
            if let url = URL(string: openUrlEvent.url()) {
                #if os(iOS)
                UIApplication.shared.open(url)
                #else
                NSWorkspace.shared.open(url)
                #endif
            }
        } else if let generalEvent = riveEvent as? RiveGeneralEvent {
            let eventName = generalEvent.name()
            
            // Handle menu item clicks using the map
            if let menuItem = menuItemClickEvents[eventName] {
                print("Received \(eventName) event")
                selectedMenuItem = menuItem
                return // Exit early after handling menu item click
            }
            
            // Handle other events
            switch eventName {
            case "keystroke-shortcut-checkbox-event":
                print("Received keystroke shortcut checkbox event")
                self.keystrokeShortcutCheckbox.toggle() // Use toggle() for brevity
            case "keystroke-switch-event":
                print("Received keystroke switch event")
                self.keystrokeSwitch.toggle() // Use toggle() for brevity
            case "close-button-click-event":
                // hide the window
                if let window = NSApplication.shared.windows.first {
                    window.animator().alphaValue = 0
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        window.animator().alphaValue = 1
                    }
                }
            case "exit-clicked":
                // close the app
                NSApp.terminate(nil)
            default:
                print("Received unhandled general event: \(eventName)")
            }
        }
    }
}

struct ContentView: View {
    
    @StateObject private var kvm = KeystroVM()
    
    var body: some View {
        VStack {
            kvm.view()
        }
        .background(Color.clear)
        .ignoresSafeArea()
    }
}
