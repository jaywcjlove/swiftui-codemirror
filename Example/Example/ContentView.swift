//
//  ContentView.swift
//  Example
//
//  Created by 王楚江 on 8/11/25.
//

import SwiftUI
import CodeMirror

let jsonString = """
    {
      "private": true,
      "scripts": {
        "start": "rollup -c"
      },
      "dependencies": {
        "@codemirror/lang-css": "^6.0.0",
        "@codemirror/lang-html": "^6.0.0",
        "@codemirror/lang-javascript": "^6.0.0",
        "@codemirror/lang-json": "^6.0.0",
        "@codemirror/lang-xml": "^6.0.0",
        
        "@codemirror/language-data": "^6.0.0",
        "@codemirror/theme-one-dark": "^6.0.0",
        
        "@rollup/plugin-node-resolve": "^15.0.2",
        "@rollup/plugin-terser": "^0.4.0",
        "codemirror": "^6.0.0",
        "rollup": "^4.0.0",
        "rollup-plugin-sizes": "~1.1.0"
      }
    }
    """

struct ContentView: View {
    @ObservedObject var vm: CodeMirrorVM = .init()
    var body: some View {
        VStack {
            CodeMirror(vm)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationTitle("Example")
                .onAppear {
                    vm.setContent(jsonString)
                }
                .toolbar {
                    ToolbarItem {
                        Toggle(isOn: $vm.lineNumber, label: { Text("Line Number") })
                            .toggleStyle(.checkbox)
                    }
                    ToolbarItem {
                        Toggle(isOn: $vm.lineWrapping, label: { Text("Line Wrapping") })
                            .toggleStyle(.checkbox)
                    }
                    ToolbarItem {
                        Button {
                            Task {
                                let content = try? await vm.getContent()
                                print(content ?? "")
                            }
                        } label: {
                            Text("GET")
                        }
                    }
                    ToolbarItem {
                        Button {
                            vm.setContent("Hello World!")
                        } label: {
                            Text("SET")
                        }
                    }
                    ToolbarItem {
                        Toggle(isOn: $vm.readOnly, label: { Text("Read Only") })
                            .toggleStyle(.checkbox)
                    }
                    ToolbarItem {
                        Picker("Lang", selection: $vm.language) {
                            ForEach(Language.allCases, id: \.rawValue) {
                                Text($0.rawValue).tag($0)
                            }
                        }
                    }
                    ToolbarItem {
                        Picker("Theme", selection: $vm.theme) {
                            ForEach(Themes.allCases, id: \.rawValue) {
                                Text($0.rawValue).tag($0)
                            }
                        }
                    }
                }
        }
    }
}

#Preview {
    ContentView()
}
