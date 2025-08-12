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
        context.coordinator.queueJavascriptFunction(
            JavascriptFunction(
                functionString: "CodeMirror.setTheme(value)",
                args: ["value": vm.theme.rawValue]
            )
        )
        context.coordinator.queueJavascriptFunction(
            JavascriptFunction(
                functionString: "CodeMirror.setLineWrapping(value)",
                args: ["value": vm.lineWrapping]
            )
        )
        context.coordinator.queueJavascriptFunction(
            JavascriptFunction(
                functionString: "CodeMirror.setLineNumber(value)",
                args: ["value": vm.lineNumber]
            )
        )
        context.coordinator.queueJavascriptFunction(
            JavascriptFunction(
                functionString: "CodeMirror.setFoldGutter(value)",
                args: ["value": vm.foldGutter]
            )
        )
        context.coordinator.queueJavascriptFunction(
            JavascriptFunction(
                functionString: "CodeMirror.setReadOnly(value)",
                args: ["value": vm.readOnly]
            )
        )
        context.coordinator.queueJavascriptFunction(
            JavascriptFunction(
                functionString: "CodeMirror.setEnabledSearch(value)",
                args: ["value": vm.enabledSearch]
            )
        )
        context.coordinator.queueJavascriptFunction(
            JavascriptFunction(
                functionString: "CodeMirror.setLanguage(value)",
                args: ["value": vm.language.rawValue]
            )
        )
        context.coordinator.queueJavascriptFunction(
            JavascriptFunction(
                functionString: "CodeMirror.setPlaceholder(value)",
                args: ["value": vm.placeholder]
            )
        )
        context.coordinator.queueJavascriptFunction(
            JavascriptFunction(
                functionString: vm.focused == true ? "CodeMirror.setFocus()" : "CodeMirror.setBlur()",
                args: [:]
            )
        )
        context.coordinator.queueJavascriptFunction(
            JavascriptFunction(
                functionString: "CodeMirror.setContent(value)",
                args: ["value": value]
            )
        )
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
        parent.vm.setContent(parent.value)
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
