// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI
import WebKit

#if canImport(AppKit)
    import AppKit
    public typealias NativeView = NSViewRepresentable
#elseif canImport(UIKit)
    import UIKit
    public typealias NativeView = UIViewRepresentable
#endif

@MainActor
public struct CodeMirrorView: NativeView {
    @ObservedObject public var vm: CodeMirrorVM
    @Binding var value: String
    public init(
        _ viewModel: CodeMirrorVM,
        value: Binding<String>
    ) {
        self.vm = viewModel
        self._value = value
    }
#if canImport(AppKit)
    public func makeNSView(context: Context) -> WKWebView {
        createWebView(context: context)
    }
    public func updateNSView(_ nsView: WKWebView, context: Context) {
        updateWebView(context: context)
    }
#elseif canImport(UIKit)
    public func makeUIView(context: Context) -> WKWebView {
        createWebView(context: context)
    }
    public func updateUIView(_ nsView: WKWebView, context: Context) {
        updateWebView(context: context)
    }
#endif
    private func createWebView(context: Context) -> WKWebView {
        let preferences = WKPreferences()
        let userController = WKUserContentController()
        userController.add(context.coordinator, name: ScriptMessageName.codeMirrorDidReady)
        userController.add(context.coordinator, name: ScriptMessageName.codeMirrorContentDidChange)

        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        configuration.userContentController = userController

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        #if os(OSX)
            webView.setValue(false, forKey: "drawsBackground")  // prevent white flicks
            webView.allowsMagnification = false
        #elseif os(iOS)
            webView.isOpaque = false
        #endif
        
        context.coordinator.webView = webView
        
        // 异步加载 HTML 内容，避免阻塞主线程
        Task { @MainActor in
            await loadWebViewContent(webView: webView)
        }
        
        return webView
    }
    
    @MainActor
    private func loadWebViewContent(webView: WKWebView) async {
        let result = await Task.detached { () -> (data: Data?, baseURL: URL?, mimeType: String?) in
            guard let indexURL = Bundle.module.url(
                forResource: "index",
                withExtension: "html",
                subdirectory: "web.bundle"
            ),
            let baseURL = Bundle.module.url(forResource: "web.bundle", withExtension: nil),
            let data = try? Data(contentsOf: indexURL) else {
                return (data: nil, baseURL: nil, mimeType: nil)
            }
            return (data: data, baseURL: baseURL, mimeType: "text/html")
        }.value
        
        if let data = result.data, 
           let baseURL = result.baseURL, 
           let mimeType = result.mimeType {
            webView.load(data, mimeType: mimeType, characterEncodingName: "utf-8", baseURL: baseURL)
        }
    }
    
