//
//  ContentView.swift
//  shakepie
//
//  Created by Ahmad Arif Aulia Sutarman on 25/03/25.
//

import RiveRuntime
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
//            RiveViewModel(fileName: "voicu_ribbon").view()
            RiveViewModel(fileName: "window", fit: .layout, alignment: .center).view()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.clear)
        .ignoresSafeArea()
    }
}
