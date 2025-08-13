//
//  ContentView.swift
//  Example
//
//  Created by 王楚江 on 8/11/25.
//

import SwiftUI
import CodeMirror

let jsonString = """
    <body>
        <h1>DevHub</h1>
    </body>
    """

struct ContentView: View {
    @State var value: String = jsonString
    @State var lineWrapping = false
    @State var lineNumber = true
    @State var foldGutter = false
    @State var readOnly = false
    @State var language: Language = .html
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
                .onContentChange { value in
                    print("@@@3 Content Did Change", value)
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
                                Text("\($0.name): .\($0.rawValue)").tag($0)
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