    private func updateWebView(context: Context) {
        let vm = self.vm
        let coordinator = context.coordinator
        
        // 如果 WebView 还没有准备好，延迟更新
        guard coordinator.webView != nil else { return }
        
        // 批量收集需要更新的配置，减少单独的 JS 调用
        var pendingUpdates: [JavascriptFunction] = []
        
        // 主题更新
        if coordinator.lastTheme != vm.theme {
            coordinator.lastTheme = vm.theme
            pendingUpdates.append(
                JavascriptFunction(
                    functionString: "CodeMirror.setTheme(value)",
                    args: ["value": vm.theme.rawValue]
                )
            )
        }
        
        // 行包装更新
        if coordinator.lastLineWrapping != vm.lineWrapping {
            coordinator.lastLineWrapping = vm.lineWrapping
            pendingUpdates.append(
                JavascriptFunction(
                    functionString: "CodeMirror.setLineWrapping(value)",
                    args: ["value": vm.lineWrapping]
                )
            )
        }
        
        // 行号更新
        if coordinator.lastLineNumber != vm.lineNumber {
            coordinator.lastLineNumber = vm.lineNumber
            pendingUpdates.append(
                JavascriptFunction(
                    functionString: "CodeMirror.setLineNumber(value)",
                    args: ["value": vm.lineNumber]
                )
            )
        }
        
        // 折叠装订线更新
        if coordinator.lastFoldGutter != vm.foldGutter {
            coordinator.lastFoldGutter = vm.foldGutter
            pendingUpdates.append(
                JavascriptFunction(
                    functionString: "CodeMirror.setFoldGutter(value)",
                    args: ["value": vm.foldGutter]
                )
            )
        }
        
        // 只读状态更新
        if coordinator.lastReadOnly != vm.readOnly {
            coordinator.lastReadOnly = vm.readOnly
            pendingUpdates.append(
                JavascriptFunction(
                    functionString: "CodeMirror.setReadOnly(value)",
                    args: ["value": vm.readOnly]
                )
            )
        }
        
        // 高亮当前行更新
        if coordinator.lastHighlightActiveLine != vm.highlightActiveLine {
            coordinator.lastHighlightActiveLine = vm.highlightActiveLine
            pendingUpdates.append(
                JavascriptFunction(
                    functionString: "CodeMirror.setHighlightActiveLine(value)",
                    args: ["value": vm.highlightActiveLine]
                )
            )
        }
        
        // 搜索功能更新
        if coordinator.lastEnabledSearch != vm.enabledSearch {
            coordinator.lastEnabledSearch = vm.enabledSearch
            pendingUpdates.append(
                JavascriptFunction(
                    functionString: "CodeMirror.setEnabledSearch(value)",
                    args: ["value": vm.enabledSearch]
                )
            )
        }
        
        // 语言更新
        if coordinator.lastLanguage != vm.language {
            coordinator.lastLanguage = vm.language
            pendingUpdates.append(
                JavascriptFunction(
                    functionString: "CodeMirror.setLanguage(value)",
                    args: ["value": vm.language.rawValue]
                )
            )
        }
        
        // 占位符更新
        if coordinator.lastPlaceholder != vm.placeholder {
            coordinator.lastPlaceholder = vm.placeholder
            pendingUpdates.append(
                JavascriptFunction(
                    functionString: "CodeMirror.setPlaceholder(value)",
                    args: ["value": vm.placeholder]
                )
            )
        }
        
        // 字体大小更新
        if coordinator.lastFontSize != vm.fontSize {
            coordinator.lastFontSize = vm.fontSize
            pendingUpdates.append(
                JavascriptFunction(
                    functionString: "CodeMirror.setFontSize(value)",
                    args: ["value": vm.fontSize]
                )
            )
        }
        
        // 焦点状态更新
        if coordinator.lastFocused != vm.focused {
            coordinator.lastFocused = vm.focused
            pendingUpdates.append(
                JavascriptFunction(
                    functionString: vm.focused == true ? "CodeMirror.setFocus()" : "CodeMirror.setBlur()",
                    args: [:]
                )
            )
        }
        
        // 批量执行配置更新，降低单次调用的频率
        if !pendingUpdates.isEmpty {
            Task { @MainActor in
                // 使用微延迟，避免阻塞 UI
                try? await Task.sleep(nanoseconds: 1_000_000) // 1ms
                for update in pendingUpdates {
                    coordinator.queueJavascriptFunction(update)
                }
            }
        }
        
        // 内容更新：只在外部值变化且不是来自编辑器本身时才更新
        if coordinator.lastValue != value {
            coordinator.lastValue = value
            // 内容更新使用更高优先级，但也异步执行
            Task { @MainActor in
                coordinator.queueJavascriptFunction(
                    JavascriptFunction(
                        functionString: "CodeMirror.setContent(value)",
                        args: ["value": value]
                    )
                )
            }
        }
    }
    public func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator(parent: self, viewModel: vm)
        vm.executeJS = { fn, cb in
            coordinator.queueJavascriptFunction(fn, callback: cb)
        }
        return coordinator
    }
}


@MainActor
public class Coordinator: NSObject {
    var parent: CodeMirrorView
    var viewModel: CodeMirrorVM
    var webView: WKWebView!
    private var pageLoaded = false
    private var pendingFunctions = [(JavascriptFunction, JavascriptCallback?)]()
    
