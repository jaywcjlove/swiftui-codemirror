//
//  JavascriptFunction.swift
//  CodeMirror
//
//  Created by 王楚江 on 8/11/25.
//

public typealias JavascriptCallback = (Result<Any?, Error>) -> Void

public struct JavascriptFunction {

    public let functionString: String
    public let args: [String: Any]

    public init(
        functionString: String,
        args: [String: Any] = [:]
    ) {
        self.functionString = functionString
        self.args = args
    }
}

public enum ScriptMessageName {
    public static let codeMirrorDidReady = "codeMirrorDidReady"
    public static let codeMirrorContentDidChange = "codeMirrorContentDidChange"
}
