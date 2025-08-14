//
//  CodeMirrorVM.swift
//  CodeMirror
//
//  Created by 王楚江 on 8/11/25.
//

#if canImport(AppKit)
import AppKit   // macOS
#endif

#if canImport(UIKit)
import UIKit    // iOS / iPadOS
#endif

@MainActor
public class CodeMirrorVM: ObservableObject {
    @Published public var lineWrapping = false
    @Published public var lineNumber = true
    @Published public var highlightActiveLine = true
    @Published public var foldGutter = false
    @Published public var readOnly = false
    @Published public var enabledSearch = false
    @Published public var language: Language = .json
    @Published public var theme: Themes = .vscodelight
    @Published public var placeholder: String = ""
    
    @Published public var focused = false
    
    public var onLoadSuccess: (() -> Void)?
    public var onLoadFailed: ((Error) -> Void)?
    public var onContentChange: ((_ value: String) -> Void)?
    
    internal var executeJS: ((JavascriptFunction, JavascriptCallback?) -> Void)!
    
    public init(
        lineWrapping: Bool = false,
        lineNumber: Bool = true,
        highlightActiveLine: Bool = true,
        foldGutter: Bool = false,
        readOnly: Bool = false,
        enabledSearch: Bool = false,
        placeholder: String = "",
        language: Language = .json,
        theme: Themes = .vscodedark
    ) {
        self.lineWrapping = lineWrapping
        self.lineNumber = lineNumber
        self.highlightActiveLine = highlightActiveLine
        self.foldGutter = foldGutter
        self.readOnly = readOnly
        self.enabledSearch = enabledSearch
        self.placeholder = placeholder
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