    // 缓存上次的值，避免重复更新
    internal var lastTheme: Themes?
    internal var lastLineWrapping: Bool?
    internal var lastLineNumber: Bool?
    internal var lastFoldGutter: Bool?
    internal var lastReadOnly: Bool?
    internal var lastHighlightActiveLine: Bool?
    internal var lastEnabledSearch: Bool?
    internal var lastLanguage: Language?
    internal var lastPlaceholder: String?
    internal var lastFontSize: CGFloat?
    internal var lastFocused: Bool?
    internal var lastValue: String?
    
    // 添加队列来批量处理 JavaScript 调用
    private var jsQueue = DispatchQueue(label: "codemirror.js.queue", qos: .userInitiated)
    private var jsExecutionTimer: Timer?

    init(parent: CodeMirrorView, viewModel: CodeMirrorVM) {
        self.parent = parent
        self.viewModel = viewModel
    }
    
    internal func queueJavascriptFunction(
        _ function: JavascriptFunction,
        callback: JavascriptCallback? = nil
    ) {
        if pageLoaded {
            // 使用微延迟执行，避免阻塞主线程
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 100_000) // 0.1ms
                self.evaluateJavascript(function: function, callback: callback)
            }
        }
        else {
            pendingFunctions.append((function, callback))
        }
    }
    
    private func callPendingFunctions() {
        // 异步批量执行待处理的函数，避免阻塞页面加载
        Task { @MainActor in
            for (function, callback) in pendingFunctions {
                evaluateJavascript(function: function, callback: callback)
                // 在函数之间添加微小延迟，防止 WebView 过载
                try? await Task.sleep(nanoseconds: 500_000) // 0.5ms
            }
            pendingFunctions.removeAll()
        }
    }

    private func evaluateJavascript(
        function: JavascriptFunction,
        callback: JavascriptCallback? = nil
    ) {
        // 确保 WebView 存在
        guard let webView = webView else { return }
        
        // not sure why but callAsyncJavaScript always callback with result of nil
        if let callback = callback {
            webView.evaluateJavaScript(function.functionString) { (response, error) in
                if let error = error {
                    callback(.failure(error))
                }
                else {
                    callback(.success(response))
                }
            }
        }
        else {
            webView.callAsyncJavaScript(
                function.functionString,
                arguments: function.args,
                in: nil,
                in: .page
            ) { (result) in
                switch result {
                case .failure(let error):
                    callback?(.failure(error))
                case .success(let data):
                    callback?(.success(data))
                }
            }
        }
    }
}

extension Coordinator: WKScriptMessageHandler {
    public func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        switch message.name {
        case ScriptMessageName.codeMirrorDidReady:
            pageLoaded = true
            callPendingFunctions()
        case ScriptMessageName.codeMirrorContentDidChange:
            if let messageBody = message.body as? String {
                // 同时更新缓存值，避免循环更新
                lastValue = messageBody
                parent.value = messageBody
                parent.vm.onContentChange?(messageBody)
            }
        default:
            print("CodeMirrorWebView receive \(message.name) \(message.body)")
        }
    }
}

extension Coordinator: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // 异步设置初始内容，避免阻塞主线程
        Task { @MainActor in
            parent.vm.setContentImmediately(parent.value)
            parent.vm.markAsInitialized()
            parent.vm.onLoadSuccess?()
        }
    }

    public func webView(
        _ webView: WKWebView,
        didFail navigation: WKNavigation!,
        withError error: Error
    ) {
        parent.vm.onLoadFailed?(error)
    }

    public func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        parent.vm.onLoadFailed?(error)
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
    @ObservedObject var vm: CodeMirrorVM = .init()
    VStack {
        CodeMirrorView(vm, value: $code)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Example")
//            .onAppear {
//                vm.setContent(jsonString)
//            }
            .toolbar {
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
            }
    }
}
#endif
