//
//  CodeMirror.swift
//  CodeMirror
//
//  Created by wong on 8/12/25.
//

import SwiftUI

public struct CodeMirror: View {
    @ObservedObject var vm: CodeMirrorVM = .init()
    @Binding var value: String
    @FocusState private var isFocused: Bool
    public init(value: Binding<String>, prompt: String = "") {
        self._value = value
        self.vm.placeholder = prompt
    }
    public var body: some View {
        CodeMirrorView(vm, value: $value)
            .focused($isFocused)
            .onChange(of: isFocused, initial: true) { old, val in
                if old != val {
                    vm.focused = val
                }
            }
    }
    /// Set Line Wrapping
    public func cmLineWrapping(_ value: Binding<Bool>) -> CodeMirror {
        vm.lineWrapping = value.wrappedValue
        return self as CodeMirror
    }
    /// Show Line Numbers
    public func cmLineNumber(_ value: Binding<Bool>) -> CodeMirror {
        vm.lineNumber = value.wrappedValue
        return self as CodeMirror
    }
    /// Set Editor Read-Only
    public func cmReadOnly(_ value: Binding<Bool>) -> CodeMirror {
        vm.readOnly = value.wrappedValue
        return self as CodeMirror
    }
    /// Set Enabled Search
    public func cmEnabledSearch(_ value: Binding<Bool>) -> CodeMirror {
        vm.enabledSearch = value.wrappedValue
        return self as CodeMirror
    }
    /// Set Programming Language
    public func cmLanguage(_ value: Binding<Language>) -> CodeMirror {
        vm.language = value.wrappedValue
        return self as CodeMirror
    }
    /// Set Programming Language
    public func cmFoldGutter(_ value: Binding<Bool>) -> CodeMirror {
        vm.foldGutter = value.wrappedValue
        return self as CodeMirror
    }
    /// Set Theme
    public func cmTheme(_ value: Binding<Themes>) -> CodeMirror {
        vm.theme = value.wrappedValue
        return self as CodeMirror
    }
    public func onLoadSuccess(perform action: (() -> Void)? = nil) -> CodeMirror {
        vm.onLoadSuccess = action
        return self as CodeMirror
    }
    public func onLoadFailed(perform action: ((Error) -> Void)? = nil) -> CodeMirror {
        vm.onLoadFailed = action
        return self as CodeMirror
    }
    public func onContentChange(perform action: (() -> Void)? = nil) -> CodeMirror {
        vm.onContentChange = action
        return self as CodeMirror
    }
}

#if DEBUG
#Preview {
    @Previewable @State var code: String = """
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
    CodeMirror(value: $code)
}
#endif
