//
//  ExampleApp.swift
//  Example
//
//  Created by 王楚江 on 8/11/25.
//

import SwiftUI
import CodeMirror

@main
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView2: View {
    @State var value: String = ""
    var body: some View {
        CodeMirror(value: $value, prompt: String(localized: "Please enter text"))
            .cmLanguage(.constant(.html))
            .cmLineWrapping(.constant(true))
    }
}
