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
    @State var value: String = jsonString
    @State var lineWrapping = false
    @State var lineNumber = true
    @State var foldGutter = false
    @State var readOnly = false
    @State var language: Language = .json
    @State var theme: Themes = .vscodedark
    @State var enabledSearch = false
    @State var count: Int = 0
    @FocusState var input: InputFocused?
    @State private var textForTextField: String = ""
    enum InputFocused: Hashable {
        case text, output, test
    }
    var body: some View {
        VStack(spacing: 0) {
//            TextField("Placeholder", text: $textForTextField)
//            ScrollView {
//                Text(value)
//            }
//            .frame(height: 120)
            CodeMirror(value: $value, prompt: String(localized: "Please enter text"))
                .cmLineNumber($lineNumber)
                .cmLineWrapping($lineWrapping)
                .cmFoldGutter($foldGutter)
                .cmReadOnly($readOnly)
                .cmLanguage($language)
                .cmEnabledSearch($enabledSearch)
                .cmTheme($theme)
                .onLoadSuccess() {
                    print("Hello!")
                }
                .onLoadFailed { error in
                    print("@@@2 \(#function) \(error)")
                }
                .onContentChange {
                    print("@@@3 Content Did Change")
                }
                .focused($input, equals: .text)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    HStack {
                        Menu {
                            Toggle(isOn: $lineNumber, label: { Text("Line Number") })
                                .toggleStyle(.checkbox)
                            Toggle(isOn: $lineWrapping, label: { Text("Line Wrapping") })
                                .toggleStyle(.checkbox)
                            Toggle(isOn: $foldGutter, label: { Text("Fold Gutter") })
                                .toggleStyle(.checkbox)
                            Toggle(isOn: $readOnly, label: { Text("Read Only") })
                                .toggleStyle(.checkbox)
                            Toggle(isOn: $enabledSearch, label: { Text("Enabled Search") })
                                .toggleStyle(.checkbox)
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.secondary)
                        }
                        .menuIndicator(.hidden)
                        .buttonStyle(.plain)
                        Button {
                            count += 1
                            value = "Hello World! \(count)"
                        } label: {
                            Text("SET")
                        }
                        Button {
                            self.input = .text
                        } label: {
                            Text("Focused text")
                        }
                        Spacer()
                        Picker("Lang", selection: $language) {
                            ForEach(Language.allCases, id: \.rawValue) {
                                Text("Lang: \($0.rawValue)").tag($0)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 134)
                        Picker("Theme", selection: $theme) {
                            ForEach(Themes.allCases, id: \.rawValue) {
                                Text("Theme: \($0.rawValue)").tag($0)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 140)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 6)
                }
        }
        .onAppear() {
            input = .text
        }
    }
}

#Preview {
    ContentView()
}
