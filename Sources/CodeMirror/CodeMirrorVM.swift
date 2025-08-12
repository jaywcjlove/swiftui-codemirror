//
//  CodeMirrorVM.swift
//  CodeMirror
//
//  Created by 王楚江 on 8/11/25.
//

import SwiftUI

public enum Language: String, CaseIterable, Hashable {
    case javascript
    case jsx
    case json
    case html
    case vue
    case css
    case xml
    case python
    case cpp
    case php
    case java
    case rust
    case sass
    case less
    case yaml
    case go
    case sql
    case mysql
    case pgsql
    case liquid
    case wast
    case swift
    case txt
}

public enum Themes: String, CaseIterable, Hashable {
    case abcdef
    case abyss
    case androidstudio
    case andromeda
    case atomone
    case aura
    case basiclight
    case basicdark
    case bbedit
    case bespin
    case consoledark
    case consolelight
    case copilot
    case darcula
    case dracula
    case duotonelight
    case duotonedark
    case eclipse
    case githublight
    case githubdark
    case gruvboxdark
    case gruvboxlight
    case kimbie
    case materiallight
    case materialdark
    case monokai
    case monokaidimmed
    case noctislilac
    case nord
    case okaidia
    case red
    case quietlight
    case solarizedlight
    case solarizeddark
    case sublime
    case tokyonight
    case tokyonightstorm
    case tokyonightday
    case tomorrownightblue
    case vscodedark
    case vscodelight
    case whitelight
    case whitedark
    case xcodelight
    case xcodedark
}

@MainActor
public class CodeMirrorVM: ObservableObject {
    @Published public var lineWrapping = false
    @Published public var lineNumber = true
    @Published public var foldGutter = false
    @Published public var readOnly = false
    @Published public var enabledSearch = false
    @Published public var language: Language = .json
    @Published public var theme: Themes = .vscodelight
    
    public var onLoadSuccess: (() -> Void)?
    public var onLoadFailed: ((Error) -> Void)?
    public var onContentChange: (() -> Void)?
    
    internal var executeJS: ((JavascriptFunction, JavascriptCallback?) -> Void)!
    
    public init(
        lineWrapping: Bool = false,
        lineNumber: Bool = false,
        foldGutter: Bool = false,
        readOnly: Bool = false,
        enabledSearch: Bool = false,
        language: Language = .json,
        theme: Themes = .vscodedark
    ) {
        self.lineWrapping = lineWrapping
        self.lineNumber = lineNumber
        self.foldGutter = foldGutter
        self.readOnly = readOnly
        self.enabledSearch = enabledSearch
        self.language = language
        self.theme = theme
    }
    
    private func executeJSAsync<T>(f: JavascriptFunction) async throws -> T? where T: Sendable {
        return try await withCheckedThrowingContinuation { continuation in
            executeJS(f) { result in
                continuation.resume(with: result.map { $0 as? T })
            }
        }
    }
    public func getContent() async throws -> String? {
        try await executeJSAsync(
            f: JavascriptFunction(
                functionString: "CodeMirror.getContent()"
            )
        )
    }
    public func setContent(_ value: String) {
        executeJS(
            JavascriptFunction(
                functionString: "CodeMirror.setContent(value)",
                args: ["value": value]
            ),
            nil
        )
    }
}
