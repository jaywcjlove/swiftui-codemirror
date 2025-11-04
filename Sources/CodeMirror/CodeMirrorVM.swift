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

import Foundation

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
    @Published public var fontSize: CGFloat = 14
    
    @Published public var focused = false
    
    public var onLoadSuccess: (() -> Void)?
    public var onLoadFailed: ((Error) -> Void)?
    public var onContentChange: ((_ value: String) -> Void)?
    
    internal var executeJS: ((JavascriptFunction, JavascriptCallback?) -> Void)!
    
    // 添加防抖机制和初始化状态跟踪
    private var setContentTimer: Timer?
    private let setContentDebounceDelay: TimeInterval = 0.1
    private var isInitialized = false
    
    public init(
        lineWrapping: Bool = false,
        lineNumber: Bool = true,
        highlightActiveLine: Bool = true,
        foldGutter: Bool = false,
        readOnly: Bool = false,
        enabledSearch: Bool = false,
        placeholder: String = "",
        language: Language = .json,
        theme: Themes = .vscodedark,
        fontSize: CGFloat = 14
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
        self.fontSize = fontSize
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
        // 如果是初始化阶段，使用立即设置避免延迟
        if !isInitialized {
            setContentImmediately(value)
            return
        }
        
        // 取消之前的定时器
        setContentTimer?.invalidate()
        
        // 捕获 value 参数以避免在闭包中访问 actor 隔离的属性
        let capturedValue = value
        
        // 创建新的防抖定时器
        setContentTimer = Timer.scheduledTimer(withTimeInterval: setContentDebounceDelay, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.executeJS(
                    JavascriptFunction(
                        functionString: "CodeMirror.setContent(value)",
                        args: ["value": capturedValue]
                    ),
                    nil
                )
            }
        }
    }
    
    // 立即设置内容，用于初始化时不需要防抖
    internal func setContentImmediately(_ value: String) {
        executeJS(
            JavascriptFunction(
                functionString: "CodeMirror.setContent(value)",
                args: ["value": value]
            ),
            nil
        )
    }
    
    // 标记为已初始化
    internal func markAsInitialized() {
        isInitialized = true
    }
}
