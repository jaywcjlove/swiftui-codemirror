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
        let indexURL = Bundle.module.url(
            forResource: "index",
            withExtension: "html",
            subdirectory: "web.bundle"
        )
        let baseURL = Bundle.module.url(forResource: "web.bundle", withExtension: nil)
        let data = try! Data.init(contentsOf: indexURL!)
        webView.load(data, mimeType: "text/html", characterEncodingName: "utf-8", baseURL: baseURL!)
        context.coordinator.webView = webView
        return webView
    }
    
    private func updateWebView(context: Context) {
        let vm = self.vm
        let coordinator = context.coordinator
        
        // 只在值真正改变时才更新
        if coordinator.lastTheme != vm.theme {
            coordinator.lastTheme = vm.theme
            coordinator.queueJavascriptFunction(
                JavascriptFunction(
                    functionString: "CodeMirror.setTheme(value)",
                    args: ["value": vm.theme.rawValue]
                )
            )
        }
        
        if coordinator.lastLineWrapping != vm.lineWrapping {
            coordinator.lastLineWrapping = vm.lineWrapping
            coordinator.queueJavascriptFunction(
                JavascriptFunction(
                    functionString: "CodeMirror.setLineWrapping(value)",
                    args: ["value": vm.lineWrapping]
                )
            )
        }
        
        if coordinator.lastLineNumber != vm.lineNumber {
            coordinator.lastLineNumber = vm.lineNumber
            coordinator.queueJavascriptFunction(
                JavascriptFunction(
                    functionString: "CodeMirror.setLineNumber(value)",
                    args: ["value": vm.lineNumber]
                )
            )
        }
        
        if coordinator.lastFoldGutter != vm.foldGutter {
            coordinator.lastFoldGutter = vm.foldGutter
            coordinator.queueJavascriptFunction(
                JavascriptFunction(
                    functionString: "CodeMirror.setFoldGutter(value)",
                    args: ["value": vm.foldGutter]
                )
            )
        }
        
        if coordinator.lastReadOnly != vm.readOnly {
            coordinator.lastReadOnly = vm.readOnly
            coordinator.queueJavascriptFunction(
                JavascriptFunction(
                    functionString: "CodeMirror.setReadOnly(value)",
                    args: ["value": vm.readOnly]
                )
            )
        }
        
        if coordinator.lastHighlightActiveLine != vm.highlightActiveLine {
            coordinator.lastHighlightActiveLine = vm.highlightActiveLine
            coordinator.queueJavascriptFunction(
                JavascriptFunction(
                    functionString: "CodeMirror.setHighlightActiveLine(value)",
                    args: ["value": vm.highlightActiveLine]
                )
            )
        }
        
        if coordinator.lastEnabledSearch != vm.enabledSearch {
            coordinator.lastEnabledSearch = vm.enabledSearch
            coordinator.queueJavascriptFunction(
                JavascriptFunction(
                    functionString: "CodeMirror.setEnabledSearch(value)",
                    args: ["value": vm.enabledSearch]
                )
            )
        }
        
        if coordinator.lastLanguage != vm.language {
            coordinator.lastLanguage = vm.language
            coordinator.queueJavascriptFunction(
                JavascriptFunction(
                    functionString: "CodeMirror.setLanguage(value)",
                    args: ["value": vm.language.rawValue]
                )
            )
        }
        
        if coordinator.lastPlaceholder != vm.placeholder {
            coordinator.lastPlaceholder = vm.placeholder
            coordinator.queueJavascriptFunction(
                JavascriptFunction(
                    functionString: "CodeMirror.setPlaceholder(value)",
                    args: ["value": vm.placeholder]
                )
            )
        }
        
        if coordinator.lastFontSize != vm.fontSize {
            coordinator.lastFontSize = vm.fontSize
            coordinator.queueJavascriptFunction(
                JavascriptFunction(
                    functionString: "CodeMirror.setFontSize(value)",
                    args: ["value": vm.fontSize]
                )
            )
        }
        
        if coordinator.lastFocused != vm.focused {
            coordinator.lastFocused = vm.focused
            coordinator.queueJavascriptFunction(
                JavascriptFunction(
                    functionString: vm.focused == true ? "CodeMirror.setFocus()" : "CodeMirror.setBlur()",
                    args: [:]
                )
            )
        }
        
        // 内容更新：只在外部值变化且不是来自编辑器本身时才更新
        if coordinator.lastValue != value {
            coordinator.lastValue = value
            coordinator.queueJavascriptFunction(
                JavascriptFunction(
                    functionString: "CodeMirror.setContent(value)",
                    args: ["value": value]
                )
            )
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

    init(parent: CodeMirrorView, viewModel: CodeMirrorVM) {
        self.parent = parent
        self.viewModel = viewModel
    }
    
    internal func queueJavascriptFunction(
        _ function: JavascriptFunction,
        callback: JavascriptCallback? = nil
    ) {
        if pageLoaded {
            evaluateJavascript(function: function, callback: callback)
        }
        else {
            pendingFunctions.append((function, callback))
        }
    }
    
    private func callPendingFunctions() {
        for (function, callback) in pendingFunctions {
            evaluateJavascript(function: function, callback: callback)
        }
        pendingFunctions.removeAll()
    }

    private func evaluateJavascript(
        function: JavascriptFunction,
        callback: JavascriptCallback? = nil
    ) {
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
        parent.vm.setContentImmediately(parent.value)
        parent.vm.onLoadSuccess?()
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
